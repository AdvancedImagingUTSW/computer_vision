function [interpolatedData] = interpolateZ(imageVolume, lateralPixelSize, axialPixelSize)


zRatio = (lateralPixelSize/axialPixelSize);

zInterpolate=round(size(imageVolume,3)*(1/zRatio));

interpolatedData = zeros(size(imageVolume,1),size(imageVolume,2),zInterpolate);

parfor i=1:size(imageVolume,2)
    tempG=squeeze((imageVolume(:,i,:)));
    interpolatedData(:,i,:)=imresize(tempG,[size(imageVolume,1),zInterpolate],'bicubic');
end
