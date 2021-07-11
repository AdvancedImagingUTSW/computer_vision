#!/bin/bash
# Clear the Terminal
clear

# Load the Modules Necessary
module load gmic
module load parallel

# Move to the directory
cd $1

# Make the directory to save files to.
if [ -d "$1/mips" ] 
then
    	echo "Directory $1/mips exists." 
else
	mkdir mips
fi

ls -v *.tif | parallel --will-cite -j 15 gmic {} -a z -orthoMIP -o $1/mips/{}

echo "Maximum Intensity Projection Complete"
