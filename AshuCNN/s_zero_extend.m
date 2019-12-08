function out = s_zero_extend(my_binary, WORD_BITS)

% S_ZERO_EXTEND zero extends MY_BINARY to WORD_BITS # of bits.

resulting_binary = '';
for j = 1:WORD_BITS 
    resulting_binary = strcat(resulting_binary, '0');
end
for o = WORD_BITS+1-length(my_binary):1:WORD_BITS
    resulting_binary(o) = my_binary(o - WORD_BITS + length(my_binary));
end

out = resulting_binary;