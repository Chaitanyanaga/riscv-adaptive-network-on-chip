`timescale 1ns/1ps

module anoc_node_tb;

    localparam DATA_WIDTH     = 32;
    localparam PRIORITY_WIDTH = 2;
    localparam FIFO_DEPTH     = 4;

    reg clk;
    reg rst_n;

    reg [2:0] current_x;
    reg [2:0] current_y;

    reg [4:0] wr_en;

    reg [31:0] wr_data_0;
    reg [31:0] wr_data_1;
    reg [31:0] wr_data_2;
    reg [31:0] wr_data_3;
    reg [31:0] wr_data_4;

    reg [1:0] wr_priority_0;
    reg [1:0] wr_priority_1;
    reg [1:0] wr_priority_2;
    reg [1:0] wr_priority_3;
    reg [1:0] wr_priority_4;

    reg [2:0] dst_x_0;
    reg [2:0] dst_x_1;
    reg [2:0] dst_x_2;
    reg [2:0] dst_x_3;
    reg [2:0] dst_x_4;

    reg [2:0] dst_y_0;
    reg [2:0] dst_y_1;
    reg [2:0] dst_y_2;
    reg [2:0] dst_y_3;
    reg [2:0] dst_y_4;

    // =========================================================
    // 38-BIT NODE OUTPUTS
    // =========================================================

    wire [37:0] north_packet;
    wire [37:0] south_packet;
    wire [37:0] east_packet;
    wire [37:0] west_packet;
    wire [37:0] local_packet;

    wire north_valid;
    wire south_valid;
    wire east_valid;
    wire west_valid;
    wire local_valid;

    wire [4:0] full;
    wire [4:0] empty;

    integer errors;

    // =========================================================
    // DUT
    // =========================================================

    anoc_node #(
        .DATA_WIDTH(DATA_WIDTH),
        .PRIORITY_WIDTH(PRIORITY_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),

        .current_x(current_x),
        .current_y(current_y),

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

        .dst_x_0(dst_x_0),
        .dst_x_1(dst_x_1),
        .dst_x_2(dst_x_2),
        .dst_x_3(dst_x_3),
        .dst_x_4(dst_x_4),

        .dst_y_0(dst_y_0),
        .dst_y_1(dst_y_1),
        .dst_y_2(dst_y_2),
        .dst_y_3(dst_y_3),
        .dst_y_4(dst_y_4),

        .north_packet(north_packet),
        .south_packet(south_packet),
        .east_packet(east_packet),
        .west_packet(west_packet),
        .local_packet(local_packet),

        .north_valid(north_valid),
        .south_valid(south_valid),
        .east_valid(east_valid),
        .west_valid(west_valid),
        .local_valid(local_valid),

        .full(full),
        .empty(empty)
    );

    // =========================================================
    // CLOCK
    // =========================================================

    always #5 clk = ~clk;

    // =========================================================
    // RESET INPUTS
    // =========================================================

    task reset_inputs;

        begin

            wr_en = 5'b00000;

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

            dst_x_0 = 3'd0;
            dst_x_1 = 3'd0;
            dst_x_2 = 3'd0;
            dst_x_3 = 3'd0;
            dst_x_4 = 3'd0;

            dst_y_0 = 3'd0;
            dst_y_1 = 3'd0;
            dst_y_2 = 3'd0;
            dst_y_3 = 3'd0;
            dst_y_4 = 3'd0;

        end

    endtask

    task clear_packet;

        begin

            @(negedge clk);

            wr_en = 5'b00000;

            #2;

        end

    endtask

    // =========================================================
    // TESTS
    // =========================================================

    initial begin

        clk = 1'b0;
        rst_n = 1'b0;

        current_x = 3'd1;
        current_y = 3'd1;

        errors = 0;

        reset_inputs();

        $display("");
        $display("======================================");
        $display(" ANOC NODE TEST");
        $display("======================================");

        // =====================================================
        // RESET
        // =====================================================

        #20;

        rst_n = 1'b1;

        #10;

        if (!local_valid &&
            !north_valid &&
            !south_valid &&
            !east_valid &&
            !west_valid) begin

            $display("PASS: RESET");

        end
        else begin

            $display("FAIL: RESET");

            errors = errors + 1;

        end

        // =====================================================
        // LOCAL
        // =====================================================

        $display("");
        $display("TEST 1: LOCAL ROUTING");

        @(negedge clk);

        wr_en[0] = 1'b1;

        wr_data_0 = 32'hAAAA0001;
        wr_priority_0 = 2'd1;

        dst_x_0 = 3'd1;
        dst_y_0 = 3'd1;

        @(negedge clk);

        wr_en[0] = 1'b0;

        #2;

        if (local_valid) begin

            $display("PASS: LOCAL");

        end
        else begin

            $display("FAIL: LOCAL");

            errors = errors + 1;

        end

        clear_packet();

        // =====================================================
        // EAST
        // =====================================================

        $display("");
        $display("TEST 2: EAST ROUTING");

        @(negedge clk);

        wr_en[0] = 1'b1;

        wr_data_0 = 32'hBBBB0002;
        wr_priority_0 = 2'd2;

        dst_x_0 = 3'd3;
        dst_y_0 = 3'd1;

        @(negedge clk);

        wr_en[0] = 1'b0;

        #2;

        if (east_valid) begin

            $display("PASS: EAST");

        end
        else begin

            $display("FAIL: EAST");

            errors = errors + 1;

        end

        clear_packet();

        // =====================================================
        // WEST
        // =====================================================

        $display("");
        $display("TEST 3: WEST ROUTING");

        @(negedge clk);

        wr_en[0] = 1'b1;

        wr_data_0 = 32'hCCCC0003;
        wr_priority_0 = 2'd0;

        dst_x_0 = 3'd0;
        dst_y_0 = 3'd1;

        @(negedge clk);

        wr_en[0] = 1'b0;

        #2;

        if (west_valid) begin

            $display("PASS: WEST");

        end
        else begin

            $display("FAIL: WEST");

            errors = errors + 1;

        end

        clear_packet();

        // =====================================================
        // NORTH
        // =====================================================

        $display("");
        $display("TEST 4: NORTH ROUTING");

        @(negedge clk);

        wr_en[0] = 1'b1;

        wr_data_0 = 32'hDDDD0004;
        wr_priority_0 = 2'd3;

        dst_x_0 = 3'd1;
        dst_y_0 = 3'd3;

        @(negedge clk);

        wr_en[0] = 1'b0;

        #2;

        if (north_valid) begin

            $display("PASS: NORTH");

        end
        else begin

            $display("FAIL: NORTH");

            errors = errors + 1;

        end

        clear_packet();

        // =====================================================
        // SOUTH
        // =====================================================

        $display("");
        $display("TEST 5: SOUTH ROUTING");

        @(negedge clk);

        wr_en[0] = 1'b1;

        wr_data_0 = 32'hEEEE0005;
        wr_priority_0 = 2'd2;

        dst_x_0 = 3'd1;
        dst_y_0 = 3'd0;

        @(negedge clk);

        wr_en[0] = 1'b0;

        #2;

        if (south_valid) begin

            $display("PASS: SOUTH");

        end
        else begin

            $display("FAIL: SOUTH");

            errors = errors + 1;

        end

        clear_packet();

        // =====================================================
        // PRIORITY
        // =====================================================

        $display("");
        $display("TEST 6: PRIORITY ARBITRATION");

        @(negedge clk);

        wr_en[0] = 1'b1;
        wr_en[1] = 1'b1;

        wr_data_0 = 32'h11110001;
        wr_data_1 = 32'h22220002;

        wr_priority_0 = 2'd1;
        wr_priority_1 = 2'd3;

        dst_x_0 = 3'd3;
        dst_y_0 = 3'd1;

        dst_x_1 = 3'd0;
        dst_y_1 = 3'd1;

        @(negedge clk);

        wr_en[0] = 1'b0;
        wr_en[1] = 1'b0;

        #2;

        if (west_valid) begin

            $display("PASS: PRIORITY");

        end
        else begin

            $display("FAIL: PRIORITY");

            errors = errors + 1;

        end

        // =====================================================
        // FINAL
        // =====================================================

        #10;

        $display("");
        $display("======================================");

        if (errors == 0) begin

            $display("ANOC NODE TEST PASS");

        end
        else begin

            $display(
                "ANOC NODE TEST FAIL: %0d errors",
                errors
            );

        end

        $display("======================================");

        $finish;

    end

endmodule
