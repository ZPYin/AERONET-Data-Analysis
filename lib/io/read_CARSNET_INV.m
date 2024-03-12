function [carsnet] = read_CARSNET_INV(file, varargin)
% READ_CARSNET_INV read particle microphysical properties from CARSNET.
%
% USAGE:
%    [carsnet] = read_CARSNET_INV(file)
%
% INPUTS:
%    file: char
%        absolute path of INV file.
%
% OUTPUTS:
%    carsnet: struct
%        time
%        radius
%        PSD
%
% HISTORY:
%    2023-06-15: first edition by Zhenping
% .. Authors: - zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'file', @ischar);
addParameter(p, 'debug', false, @islogical);

parse(p, file, varargin{:});

fid = fopen(file, 'r');

thisLine = fgetl(fid);
carsnet = struct();

% parse radius
tokens = strsplit(thisLine, ',');
radius = [];
for iToken = 52:73
    radius = cat(2, radius, str2double(tokens{iToken}));
end
carsnet.radius = radius;

data = textscan(fid, repmat('%f', 1, 85), 'delimiter', ',');

fclose(fid);


for iLine = 1:length(data{1})
    carsnet.time(iLine) = datenum(data{1}(iLine), data{2}(iLine), data{3}(iLine), data{4}(iLine), data{5}(iLine), data{6}(iLine));
    carsnet.AOD440(iLine) = data{7}(iLine);
    carsnet.AOD675(iLine) = data{8}(iLine);
    carsnet.AOD870(iLine) = data{9}(iLine);
    carsnet.AOD1020(iLine) = data{10}(iLine);
    carsnet.AAOD440(iLine) = data{38}(iLine);
    carsnet.AAOD675(iLine) = data{39}(iLine);
    carsnet.AAOD870(iLine) = data{40}(iLine);
    carsnet.AAOD1020(iLine) = data{41}(iLine);
    carsnet.AAOD550(iLine) = data{42}(iLine);
    carsnet.AE(iLine) = data{43}(iLine);
    carsnet.REAL440(iLine) = data{44}(iLine);
    carsnet.REAL675(iLine) = data{45}(iLine);
    carsnet.REAL870(iLine) = data{46}(iLine);
    carsnet.REAL1020(iLine) = data{47}(iLine);
    carsnet.IMAG440(iLine) = data{48}(iLine);
    carsnet.IMAG675(iLine) = data{49}(iLine);
    carsnet.IMAG870(iLine) = data{50}(iLine);
    carsnet.IMAG1020(iLine) = data{51}(iLine);

    for iEntry = 52:73
        carsnet.PSD(iLine, iEntry - 51) = data{iEntry}(iLine);
    end
end

end