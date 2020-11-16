function generate_json_file(dataDirectory, numberOfPositions, numberOfChannels, imageType)
%% Read Acquisition Info
positionIdx = 1;
AcqInfo = readAcqInfo(dataDirectory,positionIdx);
lateralPixelSize = AcqInfo{4,2};
axialPixelSize = AcqInfo{6,2};
pixelInfo = [num2str(lateralPixelSize) ',' num2str(lateralPixelSize) ',' num2str(axialPixelSize)];
imageSize = [num2str(AcqInfo{1,2}) ', ' num2str(AcqInfo{2,2}) ', ' num2str(AcqInfo{3,2})];

%% Iterate Through the Images
for channelIdx = 1:1:numberOfChannels
    
    fileID = fopen(['ch' num2str(channelIdx-1) '.json'],'wt');
    fprintf(fileID,'[\n');
    
    for imageIdx = 1:1:numberOfPositions
        imageName = ['1_CH0' num2str(channelIdx-1) '_' num2str(imageIdx) imageType];
        AcqInfo = readAcqInfo(dataDirectory,imageIdx);
        positionX = AcqInfo{22,2};
        positionY = AcqInfo{23,2};
        positionZ = AcqInfo{24,2};
        fprintf(fileID,'{\n');
        fprintf(fileID,['  "index" : ' num2str(imageIdx-1) ',\n']);
        fprintf(fileID,['  "file" : "' imageName '",\n']);
        fprintf(fileID,['  "position" : [' num2str(positionX) ', ' num2str(positionY) ', ' num2str(positionZ) '],\n']);
        fprintf(fileID,['  "size" : [' imageSize '],\n']);
        fprintf(fileID,['  "pixelResolution" : [' pixelInfo '],\n']);
        fprintf(fileID,'  "type" : "GRAY16"\n');
        if imageIdx == numberOfPositions
            fprintf(fileID,'}\n');
        elseif imageIdx ~= numberOfPositions
            fprintf(fileID,'},\n');
        end
    end
    fprintf(fileID,']\n');
    fclose(fileID);
    
    disp(['JSON File #' num2str(channelIdx) ' Complete']);
end