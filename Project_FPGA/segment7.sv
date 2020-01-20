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

module segment7
(
    input [3:0] bcd,
    output reg [6:0] seg
);

always_comb
begin
    case (bcd) //case statement
        0 : seg = 7'b1000000;
        1 : seg = 7'b1111001;
        2 : seg = 7'b0100100; 
        3 : seg = 7'b0110000;  
        4 : seg = 7'b0011001; 
        5 : seg = 7'b0010010;
        6 : seg = 7'b0000010;
        7 : seg = 7'b1111000;
        8 : seg = 7'b0000000;
        9 : seg = 7'b0010000;
        default : seg = 7'b1111111; 
    endcase
end
    
endmodule