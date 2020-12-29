#!/bin/bash
clear
echo "Pulling All Danuser Repos from git.biohpc.swmed.edu"

echo "Pulling applications"
cd /home2/kdean/Documents/MATLAB/applications
git pull

echo "Pulling common"
cd /home2/kdean/Documents/MATLAB/common
git pull

echo "Pulling documentation"
cd /home2/kdean/Documents/MATLAB/documentation
git pull

echo "Pulling extern"
cd /home2/kdean/Documents/MATLAB/extern
git pull

