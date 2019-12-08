function Tcnn = initTcnn(Tcnn, size_of_image, learning_rate)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Zhengyu Chen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tcnn.input_image_height = size_of_image(1);
Tcnn.input_image_width = size_of_image(2);
Tcnn.no_of_input_channels=1;
if numel(size_of_image) == 3
  Tcnn.no_of_input_channels=size_of_image(3);
end
Tcnn.no_of_layers=1;

Tcnn.layers{1}.type = 'i'; %input layer
Tcnn.layers{1}.no_featuremaps = Tcnn.no_of_input_channels;
Tcnn.layers{1}.featuremap_width = Tcnn.input_image_width;
Tcnn.layers{1}.featuremap_height =Tcnn.input_image_height ;
Tcnn.layers{1}.prev_layer_no_featuremaps = 0;

%default parameters
Tcnn.loss_func='auto'; %decide based upon last layer
Tcnn.regularization_const = 0;
Tcnn.learning_rate = learning_rate;
