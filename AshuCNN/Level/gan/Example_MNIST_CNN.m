%==========================================================================
% Version:
% Created By:   Sihua Fu, Qiankai Cao, Zhengyu Chen
% Created on:   03/16/19
% Modified on:  03/19/19
% *************************************************************************
% Current   1.
% Reuslt:
% *************************************************************************
% Remaining 1.
% Issues:
% *************************************************************************
%  Note:    1.Download MNIST dataset from http://yann.lecun.com/exdb/mnist/
%           2. Store in a folder /directory named MNIST
% *************************************************************************
clear all
%maxNumCompThreads(10)
%==========================================================================
% Parameters
global bit_scale;
dataPath                = './MNIST/';
batch_size              = 50;
n_shrinkData_train      = 10;
n_shrinkData_test       = 10;
n_epoch                 = 1;
input_enlarge           = 8; % Increase value of input(image)
bit_scale               = 10;           % (bit_scale-2) of integer bit
learning_rate           = 0.01 * 2^bit_scale;  % 0.01
erMult                  = 5;

%==========================================================================
display 'start....'
display 'reading MNIST dataset...'
% *************************************************************************
% Read train image
f = fopen(fullfile(dataPath, 'train-images.idx3-ubyte'),'r', 'b') ;
if f < 0
    error('please load MNIST dataset, store it in a folder and check the path and name of the file');
end
fread(f,1,'int32');
num = fread(f,1,'int32');
h = fread(f,1,'int32');
w = fread(f,1,'int32');
train_img = uint8(fread(f,h*w*num,'uchar')); %load train images
train_img = permute(reshape(train_img, h, w,num), [2 1 3]);
train_img = double(train_img)./255;
train_img = train_img(:,:,1:60000/n_shrinkData_train);
fclose(f) ;
% *************************************************************************
% Read train label
f = fopen(fullfile(dataPath, 'train-labels.idx1-ubyte'),'r', 'b') ;
fread(f,1,'int32');
num = fread(f,1,'int32');
y = double(fread(f,num,'uint8'));   %load train labels
y = (y)'; 
train_label = zeros([10 num]); % there are 10 labels in MNIST lables
for i = 0:9 % labels are 0 - 9
    k = find(y == i);
    train_label(i+1,k) = 1;
end
train_label = train_label(:,1:60000/n_shrinkData_train);
fclose(f) ;
% *************************************************************************
% Read test image
f = fopen(fullfile(dataPath, 't10k-images.idx3-ubyte'),'r', 'b');
fread(f,1,'int32');
num = fread(f,1,'int32');
h = fread(f,1,'int32');
w = fread(f,1,'int32');
test_img = uint8(fread(f,h*w*num,'uchar')); %load test images
test_img = permute(reshape(test_img, h, w,num), [2 1 3]);
test_img = double(test_img)./255;
test_img = test_img(:,:,1:10000/n_shrinkData_test);
fclose(f);
% *************************************************************************
% Read test label
f = fopen(fullfile(dataPath, 't10k-labels.idx1-ubyte'),'r', 'b') ;
fread(f,1,'int32');
num = fread(f,1,'int32');
y = double(fread(f,num,'uint8')); %load test labels
y = (y)' ;
test_label = zeros([10 num]); % there are 10 labels in MNIST lables
for i=0:9 % labels are 0 - 9
    k = find(y == i);
    test_label(i+1,k) = 1;
end
test_label = test_label(:,1:10000/n_shrinkData_test);
fclose(f);
%==========================================================================
% Quantize input
%==========================================================================
train_img   = round(train_img);
test_img    = round(test_img);
train_img   = train_img*input_enlarge;
test_img    = test_img*input_enlarge;


%==========================================================================
% Main Function
%***************************************
% initialize cnn
cnn.namaste = 1; % just intiationg cnn object
cnn = initcnn(cnn,[h w],learning_rate);
%cnn.loss_func = 'cros';
%cnn.loss_func = 'quad';

% Build CNN Architecture
cnn = cnnAddConvLayer(cnn, 40, [5 5], 'rect');
cnn = cnnAddPoolLayer(cnn, 2, 'mean');
cnn = cnnAddConvLayer(cnn, 40, [5 5], 'rect');
cnn = cnnAddPoolLayer(cnn, 2, 'mean');
cnn = cnnAddFCLayer(cnn,32, 'rect'); % Add fully connected layer
cnn = cnnAddFCLayer(cnn,10, 'sigm'); % Add fully connected layer % last layer no of nodes = no of lables

display 'training started...Wait for ~200 seconds...'
tic
cnn = traincnn(cnn, train_img, train_label, n_epoch, batch_size,'round', erMult);
toc
display '...training finished.'
display 'testing started....'
tic
err = testcnn(cnn, test_img, test_label,'round');
toc
display '... testing finished. To get minimum error, increase no of epochs while training.'
% imshow(train_img(:,:,1))
