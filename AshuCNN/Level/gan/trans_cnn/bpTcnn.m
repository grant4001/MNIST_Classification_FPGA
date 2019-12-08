%==========================================================================
% Back propagate of trainspose CNN
%==========================================================================
% Version: Re-write
% Creaclcclcted By: Zhengyu Chen
% Modified on: 03/21/19
% *************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Zhengyu Chen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Tcnn = bpTcnn(Tcnn, image_in, application, er_gan)

switch application
    case 'Tcnn'
        er = Tcnn.layers{Tcnn.no_of_layers}.featuremaps{1} - image_in;
    case 'gan'
        er = er_gan;
    otherwise
        error 'not implemented yet'
end

batch_size = size(image_in, 3);
% Layer 2 -> n
for l_current = (Tcnn.no_of_layers) : -1 : 2
    if strcmp(Tcnn.layers{l_current}.type, 't')
        strides = Tcnn.layers{l_current}.strides;
        padding = Tcnn.layers{l_current}.padding;
    end
    if (l_current ~= Tcnn.no_of_layers) && strcmp(Tcnn.layers{l_current+1}.type, 't')
        strides_pos = Tcnn.layers{l_current+1}.strides;
    end    
    %**********************************************************************
    % Back propagate the error
    if l_current == Tcnn.no_of_layers % Error of the last layer 
        if Tcnn.loss_func == 'cros' %cross_entropy'
            if Tcnn.layers{Tcnn.no_of_layers}.act_func == 'sigm'
                eps = 1e-12;
                Tcnn.CalcLastLayerActDerivative = 0;
                er1 = -1.*sum((image_in.*log(Tcnn.layers{Tcnn.no_of_layers}.featuremaps{1}+eps) + (1-image_in).*log(1-Tcnn.layers{Tcnn.no_of_layers}.featuremaps{1}+eps)), 1);
            else
                error('cross entropy is implemented only when last layer is sigmoid');
            end
                Tcnn.loss = sum(er1(:))/size(er1,2); %loss over all examples

        else
            er1 = er.^2;
            Tcnn.loss = sum(er1(:))/(2*size(er1,2)); %loss over all examples

        end
        if Tcnn.CalcLastLayerActDerivative == 1
            Tcnn.layers{l_current}.er{1} = applyactfunccnn(Tcnn.layers{Tcnn.no_of_layers}.featuremaps{1}, ...
                Tcnn.layers{l_current}.act_func, 1, er);
        else
            Tcnn.layers{l_current}.er{1} =  er;
        end
    else % Error of the rest layers 
        % size of error_temp: strides*SZ(fMap_pre) + SZ(K) - 1 -(strides-1)
        %  = SZ(fMap_current)
        %
        % modified at 3.24 by zc
        sz_fMap = size(Tcnn.layers{l_current}.featuremaps{1});
        sz_er_temp = sz_fMap(1)*strides_pos - (strides_pos-1);
        for k = 1 : Tcnn.layers{l_current}.no_featuremaps
            Tcnn.layers{l_current}.er{k}=zeros(sz_er_temp, sz_er_temp, sz_fMap(3));
        end
        er = Tcnn.layers{l_current+1}.er;
        i_filter1 = 0;
        for j = 1 : Tcnn.layers{l_current+1}.no_featuremaps
            for k = 1 : Tcnn.layers{l_current}.no_featuremaps
                i_filter1 = i_filter1 + 1;               
                % Different padding
                switch padding
                    case 'valid'
                        Tcnn.layers{l_current}.er{k} = Tcnn.layers{l_current}.er{k} ...
                        + convn(er{j}, rot90(Tcnn.layers{l_current+1}.K(:,:,i_filter1),2), 'valid'); % XXX                        
                    otherwise
                        error 'not implemented yet'
                end
            end
        end
        for i = 1 : Tcnn.layers{l_current}.no_featuremaps
            %**************************************************************
            % Shrink error due to strides effect
            %  x 0 y  =>  x y
            %  0 0 0      z w
            %  z 0 w
            %
            % modified at 3.24 by zc
            
            er_original = Tcnn.layers{l_current}.er{i};
            sz_er_ori = size(er_original,1);
            sz_er_ori = sz_er_ori + (strides -1);
