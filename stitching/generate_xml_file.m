function generate_xml_file(data_directory, number_of_positions)
%Dean Lab- Kevin Dean, Evgenia Azarova, Saumya Vora - 07/17/2019
%Intended to create xml file
%Pre-processing using 'bigStitchDirectory'


%%
disp('Generating XML File');
data_locations = zeros(number_of_positions,3);
for position_idx = 1:1:number_of_positions
    if(position_idx == 1)
        acq_info = read_acq_info(data_directory,position_idx);
        lateral_pixel_size=acq_info{4,2};
        axial_pixel_size = acq_info{6,2};
    end
    acq_info = read_acq_info(data_directory,position_idx);
    
    % Identify the XYZ Coordinates.
    position_X = acq_info{22,2};
    position_Y = acq_info{23,2};
    position_Z = acq_info{24,2};
    data_locations(position_idx,1) = position_X;
    data_locations(position_idx,2) = position_Y;
    data_locations(position_idx,3) = position_Z;
end

number_of_positions=length(data_locations); %user specified
pixel_ratio = axial_pixel_size/lateral_pixel_size;
data_locations = data_locations*pixel_ratio;

% imageParamters = imfinfo(imagePath);
% imageParamters.Width...

fileID = fopen('dataset2.xml','wt');
fprintf(fileID,'<?xml version="1.0" encoding="UTF-8"?> \n');
fprintf(fileID,'<SpimData version="0.2"> \n');
fprintf(fileID,'  <BasePath type="relative">.</BasePath> \n');
fprintf(fileID,'  <SequenceDescription>\n');
fprintf(fileID,'\t\t<ImageLoader format="spimreconstruction.stack.ij"> \n');
fprintf(fileID,'\t\t\t<imagedirectory type="relative">.</imagedirectory> \n');
fprintf(fileID,'\t\t\t<filePattern>1_CH00_{x}.tif</filePattern> \n');
fprintf(fileID,'\t\t\t<layoutTimepoints>0</layoutTimepoints> \n');
fprintf(fileID,'\t\t\t<layoutChannels>0</layoutChannels> \n');
fprintf(fileID,'\t\t\t<layoutIlluminations>0</layoutIlluminations> \n');
fprintf(fileID,'\t\t\t<layoutAngles>0</layoutAngles> \n');
fprintf(fileID,'\t\t\t<layoutTiles>1</layoutTiles> \n');
fprintf(fileID,'\t\t\t<imglib2container>ArrayImgFactory</imglib2container> \n');
fprintf(fileID,'\t\t</ImageLoader> \n');
fprintf(fileID,'<ViewSetups>\n');

%% Loop for id, name, size and tile
for position_idx = 1:1:number_of_positions
    
    fprintf(fileID,'\t<ViewSetup>\n');
    idValue=['\t\t\t<id>' , num2str(position_idx-1) ,'</id>\n'];
    fprintf(fileID,idValue);
    nameValue=['\t\t\t<name>' , num2str(position_idx-1) ,'</name>\n'];
    fprintf(fileID,nameValue);
    fprintf(fileID,'\t\t<size>2048 2048 471</size>\n');
    fprintf(fileID,'\t\t<voxelSize>\n');
    fprintf(fileID,'\t\t\t<unit>um</unit>\n');
    pixelsize=['\t\t\t<size>' num2str(lateral_pixel_size),' ' ,num2str(lateral_pixel_size),' ' ,num2str(axial_pixel_size), '</size> \n'];
    fprintf(fileID,pixelsize);
    fprintf(fileID,'\t\t</voxelSize>\n');
    fprintf(fileID,'\t\t<attributes>\n');
    fprintf(fileID,'\t\t\t<illumination>0</illumination>\n');
    fprintf(fileID,'\t\t\t<channel>0</channel>\n');
    positionNum=['\t\t\t<tile>' , num2str(position_idx-1) , '</tile>\n'];
    fprintf(fileID,positionNum);
    fprintf(fileID,'\t\t\t<angle>0</angle>\n');
    fprintf(fileID,'\t\t</attributes>\n');
    fprintf(fileID,'\t</ViewSetup>\n');
