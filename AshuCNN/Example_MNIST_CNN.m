s_load_mnist;

% PARAMETERS
NEW_DIM = 30;

ntest_x = zeros(NEW_DIM,NEW_DIM,10000);
ntrain_x = zeros(NEW_DIM,NEW_DIM,60000);

for i = 1:10000    
    for j = 1:28
        for k = 1:28
            ntest_x(1+j, 1+k, i) = test_x(j,k,i);
        end
    end
end

for i = 1:60000    
    for j = 1:28
        for k = 1:28
            ntrain_x(1+j, 1+k, i) = train_x(j,k,i);
        end
    end
end
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

cnn=initcnn(cnn,[30 30],0.01);

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
%   cnn=cnnAddConvLayer(cnn, 40, [5 5], 'sigm');
%   cnn=cnnAddPoolLayer(cnn, 3, 'mean');
%   cnn=cnnAddConvLayer(cnn, 50, [3 3], 'sigm');
%   cnn=cnnAddPoolLayer(cnn, 2, 'mean');
%   cnn=cnnAddFCLayer(cnn,90, 'sigm' ); %add fully connected layer
%   cnn=cnnAddFCLayer(cnn,10, 'sigm' ); %add fully connected layer
%% 

% %%% Example 3
% cnn=cnnAddConvLayer(cnn, 10, [9 9], 'rect');
%  cnn=cnnAddPoolLayer(cnn, 2, 'mean');
% cnn=cnnAddConvLayer(cnn, 20, [3 3], 'tanh');
%  cnn=cnnAddPoolLayer(cnn, 2, 'mean');
% cnn=cnnAddFCLayer(cnn,150, 'tanh' ); %add fully connected layer
% cnn=cnnAddFCLayer(cnn,10, 'sigm' ); %add fully connected layer % last layer no of nodes = no of lables


BITS = 14;

%%% Example 4
 cnn=cnnAddConvLayer(cnn, 16, [3 3], 'rect', BITS);
 cnn=cnnAddPoolLayer(cnn, 2, 'mean');
 cnn=cnnAddConvLayer(cnn, 32, [3 3], 'rect', BITS);
 cnn=cnnAddPoolLayer(cnn, 2, 'mean');
 cnn=cnnAddFCLayer(cnn,64, 'rect', BITS ); %add fully connected layer
 cnn=cnnAddFCLayer(cnn,10, 'none', BITS ); %add fully connected layer % last layer no of nodes = no of lables

no_of_epochs = 1;
batch_size=1000;
display 'training started...Wait for ~200 seconds...'
tic
cnn=traincnn(cnn,ntrain_x,train_y, no_of_epochs,batch_size, BITS);
toc
display '...training finished.'
display 'testing started....'
tic
err=testcnn(cnn, ntest_x, test_y, BITS);
toc
display '... testing finished. To get minimum error, increase no of epochs while training.'

