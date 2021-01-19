function crop_data(input_directory, image_name, varargin)
% crop_data - Displays MIPs of a volume and allows user to specify size of
% ROI.  Mask can be used with uTrack.
%
% - Kevin Dean,2021.
%
% Required Inputs:
% input_directory   - Directory for data.
% image_name        - Name of primary image for cropping
%
% Optional Inputs:
% create_mask       - Create a binary mask image? 1=yes, 0=no.
% dependent_images	- Use primary image to crop dependent images? 1=yes,
% 0=no.
%
% Outputs:
% mask              - binary mask with ones at ROI

% parse the input
ip = inputParser; 
ip.CaseSensitive = false;  
ip.KeepUnmatched=true;
ip.addParamValue('create_mask',0);
ip.addParamValue('dependent_images',0);
ip.parse(varargin{:});
p=ip.Results;

% Load the Volume
vol = load_3d_volume(input_directory, image_name);

% Create an XY Projection
maxXY = squeeze(max(vol,[],3));
imshow(maxXY,[],'Border','tight');

% Select Coordinates
xyIndices = ceil(getrect);
close all

% Create First Sub-Volume
vol2 = vol(xyIndices(2):xyIndices(2)+xyIndices(4),xyIndices(1):xyIndices(1)+xyIndices(3),:);

% Create a YZ Projection
maxYZ = squeeze(max(vol2,[],1)); 
imshow(maxYZ,[],'Border','tight'); 
zIndices = ceil(getrect);
close all

% Create Final ROI
roiIdx = nan(6,1);
roiIdx(1) = max(1,xyIndices(1));
roiIdx(2) = min(size(vol,2),xyIndices(1)+xyIndices(3)-1);
roiIdx(3) = max(1,xyIndices(2));
roiIdx(4) = min(size(vol,1),xyIndices(2)+xyIndices(4)-1);
roiIdx(5) = max(1,zIndices(1));
roiIdx(6) = min(size(vol,3),zIndices(1)+zIndices(3)-1);

% Save Cropped Image
export_data = vol(roiIdx(3):roiIdx(4),roiIdx(1):roiIdx(2),roiIdx(5):roiIdx(6));
output_path = fullfile(input_directory,['cropped_' image_name]);
save_3d_volume(output_path, uint16(export_data.*2^16-1))


% Save Mask Image
if p.create_mask == 1
    disp('Creating a Mask');
    mask = zeros(size(vol,1),size(vol,2),size(vol,3));
    mask(roiIdx(3):roiIdx(4),roiIdx(1):roiIdx(2),roiIdx(5):roiIdx(6)) = 1;
    output_path = fullfile(input_directory,'mask.tif');
    save_3d_volume(output_path, mask)
end

% Look for Secondary Images and Crop
if p.dependent_images == 1
    disp('Looking for Secondary Images');
    directory_contents = dir(input_directory);
    for i = 1:1:length(directory_contents)
        filename = directory_contents(i).name;
        if(~contains(filename,'cropped'))
            if(contains(filename,'1_CH0'))
                if(~contains(filename, image_name))
                    disp(['Cropping ' filename]);
                    vol = load_3d_volume(input_directory, filename);
                    export_data = vol(roiIdx(3):roiIdx(4),roiIdx(1):roiIdx(2),roiIdx(5):roiIdx(6));
                    output_path = fullfile(input_directory,['cropped_' filename]);
                    save_3d_volume(output_path, uint16(export_data.*2^16-1))
                end
            end
        end
    end
end

close all