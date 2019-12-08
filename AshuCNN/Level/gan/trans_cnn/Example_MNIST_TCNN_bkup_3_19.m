clear all;
clc
display 'start....'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Download MNIST dataset from http://yann.lecun.com/exdb/mnist/
%% Store in a folder /directory named MNIST
%% correct the following path
Datapath = './MNIST/';
display 'start....'
display 'reading MNIST dataset...'
f=fopen(fullfile(Datapath, 'train-images.idx3-ubyte'),'r', 'b') ;
if f < 0
    error('please load MNIST dataset, store it in a folder and check the path and name of the file');
end
nn=fread(f,1,'int32');
num=fread(f,1,'int32');
h=fread(f,1,'int32');
w=fread(f,1,'int32');
train_x = uint8(fread(f,h*w*num,'uchar')); %load train images
train_x = permute(reshape(train_x, h, w,num), [2 1 3]);
train_x = double(train_x)./255;
fclose(f) ;

f=fopen(fullfile(Datapath, 'train-labels.idx1-ubyte'),'r', 'b') ;
nn=fread(f,1,'int32');
num=fread(f,1,'int32');
y = double(fread(f,num,'uint8'));   %load train labels
y = (y)'; %.
train_y = zeros([10 num]); % there are 10 labels in MNIST lables
for i=0:9 % labels are 0 - 9
    k = find(y==i);
    train_y(i+1,k)=1;
end
fclose(f) ;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% We create our arbitary CNN and train it with MNIST dataset
%%%%% The architecture of CNN is arbitrarily choosen for experimental purpose
%%%%% The architecture may be revised for better result.

%   cnnAddConvLayer - Add convolution layer
%   cnn, no_of_feature_maps, sizeof(kernels), activation function -'sigm' 
%   for sigmoid, 'tanh' for tanh, 'rect' for ReLu, 'soft' for softmax, 
%  'none' for none, 'plus' for softplus.

% cnnAddPoolLayer - Add Pool layer
% cnn, subsampling factor, subsampling type. Presently only 'mean'
% subsampling is implemented.

%cnnAddFCLayer - Add fully connected neural network layer
% cnn, no of NN nodes, activation function.


%% xx = xx - mean(xx(:));
k = 1;
learning_rate = 0.01;
for i = 1 : size(train_x,3)
    if train_y(2,i) == 1
        x(:,:,k) = train_x(:,:,i);
        k = k+1;
    end   
end
% train_x = x; % random targets
train_x = repmat(x(:,:,1),[1,1,100000]); % identical train data
% imshow(train_x(:,:,randi(1000,1)));   
n_test = 200; %200
batch_size = 100; % 100
train_x = train_x(:,:,1:n_test*batch_size);
% initialize cnn

% xx = rand(2, 2, size(train_x,3)); % random input
yy = rand(28, 28, size(train_x,3));
xx = repmat(rand(7,7), [1,1,size(train_x,3)]); % identical input
h = size(xx,1);
w = size(xx,2);
Tcnn.namaste=1; % just intiationg cnn object

Tcnn=initTcnn(Tcnn,[h w], learning_rate);

%%
%  below is an another example of CNN that can be used.

%%% Example 1
% tcnn=cnnAddTransConvLayer(tcnn,2,[2 2],1,'valid','rect');
% tcnn=cnnAddTransConvLayer(tcnn,3,[4 4],1,'valid','rect');
% tcnn=cnnAddTransConvLayer(tcnn,2,[7 7],1,'valid','rect');
% tcnn=cnnAddTransConvLayer(tcnn,1,[17 17],1,'valid','rect');
%%% Example 2
Tcnn=cnnAddTransConvLayer(Tcnn,3,[5 5], 2, 'same','rect');
Tcnn=cnnAddTransConvLayer(Tcnn,3,[5 5], 2, 'same', 'rect');
Tcnn=cnnAddTransConvLayer(Tcnn,1, [5 5], 1, 'same', 'rect');
 
 
%%
%%%more parameters
%cnn.loss_func = 'cros';

%cnn.loss_func = 'quad'; 
% no_of_epochs = 1;
% batch_size=10;
% display 'training started...Wait for ~200 seconds...'
% tic
% % tcnn=traintcnn(tcnn,train_x,train_y, no_of_epochs,batch_size);
% tcnn=fftcnn(tcnn, xx);
% tcnn = bptcnn(tcnn,yy,'none',0);
% tcnn =gradientdescenttcnn(tcnn);
% toc
no_of_epochs = 1;
% batch_size=50;
display 'training started...Wait for ~200 seconds...'
tic
Tcnn = trainTcnn(Tcnn,xx,train_x, no_of_epochs,batch_size);
toc
display '...training finished.'
display 'testing started....'
tic
% err=testcnn(tcnn, test_x, test_y);
toc
display '... testing finished. To get minimum error, increase no of epochs while training.'
imshow(Tcnn.layers{5}.H{1}(:,:,1));
% imshow(train_x(:,:,randi(1000,1)));
