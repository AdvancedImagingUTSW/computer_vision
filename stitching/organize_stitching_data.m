function organize_stitching_data(data_directory, number_of_positions, number_of_channels, image_type)

parfor positionIdx = 1:1:number_of_positions    
    number_of_channels = numberOfStrings(fullfile(data_directory,['position ' num2str(positionIdx)]),'1_CH');
    for channelIdx = 1:1:number_of_channels
        
        % Establish a string with the old image name.
        oldImageName = ['1_CH0' num2str(channelIdx-1) '_000000' image_type];
        oldLocation = fullfile(data_directory,['position ' num2str(positionIdx)],oldImageName);
        
        % Establish a string with a new inmage name.
        newImageName =  ['1_CH0' num2str(channelIdx-1) '_' num2str(positionIdx) image_type];
        newLocation = fullfile(data_directory,newImageName);
        
        % Move The File
        movefile(oldLocation, newLocation);
    end
end