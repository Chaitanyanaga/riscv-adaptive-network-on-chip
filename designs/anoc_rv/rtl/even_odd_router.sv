`timescale 1ns/1ps

module even_odd_router #(
    parameter COORD_WIDTH = 3
)(
    input logic [COORD_WIDTH-1:0] src_x,
    input logic [COORD_WIDTH-1:0] src_y,

    input logic [COORD_WIDTH-1:0] dst_x,
    input logic [COORD_WIDTH-1:0] dst_y,

    output logic route_north,
    output logic route_south,
    output logic route_east,
    output logic route_west,
    output logic route_local
);

    always_comb begin

        route_north = 1'b0;
        route_south = 1'b0;
        route_east  = 1'b0;
        route_west  = 1'b0;
        route_local = 1'b0;

        if ((src_x == dst_x) &&
            (src_y == dst_y)) begin

            route_local = 1'b1;

        end

        else if (src_x != dst_x) begin

            if (dst_x > src_x)
                route_east = 1'b1;
            else
                route_west = 1'b1;

        end

        else begin

            if (dst_y > src_y)
                route_north = 1'b1;
            else
                route_south = 1'b1;

        end

    end

endmodule
