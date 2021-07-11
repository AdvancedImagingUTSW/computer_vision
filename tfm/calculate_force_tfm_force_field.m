function calculate_force_tfm_force_field(MD)
funParams = ForceFieldCalculationProcess.getDefaultParams(MD);
funParams.YoungModulus = 8000;
funParams.method = 'FTTC'; %'FastBEM'; %'FTTC';
funParams.solMethodBEM='1NormReg';
funParams.basisClassTblPath=[MD.outputDirectory_ filesep 'tfmbasistable.mat'];
funParams.useLcurve=true;
funParams.lcornerOptimal='optimal';
iFfcp = MD.getProcessIndex('ForceFieldCalculationProcess');
if(isempty(iFfcp))
    MD.addProcess(ForceFieldCalculationProcess(MD, 'funParams', funParams));
    iFfcp = MD.getProcessIndex('ForceFieldCalculationProcess');
end
MD.processes_{iFfcp}.setParameters(funParams);
MD.processes_{iFfcp}.run();