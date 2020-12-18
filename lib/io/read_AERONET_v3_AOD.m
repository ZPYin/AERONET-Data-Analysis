function aeronet = read_AERONET_v3_AOD(filename, varargin)
%READ_AERONET_V3_AOD read AERONET version 3 AOD/SDA products.
%Example:
%   % Usecase 1: read AOD data
%   [aeronet] = read_AERONET_v3_AOD(filename, 'productType', 'AOD15');
%Inputs:
%   filename: char
%       absolute path of AERONET INV product file.
%Keywords:
%   productType (default: 'AOD15'): char
%       product type
%       AOD10   Aerosol Optical Depth Level 1.0
%       AOD15   Aerosol Optical Depth Level 1.5
%       AOD20   Aerosol Optical Depth Level 2.0
%       SDA10   SDA Retrieval Level 1.0
%       SDA15   SDA Retrieval Level 1.5
%       SDA20   SDA Retrieval Level 2.0
%       TOT10   Total Optical Depth based on AOD Level 1.0 (all points only)
%       TOT15   Total Optical Depth based on AOD Level 1.5 (all points only)
%       TOT20   Total Optical Depth based on AOD Level 2.0 (all points only)
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
%References:
%   1. https://aeronet.gsfc.nasa.gov/print_web_data_help_v3.html
%History:
%   2020-07-24. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'filename', @ischar);
addParameter(p, 'productType', 'AOD15', @ischar);
addParameter(p, 'AVG', '10', @ischar);

parse(p, filename, varargin{:});

%% Parameter initialization
aeronet = struct();

%% read data
fid = fopen(filename, 'r');

switch p.Results.productType

case {'AOD15', 'AOD20'}   % Level 1.5 and 2.0 AOD

    fgetl(fid);
    fgetl(fid);

    thisLine = fgetl(fid);
    data = regexp(thisLine, 'Version (?<version>\d): AOD Level (?<level>.{3})', 'names');

    if ~ strcmpi(data.version, '3')
        error('MATLAB:read_AERONET_v3_AOD:WrongFile', 'Input AERONET product is not version 3');
    end

    fgetl(fid);

    thisLine = fgetl(fid);
    data = regexp(thisLine, 'Contact: PI=(?<PI>.*); PI Email=(?<email>.*)', 'names');
    aeronet.PI = data.PI;
    aeronet.email = data.email;

    % variable name
    thisLine = fgetl(fid);
    data = textscan(thisLine, '%s', 'delimiter', ',');
    aeronet.variables = data{:};

    % parsing data
    data = textscan(fid, '%s %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %f %s %f %f %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'delimiter', ',', 'TreatAsEmpty', 'N/A');

    aeronet.all_points_data = data;
    aeronet.date_time = [];
    for iDatetime = 1:length(data{1})
        aeronet.date_time = cat(2, aeronet.date_time, datenum([data{2}{iDatetime}, data{3}{iDatetime}], 'dd:mm:yyyyHH:MM:SS'));
    end

    aeronet.AOD_1020 = data{7};
    aeronet.AOD_870 = data{8};
    aeronet.AOD_675 = data{11};
    aeronet.AOD_532 = data{17};
    aeronet.AOD_500 = data{20};
    aeronet.AOD_440 = data{23};
    aeronet.AOD_380 = data{26};
    aeronet.AOD_340 = data{27};
    aeronet.PWV = data{28};
    aeronet.latitude = data{end - 39};
    aeronet.longtitude = data{end - 38};
    aeronet.elevation = data{end - 37};
    aeronet.Solar_Zenith_Angle = data{end - 36};
    aeronet.Sensor_Temperature = data{end - 34};
    aeronet.Ozone = data{end - 33};
    aeronet.NO2 = data{end - 32};
    aeronet.AE_440_675 = data{end - 43};
    aeronet.AE_340_440 = data{end - 44};
    aeronet.AE_500_870 = data{end - 45};
    aeronet.AE_440_675 = data{end - 46};
    aeronet.AE_380_500 = data{end - 47};
    aeronet.AE_440_870 = data{end - 48};

case {'SDA15'}

    fgetl(fid);
    fgetl(fid);

    % version and level
    thisLine = fgetl(fid);
    data = regexp(thisLine, '\w*Version (?<version>\d): SDA Retrieval Level (?<level>.{3})', 'names');

    if ~ strcmpi(data.version, '3')
        error('MATLAB:read_AERONET_v3_AOD:WrongFile', 'Input AERONET product is not version 3');
    end

    fgetl(fid);

    % PI and PI email
    thisLine = fgetl(fid);
    data = regexp(thisLine, 'Contact: PI=(?<PI>.*); PI Email=(?<email>.*)', 'names');
    aeronet.PI = data.PI;
    aeronet.email = data.email;

    % variable name 
    thisLine = fgetl(fid);
    data = textscan(thisLine, '%s', 'delimiter', ',');
    aeronet.variables = data{:};

    % SDA data
    data = textscan(fid, '%s %s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %s %f %s %f %f %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'delimiter', ',');

    aeronet.all_points_data = data;
    aeronet.date_time = [];
    for iDatetime = 1:length(data{1})
        aeronet.date_time = cat(2, aeronet.date_time, datenum([data{2}{iDatetime}, data{3}{iDatetime}], 'dd:mm:yyyyHH:MM:SS'));
    end

    aeronet.Total_AOD_500 = data{6};
    aeronet.Fine_Mode_AOD_500 = data{7};
    aeronet.Coarse_Mode_AOD_500 = data{8};
    aeronet.FMF_500 = data{9};
    aeronet.RMSE_Fine_Mode_AOD_500 = data{11};
    aeronet.RMSE_Coarse_Mode_AOD_500 = data{12};
    aeronet.RMSE_FMF_500 = data{13};
    aeronet.Solar_Zenith_Angle = data{18};

otherwise

    error('MATLAB:read_AERONET_v3_AOD:UnknownDataType', 'Unknown data type');

end

fclose(fid);

end