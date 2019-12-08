function cnn = gradientdescentcnn(cnn, erMult)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global bit_scale;
paramRange_ori = 0.25; % original parameter range 
for i = 2:cnn.no_of_layers
    
   if cnn.layers{i}.type == 'f'
       cnn.layers{i}.W = cnn.layers{i}.W - cnn.learning_rate*( cnn.layers{i}.dW/erMult );
       cnn.layers{i}.b = cnn.layers{i}.b - cnn.learning_rate*( cnn.layers{i}.db/erMult );
       % Quantization
%       cnn.layers{i}.W = quantize_level_clip(cnn.layers{i}.W, bit_level, paramRange_ori);
%       cnn.layers{i}.b = quantize_level_clip(cnn.layers{i}.b, bit_level, paramRange_ori);
        cnn.layers{i}.W = quantize_round_clip(cnn.layers{i}.W, paramRange_ori * 2^bit_scale);
        cnn.layers{i}.b = quantize_round_clip(cnn.layers{i}.b, paramRange_ori * 2^bit_scale);
        

   elseif cnn.layers{i}.type == 'c'
       kk=0;
       for j = 1:cnn.layers{i}.no_featuremaps
            for k = 1:cnn.layers{i-1}.no_featuremaps
                kk = kk +1;
                cnn.layers{i}.K(:,:,kk) = cnn.layers{i}.K(:,:,kk) -  cnn.learning_rate*( cnn.layers{i}.dK(:,:,kk)/erMult );
            end
            cnn.layers{i}.b(j) = cnn.layers{i}.b(j) -  cnn.learning_rate*(cnn.layers{i}.db(j)/erMult );
       end
       % Quantization
%       cnn.layers{i}.K = quantize_level_clip(cnn.layers{i}.K, bit_level, paramRange_ori);
%       cnn.layers{i}.b = quantize_level_clip(cnn.layers{i}.b, bit_level, paramRange_ori);
        cnn.layers{i}.K = quantize_round_clip(cnn.layers{i}.K, paramRange_ori * 2^bit_scale);
        cnn.layers{i}.b = quantize_round_clip(cnn.layers{i}.b, paramRange_ori * 2^bit_scale);
   end
   
   
end