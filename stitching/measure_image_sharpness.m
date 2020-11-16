function measure_image_sharpness(dataDirectory, numberOfPositions, numberOfChannels)

% Uses AutoPilot image metrics to determine if something is present in the
% image.
% https://github.com/MicroscopeAutoPilot/AutoPilot/wiki/howtobuild
% To compile, must specify load the java module (java/oracle/jdk1.8.0_231)
% and specify the Java and Gradle proxy (these are not the actual commands):
% _JAVA_OPTIONS: -Dhttp.proxyHost=proxy.swmed.edu -Dhttp.proxyPort=3128 -Dhttps.proxyHost=proxy.swmed.edu -Dhttps.proxyPort=3128
%
% systemProp.http.proxyHost=proxy.swmed.edu
% systemProp.http.proxyPort=3128
% systemProp.https.proxyHost=proxy.swmed.edu
% systemProp.https.proxyPort=3128

% Kevin Dean, 05-24-2020.

%% MIP Data, and perform 2D DCTS on it.
import autopilot.interfaces.AutoPilotM.*;

final_data = zeros(numberOfPositions, numberOfChannels);

for channelIdx = 1:1:numberOfChannels
    for positionIdx = 1:1:numberOfPositions
        filepath = fullfile(dataDirectory,['MIP_CH0' num2str(channelIdx-1)], ...
            ['1_CH0' num2str(channelIdx-1) '_' num2str(positionIdx) '.tif']);
        image_data = imread(filepath);
        a = dcts2(image_data, 3);
        final_data(positionIdx, channelIdx) = a;
    end
end

plot(final_data);

