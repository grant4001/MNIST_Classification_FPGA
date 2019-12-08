%===============================================================================
% Feed forward of trainspose CNN
%===============================================================================
% Version: Re-write
% Creaclcclcted By: Zhengyu Chen
% Modified on: 03/21/19
% ******************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Zhengyu Chen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Tcnn=ffTcnn(Tcnn, noise)
% Send data into 1st layer
if Tcnn.no_of_input_channels > 1 % RGB
    for i = 1 : Tcnn.no_of_input_channels 
        Tcnn.layers{1}.featuremaps{i} = noise(:,:,i,:);
    end
else
    Tcnn.layers{1}.featuremaps{1} = noise; % Gray scale
end
batch_size = size(noise, 3);
%===============================================================================
% Forward calculation
for l_current = 2 : Tcnn.no_of_layers
    switch Tcnn.layers{l_current}.type
% ******************************************************************************
% Trainspose Conv layer
% ******************************************************************************
        case 't'            
            strides = Tcnn.layers{l_current}.strides;   
            padding = Tcnn.layers{l_current}.padding;
            i_filter = 0; % (i)th filter
%             fMap_sum = 0;
            %*******************************************************************
            % Resize the output from fully-connect layer, into 'T-conv'
            % shape
            %
            % [1:9]' =>  1 4 7
            %            2 5 8
            %            3 6 9
            switch Tcnn.layers{l_current-1}.type
                case {'t' 'i', 'b'}
                case 'f'
                    fMap_width = Tcnn.layers{l_current-1}.featuremap_width;
                    Tcnn.layers{l_current-1}.no_featuremaps = ...
                        size(Tcnn.layers{l_current-1}.W, 1)/...
                        (Tcnn.layers{l_current-1}.featuremap_width)^2;                    
                    for i_fMap = 1 : Tcnn.layers{l_current-1}.no_featuremaps
                        Tcnn.layers{l_current-1}.featuremaps{i_fMap} = ...
                            zeros(fMap_width, fMap_width, batch_size);
                        for j_batch = 1 : batch_size
                            Tcnn.layers{l_current-1}.featuremaps{i_fMap}(:,:,j_batch) = ...
                                reshape(Tcnn.layers{l_current-1}.outputs(...
                                (i_fMap-1)*fMap_width^2+1 : i_fMap*fMap_width^2,j_batch), ...
                                fMap_width, fMap_width);
                        end
                    end    
                otherwise
                    error 'not implemented yet'
            end
            % Resize the output from fully-connect layer
            %*******************************************************************

            for j = 1 : Tcnn.layers{l_current}.no_featuremaps
                fMap = 0; 
                for k = 1 : Tcnn.layers{l_current-1}.no_featuremaps
                    i_filter = i_filter +1;
                    % Add convoluted results (matrix) of all channels into one matrix
                    
                    %***********************************************************
                    % Enlarge the previous output/featuremaps
                    %            0 0 0 0 
                    %  x y  ==>  0 x 0 y ==> x 0 y
                    %  z w       0 0 0 0     0 0 0
                    %            0 z 0 w     z 0 w
                    %
                    
                    fMap_prev = Tcnn.layers{l_current-1}.featuremaps{k};
                    sz_fMap_pre = size(fMap_prev,1);
                    batch_size = size(fMap_prev,3);                  
                    input = zeros(sz_fMap_pre,sz_fMap_pre,batch_size);                    
                    for m = strides : strides : strides*sz_fMap_pre
                        for n = strides : strides : strides*sz_fMap_pre
                            input(m,n,:) = fMap_prev(m/strides, n/strides, :);
                        end
                    end
                    % 3.24
                    input_samePd = input;                                  % input for 'same'(padding) case
                    input_validPd = input(strides:end, strides:end, :);    % input for 'same'(valid) case
                    %***********************************************************
                    
                    %***********************************************************
                    % Calculation with different 'padding'
                    switch padding
                        case 'valid' % !! check if it is right instead of using 'full'
%                             fMap = fMap + convn(Tcnn.layers{l_current}.K(:,:,i_filter), ...
%                                 input_validPd, 'full');
                                fMap = fMap + convn(Tcnn.layers{l_current}.K(:,:,i_filter), ...
                                    rot90(input_validPd,0), 'full');
                        case 'same' % XXX
                            fMap = fMap + convn(input_samePd, rot90(Tcnn.layers{l_current}.K(:,:,i_filter),0), ...
                                'same');
                        otherwise
                            error('not implemented')
                    end
                    %******************************************************
                end
                Tcnn.layers{l_current}.featuremaps{j} = applyactfunccnn(fMap + Tcnn.layers{l_current}.b(j), Tcnn.layers{l_current}.act_func, 0, 0);
            end
            
