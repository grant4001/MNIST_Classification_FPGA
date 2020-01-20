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

module cnn_receiver 
(
    input clk,
    input rst,

    // Biases I/O
    output reg [3:0] bi_addr_a,
    output reg [3:0] bi_addr_b,
    input [127:0] bi_q_a,
    input [127:0] bi_q_b,

    // fmap I memory I/O, for the resulting fmaps of CONV2. (input image -> CONV2 -> fmap I)
    output reg [7:0] fmap_wr_addr_I [15:0],
    output reg fmap_wr_en_I [15:0],
    output reg [15:0] fmap_wr_data_I [15:0],

    // fmap II memory I/O, for the resulting fmaps of CONV4. (fmap I -> CONV4 -> fmap II)
    output reg [2:0] fmap_wr_addr_II [143:0],
    output reg fmap_wr_en_II [143:0],
    output reg [15:0] fmap_wr_data_II [143:0],

    // fmap III memory I/O, for the resulting fmaps of FC6. (fmap II -> FC6 -> fmap III).
    output reg fmap_wr_addr_III [63:0],
    output reg fmap_wr_en_III [63:0],
    output reg [15:0] fmap_wr_data_III [63:0],

    // Classification. (fmap III -> FC7 -> 10 registers -> apply max -> get "digit_o" right here)
    output wire [3:0] digit_o,
    output wire digit_o_valid,

    // mac_array I/O
    input valid_o,
    input [17:0] accum_o [15:0],
    output wire RCV_L2

    // TESTING
    /*
    input fifo_rd_en,
    output [15:0] fifo_dout,
    output fifo_empty*/
);

/*
reg fifo_wr_en;
reg [15:0] fifo_din;
wire fifo_full;

fifo #(16, 16) fifo_u 
(
    .rd_clk(clk),
    .wr_clk(clk),
    .reset(rst),
    .rd_en(fifo_rd_en),
    .wr_en(fifo_wr_en),
    .din(fifo_din),
    .dout(fifo_dout),
    .full(fifo_full),
    .empty(fifo_empty)
);*/

// Average-pooling function
function [15:0] Pool_avg; // unsigned
    input [15:0] p1, p2, p3, p4;
    reg [17:0] temp;
    begin
        temp = p1 + p2 + p3 + p4;
        Pool_avg = temp[17:2];
    end
endfunction

function [17:0] relu_sext; 
    input [17:0] x;
    begin
        if (~x[17]) begin
            relu_sext = x;
        end else begin
            relu_sext = 0;
        end
    end
endfunction

integer x, y, z, q, r;

// registers to keep track of which layer we're on
reg [3:0] rcv_layer, rcv_layer_next; // for the receiving FSM (same reason as right above^)
localparam CONV2_layer = 4'b0001;
localparam CONV4_layer = 4'b0010;
localparam FC6_layer = 4'b0100;
localparam FC7_layer = 4'b1000;
localparam CONV2 = 0; // index decoders
localparam CONV4 = 1;
localparam FC6 = 2;
localparam FC7 = 3;

// RECEIVING FSM control
reg [2:0] rcv_state;
reg [2:0] rcv_state_next;
localparam CONV2_PROCESS = 0;
localparam CONV2_LAST_PIX = 1;
localparam CONV4_PROCESS = 2;
localparam CONV4_LAST_PIX = 3;
localparam FC6_PROCESS = 4;
localparam FC7_PROCESS = 5;
localparam CLASSIFY = 6;

// RECEIVING FSM's counters.
reg x_decimate_next, x_decimate;
reg y_decimate_next, y_decimate;
reg [3:0] pool_cnt_x, pool_cnt_x_next; // log2(14) = 4 bits
reg [3:0] pool_cnt_y, pool_cnt_y_next;
reg [8:0] pool_cnt, pool_cnt_next; //

