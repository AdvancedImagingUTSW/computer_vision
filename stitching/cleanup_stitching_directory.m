function cleanup_stitching_directory(data_directory, number_of_positions)
cd(data_directory)
mkdirRobust('acquisitionInfo');
parfor position_idx = 1:1:number_of_positions
    old_location = fullfile(data_directory,['position ' num2str(position_idx)],'AcqInfo.txt');
    
    % Establish a string with a new inmage name.
    new_acq_info_name =  ['AcqInfo_' sprintf('%06d',position_idx) '.txt'];
    new_location = fullfile(data_directory,'acquisitionInfo',new_acq_info_name);
    
    % Move The File
    movefile(old_location, new_location);
    
    % Remove the Directory
    rmdir(fullfile(data_directory,['position ' num2str(position_idx)]));
end