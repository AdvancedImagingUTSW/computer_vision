function plot_with_error(average, error, varargin)
%PLOT_WITH_ERROR Plot line standard deviation as solid background.
% average input is a matrix where each row is a time point, and each
% column is a unique time-series. error is the equivalent, but with
% whatever error you would like to report (std, 95% ci, etc.
%   PLOT_WITH_ERROR(FILENAME,FMT)

% parse the input
ip = inputParser; 
ip.CaseSensitive = false;  
ip.KeepUnmatched=true;
ip.addParamValue('x_label','Time Points');
ip.addParamValue('y_label','Fluorescence');
ip.parse(varargin{:});
p=ip.Results;

assert(all(size(average)==size(error)), 'The average and error inputs are not the same size.');

for i = 1:1:size(average,2)
    % Create the Plot Inputs
    x_1 = (1:size(average(:,i),1))';
    y_1 = average(:,i);
    e_1 = error(:,i);
    lo_1 = y_1 - e_1;
    lo_2 = y_1 + e_1;
    first_patch = [x_1; x_1(end:-1:1)];
    second_patch = [lo_1; lo_2(end:-1:1)];
    
    % Make the Figure
    opacity = 0.85;
    hold on;
    hp1 = patch(first_patch, second_patch, 'r');
    set(hp1, 'facecolor', [1 opacity opacity], 'edgecolor', 'none');
    h1 = plot(x_1,y_1,'-r');
   
    %legend([hp1 hp2],'LLSM','OPM','Location','northeast','Orientation','horizontal');
    % legend('boxoff')
    xlabel(p.x_label);
    ylabel(p.y_label);
    
    ax = gca; % current axes
    ax.FontSize = 12;
    ax.TickDir = 'in';
    ax.TickLength = [0.02 0.02];
    ax.XMinorTick = 'on'
    ax.YMinorTick = 'on'
    box on
end
