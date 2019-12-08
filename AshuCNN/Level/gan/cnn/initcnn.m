function cnn=initcnn(cnn, size_of_image, learning_rate)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cnn.input_image_height = size_of_image(1);
cnn.input_image_width = size_of_image(2);
cnn.no_of_input_channels=1;
if numel(size_of_image) == 3
  cnn.no_of_input_channels=size_of_image(3);
end
cnn.no_of_layers=1;
cnn.layers{1} =struct('type', 'i', 'no_featuremaps', cnn.no_of_input_channels);
cnn.layers{1}.type = 'i'; %input layer
cnn.layers{1}.no_featuremaps = cnn.no_of_input_channels;
cnn.layers{1}.featuremap_width = cnn.input_image_width;
cnn.layers{1}.featuremap_height =cnn.input_image_height ;
cnn.layers{1}.prev_layer_no_featuremaps = 0;

%default parameters
cnn.loss_func='auto'; %decide based upon last layer
cnn.regularization_const = 0;
cnn.learning_rate = learning_rate;
