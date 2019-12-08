%==========================================================================
% Add a fully-connected layer
%==========================================================================
% Version: Re-write
% Created By: Zhengyu Chen
% Modified on: 03/17/19
% *************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Zhengyu Chen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cnn = ffcnn(cnn, batch, quantTpye)
% Send data into 1st layer
if cnn.no_of_input_channels > 1 % RGB
    for i = 1 : cnn.no_of_input_channels 
        cnn.layers{1}.featuremaps{i} = batch(:,:,i,:);
    end
else
    cnn.layers{1}.featuremaps{1} = batch; % Gray scale
end
%==========================================================================
% Forward calculation
for l_current = 2 : cnn.no_of_layers
    switch cnn.layers{l_current}.type
% *************************************************************************
% Conv layer
% *************************************************************************
        case 'c'
            i_filter = 0; % (i)th filter
            fMap_sum = 0;
            for j = 1 : cnn.layers{l_current}.no_featuremaps
                fMap = 0; % Feature map
                for k = 1 : cnn.layers{l_current-1}.no_featuremaps
                    i_filter = i_filter +1;
                    % Add convoluted results (matrix) of all channels into one matrix 
                    fMap = fMap + convn(cnn.layers{l_current-1}.featuremaps{k},rot90(cnn.layers{l_current}.K(:,:,i_filter),2),'valid'); %XXX rot90 %cnn.layers{i}.K(:,:,kk),'valid');%rot90(cnn.layers{i}.K(:,:,kk),2),'valid');
    %                 checkvalues(z)
    %                 checkvalues(cnn.layers{i}.K(:,:,kk))
    %                 checkvalues(cnn.layers{i-1}.featuremaps{k})
                end
                if strcmp(cnn.layers{l_current}.act_func, 'soft')
                    cnn.layers{l_current}.featuremaps{j}= exp(fMap + cnn.layers{l_current}.b(j));
                    fMap_sum = fMap_sum + cnn.layers{l_current}.featuremaps{j};
                else
                    cnn.layers{l_current}.featuremaps{j} = applyactfunccnn(fMap + cnn.layers{l_current}.b(j),cnn.layers{l_current}.act_func, 0);
    %                 checkvalues(z+ cnn.layers{i}.b(j))
    %                 checkvalues(cnn.layers{i}.featuremaps{j})
                end
            end
            if strcmp(cnn.layers{l_current}.act_func, 'soft')
                for j = 1 : cnn.layers{l_current}.no_featuremaps
                    cnn.layers{l_current}.featuremaps{j}= cnn.layers{l_current}.featuremaps{j} ./ fMap_sum;                   
                end
            end
            %**************************************************************
            % Quantization
            switch quantTpye
                case 'none'

                case 'round'
                    for j = 1 : cnn.layers{l_current}.no_featuremaps
                        cnn.layers{l_current}.featuremaps{j} = round(cnn.layers{l_current}.featuremaps{j});
                    end
                otherwise
                    error 'not implemented'
            end
            %**************************************************************
            
% *************************************************************************
% Pooling layer
% *************************************************************************
        case 'p'
            stride = cnn.layers{l_current}.subsample_rate;
            switch cnn.layers{l_current}.subsample_method
                case 'mean'
                    h = ones([stride stride]); 
                    h = h./sum(h(:));
                    for k = 1 : cnn.layers{l_current-1}.no_featuremaps % k-> num of prev layer's channel/feature map
                        fMap = convn(cnn.layers{l_current-1}.featuremaps{k}, h, 'valid'); 
                        cnn.layers{l_current}.featuremaps{k} = fMap(1:stride:end, 1:stride:end, :);
                        %**************************************************************
                        % Quantization
                        switch quantTpye
                            case 'none'

                            case 'round'
                                for j = 1 : cnn.layers{l_current}.no_featuremaps
                                    cnn.layers{l_current}.featuremaps{k} = round(cnn.layers{l_current}.featuremaps{k});
                                end
                            otherwise
                                error 'not implemented'
                        end
                        %**************************************************************
    %                     checkvalues(zz);
    %                     checkvalues(cnn.layers{i}.featuremaps{k})
                    end
                case  'max '
                    error 'max pooling not implemented'
