% test read AERONET data file.

global AERONET_ENVS;

%% tests
fprintf('Start test of reading AERONET level 1.5 AOD data\n');
data = read_AERONET_v3_AOD(fullfile(AERONET_ENVS.RootDir, 'data', 'Punta_Arenas_UMAG_AOD15.txt'), ...
                    'productType', 'AOD15');

fprintf('Start test of reading AERONET level 1.5 SDA data\n');
data = read_AERONET_v3_AOD(fullfile(AERONET_ENVS.RootDir, 'data', 'Punta_Arenas_UMAG_SDA15.txt'), ...
                    'productType', 'SDA15');

fprintf('Start test of reading AERONET level 1.5 INV size-distribution data\n');
data = read_AERONET_v3_INV(fullfile(AERONET_ENVS.RootDir, 'data', 'Punta_Arenas_UMAG_SIZ.txt'), ...
                            'productType', 'SIZ', 'invType', 'ALM15');