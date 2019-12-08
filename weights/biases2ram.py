import math

def write_to_file():

    # parameters
    ADDR_WIDTH = 4
    DATA_WIDTH = 128
    MEM_AMOUNT = 1
    
    # file I/O
    CONV1_B = "Conv_1_biases.txt" # 2
    CONV2_B = "Conv_2_biases.txt" # 4
    FC1_B = "FC_1_biases.txt" # 6
    FC2_B = "FC_2_biases.txt" # 7

    OUTPUT_FILE = []
    for i in range(0 , MEM_AMOUNT):
    	OUTPUT_FILE.append("bi_mem" + str(i) + ".sv")

    # number of parameters (weights and biases)
    c1b = 16
    c2b = 32
    fc1b = 64
    fc2b = 10

    DEPTH = 16 #c1b + c1w + c2b + c2w + fc1b + fc1w + fc2b + fc2w

     # write to output file
    c1b_file = open(CONV1_B, "r")
    c2b_file = open(CONV2_B, "r")
    fc1b_file = open(FC1_B, "r")
    fc2b_file = open(FC2_B, "r")

    f = []
    for i in range(0 , MEM_AMOUNT):
        f.append( open(OUTPUT_FILE[i], "w+") )

        f[i].write('`timescale 1ns/1ns')
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
        f[i].write('reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];')
        f[i].write('\n')
        f[i].write('initial begin')
        f[i].write('\n')

    WORDS_PER_BLK = 8    # DATA_WIDTH / 16

    BITS_SO_FAR = 0
    c1b_BITS = 16 * c1b
    # conv1 biases
    j = 0 # current index of bias memory block
    for i in range(0, int(math.ceil(float(c1b)/float(WORDS_PER_BLK)))): # mem block to write
        currentblock = i % MEM_AMOUNT
        BITS_SO_FAR += 128
        if BITS_SO_FAR <= c1b_BITS:
            f[currentblock].write('mem[' + str(j) + '] = 128\'h')
            for k in range(0, WORDS_PER_BLK):
                f[currentblock].write(c1b_file.readline()[:-1])
        else:
            extra_bits = c1b_BITS - (BITS_SO_FAR - 128)
            f[currentblock].write('mem[' + str(j) + '] = {' + str(extra_bits) + '\'h')
            for k in range(0, int(math.ceil(float(extra_bits / 16)))):
                f[currentblock].write(c1b_file.readline()[:-1])
            dup = ''
            for xx in range(0, 128-extra_bits):
                dup += '0'
            f[currentblock].write(', ' + str(128 - extra_bits) + '\'b' + dup + '}')
        f[currentblock].write(';')
        f[currentblock].write('\n')
        if(currentblock == MEM_AMOUNT-1):
            j = j+1


    BITS_SO_FAR = 0
    c2b_BITS = 16 * c2b
    # conv2 biases
    j = 2 # current index of all memory blocks
    for i in range(0, int(math.ceil(float(c2b)/float(WORDS_PER_BLK)))): # mem block to write
        currentblock = i % MEM_AMOUNT
        BITS_SO_FAR += 128
        if BITS_SO_FAR <= c2b_BITS:
            f[currentblock].write('mem[' + str(j) + '] = 128\'h')
            for k in range(0, WORDS_PER_BLK):
                f[currentblock].write(c2b_file.readline()[:-1])
        else:
            extra_bits = c2b_BITS - (BITS_SO_FAR - 128)
            f[currentblock].write('mem[' + str(j) + '] = {' + str(extra_bits) + '\'h')
            for k in range(0, int(math.ceil(float(extra_bits / 16)))):
                f[currentblock].write(c2b_file.readline()[:-1])
            dup = ''
            for xx in range(0, 128-extra_bits):
                dup += '0'
            f[currentblock].write(', ' + str(128 - extra_bits) + '\'b' + dup + '}')
        f[currentblock].write(';')
        f[currentblock].write('\n')
        if(currentblock == MEM_AMOUNT-1):
            j = j+1

    # fc1 biases
    j = 6 # current index of all memory blocks
    BITS_SO_FAR = 0
    fc1b_BITS = 16 * fc1b
    for i in range(0, int(math.ceil(float(fc1b)/float(WORDS_PER_BLK)))): # mem block to write
        currentblock = i % MEM_AMOUNT
        BITS_SO_FAR += 128
        if BITS_SO_FAR <= fc1b_BITS:
            f[currentblock].write('mem[' + str(j) + '] = 128\'h')
            for k in range(0, WORDS_PER_BLK):
                f[currentblock].write(fc1b_file.readline()[:-1])
        else:
            extra_bits = fc1b_BITS - (BITS_SO_FAR - 128)
            f[currentblock].write('mem[' + str(j) + '] = {' + str(extra_bits) + '\'h')
            for k in range(0, int(math.ceil(float(extra_bits / 16)))):
                f[currentblock].write(fc1b_file.readline()[:-1])
            dup = ''
            for xx in range(0, 128-extra_bits):
                dup += '0'
            f[currentblock].write(', ' + str(128 - extra_bits) + '\'b' + dup + '}')
        f[currentblock].write(';')
        f[currentblock].write('\n')
        if(currentblock == MEM_AMOUNT-1):
            j = j+1

    # fc2 biases
    BITS_SO_FAR = 0
    fc2b_BITS = 16 * fc2b
    j = 14 # current index of all memory blocks
    for i in range(0, int(math.ceil(float(fc2b)/float(WORDS_PER_BLK)))): # mem block to write
        currentblock = i % MEM_AMOUNT
        BITS_SO_FAR += 128
        if BITS_SO_FAR <= fc2b_BITS:
            f[currentblock].write('mem[' + str(j) + '] = 128\'h')
            for k in range(0, WORDS_PER_BLK):
                f[currentblock].write(fc2b_file.readline()[:-1])
        else:
            extra_bits = fc2b_BITS - (BITS_SO_FAR - 128)
            f[currentblock].write('mem[' + str(j) + '] = {' + str(extra_bits) + '\'h')
            for k in range(0, int(math.ceil(float(extra_bits / 16)))):
                f[currentblock].write(fc2b_file.readline()[:-1])
            dup = ''
            for xx in range(0, 128-extra_bits):
                dup += '0'
            f[currentblock].write(', ' + str(128 - extra_bits) + '\'b' + dup + '}')
        f[currentblock].write(';')
        f[currentblock].write('\n')
        if(currentblock == MEM_AMOUNT-1):
            j = j+1


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
        f[i].write('\n')
        f[i].write('q_a <= mem[addr_a];')
        f[i].write('\n')
        # f[i].write('end')
        # f[i].write('\n')
        f[i].write('end')
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
        f[i].write('\n')
        f[i].write('q_b <= mem[addr_b];')
        f[i].write('\n')
        # f[i].write('end')
        # f[i].write('\n')
        f[i].write('end')
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
