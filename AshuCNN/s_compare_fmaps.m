% This script compares the Matlab generated fmap with the Verilog
% generated fmap.
LAYER_NO = 4;
FMAP_DIM = 12;
NUM_FMAPS = 32;
MATLAB_GEN = 'fmap_layer_matlab.txt';
HDL_GEN = 'sample.txt';

% matlab generated fmap:
fmap_m = fopen(strcat('Outputs/', MATLAB_GEN),'r');
A = fscanf(fmap_m,'%x');

% verilog generated fmap:
fmap_v = fopen(strcat('Outputs/', HDL_GEN),'r');
B = fscanf(fmap_v,'%x');

error = 0;
for ii = 1:(FMAP_DIM^2)*NUM_FMAPS
    matlab_data = A(ii);
    verilog_data = B(ii);
    if A(ii) ~= B(ii)
        fprintf('Wrong data at %d. Matlab data: %d. Verilog data: %d. Error: %d. \n', ii, A(ii), B(ii), A(ii) - B(ii));
        error = error + 1; 
    end
end
fprintf('\nError count: %d\n',error);
C = zeros((FMAP_DIM^2)*NUM_FMAPS,1);
if (error ~= 0)
    for aaa = 1:(FMAP_DIM^2)*NUM_FMAPS
        C(aaa) = B(aaa) - A(aaa);
    end
end
fprintf('Max error: %d', max(C));