// RECEIVING FSM's position tracker within the input feature map
// note: bits needed for dimension of 30 pixels = 5 bits
reg [4:0] fmap_cnt_x, fmap_cnt_x_next, fmap_cnt_y, fmap_cnt_y_next; 

// RECEIVING FSM: pooling buffers related (use all reg instead of sram for simplicity)
reg [15:0] my_pool_bufs [29:0][15:0]; // 28 rows + 2 extra, minus 1, 16 of these
reg [15:0] my_pool_bufs_next [29:0][15:0]; // 28 rows + 2 extra, minus 1, 16 of these

// RECEIVING FSM: registers to store the final feature map of 10 values.
reg signed [15:0] classification [9:0];
reg signed [15:0] classification_next [9:0];

// Track WHICH fmap we're on. send_fmap is for the rcv fsm
reg [4:0] rcv_fmap, rcv_fmap_next; // log2(32) = 5 bits 

// Accumulation register for FC Layer 6
reg [17:0] accum_l6, accum_l6_next;

reg classify_pipeline_v_next;

assign RCV_L2 = (rcv_layer[CONV2]) ? 1 : 0;  // accum all MAC results if we're past CONV2

//////////////////// RECEIVING FSM /////////////////////////////////////////////////////////////////////////////////
always_comb
begin
    for (x = 0; x < 30; x = x + 1) 
    begin
        for (y = 0; y < 16; y = y + 1) 
        begin
            my_pool_bufs_next[x][y] = my_pool_bufs[x][y];
        end
    end
    for (z = 0; z < 16; z = z + 1) 
    begin
        fmap_wr_data_I[z] = 0;
        fmap_wr_addr_I[z] = 0;
        fmap_wr_en_I[z] = 0;
    end
    for (z = 0; z < 144; z = z + 1) 
    begin
        fmap_wr_data_II[z] = 0;
        fmap_wr_addr_II[z] = 0;
        fmap_wr_en_II[z] = 0;
    end
    for (z = 0; z < 64; z = z + 1) 
    begin
        fmap_wr_data_III[z] = 0;
        fmap_wr_addr_III[z] = 0;
        fmap_wr_en_III[z] = 0;
    end
    for (z = 0; z < 10; z = z + 1) 
    begin
        classification_next[z] = classification[z];
    end
    fmap_cnt_x_next = fmap_cnt_x;
    fmap_cnt_y_next = fmap_cnt_y;
    rcv_state_next = rcv_state;
    x_decimate_next = x_decimate;
    y_decimate_next = y_decimate;
    pool_cnt_y_next = pool_cnt_y;
    pool_cnt_x_next = pool_cnt_x;
    pool_cnt_next = pool_cnt;
    rcv_fmap_next = rcv_fmap;
    bi_addr_a = 0;
    bi_addr_b = 0;
    rcv_layer_next = rcv_layer;
    accum_l6_next = accum_l6;
    classify_pipeline_v_next = 0;
    
    /*
    fifo_wr_en = 0;
    fifo_din = 0;*/
    
    case (rcv_state) 

        CONV2_PROCESS : 
        begin
            // Get the correct biases for the given layer.
            bi_addr_a = 0;
            bi_addr_b = 1;

            // Sequence of operations for when a valid output of the mac_array is received
            if (valid_o) 
            begin
                // shift the pool buffer shift registers over by 1.
                for (x = 29; x > 0; x = x - 1) 
                begin
                    for (y = 0; y < 16; y = y + 1) 
                    begin
                        my_pool_bufs_next[x][y] = my_pool_bufs[x-1][y];
                    end
                end

                // apply activation function
                for (z = 0; z < 8; z = z + 1)
                begin
                    my_pool_bufs_next[0][z] = relu_sext( accum_o[z] + { {2{bi_q_a[127 - (16*z)]}}, bi_q_a[127 - (16*z)-:16] } );
                    my_pool_bufs_next[0][z+8] = relu_sext( accum_o[z+8] + { {2{bi_q_b[127 - (16*z)]}}, bi_q_b[127 - (16*z)-:16] } );
                end

                // FIFO SAMPLING FOR LAYER 2
                // (insert code here)
                //
                // passes
                /*
                if (~fifo_full) begin
                    fifo_wr_en = 1;
                    fifo_din = relu_sext( accum_o[1+8] + { {2{bi_q_b[127 - (16*1)]}}, bi_q_b[127 - (16*1)-:16] } );
                end
                */

                // (x, y) position counter in ofmap
                fmap_cnt_x_next = fmap_cnt_x + 1;
                x_decimate_next = ~x_decimate; // x_dec and y_dec mark points to compute pooling
                if (fmap_cnt_x == 27) 
                begin
                    fmap_cnt_y_next = fmap_cnt_y + 1;
                    fmap_cnt_x_next = 0;
                    y_decimate_next = ~y_decimate;
                    if (fmap_cnt_y == 27) 
                    begin
                        fmap_cnt_y_next = 0;
                        y_decimate_next = 0;
                        x_decimate_next = 0;
                        rcv_state_next = CONV2_LAST_PIX;
                    end
                end

                // (x, y) position counter in the pooled fmap (so 1/4 the original size)
                if (x_decimate && y_decimate) 
                begin
                    pool_cnt_x_next = pool_cnt_x + 1;
                    pool_cnt_next = pool_cnt + 1;
                    if (pool_cnt_x == 13) 
                    begin
                        pool_cnt_x_next = 0;
                        pool_cnt_y_next = pool_cnt_y + 1;
                        if (pool_cnt_y == 13) 
                        begin
                            pool_cnt_y_next = 0;
                            pool_cnt_next = 0;
                        end
                    end
                end

                // Apply pooling (avg) onto the fmap
                if (((fmap_cnt_x >= 2) && (fmap_cnt_y >= 1) && (~x_decimate & y_decimate)) || 
                    ((fmap_cnt_x == 0) && (fmap_cnt_y >= 2) && (~y_decimate))) 
                begin
                    for (z = 0; z < 16; z = z + 1) 
                    begin
                        fmap_wr_en_I[z] = 1;
                        fmap_wr_addr_I[z] = pool_cnt - 1;
                        fmap_wr_data_I[z] = Pool_avg(my_pool_bufs[0][z], my_pool_bufs[1][z], my_pool_bufs[28][z], my_pool_bufs[29][z]);
                    end

                    // Sample Layer 3 results using FIFO
                    /*
                    if (~fifo_full) begin
                        fifo_wr_en = 1;
                        fifo_din = Pool_avg(my_pool_bufs[0][0], my_pool_bufs[1][0], my_pool_bufs[28][0], my_pool_bufs[29][0]);
                    end*/
                end
            end
        end

        CONV2_LAST_PIX : 
        begin
            // Apply pooling (avg) onto the fmap
            rcv_state_next = CONV4_PROCESS;
            rcv_layer_next = CONV4_layer;
            bi_addr_a = 2;
            for (z = 0; z < 16; z = z + 1) 
            begin
                fmap_wr_en_I[z] = 1;
                fmap_wr_addr_I[z] = 195;
                fmap_wr_data_I[z] = Pool_avg(my_pool_bufs[0][z], my_pool_bufs[1][z], my_pool_bufs[28][z], my_pool_bufs[29][z]);
            end

            // Sample Layer 3 results using FIFO
            /*
            if (~fifo_full) begin
                fifo_wr_en = 1;
                fifo_din = Pool_avg(my_pool_bufs[0][0], my_pool_bufs[1][0], my_pool_bufs[28][0], my_pool_bufs[29][0]);
            end*/
        end

        CONV4_PROCESS : 
        begin
            // Get the correct biases for the given layer.
            bi_addr_a = 2 + rcv_fmap[4:3];

            // Sequence of operations for when a valid output of the mac_array is received
            if (valid_o) 
            begin
                // shift the pool buffer shift registers over by 1.
                for (x = 29; x > 0; x = x - 1) 
                begin
                    for (y = 0; y < 16; y = y + 1) 
                    begin
                        my_pool_bufs_next[x][y] = my_pool_bufs[x-1][y];
                    end
                end

                // FIFO SAMPLING
                // (insert code here)
                //
                //
                // passes

                my_pool_bufs_next[0][0] = relu_sext(accum_o[0] + { {2{bi_q_a[127 - (16 * rcv_fmap[2:0])]}}, bi_q_a[127 - (16 * rcv_fmap[2:0])-:16] } );
                
                /*
                if (~fifo_full) begin
                    fifo_wr_en = 1;
                    fifo_din = relu_sext(accum_o[0] + { {2{bi_q_a[127 - (16 * rcv_fmap[2:0])]}}, bi_q_a[127 - (16 * rcv_fmap[2:0])-:16] } );
                end*/

                // (x, y) position counter in ofmap
                fmap_cnt_x_next = fmap_cnt_x + 1;
                x_decimate_next = ~x_decimate; // x_dec and y_dec mark points to compute pooling
                if (fmap_cnt_x == 11)
                begin
                    fmap_cnt_y_next = fmap_cnt_y + 1;
                    fmap_cnt_x_next = 0;
                    y_decimate_next = ~y_decimate;
                    if (fmap_cnt_y == 11) 
                    begin
                        fmap_cnt_y_next = 0;
                        y_decimate_next = 0;
                        x_decimate_next = 0;
                        rcv_state_next = CONV4_LAST_PIX;
                    end
                end

                // (x, y) position counter in the pooled fmap (so half the original size)
                if (x_decimate && y_decimate) 
                begin
                    pool_cnt_x_next = pool_cnt_x + 1;
                    pool_cnt_next = pool_cnt + 1;
                    if (pool_cnt_x == 5)
                    begin
                        pool_cnt_x_next = 0;
                        pool_cnt_y_next = pool_cnt_y + 1;
                        if (pool_cnt_y == 5) 
                        begin
                            pool_cnt_y_next = 0;
                            pool_cnt_next = 0;
                        end
                    end
                end

                // Apply pooling (avg) onto the fmap
                if (((fmap_cnt_x >= 2) && (fmap_cnt_y >= 1) && (~x_decimate && y_decimate)) || 
                    ((~|fmap_cnt_x) && (fmap_cnt_y >= 2) && (~y_decimate))) 
                begin
                    if (rcv_fmap[0])
                    begin
                        if (rcv_fmap[1]) 
                        begin
                            fmap_wr_en_II[(pool_cnt - 1) + 108] = 1;
                            fmap_wr_addr_II[(pool_cnt - 1) + 108] = rcv_fmap[4:2];
                            fmap_wr_data_II[(pool_cnt - 1) + 108] = Pool_avg(my_pool_bufs[0][0], my_pool_bufs[1][0], my_pool_bufs[12][0], my_pool_bufs[13][0]);
                        end else begin
                            fmap_wr_en_II[(pool_cnt - 1) + 36] = 1;
                            fmap_wr_addr_II[(pool_cnt - 1) + 36] = rcv_fmap[4:2];
                            fmap_wr_data_II[(pool_cnt - 1) + 36] = Pool_avg(my_pool_bufs[0][0], my_pool_bufs[1][0], my_pool_bufs[12][0], my_pool_bufs[13][0]);
                        end
                    end else begin
                        if (rcv_fmap[1]) 
                        begin
                            fmap_wr_en_II[(pool_cnt - 1) + 72] = 1;
                            fmap_wr_addr_II[(pool_cnt - 1) + 72] = rcv_fmap[4:2];
                            fmap_wr_data_II[(pool_cnt - 1) + 72] = Pool_avg(my_pool_bufs[0][0], my_pool_bufs[1][0], my_pool_bufs[12][0], my_pool_bufs[13][0]);
                        end else begin
                            fmap_wr_en_II[(pool_cnt - 1) ] = 1;
                            fmap_wr_addr_II[(pool_cnt - 1) ] = rcv_fmap[4:2];
                            fmap_wr_data_II[(pool_cnt - 1) ] = Pool_avg(my_pool_bufs[0][0], my_pool_bufs[1][0], my_pool_bufs[12][0], my_pool_bufs[13][0]);
                        end
                    end
                end
            end
        end

        CONV4_LAST_PIX :
        begin
            // Apply pooling (avg) onto the fmap
            rcv_state_next = CONV4_PROCESS;
            bi_addr_a = 2 + rcv_fmap[4:3];
            if (&rcv_fmap[2:0])
            begin
                bi_addr_a = 2 + rcv_fmap[4:3] + 1;
            end

            if (rcv_fmap[0])
            begin
                if (rcv_fmap[1]) 
                begin
                    fmap_wr_en_II[35 + 108] = 1;
                    fmap_wr_addr_II[35 + 108] = rcv_fmap[4:2];
                    fmap_wr_data_II[35 + 108] = Pool_avg(my_pool_bufs[0][0], my_pool_bufs[1][0], my_pool_bufs[12][0], my_pool_bufs[13][0]);
                end else begin
                    fmap_wr_en_II[35 + 36] = 1;
                    fmap_wr_addr_II[35 + 36] = rcv_fmap[4:2];
                    fmap_wr_data_II[35 + 36] = Pool_avg(my_pool_bufs[0][0], my_pool_bufs[1][0], my_pool_bufs[12][0], my_pool_bufs[13][0]);
                end
            end else begin
                if (rcv_fmap[1]) 
                begin
                    fmap_wr_en_II[35 + 72] = 1;
                    fmap_wr_addr_II[35 + 72] = rcv_fmap[4:2];
                    fmap_wr_data_II[35 + 72] = Pool_avg(my_pool_bufs[0][0], my_pool_bufs[1][0], my_pool_bufs[12][0], my_pool_bufs[13][0]);
                end else begin
                    fmap_wr_en_II[35] = 1;
                    fmap_wr_addr_II[35] = rcv_fmap[4:2];
                    fmap_wr_data_II[35] = Pool_avg(my_pool_bufs[0][0], my_pool_bufs[1][0], my_pool_bufs[12][0], my_pool_bufs[13][0]);
                end
            end

            rcv_fmap_next = rcv_fmap + 1;
            if (&rcv_fmap[4:0]) 
            begin
                rcv_fmap_next = 0;
                rcv_state_next = FC6_PROCESS;
                accum_l6_next = 0;
            end
        end

        FC6_PROCESS : 
        begin
            // use pool_cnt as an ofmap counter
            for (z = 0; z < 64; z = z + 1)
            begin
                fmap_wr_addr_III[z] = 0;
            end

            bi_addr_a = 6 + pool_cnt[8:6];
            if (&pool_cnt[5:0])
            begin
                bi_addr_a = 6 + pool_cnt[8:6] + 1;
            end

            if (valid_o) 
            begin
                pool_cnt_next = pool_cnt + 1;
                if (&pool_cnt[8:0]) 
                begin
                    pool_cnt_next = 0;
                    rcv_state_next = FC7_PROCESS;
                end

                // use my_pool_bufs[0][0] as accumulator
                accum_l6_next = accum_l6 + accum_o[0];
                if (&pool_cnt[2:0]) 
                begin
                    accum_l6_next = 0;
                    fmap_wr_en_III[pool_cnt[8:3]] = 1;
                    fmap_wr_data_III[pool_cnt[8:3]] = relu_sext(accum_l6 + accum_o[0] + {{2{bi_q_a[127 - 16*pool_cnt[5:3]]}}, bi_q_a[127 - 16*pool_cnt[5:3]-:16]} );

                    // FIFO SAMPLING FOR LAYER 6
                    // (insert code here)
                    //
                    // passes (positive overflow not considered , however)
                    /*
                    if (~fifo_full) begin
                        fifo_wr_en = 1;
                        fifo_din = relu_sext(accum_l6 + accum_o[0] + {{2{bi_q_a[127 - 16*pool_cnt[5:3]]}}, bi_q_a[127 - 16*pool_cnt[5:3]-:16]} );
                    end*/
                    
                end
            end
        end

        FC7_PROCESS : 
        begin
            bi_addr_a = 14 + pool_cnt[3];
            if (&pool_cnt[2:0])
            begin
                bi_addr_a = 15;
            end

            if (valid_o)
            begin
                pool_cnt_next = pool_cnt + 1;
                classification_next[pool_cnt] = accum_o[0][15:0] + bi_q_a[127 - 16*pool_cnt[2:0]-:16];

                /*
                if (~fifo_full) begin
                    fifo_wr_en = 1;
                    fifo_din = accum_o[0][15:0] + bi_q_a[127 - 16*pool_cnt[2:0]-:16];
                end*/
                
            end

            if (pool_cnt == 9) 
            begin
                pool_cnt_next = 0;
                rcv_state_next = CLASSIFY;
                classification_next[pool_cnt] = accum_o[0][15:0] + bi_q_a[127 - 16*pool_cnt[2:0]-:16];

                /*
                if (~fifo_full) begin
                    fifo_wr_en = 1;
                    fifo_din = accum_o[0][15:0] + bi_q_a[127 - 16*pool_cnt[2:0]-:16];
                end*/
                
            end
        end

        CLASSIFY :
        begin
            classify_pipeline_v_next = 1;
            rcv_state_next = CONV2_PROCESS;
            bi_addr_a = 0;
            bi_addr_b = 0;

            // reset
            fmap_cnt_x_next = 0;
            fmap_cnt_y_next = 0;
            pool_cnt_next = 0;
            accum_l6_next = 0;
            rcv_layer_next = CONV2_layer;
            x_decimate_next = 0;
            y_decimate_next = 0;
            pool_cnt_next = 0;
            pool_cnt_x_next = 0;
            pool_cnt_y_next = 0;
            rcv_fmap_next = 0;
        end

        default :
        begin
            rcv_state_next = CONV2_PROCESS;
        end

    endcase

