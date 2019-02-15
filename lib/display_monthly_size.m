function [] = display_monthly_size(time, size_x, size_dist, Title, cRange)
%display_monthly_size description
%   Example:
%       [] = display_monthly_size(time, data, yLabel, Title, dry_month, wet_month, yLog)
%   Inputs:
%       time, data, yLabel, Title, dry_month, wet_month, yLog
%   Outputs:
%       
%   History:
%       2019-02-15. First Edition by Zhenping
%   Contact:
%       zhenping@tropos.de

if ~ exist('cRange', 'var')
    cRange = [0, 0.04];
end

% calculate the monthly mean values of the size distribution
size_dist_monthly_mean = NaN(12, length(size_x));
tot_invs_monthly = NaN(1, 12);
[~, thisMonth, ~, ~, ~, ~] = datevec(time);
for iMonth = 1:12
    indx_month = (thisMonth == iMonth);
    tot_invs_monthly(iMonth) = sum(indx_month);
    size_dist_monthly_mean(iMonth, :) = nanmean(size_dist(indx_month, :), 1);
end

figure;

% for plotting we need the log of the radius
lograd=log10(size_x);

subplot('position',[0.1 0.1 0.7 0.7])

p = imagesc(1:12,lograd,size_dist_monthly_mean');
set(p, 'alphadata', ~isnan(size_dist_monthly_mean'));

% color bar
cb=colorbar('position', [0.82, 0.1, 0.02, 0.7]); caxis(cRange);
ylabel(cb,'dV(r)/dln(r) [\mum^3/\mum^2]','fontsize',12);
% y-axis (log)
set(gca, 'ydir', 'normal')
set(gca, 'ytick', [-2:2])
yvals = get(gca,'ytick');
yTickLabel = cell(0);
for iYTick = 1:numel(yvals)
    yTickLabel{end + 1} = sprintf('%4.1f', 10^yvals(iYTick));
end
set(gca, 'yticklabel', yTickLabel);
ylabel('Radius (r) [\mum]' , 'fontsize', 12);
% x-axis
xlabel('Months','fontsize',12);

% add upper panel
subplot('position', [0.1 0.81 0.7 0.12])
bar(1:12, tot_invs_monthly, 1); xlim([0.5, 12.5]); set(gca,'xticklabel',[]);
ylabel('counts');
title(Title);

end