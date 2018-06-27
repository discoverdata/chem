# Welcome 
### Varun Khanna
##  Acknowledgement
All the credit should go to GROMACS authors for making such a wonderful molecular dynamics software GROMACS.
# This script runs MD using GROMACS
Download the script, default_mdp.zip folder and the example folder (optional) to your local computer.
## Steps to run the script 
- (Required) Make sure you have GROMACS installed (I have tested it on version 2016.3 on ubuntu). However, it should work on versions 5.1.0 and above. 
- (Required) Unzip the default_mdp folder using "unzip default_mdp.zip" command.
- (Optional) Provide the mdp files in the same folder you are running the md.sh script or the script will use default files and run 1ns simulation
- (Optional) Modify the forcefield and water model used for toplogy generation. Othewise it uses amber99sb forcefield and spce water model
- You are ready to go!!
 ```diff
+ run bash md.sh 
+ and enter the pdb file on prompt.
``` 
 
- Happy Simulation. 
