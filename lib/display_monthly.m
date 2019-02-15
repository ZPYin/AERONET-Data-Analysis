function [] = display_monthly(time, data, yLabel, Title, dry_month, wet_month, yLog)
%display_monthly display the monthly mean values of the input parameter.
%   Example:
%       [] = display_monthly(time, data, yLabel, Title, dry_month, wet_month, yLog)
%   Inputs:
%       time, data, yLabel, Title, dry_month, wet_month, yLog
%   Outputs:
%       
%   History:
%       The code is fully based on the source code from https://github.com/hmjbarbosa/aeronet.
%   Contact:
%       zhenping@tropos.de

if ~exist('ylog','var') 
    ylog = 0; 
end

if (ylog)
    data(data <= 0) = nan;
end

figure;
% large horizontal plot
set(gcf, 'position', [300,300,800,300]); % units in pixels!
set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 8 3]);
%-----------------------------------------------------------------------
% climatology on the left side
%-----------------------------------------------------------------------
sub=subplot('position',[0.08 0.05 0.73 0.85]);
XX(1:size(data,1),1:12) = NaN;
for i=1:size(data,1)
    thisDate = datevec(time(i));
    XX(i,thisDate(2)) = data(i,1);
end
boxplot(XX, 'whisker', 1000);
title(Title, 'interpreter', 'none');
% set vertical scale
%maxval=max(data)*1.2;
%minval=0;
yval=get(gca,'ylim'); 
minval=yval(1); 
maxval=yval(2);
if (ylog)
    if (minval<0)
    minval=min(data(:,1));
    end
    maxval=10^(ceil(log10(maxval)));
    minval=10^(floor(log10(minval)));
    ylim([minval maxval]); 
    set(gca,'yscale','log');
else
    ylim([minval maxval]); 
end
pos=get(gca,'position');
ylabel(yLabel,'fontsize',12);
xlabel('Months','fontsize',12);
grid on;
%-----------------------------------------------------------------------
% histograms on right side
%-----------------------------------------------------------------------
sub=subplot('position',[0.83 pos(2) 0.15 pos(4)]);
if (ylog)
    bins=10.^[log10(minval):(log10(maxval)-log10(minval))/100:log10(maxval)];
else
    bins=[minval:(maxval-minval)/100:maxval];
end
hdry=histc(reshape(XX(:,dry_month),[],1),bins);
stairs(hdry/sum(hdry),bins,'r','linewidth',2); 
hold on;
hwet=histc(reshape(XX(:,wet_month),[],1),bins);
stairs(hwet/sum(hwet),bins,'b','linewidth',2); 
% set vertical scale
if (ylog)
    maxval=10^(ceil(log10(maxval)));
    minval=10^(floor(log10(minval)));
    ylim([minval maxval]); 
    set(gca,'yscale','log');
else
    ylim([minval maxval]); 
end
xlabel('freq','fontsize',12);
% set horizontal scale
tmp=get(gca,'xtick');
xtic=linspace(0, max([hdry/sum(hdry);hwet/sum(hwet)])*1.2, 4);
xlim([min(xtic) max(xtic)]);
xticl=cell(0);
for i=2:numel(xtic)
    tmp=sprintf('%4.2f',xtic(i));
    xticl{end + 1}= tmp(2:4);
end
set(gca,'XTick',xtic);
set(gca,'xticklabel',xticl);
set(gca,'yticklabel','');
grid on; 
%-----------------------------------------------------------------------
% basis stats in a textbox
%-----------------------------------------------------------------------
medi(1)=nanmean(reshape(XX,[],1));
medi(2)=nanmean(reshape(XX(:,dry_month),[],1));
medi(3)=nanmean(reshape([XX(:,wet_month)],[],1));
desv(1)=nanstd(reshape(XX,[],1));
desv(2)=nanstd(reshape(XX(:,dry_month),[],1));
desv(3)=nanstd(reshape([XX(:,wet_month)],[],1));
% text goes inside the box
stats=['all: ' sprintf('%4.2f',medi(1)) ' \pm ' ...
        sprintf(' %4.2f',desv(1)) char(10) ...
        'dry: ' sprintf('%4.2f',medi(2)) ' \pm ' ...
        sprintf(' %4.2f',desv(2)) char (10) ...
        'wet: ' sprintf('%4.2f',medi(3)) ' \pm ' ...
        sprintf(' %4.2f',desv(3)) ];
% average the first 3 months to know where to place the box
tmp=nanmean(reshape(XX(:,1:3),[],1));
bxw=0.15;
byw=0.20;
bx=pos(1)+pos(3)*0.01;
if (abs(maxval-tmp) > abs(tmp-minval))
    % top
    by=pos(2)+pos(4)-byw-pos(4)*0.02;
else
    % bottom
    by=pos(2)+pos(4)*0.02;
end
%annotation('textbox', [pos(1), pos(2)+pos(4)-0.20, 0.15, 0.199], ...
annotation('textbox', [bx, by, bxw, byw], ...
            'string', stats,'backgroundcolor','w')
%
end