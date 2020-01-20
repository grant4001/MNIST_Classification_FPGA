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

module wt_mem4 #(parameter ADDR_WIDTH = 7, DATA_WIDTH = 144, DEPTH = 76) (
input wire clk,
input wire [ADDR_WIDTH-1:0] addr_a, 
input wire [ADDR_WIDTH-1:0] addr_b, 
output reg [DATA_WIDTH-1:0] q_a,
output reg [DATA_WIDTH-1:0] q_b
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

initial begin
mem[0] = 144'hf9ece8bb06b6ef42f7fe075f019bf41ef075;
mem[1] = 144'h0433eeefea81fec4ea39f86cefc8f8e7ea37;
mem[2] = 144'hfcf6f11ff69df4b9005cfe2b016cef6c03d1;
mem[3] = 144'hf989fcfdf4f6f0bfff6a094dfa9ff893ea2c;
mem[4] = 144'he279f141f26bec89f89bf61af35ef99ce509;
mem[5] = 144'hf4a3ea8af299f1cef5cef199ea82e78afe51;
mem[6] = 144'hf0b30149edf20746f0ecfc3bf1b2f29eff3a;
mem[7] = 144'hf5baf3faf10ff00beb07f830fdff03d601aa;
mem[8] = 144'hfc29f1b2fd8ffacbfa98067104c808f20417;
mem[9] = 144'h0a2bfc0fefeb0631f164ebc704d0f7cc08ca;
mem[10] = 144'hed25fa06e52be964f87afbefefd3e5f20188;
mem[11] = 144'hefddecbef0ddfe15013cf02ff98eea51f691;
mem[12] = 144'h0a52f8e5f918f0b0ef0f0b74f49f036efa11;
mem[13] = 144'h0091071ff8560733027df19aef07fc2e0252;
mem[14] = 144'h066afc2608370ce0ecd3eb07ecf1037307e1;
mem[15] = 144'hef0b0836f0690357ee1bfcf5023bf186f189;
mem[16] = 144'hf27afd3ee4f9ed02ec5afc46fd58f9d2e5d8;
mem[17] = 144'hf400eb2f016ffa16f444fbc5e94eedd2f823;
mem[18] = 144'hf363f4affed203def462f77901b3fb00f8b0;
mem[19] = 144'hea3f058aff2cf1f3f99aef4bf048f9b3f1c4;
mem[20] = 144'hea9ff628f66204cb054b05d4f5b8f770f853;
mem[21] = 144'h03dbfaa8f91df4df04cfef40f0590588ff02;
mem[22] = 144'h0292ef70f07df594ec62fcbbf5f8040808c0;
mem[23] = 144'hfdf60323f050f284051de5def278fb2e0253;
mem[24] = 144'hfc530ae80a1409b40173fb9904ecf8fbf54f;
mem[25] = 144'heb10edc5f63df11ceaa60515f9d20386f9ec;
mem[26] = 144'h05aefc1d0789ee170424f17f0b69044afaed;
mem[27] = 144'h04170621077afd91fdf7f734f6a10a4bfdbb;
mem[28] = 144'h08b009ec012df26bfa10047f08bdfb7b04f0;
mem[29] = 144'h0c3b041b0a20feb9fe69f820ee55ef0df4ea;
mem[30] = 144'hf9beff15f4a7fc5be685fa2cfc1cffe0eaf2;
mem[31] = 144'h045403f5f92cec4df7f7fd1ef1e4fc1fe8c2;
mem[32] = 144'h0809f236099af51dfd0bfa20fdb20510f2a5;
mem[33] = 144'hf4baf280052deb770404f05f01cff697ef54;
mem[34] = 144'hfc5cf74ff937e91becb60025fe3e020fea14;
mem[35] = 144'he94ffaf5e763f0be0381f98102a0f400e6c1;
mem[36] = 144'hff6103d5008e01fe0711f573e6def242eed0;
mem[37] = 144'hf86afda4f5adf935040af151ea48ebda0824;
mem[38] = 144'h08bffa0fe660f601046ae84eeecaf478e755;
mem[39] = 144'hf7d307d109b2f96c08bff8e1f400fa0df788;
mem[40] = 144'h0a3eff82042100f70a45fb62f10905a7f4bb;
mem[41] = 144'hf773fba1f868ffa70b1302470bfaf376eeb4;
mem[42] = 144'hfb1cee36fdf3f232eb23edec01b2f50df707;
mem[43] = 144'he9f6f990fc0be7e6f7ac059bf62fe443fb46;
mem[44] = 144'h019b04fc0714f49a0135fae4ef47fed002bf;
mem[45] = 144'hfd9eeaf9fee7f991f454fa6cee5aeb0ffeda;
mem[46] = 144'hf377fbd409aef7dff4e8ee6dfe42ffccfadb;
mem[47] = 144'hef09f07df9ee0b07f10b0142f28bee2d05ff;
mem[48] = 144'h099704aaf733f39508c4f011fcc207f8058a;
mem[49] = 144'hec90fd40f84af77a0a370a2dfc92fa1cf24e;
mem[50] = 144'hf152f0a2eed9085b08710732fcc8ff41eb3b;
mem[51] = 144'h011efef306ab09e6fd81f125fc8e0965f20e;
mem[52] = 144'he9e903b9e72204d0f3caffa2fc84f833fc4d;
mem[53] = 144'hf52e005ee94ff8bbec5304f4f507ed75fb9a;
mem[54] = 144'h06f408c9f5f709faf972098ff1d5f958041d;
mem[55] = 144'hed6e0b4b02affb12f8adfddcf05a09e6fced;
mem[56] = 144'h0caf008ff6f8f04b09a7ef1e0775f083fd5d;
mem[57] = 144'hff67fb6d053d083ff2f30719fd7cee4bf780;
mem[58] = 144'hef370b35f830f3cf0283fd40f7e1f9b20c20;
mem[59] = 144'hff2ff897f147f4a10117f454f9c7f1300d53;
mem[60] = 144'hf796e965f923f8790409fd66ff1ce504f8b0;
mem[61] = 144'hee7700f1ff00fc67e870e8970024ea42e723;
mem[62] = 144'h0a5703f8eed606eafb2300e9067cf8a908b5;
mem[63] = 144'h042803420a4802ba06c7ede0035303eef7b1;
mem[64] = 144'h03d3e993f638f918ebeff13ef45cf31bffa9;
mem[65] = 144'he62cec3f03e2e64ffbe3f049fbc300fbfc84;
mem[66] = 144'hf3f2f3c50c7ff8c1f756f967fe9e0d3a0211;
mem[67] = 144'he61bff01f446f227f483fff2ea84ef1cfec2;
mem[68] = 144'hfb98edf1fdb6f9d60df1f926027808a30852;
mem[69] = 144'he55f033c07960637f584fba4f940f7e3fc57;
mem[70] = 144'hf6d2f23ff6f2f9590dcee160ffbff7f1fd43;
mem[71] = 144'hf4f8f39ff34e01f50ab4ea3cfff8fde0fde5;
mem[72] = 144'hf4930278056f04f800e1fc57025f02370003;
mem[73] = 144'h08a7f3f209d909ea0cdbe7990263fe2b00bb;
mem[74] = 144'hf4530b71f988fe6e007ef49b0310f997f4d3;
mem[75] = 144'hefd706b0ec57fd6d0e8b0793eb24f0dc0b34;
end

always @ (posedge clk) begin
	q_a <= mem[addr_a];
end

always @ (posedge clk) begin
	q_b <= mem[addr_b];
end

endmodule