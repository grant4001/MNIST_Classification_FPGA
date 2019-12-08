function cnn=ffcnn(cnn, xx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if cnn.no_of_input_channels > 1
    for i=1:cnn.no_of_input_channels 
        cnn.layers{1}.featuremaps{i}=xx(:,:,i,:);
    end
else
    cnn.layers{1}.featuremaps{1}=xx;
end
for i=2:cnn.no_of_layers
%%    
    if cnn.layers{i}.type == 'c'
        kk=0;
        zz=0;
        for j=1:cnn.layers{i}.no_featuremaps
            z = 0; %zeros(size([cnn.layers{i}.featuremap_height cnn.layers{i}.featuremap_width]));
            for k=1:cnn.layers{i-1}.no_featuremaps
                kk = kk +1;
                % Add convoluted results (matrix) of all channels into one matrix 
                z = z + convn(cnn.layers{i-1}.featuremaps{k},rot90(cnn.layers{i}.K(:,:,kk),2),'valid'); %cnn.layers{i}.K(:,:,kk),'valid');%rot90(cnn.layers{i}.K(:,:,kk),2),'valid');
%                 checkvalues(z)
%                 checkvalues(cnn.layers{i}.K(:,:,kk))
%                 checkvalues(cnn.layers{i-1}.featuremaps{k})
            end
            if cnn.layers{i}.act_func == 'soft'
                cnn.layers{i}.featuremaps{j}= exp(z + cnn.layers{i}.b(j));
                zz = zz + cnn.layers{i}.featuremaps{j};
            else
                cnn.layers{i}.featuremaps{j} = applyactfunccnn(z+ cnn.layers{i}.b(j),cnn.layers{i}.act_func, 0);
                %modified by qc, quantize
                %cnn.layers{i}.featuremaps{j} = round(cnn.layers{i}.featuremaps{j});
%               checkvalues(z+ cnn.layers{i}.b(j))
%               checkvalues(cnn.layers{i}.featuremaps{j})
            end
        end
        if cnn.layers{i}.act_func == 'soft'
            for j=1:cnn.layers{i}.no_featuremaps
                cnn.layers{i}.featuremaps{j}= cnn.layers{i}.featuremaps{j} ./ zz;
            end
        end
        %%
    elseif cnn.layers{i}.type == 'p'
            %% Modificaiton needed!
            if cnn.layers{i}.subsample_method == 'mean'
                h = ones([cnn.layers{i}.subsample_rate cnn.layers{i}.subsample_rate]); h=h./sum(h(:));
                for k=1:cnn.layers{i-1}.no_featuremaps
                    zz = convn(cnn.layers{i-1}.featuremaps{k}, h, 'valid'); %%'same'
                    % Modificaiton needed!!
                    cnn.layers{i}.featuremaps{k} = zz(1:cnn.layers{i}.subsample_rate:end, 1:cnn.layers{i}.subsample_rate:end,:);
%                   %modified by qc, quantize
                    %cnn.layers{i}.featuremaps{k} = round(cnn.layers{i}.featuremaps{k});
%                    checkvalues(zz);
%                    checkvalues(cnn.layers{i}.featuremaps{k})
                end
            elseif cnn.layers{i}.subsample_method == 'max '
                error 'max pooling not implemented'
%                 h = ones([cnn.layers{i}.subsample_rate cnn.layers{i}.subsample_rate]); %h=h./sum(h(:));
%                 for k=1:cnn.layers{i-1}.no_featuremaps
%                     zz = ordfilt2(cnn.layers{i-1}.featuremaps{k},prod(size(h)),h);
%                     cnn.layers{i}.featuremaps{k} = zz(1:cnn.layers{i}.subsample_rate:end, 1:cnn.layers{i}.subsample_rate:end,:);
% %                     checkvalues(zz);
% %                     checkvalues(cnn.layers{i}.featuremaps{k})
%                 end
            end
            %%
    elseif cnn.layers{i}.type == 'f'
            zz=0;
            zz=[];
            if cnn.layers{i-1}.type  ~= 'f'
                for k=1:cnn.layers{i-1}.no_featuremaps
                   ss =size(cnn.layers{i-1}.featuremaps{k});
                   ss(3) =size(cnn.layers{i-1}.featuremaps{k},3);
                   if cnn.input_image_width == 1
                       ss(3) =ss(2);
                       ss(2)=1;
                   end
                   zz =[zz; reshape(cnn.layers{i-1}.featuremaps{k}, ss(1)*ss(2), ss(3))];
                   
                end
                cnn.layers{i-1}.outputs = zz;
                cnn.layers{i}.outputs = applyactfunccnn(cnn.layers{i}.W*zz + repmat(cnn.layers{i}.b, 1, size(zz,2)), cnn.layers{i}.act_func, 0); 
                %modified by qc, quantize
                %cnn.layers{i}.outputs = round(cnn.layers{i}.outputs);
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
                zz= cnn.layers{i-1}.outputs;
                cnn.layers{i}.outputs = applyactfunccnn(cnn.layers{i}.W*zz + repmat(cnn.layers{i}.b, 1, size(zz,2)), cnn.layers{i}.act_func, 0); 
                %modified by qc, quantize
                %cnn.layers{i}.outputs = round(cnn.layers{i}.outputs);
            end
                
        
    end
    
end