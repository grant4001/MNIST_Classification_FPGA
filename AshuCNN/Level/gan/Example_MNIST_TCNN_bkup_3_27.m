%==========================================================================
% Version:      Tranposed CNN Test
% Created By:   Sihua Fu, Qiankai Cao, Zhengyu Chen
% Created on:   03/19/19
% Modified on:  03/20/19
% *************************************************************************
% Current   1.
% Reuslt:
% *************************************************************************
% Remaining 1.
% Issues:
% *************************************************************************
%  Note:    1. Download MNIST dataset from http://yann.lecun.com/exdb/mnist/
%           2. Store in a folder /directory named MNIST
% *************************************************************************
close all;
clear all;

%==========================================================================
% Parameters
%==========================================================================
% global bit_scale;
dataPath                = './MNIST/';
batch_size              = 100;       % 50
n_shrinkData_train      = 10;
n_shrinkData_test       = 10;
n_epoch                 = 1;
input_enlarge           = 1;        % Increase value of input(image)
bit_scale               = 10;       % (bit_scale-2) of integer bit
learning_rate           = 0.00015*10;    % 0.001 for case I
digit_sel               = 4;
train_identical         = 1;
noise_identical         = 1;
noise_hardcode          = 1;        % hardcode noise
noise_height            = 64;       % 64
noise_width             = 1;        % 1
optimizer               = 'gd';     % 'gd', 'mom', 'adam', 'rms', 
loss_func               = 'cros';   % 'auto', 'cros'

%==========================================================================
% Read database
%==========================================================================
[train_img, train_label, test_img, test_label] = readMNIST(dataPath, ...
    1, n_shrinkData_test);
%==========================================================================
% Quantize input
%==========================================================================
train_img   = round(train_img);
test_img    = round(test_img);
train_img   = train_img*input_enlarge;
test_img    = test_img*input_enlarge;
%==========================================================================
% Main
%==========================================================================

%**************************************************************************
% Select train_img with particular digit, e.g. '1'
k_cnt = 1;
for i = 1 : size(train_img,3)
    if train_label(digit_sel+1,i) == 1
        train_img_sel(:,:,k_cnt) = train_img(:,:,i);
        k_cnt = k_cnt+1;
    end   
end
train_img_sel = train_img_sel(:,:,1:5000); 
train_img_sel = repmat(train_img_sel,[1,1,12]);
if train_identical == 1
    train_img_sel = repmat(train_img_sel(:,:,1),[1,1,60000]); % Identical train data
end
train_img_sel = train_img_sel(:, :, 1:60000/n_shrinkData_train);
train_img = train_img(:, :, 1 : 60000/n_shrinkData_train);
% Random noise
if noise_identical == 1
    if noise_hardcode == 1
%         load('z_noise_2x2.mat')
        load('z_noise_1x64.mat')
        noise = repmat(ans, [1,1,size(train_img_sel,3)]); % Identical noise
    else
        noise = repmat(rand(noise_width,noise_height), [1,1,size(train_img_sel,3)]); % Identical noise
    end
else
    noise = rand(noise_width,noise_height,size(train_img_sel,3));          % Random noise
end
h_noise = noise_width;
w_noise = noise_height;

% load('z_noise_identical.mat')
%*******************************************************************************
% Build T-CNN architecture
%*******************************************************************************

% Initialize CNN
Tcnn.namaste=1; % just intiationg cnn object
Tcnn=initTcnn(Tcnn,[h_noise w_noise], learning_rate);
Tcnn.loss_func = loss_func;

% Case I: worked
% noise_width             = 2; 
% Tcnn = cnnAddTransConvLayer(Tcnn, 2, [2 2], 1, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 2, [4 4], 1, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 2, [7 7], 1, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 1, [17 17],1,'valid','sigm');

% Case I-I XXX 3.24worked!
% noise_width             = 2; 
% Tcnn = cnnAddTransConvLayer(Tcnn, 10, [2 2], 1, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 10, [4 4], 1, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 10, [7 7], 1, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 1, [17 17],1, 'valid','sigm');

% Case II: didn't work
% noise_width             = 2; 
% Tcnn = cnnAddTransConvLayer(Tcnn, 5, [3 3], 2, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 5, [5 5], 2, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 1, [5 5], 1, 'valid','sigm');

% % Case III
% Tcnn = cnnAddFCLayer(Tcnn, 4*4*32, 'rect'); % 512
% Tcnn.layers{Tcnn.no_of_layers}.featuremap_width = 4;
% Tcnn = cnnAddTransConvLayer(Tcnn, 30, [5 5], 2, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 1, [5 5], 2, 'valid','sigm');

% Case III-I
fMap_w = 5;

Tcnn = cnnAddFCLayer(Tcnn, fMap_w*fMap_w*40, 'rect'); % 
Tcnn.layers{Tcnn.no_of_layers}.featuremap_width = fMap_w;
Tcnn = cnnAddTransConvLayer(Tcnn, 40, [5 5], 2, 'valid','rect');
Tcnn = cnnAddTransConvLayer(Tcnn, 1, [4 4], 2, 'valid','sigm');


% Case III-II
% noise_width             = 2;
% Tcnn = cnnAddTransConvLayer(Tcnn, 40, [5 5], 2, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 1, [4 4], 2, 'valid','sigm');

% Tcnn = cnnAddFCLayer(Tcnn, 4*4*16, 'rect'); % 512
% Tcnn.layers{Tcnn.no_of_layers}.featuremap_width = 4;
% Tcnn = cnnAddTransConvLayer(Tcnn, 10, [5 5], 2, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 1, [5 5], 2, 'valid','sigm');


% Case IV
% Tcnn = cnnAddFCLayer(Tcnn, 2*2*16, 'rect'); % 512
% Tcnn.layers{Tcnn.no_of_layers}.featuremap_width = 2;
% Tcnn = cnnAddTransConvLayer(Tcnn, 2, [2 2], 1, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 2, [4 4], 1, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 2, [7 7], 1, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 1, [17 17],1,'valid','sigm');

%*******************************************************************************

figure;
hold on;
tic
Tcnn = trainTcnn(Tcnn, noise ,train_img_sel, n_epoch,batch_size, optimizer);
toc

display '... testing finished. To get minimum error, increase no of epochs while training.'
Tcnn.loss_array(end)
% subplot(1,2,1) 
% imshow(Tcnn.layers{Tcnn.no_of_layers}.featuremaps{1}(:,:,1));
% subplot(1,2,2) 
% imshow(train_img_sel(:,:,1))

% imshow(train_x(:,:,randi(1000,1)));
