% step 1. download a dataset or make your own dataset. Load data  in 3d
%         matrix- x(:,:,1) should represent first 2D image. Load labels in
%         2d marix - y(:,1) should represent label for first image.
%

% step 2. size of images should be same. If they are different, better to
% normalize them. Optionally, image can be preprocessed.
%

%step 3. Decide your CNN structure and build using following functions
%        a. % initialize cnn
%             cnn.namaste=1; % just intiationg cnn object
%             cnn=initcnn(cnn,[h w]);
%             where [h w] is size of input images.
%
%        b. Add convolution layer by calling cnnAddConvLayer()
%       parameters are : - cnn object, no_of_feature_maps, size(kernels), 
%                          activation function -'sigm' 
%   for sigmoid, 'tanh' for tanh, 'rect' for ReLu, 'soft' for softmax, 
%  'none' for none, 'plus' for softplus.
%            NOTE : size of feature maps (i.e. output) will be
%                        (h- kernel_height+1) x (w - kernel_width+1)
%                   where h x w is size of input to this layer.
%                   If this is first layer, h xw is size of input image,
%                   else, h xw is size of previous layer 's output.
%
%       c. Add Pooling layer between two conv layer or before FF layer or
%       at end.
%       parameters are: 
%                       cnn object , subsampling factor, subsampling type.
%              Presently only 'mean'subsampling type is implemented.
%           NOTE : size of input to this layer should be integer multiple 
%                  of  subsampling rate (subsampling factor). The size of
%                  output of this layer = inputsize / subsampling_rate.
%
%        d. Add Fully connected neural network layer,at the end of network.
%        parameters are :
%         cnn object, no of NN nodes, activation function.
%         NOTE : if this is last layer, no of nodes should match with the
%         no. of labels in your dataset.
%

%step 4.  train your network with training dataset
%       use function : cnn=traincnn(cnn,train_x,train_y,
%       no_of_epochs,batch_size);
%        train_x is training data, train_y is corresponding labels.
%        batch_size should be in integer multiple of total no. of training
%        data. no_of_epochs should be > 1 for better accuracy, but will
%        take more time to train.
%

%step 5. test your network with test dataset.
%        use function: err=testcnn(cnn, test_x, test_y);
%        where test_x is test data, test_y is corresponding labels.
%        NOTE: no of examples in test data (as well as in training data)
%        should be > 1, otherwise you will get matrix size mismatch error.
%        err is error on test data returned by testcnn.
