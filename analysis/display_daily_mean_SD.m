% display daily mean size distribution

clc; close all;
global AERONET_ENVS;

%% parameter initialization
sdFile = fullfile(AERONET_ENVS.RootDir, 'data', '19930101_20190209_Beijing-CAMS.all');   % absolute path of the size distribution file.
aodFile = fullfile(AERONET_ENVS.RootDir, 'data', '19930101_20181222_Beijing-CAMS.lev20');
saveDir = 'D:\Data\AERONET';

%% load data
sdData = read_aeronet_INV_v3_lev2(sdFile);

%% filter data
dateRange = [datenum(2011, 1, 1), datenum(2018, 1, 31)];

for iDay = 1:int32(dateRange(2) - dateRange(1))

    startDate = dateRange(1) + iDay - 1;
    stopDate = dateRange(1) + iDay;

    fprintf('Finished %6.2f%%: start %s\n', (double(iDay) - 1)/double(dateRange(2) - dateRange(1)) * 100, datestr(double(startDate), 'yyyy-mm-dd'));

    % flag for averaging
    flagDate = (sdData.date_time < stopDate) & (sdData.date_time >= startDate);
    flagPollution = (sdData.AOD_440 > 0.4) & (sdData.AE_440_870 > 1.0);

    % average size
    mean_size_dist = nanmean(sdData.size_dist(flagDate & flagPollution), 2);
    nCase = sum(flagDate & flagPollution);

    if nCase <= 0
        continue;
    end

    % data visualization
    figure('Position', [50, 50, 800, 600], 'Units', 'Pixels', 'Color', 'w', 'visible', 'off');

    figPos = subfigPos([0.1, 0.1, 0.86, 0.8], 2, 2, 0.07, 0.08);
    colors_all = colormap('jet');
    colors = colors_all(floor(linspace(1, size(colors_all, 1), nCase)), :);

    subplot('Position', figPos(1, :));

    % AOD 440 nm
    p1 = scatter(sdData.date_time(flagDate), sdData.AOD_440(flagDate), [], 'k', 'Marker', 'o', 'MarkerEdgeColor', 'k', 'DisplayName', '440 nm');
    hold on;
    scatter(sdData.date_time(flagDate & flagPollution), sdData.AOD_440(flagDate & flagPollution), [], colors, 'filled', 'Marker', 'o');

    % AOD 675 nm
    p2 = scatter(sdData.date_time(flagDate), sdData.AOD_675(flagDate), [], 'k', 'Marker', 's', 'MarkerEdgeColor', 'k', 'DisplayName', '675 nm');
    hold on;
    scatter(sdData.date_time(flagDate & flagPollution), sdData.AOD_675(flagDate & flagPollution), [], colors, 'filled', 'marker', 's');

    % AOD 870 nm
    p3 = scatter(sdData.date_time(flagDate), sdData.AOD_870(flagDate), [], 'k', 'Marker', 'p', 'MarkerEdgeColor', 'k', 'DisplayName', '870 nm');
    hold on;
    scatter(sdData.date_time(flagDate & flagPollution), sdData.AOD_870(flagDate & flagPollution), [], colors, 'filled', 'Marker', 'p');

    % AOD 1020 nm
    p4 = scatter(sdData.date_time(flagDate), sdData.AOD_1020(flagDate), [], 'k', 'Marker', '^', 'MarkerEdgeColor', 'k', 'DisplayName', '1020 nm');
    hold on;
    scatter(sdData.date_time(flagDate & flagPollution), sdData.AOD_1020(flagDate & flagPollution), [], colors, 'filled', 'Marker', '^');

    xlim([startDate, stopDate]);
    ylim([0, 2]);

    xlabel('Time (UTC)');
    ylabel('AOD');

    legend([p1, p2, p3, p4], 'Location', 'NorthEast');
    
    set(gca, 'Box', 'on', 'LineWidth', 2, 'YMinorTick', 'on', 'XTick', linspace(double(startDate), double(stopDate), 5));
    datetick(gca, 'x', 'HH:MM', 'Keepticks', 'Keeplimits');

    subplot('Position', figPos(2, :));

    % Angstroem exponent 440-870
    scatter(sdData.date_time(flagDate), sdData.AE_440_870(flagDate), [], 'k', 'Marker', '^', 'MarkerEdgeColor', 'k');
    hold on;
    scatter(sdData.date_time(flagDate & flagPollution), sdData.AE_440_870(flagDate & flagPollution), [], colors, 'filled', 'Marker', '^');

    xlim([startDate, stopDate]);
    ylim([0, 2]);

    xlabel('Time (UTC)');
    ylabel('\alpha_{440-870}');
    
    set(gca, 'Box', 'on', 'LineWidth', 2, 'YMinorTick', 'on', 'XTick', linspace(double(startDate), double(stopDate), 5));
    datetick(gca, 'x', 'HH:MM', 'Keepticks', 'Keeplimits');

    % size distribution
    size_dist = sdData.size_dist(flagDate & flagPollution, :);
    subplot('Position', figPos(3, :));
    lineInstances = [];
    meas_time = sdData.date_time(flagDate & flagPollution);
    for iCase = 1:nCase
        p = semilogx(sdData.size_x, size_dist(iCase, :), 'color', colors(iCase, :), 'LineWidth', 1, 'Marker', 'o', 'MarkerFaceColor', colors(iCase, :), 'DisplayName', datestr(meas_time(iCase), 'HH:MM'));

        hold on;

        lineInstances = cat(1, lineInstances, p);
    end

    xlim([0.01, 200]);
    ylim([0, 0.3]);

    xlabel('Radius (\mum)');
    ylabel('dV(r)/dln(r) (\mum^{3}/\mum^{2})');

    set(gca, 'Box', 'on', 'LineWidth', 2, 'YMinorTick', 'on', 'XTick', [0.1, 1.0, 10]);

    legend(lineInstances, 'Location', 'NorthEast');

    % mean size distribution
    subplot('Position', figPos(4, :));
    semilogx(sdData.size_x, nanmean(size_dist, 1), 'Color', 'k', 'Marker', 'o', 'MarkerFaceColor', 'k');

    xlim([0.01, 200]);
    ylim([0, 0.3]);

    xlabel('Radius (\mum)');
    ylabel('Mean dV(r)/dln(r) (\mum^{3}/\mum^{2})');
    set(gca, 'Box', 'on', 'LineWidth', 2, 'YMinorTick', 'on', 'XTick', [0.1, 1.0, 10]);

    text(-0.7, 2.4, sprintf('%s AERONET obs. at %s', datestr(sdData.date_time(1), 'yyyy-mm-dd'), sdData.site), 'Units', 'Normalized', 'FontSize', 15);

    if ~ exist(fullfile(saveDir, sdData.site, datestr(double(startDate), 'yyyy')), 'dir')
        mkdir(fullfile(saveDir, sdData.site, datestr(double(startDate), 'yyyy')));
    end

    export_fig(gcf, fullfile(saveDir, sdData.site, datestr(double(startDate), 'yyyy'), sprintf('%s_overview.png', datestr(double(startDate), 'yyyymmdd'))), '-r300');
end