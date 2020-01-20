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

// Module: sram.v
// Date: 10/21/2019
//

`timescale 1ns/1ns

module sram #(parameter ADDR_WIDTH = 8, DATA_WIDTH = 16, DEPTH = 256) (
    input wire clk,
    input wire [ADDR_WIDTH-1:0] wr_addr, 
    input wire [ADDR_WIDTH-1:0] rd_addr, 
    input wire write_en,
    input wire [DATA_WIDTH-1:0] wr_data,
    output wire [DATA_WIDTH-1:0] rd_data 
);

    integer i;
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1]; 
    reg [ADDR_WIDTH-1:0] rd_addr_reg;

    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            mem[i] = 0;
        end 
    end

    always @ (posedge clk) begin
        if (write_en) begin
            mem[wr_addr] <= wr_data;
        end
        rd_addr_reg <= rd_addr;
    end

    assign rd_data = mem[rd_addr_reg];

endmodule
