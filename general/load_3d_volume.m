function image3D = load_3d_volume(input_directory, image_name, varargin)
%LOAD_3D_VOLUME Load 3d Image.
%input_directory - the path to the image
%name - the name of the image
%   LOAD_3D_VOLUME(FILENAME,FMT)

% parse the input
ip = inputParser; 
ip.CaseSensitive = false;  
ip.KeepUnmatched=true;
ip.addParamValue('z_interval',1);
ip.addParamValue('x_range',getfield(imfinfo(fullfile(input_directory, image_name)), 'Height'));
ip.addParamValue('y_range',getfield(imfinfo(fullfile(input_directory, image_name)), 'Width'));
ip.addParamValue('z_range',1:length(imfinfo(fullfile(input_directory, image_name))));
ip.parse(varargin{:});
p=ip.Results;

% try to find information about the image
try
    image_info = imfinfo(fullfile(input_directory, image_name));
catch 
    disp([image_name ' is not an image and will not be analyzed.'])
    image3D = [];
    return
end

% Preallocate and load the 3D Image
number_of_planes = p.z_range(1):p.z_interval:p.z_range(end);
imageSize = [image_info(1).Height; image_info(1).Width; length(image_info)];
image3D = zeros(p.x_range, p.y_range, length(number_of_planes));

parfor zIdx = 1:1:length(number_of_planes)
    z = number_of_planes(zIdx);
    image3D(:,:,zIdx) = im2double(imread(fullfile(input_directory, image_name), 'Index', z));
end