end

// MAX FUNCTION PIPELINE
wire R1_valid_n, R2_valid_n, R3_valid_n, R4_valid_n;
reg R1_valid, R2_valid, R3_valid, R4_valid;
wire [3:0] R1_temp1_n, R1_temp2_n, R1_temp3_n, R1_temp4_n, R1_temp5_n, R2_temp1_n, R2_temp2_n, R3_temp1_n, R4_temp1_n;
reg [3:0] R1_temp1, R1_temp2, R1_temp3, R1_temp4, R1_temp5, R2_temp1, R2_temp2, R3_temp1, R4_temp1;

// STAGE 1
assign R1_temp1_n = (classification[0] > classification[1]) ? 0 : 1;
assign R1_temp2_n = (classification[2] > classification[3]) ? 2 : 3;
assign R1_temp3_n = (classification[4] > classification[5]) ? 4 : 5;
assign R1_temp4_n = (classification[6] > classification[7]) ? 6 : 7;
assign R1_temp5_n = (classification[8] > classification[9]) ? 8 : 9;
assign R1_valid_n = classify_pipeline_v_next;

// STAGE 2
assign R2_temp1_n = (classification[R1_temp1] > classification[R1_temp2]) ? R1_temp1 : R1_temp2;
assign R2_temp2_n = (classification[R1_temp3] > classification[R1_temp4]) ? R1_temp3 : R1_temp4;
assign R2_valid_n = R1_valid;

