/*
Copyright 2019, Grant Yu

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

// Module: top.sv
// Date: 11/1/2019
// Description: Top level module. Wraps the controller (core of the CNN) and RAM elements.

`timescale 1ns/1ns

module top #(parameter 
    GS_BITS = 8, 
    BCD_BITS = 4, 
    D_WIDTH = 16,

    LINE_BUF_GROUPS = 16,
    LINE_BUFS_PER_GROUP = 2,
    LINE_BUF_DEPTH = 30,
    LINE_BUF_ADDR_BITS = 5,
    
    FMAP_I_MEM_BLKS = 16,
    FMAP_I_DEPTH = 196,
    FMAP_I_ADDR_BITS = 8,

    FMAP_II_MEM_BLKS = 144,
    FMAP_II_DEPTH = 8,
    FMAP_II_ADDR_BITS = 3,

    FMAP_III_MEM_BLKS = 64,
    FMAP_III_DEPTH = 1,
    FMAP_III_ADDR_BITS = 1,

    WEIGHT_MEM_BLKS = 16,
    WEIGHT_MEM_DEPTH = 76,
    WEIGHT_MEM_ADDR_BITS = 7,
    WEIGHT_MEM_D_WIDTH = 144,

    BIAS_MEM_DEPTH = 16,
    BIAS_MEM_ADDR_BITS = 4,
    BIAS_MEM_D_WIDTH = 128

) (
    // input MNIST image to the convolutional neural network
    input clk,
    input rst,

    input [GS_BITS-1:0] pixel_i,
    input pixel_i_valid, 

    // digit classification output
    output reg [BCD_BITS-1:0] digit_o,
    output reg digit_o_valid

    // TESTING
    /*
    input fifo_rd_en,
    output [D_WIDTH-1:0] fifo_dout,
    output fifo_empty*/
    
);

// Line buffers
wire [D_WIDTH-1:0] line_buffer_rd_data [LINE_BUF_GROUPS-1:0][LINE_BUFS_PER_GROUP-1:0]; // 16-b data
wire [LINE_BUF_ADDR_BITS-1:0] line_buffer_rd_addr [LINE_BUF_GROUPS-1:0][LINE_BUFS_PER_GROUP-1:0]; // log2(30) = 5 bits
wire [LINE_BUF_ADDR_BITS-1:0] line_buffer_wr_addr [LINE_BUF_GROUPS-1:0][LINE_BUFS_PER_GROUP-1:0];
wire [D_WIDTH-1:0] line_buffer_wr_data [LINE_BUF_GROUPS-1:0][LINE_BUFS_PER_GROUP-1:0];
wire line_buffer_wr_en [LINE_BUF_GROUPS-1:0][LINE_BUFS_PER_GROUP-1:0];

// fmap I memory I/O, for the resulting fmaps of CONV2. (input image -> CONV2 -> fmap I)
wire [FMAP_I_ADDR_BITS-1:0] fmap_wr_addr_I [FMAP_I_MEM_BLKS-1:0]; 
wire [FMAP_I_ADDR_BITS-1:0] fmap_rd_addr_I [FMAP_I_MEM_BLKS-1:0];
wire fmap_wr_en_I [FMAP_I_MEM_BLKS-1:0];
wire [D_WIDTH-1:0] fmap_wr_data_I [FMAP_I_MEM_BLKS-1:0];
wire [D_WIDTH-1:0] fmap_rd_data_I [FMAP_I_MEM_BLKS-1:0];

// fmap II memory I/O, for the resulting fmaps of CONV4. (fmap I -> CONV4 -> fmap II)
wire [FMAP_II_ADDR_BITS-1:0] fmap_wr_addr_II [FMAP_II_MEM_BLKS-1:0];
wire [FMAP_II_ADDR_BITS-1:0] fmap_rd_addr_II [FMAP_II_MEM_BLKS-1:0];
wire fmap_wr_en_II [FMAP_II_MEM_BLKS-1:0];
wire [D_WIDTH-1:0] fmap_wr_data_II [FMAP_II_MEM_BLKS-1:0];
wire [D_WIDTH-1:0] fmap_rd_data_II [FMAP_II_MEM_BLKS-1:0];

