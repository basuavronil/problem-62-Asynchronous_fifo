// Asynchronous FIFO, 16 x 8, Gray-coded pointers, registered flags
module async_fifo (
    input        clk_rd, clk_wr, wr_en, rd_en, rst,   // rst: active-low, asynchronous
    input  [7:0] d_in,
    output reg   empty, full,
    output reg [7:0] d_out
);

    reg [7:0] mem [0:15];
    reg [4:0] rd_ptr, wr_ptr, gray_rd, gray_wr;
    reg [4:0] syncff1_rd, syncff2_rd, syncff1_wr, syncff2_wr;

    // ---------------------------------------------------------------
    // 0. Reset synchronizers: async assert, synchronous deassert,
    //    one per clock domain
    // ---------------------------------------------------------------
    reg rstff1_wr, rstff2_wr, rstff1_rd, rstff2_rd;
    wire rst_wr = rstff2_wr;
    wire rst_rd = rstff2_rd;

    always @(posedge clk_wr or negedge rst) begin
        if (!rst) {rstff2_wr, rstff1_wr} <= 2'b00;
        else      {rstff2_wr, rstff1_wr} <= {rstff1_wr, 1'b1};
    end

    always @(posedge clk_rd or negedge rst) begin
        if (!rst) {rstff2_rd, rstff1_rd} <= 2'b00;
        else      {rstff2_rd, rstff1_rd} <= {rstff1_rd, 1'b1};
    end

    // ---------------------------------------------------------------
    // Next-state values (computed once, reused everywhere)
    // ---------------------------------------------------------------
    wire       wr_fire      = wr_en && !full;
    wire       rd_fire      = rd_en && !empty;
    wire [4:0] wr_ptr_next  = wr_ptr + {4'd0, wr_fire};
    wire [4:0] rd_ptr_next  = rd_ptr + {4'd0, rd_fire};
    wire [4:0] gray_wr_next = (wr_ptr_next >> 1) ^ wr_ptr_next;
    wire [4:0] gray_rd_next = (rd_ptr_next >> 1) ^ rd_ptr_next;

    // ---------------------------------------------------------------
    // 1. Write Domain Logic
    // ---------------------------------------------------------------
    always @(posedge clk_wr or negedge rst_wr) begin
        if (!rst_wr) begin
            wr_ptr  <= 5'd0;
            gray_wr <= 5'd0;
            full    <= 1'b0;
        end else begin
            wr_ptr  <= wr_ptr_next;
            gray_wr <= gray_wr_next;
            // FULL: next write Gray pointer == synced read Gray pointer
            //       with the top 2 bits inverted
            full    <= (gray_wr_next == {~syncff2_rd[4:3], syncff2_rd[2:0]});
        end
    end

    // Memory write: no reset, so it can map to RAM / a macro
    always @(posedge clk_wr) begin
        if (rst_wr && wr_fire)
            mem[wr_ptr[3:0]] <= d_in;
    end

    // ---------------------------------------------------------------
    // 2. Synchronize Read Pointer into Write Domain (for FULL flag)
    // ---------------------------------------------------------------
    always @(posedge clk_wr or negedge rst_wr) begin
        if (!rst_wr) begin
            syncff1_rd <= 5'd0;
            syncff2_rd <= 5'd0;
        end else begin
            syncff1_rd <= gray_rd;
            syncff2_rd <= syncff1_rd;
        end
    end

    // ---------------------------------------------------------------
    // 3. Read Domain Logic
    // ---------------------------------------------------------------
    always @(posedge clk_rd or negedge rst_rd) begin
        if (!rst_rd) begin
            d_out   <= 8'd0;
            rd_ptr  <= 5'd0;
            gray_rd <= 5'd0;
            empty   <= 1'b1;               // FIFO is empty after reset
        end else begin
            if (rd_fire)
                d_out <= mem[rd_ptr[3:0]];
            rd_ptr  <= rd_ptr_next;
            gray_rd <= gray_rd_next;
            // EMPTY: next read Gray pointer == synced write Gray pointer
            empty   <= (gray_rd_next == syncff2_wr);
        end
    end

    // ---------------------------------------------------------------
    // 4. Synchronize Write Pointer into Read Domain (for EMPTY flag)
    // ---------------------------------------------------------------
    always @(posedge clk_rd or negedge rst_rd) begin
        if (!rst_rd) begin
            syncff1_wr <= 5'd0;
            syncff2_wr <= 5'd0;
        end else begin
            syncff1_wr <= gray_wr;
            syncff2_wr <= syncff1_wr;
        end
    end

endmodule
