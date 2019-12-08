function  cnn = RMSprop(cnn, Beta, epsi)
 
% original parameter range 
for i = 2 : cnn.no_of_layers
    if cnn.layers{i}.type == 'f'
        dW_nor = [];
        for k = 1 : cnn.layers{i}.no_of_inputs
            cnn.layers{i}.S_dW(k) = Beta * cnn.layers{i}.S_dW(k) + (1 - Beta) * mean(cnn.layers{i}.dW(:,k) .^ 2) ;
        end 
        cnn.layers{i}.S_db = Beta * cnn.layers{i}.S_db + (1 - Beta) * mean(cnn.layers{i}.db .^ 2) ; 
        S_dW_rt = (cnn.layers{i}.S_dW + epsi * ones(1 , cnn.layers{i}.no_of_inputs)) .^ 0.5 ;
        S_db_rt = (cnn.layers{i}.S_db + epsi * ones(1 , cnn.layers{i}.no_of_inputs)) .^ 0.5 ;

        for no_of_inputs = 1 : cnn.layers{i}.no_of_inputs
            dW_nor = [dW_nor, cnn.layers{i}.dW(:,no_of_inputs) / S_dW_rt(1,no_of_inputs)];
        end 
        db_nor = cnn.layers{i}.db / S_db_rt(1,no_of_inputs);
       
        cnn.layers{i}.W = cnn.layers{i}.W - cnn.learning_rate* dW_nor ;
        cnn.layers{i}.b = cnn.layers{i}.b - cnn.learning_rate* db_nor ;
        % Quantization 
        %cnn.layers{i}.W = quantize_round_clip(cnn.layers{i}.W, paramRange_ori * 2^bit_scale);
        %cnn.layers{i}.b = quantize_round_clip(cnn.layers{i}.b, paramRange_ori * 2^bit_scale);
    
    
    elseif cnn.layers{i}.type == 'c'
        
        kk=0;
        feature_width  = cnn.layers{i}.kernel_width;
        feature_height = cnn.layers{i}.kernel_height;
        sum_sqr_K = zeros(feature_height,feature_width, cnn.layers{i}.prev_layer_no_featuremaps * cnn.layers{i}.no_featuremaps);
        sum_sqr_b = zeros(1,cnn.layers{i}.no_featuremaps);
        
        for j = 1:cnn.layers{i}.no_featuremaps
            for k = 1:cnn.layers{i-1}.no_featuremaps
                kk = kk +1;
                %RMSprop optimizer
                sum_sqr_K(:,:,kk) = sum_sqr_K(:,:,kk) + cnn.layers{i}.dK(:,:,kk) .^ 2;
            end
            sum_sqr_b(j) = sum_sqr_b(j) + cnn.layers{i}.db(j) .^ 2;
        end
        mean_of_sum_sqr_b = sum_sqr_b / cnn.layers{i}.no_featuremaps;
        
        mean_of_sum_sqr_K = (sum_sqr_K / (cnn.layers{i}.no_featuremaps * cnn.layers{i}.prev_layer_no_featuremaps));
       
        
        cnn.layers{i}.S_dK = Beta * cnn.layers{i}.S_dK + (1 - Beta) * mean_of_sum_sqr_K ; 
        cnn.layers{i}.S_db = Beta * cnn.layers{i}.S_db + (1 - Beta) * mean_of_sum_sqr_b ;
        
        S_dK_rt = (cnn.layers{i}.S_dK + epsi * ones(feature_height,feature_width)) .^ 0.5 ;
        S_db_rt = (cnn.layers{i}.S_db + epsi) .^ 0.5 ;
 
        
        kk = 0 ;
        for j = 1:cnn.layers{i}.no_featuremaps
            for k = 1:cnn.layers{i-1}.no_featuremaps
                kk = kk + 1 ;
                dK_nor(:,:,kk) = cnn.layers{i}.dK(:,:,kk) ./ S_dK_rt(:,:,kk) ;
                cnn.layers{i}.K(:,:,kk) = cnn.layers{i}.K(:,:,kk) -  cnn.learning_rate * dK_nor(:,:,kk) ;
            end
            db_nor(j) = cnn.layers{i}.db(j) / S_db_rt(j);
            cnn.layers{i}.b(j) = cnn.layers{i}.b(j) -  cnn.learning_rate * db_nor(j) ;
        end
        
        % Quantization
        %cnn.layers{i}.K = quantize_round_clip(cnn.layers{i}.K, paramRange_ori * 2^bit_scale);
        %cnn.layers{i}.b = quantize_round_clip(cnn.layers{i}.b, paramRange_ori * 2^bit_scale);
    end
end


