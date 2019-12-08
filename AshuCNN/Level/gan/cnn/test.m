clear all
Example_MNIST_CNN
load('cnn_old.mat')
i = 4;
cnn_old.layers{4}.K(:,:,i) == cnn.layers{4}.K(:,:,i)