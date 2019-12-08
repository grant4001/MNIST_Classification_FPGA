function distri = distributioncnn(cnn, n_bit, precision, layer, way, type, rmZero)

%%%%%%%%%%%%%%%%%%%%%%%%%%%   created by qc  %%%%%%%%%%%%%%%%%%%%%%%%%
% cnn refers to outcome of train
% n_bit refers to range of distribution, [-2^n_bit, 2^n_bit]
% preci refers to precition of distribution, 
% if precision = 0, precition is default
% way refers to whether sum of distribution ot seperate of distribution
% type refers to parameters of W,dW,b,db,er,featuremaps'featuremaps'
% batch refers to batch size of cnn
% rmZero refers to whether get rid of zero
% 1 represents yes, 0 represents no
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% featureMap
% error

num = cnn.no_of_layers;
distri = []; 

switch way 
    case 'all'

    for i = 1 : num
    
        switch cnn.layers{1,i}.type
            case 'i'
                distri_ftmap{i} = [];
                for k = 1 : cnn.layers{1,i}.no_featuremaps
                    distri_ftmap{i} = [distri_ftmap{i},reshape( cnn.layers{1,i}.featuremaps{1,k}, 1,[])];
                end
                
            case {'c','t'}
                
                distri_W{i} = [];
                distri_dW{i} = [];
                distri_b{i} = [];
                distri_db{i} = [];
                distri_ftmap{i} = [];
                distri_er{i}  = [];
                
                distri_W{i}  = [distri_W{i}, reshape(cnn.layers{1,i}.K, 1, [])];
                distri_dW{i} = [distri_dW{i}, reshape(cnn.layers{1,i}.dK, 1, [])];
                distri_b{i}  = [distri_b{i}, reshape(cnn.layers{1,i}.b, 1, [])];
                distri_db{i} = [distri_db{i}, reshape(cnn.layers{1,i}.db, 1, [])];
                    

                for k = 1 : cnn.layers{1,i}.no_featuremaps
                    distri_ftmap{i} = [distri_ftmap{i},reshape( cnn.layers{1,i}.featuremaps{1,k}, 1,[])];
                    distri_er{i} = [distri_er{i},reshape(cnn.layers{1,i}.er{1,k}, 1,[])];
                end
         
            case 'p'
                
                distri_ftmap{i} = [];
                distri_er{i} = [];
                
                for k = 1 : cnn.layers{1,i}.no_featuremaps
                    distri_ftmap{i} = [distri_ftmap{i},reshape( cnn.layers{1,i}.featuremaps{1,k}, 1,[])];
                    distri_er{i} = [distri_er{i},reshape( cnn.layers{1,i}.er{1,k}, 1,[])];
                end
                

            case 'f'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
                %modified by qc
%               for k = 1 : cnn.layers{1,i}.no_of_nodes
%                 
%               batch = cnn.layers{1,i}.no_of_inputs;
%               distri_W{i}((k-1)*batch+1 : k*batch)  = cnn.layers{1,i}.W(k,:);
%               distri_dW{i}((k-1)*batch+1 : k*batch) = cnn.layers{1,i}.dW(k,:);
%               distri_b{i} = cnn.layers{1,i}.b';
%               distri_db{i} = cnn.layers{1,i}.db';
%               end
                distri_W{i}  = reshape(cnn.layers{1,i}.W, 1, []);
                distri_dW{i} = reshape(cnn.layers{1,i}.dW, 1, []);
                distri_b{i}  = reshape(cnn.layers{1,i}.b, 1, []);
                distri_db{i} = reshape(cnn.layers{1,i}.db, 1, []);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
                distri_ftmap{i} = [];
                distri_er{i} = [];
                distri_ftmap{i} = [distri_ftmap{i},reshape( cnn.layers{1,i}.outputs, 1,[])];
                distri_er{i} = [distri_er{i}, reshape(cnn.layers{1,i}.er{1,1},1,[])];
                
                i = i + 1;
            
        end
    end


        switch type
            case 'W'
                for i = 1 : num
                        distri = [distri, distri_W{i}];
                end
                if rmZero == 1
                    distri = distri(find(distri ~= 0));
                   
                elseif rmZero == 0
                    
                end    
                
            case 'b'

                for i = 1 : num
                    distri = [distri, distri_b{i}]; 
                end
                if rmZero == 1
                    distri = distri(find(distri ~= 0));
                    
                elseif rmZero == 0
                    
                end
                
            case 'dW'

                for i = 1 : num
                distri = [distri, distri_dW{i}];
                end
                if rmZero == 1
                    distri = distri(find(distri ~= 0));
                    
                elseif rmZero == 0
                    
                end
                
            case 'db'
                for i = 1 : num
                    distri = [distri, distri_db{i}];
                end
                if rmZero == 1
                    distri = distri(find(distri ~= 0));
                    
                elseif rmZero == 0
                    
                end
                
            case 'featuremaps'
                
                for i = 1 : num
                    distri = [distri, distri_ftmap{i}];
                end
                if rmZero == 1
                    distri = distri(find(distri ~= 0));
                    
                elseif rmZero == 0
                    
                end
                
            case 'er'
                for i = 1 : num
                    distri = [distri, distri_er{i}];
                end
                if rmZero == 1
                    distri = distri(find(distri ~= 0));
                    
                elseif rmZero == 0
                   
                end
                
            otherwise
                error ('undefined type')
        end
    
    case 'sep'
        
        i = layer;
        switch cnn.layers{1,i}.type
            case 'i'
                
                distri_ftmap{i} = [];
                for k = 1 : cnn.layers{1,i}.no_featuremaps
                    distri_ftmap{i} = [distri_ftmap{i},reshape( cnn.layers{1,i}.featuremaps{1,k}, 1,[])];
                end
                
            case {'c','t'}