// STAGE 3
assign R3_temp1_n = (classification[R2_temp1] > classification[R2_temp2]) ? R2_temp1 : R2_temp2;
assign R3_valid_n = R2_valid;

// STAGE 4
assign R4_temp1_n = (classification[R3_temp1] > classification[R1_temp5]) ? R3_temp1 : R1_temp5;
assign R4_valid_n = R3_valid;

// OUTPUT STAGE
assign digit_o = R4_temp1;
assign digit_o_valid = R4_valid;

///////////////////////////// WRITE THE RESULT INTO FIFO ////////////////////////

/*
always_comb
begin
    fifo_din = R4_temp1;
    fifo_wr_en = 0;
    if (R4_valid) 
    begin
        if (~fifo_full) 
        begin
            fifo_wr_en = 1;
        end
    end
end
*/

// dff 
always_ff @(posedge clk or negedge rst) 
begin
    if (~rst)
    begin
        for (q = 0; q < 30; q = q + 1) 
        begin
            for (r = 0; r < 16; r = r + 1) 
            begin
                my_pool_bufs[q][r] <= 0;
            end
        end // 30x16 = 480 regs (30 words)
        for (q = 0; q < 10; q = q + 1) 
        begin
            classification[q] <= 0;
        end // 10*16 = 160 regs (10 words)
        fmap_cnt_x <= 0;
        fmap_cnt_y <= 0;
        rcv_state <= CONV2_PROCESS;
        x_decimate <= 0;
        y_decimate <= 0;
        pool_cnt_x <= 0;
        pool_cnt_y <= 0;
        pool_cnt <= 0;
        rcv_fmap <= 0;
        rcv_layer <= CONV2_layer;
        accum_l6 <= 0;

        // MAX FUNC PIPELINE REGS

        // STAGE 1

        R1_temp1 <= 0;
        R1_temp2 <= 0;
        R1_temp3 <= 0;
        R1_temp4 <= 0;
        R1_temp5 <= 0;
        R1_valid <= 0;

        // STAGE 2

        R2_temp1 <= 0;
        R2_temp2 <= 0;
        R2_valid <= 0;

        // STAGE 3

        R3_temp1 <= 0;
        R3_valid <= 0;

        // STAGE 4

        R4_temp1 <= 0;
        R4_valid <= 0;

    end else begin
        for (q = 0; q < 30; q = q + 1) 
        begin
            for (r = 0; r < 16; r = r + 1) 
            begin
                my_pool_bufs[q][r] <= my_pool_bufs_next[q][r];
            end
        end
        for (q = 0; q < 10; q = q + 1) 
        begin
            classification[q] <= classification_next[q];
        end
        fmap_cnt_x <= fmap_cnt_x_next;
        fmap_cnt_y <= fmap_cnt_y_next;
        rcv_state <= rcv_state_next;
        x_decimate <= x_decimate_next;
        y_decimate <= y_decimate_next;
        pool_cnt_x <= pool_cnt_x_next;
        pool_cnt_y <= pool_cnt_y_next;
        pool_cnt <= pool_cnt_next;
        rcv_fmap <= rcv_fmap_next;
        rcv_layer <= rcv_layer_next;
        accum_l6 <= accum_l6_next;

        // MAX FUNC PIPELINE REGS

        // STAGE 1

        R1_temp1 <= R1_temp1_n;
        R1_temp2 <= R1_temp2_n;
        R1_temp3 <= R1_temp3_n;
        R1_temp4 <= R1_temp4_n;
        R1_temp5 <= R1_temp5_n;
        R1_valid <= R1_valid_n;

        // STAGE 2

        R2_temp1 <= R2_temp1_n;
        R2_temp2 <= R2_temp2_n;
        R2_valid <= R2_valid_n;

        // STAGE 3

        R3_temp1 <= R3_temp1_n;
        R3_valid <= R3_valid_n;

        // STAGE 4

        R4_temp1 <= R4_temp1_n;
        R4_valid <= R4_valid_n;

    end
end

endmodule