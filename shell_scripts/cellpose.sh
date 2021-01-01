#!/bin/bash

module add cuda101/toolkit/10.1.243
module load python/3.6.4-anaconda
source activate cellpose

# Specify Directory
# input_directory="/archive/MIL/marciano/20201211_CapillaryLooping/cropped/wt/"
input_directory="/home2/kdean/Desktop/test"

# Clear PyTorch Memory
python -c "import torch; torch.cuda.empty_cache(); print('Done Emptying Cache')"

# Launch Cellpose - Previous diameter was set to 30
python -m cellpose \
--dir $input_directory \
--pretrained_model cyto \
--diameter 5 \
--save_tif \
--use_gpu \
--do_3D \
--no_npy
