`timescale 1ns/1ns
module bi_mem0 #(parameter ADDR_WIDTH = 4, DATA_WIDTH = 128, DEPTH = 16) (
input wire clk,
input wire [ADDR_WIDTH-1:0] addr_a, 
input wire [ADDR_WIDTH-1:0] addr_b, 
output reg [DATA_WIDTH-1:0] q_a,
output reg [DATA_WIDTH-1:0] q_b
);
reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
initial begin
mem[0] = 128'hfd45f68cfd7ffef70016f9eb013005b6;
mem[1] = 128'hfe1dffef00cbfdec0789f6e70000016e;
mem[2] = 128'hff5bfd29f9f6fdcf016cfd24ff6a04ed;
mem[3] = 128'hfe13ffec073b03bff6befb48075904c4;
mem[4] = 128'hfee8fe4cfe2cfc0e006e0552f7befb4a;
mem[5] = 128'h078afec3ffbbfeeefc42fe4bff09fd51;
mem[6] = 128'hf6591e6010e7fd181915e348e4780e4e;
mem[7] = 128'h1c4dffabe5dce45bec861c9407dae172;
mem[8] = 128'h0fc7e46b121cfc241cb004c1f5c7053c;
mem[9] = 128'h1dcee4d6fe7ae9db0fcc1cb9e3ffe00d;
mem[10] = 128'h17e9f8dc10220599f48f02feec631da3;
mem[11] = 128'heb91f07ef420e5d5e860fa4705920d14;
mem[12] = 128'hfa86f8fd10a8e766ebbb0306e7631ab8;
mem[13] = 128'hf3b0174de3d71917e7a605f70d221f80;
mem[14] = 128'h0486e85d13dbfc6ffa0a1e24e4aa04bb;
mem[15] = {32'h07deeaa1, 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000};
end

always @ (posedge clk) begin

q_a <= mem[addr_a];
end
always @ (posedge clk) begin

q_b <= mem[addr_b];
end

endmodule