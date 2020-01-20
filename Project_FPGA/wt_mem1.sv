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

module wt_mem1 #(parameter ADDR_WIDTH = 7, DATA_WIDTH = 144, DEPTH = 76) (
input wire clk,
input wire [ADDR_WIDTH-1:0] addr_a, 
input wire [ADDR_WIDTH-1:0] addr_b, 
output reg [DATA_WIDTH-1:0] q_a,
output reg [DATA_WIDTH-1:0] q_b
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

initial begin
mem[0] = 144'h05d80544ed62ebcef524f4d203effdf1038e;
mem[1] = 144'hf8d6fc18f921f242e9bcec29f160f52cef05;
mem[2] = 144'h095df703eefcfac5071e02aaf92ff6ebf943;
mem[3] = 144'h08c7f293f278f73af64afe05efedfe90003e;
mem[4] = 144'h005bec7bebdbfafbff11f941fa07eaeeedae;
mem[5] = 144'h0021e9d3e150f952f0aaf02ff0a1f06be819;
mem[6] = 144'hf13af5ceea0effb401f8fcca05c900e0f78f;
mem[7] = 144'h00f6ef98ea7ffba1ee6ff8b909f2edd7f974;
mem[8] = 144'hf8940560ee330351f6faf0070756fed9f141;
mem[9] = 144'hf9adede10689fc90fbccf3adfa1506a2f17c;
mem[10] = 144'hfa3c0353f0b007e00230ffbeed75fc1cf51f;
mem[11] = 144'hec3febb1fbbbffcefc45fd54ecffefd1f275;
mem[12] = 144'h0180ef6aefde01a0fedcef45fc06f032f169;
mem[13] = 144'hfb050534ff89f0c4efdd07adec7def3cfaa2;
mem[14] = 144'h0b57f4520196f492f927f27a0901ef7fed0c;
mem[15] = 144'h0b72f645f987f76b095ff3870b74fbeeef2c;
mem[16] = 144'hf2e7f8d1f323fd50f59d026c074afb13f572;
mem[17] = 144'hf07bf7b2e86bfab2f7edeca9fbc9fb93e2fd;
mem[18] = 144'h03bc0b65fad1f9c10976f7700a15f90b060a;
mem[19] = 144'h0150069bf29704f2f8a4f452f8cef708f51e;
mem[20] = 144'hf04b06340827ea00fe69ee62f7f9fb85086a;
mem[21] = 144'hed5d05bdf1affaa6eeccf42403fef618e8a2;
mem[22] = 144'h01cff8ebf3e2edd6edf1ffe0f7d5ebfdf4b0;
mem[23] = 144'h06dc01c5044e0679f016eee9fd86f7c609c7;
mem[24] = 144'hf7e3023d0379f52a0afbf291f4a2f1d30cba;
mem[25] = 144'h0482057b0460fcd1036e0799f4b9f7adf86b;
mem[26] = 144'hf948f77209b109b2f47cf05affbffc1bfc03;
mem[27] = 144'h04f700d2f7f8fd0bf305fd71f4bffae60b74;
mem[28] = 144'h0c96081006ddee87f5da085f01100b2d0038;
mem[29] = 144'h08c70d80058cfb320061fdf1028b0bfd0247;
mem[30] = 144'hf962f787009f09c7f4b8f835075aef9af169;
mem[31] = 144'hfb07fd4fe93503b7ee16e8a203e9fc04ea8d;
mem[32] = 144'hf108f6e4fb77f96102d8f52e0226fe7304e6;
mem[33] = 144'hfa87ffd4f3c10a8af8b50581fa48ec5cf639;
mem[34] = 144'hf3cbf9c8fec5f9b3f37dfa4b019a0763f21f;
mem[35] = 144'hfcc4f58befcbf7b40346f2a7f0bbe62df253;
mem[36] = 144'hfc3c048e040f0a06feeeee05f5c00563f51a;
mem[37] = 144'hf421f371f2a4f26fe9bf0a5aee1df746fb2b;
mem[38] = 144'hf77bf5b30870074effe709b8f8bbf9fd0368;
mem[39] = 144'hf2cef5b3ec18ea9400b40425022aee550366;
mem[40] = 144'hed000185f467f84ff8f5ffeb087500110c0e;
mem[41] = 144'hf3d5fb41f3a50856ef1cfd52055bfe0bf7e8;
mem[42] = 144'h0673fbbffa09fcabedc2fd76f22a081cfe04;
mem[43] = 144'h0467f130eaf1f614e837f335efa9f809ef19;
mem[44] = 144'h0694ea05f90df72b04cc05fdf559fb330259;
mem[45] = 144'hf575de01e313f0dce934f952f15debf2f0cb;
mem[46] = 144'h0a30fdc90ba0f754fc10efb7072e07070356;
mem[47] = 144'h046207d502070881f09e0173f1800558ef95;
mem[48] = 144'h073d0b46fbfc00aaeba3fe0101a4fa43eeed;
mem[49] = 144'h0a2effb60748f97403e5085afc73f5b20269;
mem[50] = 144'hf535f5b607fcfe2d01eff35bf5120974fa17;
mem[51] = 144'hf45e05dd0093f6d000f8f33403fff93a00a7;
mem[52] = 144'heed4034fec84f5b8f1b0fa890ce00d33f93a;
mem[53] = 144'hf45f008df99ff642f308fd11ee49faa000f2;
mem[54] = 144'h0b57092403b0f60b09aa0b02fe56f3d50c69;
mem[55] = 144'h03a5ee99ec99fa3205a0fde6ee0900a002d4;
mem[56] = 144'h08a1040a0ca0f257ee8ef129058efdb305f9;
mem[57] = 144'h010df3240aebeef3f44e073df9acee2af852;
mem[58] = 144'h031f0221fa42fdc70240feecefaf03b4057a;
mem[59] = 144'hef4cff7eef32f437fb56090a0010f8e40374;
mem[60] = 144'hefc209ca0570fc2a01e206b2edb30474ff11;
mem[61] = 144'hfd78f11501a4ebc6ea4ff260f84602e0eac5;
mem[62] = 144'hef09f1680887f5deeb6ef2180563fa4afcfb;
mem[63] = 144'h006eed5c06060663f58af4e4fa93feb3faa6;
mem[64] = 144'h0553f74e0456f08d01b0fbc80340e9d0075a;
mem[65] = 144'hf029ee29f77bfb15f46fe9680343faecff86;
mem[66] = 144'hf68df0b8fcbcf383f3cbeeadfbb20121ff32;
mem[67] = 144'hf4090838032f0d9af2e5eeb00be0ef14f27d;
mem[68] = 144'h05d1f9bcfe21f148f997fab0f4f9fcbf0f1f;
mem[69] = 144'h04a2062301370892e4bdf5780c3af611fc2a;
mem[70] = 144'hf878072ffd1eedb0f8a91776fc4bf317f8b5;
mem[71] = 144'h05dff44ff34900a3ec60f49e046f0678075e;
mem[72] = 144'hf0ef061cf501fe5bf72bee8c09c8ff7a0c8e;
mem[73] = 144'hfc37fbc30470f2432bb9e890f43806c0f972;
mem[74] = 144'hf778f10e087afa5ef3a9eca0f35202e60a5c;
mem[75] = 144'hfa9bf31b00b704a306601d59fbb2fd6a0ded;
end

always @ (posedge clk) begin
	q_a <= mem[addr_a];
end

always @ (posedge clk) begin
	q_b <= mem[addr_b];
end

endmodule