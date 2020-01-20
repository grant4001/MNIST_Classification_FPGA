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
mem[0] = 128'hf6cff317f5c8fa69f638fa01fbbaffeb;
mem[1] = 128'hf81f063a03dffaa7fe7bf5a3fa22ffee;
mem[2] = 128'hf852fe23f8e3f9bf08a4f8d7f6effa41;
mem[3] = 128'h052b0609fff9feaaf573f9e90722006c;
mem[4] = 128'h0306fd190510f912020609f4f7e8f62d;
mem[5] = 128'hfd45029ffc86fcbffdb7fe39f6f2032f;
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