`timescale 1ns/1ps

module anoc_router #(
    parameter X_WIDTH        = 3,
    parameter Y_WIDTH        = 3,
    parameter DATA_WIDTH     = 30,
    parameter PRIORITY_WIDTH = 2
)(
    input wire clk,
    input wire rst_n,

    input wire [37:0] packet_in,
    input wire packet_valid,

    input wire [X_WIDTH-1:0] current_x,
    input wire [Y_WIDTH-1:0] current_y,

    output reg [4:0] port_valid,

    output reg [37:0] north_packet,
    output reg [37:0] south_packet,
    output reg [37:0] east_packet,
    output reg [37:0] west_packet,
    output reg [37:0] local_packet
);

    wire [X_WIDTH-1:0] dst_x;
    wire [Y_WIDTH-1:0] dst_y;

    assign dst_x = packet_in[37:35];
    assign dst_y = packet_in[34:32];

    always @(*) begin

        port_valid = 5'b00000;

        north_packet = 38'd0;
        south_packet = 38'd0;
        east_packet  = 38'd0;
        west_packet  = 38'd0;
        local_packet = 38'd0;

        if (packet_valid) begin

            if ((dst_x == current_x) &&
                (dst_y == current_y)) begin

                port_valid[4] = 1'b1;
                local_packet = packet_in;

            end

            else if (dst_x > current_x) begin

                port_valid[2] = 1'b1;
                east_packet = packet_in;

            end

            else if (dst_x < current_x) begin

                port_valid[3] = 1'b1;
                west_packet = packet_in;

            end

            else if (dst_y > current_y) begin

                port_valid[0] = 1'b1;
                north_packet = packet_in;

            end

            else if (dst_y < current_y) begin

                port_valid[1] = 1'b1;
                south_packet = packet_in;

            end

        end

    end

endmodule
