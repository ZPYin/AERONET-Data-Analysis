clc; close all;

projDir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projDir, 'lib')));
addpath(genpath(fullfile(projDir, 'include')));

%% Initialization
% if you want to analysis the data from other AERONET sites, you need to download the data to the 'data' folder, and change the filename below
AODFile = fullfile(projDir, 'data', '19930101_20181222_Taihu.lev20');
SDAFile = fullfile(projDir, 'data', '19930101_20181222_Taihu.ONEILL_lev20');
INVFile = fullfile(projDir, 'data', '19930101_20190209_Taihu.all');

%% read data
fprintf('Start reading the AOD data: %s\n', basename(AODFile));
AOD_Res = read_aeronet_AOD_v3_lev2(AODFile);
fprintf('Finish.\n\n');

fprintf('Start reading the SDA data: %s\n', basename(SDAFile));
SDA_Res = read_aeronet_SDA_v3_lev2(SDAFile);
fprintf('Finish.\n\n');

fprintf('Start reading the INV data: %s\n', basename(INVFile));
INV_Res = read_aeronet_INV_v3_lev2(INVFile);
fprintf('Finish.\n\n');

%% data visualization

% AOD and Angstroem Exponent
mask = (AOD_Res.PWV < 6) & (AOD_Res.AOD_500 ~= -999) & (AOD_Res.AE_440_870 ~= -999);
display_time_series(AOD_Res.date_time(mask), AOD_Res.AOD_500(mask), 'yLabel', 'AOD @ 500 nm', 'title', 'Sunphotometer analysis for Taihu');
display_monthly(AOD_Res.date_time(mask), AOD_Res.AOD_500(mask), 'yLabel', 'AOD @ 500 nm', 'title', 'Sunphotometer analysis for Taihu', 'wet_month', 3:10, 'dry_month', [1:2, 11:12]);
display_time_series(AOD_Res.date_time(mask), AOD_Res.AE_440_870(mask), 'yLabel', 'AE 440-870 nm', 'title', 'Sunphotometer analysis for Taihu');
display_monthly(AOD_Res.date_time(mask), AOD_Res.AE_440_870(mask), 'yLabel', 'AE 440-870 nm','title', 'Sunphotometer analysis for Taihu', 'wet_month', 3:10, 'dry_month', [1:2, 11:12]);

% Fine Mode Fraction
mask = (SDA_Res.FMF_500 ~= -999);
display_time_series(SDA_Res.date_time(mask), SDA_Res.FMF_500(mask), 'yLabel', 'FMF @ 500 nm', 'title', 'Sunphotometer analysis for Taihu');
display_monthly(SDA_Res.date_time(mask), SDA_Res.FMF_500(mask), 'yLabel', 'FMF @ 500 nm', 'title', 'Sunphotometer analysis for Taihu', 'wet_month', 3:10, 'dry_month', [1:2, 11:12]);

% depolarization ratio at 1020 nm
mask = (INV_Res.DepRatio_1020 ~= -999) & (INV_Res.DepRatio_1020 >= 0);
display_time_series(INV_Res.date_time(mask), INV_Res.DepRatio_1020(mask), 'yLabel', 'Depolarization Ratio @ 1020 nm', 'title', 'Sunphotometer analysis for Taihu');
display_monthly(INV_Res.date_time(mask), INV_Res.DepRatio_1020(mask), 'yLabel', 'Depolarization Ratio @ 1020 nm', 'title', 'Sunphotometer analysis for Taihu', 'wet_month', 3:10, 'dry_month', [1:2, 11:12]);

% Lidar ratio at 1020 nm
mask = (INV_Res.LR_1020 ~= -999) & (INV_Res.LR_1020 >= 0);
display_time_series(INV_Res.date_time(mask), INV_Res.LR_1020(mask), 'yLabel', 'Lidar Ratio @ 1020 nm', 'title', 'Sunphotometer analysis for Taihu');
display_monthly(INV_Res.date_time(mask), INV_Res.LR_1020(mask), 'yLabel', 'Lidar Ratio @ 1020 nm', 'title', 'Sunphotometer analysis for Taihu', 'wet_month', 3:10, 'dry_month', [1:2, 11:12]);

% % size distribution
display_monthly_size(INV_Res.date_time, INV_Res.size_x, INV_Res.size_dist, 'title', 'Monthly size distribution for Taihu', 'cRange', [0, 0.06]);
