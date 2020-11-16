function eliminate_empty_volumes(numberOfPositions, imageThreshold, final_data)

% A function that formats a text file for the LabView software, but
% eliminates volumes with the contrast below the specified imageThreshold
% values determined from the dcts2 function in AutoPilot.
fileID3 = fopen('SPIMProject 3D Stage Sequence Locations.txt','wt');
counter = 0;

for positionIdx = 1:1:numberOfPositions
    counter = counter +1;
    
    % Identify the XYZ Coordinates.
    AcqInfoMIL = readAcqInfoMIL(dataDirectory,positionIdx);
    positionX = AcqInfoMIL{22,2};
    positionY = AcqInfoMIL{23,2};
    positionZ = AcqInfoMIL{24,2};
    
    positionX = sprintf('%.2f',positionX);
    positionY = sprintf('%.2f',positionY);
    positionZ = sprintf('%.2f',positionZ);
    
    if imageThreshold > final_data(positionIdx)
        printValue=[num2str(counter) '\t' num2str(positionIdx) '\t' num2str(positionX) '\t' num2str(positionY) '\t' num2str(positionZ) '\t' 'NaN' '\t' 'NaN' '\r\n'];
        fprintf(fileID3,printValue);
    end
end
fclose(fileID3);
%end