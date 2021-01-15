'''

Image Registration:
Based upon the pystackreg package - https://pystackreg.readthedocs.io/en/latest/

'''

# Standard Library Imports
import os

# Third Party Imports
from pystackreg import StackReg
from tifffile import imread, imsave
import numpy as np
from skimage.metrics import mean_squared_error

# Local Imports


def camera_registration_transform(path, ref_name, mov_name, method):
    print("Registering " + ref_name + " and " + mov_name)

    # Generate the Path
    ref_path = os.path.join(path, ref_name)
    mov_path = os.path.join(path, mov_name)

    # load reference and "moved" image
    ref_image = imread(ref_path, key=0)
    mov_image = imread(mov_path, key=0)

    # Specify the type of registration
    if method is 'TRANSLATION':
        transform_object = StackReg(StackReg.TRANSLATION)
    elif method is 'AFFINE':
        transform_object = StackReg(StackReg.AFFINE)
    elif method is 'RIGID_BODY':
        transform_object = StackReg(StackReg.RIGID_BODY)
    elif method is 'SCALED_ROTATION':
        transform_object = StackReg(StackReg.SCALED_ROTATION)
    elif method is 'BILINEAR':
        transform_object = StackReg(StackReg.BILINEAR)
    else:
        print('The registration method you selected is unsupported - options include translation'
              ', affine, rigid body, scaled rotation, and bilinear')

    transform_object.register(ref_image, mov_image)
    print(transform_object.get_matrix())

    transformed_image = np.uint16(transform_object.transform(mov_image))

    # Root Mean Square
    score1 = mean_squared_error(ref_image, mov_image)
    score2 = mean_squared_error(ref_image, transformed_image)
    print("RMS Before Registration = " + str(score1))
    print("RMS After Registration = " + str(score2))

    return transform_object

def transform_single_image(path, mov_name, transform_object):
    # Specify the file path
    mov_path = os.path.join(path, mov_name)

    # load reference and "moved" image
    mov_image = imread(mov_path, key=0)

    # Transform the image with the transform_object
    output_image = transform_object.transform(mov_image)
    output_image = np.uint16(output_image)

    output_path = os.path.join(path, 'r_' + mov_name)
    imsave(output_path, output_image)

    print("Affine Transformation Complete for " + mov_name)

    return

def transform_spectral_data(image_data, transform_object, channel_number):
    for ch_idx in range(int(channel_number)):
        if ch_idx > 4:
            # Perform the transformation for only the second camera.
            transformed_image = transform_object.transform(image_data[ch_idx, :, :])
            image_data[ch_idx, :, :] = transformed_image
    return image_data
