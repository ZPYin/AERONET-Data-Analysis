function aeronet = read_AERONET_v3_INV(filename, varargin)
%READ_AERONET_V3_INV read AERONET version 3 INV products.
%Example:
%   % Usecase 1: read size distribution data
%   [aeronet] = read_AERONET_v3_INV(filename, 'invType', 'ALM15', 'productType', 'SIZ');
%Inputs:
%   filename: char
%       absolute path of AERONET INV product file.
%Keywords:
%   invType (default: 'ALM15'): char
%       scanning type (default: ALM15).
%       ALM15   Level 1.5 Almucantar Retrievals
%       ALM20   Level 2.0 Almucantar Retrievals
%       HYB15   Level 1.5 Hybrid Retrievals
%       HYB20   Level 2.0 Hybrid Retrievals
%   productType (default: 'SIZ'): char
%       product type
%       SIZ Size distribution
%       RIN Refractive indicies (real and imaginary)
%       CAD Coincident AOT data with almucantar retrieval
%       VOL Volume concentration, volume mean radius, effective radius and standard deviation
%       TAB AOT absorption
%       AOD AOT extinction
%       SSA Single scattering albedo
%       ASY Asymmetry factor
%       FRC Radiative Forcing
%       LID Lidar and Depolarization Ratios
%       FLX Spectral flux
%       ALL All of the above retrievals (SIZ to FLUX) in one file
%       PFN*    Phase function (available for only all points data format: AVG=10)
%       U27 Estimation of Sensitivity to 27 Input Uncertainty Variations 
%           (available for only all points data format: AVG=10 and ALM20 and HYB20)
%   AVG: char
%       daily averaged product ('20') or all points ('10')
%Outputs:
%   aeronet: struct
%       PI: char
%       email: char
%       variables: cell
%           variables definition for each column in all_points_data.
%       all_points_data: cell
%           each cell contains the whole column of the data file.
%       date_time: array
%           datenum array for each measurement.
%       **product type relevant variables
%References:
%   1. https://aeronet.gsfc.nasa.gov/print_web_data_help_v3_inv.html
%History:
%   2020-07-24. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'filename', @ischar);
addParameter(p, 'invType', 'SIZ', @ischar);
addParameter(p, 'productType', 'ALM15', @ischar);
addParameter(p, 'AVG', '10', @ischar);

parse(p, filename, varargin{:});

%% Parameter initialization
aeronet = struct();

%% read data
fid = fopen(filename, 'r');

switch [p.Results.invType, '+', p.Results.productType]

case {'ALM15+SIZ'} % size distribution

    fgetl(fid);
    fgetl(fid);
    fgetl(fid);

    % version and level
    thisLine = fgetl(fid);
    data = regexp(thisLine, 'Version (?<version>\d): Almucantar Level (?<level>.{3}) Inversion', 'names');
    
    if ~ strcmpi(data.version, '3')
        error('MATLAB:read_AERONET_v3_INV:WrongFile', 'Input AERONET product is not version 3');
    end
    
    fgetl(fid);

    % PI and PI email
    thisLine = fgetl(fid);
    data = regexp(thisLine, '\w*Contact: PI=(?<PI>.*); PI Email=(?<email>.*)', 'names');
    aeronet.PI = data.PI;
    aeronet.email = data.email;

    % variable name 
    thisLine = fgetl(fid);
    data = textscan(thisLine, '%s', 'delimiter', ',');
    aeronet.variables = data{:};

    % parsing data
    data = textscan(fid, '%s %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %s %f %f %f %f %s %s', 'delimiter', ',', 'TreatAsEmpty', 'N/A');

    aeronet.all_points_data = data;
    aeronet.date_time = [];
    for iDatetime = 1:length(data{1})
        aeronet.date_time = cat(2, aeronet.date_time, datenum([data{2}{iDatetime}, data{3}{iDatetime}], 'dd:mm:yyyyHH:MM:SS'));
    end

    % get site
    if isempty(data{1})
        warning('No data was read');
        aeronet.site = '';
    else
        aeronet.site = data{1}{1};
    end

    aeronet.size_bin = [0.050000,0.065604,0.086077,0.112939,0.148184,0.194429,0.255105,0.334716,0.439173,0.576227,0.756052,0.991996,1.301571,1.707757,2.240702,2.939966,3.857452,5.061260,6.640745,8.713145,11.432287,15.000000];
    aeronet.Vr = [data{6}, data{7}, data{8}, data{9}, data{10}, data{11}, data{12}, data{13}, data{14}, data{15}, data{16}, data{17}, data{18}, data{19}, data{20}, data{21}, data{22}, data{23}, data{24}, data{25}, data{26}, data{27}];

case {'ALM15+LID'} % size distribution

    fgetl(fid);
    fgetl(fid);
    fgetl(fid);

    % version and level
    thisLine = fgetl(fid);
    data = regexp(thisLine, 'Version (?<version>\d): Almucantar Level (?<level>.{3}) Inversion', 'names');
    
    if ~ strcmpi(data.version, '3')
        error('MATLAB:read_AERONET_v3_INV:WrongFile', 'Input AERONET product is not version 3');
    end
    
    fgetl(fid);

    % PI and PI email
    thisLine = fgetl(fid);
    data = regexp(thisLine, '\w*Contact: PI=(?<PI>.*); PI Email=(?<email>.*)', 'names');
    aeronet.PI = data.PI;
    aeronet.email = data.email;

    % variable name 
    thisLine = fgetl(fid);
    data = textscan(thisLine, '%s', 'delimiter', ',');
    aeronet.variables = data{:};

    % parsing data
    data = textscan(fid, '%s %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %s', 'delimiter', ',', 'TreatAsEmpty', 'N/A');

    aeronet.all_points_data = data;
    aeronet.date_time = [];
    for iDatetime = 1:length(data{1})
        aeronet.date_time = cat(2, aeronet.date_time, datenum([data{2}{iDatetime}, data{3}{iDatetime}], 'dd:mm:yyyyHH:MM:SS'));
    end

    % get site
    if isempty(data{1})
        warning('No data was read');
        aeronet.site = '';
    else
        aeronet.site = data{1}{1};
    end

    aeronet.lidar_ratio_440 = data{6};
    aeronet.lidar_ratio_675 = data{7};
    aeronet.lidar_ratio_870 = data{8};
    aeronet.lidar_ratio_1020 = data{9};
    aeronet.depolarization_ratio_440 = data{10};
    aeronet.depolarization_ratio_675 = data{11};
    aeronet.depolarization_ratio_870 = data{12};
    aeronet.depolarization_ratio_1020 = data{13};

otherwise

    error('MATLAB:read_AERONET_web:UnknownDataType', 'Unknown data type');

end