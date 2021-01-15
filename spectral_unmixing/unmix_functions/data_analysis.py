'''

This function outputs the slope, intercept, confidence_interval of the fit, the residual sum of squares(RSS) etc
input X: the pixel values of the main image to set as 1
input y: the pixel values of the image to be determined a slope.

'''



# Standard Library Imports
import os

# Third Party Imports
import numpy as np
import statsmodels.api as sm
from tifffile import imread, imsave
import matplotlib.pyplot as plt
import pandas as pd
import tqdm as tqdm
from sklearn.linear_model import LinearRegression
from scipy.optimize import nnls

# Local Imports
import unmix_functions.file_processes as fp
import unmix_functions.background_correction as bc
import unmix_functions.registration_correction as rc


def fit_stat_with_intercept(x, y, fit_positive_results):
    if fit_positive_results:
        # optional - only include the pixels with values > 0 in the fitting
        xs = x[(x > 0) & (y > 0)]
        ys = y[(x > 0) & (y > 0)]
        x = xs
        y = ys

    x = np.vstack([x]).T
    ols_model = sm.OLS(y, sm.add_constant(x))
    ols_result = ols_model.fit()
    conf_int = ols_result.conf_int(alpha=0.05)
    coef = ols_result.params
    f_pvalue = ols_result.f_pvalue
    rss = np.sum(np.square(y-ols_result.predict(sm.add_constant(x))))
    rs_adj = ols_result.rsquared_adj
    return conf_int, coef, rss, f_pvalue, rs_adj


def measure_crosstalk(primary_channel, channel_name, channel_number, time_number, data_path, test_subset=False):
    final_data = np.array([])
    for ch_idx in range(int(channel_number)):
        if test_subset:
            time_number = 1
        
        for t_idx in range(int(time_number)):
            # Create the name of the mask, and then import it.
            mask_name = ('bin_' + fp.generate_image_name(primary_channel, int(t_idx)))
            mask = np.array(imread(os.path.join(data_path, mask_name)))
        
            combined_channel_data = np.array([])

            # Create the name of the image and import it
            image_name = fp.generate_image_name(ch_idx, t_idx)
            image_data = np.array(imread(os.path.join(data_path, image_name)))

            # Muiltiply the mask by the raw image
            masked_data = np.multiply(mask, image_data)

            # Create a vector
            masked_vector = np.ndarray.flatten(masked_data)

            # If it is the first channel, initialize the vector, and assign CH0 to it.
            if int(t_idx) == 0:
                output_data = np.array([])
                output_data = np.array(masked_vector)
            else:
                b = np.array([])
                b = np.array(masked_vector)
                output_data = np.append(output_data, b)
        if int(ch_idx) == 0:
            final_data = output_data
        else:
            final_data = np.dstack((final_data, output_data))
    return final_data


def plot_crosstalk_scatterplots(master_channel, channel_name, channel_number, intensity, save_path):
    axes_limit = float(np.max(intensity))
    # Initialize the Plot
    fig, axs = plt.subplots(2, int(channel_number / 2), figsize=(20, 10))
    output_slopes = []
    for ch_idx in range(int(channel_number)):    
        # Isolate the reference channel data
        master_data = np.array(intensity[:, :, master_channel])
        master_data = np.delete(master_data, np.where(master_data == 0))
        master_data = np.vstack(master_data)
        # Isolate the variable channel data
        channel_data = np.array(intensity[:, :, ch_idx])
        channel_data = np.delete(channel_data, np.where(channel_data == 0))
        channel_data = np.vstack(channel_data)
        # Measure linear correlation
        lm = LinearRegression(fit_intercept=True).fit(master_data,channel_data)
        # Plot the Data
        axs[(ch_idx >= 5) * 1, (ch_idx + 1) % 5 - 1].scatter(master_data, channel_data, s=0.5, marker='.', c='000000')
        axs[(ch_idx >= 5) * 1, (ch_idx + 1) % 5 - 1].plot(master_data, lm.coef_*master_data + lm.intercept_, 'r', label='Fitted line')
        axs[(ch_idx >= 5) * 1, (ch_idx + 1) % 5 - 1].set_title('slope: ' + str(lm.coef_))
        axs[(ch_idx >= 5) * 1, (ch_idx + 1) % 5 - 1].set_xlim(0, axes_limit)
        axs[(ch_idx >= 5) * 1, (ch_idx + 1) % 5 - 1].set_ylim(0, axes_limit)
        
        print(lm.coef)
        output_slopes = np.append(output_slopes, lm.coef_)

    plt.show()
    output_path = os.path.join(save_path, (channel_name + 'crosstalk.tif'))
    plt.savefig(output_path)
    
    return output_slopes

def unmix_data(image_info):
    # Unwrap the input matrix
    [t_idx, channel_number, multichannel_data_path, multichannel_save_path, median_background_path, transform_object, unmixing_matrix_path] = image_info
    
    # Load the Unmixing Matrix
    unmixing_matrix = pd.read_csv(os.path.join(unmixing_matrix_path, 'unmixing_matrix.csv'))
    unmixing_np_matrix = unmixing_matrix.to_numpy()
    unmixing_np_matrix = np.abs(unmixing_np_matrix)
    
    # Load the Background Correction - ZYX Matrix
    background_correction = bc.load_prepared_background_correction(median_background_path, channel_number)
       
    # Apply the Data Corrections - ZYX Matrix
    image_data = bc.background_correct_spectral_data(multichannel_data_path, channel_number, t_idx, background_correction)
    image_data = rc.transform_spectral_data(image_data, transform_object, channel_number)
    image_data = bc.cleanup_spectral_data(image_data, channel_number)
    image_data=np.array(image_data)
    (z_len, y_len, x_len) = np.shape(image_data)
    # 10, 512, 512
    
    # Convert to an array of vectors
    image_array = np.zeros((z_len, x_len*y_len))
    for ch_idx in range(int(channel_number)):
        image_array[ch_idx, :] = np.ndarray.flatten(image_data[ch_idx, :, :])

    x = []
    output = np.zeros((np.shape(image_array)[1], np.shape(unmixing_np_matrix)[1]))
    residuals = np.zeros((np.shape(image_array)[1]))
    for vec_idx in range(image_array.shape[1]): 
        (x, y) = nnls(unmixing_np_matrix, image_array[:,vec_idx])
        output[vec_idx] = x
        residuals[vec_idx] = y
    
    output = np.array(output)
    for im_idx in range(np.shape(output)[1]):
        output_array = np.uint16(output[:,im_idx])
        output_array = output_array.reshape(y_len, x_len)
        output_path = os.path.join(multichannel_save_path, 'um_' + fp.generate_image_name(im_idx, t_idx))
        imsave(output_path, output_array)

    residuals = np.uint16(residuals)
    residuals = residuals.reshape(y_len, x_len)
    output_path = os.path.join(multichannel_save_path, 'res_' + fp.generate_image_name(0, t_idx))
    imsave(output_path, residuals)

