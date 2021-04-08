#!/bin/bash
# Clear the Terminal
clear

# Load the Modules Necessary
module load gmic
module load parallel

# Move to the directory
cd $1

# Make the directory to save files to.
if [ -d "/home2/kdean/Desktop/mips" ] 
then
    	echo "Directory /home2/kdean/Desktop/mips exists." 
	rm /home2/kdean/Desktop/mips/*.tif
else
	mkdir /home2/kdean/Desktop/mips
fi

ls -v *.tif | parallel --will-cite -j 15 gmic {} -a z -orthoMIP -o /home2/kdean/Desktop/mips/{}

echo "Maximum Intensity Projection Complete"
