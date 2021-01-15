'''

Particle detection functions first designed the Danuser lab, now implemented in Python 3.6

'''

# Standard Library Imports
import os

# Third Party Imports
import cv2
import numpy as np
from tifffile import imread
from skimage.measure import label as get_labels
from skimage import morphology
from tqdm import tqdm

# Local Imports
import unmix_functions.file_processes as fp


def watershed_bandpass(channel_to_detect, tIdx, data_path, high_frequency_cutoff, low_frequency_cutoff, step_size, image_threshold):
    # Prepare watershed properties.  step_size is the gradient step.  image_threshold is the minimum value.
    # Filter Kernel must be an odd value.
    minimum_eb3_area = 3
    image_name = '1_CH' + str(("{:02d}".format(int(channel_to_detect)))) + '_' + \
                 str(("{:06d}".format(tIdx))) + ".tif"

    image_path = os.path.join(data_path, image_name)
    image_data = imread(image_path, key=0)
    image_data = image_data.astype(float)

    # Apply a Guassian blur to the image.  Kernel must be odd.
    dst1 = cv2.GaussianBlur(image_data, (high_frequency_cutoff, high_frequency_cutoff), 0)
    dst2 = cv2.GaussianBlur(image_data, (low_frequency_cutoff, low_frequency_cutoff), 0)
    filtered_data = (dst1-dst2)

    # Begin Watershed
    image_maximum = np.nanmax(filtered_data)
    number_of_steps = np.round((image_maximum-image_threshold)/step_size)
    if number_of_steps <= 0:
        # Either the image_threshold is too high, or the step size is too large.
        slice2 = np.zeros(np.shape(image_data))
    else:
        threshold_list = np.linspace(image_maximum, image_threshold, int(number_of_steps))
        if number_of_steps == 1:
            # If number_of_steps only one, hard-threshold data.
            slice2 = filtered_data > threshold_list[0]
        elif number_of_steps > 1:
            step_counter = 0
            for steps in range(int(number_of_steps-1)):

                # Threshold the data
                if step_counter == 0:
                    slice1 = filtered_data > threshold_list[int(step_counter)]
                else:
                    slice1 = slice2

                slice2 = filtered_data > threshold_list[int(step_counter + 1)]

                # From binary data, generate labels.
                feature_map1 = get_labels(slice1)
                feature_map2 = get_labels(slice2)

                # Count the number of labels in each slice
                number_of_labels1 = np.max(feature_map1)
                number_of_labels2 = np.max(feature_map1)

                label_counter = 0
                for labels in range(int(number_of_labels2)):
                    if label_counter != 0:
                        # Iterate through each label, creating a binary image for a single label
                        label_indices2 = feature_map2 == label_counter

                        # use that binary image to pull out the values in the first slice
                        label_in_slice1 = slice1[label_indices2]
                        unique_labels = []
                        unique_labels, indices = np.unique(label_in_slice1, return_index=True)

                        # Throw away the background
                        unique_indices = np.delete(indices, np.where(indices == 0))

                        # If there is more than one unique index
                        if len(unique_indices) > 1:
                            slice2[label_indices2] = slice1[label_indices2]
                    label_counter += 1
                step_counter += 1

    # Create Binary Image
    #final_labels = get_labels(slice2)
    b = morphology.remove_small_objects(slice2, minimum_eb3_area)
    output_binary_image = np.zeros(np.shape(slice2))
    output_binary_image[b] = 1

    # Output Name
    output_path = os.path.join(data_path, 'bin_1_CH' + str(("{:02d}".format(int(channel_to_detect)))) + '_' +
                              str(("{:06d}".format(int(tIdx)))) + ".tif")
    cv2.imwrite(output_path, np.uint8(output_binary_image))


def mask_by_probability_map(channel_to_detect, tIdx, data_path, probability_threshold):
    probability_map_name = 'vim-data_Probabilities_' + str(("{:03d}".format(int(tIdx)))) + '.tif'
    probability_map_name = os.path.join(data_path, probability_map_name)
    
    probability_data = imread(probability_map_name, key=0)
    probability_data = probability_data.astype(float)   
    
    greater_than_threshold = probability_data > probability_threshold

    output_binary_image = np.zeros(np.shape(probability_data))
    output_binary_image[greater_than_threshold] = 1

    # Output Name
    output_path = os.path.join(data_path, 'bin_1_CH' + str(("{:02d}".format(int(channel_to_detect)))) + '_' +
                              str(("{:06d}".format(int(tIdx)))) + ".tif")
    cv2.imwrite(output_path, np.uint8(output_binary_image))
