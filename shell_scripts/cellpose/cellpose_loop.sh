#!/bin/bash
clear
module add cuda101/toolkit/10.1.243
module load python/3.6.4-anaconda
source activate cellpose

input_directory="/archive/MIL/marciano/20201211_CapillaryLooping/cropped/wt/"
image_base="1_CH00_"

# Create Directory to Save the Final Data to
final_directory="/home2/kdean/Desktop/final_data/"
if [[ ! -e $final_directory ]]; then
    mkdir $final_directory
fi

for i in {000000..000000} #42
do
	# Create a temporary directory to save intermediate results to.
	output_directory="/home2/kdean/Desktop/temp_folder/"
	if [[ ! -e $output_directory ]]; then
	    mkdir $output_directory
	else
		rm -R $output_directory
		mkdir $output_directory
	fi

	image_name=$input_directory$image_base$i.tif
	echo $image_name 
	
	# Open an image in ImageJ and export image series to temp_folder
	/home2/kdean/Desktop/ImageJ-linux64 --headless --console -macro \
	/home2/kdean/Desktop/GitHub/computer_vision/imagej_macros/save_image_to_sequence.ijm \
	"$image_name $output_directory"

	# Clear the Pytorch Memory
	python -c "import torch; torch.cuda.empty_cache(); print('Done Emptying Cache')"

	# Run Cellpose
	python -m cellpose \
	--dir $output_directory \
	--pretrained_model cyto \
	--diameter 30. \
	--save_png \
	--use_gpu \
	--no_npy

	# Combine the Images and Save into the Final Data Directory
	/home2/kdean/Desktop/ImageJ-linux64 --headless --console -macro \
	/home2/kdean/Desktop/GitHub/computer_vision/imagej_macros/save_sequence_to_image.ijm \
	"$output_directory $final_directory/$i.tif"

done