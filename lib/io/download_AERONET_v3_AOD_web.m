function status = download_AERONET_v3_AOD_web(site, filename, varargin)
% DOWNLOAD_AERONET_V3_AOD_WEB download AERONET version 3 AOD/SDA products.
%
% USAGE:
%    status = download_AERONET_v3_AOD_web(site, filename)
%
% INPUTS:
%    site: char
%        AERONET site label.
%    filename: char
%        full path of the file to be exported to.
% 
% KEYWORDS:
%    starttime: numeric
%        timestamp of the start time of the product in MATLAB datenum (default: datenum(2019, 1, 1)).
%    stoptime: numeric
%        timestamp of the stop time of the product in MATLAB datenum (default: datenum(2019, 2, 1)).
%    productType (default: 'AOD15'): char
%        product type
%        AOD10   Aerosol Optical Depth Level 1.0
%        AOD15   Aerosol Optical Depth Level 1.5
%        AOD20   Aerosol Optical Depth Level 2.0
%        SDA10   SDA Retrieval Level 1.0
%        SDA15   SDA Retrieval Level 1.5
%        SDA20   SDA Retrieval Level 2.0
%        TOT10   Total Optical Depth based on AOD Level 1.0 (all points only)
%        TOT15   Total Optical Depth based on AOD Level 1.5 (all points only)
%        TOT20   Total Optical Depth based on AOD Level 2.0 (all points only)
%    AVG: char
%        daily averaged product ('20') or all points ('10')
% 
% OUTPUTS:
%    status: logical
%        flag to show whether the download process finish successfully.
% 
% EXAMPLE:
%    % USECASE 1: download level 1.5 AOD data
%    download_AERONET_v3_AOD_web('Punta_Arenas_UMAG', 'test.txt', 'productType', 'AOD15');
%    % USECASE 2: download AOD data at given temporal range
%    download_AERONET_v3_AOD_web('Punta_Arenas_UMAG', 'test.txt', 'starttime', datenum(2019, 1, 1), 'stoptime', datenum(2019, 12, 1), 'productType', 'AOD15');
%
% REFERENCES:
%    1. https://aeronet.gsfc.nasa.gov/print_web_data_help_v3.html
%
% HISTORY:
%    2020-07-24: first edition by Zhenping
% .. Authors: - zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'site', @ischar);
addRequired(p, 'filename', @ischar);
addParameter(p, 'starttime', datenum(2019, 1, 1), @isnumeric);
addParameter(p, 'stoptime', datenum(2019, 2, 1), @isnumeric);
addParameter(p, 'productType', 'AOD15', @ischar);
addParameter(p, 'AVG', '10', @ischar);

parse(p, site, filename, varargin{:});

%% Parameter initialization
status = false;

%% read data
starttimeNum = datevec(p.Results.starttime);
stoptimeNum = datevec(p.Results.stoptime);
AERONET_URL = sprintf('https://aeronet.gsfc.nasa.gov/cgi-bin/print_web_data_v3?site=%s&year=%4d&month=%d&day=%d&year2=%4d&month2=%d&day2=%d&%s=1&AVG=%s&if_no_html=1', ...
                      site, ...
                      starttimeNum(1), starttimeNum(2), starttimeNum(3), ...
                      stoptimeNum(1), stoptimeNum(2), stoptimeNum(3), ...
                      p.Results.productType, p.Results.AVG);

% call the system command 'wget' to download the html text
if ispc
    [status, ~] = system(sprintf('wget --no-check-certificate -q -O %s "%s"', filename, AERONET_URL));
    if status ~= 0
        warning(['Error in calling wget in window cmd. Please make sure ' ...
                 'wget is available and it is in the searching path of ' ...
                 'window. \nOtherwise, you need to download the suitable ' ...
                 'version online and add the path to the environment ' ...
                 'variables manually.\n You can go to ' ...
                 'https://de.mathworks.com/matlabcentral/answers/' ...
                 '94933-how-do-i-edit-my-system-path-in-windows ' ...
                 'for detailed information']);
        return;
    end
elseif isunix
    % add search path of 'wget' to matlab environment
    path1 = getenv('PATH');
    path1 = [path1 ':/usr/local/bin'];
    setenv('PATH', path1);
    [status, ~] = system(sprintf('wget --no-check-certificate -q -O %s "%s"', filename, AERONET_URL));
end

%% parsing the data from HTML strings
if status == 0
    status = true;
else
    warning('MATLAB:download_AERONET_v3_AOD_web:InvalidURL', 'Invalid URL');
    status = false;
end

end