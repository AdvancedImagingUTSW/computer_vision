function acq_info = read_acq_info(data_directory,position_idx)
%% Import data from text file.
% Script for importing data from the following folder created for MIL in the format :
% dataDirectory/acquisitionInfo
% for Microscopy Innovation Lab
% Saumya Vora, 13-08-2020

%% Initialize Text File Location.
acq_info_location = fullfile(data_directory,['position ' num2str(position_idx)],'AcqInfo.txt');

%% Open the text file.
text_file_import = fopen(acq_info_location,'r');
delimiter = {',','='}; format_spec = '%q%q%[^\n\r]';
data_array = textscan(text_file_import, format_spec, 'Delimiter', delimiter, 'TextType', 'string',  'ReturnOnError', false);
fclose(text_file_import);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(data_array{1}),length(data_array)-1);
for col=1:length(data_array)-1
    raw(1:length(data_array{col}),col) = mat2cell(data_array{col}, ones(length(data_array{col}), 1));
end
numericData = NaN(size(data_array{1},1),size(data_array,2));

% Converts text in the input cell array to numbers. Replaced non-numeric
% text with NaN.
rawData = data_array{2};
for row=1:size(rawData, 1)
    % Create a regular expression to detect and remove non-numeric prefixes and
    % suffixes.
    regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
    try
        result = regexp(rawData(row), regexstr, 'names');
        numbers = result.numbers;
        
        % Detected commas in non-thousand locations.
        invalidThousandsSeparator = false;
        if numbers.contains(',')
            thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
            if isempty(regexp(numbers, thousandsRegExp, 'once'))
                numbers = NaN;
                invalidThousandsSeparator = true;
            end
        end
        % Convert numeric text to numbers.
        if ~invalidThousandsSeparator
            numbers = textscan(char(strrep(numbers, ',', '')), '%f');
            numericData(row, 2) = numbers{1};
            raw{row, 2} = numbers{1};
        end
    catch
        raw{row, 2} = rawData{row};
    end
end


%% Split data into numeric and string columns.
rawNumericColumns = raw(:, 2);
rawStringColumns = string(raw(:, 1));

%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Create output variable
acq_info = raw;

end