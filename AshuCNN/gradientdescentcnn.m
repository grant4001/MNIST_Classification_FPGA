function cnn=gradientdescentcnn(cnn, BITS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=2:cnn.no_of_layers
    
   if cnn.layers{i}.type == 'f'
        temp5 = cnn.layers{i}.W - cnn.learning_rate*( cnn.layers{i}.dW );
        temp6 = s_quantize(temp5, BITS);
        cnn.layers{i}.W = temp6;
        temp7 = cnn.layers{i}.b - cnn.learning_rate*( cnn.layers{i}.db );
        temp8 = s_quantize(temp7, BITS);
         cnn.layers{i}.b = temp8;
   elseif cnn.layers{i}.type == 'c'
       kk=0;
       for j=1:cnn.layers{i}.no_featuremaps
            for k=1:cnn.layers{i-1}.no_featuremaps
                kk = kk +1;
                temp = cnn.layers{i}.K(:,:,kk) -  cnn.learning_rate*( cnn.layers{i}.dK(:,:,kk) );
                
                % Process the weight
                temp2 = s_quantize(temp, BITS);
                
                cnn.layers{i}.K(:,:,kk) = temp2;
            end
             temp3 = cnn.layers{i}.b(j) -  cnn.learning_rate*(cnn.layers{i}.db(j) );
             
             temp4 = s_quantize(temp3, BITS);
                
             cnn.layers{i}.b(j) = temp4;
       end
       
   end
   
end