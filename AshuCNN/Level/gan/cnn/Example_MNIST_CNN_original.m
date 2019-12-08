clear all
display 'start....'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Download MNIST dataset from http://yann.lecun.com/exdb/mnist/
%% Store in a folder /directory named MNIST
%% correct the following path
Datapath = '.\MNIST\';

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


f=fopen(fullfile(Datapath, 't10k-images.idx3-ubyte'),'r', 'b') ;
nn=fread(f,1,'int32');
num=fread(f,1,'int32');
h=fread(f,1,'int32');
w=fread(f,1,'int32');
test_x = uint8(fread(f,h*w*num,'uchar')); %load train images
test_x = permute(reshape(test_x, h, w,num), [2 1 3]);
test_x = double(test_x)./255;
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


f=fopen(fullfile(Datapath, 't10k-labels.idx1-ubyte'),'r', 'b') ;
nn=fread(f,1,'int32');
num=fread(f,1,'int32');
y = double(fread(f,num,'uint8')); %load test labels
y = (y)' ;
test_y = zeros([10 num]); % there are 10 labels in MNIST lables
for i=0:9 % labels are 0 - 9
    k = find(y==i);
    test_y(i+1,k)=1;
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

% initialize cnn
cnn.namaste=1; % just intiationg cnn object

cnn=initcnn(cnn,[h w], 0.01);

%%
%  below is an another example of CNN that can be used.
% Example 1
%  cnn=cnnAddConvLayer(cnn, 10, [7 7], 'tanh'); 
%  cnn=cnnAddPoolLayer(cnn, 2, 'mean'); %cnn, subsampling factor
%  cnn=cnnAddConvLayer(cnn, 15, [3 3], 'tanh');
%  cnn=cnnAddPoolLayer(cnn, 3, 'mean');
% cnn=cnnAddFCLayer(cnn,150, 'tanh' ); %add fully connected layer
% cnn=cnnAddFCLayer(cnn,10, 'sigm' ); %add fully connected layer
% 

%% Example 2
%  
%  cnn=cnnAddConvLayer(cnn, 40, [5 5], 'sigm');
%  cnn=cnnAddPoolLayer(cnn, 3, 'mean');
%  cnn=cnnAddConvLayer(cnn, 50, [3 3], 'sigm');
%  cnn=cnnAddPoolLayer(cnn, 2, 'mean');
% cnn=cnnAddFCLayer(cnn,90, 'sigm' ); %add fully connected layer
% cnn=cnnAddFCLayer(cnn,10, 'sigm' ); %add fully connected layer
%% 

%%% Example 3
cnn=cnnAddConvLayer(cnn, 10, [9 9], 'rect');
 cnn=cnnAddPoolLayer(cnn, 2, 'mean');
cnn=cnnAddConvLayer(cnn, 20, [3 3], 'tanh');
 cnn=cnnAddPoolLayer(cnn, 2, 'mean');
cnn=cnnAddFCLayer(cnn,150, 'tanh' ); %add fully connected layer
cnn=cnnAddFCLayer(cnn,10, 'sigm' ); %add fully connected layer % last layer no of nodes = no of lables

%%
%%%more parameters
%cnn.loss_func = 'cros';

%cnn.loss_func = 'quad'; 
no_of_epochs = 1;
batch_size=50;
display 'training started...Wait for ~200 seconds...'
tic
cnn=traincnn(cnn,train_x,train_y, no_of_epochs,batch_size);
toc
display '...training finished.'
display 'testing started....'
tic
err=testcnn(cnn, test_x, test_y);
toc
display '... testing finished. To get minimum error, increase no of epochs while training.'