// fmap III memory I/O, for the resulting fmaps of FC6. (fmap II -> FC6 -> fmap III).
wire [FMAP_III_ADDR_BITS-1:0] fmap_wr_addr_III [FMAP_III_MEM_BLKS-1:0];
wire [FMAP_III_ADDR_BITS-1:0] fmap_rd_addr_III [FMAP_III_MEM_BLKS-1:0];
wire fmap_wr_en_III [FMAP_III_MEM_BLKS-1:0];
wire [D_WIDTH-1:0] fmap_wr_data_III [FMAP_III_MEM_BLKS-1:0];
wire [D_WIDTH-1:0] fmap_rd_data_III [FMAP_III_MEM_BLKS-1:0];

// Weight memory (dual port ROM)
wire [WEIGHT_MEM_ADDR_BITS-1:0] addr_a [WEIGHT_MEM_BLKS/2-1:0];
wire [WEIGHT_MEM_ADDR_BITS-1:0] addr_b [WEIGHT_MEM_BLKS/2-1:0];
wire [WEIGHT_MEM_D_WIDTH-1:0] q_a [WEIGHT_MEM_BLKS/2-1:0];
wire [WEIGHT_MEM_D_WIDTH-1:0] q_b [WEIGHT_MEM_BLKS/2-1:0];

// Bias memory (dual port ROM)
wire [BIAS_MEM_ADDR_BITS-1:0] bi_addr_a;
wire [BIAS_MEM_ADDR_BITS-1:0] bi_addr_b;
wire [BIAS_MEM_D_WIDTH-1:0] bi_q_a;
wire [BIAS_MEM_D_WIDTH-1:0] bi_q_b;

///////////////////////////////// FC1 MEM I/O ////////////////////////////////////
wire [9:0] fc_addr_a [7:0];
wire [9:0] fc_addr_b [7:0];
wire [143:0] fc_q_a [7:0];
wire [143:0] fc_q_b [7:0];

// CNN core
controller controller_u 
(
    .clk(clk),
    .rst(rst),

    // Ifmap pixel input
    .pixel_i(pixel_i),
    .pixel_i_valid(pixel_i_valid),

    // Weights I/O
    .addr_a(addr_a),
    .addr_b(addr_b),
    .q_a(q_a),
    .q_b(q_b),

    // Biases I/O
    .bi_addr_a(bi_addr_a),
    .bi_addr_b(bi_addr_b),
    .bi_q_a(bi_q_a),
    .bi_q_b(bi_q_b),

    // Line buffer I/O
    .line_buffer_rd_data(line_buffer_rd_data),
    .line_buffer_rd_addr(line_buffer_rd_addr),
    .line_buffer_wr_addr(line_buffer_wr_addr),
    .line_buffer_wr_data(line_buffer_wr_data),
    .line_buffer_wr_en(line_buffer_wr_en),

    // fmap I memory I/O, for the resulting fmaps of CONV2. (input image -> CONV2 -> fmap I)
    .fmap_wr_addr_I(fmap_wr_addr_I),
    .fmap_rd_addr_I(fmap_rd_addr_I),
    .fmap_wr_en_I(fmap_wr_en_I),
    .fmap_wr_data_I(fmap_wr_data_I),
    .fmap_rd_data_I(fmap_rd_data_I),

    // fmap II memory I/O, for the resulting fmaps of CONV4. (fmap I -> CONV4 -> fmap II)
    .fmap_wr_addr_II(fmap_wr_addr_II),
    .fmap_rd_addr_II(fmap_rd_addr_II),
    .fmap_wr_en_II(fmap_wr_en_II),
    .fmap_wr_data_II(fmap_wr_data_II),
    .fmap_rd_data_II(fmap_rd_data_II),

    // fmap III memory I/O, for the resulting fmaps of FC6. (fmap II -> FC6 -> fmap III).
    .fmap_wr_addr_III(fmap_wr_addr_III),
    .fmap_rd_addr_III(fmap_rd_addr_III),
    .fmap_wr_en_III(fmap_wr_en_III),
    .fmap_wr_data_III(fmap_wr_data_III),
    .fmap_rd_data_III(fmap_rd_data_III),

    // Classification. (fmap III -> FC7 -> 10 registers -> apply max -> get "digit_o" right here)
    .digit_o(digit_o),
    .digit_o_valid(digit_o_valid),

    /// NEW MEMORY IO
    .fc_addr_a(fc_addr_a),
    .fc_addr_b(fc_addr_b),
    .fc_q_a(fc_q_a),
    .fc_q_b(fc_q_b)

    // TESTING
    /*
    .fifo_rd_en(fifo_rd_en),
    .fifo_dout(fifo_dout),
    .fifo_empty(fifo_empty)*/
);

