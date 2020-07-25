clc; close all;

projectDir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(projectDir, 'lib')));
addpath(genpath(fullfile(projectDir, 'include')));

%% tests
fprintf('Start test of reading AERONET level 1.5 AOD data\n');
data = read_AERONET_v3_AOD(fullfile(projectDir, 'data', 'Punta_Arenas_UMAG_AOD15.txt'), ...
                    'productType', 'AOD15');

fprintf('Start test of reading AERONET level 1.5 SDA data\n');
data = read_AERONET_v3_AOD(fullfile(projectDir, 'data', 'Punta_Arenas_UMAG_SDA15.txt'), ...
                    'productType', 'SDA15');

fprintf('Start test of reading AERONET level 1.5 INV size-distribution data\n');
data = read_AERONET_v3_INV(fullfile(projectDir, 'data', 'Punta_Arenas_UMAG_SIZ.txt'), ...
                            'productType', 'SIZ', 'invType', 'ALM15');