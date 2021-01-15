'''

Standard processes for handling data acquired with the UTSW LabView Software.

'''


# Standard Library Imports
import os
import re

# Third Party Imports
import numpy as np
from tifffile import imsave

# Local Imports


def number_of_channels(path):
    # Data is acquired with a file name that follows 1_CH0*_*.tif, where the first * is the channel
    # and the second * is the number of timepoints.

    # Generate a list with the contents of the directory
    path_contents = os.listdir(path)

    # Initialize Numpy Array
    channel_number = np.array([])

    # Iterate through the list.
    counter = 0
    for i in path_contents:

        # Get the file name
        filename = path_contents[counter]

        # Search for the CH00, CH01... regular expression
        regexp1 = re.search("1_CH(\d\d)", filename)

        if regexp1 is not None:
            channel_number = np.append(channel_number, int(regexp1.group(1)))
        else:
            channel_number = np.append(channel_number, int(0))
        counter += 1

    largest_channel_idx = np.max(channel_number)
    total_number_of_channels = largest_channel_idx + 1
    print("There are " + str(total_number_of_channels) + " channels in this dataset.")
    return total_number_of_channels

def number_of_timepoints(path):
    # Data is acquired with a file name that follows 1_CH0*_*.tif, where the first * is the channel
    # and the second * is the number of timepoints.

    # Generate a list with the contents of the directory
    path_contents = os.listdir(path)

    # Initialize Numpy Array
    time_number = np.array([])

    # Iterate through the list.
    counter = 0
    for i in path_contents:

        # Get the file name
        filename = path_contents[counter]

        # Search for the CH00, CH01... regular expression
        regexp1 = re.search("_(\d\d\d\d\d\d).tif", filename)

        if regexp1 is not None:
            time_number = np.append(time_number, int(regexp1.group(1)))
        else:
            time_number = np.append(time_number, int(0))
        counter += 1

    largest_time_idx = np.max(time_number)
    total_number_of_time = largest_time_idx + 1
    print("There are " + str(total_number_of_time) + " time points in this dataset.")
    return total_number_of_time

def all_files_present(path, channelNumber, timeNumber):
    # Used to find aborted acquisitions where the number of images per channel is not constant.

    file_check = np.array([])

    # Initialize counters
    channelCounter = 0

    for i in range(int(channelNumber - 1)):
        timeCounter = 0

        for j in range(int(timeNumber - 1)):
            filename = "1_CH" + str(("{:02d}".format(channelCounter))) + "_" + str(("{:06d}".format(timeCounter))) + ".tif"
            filepath = os.path.join(path, filename)
            exists = os.path.isfile(filepath)
            if exists:
                file_check = np.append(file_check, int(1))
            else:
                file_check = np.append(file_check, int(0))
                print("Not Found:" + str(filename))

            timeCounter += 1
        channelCounter += 1

    if all(file_check):
        print("All files are present")
        return
    else:
        raise UserWarning('Some files not found')

def save_spectral_data(save_path, image_data, channel_number, time_number):
    for ch_idx in range(int(channel_number)):
        # Generate the Path and Load the Data
        image_name = "1_CH" + str(("{:02d}".format(int(ch_idx)))) + "_" + str(
            ("{:06d}".format(int(time_number)))) + ".tif"

        imsave(os.path.join(save_path, image_name), np.uint16(image_data[ch_idx, :, :]))
    return

def generate_image_name(ch_idx, t_idx):
    image_name = "1_CH" + str(("{:02d}".format(int(ch_idx)))) + "_" + \
                 str(("{:06d}".format(int(t_idx)))) + ".tif"
    return image_name


def garbage_bin():
    from tifffile import imread, imsave
    from scipy.optimize import nnls
    import numpy as np
    unmixing_np_matrix = unmixing_matrix.to_numpy()
    unmixing_np_matrix = np.abs(unmixing_np_matrix)

    for t_idx in (range(int(time_number))):
        image_array = []
        for ch_idx in range(int(channel_number)):
            image_path = os.path.join(multichannel_save_path, fp.generate_image_name(ch_idx, t_idx))
            image_temp = imread(image_path, key=0).astype(float)
            image_temp = np.array(image_temp)
            (y_len, x_len) = image_temp.shape
            image_temp = np.ndarray.flatten(image_temp)
            image_array.append(image_temp)

        image_array=np.array(image_array)

        # Initialize the vector to store the unmixed values.
        x = []        
        x = [nnls(unmixing_np_matrix,image_array[:,i]) for i in range(image_array.shape[1])]


        for vec_idx in tqdm(range(image_array.shape[1])):            
            # first bracket is position in vector
            # second bracket is whether we are in the 3x1 vector, or the residuals?
            # third bracket is the channel position in the 3x1 vector
            temp = x[vec_idx][0]
            if vec_idx == 0:
                output = np.array(temp)
            else:
                output = np.vstack((output,temp))

        for im_idx in range(np.shape(output)[1]):
            output_array = np.uint16(output[:,im_idx])
            output_array = output_array.reshape(y_len, x_len)
            output_path = os.path.join(multichannel_save_path, 'um_' + fp.generate_image_name(im_idx, t_idx))
            imsave(output_path, output_array)