// Line buffer memory
ff_line_buffer_groups #(
    .LINE_BUF_GROUPS(LINE_BUF_GROUPS),
    .LINE_BUFS_PER_GROUP(LINE_BUFS_PER_GROUP),
    .LINE_BUF_ADDR_BITS(LINE_BUF_ADDR_BITS),
    .D_WIDTH(D_WIDTH),
    .LINE_BUF_DEPTH(LINE_BUF_DEPTH)
)
ff_line_buffer_groups_u 
(
    .clk(clk),
    .line_buffer_rd_addr(line_buffer_rd_addr),
    .line_buffer_wr_addr(line_buffer_wr_addr),
    .line_buffer_wr_data(line_buffer_wr_data),
    .line_buffer_wr_en(line_buffer_wr_en),
    .line_buffer_rd_data(line_buffer_rd_data)  
);

// Fmap memory
fmap_I #(
    .ADDR_WIDTH(FMAP_I_ADDR_BITS),
    .DATA_WIDTH(D_WIDTH),
    .DEPTH(FMAP_I_DEPTH)
)
fmap_I_u 
(
    .clk(clk),
    .wr_addr_1(fmap_wr_addr_I[0]),
    .wr_addr_2(fmap_wr_addr_I[1]),
    .wr_addr_3(fmap_wr_addr_I[2]),
    .wr_addr_4(fmap_wr_addr_I[3]),
    .wr_addr_5(fmap_wr_addr_I[4]),
    .wr_addr_6(fmap_wr_addr_I[5]),
    .wr_addr_7(fmap_wr_addr_I[6]),
    .wr_addr_8(fmap_wr_addr_I[7]),
    .wr_addr_9(fmap_wr_addr_I[8]),
    .wr_addr_10(fmap_wr_addr_I[9]),
    .wr_addr_11(fmap_wr_addr_I[10]),
    .wr_addr_12(fmap_wr_addr_I[11]),
    .wr_addr_13(fmap_wr_addr_I[12]),
    .wr_addr_14(fmap_wr_addr_I[13]),
    .wr_addr_15(fmap_wr_addr_I[14]),
    .wr_addr_16(fmap_wr_addr_I[15]),
    .rd_addr_1(fmap_rd_addr_I[0]),
    .rd_addr_2(fmap_rd_addr_I[1]),
    .rd_addr_3(fmap_rd_addr_I[2]),
    .rd_addr_4(fmap_rd_addr_I[3]),
    .rd_addr_5(fmap_rd_addr_I[4]),
    .rd_addr_6(fmap_rd_addr_I[5]),
    .rd_addr_7(fmap_rd_addr_I[6]),
    .rd_addr_8(fmap_rd_addr_I[7]),
    .rd_addr_9(fmap_rd_addr_I[8]),
    .rd_addr_10(fmap_rd_addr_I[9]),
    .rd_addr_11(fmap_rd_addr_I[10]),
    .rd_addr_12(fmap_rd_addr_I[11]),
    .rd_addr_13(fmap_rd_addr_I[12]),
    .rd_addr_14(fmap_rd_addr_I[13]),
    .rd_addr_15(fmap_rd_addr_I[14]),
    .rd_addr_16(fmap_rd_addr_I[15]),
    .wr_en_1(fmap_wr_en_I[0]),
    .wr_en_2(fmap_wr_en_I[1]),
    .wr_en_3(fmap_wr_en_I[2]),
    .wr_en_4(fmap_wr_en_I[3]),
    .wr_en_5(fmap_wr_en_I[4]),
    .wr_en_6(fmap_wr_en_I[5]),
    .wr_en_7(fmap_wr_en_I[6]),
    .wr_en_8(fmap_wr_en_I[7]),
    .wr_en_9(fmap_wr_en_I[8]),
    .wr_en_10(fmap_wr_en_I[9]),
    .wr_en_11(fmap_wr_en_I[10]),
    .wr_en_12(fmap_wr_en_I[11]),
    .wr_en_13(fmap_wr_en_I[12]),
    .wr_en_14(fmap_wr_en_I[13]),
    .wr_en_15(fmap_wr_en_I[14]),
    .wr_en_16(fmap_wr_en_I[15]),
    .wr_data_1(fmap_wr_data_I[0]),
    .wr_data_2(fmap_wr_data_I[1]),
    .wr_data_3(fmap_wr_data_I[2]),
    .wr_data_4(fmap_wr_data_I[3]),
    .wr_data_5(fmap_wr_data_I[4]),
    .wr_data_6(fmap_wr_data_I[5]),
    .wr_data_7(fmap_wr_data_I[6]),
    .wr_data_8(fmap_wr_data_I[7]),
    .wr_data_9(fmap_wr_data_I[8]),
    .wr_data_10(fmap_wr_data_I[9]),
    .wr_data_11(fmap_wr_data_I[10]),
    .wr_data_12(fmap_wr_data_I[11]),
    .wr_data_13(fmap_wr_data_I[12]),
    .wr_data_14(fmap_wr_data_I[13]),
    .wr_data_15(fmap_wr_data_I[14]),
    .wr_data_16(fmap_wr_data_I[15]),
    .rd_data_1(fmap_rd_data_I[0]),
    .rd_data_2(fmap_rd_data_I[1]),
    .rd_data_3(fmap_rd_data_I[2]),
    .rd_data_4(fmap_rd_data_I[3]),
    .rd_data_5(fmap_rd_data_I[4]),
    .rd_data_6(fmap_rd_data_I[5]),
    .rd_data_7(fmap_rd_data_I[6]),
    .rd_data_8(fmap_rd_data_I[7]),
    .rd_data_9(fmap_rd_data_I[8]),
    .rd_data_10(fmap_rd_data_I[9]),
    .rd_data_11(fmap_rd_data_I[10]),
    .rd_data_12(fmap_rd_data_I[11]),
    .rd_data_13(fmap_rd_data_I[12]),
    .rd_data_14(fmap_rd_data_I[13]),
    .rd_data_15(fmap_rd_data_I[14]),
    .rd_data_16(fmap_rd_data_I[15])
);

