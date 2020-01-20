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

// Module: mod_N_counter.sv
// Date: 12/7/2019
// Description: MOD_N_COUNTER is an up-counter that resets at the specified number

`timescale 1ns/1ns

module mod_N_counter #(parameter
    N = 900,
    N_BITS = 10
)
(
    input clk,
    input rst,
    input en,
    output wire [N_BITS-1:0] count,
    output wire done
);

wire [N_BITS-1:0] count_next;
reg [N_BITS-1:0] count_t;
assign done = (count_t == N - 1);
assign count_next = (count_t == N - 1) ? 0 : count_t + 1;
assign count = count_t;

always_ff @(posedge clk or negedge rst)
begin
    if (~rst)
    begin
        count_t <= 0;
    end else
    begin
        if (en)
        begin
            count_t <= count_next;
        end else
        begin
            count_t <= count_t;
        end
    end
end

endmodule