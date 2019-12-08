function Tcnn = Adamcnn(Tcnn, Beta_1, Beta_2, epsi, crt_t)
%%%%%%%%%%%%%  created by qc  %%%%%%%%%%%%%%%
% Beta_1 normally have value of 0.9         %
% Beta_2 normally have value of 0.99        %
%  epsi  normally have value of e-8         %
% crt_t = 10                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 2 : Tcnn.no_of_layers
    if Tcnn.layers{i}.type == 'f'
         
        dW_nor = [];
        Tcnn.layers{i}.v_dW = Beta_1 * Tcnn.layers{i}.v_dW + (1 - Beta_1) * Tcnn.layers{i}.dW;
        Tcnn.layers{i}.v_db = Beta_1 * Tcnn.layers{i}.v_db + (1 - Beta_1) * Tcnn.layers{i}.db;
        for k = 1 : Tcnn.layers{i}.no_of_inputs
            Tcnn.layers{i}.S_dW(1,k) = Beta_2 * Tcnn.layers{i}.S_dW(1,k) + (1 - Beta_2) * mean(Tcnn.layers{i}.dW(:,k) .^ 2) ;
        end 
        Tcnn.layers{i}.S_db = Beta_2 * Tcnn.layers{i}.S_db + (1 - Beta_2) * mean(Tcnn.layers{i}.db .^ 2) ;
        % correcting deviation
        v_dW_crt = Tcnn.layers{i}.v_dW / (1 - Beta_1 ^ crt_t);
        v_db_crt = Tcnn.layers{i}.v_db / (1 - Beta_1 ^ crt_t);
        S_dW_crt = Tcnn.layers{i}.S_dW / (1 - Beta_2 ^ crt_t);
        S_db_crt = Tcnn.layers{i}.S_db / (1 - Beta_2 ^ crt_t);
        
        S_dW_rt = (S_dW_crt + epsi * ones(1 , Tcnn.layers{i}.no_of_inputs)) .^ 0.5 ;
        S_db_rt = (S_db_crt + epsi * ones(Tcnn.layers{i}.no_of_nodes, 1)) .^ 0.5 ;

        for no_of_inputs = 1 : Tcnn.layers{i}.no_of_inputs
            dW_nor = [dW_nor, v_dW_crt(:,no_of_inputs) / S_dW_rt(1,no_of_inputs)];
        end 
        db_nor = v_db_crt / S_db_rt(Tcnn.layers{i}.no_of_nodes, 1);
       
        Tcnn.layers{i}.W = Tcnn.layers{i}.W - Tcnn.learning_rate* dW_nor ;
        Tcnn.layers{i}.b = Tcnn.layers{i}.b - Tcnn.learning_rate* db_nor ;
        % Quantization 
        %cnn.layers{i}.W = quantize_round_clip(cnn.layers{i}.W, paramRange_ori * 2^bit_scale);
        %cnn.layers{i}.b = quantize_round_clip(cnn.layers{i}.b, paramRange_ori * 2^bit_scale);
    
    
    elseif Tcnn.layers{i}.type == 'c'
        
        kk=0;
        feature_width  = Tcnn.layers{i}.kernel_width;
        feature_height = Tcnn.layers{i}.kernel_height;
        sum_sqr_K = zeros(feature_height, feature_width, Tcnn.layers{i}.no_featuremaps * Tcnn.layers{i}.prev_layer_no_featuremaps);
        sum_sqr_b = zeros(1, Tcnn.layers{i}.no_featuremaps);
        
        for j = 1:Tcnn.layers{i}.no_featuremaps
            for k = 1:Tcnn.layers{i-1}.no_featuremaps
                kk = kk +1;
                %Adam optimizer
                Tcnn.layers{i}.v_dK(:,:,kk) = Beta_1 * Tcnn.layers{i}.v_dK(:,:,kk) + (1 - Beta_1) * Tcnn.layers{i}.dK(:,:,kk);
                sum_sqr_K(:,:,kk) = sum_sqr_K(:,:,kk) + Tcnn.layers{i}.dK(:,:,kk) .^ 2;
            end
            Tcnn.layers{i}.v_db(j) = Beta_1 * Tcnn.layers{i}.v_db(j) + (1 - Beta_1) * Tcnn.layers{i}.db(j);
            sum_sqr_b(j) = sum_sqr_b(j) + Tcnn.layers{i}.db(j) .^ 2;
        end
        
        mean_of_sum_sqr_b = sum_sqr_b / Tcnn.layers{i}.no_featuremaps;
        mean_of_sum_sqr_K = sum_sqr_K / (Tcnn.layers{i}.no_featuremaps * Tcnn.layers{i}.prev_layer_no_featuremaps);

        Tcnn.layers{i}.S_dK = Beta_2 * Tcnn.layers{i}.S_dK + (1 - Beta_2) * mean_of_sum_sqr_K ; 
        Tcnn.layers{i}.S_db = Beta_2 * Tcnn.layers{i}.S_db + (1 - Beta_2) * mean_of_sum_sqr_b ;
        
        v_dK_crt = Tcnn.layers{i}.v_dK / (1 - Beta_1 ^ crt_t);
        v_db_crt = Tcnn.layers{i}.v_db / (1 - Beta_1 ^ crt_t);
        S_dK_crt = Tcnn.layers{i}.S_dK / (1 - Beta_2 ^ crt_t);
        S_db_crt = Tcnn.layers{i}.S_db / (1 - Beta_2 ^ crt_t);
        
        S_dK_rt = (S_dK_crt + epsi * ones(feature_height,feature_width)) .^ 0.5 ;
        S_db_rt = (S_db_crt + epsi) .^ 0.5 ;
 
        
        kk = 0 ;
        for j = 1:Tcnn.layers{i}.no_featuremaps
            for k = 1:Tcnn.layers{i-1}.no_featuremaps
                kk = kk + 1;
                dK_nor(:,:,kk) = v_dK_crt(:,:,kk) ./ S_dK_rt (:,:,kk);
                Tcnn.layers{i}.K(:,:,kk) = Tcnn.layers{i}.K(:,:,kk) -  Tcnn.learning_rate * dK_nor(:,:,kk) ;
            end
            db_nor(j) = v_db_crt(j) / S_db_rt(j);
            Tcnn.layers{i}.b(j) = Tcnn.layers{i}.b(j) -  Tcnn.learning_rate * db_nor(j);
        end
        
        % Quantization
        %cnn.layers{i}.K = quantize_round_clip(cnn.layers{i}.K, paramRange_ori * 2^bit_scale);
        %cnn.layers{i}.b = quantize_round_clip(cnn.layers{i}.b, paramRange_ori * 2^bit_scale);
    end
end
