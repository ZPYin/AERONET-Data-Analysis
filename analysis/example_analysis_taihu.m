clc; close all;

projDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projDir, 'lib'));

%% Initialization
% if you want to analysis the data from other AERONET sites, you need to download the data to the 'data' folder, and change the filename below
AODFile = fullfile(projDir, 'data', '19930101_20181222_Taihu.lev20');
SDAFile = fullfile(projDir, 'data', '19930101_20181222_Taihu.ONEILL_lev20');
INVFile = fullfile(projDir, 'data', '19930101_20190209_Taihu.all');

%% read data
fprintf('Start reading the AOD data from %s\n', basename(AODFile));
AOD_Res = read_aeronet_AOD_v3_lev2(AODFile);
fprintf('Finish.\n\n');

fprintf('Start reading the SDA data from %s\n', basename(AODFile));
SDA_Res = read_aeronet_SDA_v3_lev2(SDAFile);
fprintf('Finish.\n\n');

fprintf('Start reading the INV data from %s\n', basename(AODFile));
INV_Res = read_aeronet_INV_v3_lev2(INVFile);
fprintf('Finish.\n\n');

%% data visualization

% AOD and Angstroem Exponent
mask = (AOD_Res.PWV < 6) & (AOD_Res.AOD_500 ~= -999) & (AOD_Res.AE_440_870 ~= -999);
display_time_series(AOD_Res.date_time(mask), AOD_Res.AOD_500(mask), 'AOD @ 500 nm', 'Sunphotometer analysis for Taihu');
display_monthly(AOD_Res.date_time(mask), AOD_Res.AOD_500(mask), 'AOD @ 500 nm', 'Sunphotometer analysis for Taihu', [3:10], [1:2, 11:12]);
display_time_series(AOD_Res.date_time(mask), AOD_Res.AE_440_870(mask), 'AE 440-870 nm', 'Sunphotometer analysis for Taihu');
display_monthly(AOD_Res.date_time(mask), AOD_Res.AE_440_870(mask), 'AE 440-870 nm', 'Sunphotometer analysis for Taihu', [3:10], [1:2, 11:12]);

% Fine Mode Fraction
mask = (SDA_Res.FMF_500 ~= -999);
display_time_series(SDA_Res.date_time(mask), SDA_Res.FMF_500(mask), 'FMF @ 500 nm', 'Sunphotometer analysis for Taihu');
display_monthly(SDA_Res.date_time(mask), SDA_Res.FMF_500(mask), 'FMF @ 500 nm', 'Sunphotometer analysis for Taihu', [3:10], [1:2, 11:12]);

% depolarization ratio at 1020 nm
mask = (INV_Res.DepRatio_1020 ~= -999) & (INV_Res.DepRatio_1020 >= 0);
display_time_series(INV_Res.date_time(mask), INV_Res.DepRatio_1020(mask), 'Depolarization Ratio @ 1020 nm', 'Sunphotometer analysis for Taihu');
display_monthly(INV_Res.date_time(mask), INV_Res.DepRatio_1020(mask), 'Depolarization Ratio @ 1020 nm', 'Sunphotometer analysis for Taihu', [3:10], [1:2, 11:12]);

% Lidar ratio at 1020 nm
mask = (INV_Res.LR_1020 ~= -999) & (INV_Res.LR_1020 >= 0);
display_time_series(INV_Res.date_time(mask), INV_Res.LR_1020(mask), 'Lidar Ratio @ 1020 nm', 'Sunphotometer analysis for Taihu');
display_monthly(INV_Res.date_time(mask), INV_Res.LR_1020(mask), 'Lidar Ratio @ 1020 nm', 'Sunphotometer analysis for Taihu', [3:10], [1:2, 11:12]);

% size distribution
display_monthly_size(INV_Res.date_time, INV_Res.size_x, INV_Res.size_dist, 'Monthly size distribution for Taihu', [0, 0.06]);