%            batch_size = size(er_original,3);
            er_shrink = zeros(sz_er_ori/strides_pos, sz_er_ori/strides_pos, batch_size);
            for m = 1: 1 : sz_er_ori/strides_pos
                for n =  1: 1 : sz_er_ori/strides_pos
                    er_shrink(m,n,:) = er_original(m*strides_pos-(strides-1), n*strides_pos-(strides-1), :);
                end
            end   
            Tcnn.layers{l_current}.er{i} = applyactfunccnn(Tcnn.layers{l_current}.featuremaps{i}, ...
                Tcnn.layers{l_current}.act_func,1, er_shrink);
        end
    end
    % Back propagate the error
    %**********************************************************************
    
    %**********************************************************************
    % Calculate dK,db
    switch  Tcnn.layers{l_current}.type        
        % ******************************************************************************
        % Trainspose Conv layer
        % ******************************************************************************
        case 't'
            switch padding 
                case 'valid'
                    i_filter2 = 0;
                    for i_dK = 1 : Tcnn.layers{l_current}.no_featuremaps
                        for j_dK = 1 : Tcnn.layers{l_current-1}.no_featuremaps
                            %******************************************************
                            % Enlarge the previous output/featuremaps
                            %            0 0 0 0 
                            %  x y  ==>  0 x 0 y ==> x 0 y
                            %  z w       0 0 0 0     0 0 0
                            %            0 z 0 w     z 0 w
                            %
                            fMap_prev = Tcnn.layers{l_current-1}.featuremaps{j_dK};
                            sz_fMap_pre = size(fMap_prev,1);
                            batch_size = size(fMap_prev,3);
                            input = zeros(sz_fMap_pre*strides,sz_fMap_pre*strides,batch_size);                    
                            for m = strides : strides : strides*sz_fMap_pre
                                for n = strides : strides : strides*sz_fMap_pre
                                    input(m,n,:) = fMap_prev(m/strides, n/strides, :);
                                end
                            end
                            % 3.24
                            input = input(strides:end, strides:end, :);                            
                            %******************************************************

                            dK_temp = convn(Tcnn.layers{l_current}.er{i_dK}, ...
                                rot90(input,2), 'valid');       % XXX
                            i_filter2 = i_filter2 + 1;
                            Tcnn.layers{l_current}.dK(:,:,i_filter2) = ...
                            dK_temp./size(Tcnn.layers{l_current}.er{i_dK},3); % Mean
                        end
                        % XXX check if it's right with strides>1 case!!
                        Tcnn.layers{l_current}.db(i_dK) = ...
                            sum(Tcnn.layers{l_current}.er{i_dK}(:))/size(Tcnn.layers{l_current}.er{i_dK},3);
                    end
                otherwise
                    error 'not inplemented yet'
            end 
        % ******************************************************************************
        % Fully-connecte layer
        % ******************************************************************************
        case 'f'    
            if strcmp(Tcnn.layers{l_current+1}.type, 't')
                %***************************************************************
                % Resize the error from t-conv layer
                %
                %  1 4 7
                %  2 5 8  => [1:9,1] 
                %  3 6 9
                fMap_width = Tcnn.layers{l_current}.featuremap_width;
                er_original = Tcnn.layers{l_current}.er; % Record the un-reshaped error
                Tcnn.layers{l_current}.er = cell(1,1);                 
                Tcnn.layers{l_current}.er{1} = ...
                    zeros(Tcnn.layers{l_current}.no_of_nodes,batch_size); % re-initilize the error
                for i_fMap = 1 :  Tcnn.layers{l_current}.no_featuremaps
                    for j_batch = 1 : batch_size
                        Tcnn.layers{l_current}.er{1}( ...
                            (i_fMap-1)*fMap_width^2+1:i_fMap*fMap_width^2,j_batch) = ...
                            reshape(er_original{i_fMap}(:,:,j_batch),fMap_width^2,1);                    
                    end
                end
                % Concert error from matrix to vector
                %***************************************************************
                
                Tcnn.layers{l_current}.dW = Tcnn.layers{l_current}.er{1} * ( Tcnn.layers{l_current-1}.outputs)' / size(Tcnn.layers{l_current}.er{1}, 2);
                Tcnn.layers{l_current}.db = mean( Tcnn.layers{l_current}.er{1}, 2);
                
                
                
                
            else
                error 'not implemented yet'
            end
        otherwise
            error 'not implemented yet'
    end            
    % Calculate dK,db
    %**********************************************************************
end

