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

module cnn_sender # (parameter LINE_BUF_GROUPS = 16, LINE_BUFS = 2, KERNEL_DIM = 3) 
(
    input clk,
    input rst,

    // Ifmap pixel input
    input [7:0] pixel_i, //8b gs
    input pixel_i_valid,

    // Weights I/O
    output reg [6:0] addr_a [7:0],
    output reg [6:0] addr_b [7:0],
    input [143:0] q_a [7:0],
    input [143:0] q_b [7:0],

    //// NEW WEIGHTS i/o

    output reg [9:0] fc_addr_a [7:0],
    output reg [9:0] fc_addr_b [7:0],
    input [143:0] fc_q_a [7:0],
    input [143:0] fc_q_b [7:0],

    // Line buffer I/O
    input [15:0] line_buffer_rd_data [LINE_BUF_GROUPS-1:0][1:0], //16b fmap val
    output reg [4:0] line_buffer_rd_addr [LINE_BUF_GROUPS-1:0][1:0], //log2(30) = 5
    output reg [4:0] line_buffer_wr_addr [LINE_BUF_GROUPS-1:0][1:0],
    output reg [15:0] line_buffer_wr_data [LINE_BUF_GROUPS-1:0][1:0],
    output reg line_buffer_wr_en [LINE_BUF_GROUPS-1:0][1:0],

    // fmap I memory I/O, for the resulting fmaps of CONV2. (input image -> CONV2 -> fmap I)
    output reg [7:0] fmap_rd_addr_I [15:0],
    input [15:0] fmap_rd_data_I [15:0],

    // fmap II memory I/O, for the resulting fmaps of CONV4. (fmap I -> CONV4 -> fmap II)
    output reg [2:0] fmap_rd_addr_II [143:0],
    input reg [15:0] fmap_rd_data_II [143:0],

    // fmap III memory I/O, for the resulting fmaps of FC6. (fmap II -> FC6 -> fmap III).
    output reg fmap_rd_addr_III [63:0],
    input reg [15:0] fmap_rd_data_III [63:0],

    // mac array I/O
    output reg valid_i_final,
    output reg [143:0] wt [15:0],
    output reg [143:0] ifmap_chunk [15:0]
);

integer i, j, k, q, r, s;

// SENDING FSM's control, one-hot encoded (sends ifmap data to mac_array)
reg [3:0] state, state_next;
localparam CONV2_FILL_LINE_BUF = 0;
localparam CONV2_SEND_TO_CNN = 1;
localparam CONV2_SEND_LAST_WINDOW = 2;
localparam CONV4_FILL_LINE_BUF = 3;
localparam CONV4_SEND_TO_CNN = 4;
localparam CONV4_SEND_LAST_WINDOW = 5;
localparam STALL_FF_FC6 = 6;
localparam FF_FC6 = 7;
localparam STALL_FF_FC7 = 8;
localparam FF_FC7 = 9;

// registers to keep track of which layer we're on
reg [3:0] layer, layer_next; // for the sending FSM (may be on a different layer than the rcv FSM)
localparam CONV2_layer = 4'b0001;
localparam CONV4_layer = 4'b0010;
localparam FC6_layer = 4'b0100;
localparam FC7_layer = 4'b1000;

// SENDING FSM's ifmap position tracker.
reg [4:0] current_x, current_x_next, current_y, current_y_next;

// SENDING FSM's 1 bit counter for the line buffer positional encoding (alternating 0, 1)
reg counter_1b, counter_1b_next;

// SENDING FSM's 3x3 register buffers aka our sliding window for the input fmap of 16b resolution. 
// We have 16 of these windows.
// resource utilization: 16x (3x3) pixels = 144 pixels going to the mac_array, which perfectly has 144 multipliers.
// Note: these buffers used for CONV2 and CONV4 processing only.
reg [15:0] reg_buffer [KERNEL_DIM-1:0][KERNEL_DIM-1:0][LINE_BUF_GROUPS-1:0];
reg [15:0] reg_buffer_next [KERNEL_DIM-1:0][KERNEL_DIM-1:0][LINE_BUF_GROUPS-1:0];

