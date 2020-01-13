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