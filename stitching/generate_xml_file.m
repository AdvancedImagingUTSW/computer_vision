function generate_xml_file(dataDirectory, numberOfPositions)
%Dean Lab- Kevin Dean, Evgenia Azarova, Saumya Vora - 07/17/2019
%Intended to create xml file
%Pre-processing using 'bigStitchDirectory'


%%
disp('Generating XML File');
dataLocations = zeros(numberOfPositions,3);
for positionIdx = 1:1:numberOfPositions
    if(positionIdx == 1)
        AcqInfo = readAcqInfo(dataDirectory,positionIdx);
        lateralPixelSize=AcqInfo{4,2};
        axialPixelSize = AcqInfo{6,2};
    end
    AcqInfo = readAcqInfo(dataDirectory,positionIdx);
    
    % Identify the XYZ Coordinates.
    positionX = AcqInfo{22,2};
    positionY = AcqInfo{23,2};
    positionZ = AcqInfo{24,2};
    dataLocations(positionIdx,1) = positionX;
    dataLocations(positionIdx,2) = positionY;
    dataLocations(positionIdx,3) = positionZ;
  
end



numberOfPositions=length(dataLocations); %user specified
pixelRatio = axialPixelSize/lateralPixelSize;
dataLocations = dataLocations*pixelRatio;

% imageParamters = imfinfo(imagePath);
% imageParamters.Width...

fileID = fopen('dataset2.xml','wt');
fprintf(fileID,'<?xml version="1.0" encoding="UTF-8"?> \n');
fprintf(fileID,'<SpimData version="0.2"> \n');
fprintf(fileID,'  <BasePath type="relative">.</BasePath> \n');
fprintf(fileID,'  <SequenceDescription>\n');
fprintf(fileID,'\t\t<ImageLoader format="spimreconstruction.stack.ij"> \n');
fprintf(fileID,'\t\t\t<imagedirectory type="relative">.</imagedirectory> \n');
fprintf(fileID,'\t\t\t<filePattern>1_CH00_{x}.tif</filePattern> \n');
fprintf(fileID,'\t\t\t<layoutTimepoints>0</layoutTimepoints> \n');
fprintf(fileID,'\t\t\t<layoutChannels>0</layoutChannels> \n');
fprintf(fileID,'\t\t\t<layoutIlluminations>0</layoutIlluminations> \n');
fprintf(fileID,'\t\t\t<layoutAngles>0</layoutAngles> \n');
fprintf(fileID,'\t\t\t<layoutTiles>1</layoutTiles> \n');
fprintf(fileID,'\t\t\t<imglib2container>ArrayImgFactory</imglib2container> \n');
fprintf(fileID,'\t\t</ImageLoader> \n');
fprintf(fileID,'<ViewSetups>\n');

%% Loop for id, name, size and tile
for positionIdx = 1:1:numberOfPositions
    
    fprintf(fileID,'\t<ViewSetup>\n');
    idValue=['\t\t\t<id>' , num2str(positionIdx-1) ,'</id>\n'];
    fprintf(fileID,idValue);
    nameValue=['\t\t\t<name>' , num2str(positionIdx-1) ,'</name>\n'];
    fprintf(fileID,nameValue);
    fprintf(fileID,'\t\t<size>2048 2048 471</size>\n');
    fprintf(fileID,'\t\t<voxelSize>\n');
    fprintf(fileID,'\t\t\t<unit>um</unit>\n');
    pixelsize=['\t\t\t<size>' num2str(lateralPixelSize),' ' ,num2str(lateralPixelSize),' ' ,num2str(axialPixelSize), '</size> \n'];
    fprintf(fileID,pixelsize);
    fprintf(fileID,'\t\t</voxelSize>\n');
    fprintf(fileID,'\t\t<attributes>\n');
    fprintf(fileID,'\t\t\t<illumination>0</illumination>\n');
    fprintf(fileID,'\t\t\t<channel>0</channel>\n');
    positionNum=['\t\t\t<tile>' , num2str(positionIdx-1) , '</tile>\n'];
    fprintf(fileID,positionNum);
    fprintf(fileID,'\t\t\t<angle>0</angle>\n');
    fprintf(fileID,'\t\t</attributes>\n');
    fprintf(fileID,'\t</ViewSetup>\n');
