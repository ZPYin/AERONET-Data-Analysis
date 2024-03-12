function [aeronet] = read_aeronet_SDA_v3_lev2(file)
% READ_AERONET_SDA_V3_LEV2 read aeronet SDA products.
%
% USAGE:
%    [aeronet] = read_aeronet_SDA_v3_lev2(file)
%
% INPUTS:
%    file: char
%        fullpath for data file.
% 
% OUTPUTS:
%    aeronet: struct
%        site: char
%        PI: char
%        email: char
%        variables: cell
%            variables definition for each column in all_points_data.
%        all_points_data: cell
%            each cell contains the whole column of the data file.
%        date_time: array
%            datenum array for each measurement.
%        Total_AOD_500: array
%            AOD at 500 nm.
%        Fine_Mode_AOD_500: array
%            Fine mode AOD at 500 nm.
%        Coarse_Mode_AOD_500: array
%            Coarse mode AOD at 500 nm.
%        FMF_500: array
%            Fine mode fraction at 500 nm.
%        RMSE_Fine_Mode_AOD_500: array
%            RMSE of fine mode AOD at 500 nm.
%        RMSE_Coarse_Mode_AOD_500: array
%            RMSE of coarse mode AOD at 500 nm.
%        RMSE_FMF_500: array
%            RMSE of fine mode fraction at 500 nm.
%        Solar_Zenith_Angle: array
%            solar zenith angle. This data can be used to filter some unqualified points.
%
% HISTORY:
%    2019-02-14: first edition by Zhenping
% .. Authors: - zp.yin@whu.edu.cn

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
data = regexp(thisLine, 'Version (?<version>\d): SDA Retrieval Level (?<level>.{3})', 'names');

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

    % SDA data
    data = textscan(fid, '%s%s%d%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%s%d%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f', 'delimiter', ',');

    aeronet.all_points_data = data;
    aeronet.date_time = [];
    for iDatetime = 1:length(data{1})
        aeronet.date_time = cat(1, aeronet.date_time, datenum([data{1}{iDatetime}, data{2}{iDatetime}], 'dd:mm:yyyyHH:MM:SS'));
    end

    aeronet.Total_AOD_500 = data{5};
    aeronet.Fine_Mode_AOD_500 = data{6};
    aeronet.Coarse_Mode_AOD_500 = data{7};
    aeronet.FMF_500 = data{8};
    aeronet.RMSE_Fine_Mode_AOD_500 = data{10};
    aeronet.RMSE_Coarse_Mode_AOD_500 = data{11};
    aeronet.RMSE_FMF_500 = data{12};
    aeronet.Solar_Zenith_Angle = data{17};

    fclose(fid);
else
    warning('Only version 3 and level 2.0 products are compatible.');
    return;
end

end