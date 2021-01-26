function installGMIC()
% 2019-07-19 Kevin Dean

if(ismac || ispc)
    disp('Only Supported On a BioHPC Linux System'); return;
elseif isunix
    
    % Load the GMIC Module from BioHPC
    [status,~] = system('module load gmic/2.1.1');
    if(~status)
        disp('GMIC Module Loaded');
    else
        disp('Error - GMIC Not Loaded');
        return
    end
    
    % Load the Parallel Module from BioHPC
    [status,~] = system('module load parallel/20150122');
    if(~status)
        disp('parallel/20150122 Module Loaded');
    else
        disp('Error - parallel/20150122 Not Loaded');
        return
    end
    
    % Search for the gmic directory, and copy the file to home.
    if exist('~/Desktop/GitHub/computer_vision/shell_scripts/gmic', 'dir')
        copyfile('~/Desktop/GitHub/computer_vision/shell_scripts/gmic/gmic_scripts',...
            '~/.gmic');
        disp('GMIC Scripts Copied to Root Directory');
    else
        disp('Error - Does not appear that the Repository has been cloned');
        return
    end
end
