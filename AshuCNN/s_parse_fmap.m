% This script parses the fmaps from our given cnn. 
% 
% Our given CNN results from running s_test_my_sample_images.m

s_test_my_sample_images;

OUTPUT_FILE = 'fmap_layer_matlab.txt';
LAYER_NO = 4;
FMAP_DIM = 12;
NUM_FMAPS = 32;
FIRST_FC_LAYER = 6;
BITS = 14;
WORD_BITS = 16;

% Next, get the output of each layer.

my_fmap = zeros(FMAP_DIM, FMAP_DIM, NUM_FMAPS);
if LAYER_NO >= FIRST_FC_LAYER
    for qp = 1:NUM_FMAPS
        my_fmap(:,:,qp) = resulting_cnn.layers{1,LAYER_NO}.outputs(qp);
    end
else
    for qp = 1:NUM_FMAPS
        my_fmap(:,:,qp) = resulting_cnn.layers{1,LAYER_NO}.featuremaps{1,qp};
    end
end

% write to output text file
fileID = fopen(strcat('Outputs/', OUTPUT_FILE),'w');

for hh = 1:NUM_FMAPS
    for ii = 1:FMAP_DIM
        for jj = 1:FMAP_DIM
            result = my_fmap(ii, jj, hh) * (2^BITS);
            if (result >= 0) 
                fprintf(fileID, '%04x\n', result);
            else
                result = -1 * result;
                my_binary = dec2bin(round(result ));
                
                % zero extend the binary 
                new_weight = '';
                for kkk = 1:WORD_BITS
                    new_weight = strcat(new_weight, '0');
                end
                for o = WORD_BITS+1-length(my_binary):1:WORD_BITS
                    new_weight(o) = my_binary(o - WORD_BITS + length(my_binary));
                end

                new_weight = s_twos_complement(new_weight);
                fprintf(fileID, '%04x\n', bin2dec(new_weight));
            end
        end
    end
end
fclose(fileID);