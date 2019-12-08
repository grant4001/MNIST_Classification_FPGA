// Module: fmap_III.sv
// Date: 10/29/2019

module fmap_III #(ADDR_WIDTH = 1, DATA_WIDTH = 16, DEPTH = 1) (
    input clk,
    input fmap_wr_addr [63:0],
    input fmap_rd_addr [63:0],
    input fmap_wr_en [63:0],
    input [DATA_WIDTH-1:0] fmap_wr_data [63:0],
    output [DATA_WIDTH-1:0] fmap_rd_data [63:0]
);

genvar q;
generate
    for (q = 0; q < 64; q = q + 1) 
    begin : fmap_III_gen
        sram #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) mem_blks(
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