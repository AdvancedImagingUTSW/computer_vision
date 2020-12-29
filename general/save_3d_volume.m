function save_3d_volume(output_path, image3d, varargin)

% saveImage3D - saves a 3D image as a single tif (assumes that the image is already of the correct class)
%
% INPUTS:
%
% image3D - the image, which should be of the correct class already
%
% imagePath - the path and name of the image

% parse the input
ip = inputParser; 
ip.CaseSensitive = false;  
ip.KeepUnmatched=true;
ip.addParameter('z_interval',1);
ip.parse(varargin{:});
p=ip.Results;

% check inputs
assert(isnumeric(image3d) | islogical(image3d), 'image3D must be a numerical or logical matrix');
assert(ischar(output_path), 'imagePath should be a path to an image');

% saves the first slice and overwrites any existing image of the same name
imwrite(squeeze(image3d(:,:,1)), output_path, 'Compression', 'none')

% saves subsequent slices
imageSize = size(image3d);
for z=2:imageSize(3)
    imwrite(squeeze(image3d(:,:,z)), output_path, 'Compression', 'none', 'WriteMode', 'append')
end