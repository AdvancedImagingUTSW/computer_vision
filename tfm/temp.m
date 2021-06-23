%% Prepare file lists
eDir = '/project/bioinformatics/Danuser_lab/P01if/analysis/Ben/201218--tfm/';
lf = load([eDir '201218-MDindex-fastBEM05.mat'], 'mdFileNames', 'refTif');
mdFileNames = lf.mdFileNames;
slideSetTable = [eDir '201218-slideset-table.xml'];
masks = strcat(eDir, bnGetSlidesetTableColumn(slideSetTable, "Masks", "Mask image"));
outDir = [eDir '8bit/fastBEM05/'];
outPat = '-tractionField';
if ~isfolder(outDir), mkdir(outDir); end
%%
for iImg = 1:length(mdFileNames)
    
    load(mdFileNames(iImg));
    
    [a, b, c] = fileparts(MD.movieDataFileName_);
    outFile = [outDir b outPat];

    iEsrp = MD.getProcessIndex('EfficientSubpixelRegistrationProcess');
    %%
    if(isempty(iEsrp) || iEsrp<1)
        display(b);
        continue;
    end
    %%
    filChan = 0;
    if(iImg<=10)
        filChan = 1;
    else
        filChan = 2;
    end
    regIm = MD.processes_{iEsrp}.loadChannelOutput(filChan,1);
    lf = load(MD.processes_{iEsrp}.outFilePaths_{3,1});
    registration = lf.T;
    iFfcp = MD.getProcessIndex('ForceFieldCalculationProcess');
    %%
    if(isempty(iFfcp) || iFfcp<1)
        display(b);
        continue;
    end
    %%
    ff = MD.processes_{iFfcp}.loadChannelOutput('output', 'forceField');
    tMap = MD.processes_{iFfcp}.loadChannelOutput('output', 'tMap');
    tMap = tMap{1};
    %%
    ROI = imread(masks(iImg));
    ROIt = imtranslate(ROI, flip(registration), 'nearest');
    ROItd = imdilate(ROIt, strel('disk', 20, 4));
    ROIt = bwboundaries(ROIt);
    ROItd = bwboundaries(ROItd);
%%
    %I = bnRGBify(double(regIm), 'rel', [0.05 0.9975]) .* 0.8;
    %I = I + bnRGBify(tMap, 'rel', [0.01 0.999], 'colormap', jet);
    
    fig = figure();
    image(tMap,'CDataMapping','scaled');
    set(gca, 'CLim', [0 9000]);
    colorbar;
    hold on;
    Ioverlay = ones([size(regIm) 3]);
    Ioverlay = imshow(Ioverlay);
    Ioverlay.AlphaData = rescale(regIm) .* 0.8;
    for(k = 1:length(ROIt))
        B = ROIt{k};
        plot(B(:,2), B(:,1), 'w');
    end
    for(k = 1:length(ROItd))
        B = ROItd{k};
        plot(B(:,2), B(:,1), 'w');
    end
    
    ffu = size(tMap, 2);
    ffv = size(tMap, 1);
    [ffgridu, ffgridv] = meshgrid(1:20:ffu, 1:20:ffv);
    ffinterpu = scatteredInterpolant(ff.pos, ff.vec(:,1), 'linear', 'nearest');
    ffinterpv = scatteredInterpolant(ff.pos, ff.vec(:,2), 'linear', 'nearest');
    quiver(ffgridu(:), ffgridv(:), ffinterpu(ffgridu(:), ffgridv(:)), ffinterpv(ffgridu(:), ffgridv(:)),3,'Color', 'red');
    %ffMag = sum(ff.vec .^ 2, 2);
    %ffInc = ffMag > 100^2;
    %asc=50;
    %quiver(ff.pos(ffInc,1), ff.pos(ffInc,2), ff.vec(ffInc,1).*asc, ff.vec(ffInc,2).*asc, 5, 'AutoScale', 'Off', 'Color', 'red');
    %%
    %exportgraphics(fig, [outFile '.pdf']);
    exportgraphics(fig, [outFile '.jpg'], 'Resolution', 300);

    %imwrite(I, outFile);

end
