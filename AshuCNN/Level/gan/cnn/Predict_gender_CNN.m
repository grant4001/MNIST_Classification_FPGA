clear all
display 'start....'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% This examples is created for fun purpose only. Limited accuracy.
%%%%%%%% Trained on 500 images searched on internet with the keywords - actors,
%%%%%%%% actors bollywood, actress, actress indian, monkey face.
%%%%%%%% I found accuracy around 80% on collected dataset.
tic
%% correct the following path
Datapath1 = 'D:/AshuCNN/Internet_Images/'; %path of images
Datapath ='D:/AshuCNN/';  % path of program files and data on your pc
display 'start....'
display 'reading dataset...'


% image's size
h = 60;
w = 60;

% storage for test images: at least two images required.
test_x = zeros([h w  3]);  % 3 test images
%test_y = zeros([3 120]);


k=1; % k -> index for images
% load multiple images .
% labels
% [1 0 0] - for female
% [0 1 0] - for male
% [0 0 1] - more similar to monkey rather than male or female human - just
% for fun.

% change the file names according to your images.
% we assume filenames are stored as f (1).jpg, f (2).jpg etc.
for i=1:1:3
    %I=imread(fullfile(Datapath, wiki.full_path{i}));
    st = sprintf('f (%d).jpg',i);
    I=imread(fullfile(Datapath1, st));
     if(size(I,3) > 1)
        I = rgb2gray(I);
%         M=I;
%         I(:,:,1)=M;
%         I(:,:,2)=M;
%         I(:,:,3)=M;
    end
    I = imresize(I, [h w ] );
    I = rescale(double(I))/2;
    %I = I - mean(I(:));
    test_x(:,:,k)=I;
    
    k = k+1;
    
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% We create our arbitary CNN and train it with internet dataset
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




% initialize cnn
cnn.namaste=1; % just intiationg cnn object

cnn=initcnn(cnn,[h w ]);

%load trained cnn network
     cnn = loadcnn(fullfile(Datapath, 'my_face_cnn5.mat'));
 %following commented code shows the cnn we have trained and saved in above
 %file.
% cnn=cnnAddConvLayer(cnn, 9, [5 5], 'rect');
%  cnn=cnnAddPoolLayer(cnn, 2, 'mean');
% cnn=cnnAddConvLayer(cnn, 15, [5 5], 'rect');
%  cnn=cnnAddPoolLayer(cnn, 2, 'mean');
%  cnn=cnnAddConvLayer(cnn, 21, [5 5], 'rect');
%  cnn=cnnAddPoolLayer(cnn, 2, 'mean');
% 
% cnn=cnnAddFCLayer(cnn,300, 'tanh' ); %add fully connected layer
% cnn=cnnAddFCLayer(cnn,3, 'sigm' ); %add fully connected layer % last layer no of nodes = no of lables



%%

display '...predicting gender..'
[a l1]=predictcnn(cnn, test_x);
for i=1:size(test_x, 3)
    if l1(i) == 1
        str=sprintf('f (%d).jpg looks alike female with prob. %f\n', i, a(i));
        display(str)
    elseif l1(i) == 2
        str=sprintf('f (%d).jpg looks alike male with prob. %f\n', i, a(i));
        display(str)
     elseif l1(i) == 3
        str=sprintf('f (%d).jpg looks alike monkey with prob. %f\n', i, a(i));
        display(str)
    end
end


toc