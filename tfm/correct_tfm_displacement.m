function correct_tfm_displacement(MD)
funParams = DisplacementFieldCorrectionProcess.getDefaultParams(MD);
iDfcorp = MD.getProcessIndex('DisplacementFieldCorrectionProcess');
if(isempty(iDfcorp))
    MD.addProcess(DisplacementFieldCorrectionProcess(MD, 'funParams', funParams));
    iDfcorp = MD.getProcessIndex('DisplacementFieldCorrectionProcess');
end
MD.processes_{iDfcorp}.setParameters(funParams);
MD.processes_{iDfcorp}.run();