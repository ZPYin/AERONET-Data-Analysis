function [nr] = conv_vr_2_nr(vr, size_bin)
% CONV_VR_2_NR convert particle volume size distribution to number size distribution.
%
% USAGE:
%    [nr] = conv_vr_2_nr(vr, size_bin)
%
% INPUTS:
%    vr: matrix (time * bins)
%        volume per logarithm of radius (um^3/um^2)
%    size_bin: array (1 * bins)
%        radius per bin. (um)
%
% OUTPUTS:
%    nr: matrix (time * bins)
%        number per logarithm of radius (um^{-2})
%
% HISTORY:
%    2020-05-26: first edition by Zhenping
% .. Authors: - zp.yin@whu.edu.cn

size_bins = repmat(size_bin, size(vr, 1), 1);

nr = 3 ./ (4 .* pi .* size_bins.^3) .* vr;

end