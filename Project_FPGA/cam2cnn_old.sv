`timescale 1ns/1ns

module cam2cnn 
(
    input clk,
    input rst,
    input EOF,
    input [7:0] raw_pixel,
    input raw_pixel_valid,
    output [3:0] digit,
    output digit_valid_output
);


    /////////////////////////// PARAMETERS ////////////////////////////////////////

    localparam IMG_DIM = 30;
    localparam NUM_SAMPLES = 1;


    ////////////////////////// STRICT PARAMETERS //////////////////////////////////

    localparam GS_BITS = 8;
    localparam BCD_BITS = 4;
    localparam D_WIDTH = 8;


    //////////////////////////////// SIGNALS ////////////////////////////////////

    localparam NUM_BYTES_IM = IMG_DIM * IMG_DIM;
    localparam NUM_BYTES_TOTAL = NUM_BYTES_IM * NUM_SAMPLES;
    reg [GS_BITS-1:0] mem [NUM_BYTES_TOTAL-1:0];
    reg rd_state, rd_state_next;         /// encode 2 states 

    reg [1:0] wr_state, wr_state_next ;  /// encode 3 states

    // Counters
    wire fifo_in_count_done, fifo_out_count_done;
    reg fifo_in_count_en, fifo_out_count_en;
    wire [31:0] fifo_in_count, fifo_out_count;


    /////////////////////////////////// DUT /////////////////////////////////////////
    
    reg [GS_BITS-1:0] pixel_i;
    reg pixel_i_valid;
    reg [BCD_BITS-1:0] digit_o;
    reg digit_o_valid;



    top top_u
    (
        .clk           (clk),
        .rst           (rst),

        .pixel_i       (pixel_i),
        .pixel_i_valid (pixel_i_valid),

        .digit_o       (digit_o),
        .digit_o_valid (digit_o_valid)
    );

    assign digit_valid_output = digit_o_valid;
    




    ///////////////////////// SEND PIXELS TO DUT /////////////////////////////////

    always_ff @(posedge clk or negedge rst) 
    begin
        if (~rst) 
        begin
            wr_state <= 0;
            rd_state <= 0;
        end else 
        begin
            wr_state <= wr_state_next;
            rd_state <= rd_state_next;
        end
    end
    


    // FIFO INTO CNN
    reg in_fifo_wr_en;
    reg in_fifo_rd_en;
    wire in_fifo_full;
    wire in_fifo_empty;
    reg [D_WIDTH-1:0] in_fifo_din;
    wire [D_WIDTH-1:0] in_fifo_dout;
    
    fifo #(
        .FIFO_DATA_WIDTH(D_WIDTH), 
        .FIFO_BUFFER_SIZE(1024)
    ) 
    in_fifo
    (
        .rd_clk (clk),
        .wr_clk (clk),
        .reset  (rst),
        .rd_en  (in_fifo_rd_en),
        .wr_en  (in_fifo_wr_en),
        .din    (in_fifo_din),
        .dout   (in_fifo_dout),
        .full   (in_fifo_full),
        .empty  (in_fifo_empty)
    );




    // Writing into the INPUT FIFO 
    always_comb
    begin
        in_fifo_din = raw_pixel;
        in_fifo_wr_en = 0;
        fifo_in_count_en = 0;
        wr_state_next = wr_state;

        case (wr_state)
            0 :
            begin
                if (~in_fifo_full) 
                begin
                    if (raw_pixel_valid)
                    begin
                        in_fifo_wr_en = 1;
                        fifo_in_count_en = 1;
                        if (fifo_in_count_done)
                        begin
                            wr_state_next = 1;
                        end
                    end
                end
            end
            1:
            begin
                if (digit_o_valid)
                begin
                    wr_state_next = 2;
                end
            end
            2:
            begin
                if (EOF)
                begin
                    wr_state_next = 0;
                end
            end
        endcase
    end




    // Reading from the input FIFO ( and into the CNN )
    always_comb
    begin
        in_fifo_rd_en = 0;
        pixel_i_valid = 0;
        pixel_i = in_fifo_dout;
        rd_state_next = rd_state;
        fifo_out_count_en = 0;

        case (rd_state) 
            0 : 
            begin
                if (~in_fifo_empty) 
                begin
                    in_fifo_rd_en = 1;
                    pixel_i_valid = 1;
                    fifo_out_count_en = 1;
                    if (fifo_out_count_done)
                    begin
                        rd_state_next = 1;
                    end
                end
            end
            1 : 
            begin
                if (digit_o_valid) begin
                    rd_state_next = 0;
                end
            end
        endcase
    end




    ////////////////////////////////// COUNTERS /////////////////////////////////////////



    mod_N_counter #(
        .N(NUM_BYTES_TOTAL),
        .N_BITS(32)
    ) 
    fifo_in_counter 
    (
        .clk   (clk),
        .rst   (rst),
        .en    (fifo_in_count_en),
        .count (fifo_in_count),
        .done  (fifo_in_count_done)
    );



    mod_N_counter #(
        .N(NUM_BYTES_IM),
        .N_BITS(32)
    )
    fifo_out_counter
    (
        .clk  (clk),
        .rst  (rst),
        .en   (fifo_out_count_en),
        .count(fifo_out_count),
        .done (fifo_out_count_done)
    );



    ////////////////////// OUTPUT DIGIT ///////////////////////////////////

    assign digit = digit_o;

endmodule
