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

// Module: fmap_II.sv
// Date: 10/29/2019

module fmap_II #(parameter ADDR_WIDTH = 3, DATA_WIDTH = 16, DEPTH = 8) (
    input clk,
    input [ADDR_WIDTH-1:0] fmap_wr_addr [143:0],
    input [ADDR_WIDTH-1:0] fmap_rd_addr [143:0],
    input fmap_wr_en [143:0],
    input [DATA_WIDTH-1:0] fmap_wr_data [143:0],
    output [DATA_WIDTH-1:0] fmap_rd_data [143:0]
);

genvar q;
generate
for (q = 0; q < 144; q = q + 1) begin : fmap_II_gen
    sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blks (
        .clk (clk),
        .wr_data (fmap_wr_data[q]),
        .rd_data (fmap_rd_data[q]),
        .wr_addr (fmap_wr_addr[q]),
        .rd_addr (fmap_rd_addr[q]),
        .write_en (fmap_wr_en[q])
    );
end
endgenerate
endmodule