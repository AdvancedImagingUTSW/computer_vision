function perform_cell_segmentation(MD)
% Step 1 - Add Segmentation Package
segmentation_package_idx = MD.getPackageIndex('SegmentationPackage');
if(isempty(segmentation_package_idx))
    disp('Segmentation Package Not Found');
    MD.addPackage(SegmentationPackage(MD));
    segmentation_package_idx = MD.getPackageIndex('SegmentationPackage');
    disp('Segmentation Package Added to MovieData');
else
    disp('Segmentation Package Package Found');
end

%% Threshold Process
funParams = ThresholdProcess.getDefaultParams(MD);
funParams.ChannelIndex = 1;
funParams.GaussFilterSigma = 1;
funParams.MethodIndx = 3;
funParams.MaxJump = 0;
funParams.ExcludeOutliers = 0;
funParams.ExcludeZero = 0;
funParams.PreThreshold = 0;
funParams.ThresholdValue = [];
funParams.ProcessIndex = [];
funParams.IsPercentile = [];
funParams.BatchMode = 0;

threshold_process_idx = MD.getProcessIndex('ThresholdProcess');
if(isempty(threshold_process_idx))
    MD.addProcess(ThresholdProcess(MD, 'funParams', funParams));
    threshold_process_idx = MD.getProcessIndex('ThresholdProcess');
end
MD.processes_{threshold_process_idx}.setParameters(funParams);
MD.processes_{threshold_process_idx}.run();

%% Mask Refinement Process
funParams = MaskRefinementProcess.getDefaultParams(MD);
SegProcessIndex = 4;
funParams.ChannelIndex = 1;
funParams.MaskCleanUp = 1;
funParams.MinimumSize = 100;
funParams.ClosureRadius = 3;
funParams.ObjectNumber = 1;
funParams.FillHoles = 1;
funParams.FillBoundaryHoles = 1;
funParams.EdgeRefinement = 0;
funParams.OpeningRadius = 0;
funParams.SuppressBorder = 0;
funParams.MaxEdgeAdjust = [];
funParams.MaxEdgeGap = [];
funParams.PreEdgeGrow = [];
funParams.BatchMode = 0;

mask_refinement_process_idx = MD.getProcessIndex('MaskRefinementProcess');
if(isempty(mask_refinement_process_idx))
    MD.addProcess(MaskRefinementProcess(MD, 'funParams', funParams));
    mask_refinement_process_idx = MD.getProcessIndex('MaskRefinementProcess');
end
MD.processes_{mask_refinement_process_idx}.setParameters(funParams);
MD.processes_{mask_refinement_process_idx}.run();
MD.save