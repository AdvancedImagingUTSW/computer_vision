# Create an ImageJ gateway with the newest available version of ImageJ.
import imagej
from skimage import io
import numpy as np 
import matplotlib
# import cairocffi as cairo
# matplotlib.use('PS') 



ij = imagej.init('/home2/kdean/Desktop/Applications/Fiji', headless=False)
print('ImageJ Version:' + str(ij.getVersion()))

# Load an image.
#image_url = 'https://samples.fiji.sc/new-lenna.jpg'

# jimage = ij.io().open('/archive/MIL/marciano/20210119_capillaryLooping/Control/fluospheres_sytox/210117/Cell1/max_pos1.jpg')
# print('Image Loaded')

# Convert the image from ImageJ to xarray, a package that adds
# labeled datasets to numpy (http://xarray.pydata.org/en/stable/).
# image = ij.py.from_java(jimage)

# Display the image (backed by matplotlib).
# ij.py.show(jimage, cmap='gray')



url = '/archive/MIL/marciano/20210119_capillaryLooping/Control/fluospheres_sytox/210117/Cell1/max_pos1.jpg'
img = io.imread(url)
# ij.py.show(img)

from matplotlib import pyplot as plt
plt.subplot(121)
plt.imshow(img)
plt.subplot(122)
plt.imshow(img)
plt.show()
