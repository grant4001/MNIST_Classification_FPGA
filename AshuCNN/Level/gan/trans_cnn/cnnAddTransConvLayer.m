%==========================================================================
% Add a convolutional layer
%==========================================================================
% Version: Re-write
% Created By: Zhengyu Chen
% Modified on: 03/16/19
% *************************************************************************
function Tcnn=cnnAddTransConvLayer(Tcnn, n_channel, size_of_kernels, strides, padding, activation_func_name)
% global bit_scale;


Tcnn.no_of_layers                       = Tcnn.no_of_layers + 1;    % Update total num of layer
l_current                               = Tcnn.no_of_layers;        % Current layer number
Tcnn.layers{l_current}.type             = 't';                      % Layer type
Tcnn.layers{l_current}.no_featuremaps   = n_channel;                % Num of channel in Conv layer
Tcnn.layers{l_current}.kernel_width     = size_of_kernels(1);       % Filter size
Tcnn.layers{l_current}.kernel_height    = size_of_kernels(2);       % Filter size
Tcnn.layers{l_current}.strides          = strides;
Tcnn.layers{l_current}.padding          = padding;

switch Tcnn.layers{l_current-1}.type
    case {'t', 'i'}
        prev_layer_no_featuremaps       = Tcnn.layers{l_current-1}.no_featuremaps;   % Previous layer's channel num
        prev_layer_featuremap_width     = Tcnn.layers{l_current-1}.featuremap_width; % Previous layer's filter size
        prev_layer_featuremap_height    = Tcnn.layers{l_current-1}.featuremap_height;
    case 'f'
        prev_layer_no_featuremaps       = size(Tcnn.layers{l_current-1}.W,1)/(Tcnn.layers{l_current-1}.featuremap_width)^2;   % Previous layer's channel num
        prev_layer_featuremap_width     = Tcnn.layers{l_current-1}.featuremap_width; % Previous layer's filter size
        prev_layer_featuremap_height    = Tcnn.layers{l_current-1}.featuremap_width;
    otherwise
        error 'not implemented yet'
end
        


Tcnn.layers{l_current}.prev_layer_no_featuremaps = prev_layer_no_featuremaps;
if numel(size_of_kernels) == 2
    Tcnn.layers{l_current}.kernel_width= size_of_kernels(2);
end
% calculate the length of H based 'strides' and 'padding'
switch padding 
    case 'valid'
        Tcnn.layers{l_current}.featuremap_width = strides*prev_layer_featuremap_width + Tcnn.layers{l_current}.kernel_width - 2;
    case 'same'
        Tcnn.layers{l_current}.featuremap_width = strides*Tcnn.layers{l_current-1}.prev_layer_featuremap_width;
    otherwise
        error(['we did not implement the padding of ',padding])
end
Tcnn.layers{l_current}.featuremap_height = Tcnn.layers{l_current}.featuremap_width;       

% tcnn.layers{l_current}.W = 0.5*rand(tcnn.layers{l_current}.W_height,tcnn.layers{l_current}.W_width)-0.25;
%==========================================================================
% weight/bias initialization
k = 0;
for i = 1 : n_channel
    for j = 1 : prev_layer_no_featuremaps
        k = k + 1;
%         Tcnn.layers{l_current}.K(:,:,k)= 0.5*rand(Tcnn.layers{l_current}.kernel_height, ...
%             Tcnn.layers{l_current}.kernel_width)-0.25;
        Tcnn.layers{l_current}.K(:,:,k)= rand(Tcnn.layers{l_current}.kernel_height, ...
            Tcnn.layers{l_current}.kernel_width)-0.5;

    end
end
% Tcnn.layers{l_current}.b = 0.5*rand([n_channel 1]) - 0.25;
Tcnn.layers{l_current}.b = rand([n_channel 1]) - 0.5;

switch l_current
%     case 2
%         load('z_K_l2_2x2.mat');
%         Tcnn.layers{l_current}.K = ans;
%         load('z_b_l2_2x2.mat');
%         Tcnn.layers{l_current}.b = ans;
    case 3
        load('z_K_l3_1x64.mat');
        Tcnn.layers{l_current}.K = ans;
        load('z_b_l3_1x64.mat');
        Tcnn.layers{l_current}.b = ans;
    case 4
        load('z_K_l4_1x64.mat');
        Tcnn.layers{l_current}.K = ans;
        load('z_b_l4_1x64.mat');
        Tcnn.layers{l_current}.b = ans;
%     case 5
%         load('z_K_l5_2x2.mat');
%         Tcnn.layers{l_current}.K = ans;
%         load('z_b_l5_2x2.mat');
%         Tcnn.layers{l_current}.b = ans;
end
        

Tcnn.layers{l_current}.act_func=activation_func_name;

Tcnn.layers{l_current}.S_dK          = zeros(Tcnn.layers{l_current}.kernel_width, Tcnn.layers{l_current}.kernel_height);
Tcnn.layers{l_current}.S_db          = 0;
Tcnn.layers{l_current}.v_dK          = zeros(Tcnn.layers{l_current}.kernel_width, Tcnn.layers{l_current}.kernel_height, Tcnn.layers{l_current}.no_featuremaps * Tcnn.layers{l_current}.prev_layer_no_featuremaps);
Tcnn.layers{l_current}.v_db          = zeros(1, Tcnn.layers{l_current}.no_featuremaps);

    

    
