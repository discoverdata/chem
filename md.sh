#!/bin/bash 
# This scripts runs MD using GROMACS 
#========================================================================
#
#                FILE: md.sh
#
#               USAGE: bash md.sh
#
#         DESCRIPTION: This script runs 1 ns "protein in water" simulation by default. 
#		       However the user can modify the options in the mdp files for running longer simulation. 
#
#             OPTIONS: -----
#       REQURIREMENTS: please provide MDP files or the script will use the default mdp files 
#                BUGS: -----
#               NOTES: -----
#             AUTHORS: Varun Khanna, varun.khanna@flinders.edu.au
#        ORGANIZATION: Vaxine Pvt Ltd, FMC
#             VERSION: 1.0
#             CREATED: 17-May-2018
#            REVISION: 
#                CITE: If use this script please cite Dr Varun Khanna
#========================================================================
set -e
#=======================================
# Check if gromacs is installed  
gmxrc_loc=$(which GMXRC)
if [ $? -eq 0 ]; then
	echo "OK Gromacs installed"
	source $(which GMXRC) 
else
	echo "Please install Gromacs first"
	exit
fi
#=======================================

# round ${FLOAT} ${PRECESION}
function round {
        printf "%.${2}f" "${1}"
}

# Check if all necessary files are present
echo "Checking if all necessay files are present to run the simulation...."
sleep 1
if ! [[ ( -f 'ions.mdp' ) && ( -f 'minim.mdp' ) && ( -f 'nvt.mdp' ) && ( -f 'npt.mdp' ) && ( -f 'md.mdp') ]]; then 
echo "Following files are missing
1). ions.mdp 
2). minim.mdp 
3). nvt.mdp 
4). npt.mdp
5). md.mdp"

	if ! read -t 5 -p "Do you want me to copy default files [Y/N]: " input; then # -t is time out or assign a defualt value
                input='Y'
        else
                input=$(tr '[:upper:]' '[:lower:]' <<<${input}) # Convert user input to lower case
        fi

        if [[ "${input}" == 'n' || "${input}" == 'no' ]]; then
        #       echo using ${input}
                exit
        else
                echo -e "\nCopying default files"
                sleep 2
                cp default_mdp/*.mdp .
        fi

fi

echo "Please enter the PDB file"
read pdb
if ! [[ ( -e ${pdb} ) && ( -f ${pdb} ) && ( -s ${pdb} ) ]]; then
#if ! [[ ( -e ${pdb} ) && ( -s ${pdb} ) ]]; then
echo "File name $pdb does not exist"
exit 
fi

# Get the basename of the pdb 
file=$(basename ${pdb} .pdb)

# Convert pdb to gro file and generate toplogy files using AMBER99SB forcefield and water model spce
gmx pdb2gmx -f ${pdb} -o ${file}.gro -water spce -ff amber99sb -ignh

# Define box and solvate
gmx editconf -f ${file}.gro -o ${file}_box.gro -c -d 1.2 -bt dodecahedron
gmx solvate -cp ${file}_box.gro -cs spc216.gro -o ${file}_solv.gro -p topol.top

# Add ions
gmx grompp -f ions.mdp -c ${file}_solv.gro -p topol.top -o ions.tpr

charge=$(round $(tac topol.top | grep qtot -m1 | sed 's/.*qtot//' | cut -f2) 0)
#echo $charge 
if [[ $charge =~ ^[-+]?([1-9][[:digit:]]*|0)$ && $charge -ge 1 ]]; then

	echo 13 | gmx genion -s ions.tpr -o ${file}_solv_ions.gro -p topol.top -pname NA -pq 1 -nname CL -nn ${charge} -nq -1 -conc 0.1 -neutral

elif [[ $charge =~ ^[-+]?([1-9][[:digit:]]*|0)$ && $charge -le -1 ]]; then 
	charge=$(( -1 * $charge ))
	echo 13 | gmx genion -s ions.tpr -o ${file}_solv_ions.gro -p topol.top -pname NA -np ${charge} -pq 1 -nname CL -nq -1 -conc 0.1 -neutral

else
	echo 13 | gmx genion -s ions.tpr -o ${file}_solv_ions.gro -p topol.top -pname NA -nname CL -conc 0.1 -neutral
fi

# Energy Minimization
gmx grompp -f minim.mdp -c ${file}_solv_ions.gro -p topol.top -o em.tpr
gmx mdrun -deffnm em 

echo 10 0 | gmx energy -f em.edr -o potential.xvg

# NVT Equilibration

gmx grompp -f nvt.mdp -c em.gro -p topol.top -o nvt.tpr 
gmx mdrun -v -deffnm nvt

echo 15 0 | gmx energy -f nvt.edr -o temp.xvg

# NPT Equilibration

gmx grompp -f npt.mdp -c nvt.gro -p topol.top -o npt.tpr
gmx mdrun -v -deffnm npt

echo 16 0 | gmx energy -f npt.edr -o pressure.xvg
echo 22 0 | gmx energy -f npt.edr -o density.xvg

# Production MD

gmx grompp -f md.mdp -c npt.gro -t npt.cpt -p topol.top -o md_0_1.tpr
gmx mdrun -v -deffnm md_0_1

# Basic analyis 
yes 0 | gmx trjconv -s md_0_1.tpr -f md_0_1.xtc -o md_0_1_noPBC.xtc -pbc mol -ur compact
yes 4 | gmx rms -s md_0_1.tpr -f md_0_1_noPBC.xtc -o rmsdBackbone.xvg -tu ns
yes 1 | gmx rms -s md_0_1.tpr -f md_0_1_noPBC.xtc -o rmsdProtein.xvg -tu ns
yes 4 | gmx rms -s em.tpr -f md_0_1_noPBC.xtc -o rmsd_xtalBakbone.xvg -tu ns
yes 1 | gmx rms -s em.tpr -f md_0_1_noPBC.xtc -o rmsd_xtalProtein.xvg -tu ns
yes 4 | gmx gyrate -s md_0_1.tpr -f md_0_1_noPBC.xtc -o gyrateBackbone.xvg
yes 1 | gmx gyrate -s md_0_1.tpr -f md_0_1_noPBC.xtc -o gyrateProtein.xvg
yes 4 | gmx rmsf -s md_0_1.tpr -f md_0_1_noPBC.xtc -o rmsfBackbone.xvg
yes 1 | gmx rmsf -s md_0_1.tpr -f md_0_1_noPBC.xtc -o rmsfProtein.xvg
yes 4 | gmx sasa -s md_0_1.tpr -f md_0_1_noPBC.xtc -o sasaBackbone.xvg -or res-sasaBackbone.xvg -tv volumeBackbone.xvg
yes 4 | gmx sasa -s md_0_1.tpr -f md_0_1_noPBC.xtc -o sasaProtein.xvg -or res-sasaProtein.xvg -tv volumeProtein.xvg

# Convert xvg to svg files
for xvgs in $(ls *.xvg); do
file=$(basename $xvgs .xvg)
grace -nxy ${file}.xvg  -hdevice SVG -hardcopy -printfile ${file}.svg
done

mkdir -p figures
mv *.svg *.xvg figures

echo "Done MD. Figures are available in figures directory!"

