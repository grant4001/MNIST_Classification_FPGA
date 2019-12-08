function  Tcnn = RMSprop(Tcnn, Beta, epsi)
%%%%%%%%%%% .  created by qc . %%%%%%%%%%
% Beta normally take the value of 0.9
% epsi normally take the value of 0.001
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
for i = 2 : Tcnn.no_of_layers
    if Tcnn.layers{i}.type == 'f'
        
        sum_sqr_dW = 0;
        sum_sqr_db = 0;
        for no_of_nodes = 1 : Tcnn.layers{i}.no_of_nodes
            for k = 1 : Tcnn.layers{i}.no_of_inputs
                sum_sqr_dW =  sum_sqr_dW + Tcnn.layers{i}.dW(no_of_nodes, k) ^ 2 ;
            end
            sum_sqr_db = sum_sqr_db + Tcnn.layers{i}.db(no_of_nodes, 1) ^ 2 ;
        end 
        mean_sum_sqr_W = sum_sqr_dW / (Tcnn.layers{i}.no_of_nodes * Tcnn.layers{i}.no_of_inputs);
        mean_sum_sqr_b = sum_sqr_db / Tcnn.layers{i}.no_of_nodes;
        
        Tcnn.layers{i}.S_dW = Beta * Tcnn.layers{i}.S_dW + (1 - Beta) * mean_sum_sqr_W ;
        Tcnn.layers{i}.S_db = Beta * Tcnn.layers{i}.S_db + (1 - Beta) * mean_sum_sqr_b ;
        
        %Tcnn.layers{i}.S_dW = Beta * Tcnn.layers{i}.S_dW + mean_sum_sqr_W ;
        %Tcnn.layers{i}.S_db = Beta * Tcnn.layers{i}.S_db + mean_sum_sqr_b ;
        S_dW_rt = (Tcnn.layers{i}.S_dW + epsi) .^ 0.5 ;
        S_db_rt = (Tcnn.layers{i}.S_db + epsi) .^ 0.5 ;
        %S_dW_rt = (Tcnn.layers{i}.S_dW ) .^ 0.5 + epsi;
        %S_db_rt = (Tcnn.layers{i}.S_db ) .^ 0.5 + epsi ;


        dW_nor = Tcnn.layers{i}.dW / S_dW_rt;
        db_nor = Tcnn.layers{i}.db / S_db_rt;
       
        Tcnn.layers{i}.W = Tcnn.layers{i}.W - Tcnn.learning_rate * dW_nor ;
        Tcnn.layers{i}.b = Tcnn.layers{i}.b - Tcnn.learning_rate * db_nor ;
        % Quantization 
        %Tcnn.layers{i}.W = quantize_round_clip(Tcnn.layers{i}.W, paramRange_ori * 2^bit_scale);
        %Tcnn.layers{i}.b = quantize_round_clip(Tcnn.layers{i}.b, paramRange_ori * 2^bit_scale);
    
    
    elseif Tcnn.layers{i}.type == 'c'
        
        kk=0;
        feature_width  = Tcnn.layers{i}.kernel_width;
        feature_height = Tcnn.layers{i}.kernel_height;
        sum_sqr_dK = zeros(feature_height,feature_width);
        sum_sqr_db = 0;
        
        for j = 1:Tcnn.layers{i}.no_featuremaps
            for k = 1:Tcnn.layers{i-1}.no_featuremaps
                kk = kk +1;
                %RMSprop optimizer
                sum_sqr_dK(:,:) = sum_sqr_dK(:,:) + Tcnn.layers{i}.dK(:,:,kk) .^ 2;
            end
            sum_sqr_db = sum_sqr_db + Tcnn.layers{i}.db(j) .^ 2;
        end
        
        
        mean_of_sum_sqr_dK = sum_sqr_dK / (Tcnn.layers{i}.no_featuremaps * Tcnn.layers{i}.prev_layer_no_featuremaps);
        mean_of_sum_sqr_db = sum_sqr_db / Tcnn.layers{i}.no_featuremaps;
        
        Tcnn.layers{i}.S_dK = Beta * Tcnn.layers{i}.S_dK + (1 - Beta) * mean_of_sum_sqr_dK ; 
        Tcnn.layers{i}.S_db = Beta * Tcnn.layers{i}.S_db + (1 - Beta) * mean_of_sum_sqr_db ;
        %Tcnn.layers{i}.S_dK = Beta * Tcnn.layers{i}.S_dK + (1 - Beta) * sum_sqr_dK ; 
        %Tcnn.layers{i}.S_db = Beta * Tcnn.layers{i}.S_db + (1 - Beta) * sum_sqr_db ;
        
        %Tcnn.layers{i}.S_dK = Beta * Tcnn.layers{i}.S_dK + mean_of_sum_sqr_dK ; 
        %Tcnn.layers{i}.S_db = Beta * Tcnn.layers{i}.S_db + mean_of_sum_sqr_db ;
        
        S_dK_rt = (Tcnn.layers{i}.S_dK + epsi * ones(feature_height,feature_width)) .^ 0.5 ;
        S_db_rt = (Tcnn.layers{i}.S_db + epsi) .^ 0.5 ;
        %S_dK_rt = (Tcnn.layers{i}.S_dK) .^ 0.5 +  epsi * ones(feature_height,feature_width);
        %S_db_rt = (Tcnn.layers{i}.S_db) .^ 0.5 + epsi;
        
        kk = 0 ;
        for j = 1:Tcnn.layers{i}.no_featuremaps
            for k = 1:Tcnn.layers{i-1}.no_featuremaps
                kk = kk + 1 ;
                dK_nor(:,:,kk) = Tcnn.layers{i}.dK(:,:,kk) ./ S_dK_rt(:,:) ;
                Tcnn.layers{i}.K(:,:,kk) = Tcnn.layers{i}.K(:,:,kk) -  Tcnn.learning_rate * dK_nor(:,:,kk) ;
            end
            db_nor(j) = Tcnn.layers{i}.db(j) / S_db_rt;
            Tcnn.layers{i}.b(j) = Tcnn.layers{i}.b(j) -  Tcnn.learning_rate * db_nor(j) ;
        end
        
        % Quantization
        %Tcnn.layers{i}.K = quantize_round_clip(Tcnn.layers{i}.K, paramRange_ori * 2^bit_scale);
        %Tcnn.layers{i}.b = quantize_round_clip(Tcnn.layers{i}.b, paramRange_ori * 2^bit_scale);
    end
end


