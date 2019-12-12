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
mem[0] = 128'hf690f3b1f62cfa55f540f9fdf7f2fbf1;
mem[1] = 128'hf83d0959fdeffa7ffc4df5adfa10ff9f;
mem[2] = 128'hf85e02adf8cff9c20194f94ef531037c;
mem[3] = 128'h015f001ffc6bfe31f56cfaae0642ff35;
mem[4] = 128'h0794fd46034bf991fcdf0616f7eaf3d0;
mem[5] = 128'hfc2c0420fc21fd22fd8b0575f7a1fd7b;
mem[6] = 128'hfb0d0f2a0861fe800c4bf1a1f24d06a2;
mem[7] = 128'h0e04ffa5f2eef234f6470e6303aef07b;
mem[8] = 128'h07f2f216087dfdf70e340207fae3029c;
mem[9] = 128'h0f31f266ff5af4e807d20ddaf221f002;
mem[10] = 128'h0c26fc34080e029ffa5a0181f6240ef9;
mem[11] = 128'hf5dcf815fa22f2e2f413fd0a02f7068a;
mem[12] = 128'hfd03fc7707b1f3e1f5c901d4f39a0d4e;
mem[13] = 128'hf9b00b95f2380c8df3a302f6066c0fa7;
mem[14] = 128'h021af34b09d3fdf1fce30ee4f229027d;
mem[15] = {32'h0418f5c1, 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000};
end

always @ (posedge clk) begin

q_a <= mem[addr_a];
end
always @ (posedge clk) begin

q_b <= mem[addr_b];
end

endmodule