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

module contour_draw 
#(  
    X_MIN = 305,
    Y_MIN = 225,
    X_MAX = 334,
    Y_MAX = 254,
    H_BLANK_OFFSET = 160,
    V_BLANK_OFFSET = 45,
    THRESHOLD = 100
) 
(
    input CONTOUR_MODE,
    input [12:0] VGA_H_CNT,
    input [12:0] VGA_V_CNT,
    input [7:0] iVGA_R,
    input [7:0] iVGA_G,
    input [7:0] iVGA_B,
    output [7:0] oVGA_R,
    output [7:0] oVGA_G,
    output [7:0] oVGA_B,
    output BOX_VALID,
    output [7:0] BIN_PIXVAL
);

// Must offset the pixel location by the number of blank pixels
localparam X_MIN_O = X_MIN + H_BLANK_OFFSET;
localparam Y_MIN_O = Y_MIN + V_BLANK_OFFSET;
localparam X_MAX_O = X_MAX + H_BLANK_OFFSET;
localparam Y_MAX_O = Y_MAX + V_BLANK_OFFSET;

wire X_VALID, Y_VALID, X_EDGE, Y_EDGE;
assign X_VALID = (VGA_H_CNT >= X_MIN_O) && (VGA_H_CNT <= X_MAX_O);
assign Y_VALID = (VGA_V_CNT >= Y_MIN_O) && (VGA_V_CNT <= Y_MAX_O);
assign HORIZ_EDGE = (VGA_V_CNT == Y_MIN_O) || (VGA_V_CNT == Y_MAX_O);
assign VERT_EDGE = (VGA_H_CNT == X_MIN_O) || (VGA_H_CNT == X_MAX_O);

assign BOX_VALID = X_VALID && Y_VALID;

// DRAW CONTOUR OF MNIST DIGIT
contour #(.THRESHOLD(THRESHOLD)) u0
(
	.iVGA_R			(iVGA_R),
	.iVGA_G		(iVGA_G),
	.iVGA_B			(iVGA_B),
	.bin_pixval	(BIN_PIXVAL)
);

assign oVGA_R = ((X_VALID && HORIZ_EDGE) || (Y_VALID && VERT_EDGE)) ? 8'h00 : ( (X_VALID && Y_VALID && CONTOUR_MODE) ? BIN_PIXVAL : iVGA_R );
assign oVGA_G = ((X_VALID && HORIZ_EDGE) || (Y_VALID && VERT_EDGE)) ? 8'hff : ( (X_VALID && Y_VALID && CONTOUR_MODE) ? BIN_PIXVAL : iVGA_G );
assign oVGA_B = ((X_VALID && HORIZ_EDGE) || (Y_VALID && VERT_EDGE)) ? 8'h00 : ( (X_VALID && Y_VALID && CONTOUR_MODE) ? BIN_PIXVAL : iVGA_B );



endmodule