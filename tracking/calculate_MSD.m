clc;
clear;
%data_path = '/work/archive/MIL/dean/20200602_ASLM_RemoteRefocus_GEMS_crop';
%cd(data_path);
%indexLSFMData(fullfile(data_path,'1_CH00_*.tif'), data_path, 'lateralPixelSize',163,'axialPixelSize',163,'timeInterval',0.282457);
% in the end, I used the uTrackPackageGUI to make the MovieData

%%
uTrackPackageGUI();

%%
load('/archive/MIL/dean/20200602_ASLM_RemoteRefocus_GEMS_crop/TrackingPackage/tracks/Channel_1_tracking_result.mat')
tracks = TracksHandle(tracksFinal);
tracksDiffCoeff=arrayfun(@(t) nanmean(sum([t.x(1)-t.x(2:end); t.y(1)-t.y(2:end); t.z(1)-t.z(2:end)].^2))/(6*t.lifetime),tracks);
tracksDiffCoeffMax = arrayfun(@(t) nanmax(sum([t.x(1)-t.x(2:end); t.y(1)-t.y(2:end); t.z(1)-t.z(2:end)].^2))/(6*t.lifetime),tracks);

% delta r^3/2Dt

%%
h = histogram(tracksDiffCoeffMax,50);

%%
binCounts = h.Values

%%
fitout = histfit(tracksDiffCoeff,50,'gamma')