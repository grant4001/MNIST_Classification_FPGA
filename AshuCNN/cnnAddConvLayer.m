function cnn=cnnAddConvLayer(cnn, no_of_featuremaps, size_of_kernels, activation_func_name, BITS)

%   cnnAddConvLayer - 
%   cnn, no_of_feature_maps, sizeof(kernels), activation function -'sigm' 
%   for sigmoid, 'tanh' for tanh, 'rect' for ReLu, 'soft' for softmax, 
%  'none' for none, 'plus' for softplus.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cnn.no_of_layers= cnn.no_of_layers +1;
l=cnn.no_of_layers;
cnn.layers{l}.type = 'c';
cnn.layers{l}.no_featuremaps = no_of_featuremaps;
cnn.layers{l}.kernel_width= size_of_kernels(1);
cnn.layers{l}.kernel_height= size_of_kernels(1);
if numel(size_of_kernels)==2
    cnn.layers{l}.kernel_width= size_of_kernels(2);
end
prev_layer_featuremap_width=cnn.input_image_width;
prev_layer_featuremap_height=cnn.input_image_height;
prev_layer_no_featuremaps = cnn.no_of_input_channels;
if l>1
    prev_layer_no_featuremaps = cnn.layers{l-1}.no_featuremaps;
    prev_layer_featuremap_width = cnn.layers{l-1}.featuremap_width;
    prev_layer_featuremap_height = cnn.layers{l-1}.featuremap_height;
end
%cnn.layers{l}.no_kernels=prev_layer_no_featuremaps * no_of_featuremaps;
cnn.layers{l}.featuremap_width = prev_layer_featuremap_width - cnn.layers{l}.kernel_width +1;
cnn.layers{l}.featuremap_height = prev_layer_featuremap_height - cnn.layers{l}.kernel_height +1;
cnn.layers{l}.prev_layer_no_featuremaps = prev_layer_no_featuremaps;
k=0;
for i=1: no_of_featuremaps
    for j=1: prev_layer_no_featuremaps
         k = k+1;
         cnn.layers{l}.K(:,:,k)= s_quantize(0.5*rand(cnn.layers{l}.kernel_height,cnn.layers{l}.kernel_width)-0.25, BITS);
    end
end
for j=1:no_of_featuremaps
     cnn.layers{l}.b(j)=0;
end

% for i=1:no_of_featuremaps
%     cnn.layers{l}.featuremaps{i} = zeros([cnn.layers{l}.featuremap_height cnn.layers{l}.featuremap_width]);
% end
cnn.layers{l}.act_func=activation_func_name;
    

    
