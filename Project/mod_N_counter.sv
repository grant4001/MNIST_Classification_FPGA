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
    output wire [N_BITS-1:0] count,
    output wire done
);

wire [N_BITS-1:0] count_next;
reg [N_BITS-1:0] count_t;
assign done = (count_t == N - 1);
assign count_next = (count_t == N - 1) ? 0 : count_t + 1;
assign count = count_t;

always_ff @(posedge clk or posedge rst)
begin
    if (rst)
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