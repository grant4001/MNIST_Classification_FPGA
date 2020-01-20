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

// Module: mac.sv
// Date: 10/23/2019

`timescale 1ns/1ns

module mac #(parameter 
    TOTAL_BITS = 16,
    MULTS = 9
) 
(
    input clk,
    input rst,
    input [143:0] ifmap_chunk, 
    input [143:0] weight,
    output reg signed [17:0] mac_output
);

// subwindow pixels
wire signed [TOTAL_BITS-1:0] p1_1;
wire signed [TOTAL_BITS-1:0] p1_2;
wire signed [TOTAL_BITS-1:0] p1_3;
wire signed [TOTAL_BITS-1:0] p2_1;
wire signed [TOTAL_BITS-1:0] p2_2;
wire signed [TOTAL_BITS-1:0] p2_3;
wire signed [TOTAL_BITS-1:0] p3_1;
wire signed [TOTAL_BITS-1:0] p3_2;
wire signed [TOTAL_BITS-1:0] p3_3;

// weights
wire signed [TOTAL_BITS-1:0] w1_1;
wire signed [TOTAL_BITS-1:0] w1_2;
wire signed [TOTAL_BITS-1:0] w1_3;
wire signed [TOTAL_BITS-1:0] w2_1;
wire signed [TOTAL_BITS-1:0] w2_2;
wire signed [TOTAL_BITS-1:0] w2_3;
wire signed [TOTAL_BITS-1:0] w3_1;
wire signed [TOTAL_BITS-1:0] w3_2;
wire signed [TOTAL_BITS-1:0] w3_3;

// product
reg signed [31:0] q1_1;
reg signed [31:0] q1_2;
reg signed [31:0] q1_3;
reg signed [31:0] q2_1;
reg signed [31:0] q2_2;
reg signed [31:0] q2_3;
reg signed [31:0] q3_1;
reg signed [31:0] q3_2;
reg signed [31:0] q3_3;

wire signed [31:0] accum_row1, accum_row2, accum_row3;
reg signed [31:0] accum_row1_reg, accum_row2_reg, accum_row3_reg;
wire signed [31:0] accum_all;

assign p1_1 = ifmap_chunk[143:128]; 
assign p1_2 = ifmap_chunk[127:112]; 
assign p1_3 = ifmap_chunk[111:96]; 
assign p2_1 = ifmap_chunk[95:80]; 
assign p2_2 = ifmap_chunk[79:64];
assign p2_3 = ifmap_chunk[63:48];
assign p3_1 = ifmap_chunk[47:32];
assign p3_2 = ifmap_chunk[31:16];
assign p3_3 = ifmap_chunk[15:0];
assign w1_1 = weight[143:128];
assign w1_2 = weight[127:112];
assign w1_3 = weight[111:96];
assign w2_1 = weight[95:80];
assign w2_2 = weight[79:64];
assign w2_3 = weight[63:48];
assign w3_1 = weight[47:32];
assign w3_2 = weight[31:16];
assign w3_3 = weight[15:0];

/*
assign accum_row1 = {{2{q1_1[31]}}, q1_1} + {{2{q1_2[31]}}, q1_2} + {{2{q1_3[31]}}, q1_3};
assign accum_row2 = {{2{q2_1[31]}}, q2_1} + {{2{q2_2[31]}}, q2_2} + {{2{q2_3[31]}}, q2_3};
assign accum_row3 = {{2{q3_1[31]}}, q3_1} + {{2{q3_2[31]}}, q3_2} + {{2{q3_3[31]}}, q3_3};
assign accum_all = {{2{accum_row1_reg[33]}}, accum_row1_reg} + {{2{accum_row2_reg[33]}}, accum_row2_reg} + {{2{accum_row3_reg[33]}}, accum_row3_reg};
*/

assign accum_row1 = q1_1 + q1_2 + q1_3;
assign accum_row2 = q2_1 + q2_2 + q2_3;
assign accum_row3 = q3_1 + q3_2 + q3_3;
assign accum_all = accum_row1_reg + accum_row2_reg + accum_row3_reg;

always_ff @(posedge clk or negedge rst) 
begin
    if (~rst) 
    begin
        q1_1 <= 0;
        q1_2 <= 0;
        q1_3 <= 0;
        q2_1 <= 0;
        q2_2 <= 0;
        q2_3 <= 0;
        q3_1 <= 0;
        q3_2 <= 0;
        q3_3 <= 0;
        accum_row1_reg <= 0;
        accum_row2_reg <= 0;
        accum_row3_reg <= 0;
        mac_output <= 0;
    end else begin
        q1_1 <= p1_1 * w1_1;
        q1_2 <= p1_2 * w1_2;
        q1_3 <= p1_3 * w1_3;
        q2_1 <= p2_1 * w2_1;
        q2_2 <= p2_2 * w2_2;
        q2_3 <= p2_3 * w2_3;
        q3_1 <= p3_1 * w3_1;
        q3_2 <= p3_2 * w3_2;
        q3_3 <= p3_3 * w3_3;
        accum_row1_reg <= accum_row1;
        accum_row2_reg <= accum_row2;
        accum_row3_reg <= accum_row3;
        mac_output <= accum_all[31:14];
    end  
end

endmodule