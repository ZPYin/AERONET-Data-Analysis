function []=display_time_series(time, data, yLabel, Title)
%display_time_series description
%   Example:
%       [output] = display_time_series(time, data, yLabel, Title)
%   Inputs:
%       time, data, yLabel, Title
%   Outputs:
%   History:
%       The code is fully based on the source code from https://github.com/hmjbarbosa/aeronet.

figure;

% large horizontal plot
set(gcf,'position',[300,300,800,300]); % units in pixels!
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3])
% climatology on the left side
sub=subplot('position',[0.08 0.14 0.73 0.76]);
plot(time, data, '.');
title(Title, 'interpreter', 'none');
% largest val
%maxval=max(val(:,1))*1.2;
%minval=0;
yval=get(gca,'ylim'); 
minval=yval(1); 
maxval=yval(2);
ylim([minval maxval]); 
ylabel(yLabel,'fontsize',12);
xlabel('Year/Month','fontsize',12);
% round scale to full years 
xlim([time(1), time(end)]);
datetick('x','yy/mm','keeplimits');
grid on; 
% histograms on right side
sub=subplot('position',[0.83 0.14 0.15 0.76]);
bins=[minval:(maxval-minval)/100:maxval];
hall=histc(data(:,1),bins);
b=barh(bins+(bins(2)-bins(1))/2,hall/sum(hall),1,'w'); 
set(b,'facecolor',[0.7 0.7 0.7]);
ylim([minval maxval]); 
xlabel('freq','fontsize',12);
tmp=get(gca,'xtick');
xtic=linspace(0, max(hall/sum(hall))*1.2, 4);
xlim([min(xtic) max(xtic)]);
xticl=cell(0);
for i=2:numel(xtic)
    tmp=sprintf('%4.2f',xtic(i));
    xticl{end + 1} = tmp(2:4);
end
set(gca,'XTick',xtic);
set(gca,'xticklabel',xticl);
set(gca,'yticklabel','');
grid on;

end