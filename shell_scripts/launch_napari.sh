#!/bin/bash

module load cuda112/toolkit/11.2.0
module load python/3.8.x-anaconda
source activate napari

cat > /home2/kdean/tmp/temporary_python.py <<_EOF_
# Import Modules
from skimage import data
import napari
from tifffile import imread

image_data = imread('/archive/MIL/marciano/20210302_cropped_volumes/20210119_mutant/1_CH01_000001.tif')

viewer = napari.view_image(image_data)
napari.run()  # start the event loop and show viewer

_EOF_

python /home2/kdean/tmp/temporary_python.py
