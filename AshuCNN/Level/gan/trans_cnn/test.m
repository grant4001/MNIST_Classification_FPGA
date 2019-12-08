fMap_prev = rand(2)
strides = 2;
sz_fMap_pre = size(fMap_prev,1);
batch_size = size(fMap_prev,3);
for m = strides : strides : strides*sz_fMap_pre
    for n = strides : strides : strides*sz_fMap_pre
        input(m,n,:) = fMap_prev(m/strides, n/strides, :);
    end
end
input

er_original = input
sz_er_ori = size(er_original,1);
batch_size = size(er_original,3);
er_shrink = zeros(sz_er_ori/strides, sz_er_ori/strides, batch_size);
for m = 1: 1 : sz_er_ori/strides
    for n =  1: 1 : sz_er_ori/strides
        er_shrink(m,n,:) = er_original(m*strides, n*strides, :);
    end
end
er_shrink
