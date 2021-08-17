clc; close all;

projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectDir, 'lib')));
addpath(genpath(fullfile(projectDir, 'include')));

%% initialization
dataDir = fullfile(projectDir, 'data');
site = 'Beijing-CAMS';

%% read data
AODFile = listfile(dataDir, sprintf('.*%s.lev20', site));
SDAFile = listfile(dataDir, sprintf('.*%s.ONEILL_lev20', site));
INVFile = listfile(dataDir, sprintf('.*%s.all', site));

if isempty(AODFile) || isempty(SDAFile) || isempty(INVFile)
    error('Data file is missing.');
end

AOD = read_aeronet_AOD_v3_lev2(AODFile{1});
SDA = read_aeronet_SDA_v3_lev2(SDAFile{1});
INV = read_aeronet_INV_v3_lev2(INVFile{1});

%% case filter
AOD_datetime = AOD.date_time;
AE_440_870 = AOD.AE_440_870;
AOD_500 = AOD.AOD_500;
SDA_datetime = SDA.date_time;
FMF = SDA.FMF_500;
INV_datetime = INV.date_time;
Vr = INV.size_dist;
size_bins = INV.size_x;
Nr = conv_vr_2_nr(Vr, size_bins);

% mask NaN
Vr(abs(Vr + 999) <= 1e-5) = NaN;
AOD_500(abs(AOD_500 + 999) <= 1e-5) = NaN;
AE_440_870(abs(AE_440_870 + 999) <= 1e-5) = NaN;
FMF(abs(FMF + 999) <= 1e-5) = NaN;

% interp AOD and AE
AOD_500_interp = interp1(AOD_datetime, AOD_500, INV_datetime, 'linear');
AE_440_870_interp = interp1(AOD_datetime, AE_440_870, INV_datetime, 'linear');
FMF_interp = interp1(SDA_datetime, FMF, INV_datetime, 'linear');

% case mask
flagDustCase = false(size(INV.date_time));
flagPollutionCase = false(size(INV.date_time));
flagMixedCase = false(size(INV.date_time));

flagDustCase((AE_440_870_interp < 0.3) & (FMF_interp < 0.2) & (AOD_500_interp > 0.1)) = true;
flagPollutionCase((AE_440_870_interp > 1.5) & (FMF_interp > 0.8) & (AOD_500_interp > 0.1)) = true;
flagMixedCase((AE_440_870_interp > 0.3) & (AE_440_870_interp < 1.5) & (FMF_interp > 0.4) & (FMF_interp < 0.8) & (AOD_500_interp > 0.3)) = true;

%% calculate F_AOD, C_AOD, and APC_size0
size0 = 280;

% all cases
F_AOD = AOD_500_interp .* FMF_interp;
F_AOD_std = F_AOD .* 0.05;
C_AOD = AOD_500_interp .* (1 - FMF_interp);
C_AOD_std = C_AOD .* 0.05;
APC_size0 = calc_parNumber(size_bins, Nr, 'size_range', [size0 / 1e3, 100], 'interp_size_bin', 0:0.01:20);
APC_size0_std = APC_size0 .* 0.1;
v_size0 = calc_parVolume(size_bins, Vr, 'size_range', [size0 / 1e3, 100], 'interp_size_bin', 0:0.01:20);
v_size0_std = v_size0 .* 0.1;

% dust cases
F_AOD_d = AOD_500_interp(flagDustCase) .* FMF_interp(flagDustCase);
F_AOD_d_std = F_AOD_d .* 0.05;
C_AOD_d = AOD_500_interp(flagDustCase) .* (1 - FMF_interp(flagDustCase));
C_AOD_d_std = C_AOD_d .* 0.05;
APC_size0_d = calc_parNumber(size_bins, Nr(flagDustCase, :), 'size_range', [size0 / 1e3, 100], 'interp_size_bin', 0:0.01:20);
APC_size0_d_std = APC_size0_d .* 0.1;
v_size0_d = calc_parVolume(size_bins, Vr(flagDustCase, :), 'size_range', [size0 / 1e3, 100], 'interp_size_bin', 0:0.01:20);
v_size0_d_std = v_size0_d .* 0.1;

