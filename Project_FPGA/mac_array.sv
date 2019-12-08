// Module: mac_array.sv
// Date: 10/23/2019
// 
// MAC_ARRAY performs 2-D convolutions. 
// 16x 3x3 windows of fmap pixels and corresponding weights are accepted as input.
//
// MAC_ARRAY includes 16 MAC units. Each MAC unit performs 9 multiplications in one pipeline
// stage, and performs 8 additions in the span of 2 pipeline stages. 
// If we are generating the fmap output of layer 2, each output of the MAC units are the output
// of mac_array. Otherwise, each output of the MAC units is accumulated again. 
//
// MAC_ARRAY uses 144x 16-bit hard multipliers.

`timescale 1ns/1ns

module mac_array # (parameter WT_BITS = 16) (
    input clk,
    input rst,
    input RCV_L2, 
    input valid_i,
    output valid_o,
    input [143:0] ifmap_chunk [15:0],   // A flattened 3x3 window of 16-bit input feature map pixels
    input [143:0] wt [15:0],           // A flattened 3x3 window of 16-bit weights
    output reg [19:0] accum_o [15:0]
);

// Delay shift register for the valid signal. If valid data is coming in, valid_i is high.
// Depending on which layer we are performing convolutions for, we will send out the valid_o
// signal either exactly 3 or 5 cycles later, hence the 5-DFF chain.
reg [4:0] delay_sreg;

// If the output convolution will be the layer 2 output, we need only delay by 3 cycles.
// Otherwise, 5 cycles. (3 cycles for one window convolution, and 2 more to accumulate all window convolutions.
assign valid_o = (RCV_L2) ? delay_sreg[2] : delay_sreg[4];

// Accumulation registers to accumulate all window convolutions. Only used for layers after layer 2.
wire signed [19:0] accum1, accum2, accum3, accum4;
reg signed [19:0] accum1_reg, accum2_reg, accum3_reg, accum4_reg;
wire signed [19:0] accum_final, accum_final_t;
reg signed [19:0] accum_final_reg;

// Outputs of every individual mac unit.
wire signed [19:0] res [15:0];

// Assign the output of the MAC_ARRAY.
always_comb
begin
    // If generating layer 2 feature maps, all 16 accum_o outputs are straight from the 16x MACs.
    for (int i = 0; i < 16; i++)
    begin
        accum_o[i] = res[i][15:0];
    end
    // Otherwise, if not generating layer 2 feature maps, ONLY use accum_o[0] as the fmap output port.
    if (~RCV_L2) 
    begin
        accum_o[0] = accum_final_reg;
    end
end

// Accumulation of all 16x MAC outputs in a 2-level tree structure.
/*
assign accum1 = {res[0][15], res[0]} + {res[1][15], res[1]} + {res[2][15], res[2]} + {res[3][15], res[3]};
assign accum2 = {res[4][15], res[4]} + {res[5][15], res[5]} + {res[6][15], res[6]} + {res[7][15], res[7]};
assign accum3 = {res[8][15], res[8]} + {res[9][15], res[9]} + {res[10][15], res[10]} + {res[11][15], res[11]};
assign accum4 = {res[12][15], res[12]} + {res[13][15], res[13]} + {res[14][15], res[14]} + {res[15][15], res[15]}; 
*/
assign accum1 = res[0] + res[1] + res[2] + res[3];
assign accum2 = res[4] + res[5] + res[6] + res[7];
assign accum3 = res[8] + res[9] + res[10] + res[11];
assign accum4 = res[12] + res[13] + res[14] + res[15]; 
assign accum_final_t = accum1_reg + accum2_reg + accum3_reg + accum4_reg;
assign accum_final = accum_final_t;

// Check for overflow of the accumulation of 16x MAC outputs.
// The mantissa of accum_final_temp occupies 15 bits, and the decimal portion occupies
// 3 bits (representing -8 to +7).
//
// Because the fmaps stored in memory are 16 bits, and 15 bits are used for the mantissa,
// the remaining MSB is used as the sign bit. The represented range is then [-1, 1-(2^15)].
//assign accum_final = ((&accum_final_t[19:15]) | (~|accum_final_t[17:15])) ? accum_final_t[15:0] : (accum_final_t[17] ? 16'h8000 : 16'h7fff);

always_ff @(posedge clk or posedge rst) 
begin
    if (rst) begin
        accum1_reg <= 0;
        accum2_reg <= 0;
        accum3_reg <= 0;
        accum4_reg <= 0;
        accum_final_reg <= 0;
        delay_sreg <= 0;
    end else begin
        accum1_reg <= accum1;
        accum2_reg <= accum2;
        accum3_reg <= accum3;
        accum4_reg <= accum4;
        accum_final_reg <= accum_final;
        if (RCV_L2) begin
            delay_sreg[4] <= delay_sreg[4];
            delay_sreg[3] <= delay_sreg[3];
        end else begin
            delay_sreg[4] <= delay_sreg[3];
            delay_sreg[3] <= delay_sreg[2];
        end
        delay_sreg[2] <= delay_sreg[1];
        delay_sreg[1] <= delay_sreg[0];
        delay_sreg[0] <= valid_i;
    end
end

// 16x MAC units instantiation.
genvar a;

generate
    for (a = 0; a < 16; a = a + 1)
    begin : mac_gen
        mac #(.WT_BITS(WT_BITS)) mac_u 
        (
            .clk (clk),
            .rst (rst),
            .ifmap_chunk (ifmap_chunk[a]),
            .weight (wt[a]),
            .mac_output (res[a])
        );
    end
endgenerate

endmodule
