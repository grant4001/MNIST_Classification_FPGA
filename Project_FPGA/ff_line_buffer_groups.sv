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

// Module: ff_line_buffer_groups.sv
// Date: 12/13/2019
// Description: FF_LINE_BUFFER_GROUPS contains all groups of line buffers which are
// used to stream in ifmap data into the CNN. Additionally, spatially local data becomes 
// re-used.

module ff_line_buffer_groups #(parameter 
    LINE_BUF_GROUPS = 16, 
    LINE_BUFS_PER_GROUP = 2,
    LINE_BUF_ADDR_BITS = 5,
    D_WIDTH = 16,
    LINE_BUF_DEPTH = 30
) (
    input clk,
    input [LINE_BUF_ADDR_BITS-1:0] line_buffer_rd_addr [LINE_BUF_GROUPS-1:0][LINE_BUFS_PER_GROUP-1:0],
    input [LINE_BUF_ADDR_BITS-1:0] line_buffer_wr_addr [LINE_BUF_GROUPS-1:0][LINE_BUFS_PER_GROUP-1:0],
    input [LINE_BUF_GROUPS-1:0] line_buffer_wr_data [LINE_BUF_GROUPS-1:0][LINE_BUFS_PER_GROUP-1:0],
    input line_buffer_wr_en [LINE_BUF_GROUPS-1:0][LINE_BUFS_PER_GROUP-1:0],
    output [LINE_BUF_GROUPS-1:0] line_buffer_rd_data [LINE_BUF_GROUPS-1:0][LINE_BUFS_PER_GROUP-1:0]   
);

wire [LINE_BUF_GROUPS-1:0] line_buffer_rd_data_I [LINE_BUF_GROUPS-1:0];    
reg [LINE_BUF_ADDR_BITS-1:0] line_buffer_rd_addr_I [LINE_BUF_GROUPS-1:0];
reg [LINE_BUF_ADDR_BITS-1:0] line_buffer_wr_addr_I [LINE_BUF_GROUPS-1:0];
reg [LINE_BUF_GROUPS-1:0] line_buffer_wr_data_I [LINE_BUF_GROUPS-1:0];
reg line_buffer_wr_en_I [LINE_BUF_GROUPS-1:0];
wire [LINE_BUF_GROUPS-1:0] line_buffer_rd_data_II [LINE_BUF_GROUPS-1:0];
reg [LINE_BUF_ADDR_BITS-1:0] line_buffer_rd_addr_II [LINE_BUF_GROUPS-1:0];
reg [LINE_BUF_ADDR_BITS-1:0] line_buffer_wr_addr_II [LINE_BUF_GROUPS-1:0];
reg [LINE_BUF_GROUPS-1:0] line_buffer_wr_data_II [LINE_BUF_GROUPS-1:0];
reg line_buffer_wr_en_II [LINE_BUF_GROUPS-1:0];

genvar gi;
generate 
    for (gi = 0; gi < LINE_BUF_GROUPS; gi = gi + 1) 
    begin : gen_LINE_BUFS_PER_GROUP
        assign line_buffer_rd_data[gi][0] = line_buffer_rd_data_I[gi];
        assign line_buffer_rd_data[gi][1] = line_buffer_rd_data_II[gi];
    end
endgenerate

genvar k;

generate
    for (k = 0; k < LINE_BUF_GROUPS; k = k + 1) 
    begin : gen_assignments
        assign line_buffer_rd_addr_I[k] = line_buffer_rd_addr[k][0];
        assign line_buffer_rd_addr_II[k] = line_buffer_rd_addr[k][1];
        assign line_buffer_wr_addr_I[k] = line_buffer_wr_addr[k][0];
        assign line_buffer_wr_addr_II[k] = line_buffer_wr_addr[k][1];
        assign line_buffer_wr_data_I[k] = line_buffer_wr_data[k][0];
        assign line_buffer_wr_data_II[k] = line_buffer_wr_data[k][1];
        assign line_buffer_wr_en_I[k] = line_buffer_wr_en[k][0];
        assign line_buffer_wr_en_II[k] = line_buffer_wr_en[k][1];
    end
endgenerate

// generate the sram line buffer groups
genvar ii; 

generate
    for (ii = 0; ii < LINE_BUF_GROUPS; ii = ii + 1) 
    begin : line_buf_group_generation

        line_buffer_group #(
            .ADDR_WIDTH(LINE_BUF_ADDR_BITS),
            .DATA_WIDTH(D_WIDTH),
            .DEPTH(LINE_BUF_DEPTH)
        ) 
        line_buffer_group_u 
        (
            .clk (clk),
            .wr_addr_I(line_buffer_wr_addr_I[ii]),
            .wr_addr_II(line_buffer_wr_addr_II[ii]),
            .rd_addr_I(line_buffer_rd_addr_I[ii]),
            .rd_addr_II(line_buffer_rd_addr_II[ii]),
            .wr_en_I(line_buffer_wr_en_I[ii]),
            .wr_en_II(line_buffer_wr_en_II[ii]),
            .wr_data_I(line_buffer_wr_data_I[ii]),
            .wr_data_II(line_buffer_wr_data_II[ii]),
            .rd_data_I(line_buffer_rd_data_I[ii]),
            .rd_data_II(line_buffer_rd_data_II[ii])
        );

    end
endgenerate

endmodule