NUM_SAMPLES = 1000;

% matlab generated fmap:
fmap_m = fopen('Outputs/cnn_inferred_labels.txt','r');
A = fscanf(fmap_m,'%x');

% verilog generated fmap:
fmap_v = fopen('Outputs/sample.txt','r');
B = fscanf(fmap_v,'%x');

error = 0;
count = 0;
for ii = 1:NUM_SAMPLES
    if A(ii) ~= B(ii)
        fprintf('Wrong data at %d. Matlab data: %d. Verilog data: %d. \n', ii, A(ii), B(ii));
        error = error + 1; 
    else
        count = count + 1;
    end
end

disp 'number of successes:'
fprintf('%d', count);