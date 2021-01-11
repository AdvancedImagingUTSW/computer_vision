# Adapted from n2v 3D example.
import os
from n2v.models import N2VConfig, N2V
from n2v.internals.N2V_DataGenerator import N2V_DataGenerator
import numpy as np
from tifffile import imread
from csbdeep.io import save_tiff_imagej_compatible

image_path = "/archive/bioinformatics/Danuser_lab/Fiolka/MicroscopeDevelopment/3PE/fast z data/05282020/Fish4/denoise"
image_name = '1.tif'

datagen = N2V_DataGenerator()
imgs = datagen.load_imgs_from_directory(directory=image_path, dims='ZYX')
print(imgs[0].shape)
# default = 32,64,64
patches = datagen.generate_patches_from_list(imgs[:1], shape=(32, 64, 64))

# default = :600
X = patches[:600]
X_val = patches[600:]
numberEpochs = 20
config = N2VConfig(X, unet_kern_size=3, train_steps_per_epoch=int(X.shape[0]/128),
                   train_epochs=numberEpochs,train_loss='mse', batch_norm=True, train_batch_size=4,
                   n2v_perc_pix=0.198, n2v_patch_shape=(32, 64, 64), n2v_manipulator='uniform_withCP',
                   n2v_neighborhood_radius=5)
vars(config)
model_name = '20epoch'
model = N2V(config=config, name=model_name, basedir=image_path)
history = model.train(X, X_val)
print(sorted(list(history.history.keys())))
model.export_TF()

# Load the image, and predict the denoised image.
img = imread(os.path.join(image_path, image_name))
pred = model.predict(img, axes='ZYX', n_tiles=(2,4,4))
save_tiff_imagej_compatible(os.path.join(image_path, 'denoised.tif'), pred, 'ZYX')