% pollution cases
F_AOD_p = AOD_500_interp(flagPollutionCase) .* FMF_interp(flagPollutionCase);
F_AOD_p_std = F_AOD_p .* 0.05;
C_AOD_p = AOD_500_interp(flagPollutionCase) .* (1 - FMF_interp(flagPollutionCase));
C_AOD_p_std = C_AOD_p .* 0.05;
APC_size0_p = calc_parNumber(size_bins, Nr(flagPollutionCase, :), 'size_range', [size0 / 1e3, 100], 'interp_size_bin', 0:0.01:20);
APC_size0_p_std = APC_size0_p .* 0.1;
v_size0_p = calc_parVolume(size_bins, Vr(flagPollutionCase, :), 'size_range', [size0 / 1e3, 100], 'interp_size_bin', 0:0.01:20);
v_size0_p_std = v_size0_p .* 0.1;

% mixed cases
F_AOD_m = AOD_500_interp(flagMixedCase) .* FMF_interp(flagMixedCase);
F_AOD_m_std = F_AOD_m .* 0.05;
C_AOD_m = AOD_500_interp(flagMixedCase) .* (1 - FMF_interp(flagMixedCase));
C_AOD_m_std = C_AOD_m .* 0.05;
APC_size0_m = calc_parNumber(size_bins, Nr(flagMixedCase, :), 'size_range', [size0 / 1e3, 100], 'interp_size_bin', 0:0.01:20);
APC_size0_m_std = APC_size0_m .* 0.1;
v_size0_m = calc_parVolume(size_bins, Vr(flagMixedCase, :), 'size_range', [size0 / 1e3, 100], 'interp_size_bin', 0:0.01:20);
v_size0_m_std = v_size0_m .* 0.1;
% APC_size0_m_C = APC_size0_m' - (linReg_p_FM.Coefficients.Estimate(2) .* F_AOD_m + linReg_p_FM.Coefficients.Estimate(1));
APC_size0_m_C = APC_size0_m;
APC_size0_m_C(APC_size0_m_C < 0) = NaN;
APC_size0_m_C_std = APC_size0_m_C .* 0.1;

%% linfit
if ~ isempty(C_AOD_p)
    linReg_p = fitlm(C_AOD_p + F_AOD_p, APC_size0_p);
    slope_p = nanmean(APC_size0_p ./ (C_AOD_p + F_AOD_p));
    slope_p_std = 1 ./ length(APC_size0_p) .* sqrt(nansum(((C_AOD_p_std.^2 + F_AOD_p_std.^2)./(C_AOD_p + F_AOD_p).^2) + APC_size0_p_std.^2./APC_size0_p.^2));
end
if ~ isempty(C_AOD_d)
    linReg_d = fitlm(C_AOD_d + F_AOD_d, APC_size0_d);
    slope_d = nanmean(APC_size0_d ./ (C_AOD_d + F_AOD_d));
    slope_d_std = 1 ./ length(APC_size0_d) .* sqrt(nansum(((C_AOD_d.^2 + F_AOD_d.^2)./(C_AOD_d + F_AOD_d).^2) + APC_size0_d_std.^2./APC_size0_d.^2));
end
if (~ isempty(F_AOD_p)) && (~ isempty(C_AOD_m))
    linReg_p_FM = fitlm(F_AOD_p, APC_size0_p);
    slope_p_FM = nanmean(APC_size0_p ./ F_AOD_p);
    slope_p_FM_std = 1 ./ length(APC_size0_p) .* sqrt(nansum(F_AOD_p_std.^2./F_AOD_p.^2 + APC_size0_p_std.^2./APC_size0_p.^2));
    linReg_m = fitlm(C_AOD_m, APC_size0_m_C);
    slope_m = nanmean(APC_size0_m_C ./ C_AOD_m);
    slope_m_std = 1 ./ length(APC_size0_m_C) .* sqrt(nansum(C_AOD_m_std.^2./C_AOD_m.^2 + APC_size0_m_C_std.^2./APC_size0_m_C.^2));
end

%% data visualization

