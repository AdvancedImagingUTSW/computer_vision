function perform_tfm_registration(ML, MD, cell_idx, bead_channel)
%% Specify Reference Image
reference_framePath=strrep(ML.movieDataFile_{cell_idx}, 'Analysis/movieData.mat', 'ref');
directory_contents = dir(reference_framePath);
reference_framePath = [reference_framePath filesep directory_contents(3).name];

%%
funParams = EfficientSubpixelRegistrationProcess.getDefaultParams(MD);
funParams.referenceFramePath = reference_framePath;
funParams.BeadsChannel = bead_channel;
iEsrp = MD.getProcessIndex('EfficientSubpixelRegistrationProcess');
if(isempty(iEsrp))
    MD.addProcess(EfficientSubpixelRegistrationProcess(MD, 'funParams', funParams));
    iEsrp = MD.getProcessIndex('EfficientSubpixelRegistrationProcess');
end
MD.processes_{iEsrp}.setParameters(funParams);
MD.processes_{iEsrp}.run();