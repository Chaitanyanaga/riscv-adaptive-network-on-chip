`timescale 1ns/1ps

module anoc_packet #(
    parameter DATA_WIDTH     = 30,
    parameter PRIORITY_WIDTH = 2,
    parameter COORD_WIDTH    = 3
)(
    input wire [COORD_WIDTH-1:0]        dst_x,
    input wire [COORD_WIDTH-1:0]        dst_y,
    input wire [PRIORITY_WIDTH-1:0]     pkt_priority,
    input wire [DATA_WIDTH-1:0]         payload,

    output wire [37:0] packet
);

    assign packet = {
        dst_x,
        dst_y,
        pkt_priority,
        payload
    };

endmodule
