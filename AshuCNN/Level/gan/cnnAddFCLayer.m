%==========================================================================
% Add a fully-connected layer
%==========================================================================
% Version: Re-write
% Created By: Zhengyu Chen
% Modified on: 03/17/19
% *************************************************************************
function Tcnn = cnnAddFCLayer(Tcnn, no_of_nodes, activation_func)
% global bit_scale;
%bit_scale = 10;

Tcnn.no_of_layers                   = Tcnn.no_of_layers +1;
l_current                           = Tcnn.no_of_layers;
Tcnn.layers{l_current}.type         = 'f';
Tcnn.layers{l_current}.no_of_nodes  = no_of_nodes;
Tcnn.layers{l_current}.act_func     = activation_func;

if ~strcmp(Tcnn.layers{l_current-1}.type, 'f')
    prev_layer_no_featuremaps                   = Tcnn.layers{l_current-1}.no_featuremaps;
    prev_layer_featuremap_width                 = Tcnn.layers{l_current-1}.featuremap_width;
    prev_layer_featuremap_height                = Tcnn.layers{l_current-1}.featuremap_height;
    Tcnn.layers{l_current}.no_of_inputs         = prev_layer_no_featuremaps * prev_layer_featuremap_height *prev_layer_featuremap_width;
    Tcnn.layers{l_current}.convert_input_to_1D  = 1;
elseif strcmp(Tcnn.layers{l_current-1}.type, 'f')
    Tcnn.layers{l_current}.no_of_inputs         = Tcnn.layers{l_current-1}.no_of_nodes;
    Tcnn.layers{l_current}.convert_input_to_1D  = 0; %already 1D
end

%RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
% Tcnn.layers{l_current}.W =0.5*rand([no_of_nodes Tcnn.layers{l_current}.no_of_inputs]) -0.25;
% Tcnn.layers{l_current}.b = 0.5*rand([no_of_nodes 1]) - 0.25;
%Tcnn.layers{l_current}.W = rand([no_of_nodes Tcnn.layers{l_current}.no_of_inputs]) -0.5;
%Tcnn.layers{l_current}.b = rand([no_of_nodes 1]) - 0.5;


% non-random hard-code weights/bias
if (l_current == 6)
    %CNN
 %   Tcnn.layers{l_current}.W = [0.01,0.05,0.09,0.13;0.02,0.06,0.1,0.14;0.03,0.07,0.11,0.15;0.04,0.08,0.12,0.16];
 % # of channel = 2 
    Tcnn.layers{l_current}.W = [0.01,0.05,0.09,0.13,0.01,0.05,0.09,0.13;0.02,0.06,0.1,0.14,0.02,0.06,0.1,0.14;0.03,0.07,0.11,0.15,0.03,0.07,0.11,0.15;0.04,0.08,0.12,0.16,0.04,0.08,0.12,0.16];

elseif (l_current ==7)
    %CNN
    Tcnn.layers{l_current}.W = [0.01,0.02,0.03,0.04];
elseif (l_current == 4)
    %CONV + FC
    Tcnn.layers{l_current}.W = [0.01,0.03,0.05,0.07,0.09,0.11,0.13,0.15,0.17;0.02,0.04,0.06,0.08,0.1,0.12,0.14,0.16,0.18];
elseif (l_current == 2)
    %TCNN
    Tcnn.layers{l_current}.W = [1,1,1,1;2,2,2,2;3,3,3,3;4,4,4,4];
end
Tcnn.layers{l_current}.b = zeros([no_of_nodes 1]);
%**************************************************************************
% Hardcode weight/bias
% load('z_W_layer6.mat')
% load('z_W_layer7.mat')
% load('z_b_layer6.mat')
% load('z_b_layer7.mat')
% switch l_current
%     case 2
%         load('z_W_l2_1x64.mat')
%         Tcnn.layers{l_current}.W = ans;
%         load('z_b_l2_1x64.mat')
%         Tcnn.layers{l_current}.b = ans;        
% %     case 6
% %         Tcnn.layers{l_current}.W = W_layer6 * 2^bit_scale;
% %         Tcnn.layers{l_current}.b = b_layer6 * 2^bit_scale;
% %     case 7
% %         Tcnn.layers{l_current}.W = W_layer7 * 2^bit_scale;
% %         Tcnn.layers{l_current}.b = b_layer7 * 2^bit_scale;
% end
        
    
Tcnn.layers{l_current}.v_dW          = zeros(Tcnn.layers{l_current}.no_of_nodes, Tcnn.layers{l_current}.no_of_inputs);
Tcnn.layers{l_current}.v_db          = zeros(Tcnn.layers{l_current}.no_of_nodes, 1);
Tcnn.layers{l_current}.S_dW          = 1;
Tcnn.layers{l_current}.S_db          = 1;

    
