function status = download_AERONET_v3_INV_web(site, filename, varargin)
% DOWNLOAD_AERONET_V3_INV_WEB download AERONET version 3 INV products.
%
% USAGE:
%    status = download_AERONET_v3_INV_web(site, filename)
%
% INPUTS:
%    site: char
%        AERONET site label.
%    filename: char
%        full path of the file to be exported to.
% 
% KEYWORDS:
%    starttime: numeric
%        timestamp of the start time of the product in MATLAB datenum.
%    stoptime: numeric
%        timestamp of the stop time of the product in MATLAB datenum.
%    invType (default: 'ALM15'): char
%        scanning type (default: ALM15).
%        ALM15   Level 1.5 Almucantar Retrievals
%        ALM20   Level 2.0 Almucantar Retrievals
%        HYB15   Level 1.5 Hybrid Retrievals
%        HYB20   Level 2.0 Hybrid Retrievals
%    productType (default: 'SIZ'): char
%        product type
%        SIZ Size distribution
%        RIN Refractive indicies (real and imaginary)
%        CAD Coincident AOT data with almucantar retrieval
%        VOL Volume concentration, volume mean radius, effective radius and standard deviation
%        TAB AOT absorption
%        AOD AOT extinction
%        SSA Single scattering albedo
%        ASY Asymmetry factor
%        FRC Radiative Forcing
%        LID Lidar and Depolarization Ratios
%        FLX Spectral flux
%        ALL All of the above retrievals (SIZ to FLUX) in one file
%        PFN*    Phase function (available for only all points data format: AVG=10)
%        U27 Estimation of Sensitivity to 27 Input Uncertainty Variations 
%            (available for only all points data format: AVG=10 and ALM20 and HYB20)
%    AVG: char
%        daily averaged product ('20') or all points ('10')
% 
% OUTPUTS:
%    status: logical
%        flag to show whether the download process finished successfully.
%     output
% 
% EXAMPLE:
%    % Usecase 1: download level 1.5 INV data
%    download_AERONET_v3_INV_web('Punta_Arenas_UMAG', 'test.txt', ...
%        'productType', 'SIZ', 'invType', 'ALM15');
%    % Usecase 2: download INV data at given temporal range
%    download_AERONET_v3_INV_web('Punta_Arenas_UMAG', 'test.txt', ...
%        'starttime', datenum(2019, 1, 1), 'stoptime', datenum(2019, 12, 1), ...
%        'productType', 'SIZ', 'invType', 'ALM15');
%
%REFERENCES:
%   1. https://aeronet.gsfc.nasa.gov/print_web_data_help_v3_inv.html
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
addParameter(p, 'invType', 'SIZ', @ischar);
addParameter(p, 'productType', 'ALM15', @ischar);
addParameter(p, 'AVG', '10', @ischar);

parse(p, site, filename, varargin{:});

%% Parameter initialization
status = false;

%% read data
starttimeNum = datevec(p.Results.starttime);
stoptimeNum = datevec(p.Results.stoptime);
AERONET_URL = sprintf('https://aeronet.gsfc.nasa.gov/cgi-bin/print_web_data_inv_v3?site=%s&year=%4d&month=%d&day=%d&year2=%4d&month2=%d&day2=%d&product=%s&AVG=%s&%s=1&if_no_html=1', ...
                      site, ...
                      starttimeNum(1), starttimeNum(2), starttimeNum(3), ...
                      stoptimeNum(1), stoptimeNum(2), stoptimeNum(3), ...
                      p.Results.productType, p.Results.AVG, p.Results.invType);

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
    warning('MATLAB:download_AERONET_v3_INV_web:InvalidURL', 'Invalid URL');
    status = false;
end

end