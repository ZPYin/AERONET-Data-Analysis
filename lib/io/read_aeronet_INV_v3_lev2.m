function [aeronet] = read_aeronet_INV_v3_lev2(file)
%read_aeronet_INV_v3_lev2 read aeronet INV products.
%Example:
%   [aeronet] = read_aeronet_INV_v3_lev2(file)
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
%       AOD_Ext_Tot_440
%       AOD_Ext_Tot_675
%       AOD_Ext_Tot_870
%       AOD_Ext_Tot_1020
%       AOD_Ext_Fine_440
%       AOD_Ext_Fine_675
%       AOD_Ext_Fine_870
%       AOD_Ext_Fine_1020
%       AOD_Ext_Coarse_440
%       AOD_Ext_Coarse_675
%       AOD_Ext_Coarse_870
%       AOD_Ext_Coarse_1020
%       SSA_440
%       SSA_675
%       SSA_870
%       SSA_1020
%       AAOD_440
%       AAOD_675
%       AAOD_870
%       AAOD_1020
%       RefI_Real_440
%       RefI_Real_675
%       RefI_Real_870
%       RefI_Real_1020
%       RefI_Imag_440
%       RefI_Imag_675
%       RefI_Imag_870
%       RefI_Imag_1020
%       Sphericity_Factor
%       size_x
%       size_dist
%       LR_440
%       LR_675
%       LR_870
%       LR_1020
%       DepRatio_440
%       DepRatio_675
%       DepRatio_870
%       DepRatio_1020
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
data = regexp(thisLine, 'Version (?<version>\d): Almucantar Level (?<level>.{3}) Inversion', 'names');

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

    % INV data
    data = textscan(fid, '%s%s%s%d%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%s%f%f%f%f%s%s', 'delimiter', ',');

    aeronet.all_points_data = data;
    aeronet.date_time = [];
    for iDatetime = 1:length(data{1})
        aeronet.date_time = cat(1, aeronet.date_time, datenum([data{2}{iDatetime}, data{3}{iDatetime}], 'dd:mm:yyyyHH:MM:SS'));
    end

    aeronet.AOD_440 = data{6};
    aeronet.AOD_675 = data{7};
    aeronet.AOD_870 = data{8};
    aeronet.AOD_1020 = data{9};
    aeronet.AE_440_870 = data{10};
    aeronet.AOD_Ext_Tot_440 = data{11};
    aeronet.AOD_Ext_Tot_675 = data{12};
    aeronet.AOD_Ext_Tot_870 = data{13};
    aeronet.AOD_Ext_Tot_1020 = data{14};
    aeronet.AOD_Ext_Fine_440 = data{15};
    aeronet.AOD_Ext_Fine_675 = data{16};
    aeronet.AOD_Ext_Fine_870 = data{17};
    aeronet.AOD_Ext_Fine_1020 = data{18};
    aeronet.AOD_Ext_Coarse_440 = data{19};
    aeronet.AOD_Ext_Coarse_675 = data{20};
    aeronet.AOD_Ext_Coarse_870 = data{21};
    aeronet.AOD_Ext_Coarse_1020 = data{22};
    aeronet.SSA_440 = data{24};
    aeronet.SSA_675 = data{25};
    aeronet.SSA_870 = data{26};
    aeronet.SSA_1020 = data{27};
    aeronet.AAOD_440 = data{28};
    aeronet.AAOD_675 = data{29};
    aeronet.AAOD_870 = data{30};
    aeronet.AAOD_1020 = data{31};
    aeronet.RefI_Real_440 = data{33};
    aeronet.RefI_Real_675 = data{34};
    aeronet.RefI_Real_870 = data{35};
    aeronet.RefI_Real_1020 = data{36};
    aeronet.RefI_Imag_440 = data{37};
    aeronet.RefI_Imag_675 = data{38};
    aeronet.RefI_Imag_870 = data{39};
    aeronet.RefI_Imag_1020 = data{40};
    aeronet.Sphericity_Factor = data{53};
    aeronet.size_x = [0.050000,0.065604,0.086077,0.112939,0.148184,0.194429,0.255105,0.334716,0.439173,0.576227,0.756052,0.991996,1.301571,1.707757,2.240702,2.939966,3.857452,5.061260,6.640745,8.713145,11.432287,15.000000];
    aeronet.size_dist = [data{54}, data{55}, data{56}, data{57}, data{58}, data{59}, data{60}, data{61}, data{62}, data{63}, data{64}, data{65}, data{66}, data{67}, data{68}, data{69}, data{70}, data{71}, data{72}, data{73}, data{74}, data{75}];
    aeronet.LR_440 = data{113};
    aeronet.LR_675 = data{114};
    aeronet.LR_870 = data{115};
    aeronet.LR_1020 = data{116};
    aeronet.DepRatio_440 = data{117};
    aeronet.DepRatio_675 = data{118};
    aeronet.DepRatio_870 = data{119};
    aeronet.DepRatio_1020 = data{120};

    fclose(fid);
else
    warning('Only version 3 and level 2.0 products are compatible.');
    return;
end

end