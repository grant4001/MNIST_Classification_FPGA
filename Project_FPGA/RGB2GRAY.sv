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

module RGB2GRAY 
(
    input wire [7:0] i_RED,
    input wire [7:0] i_BLUE,
    input wire [7:0] i_GREEN,
    output wire [7:0] o_GRAYSCALE
);

// Luminosity method
// .21R + .72G + 0.07B
// approx 0.25R + 0.625G + 0.125B
assign o_GRAYSCALE = i_RED[7:2] + i_GREEN[7:1] + i_GREEN[7:3] + i_BLUE[7:3];

// or, approx 0.1875R + 0.75G + 0.0625B
// or, 3/16 * R + 3/4 * G + 1/16 * B
// or, (R >> 2) - (R >> 4) + (G >> 1) + (G >> 2) + (B >> 4)

endmodule