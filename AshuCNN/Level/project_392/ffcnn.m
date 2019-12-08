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

function cnn = ffcnn(cnn, batch, type)

% Send data into 1st layer
if cnn.no_of_input_channels > 1 % RGB
    for i = 1 : cnn.no_of_input_channels 
        cnn.layers{1}.featuremaps{i} = batch(:,:,i,:);
    end
else
    sz = size(batch);
    if(type ==1 )
        for i_fMap = 1 : sz(3)
            cnn.layers{1}.featuremaps{i_fMap} = batch(:,:,i_fMap); % Gray scale
        end
    else
        cnn.layers{1}.featuremaps{1} = batch(:,:);
    end
end
%==========================================================================
% Forward calculation
for l_current = 2 : cnn.no_of_layers
    switch cnn.layers{l_current}.type
% *************************************************************************
% FC layer
% *************************************************************************
        case 'f'
            output = [];
            if cnn.layers{l_current-1}.type  ~= 'f'
                for k=1:cnn.layers{l_current-1}.no_featuremaps
                   ss =size(cnn.layers{l_current-1}.featuremaps{k});
                   %ss(3) =size(cnn.layers{l_current-1}.featuremaps{k},3);
                   if cnn.input_image_width == 1
                       ss(3) =ss(2);
                       ss(2)=1;
                   end
                   output =[output, reshape(cnn.layers{l_current-1}.featuremaps{k}, ss(1)*ss(2), 1)]; 
                end
                cnn.layers{l_current-1}.outputs = output;
%               cnn.layers{l_current}.outputs = applyactfunccnn(cnn.layers{l_current}.W*output + repmat(cnn.layers{l_current}.b, 1, size(output,2)), cnn.layers{l_current}.act_func, 0); 
                cnn.layers{l_current}.outputs = cnn.layers{l_current}.W*output + repmat(cnn.layers{l_current}.b, 1, size(output,2)); 
                %cnn.layers{l_current}.outputs = output * cnn.layers{l_current}.W + repmat(cnn.layers{l_current}.b, 1, size(output,2)); 


            else
                output = cnn.layers{l_current-1}.outputs;
%                cnn.layers{l_current}.outputs = applyactfunccnn(cnn.layers{l_current}.W*output + repmat(cnn.layers{l_current}.b, 1, size(output,2)), cnn.layers{l_current}.act_func, 0); 
                cnn.layers{l_current}.outputs = cnn.layers{l_current}.W*output + repmat(cnn.layers{l_current}.b, 1, size(output,2));
            end
                %******************************************************
                % Quantization
%                 switch quantTpye
%                     case 'none'
% 
%                     case 'round'
%  %                       if l_current ~=cnn.no_of_layers
%                             cnn.layers{l_current}.outputs = round(cnn.layers{l_current}.outputs);
%  %                       end
% 
%                     otherwise
%                         error 'not implemented'
%                 end
                %******************************************************               
            cnn.layers{l_current}.outputs = applyactfunccnn(cnn.layers{l_current}.outputs, cnn.layers{l_current}.act_func, 0); 
            if l_current ~=cnn.no_of_layers % because of the leaky relu/rect
%                 cnn.layers{l_current}.outputs = round(cnn.layers{l_current}.outputs);
            end
        otherwise
            error 'not implemented'
    end                       
end