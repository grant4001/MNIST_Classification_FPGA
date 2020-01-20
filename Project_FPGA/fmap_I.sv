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

// Module: fmap_I.sv
// Date: 10/29/2019

module fmap_I #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 16, DEPTH = 196) (
    input clk,
    input [ADDR_WIDTH-1:0] wr_addr_1,
    input [ADDR_WIDTH-1:0] wr_addr_2,
    input [ADDR_WIDTH-1:0] wr_addr_3,
    input [ADDR_WIDTH-1:0] wr_addr_4,
    input [ADDR_WIDTH-1:0] wr_addr_5,
    input [ADDR_WIDTH-1:0] wr_addr_6,
    input [ADDR_WIDTH-1:0] wr_addr_7,
    input [ADDR_WIDTH-1:0] wr_addr_8,
    input [ADDR_WIDTH-1:0] wr_addr_9,
    input [ADDR_WIDTH-1:0] wr_addr_10,
    input [ADDR_WIDTH-1:0] wr_addr_11,
    input [ADDR_WIDTH-1:0] wr_addr_12,
    input [ADDR_WIDTH-1:0] wr_addr_13,
    input [ADDR_WIDTH-1:0] wr_addr_14,
    input [ADDR_WIDTH-1:0] wr_addr_15,
    input [ADDR_WIDTH-1:0] wr_addr_16,
    input [ADDR_WIDTH-1:0] rd_addr_1,
    input [ADDR_WIDTH-1:0] rd_addr_2,
    input [ADDR_WIDTH-1:0] rd_addr_3,
    input [ADDR_WIDTH-1:0] rd_addr_4,
    input [ADDR_WIDTH-1:0] rd_addr_5,
    input [ADDR_WIDTH-1:0] rd_addr_6,
    input [ADDR_WIDTH-1:0] rd_addr_7,
    input [ADDR_WIDTH-1:0] rd_addr_8,
    input [ADDR_WIDTH-1:0] rd_addr_9,
    input [ADDR_WIDTH-1:0] rd_addr_10,
    input [ADDR_WIDTH-1:0] rd_addr_11,
    input [ADDR_WIDTH-1:0] rd_addr_12,
    input [ADDR_WIDTH-1:0] rd_addr_13,
    input [ADDR_WIDTH-1:0] rd_addr_14,
    input [ADDR_WIDTH-1:0] rd_addr_15,
    input [ADDR_WIDTH-1:0] rd_addr_16,
    input wr_en_1,
    input wr_en_2,
    input wr_en_3,
    input wr_en_4,
    input wr_en_5,
    input wr_en_6,
    input wr_en_7,
    input wr_en_8,
    input wr_en_9,
    input wr_en_10,
    input wr_en_11,
    input wr_en_12,
    input wr_en_13,
    input wr_en_14,
    input wr_en_15,
    input wr_en_16,
    input [DATA_WIDTH-1:0] wr_data_1,
    input [DATA_WIDTH-1:0] wr_data_2,
    input [DATA_WIDTH-1:0] wr_data_3,
    input [DATA_WIDTH-1:0] wr_data_4,
    input [DATA_WIDTH-1:0] wr_data_5,
    input [DATA_WIDTH-1:0] wr_data_6,
    input [DATA_WIDTH-1:0] wr_data_7,
    input [DATA_WIDTH-1:0] wr_data_8,
    input [DATA_WIDTH-1:0] wr_data_9,
    input [DATA_WIDTH-1:0] wr_data_10,
    input [DATA_WIDTH-1:0] wr_data_11,
    input [DATA_WIDTH-1:0] wr_data_12,
    input [DATA_WIDTH-1:0] wr_data_13,
    input [DATA_WIDTH-1:0] wr_data_14,
    input [DATA_WIDTH-1:0] wr_data_15,
    input [DATA_WIDTH-1:0] wr_data_16,
    output [DATA_WIDTH-1:0] rd_data_1,
    output [DATA_WIDTH-1:0] rd_data_2,
    output [DATA_WIDTH-1:0] rd_data_3,
    output [DATA_WIDTH-1:0] rd_data_4,
    output [DATA_WIDTH-1:0] rd_data_5,
    output [DATA_WIDTH-1:0] rd_data_6,
    output [DATA_WIDTH-1:0] rd_data_7,
    output [DATA_WIDTH-1:0] rd_data_8,
    output [DATA_WIDTH-1:0] rd_data_9,
    output [DATA_WIDTH-1:0] rd_data_10,
    output [DATA_WIDTH-1:0] rd_data_11,
    output [DATA_WIDTH-1:0] rd_data_12,
    output [DATA_WIDTH-1:0] rd_data_13,
    output [DATA_WIDTH-1:0] rd_data_14,
    output [DATA_WIDTH-1:0] rd_data_15,
    output [DATA_WIDTH-1:0] rd_data_16
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_1 (
    .clk (clk),
    .wr_addr (wr_addr_1),
    .rd_addr (rd_addr_1),
    .write_en (wr_en_1),
    .wr_data (wr_data_1),
    .rd_data (rd_data_1)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_2 (
    .clk (clk),
    .wr_addr (wr_addr_2),
    .rd_addr (rd_addr_2),
    .write_en (wr_en_2),
    .wr_data (wr_data_2),
    .rd_data (rd_data_2)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_3 (
    .clk (clk),
    .wr_addr (wr_addr_3),
    .rd_addr (rd_addr_3),
    .write_en (wr_en_3),
    .wr_data (wr_data_3),
    .rd_data (rd_data_3)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_4 (
    .clk (clk),
    .wr_addr (wr_addr_4),
    .rd_addr (rd_addr_4),
    .write_en (wr_en_4),
    .wr_data (wr_data_4),
    .rd_data (rd_data_4)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_5 (
    .clk (clk),
    .wr_addr (wr_addr_5),
    .rd_addr (rd_addr_5),
    .write_en (wr_en_5),
    .wr_data (wr_data_5),
    .rd_data (rd_data_5)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_6 (
    .clk (clk),
    .wr_addr (wr_addr_6),
    .rd_addr (rd_addr_6),
    .write_en (wr_en_6),
    .wr_data (wr_data_6),
    .rd_data (rd_data_6)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_7 (
    .clk (clk),
    .wr_addr (wr_addr_7),
    .rd_addr (rd_addr_7),
    .write_en (wr_en_7),
    .wr_data (wr_data_7),
    .rd_data (rd_data_7)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_8 (
    .clk (clk),
    .wr_addr (wr_addr_8),
    .rd_addr (rd_addr_8),
    .write_en (wr_en_8),
    .wr_data (wr_data_8),
    .rd_data (rd_data_8)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_9 (
    .clk (clk),
    .wr_addr (wr_addr_9),
    .rd_addr (rd_addr_9),
    .write_en (wr_en_9),
    .wr_data (wr_data_9),
    .rd_data (rd_data_9)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_10 (
    .clk (clk),
    .wr_addr (wr_addr_10),
    .rd_addr (rd_addr_10),
    .write_en (wr_en_10),
    .wr_data (wr_data_10),
    .rd_data (rd_data_10)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_11 (
    .clk (clk),
    .wr_addr (wr_addr_11),
    .rd_addr (rd_addr_11),
    .write_en (wr_en_11),
    .wr_data (wr_data_11),
    .rd_data (rd_data_11)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_12 (
    .clk (clk),
    .wr_addr (wr_addr_12),
    .rd_addr (rd_addr_12),
    .write_en (wr_en_12),
    .wr_data (wr_data_12),
    .rd_data (rd_data_12)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_13 (
    .clk (clk),
    .wr_addr (wr_addr_13),
    .rd_addr (rd_addr_13),
    .write_en (wr_en_13),
    .wr_data (wr_data_13),
    .rd_data (rd_data_13)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_14 (
    .clk (clk),
    .wr_addr (wr_addr_14),
    .rd_addr (rd_addr_14),
    .write_en (wr_en_14),
    .wr_data (wr_data_14),
    .rd_data (rd_data_14)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_15 (
    .clk (clk),
    .wr_addr (wr_addr_15),
    .rd_addr (rd_addr_15),
    .write_en (wr_en_15),
    .wr_data (wr_data_15),
    .rd_data (rd_data_15)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blk_16 (
    .clk (clk),
    .wr_addr (wr_addr_16),
    .rd_addr (rd_addr_16),
    .write_en (wr_en_16),
    .wr_data (wr_data_16),
    .rd_data (rd_data_16)
);

endmodule
