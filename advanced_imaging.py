# Kevin Dean, Microscopy Innovation Lab, University of Texas Southwestern Medical Center.
# 2018-...
#
# Python versions of optimized MATLAB versions, often from the Danuser Lab.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# Import Modules
import os
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

__all__ = ['add_median_border', 'make_sphere_3D', 'make_inside_image', 'make_normalized_image',
           'surface_filter_gauss_3D', 'surface_filter_gauss_3D', 'multiscale_surface_filter_3D', 
           'combine_images','filter_log', 'spatial_log','locmax3d']

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

def filter_log(input, sigma):
    """Same Sigma Value Assumed for All 3 Dimensions
    Approach Described Here: https://homepages.inf.ed.ac.uk/rbf/HIPR2/log.htm
    """
    
    w = np.ceil(5*sigma)
    x = np.arange(-w, w, 1)
    LoG = np.zeros((x.size,x.size,x.size))

    for i in range(int(x.size)):  
        for j in range(int(x.size)):
            for k in range(int(x.size)):
                # Gaussian
                g1 = x[i]**2/(2*sigma**2)
                g2 = x[j]**2/(2*sigma**2)
                g3 = x[k]**2/(2*sigma**2)
                # Laplacian
                l1 = -1/(np.pi*sigma**4)
                l2 = 1-((x[i]**2+x[j]**2+x[k]**2)/(2*sigma**2))
                # Combined
                LoG[i,j,k] = -l1*l2*np.exp(-g1-g2-g3)

    LoG = LoG - np.mean(LoG)
    im_LoG_response = signal.fftconvolve(input, LoG, mode='same')
    return im_LoG_response

def spatial_log(input, sigma):
    """Adopted from Philippe Roudot's uTrack3D Package
    First sigma value is for X and Y, second sigma value is for Z
    """
    w = np.ceil(5*np.max(sigma))
    x = np.arange(-w, w, 1)

    gx = np.zeros(np.shape(x))
    gz = np.zeros(np.shape(x))

    gx = np.exp(-(x**2)/(2*sigma[0]**2))
    gz = np.exp(-(x**2)/(2*sigma[1]**2))

    fg = signal.fftconvolve(input, gz[:, None, None], mode='same')
    fg = signal.fftconvolve(fg, gx[None, :, None], mode='same')
    fg = signal.fftconvolve(fg, gx[None, None, :], mode='same')

    gx2 = (x**2)*gx
    gz2 = (x**2)*gz

    fgz2 = signal.fftconvolve(input, gz2[:, None, None], mode='same')
    fgz2 = signal.fftconvolve(fgz2, gx[None, :, None], mode='same')
    fgz2 = signal.fftconvolve(fgz2, gx[None, None, :], mode='same')

    fgy2 = signal.fftconvolve(input, gz[:, None, None], mode='same')
    fgy2 = signal.fftconvolve(fgy2, gx2[None, :, None], mode='same')
    fgy2 = signal.fftconvolve(fgy2, gx[None, None, :], mode='same')

    fgx2 = signal.fftconvolve(input, gz[:, None, None], mode='same')
    fgx2 = signal.fftconvolve(fgx2, gx[None, :, None], mode='same')
    fgx2 = signal.fftconvolve(fgx2, gx2[None, None, :], mode='same')

    res = (2/sigma[0]**2+1/sigma[1]**2)*fg - ((fgx2+fgy2)/sigma[0]**4 + fgz2/sigma[1]**4);
    return res

