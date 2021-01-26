function eliminate_empty_volumes(number_of_positions, image_threshold, final_data)

% A function that formats a text file for the LabView software, but
% eliminates volumes with the contrast below the specified imageThreshold
% values determined from the dcts2 function in AutoPilot.
fileID3 = fopen('SPIMProject 3D Stage Sequence Locations.txt','wt');
counter = 0;

for position_idx = 1:1:number_of_positions
    counter = counter +1;
    
    % Identify the XYZ Coordinates.
    AcqInfoMIL = read_acq_info(data_directory,position_idx);
    positionX = AcqInfoMIL{22,2};
    positionY = AcqInfoMIL{23,2};
    positionZ = AcqInfoMIL{24,2};
    
    positionX = sprintf('%.2f',positionX);
    positionY = sprintf('%.2f',positionY);
    positionZ = sprintf('%.2f',positionZ);
    
    if image_threshold > final_data(position_idx)
        printValue=[num2str(counter) '\t' num2str(position_idx) '\t' num2str(positionX) '\t' num2str(positionY) '\t' num2str(positionZ) '\t' 'NaN' '\t' 'NaN' '\r\n'];
        fprintf(fileID3,printValue);
    end
end
fclose(fileID3);
%end