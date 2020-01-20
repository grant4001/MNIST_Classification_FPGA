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

module contour #(parameter THRESHOLD = 100)
(
    input [7:0] iVGA_R,
    input [7:0] iVGA_G,
    input [7:0] iVGA_B,
    output [7:0] bin_pixval
);

wire [7:0] GRAYSCALE_VAL;
RGB2GRAY u0
(
	.i_RED			(iVGA_R),
	.i_GREEN		(iVGA_G),
	.i_BLUE			(iVGA_B),
	.o_GRAYSCALE	(GRAYSCALE_VAL)
);

assign bin_pixval = (GRAYSCALE_VAL > THRESHOLD) ? 0 : 255 - GRAYSCALE_VAL;

endmodule