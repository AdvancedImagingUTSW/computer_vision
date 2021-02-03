#!/bin/bash
clear
module add cuda101/toolkit/10.1.243
module load python/3.6.4-anaconda
source activate cellpose

# input_directory="/archive/MIL/dean/20210201_segmentation_test/filo/"
input_directory="/archive/MIL/dean/20210201_segmentation_test/blebby/"

cd $input_directory

for i in 125 150
do
	echo "Processing Scale $i"

	# Clear the Pytorch Memory
	python -c "import torch; torch.cuda.empty_cache(); print('Done Emptying Cache')"

	# Run Cellpose
	python -m cellpose \
	--dir $input_directory \
	--pretrained_model cyto \
	--diameter $i \
	--use_gpu \
	--no_npy \
	--save_tif \
	--do_3D 

	cp 1_CAM01_000000_cp_masks.tif segmented/$i.tif
	rm 1_CAM01_000000_cp_masks.tif
done
