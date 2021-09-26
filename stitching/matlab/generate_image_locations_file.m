function generate_image_locations_file(data_directory, number_of_positions, number_of_channels)
% CURRENTLY ASSUMES SINGLE TIMEPOINT.

fileID = fopen(fullfile(data_directory,'imageLocations.txt'),'wt');
fprintf(fileID,'dim=3');
fprintf(fileID,'\n');
counter=0;

% Iterate through each Image Sub-Volume.
for channel_idx = 1:1:number_of_channels
    for position_idx = 1:1:number_of_positions
        counter = counter +1;
        
        acq_info = read_acq_info(data_directory,position_idx);
        % Identify the XYZ Coordinates.
        positionX = acq_info{22,2};
        positionY = acq_info{23,2};
        positionZ = acq_info{24,2};
        
        % Generate the String Output
        data_output = [num2str(counter-1) ';;(' num2str(positionX) ',' num2str(positionY) ',' num2str(positionZ) ')'];
        
        % Print the String Output
        fprintf(fileID,data_output);
        fprintf(fileID,'\n');
        
    end
end

fclose(fileID);

disp('Image Locations File Created');