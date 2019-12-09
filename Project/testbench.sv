// Module: testbench.sv
// Date: 12/7/2019
// Description: TESTBENCH is the top level module used to simulate the design.
// Test MNIST data is fed in as stimuli. FIFO's are used to stream data in and out
// of the CNN DUT. 

`timescale 1ns/1ns

module testbench;

    /////////////////////////// PARAMETERS ////////////////////////////////////////

    string IN_FILE = "mnist_test_digit_set.hex";
    localparam IMG_DIM = 30;
    localparam NUM_SAMPLES = 1000;
    time PERIOD = 20ns; // (50 MHz clock)

    ////////////////////////// STRICT PARAMETERS //////////////////////////////////

    localparam GS_BITS = 8;
    localparam BCD_BITS = 4;
    localparam D_WIDTH = 16;

    //////////////////////////////// TB SIGNALS ////////////////////////////////////

    localparam NUM_BYTES_IM = IMG_DIM * IMG_DIM;
    localparam NUM_BYTES_TOTAL = NUM_BYTES_IM * NUM_SAMPLES;
    reg clk;
    reg rst;
    reg start;
    reg [GS_BITS-1:0] mem [NUM_BYTES_TOTAL-1:0];
    reg tb_state, tb_state_next;
    reg [31:0] fifo_in_count;
    reg fifo_in_count_en;
    reg [31:0] fifo_out_count;
    reg fifo_out_count_en;
    reg fifo_out_count_done;

    /////////////////////////////////// DUT /////////////////////////////////////////
    
    reg [GS_BITS-1:0] pixel_i;
    reg pixel_i_valid;
    reg [BCD_BITS-1:0] digit_o;
    reg digit_o_valid;
    wire out_fifo_rd_en;
    wire [D_WIDTH-1:0] out_fifo_dout;
    wire out_fifo_empty;

    top #(
        .GS_BITS(GS_BITS),
        .BCD_BITS(BCD_BITS),
        .D_WIDTH(D_WIDTH)
    )
    top_u
    (
        .clk           (clk),
        .rst           (rst),
        .pixel_i       (pixel_i),
        .pixel_i_valid (pixel_i_valid),
        .digit_o       (digit_o),
        .digit_o_valid (digit_o_valid),

        // TESTING
        .fifo_rd_en    (out_fifo_rd_en),
        .fifo_dout     (out_fifo_dout),
        .fifo_empty    (out_fifo_empty)
    );
    
    ///////////////////////////// INITIALIZE MEM /////////////////////////////////

    initial begin
        $readmemh(IN_FILE, mem, 0, NUM_BYTES_TOTAL - 1);
        $display($time, " << .hex file done reading >> ");
        start = 0;
        clk = 0;
        rst = 0;
        #(PERIOD*2) rst = 1;
        #(PERIOD*2) rst = 0;
        $display($time, " << rst finished >> ");
        start = 1;
        $display($time, " << Simulation started >> ");
    end

    /////////////////////////// CLK /////////////////////////////////////////////

    always begin
        #(PERIOD/2) clk = ~clk;
    end

    ///////////////////////// SEND PIXELS TO DUT /////////////////////////////////

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
    fifo_dout
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

    always_ff @(posedge clk or posedge rst) 
    begin
        if (rst) 
        begin
            tb_state <= 0;
        end else 
        begin
            tb_state <= tb_state_next;
        end
    end

    // Writing into the INPUT FIFO ( from memory )
    always_comb
    begin
        in_fifo_din = mem[fifo_in_count];
        in_fifo_wr_en = 0;
        fifo_in_count_en = 0;
        
        if (start) 
        begin
            if (fifo_in_count < NUM_BYTES_TOTAL) 
            begin
                if (~in_fifo_full) 
                begin
                    in_fifo_wr_en = 1;
                    fifo_in_count_en = 1;
                end
            end
        end
    end

    // Reading from the input FIFO ( and into the CNN )
    always_comb
    begin
        in_fifo_rd_en = 0;
        pixel_i_valid = 0;
        pixel_i = in_fifo_dout;
        tb_state_next = tb_state;
        fifo_out_count_en = 0;

        case (tb_state) 
            0 : 
            begin
                if (~in_fifo_empty) 
                begin
                    in_fifo_rd_en = 1;
                    pixel_i_valid = 1;
                    fifo_out_count_en = 1;
                    if (fifo_out_count_done)
                    begin
                        tb_state_next = 1;
                    end
                end
            end
            1 : 
            begin
                if (digit_o_valid) begin
                    tb_state_next = 0;
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
        .count (fifo_in_count)
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

    ////////////////////////////////// OUTPUT TO TEXT ///////////////////////////////////

    int fd;
    assign out_fifo_rd_en = (out_fifo_empty) ? 0 : 1;

    initial begin
        fd = $fopen("sample.txt","w");
    end

    always_ff @(posedge clk) begin
        if (out_fifo_rd_en) begin
            $fdisplay(fd, "%04h", out_fifo_dout);
        end
    end

endmodule
