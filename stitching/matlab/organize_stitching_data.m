function organize_stitching_data(data_directory, number_of_positions, number_of_channels, image_type)

parfor position_idx = 1:1:number_of_positions    
    for channelIdx = 1:1:number_of_channels
        
        % Establish a string with the old image name.
        old_image_name = ['1_CH0' num2str(channelIdx-1) '_000000' image_type];
        old_location = fullfile(data_directory,['position ' num2str(position_idx)],old_image_name);
        
        % Establish a string with a new inmage name.
        new_image_name =  ['1_CH0' num2str(channelIdx-1) '_' num2str(position_idx) image_type];
        new_location = fullfile(data_directory,new_image_name);
        
        % Move The File
        movefile(old_location, new_location);
    end
end