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

module wt_mem0 #(parameter ADDR_WIDTH = 7, DATA_WIDTH = 144, DEPTH = 76) (
input wire clk,
input wire [ADDR_WIDTH-1:0] addr_a, 
input wire [ADDR_WIDTH-1:0] addr_b, 
output reg [DATA_WIDTH-1:0] q_a,
output reg [DATA_WIDTH-1:0] q_b
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

initial begin
mem[0] = 144'h00a003d9f1110472fb51f6afecc0e93d0469;
mem[1] = 144'h0140f60b0053f04bf160fb9e0776f3ddf629;
mem[2] = 144'hf637efeaf9e7eee4f2e7ee47f455f3920720;
mem[3] = 144'hf3c9fb89f8e4f172f715f126f4cb0bcc0971;
mem[4] = 144'h0349f2a0fa5afe22083eeeb8f1ffeb2d090d;
mem[5] = 144'hec3a02baf733fbddf36a08d7066af8f4f18e;
mem[6] = 144'h010d02ceff8d0a3af437ece6f3b40114f471;
mem[7] = 144'hf8c801fcfe17f1c3fd0a00e70b2e0162fe7d;
mem[8] = 144'h04570bb3ffdaf29cfebdf000086907def217;
mem[9] = 144'hef03f2e4f62df265eebcff64f15a00b60298;
mem[10] = 144'hef35fbf6f336f68bf8bb0af6ed66f354008d;
mem[11] = 144'h087dede7076c0639ed6f08b004caeea901af;
mem[12] = 144'hed2e00e3ee27f426ef9beb8d050cf198fb53;
mem[13] = 144'h0bb40551054efa1d0348f067f23502a1028a;
mem[14] = 144'hecff034f0458f998f970fe9cf27c0888f0ad;
mem[15] = 144'hf7fdff3efef4fe7bfe9af12505190073048d;
mem[16] = 144'hf1f2ffc2f7390697fd4b008aee4f03f60366;
mem[17] = 144'hf374ec3604ddeefb06c3f73ef5dfee88ee86;
mem[18] = 144'h011aefa40b0cf3acfad906f3016c0249fa53;
mem[19] = 144'hec58f19ae97dedaee8faecb6f3effc0fff2d;
mem[20] = 144'hfea5fd62ffe5f879ee37ee88f108ffdaed56;
mem[21] = 144'hed92f1f4f1c8f6baea89f2fcea83f117eefd;
mem[22] = 144'h000ff62e066bfd3afce5ffcbf9b803b40327;
mem[23] = 144'hf4200a32f38902fbfe87ef1af380ff20f45a;
mem[24] = 144'hf862091e0d11fe0ef7e4ef59044c01deff57;
mem[25] = 144'hf35a079af177f386fb080ac9f6f4f92df987;
mem[26] = 144'hf6c90b49edb90641f10f00300e1ef55df13e;
mem[27] = 144'h05a807d5fd35037ff736f8cb0793f76808c3;
mem[28] = 144'heedcf8ba041ff567f64e0d3bfbbb0cb9fccf;
mem[29] = 144'h078ff5cb0da30db604df0d93f443fab6030c;
mem[30] = 144'hedc1fb1f0603fb040451eabcf93e0137ef82;
mem[31] = 144'hff0503c5f7fdf9ee0431f601f0a0f705f11e;
mem[32] = 144'hff3c0141ee51fd6af08d0d04f8b4f2c30afe;
mem[33] = 144'h05a1fb82ffa10a97f8f4ff35f211f1e8f21a;
mem[34] = 144'h087afb23f579fd61f70b09f30842f9dbf79b;
mem[35] = 144'h080a0590f959f241f2d40296f413eceff51b;
mem[36] = 144'hf4b3eff007ce01ba0cd806fb063feaaeebdd;
mem[37] = 144'h04a1ec6a017e0081f3e0fa440b7d0c5c02ea;
mem[38] = 144'hfa37fa7b054a010efba6ed73f4530870f5eb;
mem[39] = 144'h083ffdd0fd09f1e5f7ad018803f4fb890267;
mem[40] = 144'h0abdfd4b08ca0c48093107e9ed3df51c01f8;
mem[41] = 144'hf5d5edd30647f5b303210dff058b00ecf990;
mem[42] = 144'hf99b0925f35ff5bdff5bfa60029ef504eb64;
mem[43] = 144'hf5e1eeebf165027a07e7f944ffffffba0636;
mem[44] = 144'hfc18ffc7ef43f82eff7cf765f0c40353efaa;
mem[45] = 144'hf4c1f989f916f7d2efabf2df04f9f894e7a7;
mem[46] = 144'h06c1f73cf037fd080d9906620878f6f4089a;
mem[47] = 144'h07b0f02bf8630dc9f7d20c250a58f6a8fee2;
mem[48] = 144'h0b90f5a108a5fd37f1a205a5fd87eca7f213;
mem[49] = 144'hf322004ef66b0d83f26df19ff147f3f0fbaa;
mem[50] = 144'h098c04e4ef6a009ff8acfb8803e4f4f101b4;
mem[51] = 144'h0b7bf23bf4faf125f640f068fe260aaeff84;
mem[52] = 144'h00270378efe4003f052ff78501adfc0404b6;
mem[53] = 144'hfbed021bed42f689fd91f6daf81bffebfcc5;
mem[54] = 144'hf3ebf1c3ed28f21ef2ef0b6cf1730b73ee43;
mem[55] = 144'hff220df2fdbbfa430097fc5dfcc10b1b06bb;
mem[56] = 144'h002407bcef44f9d0f28ff306f533fe19fd4a;
mem[57] = 144'hf212f76df4ea004b0dd003950cd7f94a0d22;
mem[58] = 144'hfd6ef644fa6afdee0b8d07cb0d83ef9efa25;
mem[59] = 144'h0f2e03470a540ef90682f568f752ff59f339;
mem[60] = 144'hf297e787eefde893fa97fc82fee3f685f434;
mem[61] = 144'hf163f8e2fcceefbeeadff6f7ebbafd0101f6;
mem[62] = 144'h0822f6590930fbfcfe29029707abfa400883;
mem[63] = 144'h06bfeec8ed5cfed8016aefa4f518eea4fb51;
mem[64] = 144'hec28faa7fe1df8dd06b5e97ff482f322ece8;
mem[65] = 144'hf992ffe600c8ff3d0485f548f735fd53062a;
mem[66] = 144'hf56b09e1fdb60a8a02ecf393f442f6cef0a4;
mem[67] = 144'h00ef0e12f6dffb6f14fbf637f52b28b10c1c;
mem[68] = 144'hf985fc2822b8f0ed0589e9ed0236e61af119;
mem[69] = 144'hf2c1f565f90dfd8cf484035efd2bee50f6e5;
mem[70] = 144'hfc0a0b50fa2309cd067ff262f217ef77fc9c;
mem[71] = 144'h04500253e4740a56f19eef38031be80e02ae;
mem[72] = 144'hfc9dfb89ffe00748f595073ef31fec39fe2d;
mem[73] = 144'hfa75f989ec67f2e9fdb6e2d00bc7f29af446;
mem[74] = 144'hf82efb3f0a0af15b1abf028a060cdebe0625;
mem[75] = 144'hf917fdcbff5614ef0628eec8f0c5ee8ef88a;
end

always @ (posedge clk) begin
	q_a <= mem[addr_a];
end

always @ (posedge clk) begin
	q_b <= mem[addr_b];
end

endmodule