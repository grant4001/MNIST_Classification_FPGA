function cnn=gradientdescentcnn(cnn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=2:cnn.no_of_layers
    
   if cnn.layers{i}.type == 'f'
       cnn.layers{i}.W = cnn.layers{i}.W - cnn.learning_rate*( cnn.layers{i}.dW );
       cnn.layers{i}.b = cnn.layers{i}.b - cnn.learning_rate*( cnn.layers{i}.db );
   elseif cnn.layers{i}.type == 'c'
       kk=0;
       for j=1:cnn.layers{i}.no_featuremaps
            for k=1:cnn.layers{i-1}.no_featuremaps
                kk = kk +1;
                cnn.layers{i}.K(:,:,kk)= cnn.layers{i}.K(:,:,kk) -  cnn.learning_rate*( cnn.layers{i}.dK(:,:,kk) );
            end
            cnn.layers{i}.b(j) = cnn.layers{i}.b(j) -  cnn.learning_rate*(cnn.layers{i}.db(j) );
       end
       
   end
   
end