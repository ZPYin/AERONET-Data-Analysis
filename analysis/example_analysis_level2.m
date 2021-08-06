clc; close all;

projDir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projDir, 'lib')));
addpath(genpath(fullfile(projDir, 'include')));

%% Initialization
% if you want to analysis the data from other AERONET sites, you need to download the data to the 'data' folder, and change the filename below
station = 'Taihu';
AODFile = fullfile(projDir, 'data', '19930101_20181222_Taihu.lev20');
SDAFile = fullfile(projDir, 'data', '19930101_20181222_Taihu.ONEILL_lev20');
INVFile = fullfile(projDir, 'data', '19930101_20190209_Taihu.all');
tRange = [datenum(2010, 1, 1), datenum(2015, 12, 31)];

% paths of figure file
figFileAOD500 = fullfile(projDir, 'img', sprintf('AOD_timeseries_%s.png', station));
figFileMonthAOD500 = fullfile(projDir, 'img', sprintf('AOD_monthly_mean_%s.png', station));
figFileAE = fullfile(projDir, 'img', sprintf('AE_timeseries_%s.png', station));
figFileMonthAE = fullfile(projDir, 'img', sprintf('AE_monthly_mean_%s.png', station));
figFileFMF = fullfile(projDir, 'img', sprintf('FMF_timeseries_%s.png', station));
figFileMonthFMF = fullfile(projDir, 'img', sprintf('FMF_monthly_mean_%s.png', station));
figFileDR = fullfile(projDir, 'img', sprintf('DR_timeseries_%s.png', station));
figFileMonthDR = fullfile(projDir, 'img', sprintf('DR_monthly_mean_%s.png', station));
figFileLR = fullfile(projDir, 'img', sprintf('LR_timeseries_%s.png', station));
figFileMonthLR = fullfile(projDir, 'img', sprintf('LR_monthly_mean_%s.png', station));
figFileMonthSD = fullfile(projDir, 'img', sprintf('SD_monthly_mean_%s.png', station));

% paths of mat data
matFileAOD500 = fullfile(projDir, 'data', sprintf('AOD_timeseries_%s.mat', station));

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
mask = (AOD_Res.PWV < 6) & (AOD_Res.AOD_500 ~= -999) & (AOD_Res.AE_440_870 ~= -999) & (AOD_Res.date_time >= tRange(1)) & (AOD_Res.date_time <= tRange(2));
display_time_series(AOD_Res.date_time(mask), AOD_Res.AOD_500(mask), 'yLabel', 'AOD @ 500 nm', 'title', ['Sunphotometer analysis for ', station], 'figFile', figFileAOD500, 'matFilename', matFileAOD500);
display_monthly(AOD_Res.date_time(mask), AOD_Res.AOD_500(mask), 'yLabel', 'AOD @ 500 nm', 'title', ['Sunphotometer analysis for ', station], 'wet_month', 3:10, 'dry_month', [1:2, 11:12], 'figFile', figFileMonthAOD500);
display_time_series(AOD_Res.date_time(mask), AOD_Res.AE_440_870(mask), 'yLabel', 'AE 440-870 nm', 'title', ['Sunphotometer analysis for ', station], 'figFile', figFileAE);
display_monthly(AOD_Res.date_time(mask), AOD_Res.AE_440_870(mask), 'yLabel', 'AE 440-870 nm','title', ['Sunphotometer analysis for ', station], 'wet_month', 3:10, 'dry_month', [1:2, 11:12], 'figFile', figFileMonthAE);

% Fine Mode Fraction
mask = (SDA_Res.FMF_500 ~= -999) & (SDA_Res.date_time >= tRange(1)) & (SDA_Res.date_time <= tRange(2));
display_time_series(SDA_Res.date_time(mask), SDA_Res.FMF_500(mask), 'yLabel', 'FMF @ 500 nm', 'title', ['Sunphotometer analysis for ', station], 'figFile', figFileFMF);
display_monthly(SDA_Res.date_time(mask), SDA_Res.FMF_500(mask), 'yLabel', 'FMF @ 500 nm', 'title', ['Sunphotometer analysis for ', station], 'wet_month', 3:10, 'dry_month', [1:2, 11:12], 'figFile', figFileMonthFMF);

% depolarization ratio at 1020 nm
mask = (INV_Res.DepRatio_1020 ~= -999) & (INV_Res.DepRatio_1020 >= 0) & (INV_Res.date_time >= tRange(1)) & (INV_Res.date_time <= tRange(2));
display_time_series(INV_Res.date_time(mask), INV_Res.DepRatio_1020(mask), 'yLabel', 'Depolarization Ratio @ 1020 nm', 'title', ['Sunphotometer analysis for ', station], 'figFile', figFileDR);
display_monthly(INV_Res.date_time(mask), INV_Res.DepRatio_1020(mask), 'yLabel', 'Depolarization Ratio @ 1020 nm', 'title', ['Sunphotometer analysis for ', station], 'wet_month', 3:10, 'dry_month', [1:2, 11:12], 'figFile', figFileMonthDR);

% Lidar ratio at 1020 nm
mask = (INV_Res.LR_1020 ~= -999) & (INV_Res.LR_1020 >= 0) & (INV_Res.date_time >= tRange(1)) & (INV_Res.date_time <= tRange(2));
display_time_series(INV_Res.date_time(mask), INV_Res.LR_1020(mask), 'yLabel', 'Lidar Ratio @ 1020 nm', 'title', ['Sunphotometer analysis for ', station], 'figFile', figFileLR);
display_monthly(INV_Res.date_time(mask), INV_Res.LR_1020(mask), 'yLabel', 'Lidar Ratio @ 1020 nm', 'title', ['Sunphotometer analysis for ', station], 'wet_month', 3:10, 'dry_month', [1:2, 11:12], 'figFile', figFileMonthLR);

% % size distribution
display_monthly_size(INV_Res.date_time, INV_Res.size_x, INV_Res.size_dist, 'title', ['Monthly size distribution for ', station], 'cRange', [0, 0.06], 'figFile', figFileMonthSD);