%                 h = ones([cnn.layers{i}.subsample_rate cnn.layers{i}.subsample_rate]); %h=h./sum(h(:));
%                 for k=1:cnn.layers{i-1}.no_featuremaps
%                     zz = ordfilt2(cnn.layers{i-1}.featuremaps{k},prod(size(h)),h);
%                     cnn.layers{i}.featuremaps{k} = zz(1:cnn.layers{i}.subsample_rate:end, 1:cnn.layers{i}.subsample_rate:end,:);
% %                     checkvalues(zz);
% %                     checkvalues(cnn.layers{i}.featuremaps{k})
%                 end
                otherwise
                    error 'not implemented'
            end
% *************************************************************************
% FC layer
% *************************************************************************
        case 'f'
            output = [];
            if cnn.layers{l_current-1}.type  ~= 'f'
                for k=1:cnn.layers{l_current-1}.no_featuremaps
                   ss =size(cnn.layers{l_current-1}.featuremaps{k});
                   ss(3) =size(cnn.layers{l_current-1}.featuremaps{k},3);
                   if cnn.input_image_width == 1
                       ss(3) =ss(2);
                       ss(2)=1;
                   end
                   output =[output; reshape(cnn.layers{l_current-1}.featuremaps{k}, ss(1)*ss(2), ss(3))];                   
                end
                cnn.layers{l_current-1}.outputs = output;
%                cnn.layers{l_current}.outputs = applyactfunccnn(cnn.layers{l_current}.W*output + repmat(cnn.layers{l_current}.b, 1, size(output,2)), cnn.layers{l_current}.act_func, 0); 
                cnn.layers{l_current}.outputs = cnn.layers{l_current}.W*output + repmat(cnn.layers{l_current}.b, 1, size(output,2)); 
                %%%%%%%%%%%%%%%%%testing reshaping
%                 sz2=0;
%                 er = zz;
%                 for j=1:cnn.layers{i-1}.no_featuremaps
%                     sz = size(cnn.layers{i-1}.featuremaps{j});
%                     sz1 = sz(1)*sz(2);
%                     test{j} = reshape(er(sz2+1 : sz2+sz1, : ), sz(1), sz(2), sz(3));
%                     sz2 = sz2+sz1;
%                 end
%                 for j=1:cnn.layers{i-1}.no_featuremaps
%                     if ((cnn.layers{i-1}.featuremaps{j}) ~= (test{j}))
%                         error('reshaping error');
%                     end
%                 end
                %%%%%%%%%%%%%%%%%%%
            else
                output = cnn.layers{l_current-1}.outputs;
%                cnn.layers{l_current}.outputs = applyactfunccnn(cnn.layers{l_current}.W*output + repmat(cnn.layers{l_current}.b, 1, size(output,2)), cnn.layers{l_current}.act_func, 0); 
                cnn.layers{l_current}.outputs = cnn.layers{l_current}.W*output + repmat(cnn.layers{l_current}.b, 1, size(output,2));
            end
                %******************************************************
                % Quantization
                switch quantTpye
                    case 'none'

                    case 'round'
 %                       if l_current ~=cnn.no_of_layers
                            cnn.layers{l_current}.outputs = round(cnn.layers{l_current}.outputs);
 %                       end

                    otherwise
                        error 'not implemented'
                end
                %******************************************************               
            cnn.layers{l_current}.outputs = applyactfunccnn(cnn.layers{l_current}.outputs, cnn.layers{l_current}.act_func, 0); 
            if l_current ~=cnn.no_of_layers % because of the leaky relu/rect
                cnn.layers{l_current}.outputs = round(cnn.layers{l_current}.outputs);
            end
        otherwise
            error 'not implemented'
    end                       
end