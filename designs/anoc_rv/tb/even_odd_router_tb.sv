`timescale 1ns/1ps

module even_odd_router_tb;

    localparam COORD_WIDTH = 2;

    logic [COORD_WIDTH-1:0] src_x;
    logic [COORD_WIDTH-1:0] src_y;

    logic [COORD_WIDTH-1:0] dst_x;
    logic [COORD_WIDTH-1:0] dst_y;

    logic route_north;
    logic route_south;
    logic route_east;
    logic route_west;
    logic route_local;

    integer errors;

    even_odd_router #(
        .COORD_WIDTH(COORD_WIDTH)
    ) dut (
        .src_x(src_x),
        .src_y(src_y),
        .dst_x(dst_x),
        .dst_y(dst_y),

        .route_north(route_north),
        .route_south(route_south),
        .route_east(route_east),
        .route_west(route_west),
        .route_local(route_local)
    );

    task check_route;
        input [COORD_WIDTH-1:0] tx;
        input [COORD_WIDTH-1:0] ty;
        input [COORD_WIDTH-1:0] dx;
        input [COORD_WIDTH-1:0] dy;

        input expected_north;
        input expected_south;
        input expected_east;
        input expected_west;
        input expected_local;

        begin
            src_x = tx;
            src_y = ty;
            dst_x = dx;
            dst_y = dy;

            #1;

            if ((route_north == expected_north) &&
                (route_south == expected_south) &&
                (route_east  == expected_east)  &&
                (route_west  == expected_west)  &&
                (route_local == expected_local)) begin

                $display(
                    "PASS: SRC=(%0d,%0d) DST=(%0d,%0d)",
                    tx, ty, dx, dy
                );

            end
            else begin

                $display(
                    "FAIL: SRC=(%0d,%0d) DST=(%0d,%0d)",
                    tx, ty, dx, dy
                );

                $display(
                    "      N=%b S=%b E=%b W=%b L=%b",
                    route_north,
                    route_south,
                    route_east,
                    route_west,
                    route_local
                );

                errors = errors + 1;

            end
        end
    endtask


    initial begin

        errors = 0;

        $display("");
        $display("======================================");
        $display(" EVEN-ODD ROUTER TEST");
        $display("======================================");

        /*
         * Test 1
         * Same location -> LOCAL
         */
        check_route(
            2'd1, 2'd1,
            2'd1, 2'd1,
            0, 0, 0, 0, 1
        );

        /*
         * Test 2
         * Destination to EAST
         */
        check_route(
            2'd1, 2'd1,
            2'd3, 2'd1,
            0, 0, 1, 0, 0
        );

        /*
         * Test 3
         * Destination to WEST
         */
        check_route(
            2'd3, 2'd1,
            2'd1, 2'd1,
            0, 0, 0, 1, 0
        );

        /*
         * Test 4
         * Destination to NORTH
         */
        check_route(
            2'd1, 2'd1,
            2'd1, 2'd3,
            1, 0, 0, 0, 0
        );

        /*
         * Test 5
         * Destination to SOUTH
         */
        check_route(
            2'd1, 2'd3,
            2'd1, 2'd0,
            0, 1, 0, 0, 0
        );

        /*
         * Test 6
         * X movement has priority before Y.
         */
        check_route(
            2'd0, 2'd0,
            2'd3, 2'd3,
            0, 0, 1, 0, 0
        );

        /*
         * Test 7
         * Negative X movement.
         */
        check_route(
            2'd3, 2'd3,
            2'd0, 2'd0,
            0, 0, 0, 1, 0
        );

        $display("");
        $display("======================================");

        if (errors == 0)
            $display("EVEN-ODD ROUTER TEST PASS");
        else
            $display("EVEN-ODD ROUTER TEST FAIL: %0d errors", errors);

        $display("======================================");

        $finish;

    end

endmodule