fmap_II fmap_II_u 
(
    .clk(clk),
    .fmap_wr_addr(fmap_wr_addr_II),
    .fmap_rd_addr(fmap_rd_addr_II),
    .fmap_wr_en(fmap_wr_en_II),
    .fmap_wr_data(fmap_wr_data_II),
    .fmap_rd_data(fmap_rd_data_II)
);

fmap_III fmap_III_u 
(
    .clk(clk),
    .fmap_wr_addr(fmap_wr_addr_III),
    .fmap_rd_addr(fmap_rd_addr_III),
    .fmap_wr_en(fmap_wr_en_III),
    .fmap_wr_data(fmap_wr_data_III),
    .fmap_rd_data(fmap_rd_data_III)
);

// Bias memory
bi_mem0 bi_mem0_u 
(
    .clk(clk),
    .addr_a(bi_addr_a),
    .addr_b(bi_addr_b),
    .q_a(bi_q_a),
    .q_b(bi_q_b)
);

// Weights memory
wt_mem0 wt_mem0_u (
    .clk(clk),
    .addr_a(addr_a[0]),
    .addr_b(addr_b[0]),
    .q_a(q_a[0]),
    .q_b(q_b[0])
);

wt_mem1 wt_mem1_u (
    .clk(clk),
    .addr_a(addr_a[1]),
    .addr_b(addr_b[1]),
    .q_a(q_a[1]),
    .q_b(q_b[1])
);

