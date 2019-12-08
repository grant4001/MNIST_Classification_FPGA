function err = testcnn(cnn, test_xx, test_yy)
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
[b, l2]=max(test_yy, [], 1);
idx = find(l1 ~= l2);

err = length(idx)/prod(size(l1));

display 'test error is'
err
 