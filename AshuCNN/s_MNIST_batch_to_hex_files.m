% This script generates 2 hex file.
% One of them is many samples of MNIST images.
% The other is a file of labels for those images.

s_load_mnist;

% OUTPUT FILE NAMES
O_IM_NAME = 'mnist_test_digit_set.hex';
O_LABELS_NAME = 'mnist_test_digit_set_labels.txt';

% NUM SAMPLES
SAMPLES = 1000;

% Harder parameters
I_DIM = 30;
NUM_LABELS = 10;

fileID = fopen(strcat('Outputs/', O_IM_NAME),'w');
sample1 = zeros(I_DIM, I_DIM, SAMPLES);
for jjjj = 1:SAMPLES
    sample1(2:29,2:29, jjjj) = test_x(:,:, jjjj);
end
sample1 = sample1 .* 256;

for kk = 1:SAMPLES
    for ii = 1:I_DIM
        for jj = 1:I_DIM
            fprintf(fileID, '%02x\n', sample1(ii,jj,kk));
        end
    end
end

% GET THE TESTING LABELS
fileID2 = fopen(strcat('Outputs/', O_LABELS_NAME),'w');

sample1 = zeros(NUM_LABELS, SAMPLES);

for jjjj = 1:SAMPLES
    sample1(:,jjjj) = test_y(:,jjjj);
end

for kk = 1:SAMPLES
    [M, I] = max(sample1(:,kk));
    fprintf(fileID2, '%d\n', I - 1);
end

fclose(fileID);
fclose(fileID2);