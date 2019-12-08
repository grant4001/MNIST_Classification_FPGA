i = 1;
j = 1;
for i=1:cnn.layers{1,2}.no_featuremaps
    M = max(max(cnn.layers{1,3}.featuremaps{1,1}));
    N = min(min(cnn.layers{1,3}.featuremaps{1,1}));
    Data{1,i} = M;
    Data{2,j} = N;
    
    i = i+1;
    j = j+1;
end
Maximum = max(Data{1});
Minimum = min(Data{2});