def locmax3d(input, wdims):
    """ Adopted from Francois Aguet's Software
    https://github.com/francois-a/llsmtools/blob/master/psdetect3d/locmax3d.m
    [lm] = locmax3d(img, wdims, varargin) searches for local maxima in 3D 
    wdims = default values are 1 (Philippe's Pole detector) and 3 (Deepak's Blob Detector)
    """
    input=np.array(input)
    if np.ndim(wdims)==1:
        wx = wdims
        wy = wdims
        wz = wdims
        if np.mod(wx,2)==0 and np.mod(wy,2)==0 and np.mod(wz,0)==0:
           raise ValueError("Mask dimensions must be odd integers")
        
    if np.ndim(wdims)==3:
        wx = wdims[2]
        wy = wdims[1]
        wz = wdims[0]
        if np.mod(wx,2)==0 and np.mod(wy,2)==0 and np.mod(wz,0)==0:
           raise ValueError("Mask dimensions must be odd integers")
    
    if np.ndim(input) != 3:
        raise ValueError("Expected 3D Image")
        
    (nz, ny, nx) = input.shape
    lm2D = np.zeros((nz,ny,nx))
    for z in range(int(nz)):
        lm2D[z,:,:] = ndimage.maximum_filter(input[z,:,:], size=wx[0]*wy[0])

    lm = np.zeros((nz,ny,nx))
    b = (wz[0]-1)/2
    for z in range(int(nz)):
        start_idx = np.int(np.max([0, z-b]))
        stop_idx = np.int(np.min([nz,z+b]))
        temp_matrix = lm2D[start_idx:stop_idx,:,:]
        lm[z,:,:] = np.amax(temp_matrix, axis=0)

    lm[lm != input] = 0
    
    # Clear the Borders
    b = np.int((wz[0]+2))
    lm[0:b,:,:] = 0
    stop_idx = nz
    lm[stop_idx-b:stop_idx,:,:] = 0
    
    b = np.int((wy[0]+2))
    lm[:,0:b,:] = 0
    stop_idx = ny
    lm[:,stop_idx-b:stop_idx,:] = 0
    
    b = np.int((wx[0]+2))
    lm[:,:,0:b] = 0
    stop_idx = nx
    lm[:,:,stop_idx-b:stop_idx] = 0
    

    return lm    """ Adopted from Francois Aguet's Software
    https://github.com/francois-a/llsmtools/blob/master/psdetect3d/locmax3d.m
    [lm] = locmax3d(img, wdims, varargin) searches for local maxima in 3D 
    wdims = default values are 1 (Philippe's Pole detector) and 3 (Deepak's Blob Detector)
    """
    input=np.array(input)
    if np.ndim(wdims)==1:
        wx = wdims
        wy = wdims
        wz = wdims
        if np.mod(wx,2)==0 and np.mod(wy,2)==0 and np.mod(wz,0)==0:
           raise ValueError("Mask dimensions must be odd integers")
        
    if np.ndim(wdims)==3:
        wx = wdims[2]
        wy = wdims[1]
        wz = wdims[0]
        if np.mod(wx,2)==0 and np.mod(wy,2)==0 and np.mod(wz,0)==0:
           raise ValueError("Mask dimensions must be odd integers")

    mask = np.ones((wx[0], wy[0]))
    
    if np.ndim(input) != 3:
        raise ValueError("Expected 3D Image")
        
    (nz, ny, nx) = input.shape
    lm2D = np.zeros((nz,ny,nx))
    for z in range(int(nz)):
        lm2D[z,:,:] = ndimage.maximum_filter(input[z,:,:], size=wx[0]*wy[0])

    lm = np.zeros((nz,ny,nx))
    b = (wz[0]-1)/2
    for z in range(int(nz)):
        start_idx = np.int(np.max([0, z-b]))
        stop_idx = np.int(np.min([nz,z+b]))
        temp_matrix = lm2D[start_idx:stop_idx,:,:]
        lm[z,:,:] = np.amax(temp_matrix, axis=0)

    lm[lm != input] = 0
    
    # Clear the Borders
    b = np.int((wy[0]+1))
    lm[:,0:b,:] = 0
    lm[:,-1:-1-2*b,:] = 0

    b = np.int((wx[0]+1))
    lm[:,:,0:b] = 0
    lm[:,:,-1:-1-2*b] = 0
    
    b = np.int((wz[0]+1))
    lm[0:b,:,:] = 0
    lm[-1:-1-2*b,:,:] = 0
    
    return lm
