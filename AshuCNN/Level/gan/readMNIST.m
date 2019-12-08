function [train_img, train_label, test_img, test_label] = readMNIST(dataPath, n_shrinkData_train, n_shrinkData_test)
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