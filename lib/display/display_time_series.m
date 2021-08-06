function fh = display_time_series(time, data, varargin)
%DISPLAY_TIME_SERIES display timeseries of AERONET products.
%Example:
%   % Usecase 1:
%   display_time_series(time, AOD_500, 'yLabel', 'AOD @ 500 nm', 'title', 'Sunphotometer analysis for Taihu');
%Inputs:
%   time: numeric
%       timestamp of each measurement. (datenum)
%   data: numeric
%       AERONET product.
%Keywords:
%   yLabel: char
%       y-axis label (default: 'AOD @ 500 nm').
%   title: char
%       figure title (default: '');
%   figFile: char
%       if this keyword was set, the figure will be exported to the figFile (default: '').
%   matFilename: char
%       if this keyword was set, the figure data will be exported to matFilename (default: '').
%Outputs:
%   fh: figure handle
%       figure handle.
%History:
%   The code is fully based on the source code from https://github.com/hmjbarbosa/aeronet.
%Contact:
%   zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'time', @isnumeric);
addRequired(p, 'data', @isnumeric);
addParameter(p, 'yLabel', 'AOD @ 500 nm', @ischar);
addParameter(p, 'title', '', @ischar);
addParameter(p, 'matFilename', '', @ischar);
addParameter(p, 'figFile', '', @ischar);

parse(p, time, data, varargin{:});

fh = figure;

% large horizontal plot
set(gcf, 'position', [300,300,800,300], 'Units', 'Pixels'); % units in pixels!
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 8, 3]);

% climatology on the left side
subplot('position', [0.08 0.16 0.73 0.74]);
plot(time, data, '.');
title(p.Results.title, 'interpreter', 'none');
% largest val
%maxval=max(val(:,1))*1.2;
%minval=0;
yval = get(gca, 'ylim'); 
minval = yval(1); 
maxval = yval(2);
ylim([minval, maxval]); 
ylabel(p.Results.yLabel, 'fontsize', 12);
xlabel('Year/Month', 'fontsize', 12);
% round scale to full years 
xlim([time(1), time(end)]);
datetick('x', 'yy/mm', 'keeplimits');
grid off;

% histograms on right side
subplot('position', [0.83 0.16 0.15 0.74]);
bins = minval:(maxval-minval)/100:maxval;
hall = histc(data(:, 1), bins);
b = barh(bins+(bins(2)-bins(1))/2, hall/sum(hall), 1, 'w'); 
set(b,'facecolor', [0.7, 0.7, 0.7]);
ylim([minval, maxval]); 
xlabel('freq', 'fontsize', 12);
get(gca,'xtick');
xtic = linspace(0, max(hall/sum(hall))*1.2, 4);
xlim([min(xtic), max(xtic)]);
xticl = cell(0);
for i = 2:numel(xtic)
    tmp = sprintf('%4.2f', xtic(i));
    xticl = cat(2, xticl, tmp(2:4));
end
set(gca, 'XTick', xtic);
set(gca, 'xticklabel', xticl);
set(gca, 'yticklabel', '');
grid off;

% font can be configured here
set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
set(gcf, 'Color', 'w');

% export figure to file
if ~ isempty(p.Results.figFile)
    fprintf('exporting figure to %s\n', p.Results.figFile);
    export_fig(gcf, p.Results.figFile, '-r300');
    fprintf('Finish.\n');
end

% export data
if ~ isempty(p.Results.matFilename)
    fprintf('Exporting data to %s\n', p.Results.matFilename);
    save(p.Results.matFilename, 'time', 'data');
    fprintf('Finish.\n');
end

end