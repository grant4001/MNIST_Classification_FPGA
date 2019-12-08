`timescale 1ns/1ns

module testbench;

    string IN_FILE = "mnist_test_digit_7.hex";
    parameter num_bytes = 30 * 30;
    reg clk;
    reg reset;
    reg pixel_i_valid, pixel_i_valid_next;
    reg [7:0] pixel_i, pixel_i_next;
    reg [31:0] counter, counter_next;
    reg start;
    reg [7:0] mem [num_bytes-1:0];
    wire [7:0] pixel_i_w;
    wire pixel_i_valid_w;
    wire [3:0] digit_o_w;
    wire digit_o_valid_w;

    initial begin
        $readmemh("mnist_test_digit_7.hex", mem, 0, num_bytes - 1);
        $display($time, " << .hex file done reading >> ");
        start = 0;
        clk = 0;
        reset = 0;
        #20 reset = 1'b1;
        #20 reset = 0;
        $display($time, " << Reset finished >> ");
        start = 1'b1;
        $display($time, " << Simulation started >> ");
    end

    // 50 MHz clock
    always begin
        #10 clk = ~clk;
    end

    // Send image serially into the dut
    always_ff @(posedge clk or posedge reset) 
    begin
        if (reset) begin
            pixel_i_valid <= 0;
            pixel_i <= 0;
            counter <= 0;
        end else begin
            pixel_i_valid <= pixel_i_valid_next;
            pixel_i <= pixel_i_next;
            counter <= counter_next;
        end
    end

    always_comb
    begin
        pixel_i_valid_next = 0;
        pixel_i_next = 0;
        counter_next = counter;
        if (start) begin
            if (counter < num_bytes) begin
                pixel_i_valid_next = 1;
                pixel_i_next = mem[counter];
                counter_next = counter + 1;
            end
        end
    end

    assign pixel_i_w = pixel_i;
    assign pixel_i_valid_w = pixel_i_valid;

    wire fifo_rd_en;
    wire [15:0] fifo_dout;
    wire fifo_empty;
    int fd;

    top top_u(
        .clk (clk),
        .rst (reset),
        .pixel_i (pixel_i_w),
        .pixel_i_valid (pixel_i_valid_w),
        .digit_o (digit_o_w),
        .digit_o_valid (digit_o_valid_w)

        // TESTING
        /*
        .fifo_rd_en (fifo_rd_en),
        .fifo_dout(fifo_dout),
        .fifo_empty(fifo_empty)
        */
    );
    
    assign fifo_rd_en = (fifo_empty) ? 0 : 1;
    initial begin
        fd = $fopen("sample.txt","w");
    end
    always_ff @(posedge clk) begin
        if (fifo_rd_en) begin
            $fdisplay(fd, "%04h", fifo_dout);
        end
    end

endmodule
