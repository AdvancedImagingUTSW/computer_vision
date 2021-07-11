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

#Iterate through the Positions and Move Files
echo "Moving Files"
position_idx=1
while [ -d "$1/position $position_idx" ]
do
	# Iterate through the channels
	channel_idx=0
	time_idx=_000000
	echo 
	while [ -f "$1/position $position_idx/1_CH0$channel_idx$time_idx.tif" ]
	do
		echo "position $position_idx/1_CH0$channel_idx$time_idx.tif exists" 
		# Move File to Common Directory
		temp_var=_$position_idx
		mv "$1/position $position_idx/1_CH0$channel_idx$time_idx.tif" "$1/1_CH0$channel_idx$temp_var.tif"
		channel_idx=`expr $channel_idx + 1`
	done

   	position_idx=`expr $position_idx + 1`
done

echo "Performing Maximum Intensity Projection"
ls -v *.tif | parallel --will-cite -j 15 gmic {} -a z -orthoMIP -o $1/mips/{}

echo "Maximum Intensity Projection Complete"
