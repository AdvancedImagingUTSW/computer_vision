function recreateDatasetXMLFile(dataDirectory)
% Assumes that the script has previously been run.
cd(dataDirectory)

%% Identify the number of channels.
channelIdx = 0;
numberImages = numberOfStrings(dataDirectory,['1_CH0' num2str(channelIdx)]);
if(numberImages == 0)
    disp('No Channels Found');
    return
end

while (numberImages > 0)
    channelIdx = channelIdx + 1;
    numberImages = numberOfStrings(dataDirectory,['1_CH0' num2str(channelIdx)]);
end
numberOfChannels = channelIdx;

%% Identify the number of positions.

numberOfPositions = 540;


%% Create the Image Locations File
fileID = fopen('newImageLocations.txt','wt');
fprintf(fileID,'dim=3');
fprintf(fileID,'\n');
counter = 0;

% Iterate through each Image Sub-Volume.
for channelIdx = 1:1:numberOfChannels
    for positionIdx = 1:1:numberOfPositions
        counter = counter +1;
        
        %% Read the AcqInfo Text File
        filename = fullfile(dataDirectory,'acquisitionInfo',['AcqInfo_' sprintf('%06d',positionIdx) '.txt']);
        delimiter = {',','='}; formatSpec = '%q%q%[^\n\r]';
        
        fileID2 = fopen(filename,'r');
        dataArray = textscan(fileID2, formatSpec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
        fclose(fileID2);
        
        raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
        for col=1:length(dataArray)-1
            raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
        end
        numericData = NaN(size(dataArray{1},1),size(dataArray,2));
        rawData = dataArray{2};
        for row=1:size(rawData, 1)
            regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
            try
                result = regexp(rawData(row), regexstr, 'names');
                numbers = result.numbers;
                invalidThousandsSeparator = false;
                if numbers.contains(',')
                    thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                    if isempty(regexp(numbers, thousandsRegExp, 'once'))
                        numbers = NaN;
                        invalidThousandsSeparator = true;
                    end
                end
                if ~invalidThousandsSeparator
                    numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                    numericData(row, 2) = numbers{1};
                    raw{row, 2} = numbers{1};
                end
            catch
                raw{row, 2} = rawData{row};
            end
        end
        rawNumericColumns = raw(:, 2);
        rawStringColumns = string(raw(:, 1));
        R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
        rawNumericColumns(R) = {NaN}; % Replace non-numeric cells
        AcqInfo = raw;
        clearvars filename delimiter formatSpec fileID2 dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp rawNumericColumns rawStringColumns R;
  
        %% Identify the XYZ Coordinates.
        positionX = AcqInfo{22,2};
        positionY = AcqInfo{23,2};
        positionZ = AcqInfo{24,2};
        
        % Generate the String Output
        %dataOutput = [num2str(folderIdx-1) ';;(' num2str(positionX) ',' num2str(positionY) ',' num2str(positionZ) ')'];
        dataOutput = [num2str(counter-1) ';;(' num2str(positionX) ',' num2str(positionY) ',' num2str(positionZ) ')'];
        
        
        % Print the String Output
        fprintf(fileID,dataOutput);
        fprintf(fileID,'\n');
    end
end
% Close the File
fclose(fileID);


%% Generate XML File
% CURRENTLY ASSUMES SINGLE CHANNEL
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
generateXML(dataLocations,lateralPixelSize,axialPixelSize)


end