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

module wt_mem5 #(parameter ADDR_WIDTH = 7, DATA_WIDTH = 144, DEPTH = 76) (
input wire clk,
input wire [ADDR_WIDTH-1:0] addr_a, 
input wire [ADDR_WIDTH-1:0] addr_b, 
output reg [DATA_WIDTH-1:0] q_a,
output reg [DATA_WIDTH-1:0] q_b
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

initial begin
mem[0] = 144'hfbb801b9ffcffabf041800090243f6aff27a;
mem[1] = 144'h09b0eb1bfeb1ebc60658ffb0f9d8ea0901cd;
mem[2] = 144'hf134fe6bf8460d57fcb8ff3606abfc0aff0e;
mem[3] = 144'h0684ef49028d09caf4eff1d70682f76a03bc;
mem[4] = 144'h0d46f9dff9b7f399f3e30c60f1b0fdda0bd2;
mem[5] = 144'h0117ecca01b20044f5aef857ee9afd6402ca;
mem[6] = 144'hffa203130ce1fb45038ef6000273027f0562;
mem[7] = 144'hf64f0231edd702a801a0f568f7cef8d7f911;
mem[8] = 144'h0163f1490595f6e901cc092803a503210d2c;
mem[9] = 144'hf5fdfa130785f72901bbfef8f866ed5a072c;
mem[10] = 144'h0012f916ee5ef318f8e2ef68096c065402c9;
mem[11] = 144'hed7eeee7feaff95306a80bcaef2cf70dfbde;
mem[12] = 144'h01adf33ef97df34106310353fae90a58f800;
mem[13] = 144'hf47e01b9f800edbb02d8f7cf050501fa0699;
mem[14] = 144'hef16ff4b015304630a71f1b9076d0aa3f489;
mem[15] = 144'h0800fb99f044ef5d03fef64dee83f6d3f280;
mem[16] = 144'hffa3fd36f87cf8aefcc6fba607eb09fb0cea;
mem[17] = 144'hed0bf0d5f1f0ea81058401d0fd4807480633;
mem[18] = 144'hf93f0abc0446fd1b0601fcf504caef44fc6f;
mem[19] = 144'hfb35019e0267ef4af9a5f767fc2804fff967;
mem[20] = 144'hff7af544faa9033f0076f13cf8f10945fbee;
mem[21] = 144'hf9a0fdbef873068a036cf469eaa9f145f799;
mem[22] = 144'hf5270d0bf3c4f4c1fbd6fb4cf909f726fa13;
mem[23] = 144'hfed0ffb3f3660a62f666fb9aee4d06dbf957;
mem[24] = 144'hfb96066cfe9d04ae0d970ce4ff880c96f237;
mem[25] = 144'hfb77f20709a7ee5301a70a6deebef6590d50;
mem[26] = 144'h01750ad609de0bb20034eeb109a401450a9f;
mem[27] = 144'hf83a04acee6a010ff0c0fa2d081708390482;
mem[28] = 144'h06160d59f82efb2001d9035ffd040a54017b;
mem[29] = 144'hf1c302aff731f835f0dc0a1bf587f792fc98;
mem[30] = 144'hff67fbc101560489f0c506820c8fefd10332;
mem[31] = 144'hf98ff4a6fd21ebcb060c07e4057df2d7ebda;
mem[32] = 144'h02500d6ef77b0b62f4b3fad4ff47f1f7fb91;
mem[33] = 144'h08c704330afdec7ef997f9b2015ff93dfb19;
mem[34] = 144'hf4aa07da02bb0584fe310a2e04fbfb8102bc;
mem[35] = 144'hfca5feedf8d301e8f8fbeb44fed7f2defea8;
mem[36] = 144'h08870208efeb05d5fc6dfee9f644f0bef781;
mem[37] = 144'hfec8fdad0793f453080af3a9f0ff06f8fbf8;
mem[38] = 144'h069904810980fbd5ff8601db03a402fe08e4;
mem[39] = 144'hf14b01b9fa11f1a4fbdafab7040e057cf1df;
mem[40] = 144'h004e0cce0d4ff5b30a9ff415f84e07d4feea;
mem[41] = 144'h0562f94a054efa22f75efb77068c0cadf12d;
mem[42] = 144'h0331fbbcf60f091d0b630762f7da04a9f81d;
mem[43] = 144'hee47fd2306d0f598ff3806d5f409f4aa05cc;
mem[44] = 144'hfc0904cdfb9909ac0d29f4b1fa68fed8f891;
mem[45] = 144'h043f007603ecfa1d0b4100c0f4600360fc30;
mem[46] = 144'hf103070afced00def62c0a25005001ee045f;
mem[47] = 144'h07e903fef7c205060cba0787fccafe16f612;
mem[48] = 144'hf3150a420c36f4a201fd01bcf832002eef5e;
mem[49] = 144'h03abf7bf0af50c7ffff2fbb50120ed47f71e;
mem[50] = 144'heee0fac3f0a70d93fea504f104e006cb0443;
mem[51] = 144'hf5850dae097f053c040a0ae9f305f1a50cbb;
mem[52] = 144'hf274f1b7f603044ff516049bfaf7f5d40667;
mem[53] = 144'h01d4f0a400a1eedbfb86026ff78706a2ffc7;
mem[54] = 144'hfcc1f4a008f1049cf6d90a760c3a0320fb87;
mem[55] = 144'h04d50be40555ee28ee190c5306a60675f32b;
mem[56] = 144'h0780f9ecffd8f83afc20fa49f6b806070ad8;
mem[57] = 144'hf19608b20cecf9f60345f0e008e00d5802a7;
mem[58] = 144'h0d3d069ff107ffbef00ffcea0367019efe4a;
mem[59] = 144'h08f00f470e2105ce0eff00770e22f40bf1ae;
mem[60] = 144'hfd250bb4f17df81403fdfed001950cecf27c;
mem[61] = 144'hfc76f086fba408a8ebf3f4e5f72705d1fee7;
mem[62] = 144'hf729faab02fc0907f6c0f88ff06cf2b20cf3;
mem[63] = 144'hfb400b37f1dcf386022a02a5edbbef3ff7aa;
mem[64] = 144'h0ae401f7fe2f06330332f860fbc2f2720069;
mem[65] = 144'hf1c3ecd2f1430074fb12f115015706580436;
mem[66] = 144'hfc97ffb4fc14f11b0b9533f3020b0049f159;
mem[67] = 144'hfc9ff78ff5c0045dffbffa180915f557f03a;
mem[68] = 144'hfedffda50180eb61e910ec98f7cdf2400d63;
mem[69] = 144'h00aeff520e03fd80f4a3f160ff5100f90588;
mem[70] = 144'hfb4e0272f606f2ebf038f5c6ef2101de049e;
mem[71] = 144'hf62ffa67f869f27df5d7e3460a83099b0732;
mem[72] = 144'hfba4f247efcc007df072fa5f0b03efccf5af;
mem[73] = 144'hefcffa430e2d04f0fbddf5f201b3f25a050e;
mem[74] = 144'hfaa6f088f4efef84fda5f168fef90ce5efc4;
mem[75] = 144'h028b07510210ffbdfea6f75e01cb06750d19;
end

always @ (posedge clk) begin
	q_a <= mem[addr_a];
end

always @ (posedge clk) begin
	q_b <= mem[addr_b];
end

endmodule