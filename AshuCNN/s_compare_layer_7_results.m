NUM_SAMPLES = 46;

% matlab generated fmap:
fmap_m = fopen('Outputs/fmap_layer_matlab.txt','r');
A = fscanf(fmap_m,'%x');

% verilog generated fmap:
fmap_v = fopen('Outputs/sample.txt','r');
B = fscanf(fmap_v,'%x');

error = 0;
for ii = 1:NUM_SAMPLES
    if A(ii) ~= B(ii)
        fprintf('Wrong data at %d. Matlab data: %d. Verilog data: %d. \n', ii, A(ii), B(ii));
        error = error + 1; 
    end
end