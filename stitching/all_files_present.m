function [number_of_positions, number_of_channels, image_type] = all_files_present(data_directory)

%% Determine the Number of Positions
[number_of_positions] = numberOfStrings(data_directory,'position');
if(number_of_positions == 0)
    disp('No Position Folders Found');
    return
end

%% Determine Number of Channels
position_idx = 1;
number_of_channels = numberOfStrings(fullfile(data_directory,['position ' num2str(position_idx)]),'1_CH');
disp(['The total Number of Channels is = ' num2str(number_of_channels)]);

%% Determine Image Type
directory_contents = dir(fullfile(data_directory,['position ' num2str(position_idx)]));
for directory_contents_idx=1:1:length(directory_contents)
    istiff(directory_contents_idx) = contains(directory_contents(directory_contents_idx).name,'.tiff','IgnoreCase',true);
    istif(directory_contents_idx) = contains(directory_contents(directory_contents_idx).name,'.tif','IgnoreCase',true);
end
istiff = max(cumsum(istiff));
istif = max(cumsum(istif));
if istiff > istif
    image_type = '.tiff';
    disp('Image Type is .tiff');
else
    image_type = '.tif';
    disp('Image Type is .tif');
end

%% Confirm That the Files Are Present
for position_idx = 1:1:number_of_positions
    % Acquisition Info File
    filepath = fullfile(data_directory,['position ' num2str(position_idx)],'AcqInfo.txt');
    result = isfile(filepath);
    if result == 1
    else
        error(['Acquisition Info Missing in Position ' num2str(position_idx)]);
    end
    
    % Image Files
    for channelIdx = 1:1:number_of_channels
        filepath=fullfile(data_directory,['position ' num2str(position_idx)],['1_CH0' num2str(channelIdx-1) '_000000' image_type]);
        result = isfile(filepath);
        if result==1
        else
            error(['Image Missing in Position ' num2str(position_idx)]);
        end
    end
    disp(['Position ' num2str(position_idx) ' Correct']);
end