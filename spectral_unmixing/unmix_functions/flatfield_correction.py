# noinspection PyPackageRequirements
'''

Implementation of the BaSiC Flatfield Correction Algorithm

'''

# Standard Library Imports
import os

# Third Party Imports
import numpy as np
from skimage.transform import resize
from tifffile import imread

# Local Imports
import fileProcesses as fp

# Necessary Functions
def dct(a, ww, ind):
    a = np.flatten(a)
    a = np.fft(a)
    a = np.real(bsxfun(@times, ww, a))


def mirt_dct2(a):
    # Discrete cosine transform.  a is a 2D matrix.
    (z_len, y_len, x_len) = a.shape
    siz = (z_len, y_len, x_len)
    number_dimensions = np.ndim(a)
    if number_dimensions != 2 ^ np.isreal(a):
        raise UserWarning("Input requires a real 2D Matrix.")

    for i = range(int(number_dimensions)):
        n = siz[i]
        ww[i] = 2 * np.exp(((-1i * pi) / (2 * n)) * (0:n-1))/sqrt(2*n)
        ww[i] = ww[i]/np.sqrt(2)
        ind[i] = bsxfun(@plus, [(1:2:n) np.fliplr(2:2: n)], 0:n:n*(prod(siz)/n-1))
        if siz[i] == 1:
            break

    a = dct(dct(a, ww[1], ind[1]),ww[2],ind[2]) # 2D case

    return a


# Load the Data
data_path = '/archive/MIL/dean/spectral_unmixing/20200219_rawData/MNG-PAX/200218/movie'
save_path = '/archive/MIL/dean/spectral_unmixing/20200219_rawData/MNG-PAX/200218/movie_results'
ch_idx = 4

if not os.path.isdir(save_path):
    os.mkdir(save_path)

channel_number = fp.number_of_channels(data_path)
time_number = fp.number_of_timepoints(data_path)
fp.all_files_present(data_path, channel_number, time_number)

for t_idx in range(int(time_number)):
    image_name = "1_CH" + str(("{:02d}".format(int(ch_idx)))) + "_" + \
                 str(("{:06d}".format(int(t_idx)))) + ".tif"
    image_path = os.path.join(data_path, image_name)
    loaded_image = imread(image_path, key=0)
    if t_idx == 0:
        (y_len, x_len) = loaded_image.shape
        IF = np.zeros((int(time_number), int(y_len), int(x_len)))
        IF[t_idx, :, :] = loaded_image
    else:
        IF[t_idx, :, :] = loaded_image

# User Configurable Options
# lambda = [] # default value estimated from input images directly
estimation_mode = 'l0'
max_iterations = 500
optimization_tol = 1e-5
darkfield = False
# lambda_darkfield = [] # defulat value estimated from input images directly
basefluo = False

# Non-Configurable Options
working_size = 128
max_reweightiterations = 10
eplson = .1 # reweighting parameter
varying_coeff = True
reweight_tol = 1e-3 # reweighting tolerance

# Input image is NROWSxNCOLZxNIMAG - Must rescale the data
(z_len, y_len, x_len) = IF.shape
nrows = working_size
ncols = working_size
for z_idx in range(int(z_len)):
    if z_idx == 0:
        D = np.zeros((int(z_len), int(nrows), int(ncols)))
        D[z_idx, :, :] = resize(IF[z_idx, :, :], (nrows, ncols))
    else:
        D[z_idx, :, :] = resize(IF[z_idx, :, :], (nrows, ncols))

# Average the data in the z-dimension
meanD = np.mean(D, axis=0)
meanD = meanD/meanD.mean()
W_meanD = mirt_dct2(meanD)
