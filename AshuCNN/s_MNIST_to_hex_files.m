% This script writes an individual MNIST image to a hex file. 
% The sample number from the set of testing images must be selected.

s_load_mnist;

OUTPUT_NAME = 'mnist_test_digit.hex';
sample_no = 1;
IM_DIM = 30;

fileID = fopen(strcat('Outputs/', OUTPUT_NAME),'w');
sample1 = zeros(IM_DIM,IM_DIM);
sample1(2:29,2:29) = test_x(:,:, sample_no);
sample1 = sample1 .* 256;

for ii = 1:IM_DIM
    for jj = 1:IM_DIM
        fprintf(fileID, '%02x\n', sample1(ii,jj));
    end
end


fclose(fileID);