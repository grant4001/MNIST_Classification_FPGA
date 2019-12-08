function out = quantize_level_clip(in, n_bit, range)
out = round(in*2^n_bit)/2^n_bit;
out = bound(out, -range, range);


function y = bound(x, bl, bu)
% return bounded value clipped between bl and bu
y = min(max(x,bl),bu);