`timescale 1ns/1ps

module anoc_network_5x5 #(
    parameter DATA_WIDTH     = 32,
    parameter PRIORITY_WIDTH = 2,
    parameter FIFO_DEPTH     = 4
)(
    input wire clk,
    input wire rst_n,

    // =========================================================
    // LOCAL PACKET INJECTION
    // =========================================================

    input wire        inject_valid,
    input wire [2:0]  inject_x,
    input wire [2:0]  inject_y,

    input wire [31:0] inject_data,
    input wire [1:0]  inject_priority,

    input wire [2:0] inject_dst_x,
    input wire [2:0] inject_dst_y,

    // =========================================================
    // NETWORK LOCAL DELIVERY
    // =========================================================

    output wire        local_valid,
    output wire [37:0] local_packet
);

    // =========================================================
    // 5x5 ANOC-RV MESH
    //
    //                 X
    //          0   1   2   3   4
    //
    // Y=4      N04 N14 N24 N34 N44
    // Y=3      N03 N13 N23 N33 N43
    // Y=2      N02 N12 N22 N32 N42
    // Y=1      N01 N11 N21 N31 N41
    // Y=0      N00 N10 N20 N30 N40
    //
    // =========================================================

    // =========================================================
    // PACKET FORMAT
    //
    // 37:35 = destination X
    // 34:32 = destination Y
    // 31:30 = priority
    // 29:0  = payload
    //
    // TOTAL = 38 BITS
    // =========================================================

    localparam PACKET_WIDTH = 38;

    // =========================================================
    // NODE OUTPUT PACKETS
    // =========================================================

    wire [PACKET_WIDTH-1:0] north_packet [0:4][0:4];
    wire [PACKET_WIDTH-1:0] south_packet [0:4][0:4];
    wire [PACKET_WIDTH-1:0] east_packet  [0:4][0:4];
    wire [PACKET_WIDTH-1:0] west_packet  [0:4][0:4];

    // =========================================================
    // NODE OUTPUT VALID
    // =========================================================

    wire north_valid [0:4][0:4];
    wire south_valid [0:4][0:4];
    wire east_valid  [0:4][0:4];
    wire west_valid  [0:4][0:4];

    // =========================================================
    // LOCAL OUTPUT
    // =========================================================

    wire [PACKET_WIDTH-1:0] local_packet_node [0:4][0:4];
    wire                    local_valid_node  [0:4][0:4];

    // =========================================================
    // FIFO STATUS
    // =========================================================


    // =========================================================
    // UNUSED NODE STATUS OUTPUTS
    // =========================================================

    wire [4:0] full_node  [0:4][0:4];
    wire [4:0] empty_node [0:4][0:4];

    // Consume node FIFO status outputs.
    wire fifo_status_unused;
    assign fifo_status_unused =
        |full_node[0][0]  |
        |full_node[0][1]  |
        |full_node[0][2]  |
        |full_node[0][3]  |
        |full_node[0][4]  |
        |full_node[1][0]  |
        |full_node[1][1]  |
        |full_node[1][2]  |
        |full_node[1][3]  |
        |full_node[1][4]  |
        |full_node[2][0]  |
        |full_node[2][1]  |
        |full_node[2][2]  |
        |full_node[2][3]  |
        |full_node[2][4]  |
        |full_node[3][0]  |
        |full_node[3][1]  |
        |full_node[3][2]  |
        |full_node[3][3]  |
        |full_node[3][4]  |
        |full_node[4][0]  |
        |full_node[4][1]  |
        |full_node[4][2]  |
        |full_node[4][3]  |
        |full_node[4][4]  |
        |empty_node[0][0] |
        |empty_node[0][1] |
        |empty_node[0][2] |
        |empty_node[0][3] |
        |empty_node[0][4] |
        |empty_node[1][0] |
        |empty_node[1][1] |
        |empty_node[1][2] |
        |empty_node[1][3] |
        |empty_node[1][4] |
        |empty_node[2][0] |
        |empty_node[2][1] |
        |empty_node[2][2] |
        |empty_node[2][3] |
        |empty_node[2][4] |
        |empty_node[3][0] |
        |empty_node[3][1] |
        |empty_node[3][2] |
        |empty_node[3][3] |
        |empty_node[3][4] |
        |empty_node[4][0] |
        |empty_node[4][1] |
        |empty_node[4][2] |
        |empty_node[4][3] |
        |empty_node[4][4];

    // =========================================================
    // NODE WRITE ENABLES
    //
    // 0 = NORTH
    // 1 = SOUTH
    // 2 = EAST
    // 3 = WEST
    // 4 = LOCAL
    // =========================================================

    wire [4:0] wr_en_node [0:4][0:4];

    // =========================================================
    // NODE WRITE DATA
    // =========================================================

    wire [31:0] wr_data_0 [0:4][0:4];
    wire [31:0] wr_data_1 [0:4][0:4];
    wire [31:0] wr_data_2 [0:4][0:4];
    wire [31:0] wr_data_3 [0:4][0:4];
    wire [31:0] wr_data_4 [0:4][0:4];

    // =========================================================
    // NODE WRITE PRIORITY
    // =========================================================

    wire [1:0] wr_priority_0 [0:4][0:4];
    wire [1:0] wr_priority_1 [0:4][0:4];
    wire [1:0] wr_priority_2 [0:4][0:4];
    wire [1:0] wr_priority_3 [0:4][0:4];
    wire [1:0] wr_priority_4 [0:4][0:4];

    // =========================================================
    // DESTINATION X
    // =========================================================

    wire [2:0] dst_x_0 [0:4][0:4];
    wire [2:0] dst_x_1 [0:4][0:4];
    wire [2:0] dst_x_2 [0:4][0:4];
    wire [2:0] dst_x_3 [0:4][0:4];
    wire [2:0] dst_x_4 [0:4][0:4];

    // =========================================================
    // DESTINATION Y
    // =========================================================

    wire [2:0] dst_y_0 [0:4][0:4];
    wire [2:0] dst_y_1 [0:4][0:4];
    wire [2:0] dst_y_2 [0:4][0:4];
    wire [2:0] dst_y_3 [0:4][0:4];
    wire [2:0] dst_y_4 [0:4][0:4];

    // =========================================================
    // GENERATE VARIABLES
    // =========================================================

    genvar gx;
    genvar gy;

    // =========================================================
    // INPUT CONNECTIONS
    // =========================================================

    generate

        for (gx = 0; gx < 5; gx = gx + 1) begin : INPUT_X

            for (gy = 0; gy < 5; gy = gy + 1) begin : INPUT_Y

                // =================================================
                // NORTH INPUT
                // =================================================

                if (gy > 0) begin : NORTH_LINK

                    assign wr_en_node[gx][gy][0] =
                        north_valid[gx][gy-1];

                    // 30-bit payload -> 32-bit node data
                    assign wr_data_0[gx][gy] =
                        {2'b00, north_packet[gx][gy-1][29:0]};

                    assign wr_priority_0[gx][gy] =
                        north_packet[gx][gy-1][31:30];

                    assign dst_x_0[gx][gy] =
                        north_packet[gx][gy-1][37:35];

                    assign dst_y_0[gx][gy] =
                        north_packet[gx][gy-1][34:32];

                end
                else begin : NORTH_BOUNDARY

                    assign wr_en_node[gx][gy][0] = 1'b0;

                    assign wr_data_0[gx][gy] = 32'd0;

                    assign wr_priority_0[gx][gy] = 2'd0;

                    assign dst_x_0[gx][gy] = 3'd0;

                    assign dst_y_0[gx][gy] = 3'd0;

                end

                // =================================================
                // SOUTH INPUT
                // =================================================

                if (gy < 4) begin : SOUTH_LINK

                    assign wr_en_node[gx][gy][1] =
                        south_valid[gx][gy+1];

                    // 30-bit payload -> 32-bit node data
                    assign wr_data_1[gx][gy] =
                        {2'b00, south_packet[gx][gy+1][29:0]};

                    assign wr_priority_1[gx][gy] =
                        south_packet[gx][gy+1][31:30];

                    assign dst_x_1[gx][gy] =
                        south_packet[gx][gy+1][37:35];

                    assign dst_y_1[gx][gy] =
                        south_packet[gx][gy+1][34:32];

                end
                else begin : SOUTH_BOUNDARY

                    assign wr_en_node[gx][gy][1] = 1'b0;

                    assign wr_data_1[gx][gy] = 32'd0;

                    assign wr_priority_1[gx][gy] = 2'd0;

                    assign dst_x_1[gx][gy] = 3'd0;

                    assign dst_y_1[gx][gy] = 3'd0;

                end

                // =================================================
                // EAST INPUT
                // =================================================

                if (gx > 0) begin : EAST_LINK

                    assign wr_en_node[gx][gy][3] =
                        east_valid[gx-1][gy];

                    // 30-bit payload -> 32-bit node data
                    assign wr_data_3[gx][gy] =
                        {2'b00, east_packet[gx-1][gy][29:0]};

                    assign wr_priority_3[gx][gy] =
                        east_packet[gx-1][gy][31:30];

                    assign dst_x_3[gx][gy] =
                        east_packet[gx-1][gy][37:35];

                    assign dst_y_3[gx][gy] =
                        east_packet[gx-1][gy][34:32];

                end
                else begin : EAST_BOUNDARY

                    assign wr_en_node[gx][gy][3] = 1'b0;

                    assign wr_data_3[gx][gy] = 32'd0;

                    assign wr_priority_3[gx][gy] = 2'd0;

                    assign dst_x_3[gx][gy] = 3'd0;

                    assign dst_y_3[gx][gy] = 3'd0;

                end

                // =================================================
                // WEST INPUT
                // =================================================

                if (gx < 4) begin : WEST_LINK

                    assign wr_en_node[gx][gy][2] =
                        west_valid[gx+1][gy];

                    // 30-bit payload -> 32-bit node data
                    assign wr_data_2[gx][gy] =
                        {2'b00, west_packet[gx+1][gy][29:0]};

                    assign wr_priority_2[gx][gy] =
                        west_packet[gx+1][gy][31:30];

                    assign dst_x_2[gx][gy] =
                        west_packet[gx+1][gy][37:35];

                    assign dst_y_2[gx][gy] =
                        west_packet[gx+1][gy][34:32];

                end
                else begin : WEST_BOUNDARY

                    assign wr_en_node[gx][gy][2] = 1'b0;

                    assign wr_data_2[gx][gy] = 32'd0;

                    assign wr_priority_2[gx][gy] = 2'd0;

                    assign dst_x_2[gx][gy] = 3'd0;

                    assign dst_y_2[gx][gy] = 3'd0;

                end

                // =================================================
                // LOCAL INPUT
                // =================================================

                assign wr_en_node[gx][gy][4] =
                    inject_valid &&
                    (inject_x == gx) &&
                    (inject_y == gy);

                assign wr_data_4[gx][gy] =
                    (inject_valid &&
                     (inject_x == gx) &&
                     (inject_y == gy))
                    ? inject_data
                    : 32'd0;

                assign wr_priority_4[gx][gy] =
                    (inject_valid &&
                     (inject_x == gx) &&
                     (inject_y == gy))
                    ? inject_priority
                    : 2'd0;

                assign dst_x_4[gx][gy] =
                    (inject_valid &&
                     (inject_x == gx) &&
                     (inject_y == gy))
                    ? inject_dst_x
                    : 3'd0;

                assign dst_y_4[gx][gy] =
                    (inject_valid &&
                     (inject_x == gx) &&
                     (inject_y == gy))
                    ? inject_dst_y
                    : 3'd0;

            end

        end

    endgenerate

    // =========================================================
    // 25 ANOC NODES
    // =========================================================

    generate

        for (gx = 0; gx < 5; gx = gx + 1) begin : NODE_X

            for (gy = 0; gy < 5; gy = gy + 1) begin : NODE_Y

                localparam [2:0] NODE_X_COORD = gx;
                localparam [2:0] NODE_Y_COORD = gy;

                anoc_node #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .PRIORITY_WIDTH(PRIORITY_WIDTH),
                    .FIFO_DEPTH(FIFO_DEPTH)
                ) node_inst (

                    .clk(clk),
                    .rst_n(rst_n),

                    .current_x(NODE_X_COORD),
                    .current_y(NODE_Y_COORD),

                    .wr_en(wr_en_node[gx][gy]),

                    .wr_data_0(wr_data_0[gx][gy]),
                    .wr_data_1(wr_data_1[gx][gy]),
                    .wr_data_2(wr_data_2[gx][gy]),
                    .wr_data_3(wr_data_3[gx][gy]),
                    .wr_data_4(wr_data_4[gx][gy]),

                    .wr_priority_0(wr_priority_0[gx][gy]),
                    .wr_priority_1(wr_priority_1[gx][gy]),
                    .wr_priority_2(wr_priority_2[gx][gy]),
                    .wr_priority_3(wr_priority_3[gx][gy]),
                    .wr_priority_4(wr_priority_4[gx][gy]),

                    .dst_x_0(dst_x_0[gx][gy]),
                    .dst_x_1(dst_x_1[gx][gy]),
                    .dst_x_2(dst_x_2[gx][gy]),
                    .dst_x_3(dst_x_3[gx][gy]),
                    .dst_x_4(dst_x_4[gx][gy]),

                    .dst_y_0(dst_y_0[gx][gy]),
                    .dst_y_1(dst_y_1[gx][gy]),
                    .dst_y_2(dst_y_2[gx][gy]),
                    .dst_y_3(dst_y_3[gx][gy]),
                    .dst_y_4(dst_y_4[gx][gy]),

                    .north_packet(north_packet[gx][gy]),
                    .south_packet(south_packet[gx][gy]),
                    .east_packet(east_packet[gx][gy]),
                    .west_packet(west_packet[gx][gy]),
                    .local_packet(local_packet_node[gx][gy]),

                    .north_valid(north_valid[gx][gy]),
                    .south_valid(south_valid[gx][gy]),
                    .east_valid(east_valid[gx][gy]),
                    .west_valid(west_valid[gx][gy]),
                    .local_valid(local_valid_node[gx][gy]),

                    .full(full_node[gx][gy]),
                    .empty(empty_node[gx][gy])

                );

            end

        end

    endgenerate

    // =========================================================
    // LOCAL VALID
    // =========================================================

    assign local_valid =
        local_valid_node[0][0] |
        local_valid_node[0][1] |
        local_valid_node[0][2] |
        local_valid_node[0][3] |
        local_valid_node[0][4] |

        local_valid_node[1][0] |
        local_valid_node[1][1] |
        local_valid_node[1][2] |
        local_valid_node[1][3] |
        local_valid_node[1][4] |

        local_valid_node[2][0] |
        local_valid_node[2][1] |
        local_valid_node[2][2] |
        local_valid_node[2][3] |
        local_valid_node[2][4] |

        local_valid_node[3][0] |
        local_valid_node[3][1] |
        local_valid_node[3][2] |
        local_valid_node[3][3] |
        local_valid_node[3][4] |

        local_valid_node[4][0] |
        local_valid_node[4][1] |
        local_valid_node[4][2] |
        local_valid_node[4][3] |
        local_valid_node[4][4];

    // =========================================================
    // LOCAL PACKET
    // =========================================================

    assign local_packet =
        local_packet_node[0][0] |
        local_packet_node[0][1] |
        local_packet_node[0][2] |
        local_packet_node[0][3] |
        local_packet_node[0][4] |

        local_packet_node[1][0] |
        local_packet_node[1][1] |
        local_packet_node[1][2] |
        local_packet_node[1][3] |
        local_packet_node[1][4] |

        local_packet_node[2][0] |
        local_packet_node[2][1] |
        local_packet_node[2][2] |
        local_packet_node[2][3] |
        local_packet_node[2][4] |

        local_packet_node[3][0] |
        local_packet_node[3][1] |
        local_packet_node[3][2] |
        local_packet_node[3][3] |
        local_packet_node[3][4] |

        local_packet_node[4][0] |
        local_packet_node[4][1] |
        local_packet_node[4][2] |
        local_packet_node[4][3] |
        local_packet_node[4][4];

endmodule
