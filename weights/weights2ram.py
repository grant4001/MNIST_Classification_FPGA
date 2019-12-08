import math

def write_to_file():

    # parameters
    ADDR_WIDTH = 11
    DATA_WIDTH = 144
    MEM_AMOUNT = 8
    
    # file I/O
    CONV1_B = "Conv_1_biases.txt" # 2
    CONV1_W = "Conv_1_weights.txt"
    CONV2_B = "Conv_2_biases.txt" # 4
    CONV2_W = "Conv_2_weights.txt"
    FC1_B = "FC_1_biases.txt" # 6
    FC1_W = "FC_1_weights.txt"
    FC2_B = "FC_2_biases.txt" # 7
    FC2_W = "FC_2_weights.txt"

    OUTPUT_FILE = []
    for i in range(0 , MEM_AMOUNT):
    	OUTPUT_FILE.append("wt_mem" + str(i) + ".sv")

    # number of parameters (weights and biases)
    c1b = 16
    c1w = 144 # 3x3x1x16
    c2b = 32
    c2w = 4608 # 3x3x16x32
    fc1b = 64
    fc1w = 73728 # 6x6x32x64
    fc2b = 10
    fc2w = 640 # 1x1x64x10

    DEPTH = 1100 #c1b + c1w + c2b + c2w + fc1b + fc1w + fc2b + fc2w

     # write to output file
    c1b_file = open(CONV1_B, "r")
    c1w_file = open(CONV1_W, "r")
    c2b_file = open(CONV2_B, "r")
    c2w_file = open(CONV2_W, "r")
    fc1b_file = open(FC1_B, "r")
    fc1w_file = open(FC1_W, "r")
    fc2b_file = open(FC2_B, "r")
    fc2w_file = open(FC2_W, "r")

    f = []
    for i in range(0 , MEM_AMOUNT):
        f.append( open(OUTPUT_FILE[i], "w+") )

        f[i].write('`timescale 1ns/1ns')
        f[i].write('\n')
        f[i].write('\n')
        f[i].write('module ' + OUTPUT_FILE[i][:-3] + ' #(parameter ADDR_WIDTH = ' + str(ADDR_WIDTH) + ', DATA_WIDTH = ' + str(DATA_WIDTH) + ', DEPTH = ' + str(DEPTH) + ') (')
        f[i].write('\n')
        f[i].write('input wire clk,')
        f[i].write('\n')
        f[i].write('input wire [ADDR_WIDTH-1:0] addr_a, ')
        f[i].write('\n')
        f[i].write('input wire [ADDR_WIDTH-1:0] addr_b, ')
        f[i].write('\n')
        # f[i].write('input wire write_en_a,')
        # f[i].write('\n')
        # f[i].write('input wire write_en_b,')
        # f[i].write('\n')
        # f[i].write('input wire [DATA_WIDTH-1:0] data_a,')
        # f[i].write('\n')
        # f[i].write('input wire [DATA_WIDTH-1:0] data_b,')
        # f[i].write('\n')
        f[i].write('output reg [DATA_WIDTH-1:0] q_a,')
        f[i].write('\n')
        f[i].write('output reg [DATA_WIDTH-1:0] q_b')
        f[i].write('\n')
        f[i].write(');')
        f[i].write('\n')
        f[i].write('\n')
        f[i].write('reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];')
        f[i].write('\n')
        f[i].write('\n')
        f[i].write('initial begin')
        f[i].write('\n')

    WORDS_PER_BLK = 9    # DATA_WIDTH / 16

    BITS_SO_FAR = 0
    c1w_BITS = 16 * c1w
    # conv1 weights
    j = 0 # current index of all memory blocks
    for i in range(0, int(math.ceil(float(c1w)/float(WORDS_PER_BLK)))): # mem block to write
        currentblock = i % MEM_AMOUNT
        BITS_SO_FAR += 144
        if BITS_SO_FAR <= c1w_BITS:
            f[currentblock].write('mem[' + str(j) + '] = 144\'h')
            for k in range(0, WORDS_PER_BLK):
                f[currentblock].write(c1w_file.readline()[:-1])
        else:
            extra_bits = c1w_BITS - (BITS_SO_FAR - 144)
            f[currentblock].write('mem[' + str(j) + '] = {' + str(extra_bits) + '\'h')
            for k in range(0, (extra_bits / 16)):
                f[currentblock].write(c1w_file.readline()[:-1])
            dup = ''
            for xx in range(0, 144-extra_bits):
                dup += '0'
            f[currentblock].write(', ' + str(144 - extra_bits) + '\'b' + dup + '}')
        f[currentblock].write(';')
        f[currentblock].write('\n')
        if(currentblock == MEM_AMOUNT-1):
            j = j+1

    BITS_SO_FAR = 0
    c2w_BITS = 16 * c2w
    # conv2 weight
    j = 2 # current index of all memory bloc
    for i in range(0, int(math.ceil(float(c2w)/float(WORDS_PER_BLK)))): # mem block to write
        currentblock = i % MEM_AMOUNT
        BITS_SO_FAR += 144
        if BITS_SO_FAR <= c2w_BITS:
            f[currentblock].write('mem[' + str(j) + '] = 144\'h')
            for k in range(0, WORDS_PER_BLK):
                f[currentblock].write(c2w_file.readline()[:-1])
        else:
            extra_bits = c2w_BITS - (BITS_SO_FAR - 144)
            f[currentblock].write('mem[' + str(j) + '] = {' + str(extra_bits) + '\'h')
            for k in range(0, (extra_bits / 16)):
                f[currentblock].write(c2w_file.readline()[:-1])
            dup = ''
            for xx in range(0, 144-extra_bits):
                dup += '0'
            f[currentblock].write(', ' + str(144 - extra_bits) + '\'b' + dup + '}')
        f[currentblock].write(';')
        f[currentblock].write('\n')
        if(currentblock == MEM_AMOUNT-1):
            j = j+1
    #f[currentblock].write('// ##### C2 WEIGHTS WRITTEN')
    #f[currentblock].write('\n')

    # fc1 weights
    BITS_SO_FAR = 0
    fc1w_BITS = 16 * fc1w
    j = 66 # current index of all memory blocks
    for i in range(0, int(math.ceil(float(fc1w)/float(WORDS_PER_BLK)))): # mem block to write
        currentblock = i % MEM_AMOUNT
        BITS_SO_FAR += 144
        if BITS_SO_FAR <= fc1w_BITS:
            f[currentblock].write('mem[' + str(j) + '] = 144\'h')
            for k in range(0, WORDS_PER_BLK):
                f[currentblock].write(fc1w_file.readline()[:-1])
        else:
            extra_bits = fc1w_BITS - (BITS_SO_FAR - 144)
            f[currentblock].write('mem[' + str(j) + '] = {' + str(extra_bits) + '\'h')
            for k in range(0, (extra_bits / 16)):
                f[currentblock].write(fc1w_file.readline()[:-1])
            dup = ''
            for xx in range(0, 144-extra_bits):
                dup += '0'
            f[currentblock].write(', ' + str(144 - extra_bits) + '\'b' + dup + '}')
        f[currentblock].write(';')
        f[currentblock].write('\n')
        if(currentblock == MEM_AMOUNT-1):
            j = j+1
    #f[currentblock].write('// ##### FC1 WEIGHTS WRITTEN')
    #f[currentblock].write('

    # fc2 weights
    dup = ''
    for xx in range(0, 128):
        dup += '0'
    WORDS_SO_FAR = 0
    j = 1090 # current index of all memory blocks
    for i in range(0, 10):
        j = 1090 + i
        for k in range(0, 7):
            f[k].write('mem[' + str(j) + '] = 144\'h')
            for l in range(0, 9):
                f[k].write(fc2w_file.readline()[:-1])
            f[k].write(';\n')
        f[7].write('mem[' + str(j) + '] = {16\'h')
        f[7].write(fc2w_file.readline()[:-1])
        f[7].write(', 128\'b' + dup + '}')
        f[7].write(';\n')


    # /*for i in range(0, int(math.ceil(float(fc2w)/float(WORDS_PER_BLK)))): # mem block to write
    #     currentblock = i % MEM_AMOUNT
    #     BITS_SO_FAR += 144
    #     if BITS_SO_FAR <= fc2w_BITS:
    #         f[currentblock].write('mem[' + str(j) + '] = 144\'h')
    #         for k in range(0, WORDS_PER_BLK):
    #             f[currentblock].write(fc2w_file.readline()[:-1])
    #     else:
    #         extra_bits = fc2w_BITS - (BITS_SO_FAR - 144)
    #         f[currentblock].write('mem[' + str(j) + '] = {' + str(extra_bits) + '\'h')
    #         for k in range(0, (extra_bits / 16)):
    #             f[currentblock].write(fc2w_file.readline()[:-1])
    #         dup = ''
    #         for xx in range(0, 144-extra_bits):
    #             dup += '0'
    #         f[currentblock].write(', ' + str(144 - extra_bits) + '\'b' + dup + '}')
    #     f[currentblock].write(';')
    #     f[currentblock].write('\n')
    #     if(currentblock == MEM_AMOUNT-1):
    #         j = j+1*/
    #f[currentblock].write('// ##### FC2 WEIGHTS WRITTEN')
    #f[currentblock].write('\n')

    for i in range(0 , MEM_AMOUNT):
        f[i].write('end')
        f[i].write('\n')
        f[i].write('\n')
        f[i].write('always @ (posedge clk) begin')
        f[i].write('\n')
        # f[i].write('if (write_en_a) begin')
        # f[i].write('\n')
        # f[i].write('mem[addr_a] <= data_a;')
        # f[i].write('\n')
        # f[i].write('end')
        # f[i].write('\n')
        # f[i].write('else begin')
        # f[i].write('\n')
        f[i].write('\tq_a <= mem[addr_a];')
        f[i].write('\n')
        f[i].write('end')
        # f[i].write('\n')
        # f[i].write('end')
        f[i].write('\n')
        f[i].write('\n')

        f[i].write('always @ (posedge clk) begin')
        f[i].write('\n')
        # f[i].write('if (write_en_b) begin')
        # f[i].write('\n')
        # f[i].write('mem[addr_a] <= data_b;')
        # f[i].write('\n')
        # f[i].write('end')
        # f[i].write('\n')
        # f[i].write('else begin')
        # f[i].write('\n')
        f[i].write('\tq_b <= mem[addr_b];')
        f[i].write('\n')
        f[i].write('end')
        # f[i].write('\n')
        # f[i].write('end')
        f[i].write('\n')
        f[i].write('\n')

        #f[i].write('assign rd_data = mem[rd_addr_reg];')
        #f[i].write('\n')
        #f[i].write('assign dprd_data = mem[dprd_addr_reg];')
        #f[i].write('\n')
        f[i].write('endmodule')

        f[i].close()


if __name__ == '__main__':
    write_to_file()
