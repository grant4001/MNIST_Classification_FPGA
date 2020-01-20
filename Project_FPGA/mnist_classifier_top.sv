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

// Main processing block, which is directly interfaced to the camera driver

module mnist_classifier_top #(parameter
	H_BLANK_OFFSET = 160,
	V_BLANK_OFFSET = 45,
	W = 640,
	H = 480,
	PIC_DIM = 30,
	PIC_DIM_MULTIPLIER = 3,
	THRESHOLD = 100)
(
	/////	INPUT VGA SIGNALS
	input VGA_CLK,
    input RESET_N,
	input VGA_HS,
	input VGA_VS,
    input CONTOUR_MODE,
	input [12:0] VGA_H_CNT,
	input [12:0] VGA_V_CNT,
	input wire [7:0] iVGA_R,
    input wire [7:0] iVGA_G,
    input wire [7:0] iVGA_B,

	/////	OUTPUT VGA STREAM
    output [7:0] oVGA_R,
    output [7:0] oVGA_G,
    output [7:0] oVGA_B,

	/////	TO 7 SEGMENT DISPLAY
	// output [3:0] DIGIT_OUT,
	output wire [3:0] DIGIT_OUT,
	output [6:0] HEX7,

	/////	LED OUTPUT
	output wire DIGIT_VALID_OUTPUT,
	output wire BOX_VALID
);

localparam X_MIN = (W/2) - ((PIC_DIM*PIC_DIM_MULTIPLIER)/2);
localparam X_MAX = (W/2) + ((PIC_DIM*PIC_DIM_MULTIPLIER)/2) - 1;
localparam Y_MIN = (H/2) - ((PIC_DIM*PIC_DIM_MULTIPLIER)/2);
localparam Y_MAX = (H/2) + ((PIC_DIM*PIC_DIM_MULTIPLIER)/2) - 1;

// wire [3:0] DIGIT_OUT;

// DRAW CONTOUR IN VGA OUTPUT
wire [7:0] BIN_PIXVAL;
contour_draw #(
	.X_MIN(X_MIN),
	.Y_MIN(Y_MIN),
	.X_MAX(X_MAX),
	.Y_MAX(Y_MAX),
	.H_BLANK_OFFSET(H_BLANK_OFFSET),
	.V_BLANK_OFFSET(V_BLANK_OFFSET),
	.THRESHOLD(THRESHOLD)
) u1
(
	.CONTOUR_MODE	( CONTOUR_MODE ),
	.VGA_H_CNT	( VGA_H_CNT ),
	.VGA_V_CNT	( VGA_V_CNT ),
	.iVGA_R	( iVGA_R ),
	.iVGA_G	( iVGA_G ),
	.iVGA_B	( iVGA_B ),
	.oVGA_R	( oVGA_R ),
	.oVGA_G	( oVGA_G ),
	.oVGA_B	( oVGA_B ),
	.BOX_VALID	( BOX_VALID ),
	.BIN_PIXVAL	( BIN_PIXVAL )
);

// EOF DETECTOR
wire EOF;
assign EOF = (~VGA_HS) && (~VGA_VS);

// MAIN DESIGN
cam2cnn #(
	.PIC_DIM_MULTIPLIER(PIC_DIM_MULTIPLIER),
	.PIC_DIM(PIC_DIM)
) u2
(
	.clk					( VGA_CLK ),
	.rst					( RESET_N ),
	.EOF       				( EOF ),
	.raw_pixel				( BIN_PIXVAL ),
	.raw_pixel_valid		( BOX_VALID ),
	.digit					( DIGIT_OUT ),
	.digit_valid_output		( DIGIT_VALID_OUTPUT )
);

// 7 SEGMENT DISPLAY
segment7 u3
(
	.bcd  (DIGIT_OUT),
	.seg  (HEX7)
);

endmodule