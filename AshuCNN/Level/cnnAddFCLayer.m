function cnn=cnnAddFCLayer(cnn, no_of_nodes, activation_func)
%cnnAddFCLayer - Add fully connected neural network layer
% cnn, no of NN nodes, activation function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cnn.no_of_layers= cnn.no_of_layers +1;
l=cnn.no_of_layers;
cnn.layers{l}.type = 'f';
cnn.layers{l}.no_of_nodes=no_of_nodes;
cnn.layers{l}.act_func=activation_func;

prev_layer_featuremap_width=cnn.input_image_width;
prev_layer_featuremap_height=cnn.input_image_height;
prev_layer_no_featuremaps = cnn.no_of_input_channels;
cnn.layers{l}.no_of_inputs = prev_layer_no_featuremaps * prev_layer_featuremap_height *prev_layer_featuremap_width;
cnn.layers{l}.convert_input_to_1D=1;
if l>1 & cnn.layers{l-1}.type ~= 'f'
    prev_layer_no_featuremaps = cnn.layers{l-1}.no_featuremaps;
    prev_layer_featuremap_width = cnn.layers{l-1}.featuremap_width;
    prev_layer_featuremap_height = cnn.layers{l-1}.featuremap_height;
    cnn.layers{l}.no_of_inputs = prev_layer_no_featuremaps * prev_layer_featuremap_height *prev_layer_featuremap_width;
    cnn.layers{l}.convert_input_to_1D=1;
elseif l>1 & cnn.layers{l-1}.type == 'f'
    cnn.layers{l}.no_of_inputs = cnn.layers{l-1}.no_of_nodes;
    cnn.layers{l}.convert_input_to_1D=0; %already 1D
end
%RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
cnn.layers{l}.W =0.5*rand([no_of_nodes cnn.layers{l}.no_of_inputs]) -0.25;
%cnn.layers{l}.b = 0.5*rand([no_of_nodes 1]) - 0.25;
%modified by qc, quantize
 %cnn.layers{l}.W = 32*rand([no_of_nodes cnn.layers{l}.no_of_inputs]) - 16;
 %cnn.layers{l}.W = round(cnn.layers{l}.W );
 cnn.layers{l}.b = 0.5*rand([no_of_nodes 1]) - 0.25;
 %cnn.layers{l}.b = round(cnn.layers{l}.b);


    

    
