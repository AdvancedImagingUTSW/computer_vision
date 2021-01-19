% watershed_roi  Perform local label-based watershed.
% This function is called with any of these syntaxes:
%
%   watershed_roi(in1, in2, in 3, in4, in5, in6) accepts 6 required arguments. 
%   watershed_roi(in1, in2, in3) also accepts an optional 3rd argument.
%   Will modify soon to have optional arguments.
%   watershed_roi(___, NAME, VALUE) accepts one or more of the following name-value pair 
%       arguments. This syntax can be used in any of the previous syntaxes.
%           * 'NAME1' with logical value
%           * 'NAME2' with 'Default', 'Choice1', or 'Choice2'
function [movie_info, feat_prop_final_3d ] = watershed_roi (image_volume,low_frequency,high_frequency,...
    step_size, difference_of_gaussians, noise_sigma)



image_volume = im2uint16(image_volume);

%% Filter the Data - Originally taken from detectMoviePointSources3D.m, RAM USAGE - ~20GB/file.
if(difference_of_gaussians)
    filtered_volume = filterGauss3D(image_volume,high_frequency)-filterGauss3D(image_volume,low_frequency);
    disp(['Maximum Intensity of Vol After DoG Filtering = ' num2str(max(filtered_volume(:)))]);
else
    filtered_volume = double(image_volume);
end

%% Automatically Identify the Threshold
thFilterDiff = locmax3d(filtered_volume,1);
if(~any(thFilterDiff(:)))
    % If the entire image is zero valued...
    feat_prop_final_3d = struct('VoxelList',[],'WeightedCentroid',[],'MeanIntensity',[],'MaxIntensity',[],...
        'Volume',[],'BoundingBox',[],'Centroid',[],'ConvexImage',[],'EquivDiameter',[],'Extent',[],'PrincipalAxisLength',[],'Image',[]);
    
    movie_info = struct('xCoord',[],'yCoord',[],'zCoord',[],'amp',[],'int',[],'volume',[]);
else
    threshold = thresholdOtsu(thFilterDiff)/3 + thresholdRosin(thFilterDiff)*2/3;
    std=nanstd(filtered_volume(thFilterDiff<threshold));
    thresh= noise_sigma*std;
    disp(['The Threshold for the Watershed is = ' num2str(thresh)]);
    
    %% Run Watershed
    pxlscale = [1 1 1];
    nSteps = round((nanmax(filtered_volume(:))-thresh)/double(step_size));
    threshList = linspace(nanmax(filtered_volume(:)),thresh,nSteps);
    
    movie_info = struct('xCoord',[],'yCoord',[],'zCoord',[],'amp',[],'int',[],'volume',[]);
    feat_prop_final_3d = struct('VoxelList',[],'WeightedCentroid',[],'MeanIntensity',[],'MaxIntensity',[],...
        'Volume',[],'BoundingBox',[],'Centroid',[],'ConvexImage',[],'EquivDiameter',[],'Extent',[],'PrincipalAxisLength',[],'Image',[]);
    
    %If no peaks identified, cancel function.
    if nSteps<1
        disp('No Peaks Identified in Watershed');
        movie_info.xCoord = 0;
        movie_info.yCoord = 0;
        movie_info.zCoord = 0;
        movie_info.amp = 0;
        movie_info.int = 0;
        return
    end
    
    % Handle case where nSteps==1
    if nSteps==1
        slice2 = filtered_volume>threshList(1);
    end
    
    % compare features in z-slices starting from the highest one
    for j = 1:length(threshList)-1
        disp([num2str(j) ' out of ' num2str(length(threshList)-1)]);
        % slice1 is top slice, slice2 is next slice down
        
        % Generate BW masks of slices
        if j==1
            slice1 = filtered_volume>threshList(j);
        else
            slice1 = slice2;
        end
        slice2 = filtered_volume>threshList(j+1);
        
        % now we label them using the "bwlabeln" function from matlab which
        % labels connected components in a N-D binary image
        featMap1 = bwlabeln(slice1);
        featMap2 = bwlabeln(slice2);
        
        % get the regionproperty 'PixelIdxList' using "regionprops" function in matlab
        featProp2 = regionprops(featMap2,'PixelIdxList');
        
        % loop thru slice2 features and replace them if there are 2 or
        % more features from slice1 that contribute
        for iFeat = 1:max(featMap2(:))
            pixIdx = featProp2(iFeat,1).PixelIdxList; % pixel indices from slice2
            featIdx = unique(featMap1(pixIdx)); % feature indices from slice1 using same pixels
            featIdx(featIdx==0) = []; % 0's shouldn't count since not feature
            if length(featIdx)>1 % if two or more features contribute...
                slice2(pixIdx) = slice1(pixIdx); % replace slice2 pixels with slice1 values
            end
        end
        
    end
    
    
    % label slice2 again and get region properties
    featProp2 = regionprops(logical(slice2),'PixelIdxList','Area');
    
    % here we sort through features and retain only the "good" ones
    % we assume the good features have area > 2 pixels
    goodFeatIdx = vertcat(featProp2(:,1).Area)>2;
    
    % make new label matrix and get props
    featureMap = zeros(size(filtered_volume));
    featureMap(vertcat(featProp2(goodFeatIdx,1).PixelIdxList)) = 1;
    [featMapFinal,nFeats] = bwlabeln(featureMap);
    
    feat_prop_final = regionprops(featMapFinal,filtered_volume,'PixelIdxList','Area','WeightedCentroid','MeanIntensity','MaxIntensity','PixelValues');
    feat_prop_final_3d = regionprops3(featMapFinal,filtered_volume,'VoxelList','WeightedCentroid','MeanIntensity','MaxIntensity','Volume','BoundingBox',...
        'Centroid','Image','EquivDiameter','Extent','PrincipalAxisLength','SurfaceArea');
    
    if(nFeats==0)
        disp('No Features Detected');
        
    else
        % centroid coordinates with 0.5 uncertainties for Khuloud's tracker
        yCoord = 0.5*ones(nFeats,2);
        xCoord = 0.5*ones(nFeats,2);
        zCoord = 0.5*ones(nFeats,2);
        temp = vertcat(feat_prop_final.WeightedCentroid);
        zCoord(:,1) = temp(:,3);
        yCoord(:,1) = temp(:,2);
        xCoord(:,1) = temp(:,1);
        
        % SB: shoudl we use meanIntensity instead>>>
        % area
        featArea = vertcat(feat_prop_final(:,1).Area);
        amp = zeros(nFeats,2);
        amp(:,1) = featArea;
        
        % intensity
        featInt = vertcat(feat_prop_final(:,1).MaxIntensity);
        featI = zeros(nFeats,2);
        featI(:,1) = featInt;
        
        % Construct the Movie Info
        verDate=version('-date');
        movie_info.xCoord = xCoord*pxlscale(1);
        movie_info.yCoord = yCoord*pxlscale(2);
        movie_info.zCoord = zCoord*pxlscale(3);
        movie_info.amp = amp;
        movie_info.int = featI;
    end
end
