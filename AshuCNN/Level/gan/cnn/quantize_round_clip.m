function out = quantize_round_clip(in,range)
out = round(in);
out = bound(out, -range, range);


function y = bound(x, bl, bu)
% return bounded value clipped between bl and bu
y = min(max(x,bl),bu);