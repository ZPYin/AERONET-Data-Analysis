function [N_par] = calc_parVolume(size_bins, vr, varargin)
% CALC_PARVOLUME calculate particle volume at the given size range.
%
% USAGE:
%    [N_par] = calc_parVolume(size_bins, vr)
%
% INPUTS:
%    size_bin: array (1 * bins)
%        radius per bin. (um)
%    vr: matrix (time * bins)
%        volume per logarithm of radius (um^3/um^2)
% 
% KEYWORDS:
%    size_range: 2-element array
%        integral size range. (micron)
%    interp_size_bin: array
%        interpolated size bins. (micron)
% 
% OUTPUTS:
%    N_par: vector (times * 1)
%        columnar particle volume. (um)
% 
% EXAMPLE:
%    % Usecase 1: total particle volume between the given size range 0~2.5 um.
%    [N_par] = calc_parVolume(size_bins, vr, 'size_range', [0, 2.5]);
% 
%    % Usecase 2: total particle volume between the given size range with interpolation.
%    [N_par] = calc_parVolume(size_bins, vr, 'interp_size_bin', 0:0.01:12)
%
% HISTORY:
%    2020-05-26: first edition by Zhenping
% .. Authors: - zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'vr', @isnumeric);
addRequired(p, 'size_bins', @isnumeric);
addParameter(p, 'size_range', [0, 2.5], @isnumeric);
addParameter(p, 'interp_size_bin', [], @isnumeric);

parse(p, size_bins, vr, varargin{:});

if ~ isempty(p.Results.interp_size_bin)

    size_bins_interp = p.Results.interp_size_bin;

    vr_interp = NaN(size(vr, 1), length(p.Results.interp_size_bin));
    for iCol = 1:size(vr, 1)
        vr_interp(iCol, :) = interp1(size_bins, vr(iCol, :), p.Results.interp_size_bin, 'spline');

        % force the volume at extrap size bins to be NaN
        flagOutlier = (p.Results.interp_size_bin > size_bins(end)) | (p.Results.interp_size_bin < size_bins(1));
        vr_interp(iCol, flagOutlier) = NaN;
    end

else

    size_bins_interp = size_bins;
    vr_interp = vr;

end

% integral the volumes
flagSizeBins = (size_bins_interp <= p.Results.size_range(2)) & ...
               (size_bins_interp >= p.Results.size_range(1)) & ...
               (~ isnan(size_bins_interp)) & ...
               (isfinite(log(size_bins_interp))) & ...
               (size_bins_interp >= size_bins(1)) & ...
               (size_bins_interp <= size_bins(end));
N_par = trapz(size_bins_interp(flagSizeBins), vr_interp(:, flagSizeBins), 2);

end