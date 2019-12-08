%==========================================================================
% Add a pooling layer
%==========================================================================
% Version: Re-write
% Created By: Zhengyu Chen
% Modified on: 03/17/19
% *************************************************************************
function cnn=cnnAddPoolLayer(cnn, subsamplerate, subsamplemethod)

cnn.no_of_layers                        = cnn.no_of_layers +1;
l_current                               = cnn.no_of_layers;
cnn.layers{l_current}.type              = 'p';
cnn.layers{l_current}.subsample_rate    = subsamplerate;
cnn.layers{l_current}.subsample_method  = subsamplemethod;
cnn.layers{l_current}.no_featuremaps    = cnn.layers{l_current-1}.no_featuremaps;
cnn.layers{l_current}.featuremap_width  = cnn.layers{l_current-1}.featuremap_width/subsamplerate;
cnn.layers{l_current}.featuremap_height = cnn.layers{l_current-1}.featuremap_height/subsamplerate;

% for i=1:cnn.layers{l}.no_featuremaps
%     cnn.layers{l}.featuremaps{i} = zeros(cnn.layers{l}.featuremap_height, cnn.layers{l}.featuremap_width);
% end
    
cnn.layers{l_current}.act_func = 'none';
    
