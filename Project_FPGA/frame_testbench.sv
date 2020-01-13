// Module: frame_testbench.sv
// Date: 12/7/2019
// Description: TESTBENCH is the top level module used to simulate the design.
// Test MNIST data is fed in as stimuli. FIFO's are used to stream data in and out
// of the CNN DUT. 

`timescale 1ns/1ns

module frame_testbench;

    /////////////////////////// PARAMETERS ////////////////////////////////////////

    string IN_FILE = "frame_set.hex";
    localparam NUM_SAMPLES = 3;

    localparam W = 160;
    localparam H = 120;
    localparam PIC_DIM = 30;
    localparam PIC_DIM_MULTIPLIER = 3;
    localparam THRESHOLD = 100;

    time PERIOD = 40ns; 
    localparam RGB_BITS = 24;
    localparam GS_BITS = 8;
    localparam BCD_BITS = 4;
    localparam D_WIDTH = 16;
    localparam NUM_PIXELS_IM = W * H;
    localparam NUM_PIXELS_TOTAL = NUM_PIXELS_IM * NUM_SAMPLES;

    // testbench signals 
    reg start;
    reg [RGB_BITS-1:0] mem [NUM_PIXELS_TOTAL-1:0];
    reg tb_state, tb_state_next;
    reg [31:0] count;
    reg count_en;
    reg h_count_en, v_count_en;

    // dut signals
    reg clk;
    reg rst;
    wire h_done, v_done;
    wire [12:0] h_count;
    wire [12:0] v_count;
    reg [BCD_BITS-1:0] DIGIT_OUT;
    reg DIGIT_VALID_OUTPUT;
    wire [7:0] iVGA_R;
    wire [7:0] iVGA_G;
    wire [7:0] iVGA_B;
    wire [23:0] PIXEL;
    reg BOX_VALID;

    mnist_classifier_top #(
        .H_BLANK_OFFSET (0),
        .V_BLANK_OFFSET (0),
        .W (W),
        .H (H),
        .PIC_DIM (PIC_DIM),
        .PIC_DIM_MULTIPLIER (PIC_DIM_MULTIPLIER),
        .THRESHOLD (THRESHOLD)
    ) dut
    (
        .VGA_CLK    (clk),
        .RESET_N    (rst),
        .VGA_HS     (~h_done),
        .VGA_VS     (~v_done),
        .VGA_H_CNT	( h_count ),
        .VGA_V_CNT	( v_count ),
        .iVGA_R	( iVGA_R ),
        .iVGA_G	( iVGA_G ),
        .iVGA_B	( iVGA_B ),
        .DIGIT_OUT  ( DIGIT_OUT ),
        .DIGIT_VALID_OUTPUT (DIGIT_VALID_OUTPUT ),
        .BOX_VALID	( BOX_VALID )
    );
    


    ///////////////////////////// INITIALIZE MEM /////////////////////////////////

    initial begin
        $readmemh(IN_FILE, mem, 0, NUM_PIXELS_TOTAL - 1);
        $display($time, " << .hex file done reading >> ");
        start = 0;
        clk = 0;
        rst = 1;
        #(40) rst = 0;
        #(40) rst = 1;
        $display($time, " << rst finished >> ");
        start = 1;
        $display($time, " << Simulation started >> ");
    end

    /////////////////////////// CLK /////////////////////////////////////////////

    always begin
        #(PERIOD/2) clk = ~clk;
    end

    ///////////////////////// SEND PIXELS TO DUT /////////////////////////////////


    always_ff @(posedge clk or negedge rst) 
    begin
        if (~rst) 
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
        count_en = 0;
        v_count_en = 0;
        h_count_en = 0;
        tb_state_next = tb_state;
        case (tb_state)
            0 : 
            begin
                if (start) begin
                    tb_state_next = 1;
                end
            end
            1 :
            begin
                if (count < NUM_PIXELS_TOTAL) 
                begin
                    count_en = 1;
                    h_count_en = 1;
                    if (h_done) begin
                        v_count_en = 1;
                    end
                    
                end else begin
                    tb_state_next = 2;
                end
            end
            2 :
            begin
                
            end
        endcase
        
    end
    assign PIXEL = mem[count];
    assign iVGA_R = PIXEL[23:16];
    assign iVGA_G = PIXEL[15:8];
    assign iVGA_B = PIXEL[7:0];
  
    ////////////////////////////////// COUNTERS /////////////////////////////////////////

    mod_N_counter #(
        .N(NUM_PIXELS_TOTAL),
        .N_BITS(32)
    ) 
    pixel_counter
    (
        .clk   (clk),
        .rst   (rst),
        .en    (count_en),
        .count (count)
    );

    mod_N_counter #(
        .N(W),
        .N_BITS(13)
    ) 
    h_counter
    (
        .clk   (clk),
        .rst   (rst),
        .en    (h_count_en),
        .count (h_count),
        .done (h_done)
    );

    mod_N_counter #(
        .N(H),
        .N_BITS(13)
    ) 
    v_counter
    (
        .clk   (clk),
        .rst   (rst),
        .en    (v_count_en),
        .count (v_count),
        .done (v_done)
    );

    ////////////////////////////////// OUTPUT TO TEXT ///////////////////////////////////

/*
    int fd;
    assign out_fifo_rd_en = (out_fifo_empty) ? 0 : 1;

    initial begin
        fd = $fopen("sample.txt","w");
    end

    always_ff @(posedge clk) begin
        if (out_fifo_rd_en) begin
            $fdisplay(fd, "%04h", out_fifo_dout);
        end
    end*/

endmodule
