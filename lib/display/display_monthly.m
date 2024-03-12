function fh = display_monthly(time, data, varargin)
% DISPLAY_MONTHLY display the monthly mean values of the input parameter.
%
% USAGE:
%    fh = display_monthly(time, data)
%
% INPUTS:
%    time: numeric
%        timestamp for each measurement. (datenum)
%    data: numeric
%        AERONET product.
%
% KEYWORDS:
%    yLabel: char
%        y-axis label (default: 'AOD @ 500 nm').
%    title: char
%        figure title (default: '').
%    dry_month: numeric
%        month tag for dry season (default: []).
%    wet_month: numeric
%        month tag for wet season (default: []).
%    yLog: logical
%        flag to control whether to use logarithm scale (default: false).
%    figFile: char
%        if this keyword was set, the figure will be exported to the figFile (default: '').
%    matFilename: char
%        if this keyword was set, the figure data will be exported to matFilename (default: '').
% OUTPUTS:
%    fh: figure handle
%        figure handle
%
% EXAMPLE:
%   % USECASE 1:
%   display_monthly(time, AOD_500, 'yLabel', 'AOD @ 500 nm', 'title', 'AERONET AOD', 'wet_month', 3:10, 'dry_month', [1:2, 11:12]);
%
% HISTORY:
%    2024-03-12: first edition by Zhenping. 
%    The code is fully based on the source code from https://github.com/hmjbarbosa/aeronet.
% .. Authors: - zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'time', @isnumeric);
addRequired(p, 'data', @isnumeric);
addParameter(p, 'yLabel', 'AOD @ 500 nm', @ischar);
addParameter(p, 'title', '', @ischar);
addParameter(p, 'dry_month', [], @isnumeric);
addParameter(p, 'wet_month', [], @isnumeric);
addParameter(p, 'yLog', false, @islogical);
addParameter(p, 'figFile', '', @ischar);
addParameter(p, 'matFilename', '', @ischar);

parse(p, time, data, varargin{:});

if p.Results.yLog
    data(data <= 0) = nan;
end

fh = figure;

% large horizontal plot
set(gcf, 'position', [300,300,800,300], 'Units', 'Pixels'); % units in pixels!
% set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 8, 3]);

%-----------------------------------------------------------------------
% climatology on the left side
%-----------------------------------------------------------------------
subplot();

XX(1:size(data,1),1:12) = NaN;
for iBin = 1:size(data, 1)
    thisDate = datevec(time(iBin));
    XX(iBin, thisDate(2)) = data(iBin,1);
end

boxplot(gca, XX, 'whisker', 1000, 'PlotStyle', 'traditional');
%plot([0, 1], [0, 1])
title(p.Results.title, 'interpreter', 'none');

% set vertical scale
%maxval=max(data)*1.2;
%minval=0;
yval = get(gca, 'ylim'); 
minval = yval(1); 
maxval = yval(2);
if p.Results.yLog

    if (minval<0)
        minval=min(data(:,1));
    end

    maxval = 10^(ceil(log10(maxval)));
    minval = 10^(floor(log10(minval)));
    ylim([minval, maxval]); 
    set(gca, 'yscale', 'log');

else

    ylim([minval, maxval]); 

end

ylabel(p.Results.yLabel, 'fontsize', 12);
xlabel('Months', 'fontsize', 12);
grid off;

set(gca, 'Position', [0.08, 0.16, 0.73, 0.74]);
pos = get(gca, 'position');

%-----------------------------------------------------------------------
% histograms on right side
%-----------------------------------------------------------------------
subplot('position', [0.83, 0.16, 0.15, 0.74]);
if p.Results.yLog
    bins = 10.^(log10(minval):(log10(maxval) - log10(minval))/100:log10(maxval));
else
    bins = (minval:(maxval-minval)/100:maxval);
end

hdry = histc(reshape(XX(:,p.Results.dry_month), [], 1), bins);
stairs(hdry/sum(hdry), bins, 'r', 'linewidth', 2); 
hold on;
hwet = histc(reshape(XX(:, p.Results.wet_month), [], 1), bins);
stairs(hwet/sum(hwet), bins, 'b', 'linewidth', 2); 
% set vertical scale
if p.Results.yLog
    maxval = 10^(ceil(log10(maxval)));
    minval = 10^(floor(log10(minval)));
    ylim([minval, maxval]); 
    set(gca, 'yscale', 'log');
else
    ylim([minval, maxval]); 
end

xlabel('freq', 'fontsize', 12);

% set horizontal scale
xtic=linspace(0, max([hdry/sum(hdry);hwet/sum(hwet)])*1.2, 4);
xlim([min(xtic), max(xtic)]);
xticl = cell(0);
for i=2:numel(xtic)
    tmp = sprintf('%4.2f',xtic(i));
    xticl = cat(2, xticl, tmp(2:4));
end
set(gca, 'XTick', xtic);
set(gca, 'xticklabel', xticl);
set(gca, 'yticklabel', '');
grid off;

%-----------------------------------------------------------------------
% basis stats in a textbox
%-----------------------------------------------------------------------
medi(1) = nanmean(reshape(XX, [], 1));
medi(2) = nanmean(reshape(XX(:, p.Results.dry_month), [], 1));
medi(3) = nanmean(reshape(XX(:, p.Results.wet_month), [], 1));
desv(1) = nanstd(reshape(XX, [], 1));
desv(2) = nanstd(reshape(XX(:, p.Results.dry_month), [], 1));
desv(3) = nanstd(reshape(XX(:, p.Results.wet_month), [], 1));

% text goes inside the box
stats = ['all: ' sprintf('%4.2f',medi(1)) ' \pm ' ...
        sprintf(' %4.2f',desv(1)) char(10) ...
        'dry: ' sprintf('%4.2f',medi(2)) ' \pm ' ...
        sprintf(' %4.2f',desv(2)) char (10) ...
        'wet: ' sprintf('%4.2f',medi(3)) ' \pm ' ...
        sprintf(' %4.2f',desv(3)) ];
% average the first 3 months to know where to place the box
tmp = nanmean(reshape(XX(:,1:3), [], 1));
bxw = 0.18;
byw = 0.20;
bx = pos(1) + pos(3) * 0.01;
if (abs(maxval-tmp) > abs(tmp-minval))
    % top
    by = pos(2) + pos(4) - byw - pos(4) * 0.02;
else
    % bottom
    by = pos(2) + pos(4) * 0.02;
end

%annotation('textbox', [pos(1), pos(2)+pos(4)-0.20, 0.15, 0.199], ...
annotation('textbox', [bx, by, bxw, byw], ...
           'string', stats,'backgroundcolor','w')

set(gcf, 'Color', 'w');

% font can be configured here
set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');

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