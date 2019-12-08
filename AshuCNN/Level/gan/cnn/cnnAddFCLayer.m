%==========================================================================
% Add a fully-connected layer
%==========================================================================
% Version: Re-write
% Created By: Zhengyu Chen
% Modified on: 03/17/19
% *************************************************************************
function cnn = cnnAddFCLayer(cnn, no_of_nodes, activation_func)
global bit_scale;
%bit_scale = 10;

cnn.no_of_layers                    = cnn.no_of_layers +1;
l_current                           = cnn.no_of_layers;
cnn.layers{l_current}.type          = 'f';
cnn.layers{l_current}.no_of_nodes   = no_of_nodes;
cnn.layers{l_current}.act_func      = activation_func;

if ~strcmp(cnn.layers{l_current-1}.type, 'f')
    prev_layer_no_featuremaps                   = cnn.layers{l_current-1}.no_featuremaps;
    prev_layer_featuremap_width                 = cnn.layers{l_current-1}.featuremap_width;
    prev_layer_featuremap_height                = cnn.layers{l_current-1}.featuremap_height;
    cnn.layers{l_current}.no_of_inputs          = prev_layer_no_featuremaps * prev_layer_featuremap_height *prev_layer_featuremap_width;
    cnn.layers{l_current}.convert_input_to_1D   = 1;
elseif strcmp(cnn.layers{l_current-1}.type, 'f')
    cnn.layers{l_current}.no_of_inputs          = cnn.layers{l_current-1}.no_of_nodes;
    cnn.layers{l_current}.convert_input_to_1D   = 0; %already 1D
end

%RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
% cnn.layers{l_current}.W =0.5*rand([no_of_nodes cnn.layers{l_current}.no_of_inputs]) -0.25;
% cnn.layers{l_current}.b = 0.5*rand([no_of_nodes 1]) - 0.25;
% cnn.layers{l_current}.W = 0.1*ones([no_of_nodes cnn.layers{l_current}.no_of_inputs]);
% cnn.layers{l_current}.b = zeros([no_of_nodes 1]);
load('z_W_layer6.mat')
load('z_W_layer7.mat')
load('z_b_layer6.mat')
load('z_b_layer7.mat')
switch l_current
    case 6
        cnn.layers{l_current}.W = W_layer6 * 2^bit_scale;
        cnn.layers{l_current}.b = b_layer6 * 2^bit_scale;
    case 7
        cnn.layers{l_current}.W = W_layer7 * 2^bit_scale;
        cnn.layers{l_current}.b = b_layer7 * 2^bit_scale;
end
        
    

    
