// Module: mod_N_counter.sv
// Date: 12/7/2019
// Description: MOD_N_COUNTER is an up-counter that resets at the specified number

`timescale 1ns/1ns

module mod_N_counter #(parameter
    N = 8,
    N_BITS = 3
)
(
    input clk,
    input rst,
    input en,
    output reg [N_BITS-1:0] count,
    output wire done
);

wire [N_BITS-1:0] count_next;
assign done = (count == N - 1);
assign count_next = (count == N - 1) ? 0 : count + 1;

always_ff @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        count <= 0;
    end else
    begin
        if (en)
        begin
            count <= count_next;
        end else
        begin
            count <= count;
        end
    end
end

endmodule