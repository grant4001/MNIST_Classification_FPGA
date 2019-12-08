function tcnn=cnnAddTransConvLayer(tcnn, no_of_channels, size_of_kernels, strides, padding, activation_func_name)
%   cnnAddConvLayer - 
%   cnn, no_of_feature_maps, sizeof(kernels), activation function -'sigm' 
%   for sigmoid, 'tanh' for tanh, 'rect' for ReLu, 'soft' for softmax, 
%  'none' for none, 'plus' for softplus.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Zhengyu Chen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tcnn.no_of_layers = tcnn.no_of_layers+1;
l = tcnn.no_of_layers;
tcnn.layers{l}.type = 'tc';
tcnn.layers{l}.W_width  = size_of_kernels(1);
tcnn.layers{l}.W_height = size_of_kernels(1);
tcnn.layers{l}.no_channels = no_of_channels;
tcnn.layers{l}.strides = strides;
tcnn.layers{l}.padding = padding;
no_curChannels = no_of_channels;
no_preChannels = tcnn.layers{l-1}.no_channels;
if numel(size_of_kernels) == 2
    tcnn.layers{l}.kernel_width= size_of_kernels(2);
end
% calculate the length of H based 'strides' and 'padding'
switch padding 
    case 'valid'
        tcnn.layers{l}.H_width = strides*tcnn.layers{l-1}.H_width + tcnn.layers{l}.W_width - 1;
    case 'same'
        tcnn.layers{l}.H_width = strides*tcnn.layers{l-1}.H_width;
    otherwise
        error(['we did not implement the padding of ',padding])
end
tcnn.layers{l}.H_height = tcnn.layers{l}.H_width;       

% tcnn.layers{l}.W = 0.5*rand(tcnn.layers{l}.W_height,tcnn.layers{l}.W_width)-0.25;
tcnn.layers{l}.b = zeros(tcnn.layers{l}.H_width, tcnn.layers{l}.H_width, ...
    no_curChannels); % Initialization of B
tcnn.layers{l}.W = zeros(tcnn.layers{l}.W_width,tcnn.layers{l}.W_width,...
    no_curChannels, no_preChannels); % Initialization of W
for i= 1 : no_curChannels
    for j = 1 : no_preChannels
        tcnn.layers{l}.W(:,:,i,j) = 0.5*rand(tcnn.layers{l}.W_height,tcnn.layers{l}.W_width)-0.25;
    end
end
tcnn.layers{l}.act_func=activation_func_name;
    

    
