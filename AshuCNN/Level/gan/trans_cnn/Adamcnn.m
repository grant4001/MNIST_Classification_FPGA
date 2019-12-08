function cnn = Adamcnn(cnn, Beta_1, Beta_2, epsi, crt_t)
%%%%%%%%%%%%%  created by qc  %%%%%%%%%%%%%%%
% Beta_1 normally have value of 0.9         %
% Beta_2 normally have value of 0.9         %
% epsi  normally have value of 0.01         %
% crt_t =  10                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 2 : cnn.no_of_layers
    if cnn.layers{i}.type == 'f'
         
        sum_sqr_dW = 0;
        sum_sqr_db = 0;
        cnn.layers{i}.v_dW = Beta_1 * cnn.layers{i}.v_dW + (1 - Beta_1) * cnn.layers{i}.dW;
        cnn.layers{i}.v_db = Beta_1 * cnn.layers{i}.v_db + (1 - Beta_1) * cnn.layers{i}.db;
        
        for no_of_nodes = 1 : cnn.layers{i}.no_of_nodes
            for k = 1 : cnn.layers{i}.no_of_inputs
                sum_sqr_dW =  sum_sqr_dW + cnn.layers{i}.dW(no_of_nodes, k) ^ 2 ;
            end
            sum_sqr_db = sum_sqr_db + cnn.layers{i}.db(no_of_nodes, 1) ^ 2 ;
        end 
        mean_sum_sqr_W = sum_sqr_dW / (cnn.layers{i}.no_of_nodes * cnn.layers{i}.no_of_inputs);
        mean_sum_sqr_b = sum_sqr_db / cnn.layers{i}.no_of_nodes;
        cnn.layers{i}.S_dW = Beta_2 * cnn.layers{i}.S_dW + (1 - Beta_2) * mean_sum_sqr_W ;
        cnn.layers{i}.S_db = Beta_2 * cnn.layers{i}.S_db + (1 - Beta_2) * mean_sum_sqr_b ;
        % correcting deviation
        v_dW_crt = cnn.layers{i}.v_dW / (1 - Beta_1 ^ crt_t);
        v_db_crt = cnn.layers{i}.v_db / (1 - Beta_1 ^ crt_t);
        S_dW_crt = cnn.layers{i}.S_dW / (1 - Beta_2 ^ crt_t);
        S_db_crt = cnn.layers{i}.S_db / (1 - Beta_2 ^ crt_t);
        
        S_dW_crt_rt = (S_dW_crt + epsi) ^ 0.5 ;
        S_db_crt_rt = (S_db_crt + epsi) ^ 0.5 ;
        
       
        dW_nor = v_dW_crt(:,:) / S_dW_crt_rt; 
        db_nor = v_db_crt(:)   / S_db_crt_rt;
       
        cnn.layers{i}.W = cnn.layers{i}.W - cnn.learning_rate * dW_nor ;
        cnn.layers{i}.b = cnn.layers{i}.b - cnn.learning_rate * db_nor ;
        % Quantization 
        %cnn.layers{i}.W = quantize_round_clip(cnn.layers{i}.W, paramRange_ori * 2^bit_scale);
        %cnn.layers{i}.b = quantize_round_clip(cnn.layers{i}.b, paramRange_ori * 2^bit_scale);
    
    
    elseif cnn.layers{i}.type == 'c'
        
        kk=0;
        feature_width  = cnn.layers{i}.kernel_width;
        feature_height = cnn.layers{i}.kernel_height;
        sum_sqr_dK = zeros(feature_height, feature_width);
        sum_sqr_db = 0;
        
        for j = 1:cnn.layers{i}.no_featuremaps
            for k = 1:cnn.layers{i-1}.no_featuremaps
                kk = kk +1;
                %Adam optimizer
                cnn.layers{i}.v_dK(:,:,kk) = Beta_1 * cnn.layers{i}.v_dK(:,:,kk) + (1 - Beta_1) * cnn.layers{i}.dK(:,:,kk);
                sum_sqr_dK(:,:) = sum_sqr_dK(:,:) + cnn.layers{i}.dK(:,:,kk) .^ 2;
            end
            cnn.layers{i}.v_db(j) = Beta_1 * cnn.layers{i}.v_db(j) + (1 - Beta_1) * cnn.layers{i}.db(j);
            sum_sqr_db = sum_sqr_db + cnn.layers{i}.db(j) .^ 2;
        end
        
        mean_of_sum_sqr_db = sum_sqr_db / cnn.layers{i}.no_featuremaps;
        mean_of_sum_sqr_dK = sum_sqr_dK / (cnn.layers{i}.no_featuremaps * cnn.layers{i}.prev_layer_no_featuremaps);

        cnn.layers{i}.S_dK = Beta_2 * cnn.layers{i}.S_dK + (1 - Beta_2) * mean_of_sum_sqr_dK ; 
        cnn.layers{i}.S_db = Beta_2 * cnn.layers{i}.S_db + (1 - Beta_2) * mean_of_sum_sqr_db ;
        
        v_dK_crt = cnn.layers{i}.v_dK / (1 - Beta_1 ^ crt_t);
        v_db_crt = cnn.layers{i}.v_db / (1 - Beta_1 ^ crt_t);
        S_dK_crt = cnn.layers{i}.S_dK / (1 - Beta_2 ^ crt_t);
        S_db_crt = cnn.layers{i}.S_db / (1 - Beta_2 ^ crt_t);
        
        S_dK_crt_rt = (S_dK_crt + epsi * ones(feature_height,feature_width)) .^ 0.5 ;
        S_db_crt_rt = (S_db_crt + epsi) .^ 0.5 ;
 
        
        kk = 0 ;
        for j = 1:cnn.layers{i}.no_featuremaps
            for k = 1:cnn.layers{i-1}.no_featuremaps
                kk = kk + 1;
                dK_nor(:,:,kk) = v_dK_crt(:,:,kk) ./ S_dK_crt_rt (:,:);
                cnn.layers{i}.K(:,:,kk) = cnn.layers{i}.K(:,:,kk) -  cnn.learning_rate * dK_nor(:,:,kk) ;
            end
            db_nor(j) = v_db_crt(j) / S_db_crt_rt;
            cnn.layers{i}.b(j) = cnn.layers{i}.b(j) -  cnn.learning_rate * db_nor(j);
        end
        
        % Quantization
        %cnn.layers{i}.K = quantize_round_clip(cnn.layers{i}.K, paramRange_ori * 2^bit_scale);
        %cnn.layers{i}.b = quantize_round_clip(cnn.layers{i}.b, paramRange_ori * 2^bit_scale);
    end
end