end

%%
fprintf(fileID,'\t<Attributes name="illumination">\n');
fprintf(fileID,'\t\t<Illumination>\n');
fprintf(fileID,'\t\t\t<id>0</id>\n');
fprintf(fileID,'\t\t\t<name>0</name>\n');
fprintf(fileID,'\t\t</Illumination>\n');
fprintf(fileID,'\t</Attributes>\n');
fprintf(fileID,'\t<Attributes name="channel">\n');
fprintf(fileID,'\t\t<Channel>\n');
fprintf(fileID,'\t\t\t<id>0</id>\n');
fprintf(fileID,'\t\t\t<name>0</name>\n');
fprintf(fileID,'\t\t</Channel>\n');
fprintf(fileID,'\t</Attributes>\n');
fprintf(fileID,'\t<Attributes name="tile">\n');

%% specifying the correct tile ID
%for channelIdx = 1...
for position_idx = 1:1:number_of_positions
    fprintf(fileID,'\t\t<Tile>\n');
    idValue=['\t\t\t<id>' , num2str(position_idx-1) , '</id>\n'];
    fprintf(fileID,idValue);
    nameValue=['\t\t\t<name>' , num2str(position_idx) , '</name>\n'];
    fprintf(fileID,nameValue);
    fprintf(fileID,'\t\t</Tile>\n');
end


fprintf(fileID,'\t</Attributes>\n');
fprintf(fileID,'\t<Attributes name="angle">\n');
fprintf(fileID,'\t\t<Angle>\n');
fprintf(fileID,'\t\t\t<id>0</id>\n');
fprintf(fileID,'\t\t\t<name>0</name>\n');
fprintf(fileID,'\t\t</Angle>\n');
fprintf(fileID,'\t</Attributes>\n');
fprintf(fileID,'</ViewSetups>\n');
fprintf(fileID,'<Timepoints type="pattern">\n');
fprintf(fileID,'\t<integerpattern />\n');
fprintf(fileID,'</Timepoints>\n');
fprintf(fileID,'\t</SequenceDescription>\n');
fprintf(fileID,'\t<ViewRegistrations>\n');


%% Loop for timepoint and setup
for position_idx = 1:1:number_of_positions
    setupValue=['\t<ViewRegistration timepoint="0" setup="',num2str(position_idx-1), '">\n'];
    fprintf(fileID,setupValue);
    fprintf(fileID,'\t\t<ViewTransform type="affine">\n');
    fprintf(fileID,'\t\t\t<Name>Translation from Tile Configuration</Name>\n');
    
    firstValue = data_locations(position_idx,1)./lateral_pixel_size;
    secondValue = data_locations(position_idx,2)./lateral_pixel_size;
    thirdValue = data_locations(position_idx,3)./lateral_pixel_size;
    
    fprintf(fileID,['\t\t\t<affine>1.0 0.0 0.0 ' num2str(firstValue) ' 0.0 1.0 0.0 ' num2str(secondValue) ' 0.0 0.0 1.0 ' num2str(thirdValue) '</affine>\n']);
    fprintf(fileID,'\t\t</ViewTransform>\n');
    fprintf(fileID,'\t\t<ViewTransform type="affine">\n');
    fprintf(fileID,'\t\t\t<Name>calibration</Name>\n');
    fprintf(fileID,['\t\t\t<affine>1.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 1.0 ' num2str(axial_pixel_size/lateral_pixel_size) '</affine>\n']);
    fprintf(fileID,'\t\t</ViewTransform>\n');
    fprintf(fileID,'\t</ViewRegistration>  \n');
end


fprintf(fileID,'\t</ViewRegistrations>\n');
fprintf(fileID,'<ViewInterestPoints />\n');
fprintf(fileID,'<BoundingBoxes />\n');
fprintf(fileID,'<PointSpreadFunctions />\n');
fprintf(fileID,'<StitchingResults />\n');
fprintf(fileID,'<IntensityAdjustments />\n');
fprintf(fileID,'</SpimData> \n');


% Close the File
fclose(fileID);

disp('XML File Created');
end

