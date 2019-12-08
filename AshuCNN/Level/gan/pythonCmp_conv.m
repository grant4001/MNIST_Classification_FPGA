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
batch_size              = 4;
n_shrinkData_train      = 1;
n_shrinkData_test       = 1;
n_epoch                 = 2;
input_enlarge           = 8; % Increase value of input(image)
bit_scale               = 0;           % (bit_scale-2) of integer bit
learning_rate           = 1 * 2^bit_scale;  % 0.01
erMult                  = 5;
optimizer               = 'mom';

%==========================================================================
display 'start....'
display 'reading MNIST dataset...'
% *************************************************************************

train_img(:,:,1) = [0 0 1 0 0 ; 0 0 1 0 0 ; 0 0 1 0 0 ;0 0 1 0 0; 0 0 1 0 0 ];
train_img(:,:,2) = [0 1 1 1 0 ; 0 0 0 1 0 ; 0 1 1 1 0 ;0 1 0 0 0; 0 1 1 1 0 ];
train_img(:,:,3) = [0 1 1 1 0 ; 0 0 0 1 0 ; 0 1 1 1 0 ;0 0 0 1 0; 0 1 1 1 0 ];
train_img(:,:,4) = [0 1 0 1 0 ; 0 1 0 1 0 ; 0 1 1 1 0 ;0 0 0 1 0; 0 0 0 1 0 ];
train_img(:,:,5) = [0 1 1 1 0 ; 0 1 0 0 0 ; 0 1 1 1 0 ;0 0 0 1 0; 0 1 1 1 0 ];
train_img(:,:,6) = [0 1 1 1 0 ; 0 1 0 0 0 ; 0 1 1 1 0 ;0 1 0 1 0; 0 1 1 1 0 ];
train_img(:,:,7) = [0 1 1 1 0 ; 0 0 0 1 0 ; 0 0 0 1 0 ;0 0 0 1 0; 0 0 0 1 0 ];
train_img(:,:,8) = [0 1 1 1 0 ; 0 1 0 1 0 ; 0 1 1 1 0 ;0 1 0 1 0; 0 1 1 1 0 ];
train_img(:,:,9) = [0 1 1 1 0 ; 0 1 0 1 0 ; 0 1 1 1 0 ;0 0 0 1 0; 0 1 1 1 0 ];

%train_img = repmat(train_img, [1,1,batch_size]);
train_label = ones(18,batch_size);
h = 4;
w = 4;
%==========================================================================
% Main Function
%***************************************
% initialize cnn
cnn.namaste = 1; % just intiationg cnn object
cnn = initcnn(cnn,[h w],learning_rate);

cnn = cnnAddConvLayer(cnn, 2, [2 2], 'rect');
display 'training started...Wait for ~200 seconds...'
tic
cnn = traincnn(cnn, train_img, train_label, n_epoch, batch_size, optimizer, 1);
toc
display '...training finished.'
display 'testing started....'
tic
% err = testcnn(cnn, test_img, test_label,'round');
toc
display '... testing finished. To get minimum error, increase no of epochs while training.'
% imshow(train_img(:,:,1))