%               height = cnn.layers{1,i}.kernel_height;
%               width  = cnn.layers{1,i}.kernel_width;
%               dim = cnn.layers{1,i}.no_featuremaps * cnn.layers{1,i}.prev_layer_no_featuremaps;

%               for k = 1 : dim
%                   batch = height * width;
%
%                   distri_W{i} ((k-1)*batch+1 : k*batch) = cnn.layers{1,i}.K(:,:,k);
%                   distri_dW{i}((k-1)*batch+1 : k*batch) = cnn.layers{1,i}.dK(:,:,k);
%                   distri_b{i} = cnn.layers{1,i}.b;
%                   distri_db{i} = cnn.layers{1,i}.db;
% 
%                 end
                distri_W{i} = [];
                distri_dW{i} = [];
                distri_b{i} = [];
                distri_db{i} = [];
                distri_ftmap{i} = [];
                distri_er{i}  = [];
                
                distri_W{i}  = [distri_W{i}, reshape(cnn.layers{1,i}.K, 1, [])];
                distri_dW{i} = [distri_dW{i}, reshape(cnn.layers{1,i}.dK, 1, [])];
                distri_b{i}  = [distri_b{i}, reshape(cnn.layers{1,i}.b, 1, [])];
                distri_db{i} = [distri_db{i}, reshape(cnn.layers{1,i}.db, 1, [])];
                    
                for k = 1 : cnn.layers{1,i}.no_featuremaps
                    
                    distri_ftmap{i} = [distri_ftmap{i},reshape( cnn.layers{1,i}.featuremaps{1,k}, 1,[])];
                    distri_er{i} = [distri_er{i},reshape(cnn.layers{1,i}.er{1,k}, 1,[])];
                end
            
            case 'p'
                distri_ftmap{i} = [];
                distri_er{i}  = [];
                for k = 1 : cnn.layers{1,i}.no_featuremaps
                    distri_ftmap{i} = [distri_ftmap{i},reshape( cnn.layers{1,i}.featuremaps{1,k}, 1,[])];
                    distri_er{i} = [distri_er{i},reshape( cnn.layers{1,i}.er{1,k}, 1,[])];
                end
            
            
            case 'f'
                
            
%             for k = 1 : cnn.layers{1,i}.no_of_nodes
%                 
%                 batch = cnn.layers{1,i}.no_of_inputs;
%                 distri_W{i}((k-1)*batch+1 : k*batch)  = cnn.layers{1,i}.W(k,:);
%                 distri_dW{i}((k-1)*batch+1 : k*batch) = cnn.layers{1,i}.dW(k,:);
%                 distri_b{i} = cnn.layers{1,i}.b';
%                 distri_db{i} = cnn.layers{1,i}.db';
%             end
            distri_W{i}  = reshape(cnn.layers{1,i}.W, 1, []);
            distri_dW{i} = reshape(cnn.layers{1,i}.dW, 1, []);
            distri_b{i}  = reshape(cnn.layers{1,i}.b, 1, []);
            distri_db{i} = reshape(cnn.layers{1,i}.db, 1, []);

            distri_ftmap{i} = [];
            distri_er{i} = [];
            distri_ftmap{i} = [distri_ftmap{i},reshape( cnn.layers{1,i}.outputs, 1,[])];
            distri_er{i} = [distri_er{i}, reshape(cnn.layers{1,i}.er{1,1},1,[])];
        end
        
        switch type
            case 'W' 
                
                distri = [distri, distri_W{i}];
                if rmZero == 1
                    distri = distri(find(distri ~= 0));
                elseif rmZero == 0
                    
                end
            
            case 'b'
                distri = [distri, distri_b{i}];
                if rmZero == 1
                    distri = distri(find(distri ~= 0));
                elseif rmZero == 0

                end
            case 'dW'
                distri = [distri, distri_dW{i}];
                if rmZero == 1
                    distri = distri(find(distri ~= 0));
                elseif rmZero == 0
                    
                end
            case 'db'
                distri = [distri, distri_db{i}];
                if rmZero == 1
                    distri = distri(find(distri ~= 0));
                elseif rmZero == 0
                    
                end
            case 'featuremaps'
                distri = [distri, distri_ftmap{i}];
                if rmZero == 1
                    distri = distri(find(distri ~= 0));
                elseif rmZero == 0
                    
                end
            case 'er'
                distri = [distri, distri_er{i}];
                if rmZero == 1
                    distri = distri(find(distri ~= 0));
                elseif rmZero == 0
                    
                end
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

