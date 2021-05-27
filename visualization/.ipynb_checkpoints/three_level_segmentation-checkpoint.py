# Import Modules
import os
import time
from multiprocessing import Pool

import numpy as np
from tifffile import imread, imsave

from skimage.filters import threshold_otsu
from skimage.morphology import dilation, erosion, remove_small_objects
from skimage.measure import label, regionprops

from scipy.ndimage import gaussian_filter, binary_fill_holes
from scipy import ndimage, signal

if 'BINDER_SERVICE_HOST' in os.environ:
    os.environ['DISPLAY'] = ':1.0'
    
import napari

def add_median_border(image_data):
    (z_len, y_len, x_len) = image_data.shape
    median_intensity = np.median(image_data)
    padded_image_data = np.full((z_len+2, y_len+2, x_len+2), median_intensity)
    padded_image_data[1:z_len+1, 1:y_len+1, 1:x_len+1]=image_data
    return padded_image_data

def make_sphere_3D(radius):
    radius = int(radius)
    sphere = np.zeros((radius, radius, radius))
    (z_len, y_len, x_len) = sphere.shape
    for i in range(int(z_len)):
        for j in range(int(y_len)):
            for k in range(int(x_len)):
                if ((i**2+j**2+k**2)/radius**2) < 1:
                    sphere[i,j,k]=1
    return sphere

def make_inside_image(padded_image_data, insideGamma,insideBlur, insideDilateRadius, insideErodeRadius):
    image_blurred = padded_image_data**insideGamma
    image_blurred = gaussian_filter(image_blurred, sigma=insideBlur)
    image_threshold = threshold_otsu(image_blurred)

    image_binary = image_blurred > image_threshold                   
    image_binary = dilation(image_binary, make_sphere_3D(insideDilateRadius))
    image_binary = ndimage.binary_fill_holes(image_binary)
    image_binary = np.double(erosion(image_binary, make_sphere_3D(insideErodeRadius)))
    inside_image = gaussian_filter(image_binary, sigma=1)
    return inside_image


def make_normalized_image(input):
    image_threshold = threshold_otsu(padded_image_data)
    normalized_cell = padded_image_data - image_threshold
    normalized_cell = normalized_cell/np.std(normalized_cell)
    return normalized_cell

def surface_filter_gauss_3D(input, sigma):
    
    # Same Sigma Value for All 3 Dimensions
    w = np.ceil(5*sigma)
    x = np.arange(-w, w, 1)
    g = np.zeros(x.shape)

    # Calculate 1D Gaussian
    for i in range(int(x.size)):
        g[i] = np.exp(-x[i]**2/(2*sigma**2))

    # Calculate Second Derivative of 1D Gaussian
    d2g = np.zeros(x.shape)
    for i in range(int(x.size)):
        d2g[i] = (-(x[i]**2/sigma**2 - 1) / sigma**2)*(np.exp(-x[i]**2/(2*sigma**2)))

    gSum = np.sum(g);

    # Gaussian Kernels
    g = g/gSum; #1D Gaussian
    d2g = d2g/gSum; #1D Second Derivative Kernel

    d2z_image = signal.fftconvolve(input, d2g[:, None, None], mode='same')
    d2z_image = signal.fftconvolve(d2z_image, g[None,: , None], mode='same')
    d2z_image = signal.fftconvolve(d2z_image, g[None, None, :], mode='same')
   
    d2y_image = signal.fftconvolve(input, d2g[None, :, None], mode='same')
    d2y_image = signal.fftconvolve(d2y_image, g[None, None,:], mode='same')
    d2y_image = signal.fftconvolve(d2y_image, g[:, None, None], mode='same')
    
    d2x_image = signal.fftconvolve(input, d2g[None, None, :], mode='same')
    d2x_image = signal.fftconvolve(d2x_image, g[:, None, None], mode='same')
    d2x_image = signal.fftconvolve(d2x_image, g[None, :, None], mode='same')
    
    return d2z_image, d2y_image, d2x_image

def multiscale_surface_filter_3D(input, scales):
    n_scales = np.size(scales)
    max_response = np.zeros(np.shape(input))
    max_response_scale = np.zeros(np.shape(input))

    for i in range(n_scales):
        d2z_temp, d2y_temp, d2x_temp = surface_filter_gauss_3D(input,scales[i])
        d2z_temp[d2z_temp<0] = 0
        d2y_temp[d2y_temp<0] = 0
        d2x_temp[d2x_temp<0] = 0

        sMag = np.sqrt(d2z_temp**2 + d2y_temp**2 + d2x_temp**2)
        is_better = sMag > max_response
        max_response_scale[is_better] = i
        max_response[is_better] = sMag[is_better]
    
    surface_background_mean = np.mean(max_response)
    surface_background_std = np.std(max_response)
    surface_threshold = surface_background_mean + (nSTDsurface*surface_background_std)
    surface_cell = max_response - surface_threshold
    surface_cell = max_response/np.std(max_response)

    return surface_cell

def combine_images(inside_image, normalized_cell, surface_cell):
    level = 0.999
    combined_image = np.maximum(np.maximum(inside_image, normalized_cell), surface_cell);
    combined_image[combined_image<0] = 0
    combined_image = combined_image>level
    combined_image = binary_fill_holes(combined_image)

    # Label Connected Components
    labeled_image = label(combined_image)
    label_properties = regionprops(labeled_image)

    # Find Biggest Connected Component
    label_areas = np.zeros(np.size(label_properties[:]))
    for a in range(int(np.size(label_properties[:]))):
        label_areas[a] = label_properties[a].area
    max_label = np.argmax(label_areas, axis=None)

    # Take only the largest connected component.
    final_image = np.zeros(np.shape(labeled_image))
    final_image[labeled_image==max_label+1] = 1
    return final_image

### Run the Code ### 
start_time = time.perf_counter()
scales = [1, 2, 4]
nSTDsurface = 2
insideGamma = 0.7
insideBlur = 1
insideDilateRadius = 3
insideErodeRadius = 4

image_directory = '/archive/MIL/morrison/20201105_mitochondria_quantification/ilastik'
image_name = 'ControlCell8_cyto.tif'
image_path = os.path.join(image_directory, image_name)
image_data = np.array(imread(image_path))
print('The Image Dimensions Are: ' + str(image_data.shape))

padded_image_data = add_median_border(image_data)
inside_image = make_inside_image(padded_image_data, insideGamma, insideBlur, insideDilateRadius, insideErodeRadius)
normalized_cell = make_normalized_image(padded_image_data)
surface_cell = multiscale_surface_filter_3D(padded_image_data, scales)
final_image = combine_images(inside_image, normalized_cell, surface_cell)
end_time = time.perf_counter()
print(end_time - start_time)

with napari.gui_qt():
    viewer = napari.Viewer()  
    viewer.add_image(padded_image_data, name='raw data')
    viewer.add_labels(final_image, name='combo')
