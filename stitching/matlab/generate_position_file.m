function generate_position_file(data_directory)

cd(data_directory);
[number_of_positions, number_of_channels, image_type] = all_files_present(data_directory);

%% Generate Text File Containing Position Information
generate_image_locations_file(data_directory, number_of_positions, number_of_channels);