function [a l1]=predictcnn(cnn, test_xx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 cnn = ffcnn(cnn, test_xx);
 
 if cnn.layers{cnn.no_of_layers}.type ~= 'f'
  zz=[];
  for k=1:cnn.layers{cnn.no_of_layers}.no_featuremaps
                   ss =size(cnn.layers{cnn.no_of_layers}.featuremaps{k});
                   zz =[zz; reshape(cnn.layers{cnn.no_of_layers}.featuremaps{k}, ss(1)*ss(2), ss(3))];
  end
   cnn.layers{cnn.no_of_layers}.outputs = zz;
 end
 
[a, l1]=max(cnn.layers{cnn.no_of_layers}.outputs, [],1);

