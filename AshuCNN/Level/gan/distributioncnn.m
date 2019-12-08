function distri = distributioncnn(cnn, n_bit, precision, layer, way, type )

%%%%%%%%%%%%%%%%%%%%%%%%%%%   created by qc  %%%%%%%%%%%%%%%%%%%%%%%%%
% cnn refers to outcome of train
% n_bit refers to range of distribution, [-2^n_bit, 2^n_bit]
% preci refers to precition of distribution, 
% if precision = 0, precition is default
% way refers to whether sum of distribution ot seperate of distribution
% type refers to parameters of W,dW,b,db
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num = cnn.no_of_layers;
distri = [];

switch way 
    case 'sum'

    for i = 1 : num
    
        switch cnn.layers{1,i}.type
            case 'c'
            height = cnn.layers{1,i}.kernel_height;
            width  = cnn.layers{1,i}.kernel_width;
            dim = cnn.layers{1,i}.no_featuremaps * cnn.layers{1,i}.prev_layer_no_featuremaps;
            
            for k = 1 : dim
            batch = height * width;
            
            distri_W{i} ((k-1)*batch+1 : k*batch) = cnn.layers{1,i}.K(:,:,k);
            distri_dW{i}((k-1)*batch+1 : k*batch) = cnn.layers{1,i}.dK(:,:,k);
            distri_b{i} = cnn.layers{1,i}.b;
            distri_db{i} = cnn.layers{1,i}.db;
            end
            
            case 'f'
            
            for k = 1 : cnn.layers{1,i}.no_of_nodes
                
                batch = cnn.layers{1,i}.no_of_inputs;
                distri_W{i}((k-1)*batch+1 : k*batch)  = cnn.layers{1,i}.W(k,:);
                distri_dW{i}((k-1)*batch+1 : k*batch) = cnn.layers{1,i}.dW(k,:);
                distri_b{i} = cnn.layers{1,i}.b';
                distri_db{i} = cnn.layers{1,i}.db';
            
            end
    
            i = i + 1;
            
        end
    end


    switch type
    
        case 'W'
        
        for i = 1 : num
        
        distri = [distri, distri_W{i}];
        end
        histogram(distri)
        
        case 'b'
        
        for i = 1 : num
        distri = [distri, distri_b{i}]; 
        end
        histogram(distri)
        
        case 'dW'
        
        for i = 1 : num
        distri = [distri, distri_dW{i}];
        end
        histogram(distri)
        
        case 'db'
        
        for i = 1 : num
        distri = [distri, distri_db{i}];
        end
        histogram(distri)
        
        otherwise
            error ('undefined type')
    end
    
    case 'sep'
        
        i = layer;
        switch cnn.layers{1,i}.type
            case 'c'
                height = cnn.layers{1,i}.kernel_height;
                width  = cnn.layers{1,i}.kernel_width;
                dim = cnn.layers{1,i}.no_featuremaps * cnn.layers{1,i}.prev_layer_no_featuremaps;

                for k = 1 : dim
                    batch = height * width;

                    distri_W{i} ((k-1)*batch+1 : k*batch) = cnn.layers{1,i}.K(:,:,k);
                    distri_dW{i}((k-1)*batch+1 : k*batch) = cnn.layers{1,i}.K(:,:,k);
                    distri_b{i} = cnn.layers{1,i}.b;
                    distri_db{i} = cnn.layers{1,i}.db;

                end
            
            case 'f'
                
            
            for k = 1 : cnn.layers{1,i}.no_of_nodes
                
            batch = cnn.layers{1,i}.no_of_inputs;
            distri_W{i}((k-1)*batch+1 : k*batch)  = cnn.layers{1,i}.W(k,:);
            distri_dW{i}((k-1)*batch+1 : k*batch) = cnn.layers{1,i}.dW(k,:);
            distri_b{i} = cnn.layers{1,i}.b';
            distri_db{i} = cnn.layers{1,i}.db';
            
            end
        end
        switch type
            case 'W'        
            distri = [distri, distri_W{i}];

            case 'b'
        
            distri = [distri, distri_b{i}]; 
        
            case 'dW'
       
            distri = [distri, distri_dW{i}];

            case 'db'
        
            distri = [distri, distri_db{i}];
          
            otherwise
                
            error ('undefined type')
    end
                    
end
if precision ~= 0
    preci = precision;
    interval = (2 ^ (n_bit + 1 ))/preci;
    xbin = -2^n_bit: interval: 2^n_bit;
    histogram(distri, xbin);
else 
    histogram(distri);
end
