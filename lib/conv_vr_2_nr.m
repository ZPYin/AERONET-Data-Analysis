function [nr] = conv_vr_2_nr(vr, size_bin)
%conv_vr_2_nr convert particle volume size distribution to number size distribution.
%Example:
%   [nr] = conv_vr_2_nr(vr, size_bin)
%Inputs:
%   vr: matrix (time * bins)
%       volume per logarithm of radius (um^3/um^2)
%   size_bin: array (1 * bins)
%       radius per bin. (um)
%Outputs:
%   nr: matrix (time * bins)
%       number per logarithm of radius (um^{-2})
%History:
%   2020-05-26. First Edition by Zhenping
%Contact:
%   zp.yin@whu.edu.cn

size_bins = repmat(size_bin, size(vr, 1), 1);

nr = 3 ./ (4 .* pi .* size_bins.^3) .* vr;

end