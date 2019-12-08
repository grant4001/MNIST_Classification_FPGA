function cnnAddActLayer(cnn, activation_func_name)
cnn.no_of_layers= cnn.no_of_layers +1;
l=cnn.no_of_layers;
cnn.layers{l}.type = 'a';
cnn.layers{l}.act_func=activation_func_name;
cnn.layers{l}.no_featuremaps = cnn.layers{l-1}.no_featuremaps;

    

    
