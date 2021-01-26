function generate_json_file(data_directory, number_of_positions, number_of_channels, image_type)
%% Read Acquisition Info
position_idx = 1;
acq_info = read_acq_info(data_directory,position_idx);
lateralPixelSize = acq_info{4,2};
axialPixelSize = acq_info{6,2};
pixelInfo = [num2str(lateralPixelSize) ',' num2str(lateralPixelSize) ',' num2str(axialPixelSize)];
imageSize = [num2str(acq_info{1,2}) ', ' num2str(acq_info{2,2}) ', ' num2str(acq_info{3,2})];

%% Iterate Through the Images
for channel_idx = 1:1:number_of_channels
    
    fileID = fopen(['ch' num2str(channel_idx-1) '.json'],'wt');
    fprintf(fileID,'[\n');
    
    for image_idx = 1:1:number_of_positions
        image_name = ['1_CH0' num2str(channel_idx-1) '_' num2str(image_idx) image_type];
        acq_info = read_acq_info(data_directory,image_idx);
        positionX = acq_info{22,2};
        positionY = acq_info{23,2};
        positionZ = acq_info{24,2};
        fprintf(fileID,'{\n');
        fprintf(fileID,['  "index" : ' num2str(image_idx-1) ',\n']);
        fprintf(fileID,['  "file" : "' image_name '",\n']);
        fprintf(fileID,['  "position" : [' num2str(positionX) ', ' num2str(positionY) ', ' num2str(positionZ) '],\n']);
        fprintf(fileID,['  "size" : [' imageSize '],\n']);
        fprintf(fileID,['  "pixelResolution" : [' pixelInfo '],\n']);
        fprintf(fileID,'  "type" : "GRAY16"\n');
        if image_idx == number_of_positions
            fprintf(fileID,'}\n');
        elseif image_idx ~= number_of_positions
            fprintf(fileID,'},\n');
        end
    end
    fprintf(fileID,']\n');
    fclose(fileID);
    
    disp(['JSON File #' num2str(channel_idx) ' Complete']);
end