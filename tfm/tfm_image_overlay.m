function tfm_image_overlay(MD, cell_channel)
% Load the Forcefield and the Traction Map
force_field_calculation_process_idx = MD.getProcessIndex('ForceFieldCalculationProcess');
forcefield = MD.processes_{force_field_calculation_process_idx}.loadChannelOutput('output', 'forceField');
traction_map = MD.processes_{force_field_calculation_process_idx}.loadChannelOutput('output', 'tMap');
traction_map = traction_map{1};

% Load the Registered Images
efficient_registration_process_idx = MD.getProcessIndex('EfficientSubpixelRegistrationProcess');
registration_image = MD.processes_{efficient_registration_process_idx}.loadChannelOutput(1,1);
lf = load(MD.processes_{efficient_registration_process_idx}.outFilePaths_{3,1});
registration = lf.T;

% Load the Mask
mask_calculation_process_idx = MD.getProcessIndex('MaskRefinementProcess');
mask = MD.processes_{mask_calculation_process_idx}.outFilePaths_{cell_channel};
mask = imread(fullfile(mask, 'refined_mask_C2.tif'));
ROIt = imtranslate(mask, flip(registration), 'nearest');
ROItd = bwboundaries(ROIt);

% Create the Overlay Image
fig = figure();
image(traction_map,'CDataMapping','scaled');
%set(gca, 'CLim', [min(traction_map(:)) max(traction_map(:))]);
set(gca, 'CLim', [min(traction_map(:)) 10000]);
colorbar; 
hold on;
Ioverlay = ones([size(registration_image) 3]);
Ioverlay = imshow(Ioverlay);
Ioverlay.AlphaData = rescale(registration_image) .* 0.8;
for(k = 1:length(ROItd))
    B = ROItd{k};
    plot(B(:,2), B(:,1), 'w');
end
ffu = size(traction_map, 2);
ffv = size(traction_map, 1);
[ffgridu, ffgridv] = meshgrid(1:20:ffu, 1:20:ffv);
ffinterpu = scatteredInterpolant(forcefield.pos, forcefield.vec(:,1), 'linear', 'nearest');
ffinterpv = scatteredInterpolant(forcefield.pos, forcefield.vec(:,2), 'linear', 'nearest');
quiver(ffgridu(:), ffgridv(:), ffinterpu(ffgridu(:), ffgridv(:)), ffinterpv(ffgridu(:), ffgridv(:)),3,'Color', 'red');

x0=10; y0=10; width=800; height=800; set(gcf,'position',[x0,y0,width,height]);
export_path = fullfile(MD.movieDataPath_, ['image_overlay.pdf']);
title(MD.movieDataPath_, 'Interpreter', 'none');
saveas(gcf,export_path);

% Calculate Traction
masked_traction = traction_map.*ROIt;
integrated_traction = sum(masked_traction(:));
mean_traction = mean(masked_traction(:));
max_traction = max(masked_traction(:));
export_path = fullfile(MD.movieDataPath_,'traction_forces.mat');
save(export_path, 'integrated_traction','mean_traction','max_traction');

close all