wt_mem2 wt_mem2_u (
    .clk(clk),
    .addr_a(addr_a[2]),
    .addr_b(addr_b[2]),
    .q_a(q_a[2]),
    .q_b(q_b[2])
);

wt_mem3 wt_mem3_u (
    .clk(clk),
    .addr_a(addr_a[3]),
    .addr_b(addr_b[3]),
    .q_a(q_a[3]),
    .q_b(q_b[3])
);

wt_mem4 wt_mem4_u (
    .clk(clk),
    .addr_a(addr_a[4]),
    .addr_b(addr_b[4]),
    .q_a(q_a[4]),
    .q_b(q_b[4])
);

wt_mem5 wt_mem5_u (
    .clk(clk),
    .addr_a(addr_a[5]),
    .addr_b(addr_b[5]),
    .q_a(q_a[5]),
    .q_b(q_b[5])
);

wt_mem6 wt_mem6_u (
    .clk(clk),
    .addr_a(addr_a[6]),
    .addr_b(addr_b[6]),
    .q_a(q_a[6]),
    .q_b(q_b[6])
);

wt_mem7 wt_mem7_u (
    .clk(clk),
    .addr_a(addr_a[7]),
    .addr_b(addr_b[7]),
    .q_a(q_a[7]),
    .q_b(q_b[7])
);

////////////////// FC1 WEIGHTS ////////////////////////////////////////

wt_fc1_mem0 u_00 (
    .clk(clk),
    .addr_a(fc_addr_a[0]),
    .addr_b(fc_addr_b[0]),
    .q_a(fc_q_a[0]),
    .q_b(fc_q_b[0])
);

wt_fc1_mem1 u_01 (
    .clk(clk),
    .addr_a(fc_addr_a[1]),
    .addr_b(fc_addr_b[1]),
    .q_a(fc_q_a[1]),
    .q_b(fc_q_b[1])
);

wt_fc1_mem2 u_02 (
    .clk(clk),
    .addr_a(fc_addr_a[2]),
    .addr_b(fc_addr_b[2]),
    .q_a(fc_q_a[2]),
    .q_b(fc_q_b[2])
);

wt_fc1_mem3 u_03 (
    .clk(clk),
    .addr_a(fc_addr_a[3]),
    .addr_b(fc_addr_b[3]),
    .q_a(fc_q_a[3]),
    .q_b(fc_q_b[3])
);

wt_fc1_mem4 u_04 (
    .clk(clk),
    .addr_a(fc_addr_a[4]),
    .addr_b(fc_addr_b[4]),
    .q_a(fc_q_a[4]),
    .q_b(fc_q_b[4])
);

wt_fc1_mem5 u_05 (
    .clk(clk),
    .addr_a(fc_addr_a[5]),
    .addr_b(fc_addr_b[5]),
    .q_a(fc_q_a[5]),
    .q_b(fc_q_b[5])
);

wt_fc1_mem6 u_06 (
    .clk(clk),
    .addr_a(fc_addr_a[6]),
    .addr_b(fc_addr_b[6]),
    .q_a(fc_q_a[6]),
    .q_b(fc_q_b[6])
);

wt_fc1_mem7 u_07 (
    .clk(clk),
    .addr_a(fc_addr_a[7]),
    .addr_b(fc_addr_b[7]),
    .q_a(fc_q_a[7]),
    .q_b(fc_q_b[7])
);


endmodule
