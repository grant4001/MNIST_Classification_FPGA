%===============================================================================
% Version:      Tranposed CNN Test
% Created By:   Sihua Fu, Qiankai Cao, Zhengyu Chen
% Created on:   03/19/19
% Modified on:  03/20/19
% ******************************************************************************
% Current   1.
% Reuslt:
% ******************************************************************************
% Remaining 1.
% Issues:
% ******************************************************************************
%  Note:    1. Download MNIST dataset from http://yann.lecun.com/exdb/mnist/
%           2. Store in a folder /directory named MNIST
% ******************************************************************************
close all;
clear all;

%===============================================================================
% Parameters
%===============================================================================
% global bit_scale;
dataPath                = './MNIST/';
batch_size              = 50;       % 100
n_shrinkData_train      = 1;
n_shrinkData_test       = 10;
n_epoch                 = 1;
input_enlarge           = 1;        % Increase value of input(image)
% bit_scale               = 10;       % (bit_scale-2) of integer bit
learning_rate           = 0.00015 * 10;    % 0.001 for case I
digit_sel               = 1;
train_identical         = 1;
noise_identical         = 0;
noise_hardcode          = 0;        % hardcode noise
noise_height            = 64;       % 64
noise_width             = 1;        % 1
optimizer               = 'gd';     % 'gd', 'mom', 'adam', 'rms', 
loss_func               = 'cros';   % 'auto', 'cros'
imshow_period           = 10;

%===============================================================================
% Read database                 
%===============================================================================
% [train_img, train_label, test_img, test_label] = readMNIST(dataPath, ...
%     1, n_shrinkData_test);
load('z_train_img.mat');
load('z_train_label.mat');
load('z_test_img.mat');
load('z_test_label.mat');
%********************************
% Quantize input                *
%********************************
train_img   = round(train_img);
test_img    = round(test_img);
train_img   = train_img*input_enlarge;
test_img    = test_img*input_enlarge;
%********************************
% Modify input image and noise  *
%********************************
k_cnt = 1;
% Selct the image with chosen digit
for i = 1 : size(train_img,3)
    if train_label(digit_sel+1,i) == 1
        train_img_sel(:,:,k_cnt) = train_img(:,:,i);
        k_cnt = k_cnt+1;
    end   
end
train_img_sel = train_img_sel(:,:,1:5000); 
train_img_sel = repmat(train_img_sel,[1,1,12]);
if train_identical == 1
    train_img_sel = repmat(train_img_sel(:,:,1),[1,1,60000]); % Identical train data
end
train_img_sel = train_img_sel(:, :, 1:60000/n_shrinkData_train);
train_img = train_img(:, :, 1 : 60000/n_shrinkData_train);
% Random noise
if noise_identical == 1
    if noise_hardcode == 1
%         load('z_noise_2x2.mat')
        load('z_noise_1x64.mat')
        noise = repmat(ans, [1,1,size(train_img_sel,3)]); % Identical noise
    else
        noise = repmat(rand(noise_width,noise_height), [1,1,size(train_img_sel,3)]); % Identical noise
    end
else
    noise = rand(noise_width,noise_height,size(train_img_sel,3));          % Random noise
end
h_noise = noise_width;
w_noise = noise_height;

%********************************
% Normalize noise               *
%********************************
% mu_noise  = mean(reshape(noise,1,[]));
% std_noise = std(reshape(noise,1,[]));
% noise = (noise-mu_noise)./std_noise;

%===============================================================================
% Main                                                                        ||
%===============================================================================

%********************************
% Build GAN architecture        *
%********************************

%***************************************************************************
% Disctriminator/ CNN
cnn.namaste = 1;            % just intiationg cnn object
cnn = initcnn(cnn,[28 28],learning_rate);

cnn = cnnAddConvLayer(cnn, 40, [5 5], 'rect');
cnn = cnnAddPoolLayer(cnn, 2, 'mean');
cnn = cnnAddConvLayer(cnn, 40, [5 5], 'rect');
cnn = cnnAddPoolLayer(cnn, 2, 'mean');
cnn = cnnAddFCLayer(cnn,32, 'rect'); 
cnn = cnnAddFCLayer(cnn,1, 'sigm'); % XXXXX 10->1
%***************************************************************************


%***************************************************************************
% Disctriminator/ CNN
Tcnn.namaste = 1; % just intiationg cnn object
Tcnn=initTcnn(Tcnn,[h_noise w_noise], learning_rate);
Tcnn.loss_func = loss_func;
%%% D-1
% fMap_w = 5;
% Tcnn = cnnAddFCLayer(Tcnn, fMap_w*fMap_w*40, 'rect'); % 
% Tcnn.layers{Tcnn.no_of_layers}.featuremap_width = fMap_w;
% Tcnn = cnnAddTransConvLayer(Tcnn, 40, [5 5], 2, 'valid','rect');
% Tcnn = cnnAddTransConvLayer(Tcnn, 1, [4 4], 2, 'valid','sigm');


%%% D-II
fMap_w = 5;

Tcnn = cnnAddFCLayer(Tcnn, fMap_w*fMap_w*40, 'rect'); % 
Tcnn.layers{Tcnn.no_of_layers}.featuremap_width = fMap_w;
Tcnn = cnnAddBatchNormLayer(Tcnn);
Tcnn = cnnAddTransConvLayer(Tcnn, 40, [5 5], 2, 'valid','rect');
Tcnn = cnnAddBatchNormLayer(Tcnn);
Tcnn = cnnAddTransConvLayer(Tcnn, 1, [4 4], 2, 'valid','sigm');
%***************************************************************************

