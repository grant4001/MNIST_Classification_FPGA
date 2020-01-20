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

// Module: controller.sv
// Date: 10/21/2019
// Description: Controller for the cnn
// In this module, we have a sending FSM and receiving FSM, both w/ respect to the mac_array

`timescale 1ns/1ns

module controller #(parameter LINE_BUF_GROUPS = 16, LINE_BUFS = 2, KERNEL_DIM = 3) 
(
    //inout VDD,
    //inout VSS,

    input clk,
    input rst,

    // Ifmap pixel input
    input [7:0] pixel_i, //8b gs
    input pixel_i_valid,

    // Weights I/O
    output reg [6:0] addr_a [7:0],
    output reg [6:0] addr_b [7:0],
    input [143:0] q_a [7:0],
    input [143:0] q_b [7:0],

    // Biases I/O
    output reg [3:0] bi_addr_a,
    output reg [3:0] bi_addr_b,
    input [127:0] bi_q_a,
    input [127:0] bi_q_b,

    // Line buffer I/O
    input [15:0] line_buffer_rd_data [LINE_BUF_GROUPS-1:0][1:0], //16b fmap val
    output reg [4:0] line_buffer_rd_addr [LINE_BUF_GROUPS-1:0][1:0], //log2(30) = 5
    output reg [4:0] line_buffer_wr_addr [LINE_BUF_GROUPS-1:0][1:0],
    output reg [15:0] line_buffer_wr_data [LINE_BUF_GROUPS-1:0][1:0],
    output reg line_buffer_wr_en [LINE_BUF_GROUPS-1:0][1:0],
    // 360

    // fmap I memory I/O, for the resulting fmaps of CONV2. (input image -> CONV2 -> fmap I)
    output reg [7:0] fmap_wr_addr_I [15:0],
    output reg [7:0] fmap_rd_addr_I [15:0],
    output reg fmap_wr_en_I [15:0],
    output reg [15:0] fmap_wr_data_I [15:0],
    input [15:0] fmap_rd_data_I [15:0],
    // 272,s

    // fmap II memory I/O, for the resulting fmaps of CONV4. (fmap I -> CONV4 -> fmap II)
    output reg [2:0] fmap_wr_addr_II [143:0],
    output reg [2:0] fmap_rd_addr_II [143:0],
    output reg fmap_wr_en_II [143:0],
    output reg [15:0] fmap_wr_data_II [143:0],
    input reg [15:0] fmap_rd_data_II [143:0],

    // fmap III memory I/O, for the resulting fmaps of FC6. (fmap II -> FC6 -> fmap III).
    output reg fmap_wr_addr_III [63:0],
    output reg fmap_rd_addr_III [63:0],
    output reg fmap_wr_en_III [63:0],
    output reg [15:0] fmap_wr_data_III [63:0],
    input reg [15:0] fmap_rd_data_III [63:0],

    // Classification. (fmap III -> FC7 -> 10 registers -> apply max -> get "digit_o" right here)
    output reg [3:0] digit_o,
    output reg digit_o_valid,

    output [9:0] fc_addr_a [7:0],
    output [9:0] fc_addr_b [7:0],
    input [143:0] fc_q_a [7:0],
    input [143:0] fc_q_b [7:0]

    // TESTING
    /*
    input fifo_rd_en,
    output [15:0] fifo_dout,
    output fifo_empty*/
);

// sender to mac signals
wire valid_i, accum_all;
wire [143:0] ifmap_chunk [15:0];
wire [143:0] wt [15:0];

// mac to receiver signals
wire valid_o;
wire [17:0] accum_o [15:0];
wire RCV_L2;

cnn_sender cnn_sender_u 
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

    //// NEW WEIGHTS FC I/O
    .fc_addr_a(fc_addr_a),
    .fc_addr_b(fc_addr_b),
    .fc_q_a(fc_q_a),
    .fc_q_b(fc_q_b),

    // Line buffer I/O
    .line_buffer_rd_data(line_buffer_rd_data),
    .line_buffer_rd_addr(line_buffer_rd_addr),
    .line_buffer_wr_addr(line_buffer_wr_addr),
    .line_buffer_wr_data(line_buffer_wr_data),
    .line_buffer_wr_en(line_buffer_wr_en),

    // fmap I memory I/O, for the resulting fmaps of CONV2. (input image -> CONV2 -> fmap I)
    .fmap_rd_addr_I(fmap_rd_addr_I),
    .fmap_rd_data_I(fmap_rd_data_I),

    // fmap II memory I/O, for the resulting fmaps of CONV4. (fmap I -> CONV4 -> fmap II)
    .fmap_rd_addr_II(fmap_rd_addr_II),
    .fmap_rd_data_II(fmap_rd_data_II),

    // fmap III memory I/O, for the resulting fmaps of FC6. (fmap II -> FC6 -> fmap III).
    .fmap_rd_addr_III(fmap_rd_addr_III),
    .fmap_rd_data_III(fmap_rd_data_III),

    // mac_array I/O
    .valid_i_final(valid_i),
    .wt(wt),
    .ifmap_chunk(ifmap_chunk)
);

// Connect the mac_array to its controller
mac_array mac_array_u 
(
    .clk(clk),
    .rst(rst),
    .RCV_L2(RCV_L2),
    .valid_i(valid_i),
    .valid_o(valid_o),
    .ifmap_chunk(ifmap_chunk),
    .wt(wt),
    .accum_o(accum_o)
);

cnn_receiver cnn_receiver_u 
(
    .clk(clk),
    .rst(rst),

    // Biases I/O
    .bi_addr_a(bi_addr_a),
    .bi_addr_b(bi_addr_b),
    .bi_q_a(bi_q_a),
    .bi_q_b(bi_q_b),

    // fmap I memory I/O, for the resulting fmaps of CONV2. (input image -> CONV2 -> fmap I)
    .fmap_wr_addr_I(fmap_wr_addr_I),
    .fmap_wr_en_I(fmap_wr_en_I),
    .fmap_wr_data_I(fmap_wr_data_I),

    // fmap II memory I/O, for the resulting fmaps of CONV4. (fmap I -> CONV4 -> fmap II)
    .fmap_wr_addr_II(fmap_wr_addr_II),
    .fmap_wr_en_II(fmap_wr_en_II),
    .fmap_wr_data_II(fmap_wr_data_II),

    // fmap III memory I/O, for the resulting fmaps of FC6. (fmap II -> FC6 -> fmap III).
    .fmap_wr_addr_III(fmap_wr_addr_III),
    .fmap_wr_en_III(fmap_wr_en_III),
    .fmap_wr_data_III(fmap_wr_data_III),

    // Classification. (fmap III -> FC7 -> 10 registers -> apply max -> get "digit_o" right here)
    .digit_o(digit_o),
    .digit_o_valid(digit_o_valid),

    // mac_array I/O
    .valid_o(valid_o),
    .accum_o(accum_o),
    .RCV_L2(RCV_L2)

    // TESTING 
    /*
    .fifo_rd_en(fifo_rd_en),
    .fifo_dout(fifo_dout),
    .fifo_empty(fifo_empty)*/
);

endmodule