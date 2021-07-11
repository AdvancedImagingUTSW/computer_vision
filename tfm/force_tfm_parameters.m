function force_tfm_parameters(MD)
MD_template = MovieData.loadMatFile('/archive/MIL/baker/Cell6/movieData.mat');

if(isempty(MD.channels_(1,1).excitationWavelength_))
    for ch = 1:1:2
        MD.channels_(1,ch).excitationWavelength_ = MD_template.channels_(1,ch).excitationWavelength_;
        MD.channels_(1,ch).emissionWavelength_ = MD_template.channels_(1,ch).emissionWavelength_;
        MD.channels_(1,ch).imageType_ = MD_template.channels_(1,ch).imageType_;
        MD.channels_(1,ch).fluorophore_ = MD_template.channels_(1,ch).fluorophore_;
        MD.numAperture_ = MD_template.numAperture_;
        MD.camBitdepth_ = MD_template.camBitdepth_;
    end
    disp('Channels Copied');
else
    disp('Channels Already Exist');
end