function out=s_twos_complement(input)

% x is a char array.

x = input;
my_length = length(x);

% flip all the bits
for j = 1:my_length
    if x(j) == '0'
        x(j) = '1';
    elseif x(j) == '1'
        x(j) = '0';
    end
end

% add 1
 for k = my_length:-1:1
     if x(k) == '0'
         x(k) = '1';
         break
     else
         x(k) = '0';
     end
 end

out = x;
        
        
    