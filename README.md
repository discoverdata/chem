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

## License

The MIT License (MIT)

Copyright (c) 2018 Varun Khanna

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
