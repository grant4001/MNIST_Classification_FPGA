function err=testcnn(cnn, batch_size,test_xx, test_yy)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%(c) Ashutosh Kumar Upadhyay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 equ = 0;
 
 sz = size(test_xx);

 for i= 1 : batch_size
    cnn = ffcnn(cnn, test_xx(:,:,i), 0);
    [a, l1]=max(cnn.layers{cnn.no_of_layers}.outputs, [],1);
    [b, l2]=max(test_yy(:,i), [], 1);
    if (l1 ~= l2)
        idx = 1;
    else
        idx = 0;
    end
    equ = equ + idx ;
 end
err = equ/sz(3);

display 'test error is'
err
 