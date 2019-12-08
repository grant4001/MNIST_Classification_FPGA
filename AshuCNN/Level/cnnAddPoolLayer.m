function cnn=cnnAddPoolLayer(cnn, subsamplerate, subsamplemethod)
% cnnAddPoolLayer -
% cnn, subsampling factor, subsampling type. Presently only 'mean'
% subsampling is implemented.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cnn.no_of_layers= cnn.no_of_layers +1;
l=cnn.no_of_layers;
cnn.layers{l}.type = 'p';
cnn.layers{l}.subsample_rate=subsamplerate;
cnn.layers{l}.subsample_method=subsamplemethod;
cnn.layers{l}.no_featuremaps = cnn.layers{l-1}.no_featuremaps;
cnn.layers{l}.featuremap_width = cnn.layers{l-1}.featuremap_width/subsamplerate;
cnn.layers{l}.featuremap_height = cnn.layers{l-1}.featuremap_height/subsamplerate;

% for i=1:cnn.layers{l}.no_featuremaps
%     cnn.layers{l}.featuremaps{i} = zeros(cnn.layers{l}.featuremap_height, cnn.layers{l}.featuremap_width);
% end

    
cnn.layers{l}.act_func='none';
    
