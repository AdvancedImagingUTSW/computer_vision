function process_tfm_data(cell_idx)

cell_idx = (cell_idx+1);

copy_channel_properties=0;
perform_registration=1;
calculate_displacement=1;
calculate_force_field = 1;
correct_displacement=1;
segment_cell=1;
create_overlay_image=1;

ML=MovieList.loadMatFile('/archive/MIL/baker/210618_TFM_8kPa/Analysis/movieList.mat');
MD=MovieData.loadMatFile(ML.movieDataFile_{cell_idx});
disp(['Processing Cell = ' num2str(cell_idx)]);

%% Add the TFM Package
add_tfm_package(MD)

%% Copy Channel Properties
if(copy_channel_properties==1); force_tfm_parameters(MD); end

%% Registration
if(perform_registration); perform_tfm_registration(ML, MD, cell_idx); end

%% Displacement field calculation
if(calculate_displacement); calculate_tfm_displacement(ML, MD, cell_idx); end

%% Displacement field correction
% Had to hard code in line 95 of correctMovieDisplacementField
if(correct_displacement); correct_tfm_displacement(MD); end

%% Force field calculation
% Had to hard code in line 279 of calculateMovieForceField
if(calculate_force_field==1); calculate_force_tfm_force_field(MD); end

%% Cell Segmentation
if(segment_cell==1); perform_cell_segmentation(MD); end

%% Image Overlay
if(create_overlay_image==1); tfm_image_overlay(MD); end
MD.save


