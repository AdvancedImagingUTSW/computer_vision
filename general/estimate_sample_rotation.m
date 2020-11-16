function [xRot, yRot, zRot] = estimate_sample_rotation(dataDirectory)

[paths] = findCellDirectory(dataDirectory);
filePath = [dataDirectory filesep paths(1).name '/analysis/1_CH00_000000.mat'];
load(filePath);
%tiffReader=TiffSeriesReader({MD.channels_.channelPath_},'force3D',true);
%MD.setReader(tiffReader);
imageData=MD.getChannel(1).loadStack(1);
MD.save;

%% Interpolate the Data
[imageData] = interpolateZ(imageData, MD.pixelSize_, MD.pixelSizeZ_);
disp('Interpolation Complete')

% Estimate the Rotation
XY=squeeze(imageData(:,:,size(imageData,3)/2));
imshow(XY,[])
% angle provided gives xRot;
[x,y]=getpts; x=round(x); y=round(y);
dy = abs(y(2)-y(1));
dx = abs(x(2)-x(1));
xRot = 90-atand(dy/dx);
clear x y dy dx XY

YZ=squeeze(imageData(:,size(imageData,2)/2,:));
imshow(YZ,[]);
% angle provided gives zRot;
[x,y]=getpts; x=round(x); y=round(y);
dy = abs(y(2)-y(1));
dx = abs(x(2)-x(1));
zRot = 90-atand(dy/dx);
clear x y dy dx YZ

XZ=squeeze(imageData(size(imageData,1)/2,:,:));
imshow(XZ,[]);
% angle provided gives yRot;
[x,y]=getpts; x=round(x); y=round(y);
dy = abs(y(2)-y(1));
dx = abs(x(2)-x(1));
yRot = 90-atand(dy/dx);
clear x y dy dx XZ

cd(dataDirectory);
save('rotationParameters.mat','xRot','yRot','zRot');
clear imageData