`timescale 1ns / 1ps

module tb_async_fifo;

    // Testbench Signals
    reg clk_rd;
    reg clk_wr;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [7:0] d_in;
    
    wire empty;
    wire full;
    wire [7:0] d_out;

    // Instantiate the Device Under Test (DUT)
    async_fifo uut (
        .clk_rd(clk_rd),
        .clk_wr(clk_wr),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .rst(rst),
        .d_in(d_in),
        .empty(empty),
        .full(full),
        .d_out(d_out)
    );

    // 1. Clock Generation Block
    // Write Clock: 10ns period (100 MHz)
    initial begin
        clk_wr = 0;
        forever #(5) clk_wr = ~clk_wr;
    end

    // Read Clock: 16ns period (~62.5 MHz) - Asynchronous to clk_wr
    initial begin
        clk_rd = 0;
        forever #(8) clk_rd = ~clk_rd;
    end

    // 2. Stimulus Block
    initial begin
        // Initialize Inputs
        rst   = 0;
        wr_en = 0;
        rd_en = 0;
        d_in  = 8'h00;

        // Apply Reset
        #25;
        rst = 1;
        #15;

        // --- Test 1: Write data into the FIFO ---
        @(posedge clk_wr);
        $display("[%0t] Starting Write Operations...", $time);
        repeat (5) begin
            @(posedge clk_wr);
            wr_en = 1;
            d_in  = d_in + 8'h11; // Increment data value
        end
        
        @(posedge clk_wr);
        wr_en = 0; // Stop writing

        #40;

        // --- Test 2: Read data from the FIFO ---
        @(posedge clk_rd);
        $display("[%0t] Starting Read Operations...", $time);
        repeat (5) begin
            @(posedge clk_rd);
            rd_en = 1;
        end
        
        @(posedge clk_rd);
        rd_en = 0; // Stop reading

        #50;

        // --- Test 3: Fill FIFO completely to check FULL flag ---
        $display("[%0t] Filling FIFO to test FULL flag...", $time);
        repeat (20) begin
            @(posedge clk_wr);
            wr_en = 1;
            d_in  = d_in + 8'h01;
        end
        @(posedge clk_wr);
        wr_en = 0;

        #40;

        // --- Test 4: Drain FIFO completely to check EMPTY flag ---
        $display("[%0t] Emptying FIFO to test EMPTY flag...", $time);
        repeat (20) begin
            @(posedge clk_rd);
            rd_en = 1;
        end
        @(posedge clk_rd);
        rd_en = 0;

        #100;
        $display("[%0t] Simulation Finished.", $time);
        $finish;
    end

    // Optional: Monitor changes in console
    initial begin
        $monitor("Time=%0t | rst=%b | wr_en=%b rd_en=%b | d_in=0%h | d_out=0x%h | empty=%b full=%b", 
                 $time, rst, wr_en, rd_en, d_in, d_out, empty, full);
    end

endmodule
