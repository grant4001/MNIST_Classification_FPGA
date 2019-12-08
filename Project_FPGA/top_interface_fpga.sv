`timescale 1ns/1ns

module top_interface_fpga
(
    // input MNIST image to the convolutional neural network
    input clk,
    input rst,
    input [7:0] pixel_i,
    input pixel_i_valid, 

    // digit classification output
    output reg [3:0] digit_o,
    output reg digit_o_valid
);

fifo #(8, 256) fifo_in 
(
    .rd_clk
)

top top_u 
(
    // input MNIST image to the convolutional neural network
    .clk             (clk),
    .rst             (rst),
    .pixel_i         (pixel_i),         
    .pixel_i_valid   (pixel_i_valid), 

    // digit classification output
    .digit_o         (digit_o),
    .digit_o_valid   (digit_o_valid)
);

endmodule
