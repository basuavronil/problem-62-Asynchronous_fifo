// Corrected Asynchronous FIFO Module
module async_fifo (
    input clk_rd, clk_wr, wr_en, rd_en, rst,
    input [7:0] d_in,
    output empty, full,
    output reg [7:0] d_out    
);  

    reg [7:0] mem [0:15];
    reg [4:0] rd_ptr, wr_ptr, gray_rd, gray_wr, syncff1_rd, syncff2_rd, syncff1_wr, syncff2_wr;

    // 1. Write Domain Logic
    always @(posedge clk_wr or negedge rst) begin
        if (!rst) begin
            wr_ptr  <= 5'd0;
            gray_wr <= 5'd0;
        end else if (wr_en && !full) begin
            mem[wr_ptr[3:0]] <= d_in;
            wr_ptr           <= wr_ptr + 1'b1;
            // Correct Gray encoding: (bin >> 1) ^ bin
            gray_wr          <= ((wr_ptr + 1'b1) >> 1) ^ (wr_ptr + 1'b1);
        end
    end
  
    // 2. Synchronize Read Pointer into Write Domain (for FULL flag)
    always @(posedge clk_wr or negedge rst) begin
        if (!rst) begin
            syncff1_rd <= 5'd0;
            syncff2_rd <= 5'd0;
        end else begin
            syncff1_rd <= gray_rd;
            syncff2_rd <= syncff1_rd;
        end
    end

    // 3. Read Domain Logic
    always @(posedge clk_rd or negedge rst) begin
        if (!rst) begin
            d_out   <= 8'd0;
            rd_ptr  <= 5'd0;
            gray_rd <= 5'd0;
        end else if (rd_en && !empty) begin
            d_out   <= mem[rd_ptr[3:0]];
            rd_ptr  <= rd_ptr + 1'b1;
            gray_rd <= ((rd_ptr + 1'b1) >> 1) ^ (rd_ptr + 1'b1);
        end
    end

    // 4. Synchronize Write Pointer into Read Domain (for EMPTY flag)
    always @(posedge clk_rd or negedge rst) begin
        if (!rst) begin
            syncff1_wr <= 5'd0;
            syncff2_wr <= 5'd0;
        end else begin
            syncff1_wr <= gray_wr;
            syncff2_wr <= syncff1_wr;
        end
    end

    // -------------------------------------------------------------
    // 5. Flag Generations using Synchronized Gray Pointers
    // -------------------------------------------------------------
    // FULL: Write Gray pointer matches Read Gray pointer with top 2 bits inverted
    assign full  = (gray_wr == {~syncff2_rd[4:3], syncff2_rd[2:0]});

    // EMPTY: Read Gray pointer matches synchronized Write Gray pointer
    assign empty = (gray_rd == syncff2_wr);

endmodule
