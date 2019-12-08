function Tcnn = trainTcnn(Tcnn, noise, image, no_of_epochs, batch_size, optimizer)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Zhengyu Chen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%**************************************************************************
% Missing control
%**************************************************************************

display 'training started...'
Tcnn.loss_array=[];
n_input = size(image,3);
no_of_batches = n_input/batch_size;

Tcnn.CalcLastLayerActDerivative = 1;
imshow_period = 1;
imshow_cnt = 0;

for i = 1 : no_of_epochs
    for j = 1 : batch_size : n_input
        tStart = tic;
        imshow_cnt = imshow_cnt + 1;
        image_in = image(:, :, j:j+batch_size-1);        
        noise_in = noise(:, :, j:j+batch_size-1);
        
        Tcnn = ffTcnn(Tcnn, noise_in);
        Tcnn = bpTcnn(Tcnn, image_in, 'Tcnn', 0);
        switch optimizer
            case 'gd'
                Tcnn = gradientdescentTcnn(Tcnn);
            case 'mom'
                Tcnn = momentumcnn(Tcnn,0.9);
            case 'adam'
                Tcnn = Adamcnn(Tcnn,0.9, 0.9, 0.01, 10);
            case 'rms'
                Tcnn = RMSprop(Tcnn,0.9,0.01);
            otherwise
                error 'not implemented yet'
        end                
        Tcnn.loss_array = [Tcnn.loss_array Tcnn.loss];
        
        if mod(imshow_cnt,imshow_period) == 0;
            subplot(2,2,1)
            imshow(Tcnn.layers{Tcnn.no_of_layers}.featuremaps{1}(:,:,1)); 
            title('Generated figure')
            
            subplot(2,2,2)
            imshow(image(:,:,1));
            title('Original figure')
            
            subplot(2,2,3)
            plot(Tcnn.loss_array)
            title('Coarse loss')
            grid on;
            
            subplot(2,2,4)
            plot(min(50,Tcnn.loss_array))
            title('Zoom-in loss')
            grid on;
            drawnow;
            
            tElapsed = toc(tStart);            
            tTotoal_left =  (((n_input-j-1)/batch_size + (no_of_epochs-i)*(n_input/batch_size))*tElapsed);
            display([num2str(floor(tTotoal_left/60)),...
            ' min/',num2str(round(tTotoal_left - floor(tTotoal_left/60)*60)),...
            ' s left for training....'])
        end
    end
% plot(1:no_of_epochs*no_of_batches, Tcnn.loss_array)
end
