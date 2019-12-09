% This script parses the weights and biases of the convolutional layers

% Parameters (uncomment and comment as you go)

% Conv 1 weights
% OUTPUT_FILE = 'Conv_1_weights.txt';
% NUM_SYNAPSES = 16;
% LAYER_NO = 2;
% TYPE = 'w';

% Conv 2 weights
% OUTPUT_FILE = 'Conv_2_weights.txt';
% NUM_SYNAPSES = 16*32;
% LAYER_NO = 4;
% TYPE = 'w';

% Conv 1 biases
% OUTPUT_FILE = 'Conv_1_biases.txt';
% NUM_SYNAPSES = 16;
% LAYER_NO = 2;
% TYPE = 'b';

% Conv 2 biases
% OUTPUT_FILE = 'Conv_2_biases.txt';
% NUM_SYNAPSES = 32;
% LAYER_NO = 4;
% TYPE = 'b';

% OTHER PARAMETERS
CONV_KERNEL_DIM = 3;
BITS = 14;
WORD_BITS = 16;
CNN_NAME = '14BIT_ERR68.mat';

% Open output text file
fileID = fopen(strcat('Outputs/',OUTPUT_FILE),'w');

% first, import the "cnn" variable
load(CNN_NAME);

if TYPE == 'b'
    for i = 1:NUM_SYNAPSES
        bias = cnn.layers{1,LAYER_NO}.b(i);
        NEGATIVE = '0'; % assumed not signed
        if bias < 0
            NEGATIVE = '1'; % the weight is actually signed
            bias = -1 * bias;
        end

        % convert decimal to binary
        my_binary = dec2bin(round(bias * (2^(BITS))));

        % zero extend the binary 
        new_bias = s_zero_extend(my_binary, WORD_BITS);

        % take 2's comp if the weight is negative
        if NEGATIVE == '1'
            new_bias = s_twos_complement(new_bias);
        end

        HEX_DIGITS = ceil(WORD_BITS / 4);
        fprintf(fileID, strcat('%0', int2str(HEX_DIGITS), 'x\n'), bin2dec(new_bias));
    end
elseif TYPE == 'w'
    for i = 1:NUM_SYNAPSES
        weights = cnn.layers{1,LAYER_NO}.K(:,:,i);
        for j = 1:1:CONV_KERNEL_DIM
            for k = 1:1:CONV_KERNEL_DIM
                my_single_weight = weights(j, k);
                NEGATIVE = '0';
                if my_single_weight < 0
                    NEGATIVE = '1'; % store the negativity
                    my_single_weight = -1 * my_single_weight;
                end

                % convert decimal to binary
                my_binary = dec2bin(round(my_single_weight * (2^(BITS))));

                % zero extend the binary 
                new_weight = s_zero_extend(my_binary, WORD_BITS);

                % take 2's comp if the weight is negative
                if NEGATIVE == '1'
                    new_weight = s_twos_complement(new_weight);
                end

                HEX_DIGITS = ceil(WORD_BITS / 4);
                fprintf(fileID, strcat('%0', int2str(HEX_DIGITS), 'x\n'), bin2dec(new_weight));
            end
        end
    end 
end
fclose(fileID);