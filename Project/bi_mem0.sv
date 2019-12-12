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
mem[6] = 128'hfab40e67049007051261f050edd812e7;
mem[7] = 128'h0dd1fd4af155f150f0011409064fed00;
mem[8] = 128'h0174f22e129f04f41b930cd0f0db00cb;
mem[9] = 128'h0bf00070fdb3f37d050308a5f039eec3;
mem[10] = 128'h0596090a044f11abf9eefdc1f4400818;
mem[11] = 128'hf369f830f77ef1c0f0dcfa1c01790597;
mem[12] = 128'hfa48f8790a56eeb5f1b9ff40f9a10819;
mem[13] = 128'hf6d40624efa4095ef277023d0deb087e;
mem[14] = 128'h094c045d10c80a5809d41c7903a10931;
mem[15] = {32'h0a680611, 96'b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000};
end

always @ (posedge clk) begin

q_a <= mem[addr_a];
end
always @ (posedge clk) begin

q_b <= mem[addr_b];
end

endmodule