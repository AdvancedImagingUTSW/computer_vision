function process_tfm_data(cell_idx)
%% Specify What Functions to Run
copy_channel_properties=0;
perform_registration=0;
calculate_displacement=0;
calculate_force_field = 0;
correct_displacement=0;
segment_cell=0;
create_overlay_image=1;
view_results=0;
cell_channel = 2;
bead_channel = 1;

%% Load the MovieList and MovieData
ML=MovieList.loadMatFile('/archive/MIL/baker/220625_TFM_8kPa/wildtype/Analysis/movieList.mat');
MD=MovieData.loadMatFile(ML.movieDataFile_{cell_idx});
disp(['Processing Cell = ' num2str(cell_idx)]);

%% Add the TFM Package
add_tfm_package(MD)

%% Copy Channel Properties
if(copy_channel_properties==1); force_tfm_parameters(MD); end

%% Registration
if(perform_registration); perform_tfm_registration(ML, MD, cell_idx, bead_channel); end

%% Displacement field calculation
if(calculate_displacement); calculate_tfm_displacement(ML, MD, cell_idx, bead_channel); end

%% Displacement field correction
% Had to hard code in line 95 of correctMovieDisplacementField
if(correct_displacement); correct_tfm_displacement(MD); end

%% Force field calculation
% Had to hard code in line 279 of calculateMovieForceField
if(calculate_force_field==1); calculate_force_tfm_force_field(MD); end

%% Cell Segmentation
if(segment_cell==1); perform_cell_segmentation(MD, cell_channel); end

%% Image Overlay
if(create_overlay_image==1); tfm_image_overlay(MD, cell_channel); end

%% View Results in GUI
if (view_results==1); movieViewer(MD); end

%% Save MovieData Structure
MD.save

