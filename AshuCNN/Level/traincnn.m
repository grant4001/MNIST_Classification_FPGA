function cnn=traincnn(cnn,x,y, no_of_epochs,batch_size)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m=1;
%only images either grayvalues or RGB
m_index=1;
if size(x,4) > 1 %RGB
    m=size(x,4);
    m_index=4; %example index
else
    m=size(x,3);
    m_index=3;
end
no_of_batches = m/batch_size; %should be integer
if rem(m, batch_size) ~=0
    error('no_of_batches should be integer');
end

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

% display 'training started...'
cnn.loss_array=[];
for i=1:no_of_epochs
%     tic
    for j=1:batch_size:m
        if m_index==4
            xx = x(:,:,:,j:j+batch_size-1);
        else
            xx = x(:,:,j:j+batch_size-1);
        end
        yy =y(:,j:j+batch_size-1);
%         yy =y(j:j+batch_size-1);
        cnn = ffcnn(cnn, xx);
        cnn = bpcnn(cnn, yy);
        cnn = gradientdescentcnn(cnn);
        
        cnn.loss_array = [cnn.loss_array cnn.loss]
    end
%     toc
end
plot(1:no_of_epochs*no_of_batches, cnn.loss_array)