% ******************************************************************************
% Fully-connected layer
% ******************************************************************************      
        case 'f'
            output = [];
            if Tcnn.layers{l_current-1}.type  ~= 'f'
                for k=1 : Tcnn.layers{l_current-1}.no_featuremaps
                   ss =size(Tcnn.layers{l_current-1}.featuremaps{k});
                   ss(3) =size(Tcnn.layers{l_current-1}.featuremaps{k},3);
                   if Tcnn.input_image_width == 1
                       ss(3) =ss(2);
                       ss(2)=1;
                   end
                   output =[output; reshape(Tcnn.layers{l_current-1}.featuremaps{k}, ss(1)*ss(2), ss(3))];                   
                end
                Tcnn.layers{l_current-1}.outputs = output;
                Tcnn.layers{l_current}.outputs = Tcnn.layers{l_current}.W*output ...
                    + repmat(Tcnn.layers{l_current}.b, 1, size(output,2)); 
            else
                error 'error implemented yet'
            end
% ******************************************************************************
% BatchNorm layer
% ******************************************************************************
        case 'b'
            %********************************************************
            % Reshape input into 1-D                                *
            %********************************************************
            X = [];
            %****************************
            % Reshape 'FC' into 'T-conv'*
            %****************************
            %
            % [1:9]' =>  1 4 7
            %            2 5 8
            %            3 6 9
            if strcmp(Tcnn.layers{l_current-1}.type, 'f')
                fMap_width = Tcnn.layers{l_current-1}.featuremap_width;
                Tcnn.layers{l_current-1}.no_featuremaps = ...
                    size(Tcnn.layers{l_current-1}.W, 1)/...
                    (Tcnn.layers{l_current-1}.featuremap_width)^2;                    
                for i_fMap = 1 : Tcnn.layers{l_current-1}.no_featuremaps
                    Tcnn.layers{l_current-1}.featuremaps{i_fMap} = ...
                        zeros(fMap_width, fMap_width, batch_size);
                    for j_batch = 1 : batch_size
                        Tcnn.layers{l_current-1}.featuremaps{i_fMap}(:,:,j_batch) = ...
                            reshape(Tcnn.layers{l_current-1}.outputs(...
                            (i_fMap-1)*fMap_width^2+1 : i_fMap*fMap_width^2,j_batch), ...
                            fMap_width, fMap_width);
                    end
                end
            end
            %****************************
            % Convert fMaps into 1D     *
            %****************************
            %                    
            %  [1 3  '+' [5 7  ==>  [1:8]'
            %   2 4]      6 8]  
            % 
            X = [];
            for i_fMap = 1 : Tcnn.layers{l_current-1}.no_featuremaps
                X_temp = reshape(Tcnn.layers{l_current-1}.featuremaps{i_fMap},[],1);
                X = [X;X_temp];
            end
            Tcnn.layers{l_current}.X = X;

            %********************************************************
            % Batch Nomalization                                    *
            %********************************************************
            gamma = Tcnn.layers{l_current}.gamma;
            beta  = Tcnn.layers{l_current}.beta;           
            [out, mu, vari, X_norm] = batchNorm_forward(X, gamma, beta);
            Tcnn.layers{l_current}.mu = mu;
            Tcnn.layers{l_current}.vari = vari;
            Tcnn.layers{l_current}.X_norm = X_norm;
            %********************************************************
            % Reshap outputs                                        *
            %********************************************************
            if strcmp(Tcnn.layers{l_current+1}.type, 't')
                %************************************************
                % Reshape the output from 1D to 'T-conv' shape
                %                  
                %     [1:8]' ==> [1 3  '+' [5 7
                %                 2 4]      6 8]  
                % 
                fMap_width = Tcnn.layers{l_current}.featuremap_width;
                no_element_fMap = fMap_width^2*batch_size;
                for i_fMap = 1 : Tcnn.layers{l_current}.no_featuremaps          
                    Tcnn.layers{l_current}.featuremaps{i_fMap} = ...
                        zeros(fMap_width, fMap_width, batch_size); % Initilization
                    Tcnn.layers{l_current}.featuremaps{i_fMap} = ...
                        reshape(out((i_fMap-1)*no_element_fMap+1 : i_fMap*no_element_fMap), ...
                        fMap_width, fMap_width,  batch_size);
                       
                end
                %%% test
%                 X2 = []
%                     for i_fMap = 1 : Tcnn.layers{l_current}.no_featuremaps
%                         X2_temp = reshape(Tcnn.layers{l_current}.featuremaps{i_fMap},[],1);
%                         X2 = [X2;X2_temp];
%                     end
%                     xxx = 1;
% 
%                 
                %%% test
            else
                error 'not implemented yet'
            end
% ******************************************************************************
% Other layer
% ******************************************************************************            
        otherwise
            error 'not implemented'
    end
end




