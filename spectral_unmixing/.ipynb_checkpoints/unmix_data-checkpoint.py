'''

A workflow designed to perform linear unmixing of fluorescence images with spectral crosstalk.

Applies specific routine corrections (dark current, flatfield, registration) and unmixes the data.
All data is handled in a single matrix.

The data is collected as follows:
445: Camera 1 = 1_CH00, Camera 2 = 1_CH05
488: Camera 1 = 1_CH01, Camera 2 = 1_CH06
561: Camera 1 = 1_CH02, Camera 2 = 1_CH07
592: Camera 1 = 1_CH03, Camera 2 = 1_CH08
642: Camera 1 = 1_CH04, Camera 2 = 1_CH09

It is loaded into aa single matrix in order with their channel number.  Thus, CH03 is [3, :, :]
'''

import unmix_functions
#import unmix.fileProcesses as fp
#import imageCorrections.backgroundCorrection as bc
#import imageCorrections.registrationCorrection as rc
import particleDetection.detect_eb3 as pd
from tifffile import imread




def main():
    # Specify the Path to the Folder that Contains the Images
    data_path = '/archive/MIL/dean/20200423_spectralUnmixing/Cell1'
    save_path = '/archive/MIL/dean/20200423_spectralUnmixing/Cell1_results'

    # Step 1 - Identify number of channels, time points, and confirm that all files are present.
    channel_number = fp.number_of_channels(data_path)
    time_number = fp.number_of_timepoints(data_path)
    fp.all_files_present(data_path, channel_number, time_number)

    # Step 2 - Calculate the Camera Registration and the NRMSE, MSE, and SSMI
    registration_path = '/archive/MIL/dean/20200218-m-profile-with-controls/cameraRegistration'
    ref_name = '1_CH00_000000.tif'
    mov_name = '1_CH01_000000.tif'
    method = 'AFFINE'
    transform_object = rc.camera_registration_transform(registration_path, ref_name, mov_name, method)

    # Step 2 - Prepare the Background Correction, or Load a Previously Generated Version.
    if bc.background_correction_complete(save_path, channel_number):
        background_correction = bc.load_prepared_background_correction(save_path, channel_number)
    else:
        background_path = '/archive/MIL/dean/20200423_spectralUnmixing/background_correction'
        background_correction = bc.prepare_background_correction(background_correction, save_path)
    bc.plot_background_correction_images(save_path, channel_number, background_correction)

    # Step 3 - Prepare the Flatfield correction?  Normally divide

    # Iterate through time
    for t_idx in range(int(time_number+1)):
        print("Iterating Through Time")

        # Step 4 - Apply the Background corrections to the data
        image_data = bc.background_correct_spectral_data(data_path, channel_number, t_idx, background_correction)

        # Step 5 - Apply the Flatfield correction.

        # Step 6 - Transform the Data
        image_data = rc.transform_spectral_data(image_data, transform_object, channel_number)

        # Step 7 - Clean up the Data of zero value or saturated pixels.
        image_data = bc.cleanup_spectral_data(image_data, channel_number)

        # Step 7 - Save the Data
        fp.save_spectral_data(save_path, image_data, channel_number, t_idx)




if __name__ == "__main__":
    # main()


