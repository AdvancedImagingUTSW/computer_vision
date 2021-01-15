'''

Various functions intended to perform proper background correction of images in the spectral unmixing workflow.

'''


# Standard Library Imports
import os

# Third Party Imports
import numpy as np
from skimage.transform import resize
from tifffile import imread, imsave
import matplotlib.pyplot as plt

# Local Imports
import unmix_functions.file_processes as fp


def cleanup_spectral_data(image_data, channel_number):
    # After the transformation, some pixels have zero value or are saturated.
    # Convert to median on a per channel basis.

    for ch_idx in range(int(channel_number)):
        temporary_image = image_data[ch_idx, :, :]
        temporary_image[temporary_image == 0] = np.median(temporary_image)
        temporary_image[temporary_image > 60000] = np.median(temporary_image)
        image_data[ch_idx, :, :] = temporary_image
    return np.uint16(image_data)

def background_correction_complete(save_path, channel_number):
    # Check to see if the background correction has already been performed.

    file_check = np.array([])
    channel_counter = 0
    for i in range(int(channel_number - 1)):
        filename = "bg_1_CH" + str(("{:02d}".format(int(channel_counter)))) + "_" + str(("{:06d}".format(int(0)))) + ".tif"
        filepath = os.path.join(save_path, filename)
        exists = os.path.isfile(filepath)
        if exists:
            file_check = np.append(file_check, int(1))
        else:
            file_check = np.append(file_check, int(0))
        channel_counter += 1

    if all(file_check):
        print("All Background Correction Files are Present")
        return True
    else:
        print("Background Correction Not Complete")
        return False

def prepare_background_correction(data_path, save_path):
    path_exists = os.path.isdir(save_path)
    if not path_exists:
        os.mkdir(save_path)

    channel_number = fp.number_of_channels(data_path)
    time_number = fp.number_of_timepoints(data_path)
    fp.all_files_present(data_path, channel_number, time_number)

    # Load the Data into a Matrix for a single time point
    for ch_idx in range(int(channel_number)):
        for t_idx in range(int(time_number)):

            # Generate the Path and Load the Data
            image_name = "1_CH" + str(("{:02d}".format(int(ch_idx)))) + "_" + \
                         str(("{:06d}".format(int(t_idx)))) + ".tif"

            image_path = os.path.join(data_path, image_name)

            loaded_image = imread(image_path, key=0)
            if t_idx == 0:
                # Use first image to identify the dimensions and initialize the matrix.
                (y_len, x_len) = loaded_image.shape
                output_data = np.zeros((int(time_number), int(y_len), int(x_len)))
                output_data[t_idx, :, :] = loaded_image
            else:
                output_data[t_idx, :, :] = loaded_image

        median_image = np.median(output_data, axis=0)

        output_name = "bg_1_CH" + str(("{:02d}".format(int(ch_idx)))) + "_" + str(
                ("{:06d}".format(int(0)))) + ".tif"

        imsave(os.path.join(save_path, output_name), np.uint16(median_image))
    return

def load_prepared_background_correction(save_path, channel_number):
    # Load the Data into a Matrix for a single time point
    for ch_idx in range(int(channel_number)):
        image_name = "bg_1_CH" + str(("{:02d}".format(int(ch_idx)))) + "_" + str(("{:06d}".format(int(0)))) + ".tif"
        image_path = os.path.join(save_path, image_name)
        loaded_image = imread(image_path, key=0)
        if ch_idx == 0:
            # Use first image to identify the dimensions and initialize the matrix.
            (y_len, x_len) = loaded_image.shape
            output_data = np.zeros((int(channel_number), int(y_len), int(x_len)))
            output_data[ch_idx, :, :] = loaded_image
        else:
            output_data[ch_idx, :, :] = loaded_image
    return output_data

def plot_background_correction_images(save_path, channel_number, background_correction):
    fig, axs = plt.subplots(2, int(channel_number/2), figsize=(20, 10))
    for i in range(int(channel_number)):
        axs[(i >= (channel_number/2)) * 1, (i + 1) % int(channel_number/2) - 1].imshow(background_correction[i, :, :], cmap=plt.get_cmap('PiYG'))
        axs[(i >= (channel_number / 2)) * 1, (i + 1) % int(channel_number / 2) - 1].set_title("CH" + str(("{:02d}".format(i))))

    fig.suptitle('Background Correction Images')
    output_path = os.path.join(save_path, 'background_correction.tif')
    plt.savefig(output_path)
    return

def background_correct_spectral_data(data_path, channel_number, t_idx, background_correction):
    # Load the Data into a Matrix for a single time point
    for ch_idx in range(int(channel_number)):
        # Generate the Path and Load the Data
        image_name = "1_CH" + str(("{:02d}".format(int(ch_idx)))) + "_" + str(
            ("{:06d}".format(int(t_idx)))) + ".tif"

        image_path = os.path.join(data_path, image_name)
        loaded_image = imread(image_path, key=0)
        if ch_idx == 0:
            # Use first image to identify the dimensions and initialize the matrix.
            (y_len, x_len) = loaded_image.shape
            image_data = np.zeros((int(channel_number), int(y_len), int(x_len)))
            image_data[ch_idx, :, :] = loaded_image
        else:
            image_data[ch_idx, :, :] = loaded_image

    # Subtract the Dark Current (Background) from the Data
    image_data = image_data - background_correction

    # Remove negative values from the subtracted data.
    image_data = np.abs(image_data)
    return np.uint16(image_data)


