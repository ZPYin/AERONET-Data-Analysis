clc; close all;

projDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projDir, 'lib'));

%% Initialization
site = 'Punta_Arenas_UMAG';   % AERONET site
                              % site list can be found in https://aeronet.gsfc.nasa.gov/aeronet_locations_v3.txt
starttime = datenum(2019, 1, 1);
stoptime = datenum(2019, 1, 10);
AOD15_file = fullfile(projDir, 'data', sprintf('%s_AOD15.txt', site));
SDA15_file = fullfile(projDir, 'data', sprintf('%s_SDA15.txt', site));
SIZ_file = fullfile(projDir, 'data', sprintf('%s_SIZ.txt', site));
LID_file = fullfile(projDir, 'data', sprintf('%s_LID.txt', site));

%% download data
fprintf('Start downloading the AOD data...\n');
download_AERONET_v3_AOD_web(site, AOD15_file, 'starttime', starttime, 'stoptime', stoptime, 'productType', 'AOD15');

fprintf('Start downloading the SDA data...\n');
download_AERONET_v3_AOD_web(site, SDA15_file, 'starttime', starttime, 'stoptime', stoptime, 'productType', 'SDA15');

fprintf('Start downloading the INV data...\n');
download_AERONET_v3_INV_web(site, SIZ_file, 'starttime', starttime, 'stoptime', stoptime, 'productType', 'SIZ', 'invType', 'ALM15');
download_AERONET_v3_INV_web(site, LID_file, 'starttime', starttime, 'stoptime', stoptime, 'productType', 'LID', 'invType', 'ALM15');

%% read data
fprintf('Start reading the AOD data...\n');
AOD_Res = read_AERONET_v3_AOD(AOD15_file, 'productType', 'AOD15');
fprintf('Finish.\n\n');

fprintf('Start reading the SDA data...\n');
SDA_Res = read_AERONET_v3_AOD(SDA15_file, 'productType', 'SDA15');
fprintf('Finish.\n\n');

fprintf('Start reading the INV data...\n');
SIZ_Res = read_AERONET_v3_INV(SIZ_file, 'invType', 'ALM15', 'productType', 'SIZ');
LID_Res = read_AERONET_v3_INV(LID_file, 'invType', 'ALM15', 'productType', 'LID');
fprintf('Finish.\n\n');

%% data visualization

% AOD and Angstroem Exponent
mask = (AOD_Res.PWV < 6) & (AOD_Res.AOD_500 ~= -999) & (AOD_Res.AE_440_870 ~= -999);
display_time_series(AOD_Res.date_time(mask), AOD_Res.AOD_500(mask), 'yLabel', 'AOD @ 500 nm', 'title', sprintf('Sunphotometer analysis for %s', site));
display_monthly(AOD_Res.date_time(mask), AOD_Res.AOD_500(mask), 'yLabel', 'AOD @ 500 nm', 'title', sprintf('Sunphotometer analysis for %s', site), 'wet_month', 3:10, 'dry_month', [1:2, 11:12]);
display_time_series(AOD_Res.date_time(mask), AOD_Res.AE_440_870(mask), 'yLabel', 'AE 440-870 nm', 'title', sprintf('Sunphotometer analysis for %s', site));
display_monthly(AOD_Res.date_time(mask), AOD_Res.AE_440_870(mask), 'yLabel', 'AE 440-870 nm','title', sprintf('Sunphotometer analysis for %s', site), 'wet_month', 3:10, 'dry_month', [1:2, 11:12]);

% Fine Mode Fraction
mask = (SDA_Res.FMF_500 ~= -999);
display_time_series(SDA_Res.date_time(mask), SDA_Res.FMF_500(mask), 'yLabel', 'FMF @ 500 nm', 'title', sprintf('Sunphotometer analysis for %s', site));
display_monthly(SDA_Res.date_time(mask), SDA_Res.FMF_500(mask), 'yLabel', 'FMF @ 500 nm', 'title', sprintf('Sunphotometer analysis for %s', site), 'wet_month', 3:10, 'dry_month', [1:2, 11:12]);

% size distribution
display_monthly_size(SIZ_Res.date_time, SIZ_Res.size_bin, SIZ_Res.Vr, 'title', sprintf('Monthly size distribution for %s', site), 'cRange', [0, 0.06]);
