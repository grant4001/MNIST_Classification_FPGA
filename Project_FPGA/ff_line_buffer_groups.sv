module ff_line_buffer_groups #(parameter LINE_BUF_GROUPS = 16, LINE_BUFS = 2) (
    output [15:0] line_buffer_rd_data [LINE_BUF_GROUPS-1:0][LINE_BUFS-1:0],
    input [4:0] line_buffer_rd_addr [LINE_BUF_GROUPS-1:0][LINE_BUFS-1:0],
    input [4:0] line_buffer_wr_addr [LINE_BUF_GROUPS-1:0][LINE_BUFS-1:0],
    input [15:0] line_buffer_wr_data [LINE_BUF_GROUPS-1:0][LINE_BUFS-1:0],
    input line_buffer_wr_en [LINE_BUF_GROUPS-1:0][LINE_BUFS-1:0],
    input clk
);

wire [15:0] line_buffer_rd_data_I [LINE_BUF_GROUPS-1:0];    
reg [4:0] line_buffer_rd_addr_I [LINE_BUF_GROUPS-1:0];
reg [4:0] line_buffer_wr_addr_I [LINE_BUF_GROUPS-1:0];
reg [15:0] line_buffer_wr_data_I [LINE_BUF_GROUPS-1:0];
reg line_buffer_wr_en_I [LINE_BUF_GROUPS-1:0];
wire [15:0] line_buffer_rd_data_II [LINE_BUF_GROUPS-1:0];
reg [4:0] line_buffer_rd_addr_II [LINE_BUF_GROUPS-1:0];
reg [4:0] line_buffer_wr_addr_II [LINE_BUF_GROUPS-1:0];
reg [15:0] line_buffer_wr_data_II [LINE_BUF_GROUPS-1:0];
reg line_buffer_wr_en_II [LINE_BUF_GROUPS-1:0];

genvar gi;
generate 
    for (gi = 0; gi < LINE_BUF_GROUPS; gi = gi + 1) 
    begin : gen_line_bufs
        assign line_buffer_rd_data[gi][0] = line_buffer_rd_data_I[gi];
        assign line_buffer_rd_data[gi][1] = line_buffer_rd_data_II[gi];
    end
endgenerate

int k = 0;

always @(*)
begin
    for (k = 0; k < LINE_BUF_GROUPS; k = k + 1) 
    begin
        line_buffer_rd_addr_I[k] = line_buffer_rd_addr[k][0];
        line_buffer_rd_addr_II[k] = line_buffer_rd_addr[k][1];
        line_buffer_wr_addr_I[k] = line_buffer_wr_addr[k][0];
        line_buffer_wr_addr_II[k] = line_buffer_wr_addr[k][1];
        line_buffer_wr_data_I[k] = line_buffer_wr_data[k][0];
        line_buffer_wr_data_II[k] = line_buffer_wr_data[k][1];
        line_buffer_wr_en_I[k] = line_buffer_wr_en[k][0];
        line_buffer_wr_en_II[k] = line_buffer_wr_en[k][1];
    end
end

// generate the sram line buffer groups
genvar ii; 

generate
    for (ii = 0; ii < LINE_BUF_GROUPS; ii = ii + 1) 
    begin : line_buf_group_generation
        line_buffer_group #(5, 16, 30) line_buffer_group_u (
            .clk (clk),
            .wr_addr_I(line_buffer_wr_addr_I[ii]),
            .wr_addr_II(line_buffer_wr_addr_II[ii]),
            // .wr_addr_III(line_buffer_wr_addr_III[ii]),
            .rd_addr_I(line_buffer_rd_addr_I[ii]),
            .rd_addr_II(line_buffer_rd_addr_II[ii]),
            // .rd_addr_III(line_buffer_rd_addr_III[ii]),
            .wr_en_I(line_buffer_wr_en_I[ii]),
            .wr_en_II(line_buffer_wr_en_II[ii]),
            // .wr_en_III(line_buffer_wr_en_III[ii]),
            .wr_data_I(line_buffer_wr_data_I[ii]),
            .wr_data_II(line_buffer_wr_data_II[ii]),
            // .wr_data_III(line_buffer_wr_data_III[ii]),
            .rd_data_I(line_buffer_rd_data_I[ii]),
            .rd_data_II(line_buffer_rd_data_II[ii])
            // .rd_data_III(line_buffer_rd_data_III[ii])
        );
    end
endgenerate

endmodule