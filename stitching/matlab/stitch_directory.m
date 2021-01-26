function stitch_directory(data_directory)
%% Stitching Workflow
% Intended to streamline the stitching of large volume datasets.
% dataDirectory should be the root folder containing all of the
% sub-volumes.  e.g., 'C:\Users\AI2\Desktop\Cell3';

% Kevin Dean, 05-26-2020.

if(ismac || ispc)
    disp('Only Supported On a BioHPC Linux System');
    return;
    
elseif isunix
    % Determine Available Resources
    [~,RAM_available] = system('free -g');
    total_memory = str2num(RAM_available(97:99));
    disp(['Total Memory of Linux Node = ' num2str(total_memory) 'GB']);
    
    if(total_memory<220)
        disp('Not Enough Memory- Please Launch a 256GB Web Visualization Node on BioHPC');
        return
    else
        %% Determine Number of Positions, Channels, and the Type of Image
        cd(data_directory);
        [number_of_positions, number_of_channels, image_type] = all_files_present(data_directory);
        
        %% Move Files into Common Directory
        organize_stitching_data(data_directory, number_of_positions, number_of_channels, image_type);
        
        %% Generate Text File Containing Position Information
        generate_image_locations_file(data_directory, number_of_positions, number_of_channels);
        
        %% Generate XML File - Currently assumes single channel
        generate_xml_file(data_directory, number_of_positions);

        %% Clean Up the Directory
        cleanup_stitching_directory(data_directory, number_of_positions);

    end
end