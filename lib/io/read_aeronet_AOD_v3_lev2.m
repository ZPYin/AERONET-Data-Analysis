function [aeronet] = read_aeronet_AOD_v3_lev2(file)
%read_aeronet_AOD_v3_lev2 read aeronet AOD products.
%Example:
%   [aeronet] = read_aeronet_AOD_v3_lev2(file)
%Inputs:
%   file: char
%       fullpath for data file.
%Outputs:
%   aeronet: struct
%       site: char
%       PI: char
%       email: char
%       variables: cell
%           variables definition for each column in all_points_data.
%       all_points_data: cell
%           each cell contains the whole column of the data file.
%       date_time: array
%           datenum array for each measurement.
%       AOD_{wavelength}: array
%           AOD at each wavelength.
%       AE_{wavelength1}_{wavelength2}: array
%           Angstroem Exponent.
%       PWV: array
%           precipitable water vapor. [cm]
%       Solar_Zenith_Angle: array
%           solar zenith angle. This data can be used to filter some unqualified points.
%       Sensor_Temperature: array
%           sensor temperature. This data can be used to filter some unqualified points.
%History:
%   2019-02-14. First Edition by Zhenping
%Contact:
%   zhenping@tropos.de

aeronet = struct();

% determine whether the data file exists
if exist(file, 'file') ~= 2
    warning('AERONET data file does not exist!\n%s', file);
    return;
end

fid = fopen(file, 'r');

fgetl(fid);

% site
thisLine =  fgetl(fid);
aeronet.site = thisLine;

% version and level
thisLine = fgetl(fid);
data = regexp(thisLine, 'Version (?<version>\d): AOD Level (?<level>.{3})', 'names');

if strcmpi(data.version, '3') && strcmpi(data.level, '2.0')

    fgetl(fid);

    % PI and PI email
    thisLine = fgetl(fid);
    data = regexp(thisLine, 'Contact: PI=(?<PI>.*); PI Email=(?<email>.*)', 'names');
    aeronet.PI = data.PI;
    aeronet.email = data.email;

    fgetl(fid);
    
    % variable name 
    thisLine = fgetl(fid);
    data = textscan(thisLine, '%s', 'delimiter', ',');
    aeronet.variables = data;

    % AOD data
    data = textscan(fid, '%s %s %d %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %d %s %f %f %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'delimiter', ',');

    aeronet.all_points_data = data;
    aeronet.date_time = [];
    for iDatetime = 1:length(data{1})
        aeronet.date_time = cat(1, aeronet.date_time, datenum([data{1}{iDatetime}, data{2}{iDatetime}], 'dd:mm:yyyyHH:MM:SS'));
    end

    aeronet.AOD_1020 = data{6};
    aeronet.AOD_870 = data{7};
    aeronet.AOD_675 = data{10};
    aeronet.AOD_500 = data{19};
    aeronet.AOD_440 = data{22};
    aeronet.AOD_380 = data{25};
    aeronet.AOD_340 = data{26};
    aeronet.PWV = data{27};
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

    fclose(fid);
else
    warning('Only version 3 and level 2.0 products are compatible.');
    return;
end

end