// another note: 16 bit representation: X.XXXX_XXXX_XXXX_XXX
// bit 15 is the signed bit, and bits 0-14 are the mantissa.

// track WHICH fmap we're on. send_fmap is for the SEND FS
reg [4:0] send_fmap, send_fmap_next; // log2(32) = 5 bits 

// Valid signal going into the mac_array, to indicate valid data passing through.
reg valid_i;

// SENDING FSM's position tracker (see where we are in the current input feature map)
// (essentially a behavioral model of a counter)

// SENDING FSM!
always_comb
begin
    //    dff window              sram line buf       
    // [(0,0) (1,0) (2,0)] . . .[[SRAM line buf]] . . .  (encoded as 0/1)
    // [(0,1)         :  ] . . .[[SRAM line buf]] . . .  (encoded as 1/0)
    // [(0,2) ......  :  ]
    for (i = 0; i < 16; i = i + 1) 
    begin
        for (j = 0; j < 2; j = j + 1) 
        begin
            line_buffer_wr_addr[i][j] = 0;
            line_buffer_wr_en[i][j] = 0;
            line_buffer_wr_data[i][j] = 0;
            line_buffer_rd_addr[i][j] = 0;
        end
    end
    for (i = 0; i < 3; i = i + 1) 
    begin
        for (j = 0; j < 3; j = j + 1) 
        begin
            for (k = 0; k < 16; k = k + 1) 
            begin
                reg_buffer_next[i][j][k] = reg_buffer[i][j][k];
            end
        end
    end
    for (k = 0; k < 8; k = k + 1) 
    begin
        addr_a[k] = 0;
        addr_b[k] = 1;
        fc_addr_a[k] = 0;
        fc_addr_b[k] = 1;
    end
    for (k = 0; k < 16; k = k + 1) 
    begin
        fmap_rd_addr_I[k] = 0;
    end
    for (k = 0; k < 144; k = k + 1) 
    begin
        fmap_rd_addr_II[k] = 0;
    end
    for (k = 0; k < 64; k = k + 1)
    begin
        fmap_rd_addr_III[k] = 0;
    end
    state_next = state;
    layer_next = layer;
    valid_i = 0;
    send_fmap_next = send_fmap;
    current_y_next = current_y;
    current_x_next = current_x;
    counter_1b_next = counter_1b;
    
    case (state) 

        CONV2_FILL_LINE_BUF : 
        begin
            if (pixel_i_valid) 
            begin

                current_x_next = current_x + 1;
                if (current_x == 29) 
                begin
                    current_y_next = current_y + 1;
                    current_x_next = 0;
                    counter_1b_next = ~counter_1b;
                    if (current_y == 29) 
                    begin
                        current_y_next = 0;
                        counter_1b_next = 0;
                    end
                end

                if ((~&current_x[1:0]) && (~|current_x[4:2])) // fill up the line buffer if x <= 2
                begin
                    for (k = 0; k < 16; k = k + 1) 
                    begin
                        reg_buffer_next[current_x][current_y][k] = {2'b0, pixel_i, 6'b0000000}; // pixel_i is an 8-bit gs value divided by 256.
                    end
                end
                if (~current_y[1]) // if y is 0 or 1
                begin
                    for (k = 0; k < 16; k = k + 1) 
                    begin
                        line_buffer_wr_en[k][counter_1b] = 1;
                    end
                end
                if (current_y[1] && current_x[1]) 
                begin
                    state_next = CONV2_SEND_TO_CNN;
                end
            end
            for (k = 0; k < 8; k = k + 1) 
            begin
                addr_a[k] = 0;
                addr_b[k] = 1;
            end
            for (k = 0; k < 16; k = k + 1) 
            begin
                line_buffer_rd_addr[k][0] = current_x + 1; 
                line_buffer_rd_addr[k][1] = current_x + 1; 
                line_buffer_wr_data[k][counter_1b] = {2'b0, pixel_i, 6'b0000000};
                line_buffer_wr_addr[k][counter_1b] = current_x;
            end

        end

        CONV2_SEND_TO_CNN :
        begin
            // depending on which layer, send the right weights over (located in different 
            // addresses of the weights memory)
            for (k = 0; k < 8; k = k + 1) 
            begin
                addr_a[k] = 0;
                addr_b[k] = 1;
            end

            for (k = 0; k < 16; k = k + 1) 
            begin
                line_buffer_wr_addr[k][counter_1b] = current_x - 3;
                line_buffer_wr_addr[k][~counter_1b] = current_x - 3 + 30; 
                line_buffer_wr_data[k][0] = reg_buffer[0][2][k];
                line_buffer_wr_data[k][1] = reg_buffer[0][2][k];
                line_buffer_rd_addr[k][0] = current_x + 1; 
                line_buffer_rd_addr[k][1] = current_x + 1; 
                if (current_x == 29) 
                begin
                    line_buffer_rd_addr[k][0] = 0;
                    line_buffer_rd_addr[k][1] = 0;
                end
            end

            if (pixel_i_valid) 
            begin
                // set VALID signal to mac_array high ONLY when our position (lower-right hand corner)
                // gives us a valid window (aka we're not currently crossing an edge)
                //
                // we have valid window @ (x >= 3 AND y >= 2), (OR x == 0 AND y >= 3)
                if ( (( ( &current_x[1:0] ) || ( |current_x[4:2] ) ) && ( current_y >= 2 )) || 
                    (( ~|current_x ) && ( ( &current_y[1:0] ) || ( |current_y[4:2] ) )) ) 
                begin
                    valid_i = 1;
                end
                if (current_x == 29 && current_y == 29) 
                begin        
                    state_next = CONV2_SEND_LAST_WINDOW;
                end

                // note: the assignment statements for the actual valid ifmap pixels themselves
                // are not in this always block (go to the end of this file to view them)
                //
                // in this state, we are also shifting the sliding window. 
                // one thing we must do is: take window's (0, 2) bottom lh corner pixel, and 
                // store it into the current TOP sram line buffer
                for (k = 0; k < 16; k = k + 1) 
                begin
                    if (current_x >= 3) 
                    begin
                        line_buffer_wr_en[k][counter_1b] = 1;
                    end 
                    else 
                    begin
                        line_buffer_wr_en[k][~counter_1b] = 1;
                    end
                    // shift all subwindow values to the left!
                    for (j = 0; j < 3; j = j + 1)
                    begin
                        for (i = 0; i < 2; i = i + 1) 
                        begin
                            reg_buffer_next[i][j][k] = reg_buffer[i + 1][j][k];
                        end
                    end
                    
                    // get new values for the RIGHTMOST column of the sliding window!
                    reg_buffer_next[2][0][k] = line_buffer_rd_data[k][counter_1b];
                    reg_buffer_next[2][1][k] = line_buffer_rd_data[k][~counter_1b];
                    reg_buffer_next[2][2][k] = {2'b0, pixel_i, 6'b0000000}; // pos. grayscale, (divide by 256)
                end

                current_x_next = current_x + 1;
                if (current_x == 29) 
                begin
                    current_y_next = current_y + 1;
                    current_x_next = 0;
                    counter_1b_next = ~counter_1b;
                    if (current_y == 29) 
                    begin
                        current_y_next = 0;
                        counter_1b_next = 0;
                    end
                end
            end
        end
        
        // notice that we still have the very last window of pixels to send over! don't forget.
        CONV2_SEND_LAST_WINDOW : 
        begin
            valid_i = 1;
            state_next = CONV4_FILL_LINE_BUF; 
            layer_next = CONV4_layer; 
            for (k = 0; k < 16; k = k + 1) 
            begin
                fmap_rd_addr_I[k] = 0;
            end
        end

        CONV4_FILL_LINE_BUF :
        begin
            for (k = 0; k < 16; k = k + 1) 
            begin
                if ((~&current_x[1:0]) && (~|current_x[4:2])) // fill up the line buffer if x <= 2
                begin
                    reg_buffer_next[current_x][current_y][k] = fmap_rd_data_I[k];
                end
                if (~current_y[1]) 
                begin
                    line_buffer_wr_en[k][counter_1b] = 1;
                end
                line_buffer_wr_data[k][counter_1b] = fmap_rd_data_I[k];
                line_buffer_wr_addr[k][counter_1b] = current_x;
                line_buffer_rd_addr[k][0] = current_x + 1; 
                line_buffer_rd_addr[k][1] = current_x + 1;
                fmap_rd_addr_I[k] = {current_y, 4'h0} - {current_y, 1'b0} + current_x + 1;
            end
            // 1st window ready; transition to state where we send out data to cnn
            if ((current_y[1]) && (current_x[1]) )
            begin
                state_next = CONV4_SEND_TO_CNN;
                for (k = 0; k < 8; k = k + 1) 
                begin
                    addr_a[k] = 2;
                    addr_b[k] = 3;
                end
            end

            current_x_next = current_x + 1;
            if (current_x == 13)
            begin
                current_y_next = current_y + 1;
                current_x_next = 0;
                counter_1b_next = ~counter_1b;
                if (current_y == 13)
                begin
                    current_y_next = 0;
                    counter_1b_next = 0;
                end
            end
        end

        CONV4_SEND_TO_CNN :
        begin
            if ( (( ( &current_x[1:0] ) || ( |current_x[4:2] ) ) && ( current_y >= 2 )) || 
                (( ~|current_x ) && ( ( &current_y[1:0] ) || ( |current_y[4:2] ) )) ) 
            begin
                valid_i = 1;
            end

            for (k = 0; k < 8; k = k + 1) 
            begin
                addr_a[k] = 2 + {send_fmap, 1'b0};
                addr_b[k] = 2 + {send_fmap, 1'b1};
            end

            if (current_x == 13 && current_y == 13) 
            begin        
                state_next = CONV4_SEND_LAST_WINDOW;
            end

            for (k = 0; k < 16; k = k + 1) 
            begin
                line_buffer_wr_addr[k][counter_1b] = current_x - 3;
                line_buffer_wr_addr[k][~counter_1b] = current_x - 3 + 14;
                line_buffer_wr_data[k][0] = reg_buffer[0][2][k];
                line_buffer_wr_data[k][1] = reg_buffer[0][2][k];
                line_buffer_rd_addr[k][0] = current_x + 1; 
                line_buffer_rd_addr[k][1] = current_x + 1;
                if (current_x == 13) 
                begin
                    line_buffer_rd_addr[k][0] = 0;
                    line_buffer_rd_addr[k][1] = 0;
                end 

                if (current_x >= 3) 
                begin
                    line_buffer_wr_en[k][counter_1b] = 1;
                end 
                else 
                begin
                    line_buffer_wr_en[k][~counter_1b] = 1;
                end

                // shift all subwindow values to the left!
                for (j = 0; j < 3; j = j + 1)
                begin
                    for (i = 0; i < 2; i = i + 1) 
                    begin
                        reg_buffer_next[i][j][k] = reg_buffer[i + 1][j][k];
                    end
                end

                // get new values for the RIGHTMOST column of the sliding window!
                fmap_rd_addr_I[k] = {current_y, 4'h0} - {current_y, 1'b0} + current_x + 1;
                if (current_x == 13 && current_y == 13)
                begin
                    fmap_rd_addr_I[k] = 0;
                end
                reg_buffer_next[2][0][k] = line_buffer_rd_data[k][counter_1b];
                reg_buffer_next[2][1][k] = line_buffer_rd_data[k][~counter_1b];
                reg_buffer_next[2][2][k] = fmap_rd_data_I[k];
            end

            current_x_next = current_x + 1;
            if (current_x == 13)
            begin
                current_y_next = current_y + 1;
                current_x_next = 0;
                counter_1b_next = ~counter_1b;
                if (current_y == 13)
                begin
                    current_y_next = 0;
                    counter_1b_next = 0;
                end
            end
        end

        CONV4_SEND_LAST_WINDOW :
        begin
            valid_i = 1;
            for (k = 0; k < 8; k = k + 1) 
            begin
                // SAVE FOR FC7!!!!!!!!!!!!!
                addr_a[k] = 2 + {send_fmap, 1'b0} + 2;
                addr_b[k] = 2 + {send_fmap, 1'b1} + 2;

            end
            state_next = CONV4_SEND_TO_CNN;
            send_fmap_next = send_fmap + 1;
            if (&send_fmap) 
            begin     
                state_next = STALL_FF_FC6;
                send_fmap_next = 0;
                
                reg_buffer_next[0][0][0] = 0;
            end
        end

        STALL_FF_FC6 :
        begin
            state_next = FF_FC6;
            layer_next = FC6_layer;
            for (k = 0; k < 8; k = k + 1) 
            begin
                // FOR FC6.
                fc_addr_a[k] = 0;
                fc_addr_b[k] = 1;
            end
            for (j = 0; j < 144; j = j + 1)
            begin
                fmap_rd_addr_II[j] = 0;
            end
        end

        FF_FC6 : 
        begin
            valid_i = 1;
            // get the weights
            for (k = 0; k < 8; k = k + 1) 
            begin
                fc_addr_a[k] = 0 + {reg_buffer[0][0][0][5:0], send_fmap[2:0], 1'b0} + 2;
                fc_addr_b[k] = 0 + {reg_buffer[0][0][0][5:0], send_fmap[2:0], 1'b1} + 2;
            end
            // get the 32x (6x6) fmaps from the fmap_II memory
            for (j = 0; j < 144; j = j + 1)
            begin
                fmap_rd_addr_II[j] = send_fmap[2:0] + 1;
                if (&send_fmap[2:0])
                begin
                    fmap_rd_addr_II[j] = 0;
                end
            end
            send_fmap_next[2:0] = send_fmap[2:0] + 1;
            if (&send_fmap[2:0]) 
            begin
                send_fmap_next[2:0] = 3'b000;
                reg_buffer_next[0][0][0][5:0] = reg_buffer[0][0][0][5:0] + 1;
                if (&reg_buffer[0][0][0][5:0]) 
                begin
                    state_next = STALL_FF_FC7;
                end
            end
        end

        STALL_FF_FC7 :
        begin
            state_next = FF_FC7;
            layer_next = FC7_layer;
            for (k = 0; k < 8; k = k + 1) 
            begin
                addr_a[k] = 66;
                addr_b[k] = 1;

                // FOR LAYER 6
                fc_addr_a[k] = 0;
                fc_addr_b[k] = 1;
            end
            for (k = 0; k < 64; k = k + 1)
            begin
                fmap_rd_addr_III[k] = 0;
            end
        end

        FF_FC7 : 
        begin
            valid_i = 1;
            // get the weights
            for (k = 0; k < 8; k = k + 1) 
            begin
                addr_a[k] = 66 + send_fmap + 1;
                if (send_fmap == 9) 
                begin
                    addr_a[k] = 0;
                    addr_b[k] = 1;
                end
            end
            for (k = 0; k < 64; k = k + 1)
            begin
                fmap_rd_addr_III[k] = 0;
            end
            send_fmap_next = send_fmap + 1;
            if (send_fmap == 9) 
            begin
                state_next = CONV2_FILL_LINE_BUF;

                // reset
                layer_next = CONV2_layer;
                send_fmap_next = 0;
            end
        end

        default :
        begin
            state_next = CONV2_FILL_LINE_BUF;
        end

    endcase

end

/////////////////////////// PIPELINE THE IFMAP CHUNKS OUT ///////////////////////////////

reg [143:0] ifmap_chunk_next [15:0];
reg [143:0] wt_next [15:0];

int iii;

always_comb
begin
    case (layer)

        CONV2_layer : 
        begin
            for (iii = 0; iii < 16; iii++)
            begin
                ifmap_chunk_next[iii] = {reg_buffer[0][0][0], reg_buffer[1][0][0], reg_buffer[2][0][0],
                    reg_buffer[0][1][0], reg_buffer[1][1][0], reg_buffer[2][1][0],
                    reg_buffer[0][2][0], reg_buffer[1][2][0], reg_buffer[2][2][0]};
            end
        end

        CONV4_layer :
        begin
            for (iii = 0; iii < 16; iii++)
            begin
                ifmap_chunk_next[iii] = {reg_buffer[0][0][iii], reg_buffer[1][0][iii], reg_buffer[2][0][iii],
                    reg_buffer[0][1][iii], reg_buffer[1][1][iii], reg_buffer[2][1][iii],
                    reg_buffer[0][2][iii], reg_buffer[1][2][iii], reg_buffer[2][2][iii]};
            end
        end

        FC6_layer :
        begin
            for (iii = 0; iii < 16; iii++)
            begin
                ifmap_chunk_next[iii] = {fmap_rd_data_II[0+9*iii], fmap_rd_data_II[1+9*iii], fmap_rd_data_II[2+9*iii],
                    fmap_rd_data_II[3+9*iii], fmap_rd_data_II[4+9*iii], fmap_rd_data_II[5+9*iii],
                    fmap_rd_data_II[6+9*iii], fmap_rd_data_II[7+9*iii], fmap_rd_data_II[8+9*iii]};
            end
        end

        FC7_layer :
        begin
            for (iii = 0; iii < 7; iii++)
            begin
                ifmap_chunk_next[iii] = {fmap_rd_data_III[0+9*iii], fmap_rd_data_III[1+9*iii], fmap_rd_data_III[2+9*iii],
                    fmap_rd_data_III[3+9*iii], fmap_rd_data_III[4+9*iii], fmap_rd_data_III[5+9*iii],
                    fmap_rd_data_III[6+9*iii], fmap_rd_data_III[7+9*iii], fmap_rd_data_III[8+9*iii]};
            end

            ifmap_chunk_next[7] = {fmap_rd_data_III[63], 128'd0000};

            for (iii = 8; iii < 16; iii++)
            begin
                ifmap_chunk_next[iii] = 0;
            end
        end

        default :
        begin
            for (iii = 0; iii < 16; iii++)
            begin
                ifmap_chunk_next[iii] = 0;
            end
        end

    endcase

    if (layer != FC6_layer)
    begin
        for (int yu = 0; yu < 8; yu = yu + 1) 
        begin
            wt_next[yu] = q_a[yu];
            wt_next[yu + 8] = q_b[yu];
        end
    end 
    else
    begin
        for (int yuu = 0; yuu < 8; yuu = yuu + 1) 
        begin
            wt_next[yuu] = fc_q_a[yuu];
            wt_next[yuu + 8] = fc_q_b[yuu];
        end
    end
end

// dff 
always_ff @(posedge clk or negedge rst) 
begin
    if (~rst) 
    begin
        for (q = 0; q < KERNEL_DIM; q = q + 1) 
        begin
            for (r = 0; r < KERNEL_DIM; r = r + 1) 
            begin
                for (s = 0; s < LINE_BUF_GROUPS; s = s + 1) 
                begin
                    reg_buffer[q][r][s] <= 0;
                end
            end
        end // 3x3x16x16 = 2304 regs 
        counter_1b <= 0;
        layer <= CONV2_layer;
        current_x <= 0;
        current_y <= 0;
        state <= CONV2_FILL_LINE_BUF;
        send_fmap <= 0;

        // PIPELINED IFMAP CHUNKS
        for (q = 0; q < 16; q = q + 1)
        begin
            ifmap_chunk[q] <= 0;
            wt[q] <= 0;
        end
        valid_i_final <= 0;
    end 
    else 
    begin
        for (q = 0; q < KERNEL_DIM; q = q + 1) 
        begin
            for (r = 0; r < KERNEL_DIM; r = r + 1) 
            begin
                for (s = 0; s < LINE_BUF_GROUPS; s = s + 1) 
                begin
                    reg_buffer[q][r][s] <= reg_buffer_next[q][r][s];
                end
            end
        end
        counter_1b <= counter_1b_next;
        layer <= layer_next;
        current_x <= current_x_next;
        current_y <= current_y_next;
        state <= state_next;
        send_fmap <= send_fmap_next;

        // PIPELINED IFMAP CHUNKS
        for (q = 0; q < 16; q = q + 1)
        begin
            ifmap_chunk[q] <= ifmap_chunk_next[q];
            wt[q] <= wt_next[q];
        end
        valid_i_final <= valid_i;
    end
end

endmodule