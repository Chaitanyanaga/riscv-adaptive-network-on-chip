`timescale 1ns/1ps

module fifo_bank_5port_tb;

    localparam DATA_WIDTH = 32;
    localparam PRIORITY_WIDTH = 2;
    localparam DEPTH = 4;

    reg clk;
    reg rst_n;

    reg [4:0] wr_en;

    reg [DATA_WIDTH-1:0] wr_data_0;
    reg [DATA_WIDTH-1:0] wr_data_1;
    reg [DATA_WIDTH-1:0] wr_data_2;
    reg [DATA_WIDTH-1:0] wr_data_3;
    reg [DATA_WIDTH-1:0] wr_data_4;

    reg [PRIORITY_WIDTH-1:0] wr_priority_0;
    reg [PRIORITY_WIDTH-1:0] wr_priority_1;
    reg [PRIORITY_WIDTH-1:0] wr_priority_2;
    reg [PRIORITY_WIDTH-1:0] wr_priority_3;
    reg [PRIORITY_WIDTH-1:0] wr_priority_4;

    reg [4:0] rd_en;

    wire [DATA_WIDTH-1:0] rd_data_0;
    wire [DATA_WIDTH-1:0] rd_data_1;
    wire [DATA_WIDTH-1:0] rd_data_2;
    wire [DATA_WIDTH-1:0] rd_data_3;
    wire [DATA_WIDTH-1:0] rd_data_4;

    wire [PRIORITY_WIDTH-1:0] rd_priority_0;
    wire [PRIORITY_WIDTH-1:0] rd_priority_1;
    wire [PRIORITY_WIDTH-1:0] rd_priority_2;
    wire [PRIORITY_WIDTH-1:0] rd_priority_3;
    wire [PRIORITY_WIDTH-1:0] rd_priority_4;

    wire [4:0] rd_valid;
    wire [4:0] full;
    wire [4:0] empty;

    integer errors;

    // =========================================================
    // DUT
    // =========================================================

    fifo_bank_5port #(
        .DATA_WIDTH(DATA_WIDTH),
        .PACKET_WIDTH(DATA_WIDTH),
        .PRIORITY_WIDTH(PRIORITY_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),

        .wr_en(wr_en),

        .wr_data_0(wr_data_0),
        .wr_data_1(wr_data_1),
        .wr_data_2(wr_data_2),
        .wr_data_3(wr_data_3),
        .wr_data_4(wr_data_4),

        .wr_priority_0(wr_priority_0),
        .wr_priority_1(wr_priority_1),
        .wr_priority_2(wr_priority_2),
        .wr_priority_3(wr_priority_3),
        .wr_priority_4(wr_priority_4),

        .rd_en(rd_en),

        .rd_data_0(rd_data_0),
        .rd_data_1(rd_data_1),
        .rd_data_2(rd_data_2),
        .rd_data_3(rd_data_3),
        .rd_data_4(rd_data_4),

        .rd_priority_0(rd_priority_0),
        .rd_priority_1(rd_priority_1),
        .rd_priority_2(rd_priority_2),
        .rd_priority_3(rd_priority_3),
        .rd_priority_4(rd_priority_4),

        .rd_valid(rd_valid),

        .full(full),
        .empty(empty)
    );

    // =========================================================
    // CLOCK
    // =========================================================

    always #5 clk = ~clk;

    // =========================================================
    // TEST
    // =========================================================

    initial begin

        clk = 1'b0;
        rst_n = 1'b0;

        wr_en = 5'b00000;
        rd_en = 5'b00000;

        wr_data_0 = 32'd0;
        wr_data_1 = 32'd0;
        wr_data_2 = 32'd0;
        wr_data_3 = 32'd0;
        wr_data_4 = 32'd0;

        wr_priority_0 = 2'd0;
        wr_priority_1 = 2'd0;
        wr_priority_2 = 2'd0;
        wr_priority_3 = 2'd0;
        wr_priority_4 = 2'd0;

        errors = 0;

        $display("");
        $display("======================================");
        $display(" 5-PORT FIFO BANK TEST");
        $display("======================================");

        // =====================================================
        // RESET
        // =====================================================

        #20;

        rst_n = 1'b1;

        #5;

        if (empty == 5'b11111)
            $display("RESET PASS");
        else begin
            $display("RESET FAIL");
            errors = errors + 1;
        end

        // =====================================================
        // TEST 1
        // =====================================================

        @(negedge clk);

        wr_en = 5'b11111;

        wr_data_0 = 32'hAAAA0000;
        wr_data_1 = 32'hBBBB0001;
        wr_data_2 = 32'hCCCC0002;
        wr_data_3 = 32'hDDDD0003;
        wr_data_4 = 32'hEEEE0004;

        wr_priority_0 = 2'd0;
        wr_priority_1 = 2'd1;
        wr_priority_2 = 2'd2;
        wr_priority_3 = 2'd3;
        wr_priority_4 = 2'd1;

        @(negedge clk);

        wr_en = 5'b00000;

        #1;

        if (rd_valid == 5'b11111)
            $display("ALL 5 FIFOS WRITE PASS");
        else begin
            $display("ALL 5 FIFOS WRITE FAIL");
            errors = errors + 1;
        end

        // =====================================================
        // TEST 2
        // =====================================================

        if (rd_data_0 == 32'hAAAA0000 &&
            rd_data_1 == 32'hBBBB0001 &&
            rd_data_2 == 32'hCCCC0002 &&
            rd_data_3 == 32'hDDDD0003 &&
            rd_data_4 == 32'hEEEE0004) begin

            $display("DATA ISOLATION PASS");

        end
        else begin

            $display("DATA ISOLATION FAIL");

            errors = errors + 1;

        end

        // =====================================================
        // TEST 3
        // =====================================================

        if (rd_priority_0 == 2'd0 &&
            rd_priority_1 == 2'd1 &&
            rd_priority_2 == 2'd2 &&
            rd_priority_3 == 2'd3 &&
            rd_priority_4 == 2'd1) begin

            $display("PRIORITY STORAGE PASS");

        end
        else begin

            $display("PRIORITY STORAGE FAIL");

            errors = errors + 1;

        end

        // =====================================================
        // TEST 4
        // =====================================================

        @(negedge clk);

        rd_en = 5'b11111;

        @(negedge clk);

        rd_en = 5'b00000;

        #1;

        if (empty == 5'b11111)
            $display("ALL 5 FIFOS READ PASS");
        else begin
            $display("ALL 5 FIFOS READ FAIL");
            errors = errors + 1;
        end

        // =====================================================
        // TEST 5
        // =====================================================

        @(negedge clk);

        wr_en = 5'b00100;

        wr_data_2 = 32'h12345678;
        wr_priority_2 = 2'd3;

        @(negedge clk);

        wr_en = 5'b00000;

        #1;

        if (rd_data_2 == 32'h12345678 &&
            rd_priority_2 == 2'd3 &&
            rd_valid[2]) begin

            $display("INDEPENDENT FIFO PASS");

        end
        else begin

            $display("INDEPENDENT FIFO FAIL");

            errors = errors + 1;

        end

        // =====================================================
        // FINAL
        // =====================================================

        $display("");
        $display("======================================");

        if (errors == 0)
            $display("5-PORT FIFO BANK TEST PASS");
        else
            $display(
                "5-PORT FIFO BANK TEST FAIL: %0d errors",
                errors
            );

        $display("======================================");

        $finish;

    end

endmodule
