%==========================================================================
% Update weights/bias of trainspose CNN
%==========================================================================
% Version: Re-write
% Creaclcclcted By: Zhengyu Chen
% Modified on: 03/21/19
% *************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Zhengyu Chen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Tcnn = gradientdescentTcnn(Tcnn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i= 2 : Tcnn.no_of_layers
    switch Tcnn.layers{i}.type 
        case 't'
            i_filter=0;
            for j = 1:Tcnn.layers{i}.no_featuremaps
                for k = 1:Tcnn.layers{i-1}.no_featuremaps
                    i_filter = i_filter +1;
                    Tcnn.layers{i}.K(:,:,i_filter) = ...
                        Tcnn.layers{i}.K(:,:,i_filter) -  ...
                        Tcnn.learning_rate * Tcnn.layers{i}.dK(:,:,i_filter);
                end
                Tcnn.layers{i}.b(j) = Tcnn.layers{i}.b(j) -  ...
                    Tcnn.learning_rate*(Tcnn.layers{i}.db(j) );
            end
        case 'f'
            Tcnn.layers{i}.W = Tcnn.layers{i}.W - Tcnn.learning_rate*( Tcnn.layers{i}.dW);
            Tcnn.layers{i}.b = Tcnn.layers{i}.b - Tcnn.learning_rate*( Tcnn.layers{i}.db);
        case 'b'
            Tcnn.layers{i}.gamma = Tcnn.layers{i}.gamma - Tcnn.learning_rate*( Tcnn.layers{i}.dgamma/1);
            Tcnn.layers{i}.beta  = Tcnn.layers{i}.beta  - Tcnn.learning_rate*( Tcnn.layers{i}.dbeta/1);
        otherwise
            error 'not implemented yet'
    end
end