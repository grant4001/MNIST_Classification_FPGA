function cnn=ffcnn(cnn, xx, BITS)
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
    if i == 4
        ggggggggg = 9999
    end
    if cnn.layers{i}.type == 'c'
        kk=0;
        zz=0;
        for j=1:cnn.layers{i}.no_featuremaps
            z = 0; %zeros(size([cnn.layers{i}.featuremap_height cnn.layers{i}.featuremap_width]));
            for k=1:cnn.layers{i-1}.no_featuremaps
                kk = kk +1;
                % Add convoluted results (matrix) of all channels into one matrix 
                z = z + s_quantize(convn(cnn.layers{i-1}.featuremaps{k},rot90(cnn.layers{i}.K(:,:,kk),2),'valid'), BITS); %cnn.layers{i}.K(:,:,kk),'valid');%rot90(cnn.layers{i}.K(:,:,kk),2),'valid');
            end
            if cnn.layers{i}.act_func == 'soft'
                cnn.layers{i}.featuremaps{j}= exp(z + cnn.layers{i}.b(j));
                zz = zz + cnn.layers{i}.featuremaps{j};
            else
                cnn.layers{i}.featuremaps{j} = s_quantize(applyactfunccnn(z+ cnn.layers{i}.b(j),cnn.layers{i}.act_func, 0), BITS);
%                 checkvalues(z+ cnn.layers{i}.b(j))
%                 checkvalues(cnn.layers{i}.featuremaps{j})
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
                    zz = s_quantize(zz, BITS);
                    % Modificaiton needed!!
                    cnn.layers{i}.featuremaps{k} = zz(1:cnn.layers{i}.subsample_rate:end, 1:cnn.layers{i}.subsample_rate:end,:);
%                     checkvalues(zz);
%                     checkvalues(cnn.layers{i}.featuremaps{k})
                end
            elseif cnn.layers{i}.subsample_method == 'max'
                error 'max pooling not implemented'x
%                 h = ones([cnn.layers{i}.subsample_rate cnn.layers{i}.subsample_rate]); %h=h./sum(h(:));
%                 for k=1:cnn.layers{i-1}.no_featuremaps
%                     zz = ordfilt2(cnn.layers{i-1}.featuremaps{k},prod(size(h)),h);
%                     cnn.layers{i}.featuremaps{k} = zz(1:cnn.layers{i}.subsample_rate:end, 1:cnn.layers{i}.subsample_rate:end,:);
%                     checkvalues(zz);
%                     checkvalues(cnn.layers{i}.featuremaps{k})
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
                 zz = s_quantize(zz, BITS);
                cnn.layers{i-1}.outputs = zz;
                
               var = zeros(size(cnn.layers{i}.W, 1), size(zz, 2));
               % MUST CUSTOMIZE MATMUL TO INSERT QUANTIZATION.
                for a = 1:size(cnn.layers{i}.W, 1)
                    for b = 1:size(zz, 2)
                        var(a, b) = 0;
                        cnt = 0;
                        for c = 1:32
                            for d = [1 7 13 19 25 31 2 8 14 20 26 32 3 9 15 21 27 33 4 10 16 22 28 34 5 11 17 23 29 35 6 12 18 24 30 36]
                                var(a, b) = var(a, b) + cnn.layers{i}.W(a, d+36*(c-1)) * zz(d+36*(c-1), b);
                                cnt = cnt + 1;
                                if (mod(cnt, 9) == 0)
                                    var(a, b)=s_quantize(var(a, b),BITS);
                                end
                            end
                        end
                    end
                end
                cnn.layers{i}.outputs = s_quantize(applyactfunccnn(var + repmat(cnn.layers{i}.b, 1, size(zz,2)), cnn.layers{i}.act_func, 0), BITS); 
                
%                  cnn.layers{i}.outputs = applyactfunccnn(cnn.layers{i}.W*zz + repmat(cnn.layers{i}.b, 1, size(zz,2)), cnn.layers{i}.act_func, 0); 
%                  cnn.layers{i}.outputs = s_quantize(cnn.layers{i}.outputs, BITS);

            else
                zz= cnn.layers{i-1}.outputs;
                zz = s_quantize(zz, BITS);
                
                var = zeros(size(cnn.layers{i}.W, 1), size(zz, 2));
                % MUST CUSTOMIZE MATMUL TO INSERT QUANTIZATION.
                for a = 1:size(cnn.layers{i}.W, 1)
                    for b = 1:size(zz, 2)
                        var(a, b) = 0;
                        for c = 1:size(cnn.layers{i}.W, 2)
                            var(a, b) = var(a, b) + cnn.layers{i}.W(a, c) * zz(c, b);
                            if (mod(c, 9) == 0)
                                var(a, b)=s_quantize(var(a, b),BITS);
                            end
                        end
                    end
                end
                cnn.layers{i}.outputs = s_quantize(applyactfunccnn(var + repmat(cnn.layers{i}.b, 1, size(zz,2)), cnn.layers{i}.act_func, 0), BITS); 
                
%                   cnn.layers{i}.outputs = applyactfunccnn(cnn.layers{i}.W*zz + repmat(cnn.layers{i}.b, 1, size(zz,2)), cnn.layers{i}.act_func, 0); 
%                   cnn.layers{i}.outputs = s_quantize(cnn.layers{i}.outputs, BITS);
            end
                
        
    end
    
end