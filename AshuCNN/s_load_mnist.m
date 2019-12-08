clear all
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
train_x = double(train_x)./256;
% train_x = train_x(:,:,1:60000);
% train_x = ceil(train_x);
fclose(f);


f=fopen(fullfile(Datapath, 't10k-images.idx3-ubyte'),'r', 'b') ;
nn=fread(f,1,'int32');
num=fread(f,1,'int32');
h=fread(f,1,'int32');
w=fread(f,1,'int32');
test_x = uint8(fread(f,h*w*num,'uchar')); %load test images
test_x = permute(reshape(test_x, h, w,num), [2 1 3]);
test_x = double(test_x)./256;
% test_x = ceil(test_x);
fclose(f);


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
% train_y = train_y(:,1:30000);
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