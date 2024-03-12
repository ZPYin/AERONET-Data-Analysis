global AERONET_ENVS;

AERONET_ENVS.RootDir = fileparts(mfilename('fullpath'));

addpath(genpath(fullfile(AERONET_ENVS.RootDir, 'include')));
addpath(genpath(fullfile(AERONET_ENVS.RootDir, 'lib')));
addpath(genpath(fullfile(AERONET_ENVS.RootDir, 'test')));