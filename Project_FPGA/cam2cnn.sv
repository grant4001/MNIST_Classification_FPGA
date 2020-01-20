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

`timescale 1ns/1ns

module cam2cnn #(parameter PIC_DIM_MULTIPLIER = 3, PIC_DIM = 30)
(
    input clk,
    input rst,
    input EOF,
    input [7:0] raw_pixel,
    input raw_pixel_valid,
    output [3:0] digit,
    output digit_valid_output
);

    reg pixel_i_valid;
    top u0
    (
        .clk           (clk),
        .rst           (rst),
        .pixel_i       (raw_pixel),
        .pixel_i_valid (pixel_i_valid),
        .digit_o       (digit),
        .digit_o_valid (digit_valid_output)
    );

    // Counter for the box-delineated area 
    reg lg_box_x_count_en;
    wire lg_box_x_count_done;
    wire [6:0] lg_box_x_count;
    mod_N_counter #(
        .N(PIC_DIM*PIC_DIM_MULTIPLIER),
        .N_BITS(7)
    ) u1 
    (
        .clk   (clk),
        .rst   (rst),
        .en    (lg_box_x_count_en),
        .count (lg_box_x_count),
        .done  (lg_box_x_count_done)
    );

    // Counter for the downsampled, required 30x30 MNIST dimension
    reg sm_box_count_en;
    wire sm_box_count_done;
    wire [9:0] sm_box_count;
    mod_N_counter #(
        .N(PIC_DIM*PIC_DIM),
        .N_BITS(10)
    ) u2
    (
        .clk   (clk),
        .rst   (rst),
        .en    (sm_box_count_en),
        .count (sm_box_count),
        .done  (sm_box_count_done)
    );

    // Mod X counter
    reg x_count_en;
    wire x_count_done;
    wire [3:0] x_count;
    mod_N_counter #(
        .N (PIC_DIM_MULTIPLIER),
        .N_BITS (4)
    ) u3
    (
        .clk    (clk),
        .rst    (rst),
        .en     (x_count_en),
        .count  (x_count),
        .done   (x_count_done)
    );

    // Mod Y counter
    reg y_count_en;
    wire y_count_done;
    wire [3:0] y_count;
    mod_N_counter #(
        .N (PIC_DIM_MULTIPLIER),
        .N_BITS (4)
    ) u4
    (
        .clk    (clk),
        .rst    (rst),
        .en     (y_count_en),
        .count  (y_count),
        .done   (y_count_done)
    );
    
    reg [1:0] state, state_next;
    localparam SEND_PIX_TO_CNN = 0, WAIT_FOR_CLASSIFICATION = 1, WAIT_FOR_EOF = 2;
    always_ff @(posedge clk or negedge rst) 
    begin
        if (~rst) 
        begin
            state <= SEND_PIX_TO_CNN;
        end else 
        begin
            state <= state_next;
        end
    end

    always_comb
    begin
        state_next = state;
        y_count_en = 0;
        x_count_en = 0;
        lg_box_x_count_en = 0;
        sm_box_count_en = 0;
        pixel_i_valid = 0;
        case (state)
            SEND_PIX_TO_CNN :
            begin
                if (raw_pixel_valid)
                begin
                    lg_box_x_count_en = 1;
                    if (lg_box_x_count_done)
                    begin
                        y_count_en = 1;
                    end

                    x_count_en = 1;
                    if (x_count_done && y_count_done)
                    begin
                        sm_box_count_en = 1;
                        pixel_i_valid = 1;
                        if (sm_box_count_done)
                        begin
                            state_next = WAIT_FOR_CLASSIFICATION;
                        end
                    end
                    
                end
            end
            WAIT_FOR_CLASSIFICATION:
            begin
                if (digit_valid_output)
                begin
                    state_next = WAIT_FOR_EOF;
                end
            end
            WAIT_FOR_EOF:
            begin
                if (EOF)
                begin
                    state_next = SEND_PIX_TO_CNN;
                end
            end
        endcase
    end

endmodule