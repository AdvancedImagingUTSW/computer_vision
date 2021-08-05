function calculate_tfm_displacement(ML, MD, cell_idx, bead_channel)

%% Specify Reference Image
reference_framePath=strrep(ML.movieDataFile_{cell_idx}, 'Analysis/movieData.mat', 'ref');
directory_contents = dir(reference_framePath);
reference_framePath = [reference_framePath filesep directory_contents(3).name];


%%
funParams = DisplacementFieldCalculationProcess.getDefaultParams(MD);
funParams.ChannelIndex = bead_channel; 
funParams.referenceFramePath = reference_framePath;
funParams.minCorLength = 20;
funParams.maxFlowSpeed = 50;
funParams.highRes = true;
funParams.alpha=.05;
funParams.mode = 'accurate'; %'fast'; % This seems to control whether or not to use SCII from Han et al (accurate = yes, this is slower)
iDfcp = MD.getProcessIndex('DisplacementFieldCalculationProcess');
if(isempty(iDfcp))
    MD.addProcess(DisplacementFieldCalculationProcess(MD, 'funParams', funParams));
    iDfcp = MD.getProcessIndex('DisplacementFieldCalculationProcess');
end
MD.processes_{iDfcp}.setParameters(funParams);
MD.processes_{iDfcp}.run();