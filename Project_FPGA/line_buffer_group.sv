// Module: line_buffer_group.sv
// Date: 10/29/2019

module line_buffer_group #(parameter ADDR_WIDTH = 5, DATA_WIDTH = 16, DEPTH = 30) (
    input clk,
    input [ADDR_WIDTH-1:0] wr_addr_I,
    input [ADDR_WIDTH-1:0] wr_addr_II,
    // input [ADDR_WIDTH-1:0] wr_addr_III,
    input [ADDR_WIDTH-1:0] rd_addr_I,
    input [ADDR_WIDTH-1:0] rd_addr_II,
    // input [ADDR_WIDTH-1:0] rd_addr_III,
    input wr_en_I,
    input wr_en_II,
    // input wr_en_III,
    input [DATA_WIDTH-1:0] wr_data_I,
    input [DATA_WIDTH-1:0] wr_data_II,
    // input [DATA_WIDTH-1:0] wr_data_III,
    output [DATA_WIDTH-1:0] rd_data_I,
    output [DATA_WIDTH-1:0] rd_data_II
    // output [DATA_WIDTH-1:0] rd_data_III
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) line_buf_I (
    .clk (clk),
    .wr_addr (wr_addr_I),
    .rd_addr (rd_addr_I),
    .write_en (wr_en_I),
    .wr_data (wr_data_I),
    .rd_data (rd_data_I)
);

sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) line_buf_II (
    .clk (clk),
    .wr_addr (wr_addr_II),
    .rd_addr (rd_addr_II),
    .write_en (wr_en_II),
    .wr_data (wr_data_II),
    .rd_data (rd_data_II)
);

endmodule