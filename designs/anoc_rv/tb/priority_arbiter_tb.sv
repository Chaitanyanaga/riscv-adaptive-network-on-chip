`timescale 1ns/1ps

module priority_arbiter_tb;

    localparam NUM_INPUTS = 5;
    localparam PRIORITY_WIDTH = 2;

    logic [NUM_INPUTS-1:0] req;

    logic [NUM_INPUTS*PRIORITY_WIDTH-1:0] pkt_priority;

    logic [NUM_INPUTS-1:0] grant;

    logic grant_valid;

    logic [$clog2(NUM_INPUTS)-1:0] grant_index;

    integer errors;

    priority_arbiter #(
        .NUM_INPUTS(NUM_INPUTS),
        .PRIORITY_WIDTH(PRIORITY_WIDTH)
    ) dut (
        .req(req),
        .pkt_priority(pkt_priority),
        .grant(grant),
        .grant_valid(grant_valid),
        .grant_index(grant_index)
    );


    task clear_inputs;

        begin
            req = 5'b00000;
            pkt_priority = 10'b0;
        end

    endtask


    task set_priority;

        input integer index;
        input [PRIORITY_WIDTH-1:0] value;

        begin

            pkt_priority[
                index*PRIORITY_WIDTH +: PRIORITY_WIDTH
            ] = value;

        end

    endtask


    task check_grant;

        input [NUM_INPUTS-1:0] expected_grant;
        input expected_valid;
        input integer expected_index;

        begin

            #1;

            if (
                (grant == expected_grant) &&
                (grant_valid == expected_valid) &&
                (
                    !expected_valid ||
                    (grant_index == expected_index)
                )
            ) begin

                $display(
                    "PASS: REQ=%b GRANT=%b INDEX=%0d",
                    req,
                    grant,
                    grant_index
                );

            end
            else begin

                $display(
                    "FAIL: REQ=%b GRANT=%b INDEX=%0d",
                    req,
                    grant,
                    grant_index
                );

                errors = errors + 1;

            end

        end

    endtask


    initial begin

        errors = 0;

        $display("");
        $display("======================================");
        $display(" PRIORITY ARBITER TEST");
        $display("======================================");


        /*
         * TEST 1
         * No request.
         */

        clear_inputs;

        check_grant(
            5'b00000,
            1'b0,
            0
        );


        /*
         * TEST 2
         * Only input 0 requests.
         * Priority = 1.
         */

        clear_inputs;

        req[0] = 1'b1;

        set_priority(0, 2'd1);

        check_grant(
            5'b00001,
            1'b1,
            0
        );


        /*
         * TEST 3
         *
         * Input 3 has highest priority.
         */

        clear_inputs;

        req[0] = 1'b1;
        req[2] = 1'b1;
        req[3] = 1'b1;

        set_priority(0, 2'd1);
        set_priority(2, 2'd2);
        set_priority(3, 2'd3);

        check_grant(
            5'b01000,
            1'b1,
            3
        );


        /*
         * TEST 4
         *
         * Input 1 has highest priority.
         */

        clear_inputs;

        req[0] = 1'b1;
        req[1] = 1'b1;
        req[4] = 1'b1;

        set_priority(0, 2'd1);
        set_priority(1, 2'd3);
        set_priority(4, 2'd2);

        check_grant(
            5'b00010,
            1'b1,
            1
        );


        /*
         * TEST 5
         *
         * Equal priority.
         *
         * Input 1 and input 4 both have priority 2.
         *
         * Input 1 wins because it has lower index.
         */

        clear_inputs;

        req[1] = 1'b1;
        req[4] = 1'b1;

        set_priority(1, 2'd2);
        set_priority(4, 2'd2);

        check_grant(
            5'b00010,
            1'b1,
            1
        );


        /*
         * TEST 6
         *
         * All inputs request.
         *
         * Input 2 has priority 3.
         */

        clear_inputs;

        req = 5'b11111;

        set_priority(0, 2'd0);
        set_priority(1, 2'd1);
        set_priority(2, 2'd3);
        set_priority(3, 2'd2);
        set_priority(4, 2'd1);

        check_grant(
            5'b00100,
            1'b1,
            2
        );


        /*
         * TEST 7
         *
         * All inputs have equal priority.
         *
         * Input 0 wins.
         */

        clear_inputs;

        req = 5'b11111;

        set_priority(0, 2'd2);
        set_priority(1, 2'd2);
        set_priority(2, 2'd2);
        set_priority(3, 2'd2);
        set_priority(4, 2'd2);

        check_grant(
            5'b00001,
            1'b1,
            0
        );


        $display("");
        $display("======================================");

        if (errors == 0)
            $display("PRIORITY ARBITER TEST PASS");
        else
            $display(
                "PRIORITY ARBITER TEST FAIL: %0d errors",
                errors
            );

        $display("======================================");

        $finish;

    end

endmodule
