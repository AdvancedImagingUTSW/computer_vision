function [position_idx] = number_of_strings(data_path,string)
%% Identifies the number of a specific string in the directory.

directory_contents=dir(data_path);

is_position_dir=[];
for directory_idx = 1:length(directory_contents)
    temp = directory_contents(directory_idx).name;
    startIdx = regexp(temp,string);
    if startIdx >= 1
        is_position_dir(directory_idx)=1;
    else
        is_position_dir(directory_idx) = 0;
    end
    clear temp startIdx
end
position_idx = max(cumsum(is_position_dir));
