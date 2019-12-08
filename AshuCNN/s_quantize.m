function out=s_quantize(z,N)

% QUANTIZE quantizes z to N bits.

z_temp = floor(z .* (2^N));
z_temp = z_temp ./ (2^N);
out = z_temp;
        
        
    