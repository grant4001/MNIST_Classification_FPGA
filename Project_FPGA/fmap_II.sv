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