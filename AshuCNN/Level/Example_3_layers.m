clear all;
clc;

Datapath = './MNIST/';

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
%modified by qc
%train_x = double(train_x)./255;
% train_x = cnnquantize(train_x);
% train_x = round(train_x);
fclose(f) ;


f=fopen(fullfile(Datapath, 't10k-images.idx3-ubyte'),'r', 'b') ;
nn=fread(f,1,'int32');
num=fread(f,1,'int32');
h=fread(f,1,'int32');
w=fread(f,1,'int32');
test_x = uint8(fread(f,h*w*num,'uchar')); %load test images
test_x = permute(reshape(test_x, h, w,num), [2 1 3]);
%modified by qc
%test_x = double(test_x)./255;
% test_x = cnnquantize(test_x);
% test_x = round(test_x);
fclose(f) ;


f=fopen(fullfile(Datapath, 'train-labels.idx1-ubyte'),'r', 'b') ;
nn=fread(f,1,'int32');
num=fread(f,1,'int32');
y = double(fread(f,num,'uint8'));   %load train labels
y = (y)'; 
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




% initialize cnn
cnn.namaste = 1;
cnn = initcnn(cnn, [h, w], 0.01);

cnn = cnnAddConvLayer(cnn, 40, [5 5], 'rect');
cnn = cnnAddPoolLayer(cnn, 2, 'mean');
cnn = cnnAddConvLayer(cnn, 40, [5 5], 'rect');
cnn = cnnAddPoolLayer(cnn, 2, 'mean');
cnn = cnnAddFCLayer(cnn,32, 'rect'); % Add fully connected layer
cnn = cnnAddFCLayer(cnn,10, 'sigm'); % Add fully connected layer % last layer no of nodes = no of lables

batch_size  = 100;
no_of_epochs = 1;

% train process
tic
cnn = traincnn(cnn, train_x, train_y, no_of_epochs, batch_size);
toc


err = testcnn(cnn, test_x, test_y);

