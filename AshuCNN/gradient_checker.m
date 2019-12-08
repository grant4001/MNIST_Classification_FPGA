function fail=gradient_checker(cnn, xx, yy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
epsilon = 1e-4;
diff = 1e-7;
fail=0;
for i=cnn.no_of_layers:-1:1
   if cnn.layers{i}.type == 'f'
       for j=1:size(cnn.layers{i}.W, 1)
           for k=1:size(cnn.layers{i}.W, 2)
                cnn1 = cnn; 
                cnn1.layers{i}.W(j,k) = cnn1.layers{i}.W(j,k) -epsilon;
                cnn1= ffcnn(cnn1,xx); cnn1 = bpcnn(cnn1,yy);
                loss1=cnn1.loss; clear cnn1;
                cnn1 = cnn; 
                cnn1.layers{i}.W(j,k) = cnn1.layers{i}.W(j,k) +epsilon;
                cnn1= ffcnn(cnn1,xx); cnn1 = bpcnn(cnn1,yy);
                loss2=cnn1.loss;
                grad =(loss2 -loss1)/(2*epsilon);
                
                if abs(grad - cnn.layers{i}.dW(j,k) )> diff  %/max(grad,cnn.layers{i}.dW(j,k)) 
                    fail=1;
                    abs(grad - cnn.layers{i}.dW(j,k) )
                    grad
                    cnn.layers{i}.dW(j,k)
                    error (['gradient checking fail for FF layer W(' num2str(j) ', ' num2str(k) ') at layer ' num2str(i)]);
                end
           end
       end
       
       for j=1:numel(cnn.layers{i}.b)
                 cnn1 = cnn; 
                cnn1.layers{i}.b(j) = cnn1.layers{i}.b(j) -epsilon;
                cnn1= ffcnn(cnn1,xx); cnn1 = bpcnn(cnn1,yy);
                loss1=cnn1.loss; clear cnn1;
                cnn1 = cnn; 
                cnn1.layers{i}.b(j) = cnn1.layers{i}.b(j) +epsilon;
                cnn1= ffcnn(cnn1,xx); cnn1 = bpcnn(cnn1,yy);
                loss2=cnn1.loss;
                grad =(loss2 -loss1)/(2*epsilon);
                if abs(grad - cnn.layers{i}.db(j)) > diff
                    fail=1;
                     abs(grad - cnn.layers{i}.db(j))
                    grad
                    cnn.layers{i}.db(j)
                    error(['gradient checking fail for FF layer b(' num2str(j) ') at layer ' num2str(i)]);
                end
       end
   elseif cnn.layers{i}.type == 'c'
       
        kk=0;
        for ii=1:cnn.layers{i}.no_featuremaps
        for j=1:cnn.layers{i-1}.no_featuremaps
            kk = kk+1;
           for k=1: size(cnn.layers{i}.K, 1)
               for l=1: size(cnn.layers{i}.K, 2)
                   cnn1 = cnn; 
                    cnn1.layers{i}.K(k,l,kk) = cnn1.layers{i}.K(k,l,kk) -epsilon;
                    cnn1= ffcnn(cnn1,xx); cnn1 = bpcnn(cnn1,yy);
                    loss1=cnn1.loss; clear cnn1;
                    cnn1 = cnn; 
                    cnn1.layers{i}.K(k,l,kk) = cnn1.layers{i}.K(k,l,kk) +epsilon;
                    cnn1= ffcnn(cnn1,xx); cnn1 = bpcnn(cnn1,yy);
                    loss2=cnn1.loss;
                    grad(k,l,kk) =(loss2 -loss1)/(2*epsilon);
                    if abs(grad(k,l,kk) - cnn.layers{i}.dK(k,l,kk)) > diff
                        fail=1;
                        abs(grad(k,l,kk) - cnn.layers{i}.dK(k,l,kk))
                        grad(k,l,j)
                        cnn.layers{i}.dK(k,l,j)
                        error(['gradient checking fail for Conv layer K(' num2str(k) ', ' num2str(l) ',' num2str(j) ') at layer ' num2str(i)]);
                    end
               end
           end
%            if abs(grad(:,:,kk) - cnn.layers{i}.dK(:,:,kk)) > diff
%                         fail=1;
%                         %grad
%                         %cnn.layers{i}.dK(k,l,j)
%                         %error(['gradient checking fail for Conv layer K(' num2str(k) ', ' num2str(l) ',' num2str(j) ') at layer ' num2str(i)]);
%            end
        end
        end
       
       for j=1:numel(cnn.layers{i}.b)
                 cnn1 = cnn; 
                cnn1.layers{i}.b(j) = cnn1.layers{i}.b(j) -epsilon;
                cnn1= ffcnn(cnn1,xx); cnn1 = bpcnn(cnn1,yy);
                loss1=cnn1.loss;
                cnn1 = cnn; 
                cnn1.layers{i}.b(j) = cnn1.layers{i}.b(j) +epsilon;
                cnn1= ffcnn(cnn1,xx); cnn1 = bpcnn(cnn1,yy);
                loss2=cnn1.loss;
                grad =(loss2 -loss1)/(2*epsilon);
                if abs(grad - cnn.layers{i}.db(j)) > diff
                    fail=1;
                    abs(grad - cnn.layers{i}.db(j)) 
                    grad
                    cnn.layers{i}.db(j)
                    error(['gradient checking fail for Conv layer b(' num2str(j) ') at layer ' num2str(i)]);
                end
       end
       
   end
    
end