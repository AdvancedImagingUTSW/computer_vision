function maximum_intensity_project_data(data_directory, number_of_channels)

% Measure RAM Available
[~,RAM_available] = system('free -g');
totalMemory = str2num(RAM_available(97:99));

% Estimate Amount of Parallelization Possible Assuming 10x Overhead
s = dir('1_CH00_1.tif');
filesize = s.bytes;
totalMemory = totalMemory*1E9;
total_parallelization = totalMemory./(filesize*10);

% Determine Number of Cores Available
[~, number_of_cores] = system('nproc');
number_of_cores = str2num(number_of_cores);

% Specify the Amount of Parallelization
if(total_parallelization > number_of_cores)
    total_parallelization = number_of_cores;
else
    total_parallelization = floor(total_parallelization);
end

disp(['Total Amount of Parallel Processes for GMIC = ' num2str(total_parallelization)]);

% Install the GMIC Scripts
matlab_install_gmic();

% Iterate through each Channel
for channel_idx = 1:1:number_of_channels
    mkdirRobust(fullfile(data_directory,['MIP_CH0' num2str(channel_idx-1)]));
    systemString = ['ls -v 1_CH0' num2str(channel_idx-1) '_*.tif | parallel --will-cite -j ' num2str(total_parallelization) ' gmic {} -a z -orthoMIP -o ' data_directory '/MIP_CH0' num2str(channel_idx-1) '/{}'];
    [status,cmdout] = system(systemString,'-echo');
    disp('Maximum Intensity Projections Complete')
end