clear all
display 'start....'

size=10;%78;

xx = rand(size,size, 100);
yy= round(rand(6,100));

%xx = xx - mean(xx(:));
cnn.namaste=1;

cnn=initcnn(cnn,[size size]);
%  cnn=cnnAddConvLayer(cnn, 6, [7 7], 'tanh'); %cnn, no_of_feature_maps, sizeof(kernels), activation function -'sigm' for sigmoid, 'tanh' for tanh, 'rect' for ReLu, 'soft' for softmax, 'none' for none
%  cnn=cnnAddPoolLayer(cnn, 2, 'mean'); %cnn, subsampling factor
%  cnn=cnnAddConvLayer(cnn, 16, [4 4], 'tanh');
%  cnn=cnnAddPoolLayer(cnn, 3, 'mean');
%  cnn=cnnAddConvLayer(cnn, 32, [3 3], 'tanh');
%  cnn=cnnAddPoolLayer(cnn, 3, 'mean');
% cnn=cnnAddFCLayer(cnn,150, 'tanh' ); %add fully connected layer
% cnn=cnnAddFCLayer(cnn,6, 'none' ); %add fully connected layer

cnn=cnnAddConvLayer(cnn, 3, [5 5], 'plus');
 cnn=cnnAddPoolLayer(cnn, 2, 'mean');

%cnn=cnnAddFCLayer(cnn,10, 'sigm' ); %add fully connected layer
cnn=cnnAddFCLayer(cnn,15, 'tanh' ); %add fully connected layer
cnn=cnnAddFCLayer(cnn,6, 'soft' ); %add fully connected layer

%%%more parameters
%cnn.loss_func = 'cros';

%cnn.loss_func = 'quad'; 
no_of_epochs = 3;
batch_size=20;
% cnn=traincnn(cnn,xx,yy, no_of_epochs,batch_size);
% pause
if cnn.loss_func == 'auto'
   cnn.loss_func = 'quad'; %quadtratic
   if cnn.layers{cnn.no_of_layers}.act_func == 'sigm'
       cnn.loss_func = 'cros' ; %cross_entropy';
   elseif cnn.layers{cnn.no_of_layers}.act_func == 'tanh'
       cnn.loss_func = 'quad';
   
       
   end
elseif strcmp(cnn.loss_func, 'cros') == 1 & strcmp(cnn.layers{cnn.no_of_layers}.act_func, 'sigm') == 0
    display 'Not tested for gradient checking for cross entropy cost function other than sigm layer'
end

cnn.CalcLastLayerActDerivative =1;
if cnn.loss_func == 'cros' 
    if cnn.layers{cnn.no_of_layers}.act_func == 'soft'
        cnn.CalcLastLayerActDerivative =0;
    elseif cnn.layers{cnn.no_of_layers}.act_func == 'sigm'
        cnn.CalcLastLayerActDerivative =0;
    end    
end

if cnn.layers{cnn.no_of_layers}.act_func == 'none'
    cnn.CalcLastLayerActDerivative =0;
end

cnn=ffcnn(cnn, xx);
%sum(cnn.layers{cnn.no_of_layers}.outputs,1)
cnn=bpcnn(cnn,yy);
gradient_checker(cnn, xx, yy);
display '..checked.'