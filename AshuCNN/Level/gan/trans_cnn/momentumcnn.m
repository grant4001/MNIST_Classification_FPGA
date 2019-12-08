%function cnn = gradientdescentcnn(cnn, erMult)
function cnn = momentumcnn(cnn, Beta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% original parameter range 
for i = 2 : cnn.no_of_layers
    
   if cnn.layers{i}.type == 'f'
       %modified by qc
       cnn.layers{i}.v_dW = Beta * cnn.layers{i}.v_dW + (1 - Beta) * cnn.layers{i}.dW;
       cnn.layers{i}.v_db = Beta * cnn.layers{i}.v_db + (1 - Beta) * cnn.layers{i}.db;
       cnn.layers{i}.W = cnn.layers{i}.W - cnn.learning_rate*( cnn.layers{i}.v_dW);
       cnn.layers{i}.b = cnn.layers{i}.b - cnn.learning_rate*( cnn.layers{i}.v_db);
       %cnn.layers{i}.W = cnn.layers{i}.W - cnn.learning_rate*( cnn.layers{i}.dW/erMult);
       %cnn.layers{i}.b = cnn.layers{i}.b - cnn.learning_rate*( cnn.layers{i}.db/erMult);
       % Quantization
%       cnn.layers{i}.W = quantize_level_clip(cnn.layers{i}.W, bit_level, paramRange_ori);
%       cnn.layers{i}.b = quantize_level_clip(cnn.layers{i}.b, bit_level, paramRange_ori);
        %cnn.layers{i}.W = quantize_round_clip(cnn.layers{i}.W, paramRange_ori * 2^bit_scale);
        %cnn.layers{i}.b = quantize_round_clip(cnn.layers{i}.b, paramRange_ori * 2^bit_scale);
        

   elseif (cnn.layers{i}.type == 'c') || (cnn.layers{i}.type == 't')
       kk=0;
       for j = 1:cnn.layers{i}.no_featuremaps
            for k = 1:cnn.layers{i-1}.no_featuremaps
                kk = kk +1;
                %modified by qc
                cnn.layers{i}.v_dK(:,:,kk) = Beta * cnn.layers{i}.v_dK(:,:,kk) + (1 - Beta) * cnn.layers{i}.dK(:,:,kk);
                cnn.layers{i}.K(:,:,kk) = cnn.layers{i}.K(:,:,kk) -  cnn.learning_rate*( cnn.layers{i}.v_dK(:,:,kk) );
                %cnn.layers{i}.K(:,:,kk) = cnn.layers{i}.K(:,:,kk) -  cnn.learning_rate*( cnn.layers{i}.dK(:,:,kk));
            end
            cnn.layers{i}.v_db(j) = Beta * cnn.layers{i}.v_db(j) + (1 - Beta) * cnn.layers{i}.db(j);
            cnn.layers{i}.b(j) = cnn.layers{i}.b(j) -  cnn.learning_rate*(cnn.layers{i}.v_db(j));
            %cnn.layers{i}.b(j) = cnn.layers{i}.b(j) -  cnn.learning_rate*(cnn.layers{i}.db(j)/erMult );
       end
       % Quantization
%       cnn.layers{i}.K = quantize_level_clip(cnn.layers{i}.K, bit_level, paramRange_ori);
%       cnn.layers{i}.b = quantize_level_clip(cnn.layers{i}.b, bit_level, paramRange_ori);
        %cnn.layers{i}.K = quantize_round_clip(cnn.layers{i}.K, paramRange_ori * 2^bit_scale);
        %cnn.layers{i}.b = quantize_round_clip(cnn.layers{i}.b, paramRange_ori * 2^bit_scale);
   end
   
   
end