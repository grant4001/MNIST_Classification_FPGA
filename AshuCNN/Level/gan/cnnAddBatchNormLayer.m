%==========================================================================
% Add a BatchNorm Layer
%==========================================================================
% Version: 
% Created By: Zhengyu Chen
% Modified on: 03/27/19
% *************************************************************************
function NN = cnnAddBatchNormLayer(NN)

NN.no_of_layers                     = NN.no_of_layers +1;
l_current                           = NN.no_of_layers;
NN.layers{l_current}.type           = 'b';
if  (NN.layers{l_current-1}.type == 'c') || (NN.layers{l_current-1}.type == 't') 
    NN.layers{l_current}.no_featuremaps     = NN.layers{l_current-1}.no_featuremaps;
    NN.layers{l_current}.featuremap_width   = NN.layers{l_current-1}.featuremap_width;
    NN.layers{l_current}.featuremap_height  = NN.layers{l_current-1}.featuremap_height;
elseif NN.layers{l_current-1}.type == 'f'
    NN.layers{l_current}.featuremap_width   = NN.layers{l_current-1}.featuremap_width;
    NN.layers{l_current}.featuremap_height  = NN.layers{l_current-1}.featuremap_width;
    NN.layers{l_current}.no_featuremaps = size(NN.layers{l_current-1}.W, 1)/ ...
        (NN.layers{l_current-1}.featuremap_width)^2;
end

NN.layers{l_current}.gamma = 1;
NN.layers{l_current}.beta  = 0;

    
NN.layers{l_current}.act_func = 'none';
    
