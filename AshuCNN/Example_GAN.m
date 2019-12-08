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



tcnn.namaste = 1; % just intiationg cnn object
cnn.namaste = 1;
learning_rate = 0.01;
tcnn=inittcnn(tcnn, [7 7], learning_rate);
cnn=initcnn(cnn, [28 28], learning_rate);
%%
%  below is an another example of CNN that can be used.
%%% G
% tcnn=cnnAddTransConvLayer(tcnn,[2 2], 'rect');
% tcnn=cnnAddTransConvLayer(tcnn,[4 4], 'rect');
% tcnn=cnnAddTransConvLayer(tcnn,[7 7], 'rect');
% tcnn=cnnAddTransConvLayer(tcnn,[17 17], 'rect');
tcnn=cnnAddTransConvLayer(tcnn,3,[5 5], 2, 'same','rect');
tcnn=cnnAddTransConvLayer(tcnn,3,[5 5], 2, 'same', 'rect');
tcnn=cnnAddTransConvLayer(tcnn,1, [5 5], 1, 'same', 'rect');

%%% D
cnn=cnnAddConvLayer(cnn, 8, [5 5], 'rect');
cnn=cnnAddPoolLayer(cnn, 2, 'mean');
cnn=cnnAddConvLayer(cnn, 16, [3 3], 'rect');
cnn=cnnAddPoolLayer(cnn, 2, 'mean');
cnn=cnnAddFCLayer(cnn,32, 'rect' ); %add fully connected layer
% 'none'
cnn=cnnAddFCLayer(cnn,1, 'sigm' ); %add fully connected layer % last layer no of nodes = no of lables
 
%%

% train_x = x; % random targets
% train_x = repmat(x(:,:,1),[1,1,10000]); % identical targets
% imshow(train_x(:,:,randi(1000,1)));   
% no_test = 1000;
batch_size = 20;
iteration = 1;
% train_x = train_x(:,:,1:no_test*batch_size);
% initialize cnn
train_x = train_x(:,:,1:1000);
display 'training started...'
tcnn.loss_array=[];
train_D_y(1:batch_size) = zeros(batch_size,1);
train_D_y(batch_size+1:2*batch_size) = ones(batch_size,1);
% parpool(2)
for j = 1 : iteration
    display(['iteration ',num2str(j)])
    tstart = tic;
    for i = 1 : size(train_x,3)/batch_size

        % xx = repmat(rand(2,2), [1,1,size(train_x,3)]); % identical input

        %%% ++++++++ Train D ++++++++++++++++
        %
        %   |-----|     |-----|
        %   |  G  | ==> |image|
        %   |-----|     |-----|
        % 
        xx = rand(7, 7, batch_size); % random input
        tcnn = fftcnn(tcnn, xx); % Generate images from G
        train_D_x = zeros(28,28,batch_size*2);
        train_D_x(:,:,1:batch_size) = tcnn.layers{4}.H{1};
        train_D_x(:,:,batch_size+1:2*batch_size) = train_x(:,:,(i-1)*batch_size+1 : i*batch_size);
        
        %   |-----|     |-----|
        %   |image| ==> |  D  |
        %   |-----|     |-----|
        %                update                     
        cnn = traincnn(cnn, train_D_x, train_D_y, 1, batch_size);
        %%% ++++++++ Train G ++++++++++++++++
        train_G_x = rand(7, 7, batch_size); % random input
        train_G_y = ones(1,batch_size);    
        %
        %   |-----|     |-----|     |-----|
        %   |  G  | ==> |image| ==> |  D  |
        %   |-----|     |-----|     |-----|
        %   
        tcnn = fftcnn(tcnn, train_G_x);
        image_intl = tcnn.layers{4}.H{1};
        cnn = ffcnn(cnn, image_intl);
        %
        %   |-----|     |-----|     |-----|
        %   |  G  | <== |image| <== |  D  |
        %   |-----|     |-----|     |-----|
        %    update                   fix    
        cnn = bpcnn(cnn,train_G_y);
        % Modification needed!
        er = cnn.layers{1}.er{1}; % check the error from cnn
        tcnn = bptcnn(tcnn, 0, 'gan', er);
        tcnn = gradientdescenttcnn(tcnn); 
        tcnn.loss_array = [tcnn.loss_array tcnn.loss];
%         display(['loss_G = ', num2str(tcnn.loss)])
    end
    telapsed = toc(tstart);
    display([num2str(telapsed*(iteration-j)/60),' mins left'])
    display '...'
end
% delete(gcp('nocreate'))

    
%     no_of_epochs = 1;
% % batch_size=50;
% display 'training started...Wait for ~200 seconds...'
% tic
% tcnn=traintcnn(tcnn,xx,train_x, no_of_epochs,batch_size);
% toc
% display '...training finished.'
% display 'testing started....'
% tic
% % err=testcnn(tcnn, test_x, test_y);
% toc
% display '... testing finished. To get minimum error, increase no of epochs while training.'
% imshow(tcnn.layers{5}.H(:,:,1));
% imshow(train_x(:,:,randi(1000,1)));
