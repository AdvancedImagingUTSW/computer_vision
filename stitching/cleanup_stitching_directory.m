function cleanup_stitching_directory(dataDirectory, numberOfPositions)
cd(dataDirectory)
mkdirRobust('acquisitionInfo');
parfor positionIdx = 1:1:numberOfPositions
    oldLocation = fullfile(dataDirectory,['position ' num2str(positionIdx)],'AcqInfo.txt');
    
    % Establish a string with a new inmage name.
    newAcqInfoName =  ['AcqInfo_' sprintf('%06d',positionIdx) '.txt'];
    newLocation = fullfile(dataDirectory,'acquisitionInfo',newAcqInfoName);
    
    % Move The File
    movefile(oldLocation, newLocation);
    
    % Remove the Directory
    rmdir(fullfile(dataDirectory,['position ' num2str(positionIdx)]));
end