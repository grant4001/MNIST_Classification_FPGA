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

module wt_mem2 #(parameter ADDR_WIDTH = 7, DATA_WIDTH = 144, DEPTH = 76) (
input wire clk,
input wire [ADDR_WIDTH-1:0] addr_a, 
input wire [ADDR_WIDTH-1:0] addr_b, 
output reg [DATA_WIDTH-1:0] q_a,
output reg [DATA_WIDTH-1:0] q_b
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

initial begin
mem[0] = 144'h0292eaa200a4052b01cf014efa5501f0fdcc;
mem[1] = 144'he553fe47f14ae9350336f320f6d2e4f4e54e;
mem[2] = 144'hf299f05ffe5df9720a1bedceed5e0946f282;
mem[3] = 144'hf11af333ebb3ed15f673f1cef548fbb406dc;
mem[4] = 144'h02daef560ad605410239ffcf0302fd4b03ec;
mem[5] = 144'hf409eefef769f94cf932fca1ee18eb34f926;
mem[6] = 144'h079af8bbf659eaf3f996040dfb1503cdf9ac;
mem[7] = 144'hf61a0604f23803350989ef4efe340a0601e6;
mem[8] = 144'h0168fc0806c2faf9f0dbfe33f146ee790b04;
mem[9] = 144'hfd82f1fbee98ffa7092bee94f949ed5aef7e;
mem[10] = 144'hf019edd3fa5bf392f4a3ef0207e8ed6d0a20;
mem[11] = 144'h005e07cbf3f0f04903a3f1df00aee7fbf70e;
mem[12] = 144'hf160f7660a4cf171f48a0488f63ff5c7005c;
mem[13] = 144'h0326fd7103efefd4ff1100510908ea93ec95;
mem[14] = 144'h03c5f9f1071ef70700ca0499ffb2eb490246;
mem[15] = 144'hf411ffe409b80125ea1c04c5043b0652ee0e;
mem[16] = 144'hfc2ff3f705b704990636ea640d05038df5d4;
mem[17] = 144'hedbc03720544fa6df5e5fec1f81ce191ec57;
mem[18] = 144'h0c6f0307fe1c0c63f478f770fe920ab20c12;
mem[19] = 144'he7c4f31cfa200035fed1fe9de635ef4bffff;
mem[20] = 144'hed80fda80bb0faa6ebc90d47efa805110ec9;
mem[21] = 144'hebf9e9be047df80607d0fa69efcdf552e463;
mem[22] = 144'h030fff5e0b7af142f3c6f9f7e93207aeea29;
mem[23] = 144'heb0be99bf804f38bff1cfb0ff8cef89f06bb;
mem[24] = 144'h03affb2cf0e7f6230331013c0132f6cc0ca8;
mem[25] = 144'hf57b00c007d2fdbef72afb8d068301ebfcea;
mem[26] = 144'h0614099a0094ee77f566082504bdf267ffea;
mem[27] = 144'h04bafde4ff810b2ced5a07e0f34203fa0b49;
mem[28] = 144'h084ef939f8abf95d0162faf3f45e073207dd;
mem[29] = 144'h08e50c4709e8f31af9d00d6cfac3034702e6;
mem[30] = 144'hfd40f7570448f27e0964fcf10366ebfdf960;
mem[31] = 144'hea88009af4e8f89bfd19fa48e8d604400271;
mem[32] = 144'h0cbc0f7b10220632f627f6eaf965fb95f41e;
mem[33] = 144'heb67fd630158f7adf9a5eee1f5cd04c4ef79;
mem[34] = 144'hf2b202deff3ffb76ed0ef0e9fa6508d00ae6;
mem[35] = 144'h0118fd07f508f35ff499f483f10bff3beef0;
mem[36] = 144'h013c05ecf7ccfc09ffc60b140b1ff682fb59;
mem[37] = 144'h0243020c0535f39d07f3005bf536f85efb47;
mem[38] = 144'h01c1ed5502120334f525f8e20ab8ebb9f6c1;
mem[39] = 144'h08b5f9cf050104730894eb57ea1cf956083a;
mem[40] = 144'h07b3f817f5ebf4fd0b1e06260115ef42f014;
mem[41] = 144'hf7030509ecf601d8f215056cfce5020001f6;
mem[42] = 144'hff52f8beefaaf57eec020be5eef3051904c3;
mem[43] = 144'h0360ef4efc44e79beeebeda0fc8def89e712;
mem[44] = 144'hff7f08980bfff3d6022b0bf5007408aef4c7;
mem[45] = 144'he1e1e3f7e92deab7f9b5e3ebfa09e9d3f872;
mem[46] = 144'hf38b0630029ef8c80b7d09bff57600970146;
mem[47] = 144'hfc35079cfd4fff2a023e0a28fe7c0878ee41;
mem[48] = 144'h03fe0552f56fea85f794ff97f907fbd7f729;
mem[49] = 144'hf28ef96bf5d0061e00360242f19e042506cb;
mem[50] = 144'h095d01cd033ff6f8f260fcd60db1072af409;
mem[51] = 144'h005cf650fa84fd88f060f770f4c0050706ba;
mem[52] = 144'hf6cafce0f578ee890a62f418f9f5f3a4f6d8;
mem[53] = 144'hf7fa03feeb2e02ebea4e001be8a0ed9fe508;
mem[54] = 144'hef54ee9f0904f1e0ef450d2104f0fc77ebb7;
mem[55] = 144'hf165f13debeef4ce094ff78307d2098af156;
mem[56] = 144'h01f6ffa2f67e00a6fb46fef2fda6f0c3025a;
mem[57] = 144'h081afae5f9040580f8cc001201d2efe2fb77;
mem[58] = 144'h0ba503bef32bf0bd075bfab9f23b0e5f046b;
mem[59] = 144'hfdae09b60e19f7340a9709ee08cffe05f16e;
mem[60] = 144'h04cc00c0fd7903d70cb7fdbaf6dbefa90af1;
mem[61] = 144'he59fee2ffc7bf245eccededef0d0e966e114;
mem[62] = 144'hf6c30499f304eccff2a50064fe39ef3af6b0;
mem[63] = 144'h0544f688f72efe1ff922fa3ffb22039df6fc;
mem[64] = 144'hf869101505c2f79cfbebff11edc7ee3cf7e0;
mem[65] = 144'he29803e5f57fef9ff0070053e84d05a6ef78;
mem[66] = 144'hfbb9ef8bfcc1f057edea02a6047aec07fa4f;
mem[67] = 144'h104ee8d701361e7bf8e90274fcd80296dc74;
mem[68] = 144'hf29df7e8e960f485de95fe35f71bf69eea61;
mem[69] = 144'hfd2e169f0c86f362ea9feeacf0e62c22080e;
mem[70] = 144'h2261f84ef640f4e4f346080efe8dfa991073;
mem[71] = 144'hf47cf5f90f5d0419f392fd1105d4e7d5f43f;
mem[72] = 144'h0ff1022514dfeffbef79fd4bfb22ebe8ea36;
mem[73] = 144'hfbaefd4905d5e595f598f78605a2f127007b;
mem[74] = 144'heb80e88607fff147177ff18bfe89e3fa0573;
mem[75] = 144'he707e566fcaceb4ff637fbe20969f39cf22e;
end

always @ (posedge clk) begin
	q_a <= mem[addr_a];
end

always @ (posedge clk) begin
	q_b <= mem[addr_b];
end

endmodule