end

%%
fprintf(fileID,'\t<Attributes name="illumination">\n');
fprintf(fileID,'\t\t<Illumination>\n');
fprintf(fileID,'\t\t\t<id>0</id>\n');
fprintf(fileID,'\t\t\t<name>0</name>\n');
fprintf(fileID,'\t\t</Illumination>\n');
fprintf(fileID,'\t</Attributes>\n');
fprintf(fileID,'\t<Attributes name="channel">\n');
fprintf(fileID,'\t\t<Channel>\n');
fprintf(fileID,'\t\t\t<id>0</id>\n');
fprintf(fileID,'\t\t\t<name>0</name>\n');
fprintf(fileID,'\t\t</Channel>\n');
fprintf(fileID,'\t</Attributes>\n');
fprintf(fileID,'\t<Attributes name="tile">\n');

%% specifying the correct tile ID
%for channelIdx = 1...
for positionIdx = 1:1:numberOfPositions
    fprintf(fileID,'\t\t<Tile>\n');
    idValue=['\t\t\t<id>' , num2str(positionIdx-1) , '</id>\n'];
    fprintf(fileID,idValue);
    nameValue=['\t\t\t<name>' , num2str(positionIdx) , '</name>\n'];
    fprintf(fileID,nameValue);
    fprintf(fileID,'\t\t</Tile>\n');
end


fprintf(fileID,'\t</Attributes>\n');
fprintf(fileID,'\t<Attributes name="angle">\n');
fprintf(fileID,'\t\t<Angle>\n');
fprintf(fileID,'\t\t\t<id>0</id>\n');
fprintf(fileID,'\t\t\t<name>0</name>\n');
fprintf(fileID,'\t\t</Angle>\n');
fprintf(fileID,'\t</Attributes>\n');
fprintf(fileID,'</ViewSetups>\n');
fprintf(fileID,'<Timepoints type="pattern">\n');
fprintf(fileID,'\t<integerpattern />\n');
fprintf(fileID,'</Timepoints>\n');
fprintf(fileID,'\t</SequenceDescription>\n');
fprintf(fileID,'\t<ViewRegistrations>\n');


%% Loop for timepoint and setup
for positionIdx = 1:1:numberOfPositions
    setupValue=['\t<ViewRegistration timepoint="0" setup="',num2str(positionIdx-1), '">\n'];
    fprintf(fileID,setupValue);
    fprintf(fileID,'\t\t<ViewTransform type="affine">\n');
    fprintf(fileID,'\t\t\t<Name>Translation from Tile Configuration</Name>\n');
    
    firstValue = dataLocations(positionIdx,1)./lateralPixelSize;
    secondValue = dataLocations(positionIdx,2)./lateralPixelSize;
    thirdValue = dataLocations(positionIdx,3)./lateralPixelSize;
    
    fprintf(fileID,['\t\t\t<affine>1.0 0.0 0.0 ' num2str(firstValue) ' 0.0 1.0 0.0 ' num2str(secondValue) ' 0.0 0.0 1.0 ' num2str(thirdValue) '</affine>\n']);
    fprintf(fileID,'\t\t</ViewTransform>\n');
    fprintf(fileID,'\t\t<ViewTransform type="affine">\n');
    fprintf(fileID,'\t\t\t<Name>calibration</Name>\n');
    fprintf(fileID,['\t\t\t<affine>1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0 ' num2str(axialPixelSize/lateralPixelSize) '</affine>\n']);
    fprintf(fileID,'\t\t</ViewTransform>\n');
    fprintf(fileID,'\t</ViewRegistration>  \n');
end


fprintf(fileID,'\t</ViewRegistrations>\n');
fprintf(fileID,'<ViewInterestPoints />\n');
fprintf(fileID,'<BoundingBoxes />\n');
fprintf(fileID,'<PointSpreadFunctions />\n');
fprintf(fileID,'<StitchingResults />\n');
fprintf(fileID,'<IntensityAdjustments />\n');
fprintf(fileID,'</SpimData> \n');


% Close the File
fclose(fileID);

end