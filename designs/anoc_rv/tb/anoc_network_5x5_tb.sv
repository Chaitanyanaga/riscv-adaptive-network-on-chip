`timescale 1ns/1ps

module anoc_network_5x5_tb;

    reg clk;
    reg rst_n;

    reg        inject_valid;
    reg [2:0]  inject_x;
    reg [2:0]  inject_y;

    reg [31:0] inject_data;
    reg [1:0]  inject_priority;

    reg [2:0] inject_dst_x;
    reg [2:0] inject_dst_y;

    wire        local_valid;
    wire [37:0] local_packet;

    integer errors;

    integer found_local_1;
    integer found_local_2;
    integer found_local_3;
    integer found_local_4;
    integer found_local_5;
    integer found_local_6;

    // =========================================================
    // DUT
    // =========================================================

    anoc_network_5x5 dut (
        .clk(clk),
        .rst_n(rst_n),

        .inject_valid(inject_valid),
        .inject_x(inject_x),
        .inject_y(inject_y),

        .inject_data(inject_data),
        .inject_priority(inject_priority),

        .inject_dst_x(inject_dst_x),
        .inject_dst_y(inject_dst_y),

        .local_valid(local_valid),
        .local_packet(local_packet)
    );

    // =========================================================
    // CLOCK
    // =========================================================

    always #5 clk = ~clk;

    // =========================================================
    // PACKET INJECTION
    // =========================================================

    task send_packet;

        input [2:0]  src_x;
        input [2:0]  src_y;
        input [31:0] data_in;
        input [1:0]  prio_in;
        input [2:0]  dst_x_in;
        input [2:0]  dst_y_in;

        begin

            @(negedge clk);

            inject_valid    = 1'b1;
            inject_x        = src_x;
            inject_y        = src_y;
            inject_data     = data_in;
            inject_priority = prio_in;
            inject_dst_x    = dst_x_in;
            inject_dst_y    = dst_y_in;

            @(posedge clk);

            #1;

            inject_valid = 1'b0;

        end

    endtask

    // =========================================================
    // WAIT FOR LOCAL DELIVERY
    // =========================================================

    task wait_for_local;

        output integer result;

        integer k;

        begin

            result = 0;

            #1;

            if (local_valid)
                result = 1;

            if (!result) begin

                for (k = 0; k < 100; k = k + 1) begin

                    #1;

                    if (local_valid) begin

                        result = 1;
                        k = 100;

                    end

                    #4;

                end

            end

        end

    endtask

    // =========================================================
    // PACKET CHECK
    // =========================================================

    task check_packet;

        input [2:0]  expected_x;
        input [2:0]  expected_y;
        input [1:0]  expected_priority;
        input [31:0] expected_data;

        begin

            if (local_packet[37:35] != expected_x) begin

                $display(
                    "ERROR: DEST X expected=%0d got=%0d",
                    expected_x,
                    local_packet[37:35]
                );

                errors = errors + 1;

            end

            if (local_packet[34:32] != expected_y) begin

                $display(
                    "ERROR: DEST Y expected=%0d got=%0d",
                    expected_y,
                    local_packet[34:32]
                );

                errors = errors + 1;

            end

            if (local_packet[31:30] != expected_priority) begin

                $display(
                    "ERROR: PRIORITY expected=%0d got=%0d",
                    expected_priority,
                    local_packet[31:30]
                );

                errors = errors + 1;

            end

            if (local_packet[29:0] != expected_data[29:0]) begin

                $display(
                    "ERROR: DATA expected=%h got=%h",
                    expected_data[29:0],
                    local_packet[29:0]
                );

                errors = errors + 1;

            end

        end

    endtask

    // =========================================================
    // TEST SEQUENCE
    // =========================================================

    initial begin

        // =====================================================
        // VCD WAVEFORM
        // =====================================================

        $dumpfile(
            "designs/anoc_rv/results/github_artifacts/06_waveforms/anoc_network_5x5.vcd"
        );

        $dumpvars(
            0,
            anoc_network_5x5_tb
        );

        // =====================================================
        // INITIAL VALUES
        // =====================================================

        clk = 1'b0;
        rst_n = 1'b0;

        inject_valid = 1'b0;

        inject_x = 3'd0;
        inject_y = 3'd0;

        inject_data = 32'd0;
        inject_priority = 2'd0;

        inject_dst_x = 3'd0;
        inject_dst_y = 3'd0;

        errors = 0;

        found_local_1 = 0;
        found_local_2 = 0;
        found_local_3 = 0;
        found_local_4 = 0;
        found_local_5 = 0;
        found_local_6 = 0;

        // =====================================================
        // HEADER
        // =====================================================

        $display("");
        $display("======================================");
        $display(" ANOC 5x5 NETWORK TEST");
        $display("======================================");

        // =====================================================
        // RESET
        // =====================================================

        #20;

        rst_n = 1'b1;

        #10;

        if (!local_valid) begin

            $display("PASS: RESET");

        end
        else begin

            $display("FAIL: RESET");
            errors = errors + 1;

        end

        // =====================================================
        // TEST 1: LOCAL
        // =====================================================

        $display("");
        $display("TEST 1: LOCAL ROUTING");

        send_packet(
            3'd0,
            3'd0,
            32'hAAAA0001,
            2'd1,
            3'd0,
            3'd0
        );

        if (local_valid) begin

            check_packet(
                3'd0,
                3'd0,
                2'd1,
                32'hAAAA0001
            );

            $display("PASS: LOCAL");

        end
        else begin

            wait_for_local(found_local_1);

            if (found_local_1) begin

                check_packet(
                    3'd0,
                    3'd0,
                    2'd1,
                    32'hAAAA0001
                );

                $display("PASS: LOCAL");

            end
            else begin

                $display("FAIL: LOCAL");
                errors = errors + 1;

            end

        end

        #10;

        // =====================================================
        // TEST 2: EAST
        // =====================================================

        $display("");
        $display("TEST 2: EAST ROUTING");

        send_packet(
            3'd0,
            3'd0,
            32'hBBBB0002,
            2'd2,
            3'd1,
            3'd0
        );

        wait_for_local(found_local_2);

        if (found_local_2) begin

            check_packet(
                3'd1,
                3'd0,
                2'd2,
                32'hBBBB0002
            );

            $display("PASS: EAST");

        end
        else begin

            $display("FAIL: EAST");
            errors = errors + 1;

        end

        #10;

        // =====================================================
        // TEST 3: WEST
        // =====================================================

        $display("");
        $display("TEST 3: WEST ROUTING");

        send_packet(
            3'd3,
            3'd0,
            32'hCCCC0003,
            2'd1,
            3'd2,
            3'd0
        );

        wait_for_local(found_local_3);

        if (found_local_3) begin

            check_packet(
                3'd2,
                3'd0,
                2'd1,
                32'hCCCC0003
            );

            $display("PASS: WEST");

        end
        else begin

            $display("FAIL: WEST");
            errors = errors + 1;

        end

        #10;

        // =====================================================
        // TEST 4: NORTH
        // =====================================================

        $display("");
        $display("TEST 4: NORTH ROUTING");

        send_packet(
            3'd0,
            3'd0,
            32'hDDDD0004,
            2'd3,
            3'd0,
            3'd1
        );

        wait_for_local(found_local_4);

        if (found_local_4) begin

            check_packet(
                3'd0,
                3'd1,
                2'd3,
                32'hDDDD0004
            );

            $display("PASS: NORTH");

        end
        else begin

            $display("FAIL: NORTH");
            errors = errors + 1;

        end

        #10;

        // =====================================================
        // TEST 5: SOUTH
        // =====================================================

        $display("");
        $display("TEST 5: SOUTH ROUTING");

        send_packet(
            3'd0,
            3'd3,
            32'hEEEE0005,
            2'd2,
            3'd0,
            3'd2
        );

        wait_for_local(found_local_5);

        if (found_local_5) begin

            check_packet(
                3'd0,
                3'd2,
                2'd2,
                32'hEEEE0005
            );

            $display("PASS: SOUTH");

        end
        else begin

            $display("FAIL: SOUTH");
            errors = errors + 1;

        end

        #10;

        // =====================================================
        // TEST 6: EVEN-ODD MULTI-HOP
        //
        // (0,0)
        //   EAST
        // (1,0)
        //   EAST
        // (2,0)
        //   EAST
        // (3,0)
        //   NORTH
        // (3,1)
        //   NORTH
        // (3,2)
        // =====================================================

        $display("");
        $display("TEST 6: EVEN-ODD MULTI-HOP ROUTING");

        send_packet(
            3'd0,
            3'd0,
            32'hF00D0006,
            2'd3,
            3'd3,
            3'd2
        );

        wait_for_local(found_local_6);

        if (found_local_6) begin

            check_packet(
                3'd3,
                3'd2,
                2'd3,
                32'hF00D0006
            );

            $display("PASS: EVEN-ODD MULTI-HOP");

        end
        else begin

            $display("FAIL: EVEN-ODD MULTI-HOP");
            errors = errors + 1;

        end

        #10;

        // =====================================================
        // FINAL RESULT
        // =====================================================

        $display("");
        $display("======================================");

        if (errors == 0) begin

            $display("ANOC 5x5 NETWORK TEST PASS");

        end
        else begin

            $display(
                "ANOC 5x5 NETWORK TEST FAIL: %0d errors",
                errors
            );

        end

        $display("======================================");

        $finish;

    end

endmodule
