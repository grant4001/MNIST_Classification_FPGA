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
mem[0] = 128'hf9e0fe01f8b3fde3fe94fd4ffff6fbe9;
mem[1] = 128'h004aff040106fc99fd69032ef48904ed;
mem[2] = 128'hfbd4ffa5fd1efdefff34fd7a01600068;
mem[3] = 128'hff93fda8ff1affb0006c0357001d010a;
mem[4] = 128'hff7b049300df015106a9ffe70768faa1;
mem[5] = 128'h033f0060ff05ff8108a9fd380183fac8;
mem[6] = 128'hf54e0e1103af04c9f7a1f2c5f5ef0c04;
mem[7] = 128'h0c8601b8fea0f9c7f4e70c420356fbd0;
mem[8] = 128'hf3120e02086efbaafd7af439f9d205f8;
mem[9] = 128'hf8540678fa0f0a71f94f0892f139f39d;
mem[10] = 128'h036800cdff2a032e00acff310dc3f358;
mem[11] = 128'h02960378f260112b0db2f550fe2601dd;
mem[12] = 128'h0b820caaf74303e2f4d00546fef00a93;
mem[13] = 128'hff0f0b8df731fbcaf89bf454f7a8f02b;
mem[14] = 128'h06840690f59601d50143fe1c0a3bff0b;
mem[15] = {32'h0110fd17, 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000};
end

always @ (posedge clk) begin

q_a <= mem[addr_a];
end
always @ (posedge clk) begin

q_b <= mem[addr_b];
end

endmodule