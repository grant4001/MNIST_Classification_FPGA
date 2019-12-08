function a=applyactfunccnn(z, act_func, dir, err)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%to calculate derivatie dir==1
if dir==1000
    a=ones(size(z));
else
if act_func=='sigm'
    a=1./(1+exp(-z));
    if dir ==1
        a = z.* (1-z);
        a = a.*err;
    end
elseif act_func == 'tanh'
%     a=1.7159*tanh(2/3.* z);
%     if dir ==1
%         a = (2/3)/1.7159*(1.7159 - z).*(1.7159+z);
%     end
      a = tanh(z);
      if dir ==1
          a = 1-z.*z;
          a = a.*err;
      end
elseif act_func == 'rect' %ReLU
    leak = 0.01;
%     a=z;
%     a(z<0)=0.01 *z (z<0);
%     if dir == 1
%         a=z;
%         a(z<=0) =0.01;
%         a(z>0)=1;
%     end
      a = z .* (leak + (1 - leak) * (z > 0)) ;
      if dir ==1
          a = (leak + (1 - leak) * (z > 0)) ;
          a= a.*err;
      end 
elseif act_func == 'none'
    a=z;
    if dir ==1
        a = z.*err;
    end
elseif act_func == 'soft' %softmax
    a= exp(z);
    a = (a)./repmat(sum(a,1), [size(z,1) 1]);
    if dir ==1
%         error('softmax layer in backpropagation is not implemented yet');
        err1 = repmat(sum(err.*z, 1), [size(err,1) 1]);
        a = -z.* (err1 -err);
    end
elseif act_func == 'plus'  %softplus - similar to ReLu (rect)
    checkvalues(z)
    a = log(1+exp(z));
    checkvalues(a, z)
    if dir==1
         a=1 - exp(-z);
         a = a.*err;
    end
else
    error 'activation function not implemented'
end

end