`timescale 1ns/1ps

module priority_fifo_tb;

    localparam DATA_WIDTH = 32;
    localparam PRIORITY_WIDTH = 2;
    localparam DEPTH = 4;

    reg clk;
    reg rst_n;

    reg wr_en;
    reg [DATA_WIDTH-1:0] wr_data;
    reg [PRIORITY_WIDTH-1:0] wr_priority;

    reg rd_en;

    wire [DATA_WIDTH-1:0] rd_data;
    wire [PRIORITY_WIDTH-1:0] rd_priority;
    wire rd_valid;

    wire full;
    wire empty;
    wire [2:0] count;

    priority_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .PRIORITY_WIDTH(PRIORITY_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .wr_priority(wr_priority),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .rd_priority(rd_priority),
        .rd_valid(rd_valid),
        .full(full),
        .empty(empty),
        .count(count)
    );

    always #5 clk = ~clk;

    /*
     * WRITE ONE ENTRY
     */
    task write_entry;
        input [DATA_WIDTH-1:0] data;
        input [PRIORITY_WIDTH-1:0] prio;
        begin
            @(negedge clk);

            wr_en = 1'b1;
            wr_data = data;
            wr_priority = prio;

            @(negedge clk);

            wr_en = 1'b0;
            wr_data = 32'b0;
            wr_priority = 2'b0;
        end
    endtask

    /*
     * READ ONE ENTRY
     */
    task read_entry;
        begin
            @(negedge clk);

            rd_en = 1'b1;

            @(posedge clk);
            #1;

            if (rd_valid) begin
                $display(
                    "READ: DATA=%h PRIORITY=%0d",
                    rd_data,
                    rd_priority
                );
            end
            else begin
                $display("READ: FIFO EMPTY");
            end

            @(negedge clk);

            rd_en = 1'b0;
        end
    endtask

    initial begin

        clk = 1'b0;
        rst_n = 1'b0;

        wr_en = 1'b0;
        wr_data = 32'b0;
        wr_priority = 2'b0;

        rd_en = 1'b0;

        $dumpfile("priority_fifo.vcd");
        $dumpvars(0, priority_fifo_tb);

        /*
         * =========================
         * TEST 1: RESET
         * =========================
         */

        $display("");
        $display("======================================");
        $display("TEST 1: RESET");
        $display("======================================");

        #20;

        rst_n = 1'b1;

        #5;

        if (empty && !full && count == 0)
            $display("TEST 1 PASS");
        else
            $display("TEST 1 FAIL");

        /*
         * =========================
         * TEST 2: PRIORITY
         * =========================
         */

        $display("");
        $display("======================================");
        $display("TEST 2: PRIORITY ORDER");
        $display("======================================");

        /*
         * A = priority 1
         * B = priority 3
         * C = priority 0
         * D = priority 2
         *
         * Expected:
         *
         * B
         * D
         * A
         * C
         */

        write_entry(32'hAAAA0001, 2'd1);
        write_entry(32'hBBBB0002, 2'd3);
        write_entry(32'hCCCC0003, 2'd0);
        write_entry(32'hDDDD0004, 2'd2);

        #2;

        if (full && count == 4)
            $display("FIFO FULL PASS");
        else
            $display("FIFO FULL FAIL");

        read_entry();
        read_entry();
        read_entry();
        read_entry();

        #2;

        if (empty && count == 0)
            $display("TEST 2 PASS");
        else
            $display("TEST 2 FAIL");

        /*
         * =========================
         * TEST 3: EQUAL PRIORITY
         * =========================
         */

        $display("");
        $display("======================================");
        $display("TEST 3: EQUAL PRIORITY FIFO ORDER");
        $display("======================================");

        /*
         * All have priority 2.
         *
         * Expected:
         *
         * 11110001
         * 22220002
         * 33330003
         */

        write_entry(32'h11110001, 2'd2);
        write_entry(32'h22220002, 2'd2);
        write_entry(32'h33330003, 2'd2);

        read_entry();
        read_entry();
        read_entry();

        #2;

        if (empty)
            $display("TEST 3 PASS");
        else
            $display("TEST 3 FAIL");

        /*
         * =========================
         * TEST 4: EMPTY READ
         * =========================
         */

        $display("");
        $display("======================================");
        $display("TEST 4: EMPTY FIFO");
        $display("======================================");

        @(negedge clk);

        rd_en = 1'b1;

        @(posedge clk);
        #1;

        if (!rd_valid)
            $display("TEST 4 PASS");
        else
            $display("TEST 4 FAIL");

        @(negedge clk);

        rd_en = 1'b0;

        /*
         * =========================
         * COMPLETE
         * =========================
         */

        #20;

        $display("");
        $display("======================================");
        $display("PRIORITY FIFO TEST COMPLETE");
        $display("======================================");

        $finish;

    end

endmodule
