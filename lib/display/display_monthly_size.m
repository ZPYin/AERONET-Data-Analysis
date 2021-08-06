function fh = display_monthly_size(time, size_bins, Vc_bins, varargin)
%DISPLAY_MONTHLY_SIZE display statistics of volume-size distribution.
%Example:
%   fh = display_monthly_size(time, size_bins, Vc_bins, varargin)
%Inputs:
%   time: numeric
%       timestamp of each measurement. (datenum)
%   size_bins: numberic
%       radius. (micron)
%   Vc_bins: numeric
%       volume-size distribution. (dV(r)/dln(r) micron^3*m^-2)
%   cRange: 2-element array
%       color range of volume-size distribution (default: [0, 0.06]). (micron^3*m^-2)
%   title: char
%       figure title (default: '').
%   figFile: char
%       if this keyword was set, the figure will be exported to the figFile (default: '').
%   matFilename: char
%       if this keyword was set, the figure data will be exported to matFilename (default: '').
%Outputs:
%   fh: figure handle
%       figure handle.
%History:
%   2019-02-15. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'time', @isnumeric);
addRequired(p, 'size_bins', @isnumeric);
addRequired(p, 'Vc_bins', @isnumeric);
addParameter(p, 'cRange', [0, 0.06], @isnumeric);
addParameter(p, 'title', '', @ischar);
addParameter(p, 'figFile', '', @ischar);
addParameter(p, 'matFilename', '', @ischar);

parse(p, time, size_bins, Vc_bins, varargin{:});

% calculate the monthly mean values of the size distribution
size_dist_monthly_mean = NaN(12, length(size_bins));
tot_invs_monthly = NaN(1, 12);
[~, thisMonth, ~, ~, ~, ~] = datevec(time);
for iMonth = 1:12
    indx_month = (thisMonth == iMonth);
    tot_invs_monthly(iMonth) = sum(indx_month);
    size_dist_monthly_mean(iMonth, :) = nanmean(Vc_bins(indx_month, :), 1);
end

fh = figure;

% for plotting we need the log of the radius
lograd = log10(size_bins);

subplot('position', [0.1 0.11 0.7 0.7])

p1 = imagesc(1:12, lograd, transpose(size_dist_monthly_mean));
set(p1, 'alphadata', ~ isnan(transpose(size_dist_monthly_mean)));

% color bar
cb = colorbar('position', [0.82, 0.13, 0.02, 0.66]);
caxis(p.Results.cRange);
ylabel(cb, 'dV(r)/dln(r) [\mum^3/\mum^2]', 'fontsize', 12);

% y-axis (log)
set(gca, 'ydir', 'normal')
set(gca, 'ytick', -2:2)
yvals = get(gca, 'ytick');
yTickLabel = cell(0);
for iYTick = 1:numel(yvals)
    yTickLabel = cat(2, yTickLabel, sprintf('%4.1f', 10^yvals(iYTick)));
end

set(gca, 'yticklabel', yTickLabel, 'Box', 'on', 'LineWidth', 2, 'TickDir', 'out', 'XTick', 1:12);
ylabel('Radius (r) [\mum]', 'fontsize', 12);
% x-axis
xlabel('Months', 'fontsize', 12);

% add upper panel
subplot('position', [0.1 0.82 0.7 0.12])
bar(1:12, tot_invs_monthly, 1);
xlim([0.5, 12.5]);
set(gca, 'xticklabel', []);
ylabel('counts');
title(p.Results.title);

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