% Parameters

% FC 1 weights
% OUTPUT_FILE = 'FC_1_weights.txt';
% NUM_SYNAPSES = 1152;
% NUM_OUTPUTS = 64;
% LAYER_NO = 6;
% TYPE = 'w';

% FC 2 weights
% OUTPUT_FILE = 'FC_2_weights.txt';
% NUM_SYNAPSES = 64;
% NUM_OUTPUTS = 10;
% LAYER_NO = 7;
% TYPE = 'w';

% FC 1 biases
% OUTPUT_FILE = 'FC_1_biases.txt';
% NUM_SYNAPSES = 1152;
% NUM_OUTPUTS = 64;
% LAYER_NO = 6;
% TYPE = 'b';

% FC 2 biases
% OUTPUT_FILE = 'FC_2_biases.txt';
% NUM_SYNAPSES = 64;
% NUM_OUTPUTS = 10;
% LAYER_NO = 7;
% TYPE = 'b';

% OTHER PARAMETERS
BITS = 14;
WORD_BITS = 16;
CNN_NAME = '14BIT_ERR68.mat';
iterator6x6 = [1 7 13 19 25 31 2 8 14 20 26 32 3 9 15 21 27 33 4 10 16 22 28 34 5 11 17 23 29 35 6 12 18 24 30 36];

% Open output text file
fileID = fopen(strcat('Outputs/',OUTPUT_FILE),'w');

% first, import the "cnn" variable
load(CNN_NAME);

if TYPE == 'b'
    NUM_SYNAPSES = 1;
end

% then, strip off the fc layer's weights
for i = 1:NUM_OUTPUTS
    
    iterator = 1:NUM_SYNAPSES;
    if TYPE == 'w'
        weights = cnn.layers{1,LAYER_NO}.W(i,:);
        
        if LAYER_NO == 6
            iterator = [];
            for mm = 1:32
                for nn = iterator6x6
                    iterator = [iterator (nn + ((mm - 1) * 36))];
                end
            end
        end
        
    elseif TYPE == 'b'        
        weights = cnn.layers{1,LAYER_NO}.b(i,:);
    end
    
    for k = iterator
        NEGATIVE = '0'; % assumed not signed
        my_single_weight = weights(k);
        if my_single_weight < 0
            NEGATIVE = '1'; % the weight is actually signed
            my_single_weight = -1 * my_single_weight;
        end

        % convert weight into binary (abs value)
        my_binary = dec2bin(round(my_single_weight * (2^(BITS))));

        % zero extend the binary 
        new_weight = s_zero_extend(my_binary, WORD_BITS);

        % take the 2's comp if negative
        if NEGATIVE == '1'
            new_weight = s_twos_complement(new_weight); 
        end

        HEX_DIGITS = ceil(WORD_BITS / 4);

        fprintf(fileID, strcat('%0', int2str(HEX_DIGITS), 'x\n'), bin2dec(new_weight));

    end
end

fclose(fileID);