%Honghu.haoyu.x = 'Machinelearning master'
%Honghu.zeyu = 'King of beautiful words'
%Honghu.shimeng = 'Winner of life'
%Honghu.yulong = 'Master of chemistry'
%C = {{1;0},2,3;
%    'text', rand(5,10,2), {11;22;33}}
%CNN_test.layers{}
%cnn.layers = {'type', 'no_features', 'feature_map_width', 'featuremap_height'
%    , 'prev_layer_no_featuremaps','featuremaps, er'};
% Datapath = './MNIST/';
%  
%  f=fopen(fullfile(Datapath, 'train-images.idx3-ubyte'),'r', 'b') ;
% 
% nn=fread(f,1,'int32');
% num=fread(f,1,'int32');
% h=fread(f,1,'int32');
% w=fread(f,1,'int32');
% train_x = uint8(fread(f,h*w*num,'uchar'));
% train_x = permute(reshape(train_x, h, w,num), [2 1 3]);
% train_x = double(train_x)./255;

%data1.nn = nn;
%data1.num = num;
%data1.h = h;
%data1.w = w;
%data1.train_x = train_x;
%fclose(f) ;

%f=fopen(fullfile(Datapath, 't10k-labels.idx1-ubyte'),'r', 'b') ;
%nn=fread(f,1,'int32');
%num=fread(f,1,'int32');
%y = double(fread(f,num,'uint8')); %load test labels
%y = (y)' ;
%test_y = zeros([10 num]); % there are 10 labels in MNIST lables
%for i=0:9 % labels are 0 - 9
%    k = find(y==i);
%    test_y(i+1,k)=1;
%end
%data4.nn = nn;
%data4.num = num;
%data4.y = y ;
%data4.test_y = test_y;
% er = 2;
% er1 = -1*er;

%             ss =size(cnn.layers{cnn.no_of_layers}.featuremaps{k});
%             zz =[zz; reshape(cnn.layers{cnn.no_of_layers}.featuremaps{k}, ss(1)*ss(2), ss(3))];
% repmat([1 2; 3 4],2,3)
% l1 = [2 4; -2 1];
% l2 = [9 4; -5 7];
% idx = find(l1 ~= l2)
% kk = [2 ,4 ,5; 5, 3, 1; 6, 8, 4]
% k = reshape(kk, 9,1);


% x = -1000: 0.1 : 1000;
% z = tanh(x);
% df1 = diff(z);
% f2 = 1-z.*z;
% f3 = 1-x.*x;
% figure(1)
% plot (x, f2);
% legend('1-z.*z');
% figure(2);
% plot (x, f3);
% legend('1-x.*x');
%  figure(3)
%  plot (df1);


%   x=-100 : 0.001 : 100;
%   y=1./(1+exp(-x));
%   z = y .* (1-y);
%   k = x .* (1-x);
%   
%   err = k./z;
%   dif = diff(y,1)/0.001;
%   w = -99.999:0.001:100
% %    plot(x,err);
% %    axis([-1 1 ]);
%     figure(1)
%     subplot(2,2,1);
%     plot(x,y);
%     axis([-1 1 -1 1]);
%     legend('function of sigm(x)');
%     subplot(2,2,2);
%     plot(w,dif);
%     legend('dirivative of sigm(x)');
%     axis([-1 1 -1 1]);
%     subplot(2,2,3);
%     plot(x,z);
%     legend('z = y .* (1-y)');
%     axis([-1 1 -1 1]);
%     subplot(2,2,4);
%     plot(x,k);
%     legend('k = x .* (1-x)');
%     axis([-1 1 -1 1]);
%     figure(2)
%     plot(x,err);
%     axis([-1 1 -2 2 ]);

%  x = -100:0.1:100;
%  y= 1./(1+exp(-x));
%  dif(y);
%  subplot(2,1,1);
%  plot(x,y);
%  subplot(2,1,2);
%  plot(x,dif1);

% [a, l1]=max(cnn.layers{cnn.no_of_layers}.outputs, [],1);
% [b, l2]=max(test_yy, [], 1);
% idx = find(l1 ~= l2);
% 
% err = length(idx)/prod(size(l1));

%p(:,:,8)= 0.5*rand(5,5)-0.25; % transfer random numbers' range from [-1,1] to [-0.25,0.25]
% i = 1;
% j = 1;
% for i=1:cnn.layers{1,2}.no_featuremaps
%     M = max(max(max(cnn.layers{1,2}.featuremaps{1,i})));
%     N = min(min(min(cnn.layers{1,2}.featuremaps{1,i})));
%     Data{1,i} = M;
%     Data{2,j} = N;
%     
%     i = i+1;
%     j = j+1;
% end
% Maximum = max(Data{1});
% Minimum = min(Data{2});