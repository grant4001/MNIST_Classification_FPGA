%==========================================================================
% Add a convolutional layer
%==========================================================================
% Version: Re-write
% Created By: Zhengyu Chen
% Modified on: 03/16/19
% *************************************************************************
function cnn = cnnAddConvLayer(cnn, n_channel, size_filter, activation_func)
global bit_scale;
%bit_scale = 10;

cnn.no_of_layers                        = cnn.no_of_layers + 1; % Update total num of layer
l_current                               = cnn.no_of_layers;     % Current layer number
cnn.layers{l_current}.type              = 'c';                  % Layer type
cnn.layers{l_current}.no_featuremaps    = n_channel;            % Num of channel in Conv layer
cnn.layers{l_current}.kernel_width      = size_filter(1);       % Filter size
cnn.layers{l_current}.kernel_height     = size_filter(2);       % Filter size

prev_layer_no_featuremaps       = cnn.layers{l_current-1}.no_featuremaps;   % Previous layer's channel num
prev_layer_featuremap_width     = cnn.layers{l_current-1}.featuremap_width; % Previous layer's filter size
prev_layer_featuremap_height    = cnn.layers{l_current-1}.featuremap_height;

cnn.layers{l_current}.featuremap_width  = prev_layer_featuremap_width - cnn.layers{l_current}.kernel_width +1;
cnn.layers{l_current}.featuremap_height = prev_layer_featuremap_height - cnn.layers{l_current}.kernel_height +1;
cnn.layers{l_current}.prev_layer_no_featuremaps = prev_layer_no_featuremaps;
%==========================================================================
% weight/bias initialization
k = 0;
% for i = 1 : n_channel
%     for j=1: prev_layer_no_featuremaps
%         k = k + 1;
%       cnn.layers{l_current}.K(:,:,k)= 0.5*rand(cnn.layers{l_current}.kernel_height,cnn.layers{l_current}.kernel_width)-0.25;
% %         cnn.layers{l_current}.K(:,:,k) = 0.1*ones(cnn.layers{l_current}.kernel_height);
%     end
% end
load('z_K_layer2.mat')
load('z_K_layer4.mat')
switch l_current
    case 2
        cnn.layers{l_current}.K = K_layer2 * 2^bit_scale;
    case 4
        cnn.layers{l_current}.K = K_layer4 * 2^bit_scale;
end
        


for j = 1 : n_channel
     cnn.layers{l_current}.b(j) = 0;
end

cnn.layers{l_current}.act_func = activation_func;
    

    
