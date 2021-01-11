from n2v.models import N2V
import numpy as np
from tifffile import imread
from csbdeep.io import save_tiff_imagej_compatible

# Load the model
model_name = 'n2v_3D-20epoch'
basedir = '/archive/MIL/dean/20200312_n2v/data/models'
model = N2V(config=None, name=model_name, basedir=basedir)

# Load the image, and predict the denoised image.
img = imread('/archive/MIL/dean/20200312_n2v/data/1_CH00_7_crop.tif')
pred = model.predict(img, axes='ZYX', n_tiles=(2,4,4))
save_tiff_imagej_compatible('/archive/MIL/dean/20200312_n2v/data/1_CH00_7_prediction.tif', pred, 'ZYX')
