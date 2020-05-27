function [N_par] = calc_parNumber(size_bins, nr, varargin)
%calc_parNumber calculate particle number at the given size range.
%Example:
%   % Usecase 1: total particle number between the given size range 0~2.5 um.
%   [N_par] = calc_parNumber(size_bins, nr, 'size_range', [0, 2.5]);
%   % Usecase 2: total particle number between the given size range with interpolation.
%   [N_par] = calc_parNumber(size_bins, nr, 'interp_size_bin', 0:0.01:12)
%Inputs:
%   size_bin: array (1 * bins)
%       radius per bin. (um)
%   nr: matrix (time * bins)
%       number per logarithm of radius (um^{-2})
%Keywords:
%   size_range: 2-element array
%       integral size range. (micron)
%   interp_size_bin: array
%       interpolated size bins. (micron)
%Outputs:
%   N_par: vector (times * 1)
%       columnar particle number. (um^{-2})
%History:
%   2020-05-26. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

p = inputParser;
p.KeepUnmatched = true;

addRequired(p, 'nr', @isnumeric);
addRequired(p, 'size_bins', @isnumeric);
addParameter(p, 'size_range', [0, 2.5], @isnumeric);
addParameter(p, 'interp_size_bin', [], @isnumeric);

parse(p, size_bins, nr, varargin{:});

if ~ isempty(p.Results.interp_size_bin)

    size_bins_interp = p.Results.interp_size_bin;

    nr_interp = NaN(size(nr, 1), length(p.Results.interp_size_bin));
    for iCol = 1:size(nr, 1)
        nr_interp(iCol, :) = interp1(size_bins, nr(iCol, :), p.Results.interp_size_bin, 'spline');

        % force the number at extrap size bins to be NaN
        flagOutlier = (p.Results.interp_size_bin > size_bins(end)) | (p.Results.interp_size_bin < size_bins(1));
        nr_interp(iCol, flagOutlier) = NaN;
    end

else

    size_bins_interp = size_bins;
    nr_interp = nr;

end

% integral the numbers
flagSizeBins = (size_bins_interp <= p.Results.size_range(2)) & ...
               (size_bins_interp >= p.Results.size_range(1)) & ...
               (~ isnan(size_bins_interp)) & ...
               (isfinite(log(size_bins_interp))) & ...
               (size_bins_interp >= size_bins(1)) & ...
               (size_bins_interp <= size_bins(end));
N_par = trapz(log(size_bins_interp(flagSizeBins)), nr_interp(:, flagSizeBins), 2);

end