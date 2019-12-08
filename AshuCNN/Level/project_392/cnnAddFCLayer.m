function cnn = cnnAddFCLayer(cnn, no_of_nodes, activation_func)
% global bit_scale;
%bit_scale = 10;

cnn.no_of_layers                   = cnn.no_of_layers +1;
l_current                           = cnn.no_of_layers;
cnn.layers{l_current}.type         = 'f';
cnn.layers{l_current}.no_of_nodes  = no_of_nodes;
cnn.layers{l_current}.act_func     = activation_func;

if ~strcmp(cnn.layers{l_current-1}.type, 'f')
    prev_layer_featuremap_width                 = cnn.layers{l_current-1}.featuremap_width;
    prev_layer_featuremap_height                = cnn.layers{l_current-1}.featuremap_height;
    cnn.layers{l_current}.no_of_inputs         = prev_layer_featuremap_height *prev_layer_featuremap_width;
    cnn.layers{l_current}.convert_input_to_1D  = 1;
elseif strcmp(cnn.layers{l_current-1}.type, 'f')
    cnn.layers{l_current}.no_of_inputs         = cnn.layers{l_current-1}.no_of_nodes;
    cnn.layers{l_current}.convert_input_to_1D  = 0; %already 1D
end



cnn.layers{l_current}.W = 0.5*rand([no_of_nodes cnn.layers{l_current}.no_of_inputs]) -0.25;
cnn.layers{l_current}.b = 0.5*rand([no_of_nodes 1]) - 0.25;

 cnn.layers{l_current}.v_dW          = zeros(cnn.layers{l_current}.no_of_nodes, cnn.layers{l_current}.no_of_inputs);
 cnn.layers{l_current}.v_db          = zeros(cnn.layers{l_current}.no_of_nodes, 1);
% For Adam, initial value 
% cnn.layers{l_current}.S_dW          = 1;
% cnn.layers{l_current}.S_db          = 1;
% For RMSprop, initial value
cnn.layers{l_current}.S_dW          = 0;
cnn.layers{l_current}.S_db          = 0;
end
    