% train_x = x; % random targets
% train_x = repmat(x(:,:,1),[1,1,10000]); % identical targets
% imshow(train_x(:,:,randi(1000,1)));   
% no_test = 1000;

iteration = 1;
% train_x = train_x(:,:,1:no_test*batch_size);
% initialize cnn
display 'training started...'

train_D_y(1:batch_size) = zeros(batch_size,1); % Target score for fake images(from generator)
train_D_y(batch_size+1:2*batch_size) = ones(batch_size,1);% Target score for real images
% parpool(2)
figure;
hold on;
tic
Tcnn.loss_array_gan=[];
cnn.loss_array_gan=[];
train_g = 1;
train_d = 1;
imshow_cnt = 0;
for j = 1 : iteration
    display(['iteration ',num2str(j)])
    for i = 1 : size(train_img_sel,3)/batch_size
    tstart = tic;
    imshow_cnt = imshow_cnt+1;

        noise_in(:,:,1:batch_size) =noise(:,:,(i-1)*batch_size+1 : i*batch_size);

        %%% ++++++++ Train D ++++++++++++++++
        %
        %   |-----|     |-----|
        %   |  G  | ==> |image|
        %   |-----|     |-----|
        % 
        Tcnn = ffTcnn(Tcnn, noise_in); % Generate images from G
        image_intl = Tcnn.layers{Tcnn.no_of_layers}.featuremaps{1};
        train_D_x = zeros(28,28,batch_size*2);
        train_D_x(:,:,1:batch_size) = image_intl; % Images from generator/T-CNN
        train_D_x(:,:,batch_size+1:2*batch_size) = train_img_sel(:,:,(i-1)*batch_size+1 : i*batch_size);  % Images from database
        %   |-----|     |-----|
        %   |image| ==> |  D  |
        %   |-----|     |-----|
        %                update                     
        cnn = traincnn(cnn, train_D_x, train_D_y, 1, batch_size*2, optimizer, train_d);
        score_fake = cnn.layers{cnn.no_of_layers}.outputs(1:batch_size);
        score_real = cnn.layers{cnn.no_of_layers}.outputs(batch_size+1:2*batch_size);
        
        
        loss_d_fake = crossEntropy(score_fake, zeros(size(score_fake)), 'mean');
        loss_d_real = crossEntropy(score_real, ones(size(score_fake)),  'mean');
        loss_d = 0.5 * (loss_d_fake + loss_d_real);
        loss_g = crossEntropy(score_fake, ones(size(score_fake)), 'mean');
        cnn.loss_array_gan = [cnn.loss_array_gan loss_d];
        Tcnn.loss_array_gan = [Tcnn.loss_array_gan loss_g];
        
        %%% ++++++++ Train G ++++++++++++++++
        train_G_y = ones(1,batch_size);    
        %
        %   |-----|     |-----|     |-----|
        %   |  G  | ==> |image| ==> |  D  |
        %   |-----|     |-----|     |-----|
        %   
        
        cnn = ffcnn(cnn, image_intl,'none');
        %
        %   |-----|     |-----|     |-----|
        %   |  G  | <== |image| <== |  D  |
        %   |-----|     |-----|     |-----|
        %    update                   fix    
        cnn = bpcnn(cnn,train_G_y,1);
        % Modification needed!
        er = cnn.layers{1}.er{1}; % check the error from cnn
        Tcnn = bpTcnn(Tcnn, 0, 'gan', er);
        if train_g 
            switch optimizer
                case 'gd'
                    Tcnn = gradientdescentTcnn(Tcnn);
                case 'mom'
                    Tcnn = momentumcnn(Tcnn,0.9);
                case 'adam'
                    Tcnn = AdamTcnn(Tcnn,0.9, 0.9, 0.01, 10);
                case 'rms'
                    Tcnn = RMSpropcnn(Tcnn,0.9,0.01);
                otherwise
                    error 'not implemented yet'
            end
        else
            fprintf(2,'generator not train\n\n')
        end

        
        %********************************
        % Check strength NN             *
        %********************************
        if Tcnn.loss_array_gan(end) * 1.5 < cnn.loss_array_gan(end)
            train_g = false;
        else
            train_g = true;
        end
        
        if cnn.loss_array_gan(end) *2 < Tcnn.loss_array_gan(end)
            train_d = false;
        else
            train_d = true;
        end
        if mod(imshow_cnt,imshow_period) == 0
            subplot(2,2,1)
            plot(cnn.loss_array_gan);
            title('Discriminator Loss')
            subplot(2,2,2)
            plot(Tcnn.loss_array_gan);
            title('Generator Loss')
            subplot(2,2,3)
            imshow(Tcnn.layers{Tcnn.no_of_layers}.featuremaps{1}(:,:,1));
            subplot(2,2,4)
            imshow(train_D_x(:,:,batch_size+1));
            drawnow;
        
            fprintf(['loss of generator: ' ,num2str(Tcnn.loss_array_gan(end)),'; loss of discriminator: ', num2str(cnn.loss_array_gan(end)),'\n'])


            tElapsed = toc(tstart);            
            tTotoal_left =  (((size(train_img,3)/batch_size - i) + (iteration-j)*(size(train_img,3)/batch_size))*tElapsed);
            display([num2str(floor(tTotoal_left/60)),...
            ' min/',num2str(round(tTotoal_left - floor(tTotoal_left/60)*60)),...
            ' s left for training....'])
        end
    end
end

toc
%         display(['loss_G = ', num2str(Tcnn.loss)])    

% imshow(Tcnn.layers{5}.H(:,:,1));
% imshow(train_x(:,:,randi(1000,1)));
