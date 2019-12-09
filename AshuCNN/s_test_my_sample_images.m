% This script tests one OR many MNIST test digits against the test vector.

s_load_mnist;

MY_CNN = '14BIT_ERR68.mat';
OUTPUT_FILE = 'cnn_inferred_labels.txt';
SENTINEL_MANY_SAMPLES = 0; % set if we test more than one sample.
sample_no = 390; % only applicable if testing 1.
how_many_samples = 1;
BITS = 14;

% Harder parameters
IM_DIM = 30;
NUM_LABELS = 10;

sample1 = zeros(IM_DIM,IM_DIM);
sample1(2:29,2:29) = test_x(:,:,sample_no);
load(MY_CNN);

%%%%%%%%%%%%%%%%%%% NOW, TEST FIRST IMAGE USING CNN %%%%%%%%%%%%%%
if SENTINEL_MANY_SAMPLES == 0
    test_vec = test_y(:,sample_no);
    % test_vec = [1 0 0 0 0 0 0 0 0 0]';
    [err, resulting_cnn] = testcnn(cnn, sample1, test_vec, BITS);
else
    fileID = fopen(strcat('Outputs/', OUTPUT_FILE),'w');
    for qq = 1:how_many_samples
        my_samp = zeros(IM_DIM,IM_DIM);
        my_samp(2:29,2:29) = test_x(:,:,qq);
        for ww = 1:NUM_LABELS
            dingle = zeros(1,NUM_LABELS);
            dingle(ww) = 1;
            dingle = dingle';
            [err, resulting_cnn] = testcnn(cnn, my_samp, dingle, BITS);
            if err == 0
                fprintf(fileID, '%04d\n', ww-1);
                break
            end
        end
    end
end