% pollution cases (APC280)
if ~ isempty(F_AOD_p)
    figure('Position', [0, 20, 500, 400], 'Units', 'Pixels');

    p1 = scatter(F_AOD + C_AOD, APC_size0, 10, 'Marker', 'o', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'c', 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0.2, 'DisplayName', 'all cases');
    hold on;
    p2 = scatter(F_AOD_p + C_AOD_p, APC_size0_p, 10, 'Marker', 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'DisplayName', 'pollution');

    plot([0, 10], [0, 10] .* repmat(slope_p, 1, 2), '--k', 'LineWidth', 2);

    xlim([0, 2]);
    ylim([0, 0.5]);

    xlabel('AOD @ 500 nm');
    ylabel(sprintf('n_{%d} (10^{12}m^{-2})', size0))
    title(sprintf('Correlation of n_{%d nm} with AOD for pollution at %s', size0, site));
    text(0.1, 0.7, sprintf('Slope: %5.3f\\pm%5.3f\n', slope_p, slope_p_std), 'Units', 'normalized');

    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLength', [0.02, 0.02]);

    legend([p1, p2], 'Location', 'NorthEast');

    set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
    set(findall(gcf, '-Property', 'FontSize'), 'FontSize', 16);

    export_fig(gcf, fullfile(projectDir, 'img', sprintf('Pollution_related_n%d_at_%s_weighted_mean.png', size0, site)), '-r300');
end

% dust cases
if ~ isempty(F_AOD_d)
    figure('Position', [0, 20, 500, 400], 'Units', 'Pixels');

    p1 = scatter(F_AOD + C_AOD, APC_size0, 10, 'Marker', 'o', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'c', 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0.2, 'DisplayName', 'all cases');
    hold on;
    p2 = scatter(F_AOD_d + C_AOD_d, APC_size0_d, 10, 'Marker', 'o', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'y', 'DisplayName', 'dust');

    plot([0, 10], [0, 10] .* repmat(slope_d, 1, 2), '--y', 'LineWidth', 2);

    xlim([0, 2]);
    ylim([0, 0.5]);

    xlabel('AOD @ 500 nm');
    ylabel(sprintf('n_{%d} (10^{12}m^{-2})', size0));
    title(sprintf('Correlation of n_{%d nm} with AOD for dust at %s', size0, site));
    text(0.1, 0.7, sprintf('Slope: %5.3f\\pm%5.3f\n', slope_d, slope_d_std), 'Units', 'normalized');

    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLength', [0.02, 0.02]);

    legend([p1, p2], 'Location', 'NorthEast');

    set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
    set(findall(gcf, '-Property', 'FontSize'), 'FontSize', 16);

    export_fig(gcf, fullfile(projectDir, 'img', sprintf('Dust_related_n%d_at_%s_weighted_mean.png', size0, site)), '-r300');
end

% mixed cases
if (~ isempty(F_AOD_p)) && (~ isempty(F_AOD_m))
    figure('Position', [0, 20, 500, 400], 'Units', 'Pixels');

    p1 = scatter(F_AOD_d + C_AOD_d, APC_size0_d, 10, 'Marker', 'o', 'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'c', 'MarkerEdgeAlpha', 0.2, 'MarkerFaceAlpha', 0.2, 'DisplayName', 'dust cases');
    hold on;
    p2 = scatter(C_AOD_m, APC_size0_m_C, 10, 'Marker', 'o', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r', 'DisplayName', 'mixed cases');

    plot([0, 10], [0, 10] .* repmat(slope_m, 1, 2), '--r', 'LineWidth', 2);

    xlim([0, 2]);
    ylim([0, 0.5]);

    xlabel('AOD @ 500 nm');
    ylabel(sprintf('n_{%d} (10^{12}m^{-2})', size0));
    title(sprintf('Correlation of n_{%d nm} with AOD for mixed aerosol at %s', size0, site));
    text(0.1, 0.7, sprintf('Slope: %5.3f\\pm%5.3f\n', slope_m, slope_m_std), 'Units', 'normalized');

    set(gca, 'XMinorTick', 'on', 'YMinorTick', 'on', 'Box', 'on', 'LineWidth', 2, 'TickLength', [0.02, 0.02]);

    legend([p1, p2], 'Location', 'NorthEast');

    set(findall(gcf, '-Property', 'FontName'), 'FontName', 'Times New Roman');
    set(findall(gcf, '-Property', 'FontSize'), 'FontSize', 16);

    export_fig(gcf, fullfile(projectDir, 'img', sprintf('Mixed_related_n%d_at_%s_weighted_mean.png', size0, site)), '-r300');
end