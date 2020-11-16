function generate_image_locations_file(dataDirectory, numberOfPositions, numberOfChannels)
% CURRENTLY ASSUMES SINGLE TIMEPOINT.

fileID = fopen('imageLocations.txt','wt');
fprintf(fileID,'dim=3');
fprintf(fileID,'\n');
counter=0;
% Iterate through each Image Sub-Volume.
for channelIdx = 1:1:numberOfChannels
    for positionIdx = 1:1:numberOfPositions
        counter = counter +1;
        
        AcqInfo = readAcqInfo(dataDirectory,positionIdx);
        % Identify the XYZ Coordinates.
        positionX = AcqInfo{22,2};
        positionY = AcqInfo{23,2};
        positionZ = AcqInfo{24,2};
        
        % Generate the String Output
        dataOutput = [num2str(counter-1) ';;(' num2str(positionX) ',' num2str(positionY) ',' num2str(positionZ) ')'];
        
        
        % Print the String Output
        fprintf(fileID,dataOutput);
        fprintf(fileID,'\n');
        
    end
end

% Close the File
fclose(fileID);
