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

module wt_mem6 #(parameter ADDR_WIDTH = 7, DATA_WIDTH = 144, DEPTH = 76) (
input wire clk,
input wire [ADDR_WIDTH-1:0] addr_a, 
input wire [ADDR_WIDTH-1:0] addr_b, 
output reg [DATA_WIDTH-1:0] q_a,
output reg [DATA_WIDTH-1:0] q_b
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

initial begin
mem[0] = 144'hea4df43dff27f61dfad1f0b2044aef66f7bc;
mem[1] = 144'hec1401bdef7cf571f496f108f34207e7efe3;
mem[2] = 144'h0521f67af4cd03740498083c0096fd5b082f;
mem[3] = 144'hf00503c1066f00e0028df58efd4e0b430393;
mem[4] = 144'heb27f88ff2fbfed7fac7064cef410491f046;
mem[5] = 144'h006af0d0fc620774ebb3f49ff973fda5ed9d;
mem[6] = 144'hf318fc730564efbafbd0f791fe7501830210;
mem[7] = 144'hf6dbfb2e05ddf2f4093cfa570660f8ef069b;
mem[8] = 144'h043cfedc07e1fd5debd3fab70988ef1c0661;
mem[9] = 144'hf717f29408a3fae7031cf14bef73f8640c92;
mem[10] = 144'hfe0000d9fee3fc170217f946033cf268f404;
mem[11] = 144'hff14fc80ea4500f8e805eee5f598049e01db;
mem[12] = 144'hfe61f707f82c06d8f40df50bfe56f870fb68;
mem[13] = 144'hf80b09000b4c0623fcaefa5e049500abedeb;
mem[14] = 144'hf0a2ff17fadaeb7209060d35ee8cf7020b8b;
mem[15] = 144'hfe60f19afcab0a91f9b5fa8b01e9eed40cbc;
mem[16] = 144'he7abf97eeeec0385f7d0fbaaea95fba10525;
mem[17] = 144'hf421f2f4e49a00a9fd6ff5830724fc6bfdc3;
mem[18] = 144'hed0eef11f4d8fff1f1f6f799eef5f2a7f3ab;
mem[19] = 144'hf045efeafa1bfe96fb5cfcd3001807a4ec2b;
mem[20] = 144'hf166f642ee6df46df5a5ed50022ff445e7be;
mem[21] = 144'hf2a2fb85ea94f6a8efd7e467e756f046008c;
mem[22] = 144'hec75fd390389f84ce9eceebded6efe31f92a;
mem[23] = 144'h04e4f6b0f7a200ccedddec9cf22f0274f089;
mem[24] = 144'hee72fc3af866f63e08d0fc53fe59fd3d028d;
mem[25] = 144'hf96bfae0fa83f2a40367ff6ff445f88c09a9;
mem[26] = 144'hf997f1c9f3daed50f106f783039cff0ff8a1;
mem[27] = 144'h07250a10f3f2f9dcf682f9c804c4f234f76d;
mem[28] = 144'h0c58fe5b09deeffdf045fbedfe0d0ad306f5;
mem[29] = 144'h0693f19defde01580d79fd7e076109b8f92c;
mem[30] = 144'hf5b30a07025d0465ec450528f6ccefa90056;
mem[31] = 144'hebd7fb9bfb71e654e9d9e336f7e5fb58e324;
mem[32] = 144'hf48af674eede0150f58cfeaef035f758f5a0;
mem[33] = 144'hf1b70925f8d4f5d2f3620221f5c1f59cf0cd;
mem[34] = 144'hfa09f46a0282f25df82a0129fee902a402ad;
mem[35] = 144'h07e801a4fe3ee97be8e8e4fae81ae3a6fe5e;
mem[36] = 144'hf62ff6c8fda1f4400102f786ef3cf15bf8c0;
mem[37] = 144'h06ee05ddf957ef6af17f062b0682edf9fa67;
mem[38] = 144'hf94b01de00c7f046f54efcedecfaff7600f7;
mem[39] = 144'hfa9eff7ff658ec53fcf1fe08e79bef2afb30;
mem[40] = 144'h022ef863ff02089503bbeef201d806e20a1b;
mem[41] = 144'h0561f23aee9001ba0d03ef7befbffd78f27b;
mem[42] = 144'hf1f5f699ef5ae911f32d01f8f200f37b01a8;
mem[43] = 144'hf37a05a102f5e9c4e85defdcffcaec5a021d;
mem[44] = 144'he807efdef412ee2cfc5bfaabee10f3d7e6b6;
mem[45] = 144'hfd8ee324ef31f19bfed7edccfc44e492e82d;
mem[46] = 144'hf9120afaf884f9b9f56d041bf5cdf3730235;
mem[47] = 144'hf5d8024ff7d6fd9ff27a060e029af2e1fc29;
mem[48] = 144'h0344f19bf0e3feaaf2c1ec0afd50fd05f02d;
mem[49] = 144'h08c5ed4bee31fa8aff24ffdff6d8f305f6f5;
mem[50] = 144'hfac5f117f2a4fedaf8a9f7d0f6300918f78a;
mem[51] = 144'hff6afdc8fbdefde8fc41fb85f1c9f1b5f36b;
mem[52] = 144'hf7cc0800059ff665fa40fb0bfc53f926f531;
mem[53] = 144'h00b8edca03000289f845e9d9fd8eeeb0f4aa;
mem[54] = 144'hf16e08130168f0f9f431ec6ef93105c20572;
mem[55] = 144'h0b3ff6b9f16501d1061cfc97f0440719f49c;
mem[56] = 144'h0ce9024df6ce01e2fa33054df2210cdcfeff;
mem[57] = 144'hfe4afe08f6aaf08606ca034c0a7df08ef285;
mem[58] = 144'hf02e006af3f3f164fb03f4320ceefb05fa8b;
mem[59] = 144'hf930ef50f7380bff03d3f1b70a5b08fcf80f;
mem[60] = 144'hf6080486f6cafb4ff2b9eb7ceaa700d3ea58;
mem[61] = 144'h0226f03fee2ff4a509d3f8e3ff9b00acfcb4;
mem[62] = 144'hfb90ff57008703d1ff3a07afeb9605530984;
mem[63] = 144'hef26045800b7fab30904018df0d9eca2f4a0;
mem[64] = 144'h03e9050df365f4270424037aeaccf575fa9a;
mem[65] = 144'hf8b5fe46fa3aee8afdcd009aeef6f2fdf22a;
mem[66] = 144'hef07ee72ef97038e082cf08cfc5902a8fb56;
mem[67] = 144'hec7cff13fca9f042f64ffc55086ef1bc15d8;
mem[68] = 144'hef8cff2ff36dfa8af15300a2f963fcf0ed5f;
mem[69] = 144'hefa8efc0f7ee0a2ef71ffe80fc37080de94b;
mem[70] = 144'hed3ff20ff7a8f7fe04480a67f700099f00dc;
mem[71] = 144'hed70f1490122f5420036f1bcf3690915e5f6;
mem[72] = 144'h2c35071af06205e9fea3fdfc0375fca0f00a;
mem[73] = 144'hffbffad601c5f507f11b0391fd6b0172e708;
mem[74] = 144'hea39f9370d43f693f67f01f2fbcd0590ee6d;
mem[75] = 144'hf159f61af8cd041a0061f3d4fffb0534eef6;
end

always @ (posedge clk) begin
	q_a <= mem[addr_a];
end

always @ (posedge clk) begin
	q_b <= mem[addr_b];
end

endmodule