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

module wt_mem3 #(parameter ADDR_WIDTH = 7, DATA_WIDTH = 144, DEPTH = 76) (
input wire clk,
input wire [ADDR_WIDTH-1:0] addr_a, 
input wire [ADDR_WIDTH-1:0] addr_b, 
output reg [DATA_WIDTH-1:0] q_a,
output reg [DATA_WIDTH-1:0] q_b
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

initial begin
mem[0] = 144'hfad804f1ef7803b0ef87ef41f36bf5620580;
mem[1] = 144'hf71cf7baffedf003fd6af520055ef06ffec0;
mem[2] = 144'hf899ee2c04b70761f27f024feda302f7fd50;
mem[3] = 144'hee83fd53fa140a03ffa60ab4046df5bffe82;
mem[4] = 144'hfba8efdbf9ecfaf6f10c085c0757f23e07aa;
mem[5] = 144'hf6760b26f0b6fd4c0a3bfc3bee29077bed58;
mem[6] = 144'heeb6fde302aef402f371f4cd04def9300625;
mem[7] = 144'hf1b609c00281ffcafe2f04aefe4ffa2ffde7;
mem[8] = 144'h039d099909c400450e0f020d087bee910d88;
mem[9] = 144'hffb50abcefd6fe57046609e2eed304570b61;
mem[10] = 144'hf580fd32f8b4efcbf1b8f814f7530e39efc4;
mem[11] = 144'hfec8f311f5310573edf2f6bef85f0454fd23;
mem[12] = 144'hf4770c6af8d5f5fe0585f38df17a004201cd;
mem[13] = 144'hfebbfb51f612f776f9baed64fcecf0e40996;
mem[14] = 144'h08c6ff92f45bfa8bfe59fb8d012df618f496;
mem[15] = 144'hf844f4d4fe110264f5660266042102def53a;
mem[16] = 144'h00b5035402d5f65e018eef89f45effd6f8c0;
mem[17] = 144'hf9280151f7cb0895f69cf19d0020f8e90446;
mem[18] = 144'h04520268f9e6091b0260f5d8f6cdf19e0373;
mem[19] = 144'h085a05aef9d3eea4fb8f0179f0cdf9a2fa5f;
mem[20] = 144'hfcd9fe96f0e1f54b0028026ff10005e2fe33;
mem[21] = 144'hff2ffbe4f3edfeb3f0fff59ffe93044305f1;
mem[22] = 144'h036beecd01f40893fbb304370ce6ffec0276;
mem[23] = 144'h034603a5f6eaf508ef04fc42fa91f09b0b56;
mem[24] = 144'hf2b3eea30044fa5c0b46f35806090631fccb;
mem[25] = 144'hf649ee300873ef13fafffff0f34bee24ec9a;
mem[26] = 144'h0b5ef8a708b4f440fbb402b1061bf2ff0571;
mem[27] = 144'h0c37ff51f74cfb1cf561f1c7ed26f4910655;
mem[28] = 144'h022608e2fcf60d8a034cfa2ef41bf5660103;
mem[29] = 144'hf28d00a103adefd50d09ff2b025c0632f6c6;
mem[30] = 144'h029909a0f28e046cec820908ef6ef51bed9c;
mem[31] = 144'hfcfdedccf57deef5f31ff07e04fc05e1ea99;
mem[32] = 144'h0c49ff820618eea6f27afcb1f65d018f024b;
mem[33] = 144'h06d1083d004600f6fcf1043fee75fe5706a7;
mem[34] = 144'hf296f1fb0675ff84ed2dfbf5fe700647efc7;
mem[35] = 144'hf160063eff6feb94ef34027eeb7103da05f3;
mem[36] = 144'h087aef96ff12f1c10b56f31509680b1df3b1;
mem[37] = 144'h0a66ff2206eb065df75debf40b45fb57f183;
mem[38] = 144'hf58fef43f8d8feb7f048f015f662eed3fbe5;
mem[39] = 144'h06a9f5a7f87efccf021a097cf89deb4dfbc8;
mem[40] = 144'hffacf2e9fd44080dfc6900d6063efa0af298;
mem[41] = 144'h0c55fdd9f0f0f07901b309f80a1ef823f28b;
mem[42] = 144'h0b2af5eef8fefda705130567f6230cf0f1e3;
mem[43] = 144'h0ad20865e8cafd2a065efce6f4b6f37f0471;
mem[44] = 144'hee29fc62f9bcfb990b39fa80ed8ff50107c9;
mem[45] = 144'hed19f275f6c505dafcdafc7fec48eb220417;
mem[46] = 144'h011ffa2cfd9cfb71fbf3feac0361fa540ba9;
mem[47] = 144'hff37039df917f83cf47b099ffe7b0245f19c;
mem[48] = 144'heee6f3bffa0ff7b800c7f51ef555ffba0ace;
mem[49] = 144'hecd6f73e0290f015f7c10ac109910bf1f3d1;
mem[50] = 144'hf00e024104daf4620b50089af85ef31dfc06;
mem[51] = 144'hf6530966095609ddf9befaf00884fa590047;
mem[52] = 144'hf3eaf4df094bed7008780cd3fa06fdc70139;
mem[53] = 144'hed96ef8df7e0ec59f2130688005f036fef5c;
mem[54] = 144'hff900999f23409620a91fe7e0b0b057bf379;
mem[55] = 144'hffe10c4d02adf1650ceef081ee80f81cf438;
mem[56] = 144'h0cd703bdfa590e5e023ffe2ef18bfdd8043f;
mem[57] = 144'h0350f22ff3f4ff19fd51028408a40101f07a;
mem[58] = 144'hfb45f39a0b430b0005020755f8c6f5edfccb;
mem[59] = 144'hf6f2fe3407c3097f0db401e6fc5d0e550c85;
mem[60] = 144'h01d807c5f1b20d2efc5101aa004cfeb00c9e;
mem[61] = 144'hf1e30769fae9ec18f7b4fa0405d2edecff4f;
mem[62] = 144'h01bef96b045dee14ef600be90553fb9a0dda;
mem[63] = 144'h0433fc71ed0b0081fab5f9a901f7fd2a0c9d;
mem[64] = 144'h0578fda5004b078bfb080b9df576f1cfefbc;
mem[65] = 144'h05c5fd79f2b10678fd3beca8f71507100734;
mem[66] = 144'hfa5af50afc74fb4e07f508210e44ea31fad1;
mem[67] = 144'hf162f626e9f4f8c00bfaff6efff1f4d50a6e;
mem[68] = 144'h0026e9fcf16c0c18feb10bb6e413f1bf189d;
mem[69] = 144'h08efefeaf4ea0904f502046112d8fa40faae;
mem[70] = 144'hefa2fe8b0736ff3cfabbf2d1f6d8ffadf29d;
mem[71] = 144'hf596ef1febe0f935f858fe30e906f0f1f1fd;
mem[72] = 144'h09610869f005f7e4075000f7f056039eff75;
mem[73] = 144'h0b56f3890185f83102c8f766f744fd0b1cbd;
mem[74] = 144'hf3beea05ee600e42f81603b1f879f8f2e650;
mem[75] = 144'hf626ff76f1380404014cf51c0d7cffb9ff81;
end

always @ (posedge clk) begin
	q_a <= mem[addr_a];
end

always @ (posedge clk) begin
	q_b <= mem[addr_b];
end

endmodule