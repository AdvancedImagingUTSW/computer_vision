#!/bin/bash

# Load Modules
module add cuda101/toolkit/10.1.243
module load python/3.6.4-anaconda
source activate decon_env

# Specify Paths
input_path="/archive/MIL/marciano/20201211_CapillaryLooping/cropped/mutant/1_CH00_000000.tif"
psf_path="/archive/MIL/dean/PSF/ctASLM2/ctASLM2-510nm.tif"
python_imports="from pycudadecon import decon; import tifffile;"



python -c "$module_imports result=decon($input_path, $psf_path); "


from pycudadecon import decon
image_path = '/path/to/some_image.tif'
psf_path = '/path/to/psf_3D.tif'
result = decon(image_path, psf_path)

# Launch Cellpose - Previous diameter was set to 30
python -m cellpose \
--dir $input_directory \
--pretrained_model cyto \
--diameter 30 \
--save_tif \
--use_gpu \
--do_3D \
--no_npy
