`timescale 1ns/1ps

module anoc_node #(
    parameter DATA_WIDTH     = 32,
    parameter PRIORITY_WIDTH = 2,
    parameter FIFO_DEPTH     = 4
)(
    input  wire clk,
    input  wire rst_n,

    input  wire [2:0] current_x,
    input  wire [2:0] current_y,

    input  wire [4:0] wr_en,

    input  wire [DATA_WIDTH-1:0] wr_data_0,
    input  wire [DATA_WIDTH-1:0] wr_data_1,
    input  wire [DATA_WIDTH-1:0] wr_data_2,
    input  wire [DATA_WIDTH-1:0] wr_data_3,
    input  wire [DATA_WIDTH-1:0] wr_data_4,

    input  wire [PRIORITY_WIDTH-1:0] wr_priority_0,
    input  wire [PRIORITY_WIDTH-1:0] wr_priority_1,
    input  wire [PRIORITY_WIDTH-1:0] wr_priority_2,
    input  wire [PRIORITY_WIDTH-1:0] wr_priority_3,
    input  wire [PRIORITY_WIDTH-1:0] wr_priority_4,

    input  wire [2:0] dst_x_0,
    input  wire [2:0] dst_x_1,
    input  wire [2:0] dst_x_2,
    input  wire [2:0] dst_x_3,
    input  wire [2:0] dst_x_4,

    input  wire [2:0] dst_y_0,
    input  wire [2:0] dst_y_1,
    input  wire [2:0] dst_y_2,
    input  wire [2:0] dst_y_3,
    input  wire [2:0] dst_y_4,

    // =========================================================
    // 38-BIT PACKET
    //
    // [37:35] = destination X
    // [34:32] = destination Y
    // [31:30] = priority
    // [29:0]  = payload
    // =========================================================

    output reg [37:0] north_packet,
    output reg [37:0] south_packet,
    output reg [37:0] east_packet,
    output reg [37:0] west_packet,
    output reg [37:0] local_packet,

    output reg north_valid,
    output reg south_valid,
    output reg east_valid,
    output reg west_valid,
    output reg local_valid,

    output reg [4:0] full,
    output reg [4:0] empty
);

    // =========================================================
    // FIFO STORAGE
    // =========================================================

    reg [DATA_WIDTH-1:0]
        fifo_data [0:4][0:FIFO_DEPTH-1];

    reg [PRIORITY_WIDTH-1:0]
        fifo_priority [0:4][0:FIFO_DEPTH-1];

    reg [2:0]
        fifo_dst_x [0:4][0:FIFO_DEPTH-1];

    reg [2:0]
        fifo_dst_y [0:4][0:FIFO_DEPTH-1];

    reg
        fifo_valid [0:4][0:FIFO_DEPTH-1];

    reg [2:0]
        fifo_count [0:4];


    // =========================================================
    // SELECTED PACKET
    // =========================================================

    reg selected_valid;
    reg [2:0] selected_input;

    reg [PRIORITY_WIDTH-1:0]
        selected_priority;

    reg [29:0]
        selected_data;

    reg [2:0] selected_dst_x;
    reg [2:0] selected_dst_y;

    // =========================================================
    // FIFO STATUS
    // =========================================================

    always @(*) begin
        integer i;

        for (i = 0; i < 5; i = i + 1) begin

            full[i] =
                (fifo_count[i] >= FIFO_DEPTH);

            empty[i] =
                (fifo_count[i] == 0);

        end

    end

    // =========================================================
    // PRIORITY ARBITRATION
    //
    // Higher priority wins.
    // Equal priority -> lower input number wins.
    // =========================================================

    always @(*) begin

        selected_valid    = 1'b0;
        selected_input    = 3'd0;
        selected_priority = 2'd0;
        selected_data     = 30'd0;
        selected_dst_x    = 3'd0;
        selected_dst_y    = 3'd0;

        if (fifo_count[0] != 0) begin

            selected_valid    = 1'b1;
            selected_input    = 3'd0;
            selected_priority = fifo_priority[0][0];
            selected_data     = fifo_data[0][0][29:0];
            selected_dst_x    = fifo_dst_x[0][0];
            selected_dst_y    = fifo_dst_y[0][0];

        end

        if (fifo_count[1] != 0) begin

            if (!selected_valid ||
                fifo_priority[1][0] > selected_priority) begin

                selected_valid    = 1'b1;
                selected_input    = 3'd1;
                selected_priority = fifo_priority[1][0];
                selected_data     = fifo_data[1][0][29:0];
                selected_dst_x    = fifo_dst_x[1][0];
                selected_dst_y    = fifo_dst_y[1][0];

            end

        end

        if (fifo_count[2] != 0) begin

            if (!selected_valid ||
                fifo_priority[2][0] > selected_priority) begin

                selected_valid    = 1'b1;
                selected_input    = 3'd2;
                selected_priority = fifo_priority[2][0];
                selected_data     = fifo_data[2][0][29:0];
                selected_dst_x    = fifo_dst_x[2][0];
                selected_dst_y    = fifo_dst_y[2][0];

            end

        end

        if (fifo_count[3] != 0) begin

            if (!selected_valid ||
                fifo_priority[3][0] > selected_priority) begin

                selected_valid    = 1'b1;
                selected_input    = 3'd3;
                selected_priority = fifo_priority[3][0];
                selected_data     = fifo_data[3][0][29:0];
                selected_dst_x    = fifo_dst_x[3][0];
                selected_dst_y    = fifo_dst_y[3][0];

            end

        end

        if (fifo_count[4] != 0) begin

            if (!selected_valid ||
                fifo_priority[4][0] > selected_priority) begin

                selected_valid    = 1'b1;
                selected_input    = 3'd4;
                selected_priority = fifo_priority[4][0];
                selected_data     = fifo_data[4][0][29:0];
                selected_dst_x    = fifo_dst_x[4][0];
                selected_dst_y    = fifo_dst_y[4][0];

            end

        end

    end

    // =========================================================
    // ROUTING
    //
    // EAST  : destination X > current X
    // WEST  : destination X < current X
    // NORTH : destination Y > current Y
    // SOUTH : destination Y < current Y
    //
    // X dimension is handled first.
    // Then Y dimension.
    // =========================================================

    always @(*) begin

        north_packet = 38'd0;
        south_packet = 38'd0;
        east_packet  = 38'd0;
        west_packet  = 38'd0;
        local_packet = 38'd0;

        north_valid = 1'b0;
        south_valid = 1'b0;
        east_valid  = 1'b0;
        west_valid  = 1'b0;
        local_valid = 1'b0;

        if (selected_valid) begin

            // =================================================
            // LOCAL
            // =================================================

            if ((selected_dst_x == current_x) &&
                (selected_dst_y == current_y)) begin

                local_valid = 1'b1;

                local_packet = {
                    selected_dst_x,
                    selected_dst_y,
                    selected_priority,
                    selected_data[29:0]
                };

            end

            // =================================================
            // EAST
            // =================================================

            else if (selected_dst_x > current_x) begin

                east_valid = 1'b1;

                east_packet = {
                    selected_dst_x,
                    selected_dst_y,
                    selected_priority,
                    selected_data[29:0]
                };

            end

            // =================================================
            // WEST
            // =================================================

            else if (selected_dst_x < current_x) begin

                west_valid = 1'b1;

                west_packet = {
                    selected_dst_x,
                    selected_dst_y,
                    selected_priority,
                    selected_data[29:0]
                };

            end

            // =================================================
            // NORTH
            // =================================================

            else if (selected_dst_y > current_y) begin

                north_valid = 1'b1;

                north_packet = {
                    selected_dst_x,
                    selected_dst_y,
                    selected_priority,
                    selected_data[29:0]
                };

            end

            // =================================================
            // SOUTH
            // =================================================

            else if (selected_dst_y < current_y) begin

                south_valid = 1'b1;

                south_packet = {
                    selected_dst_x,
                    selected_dst_y,
                    selected_priority,
                    selected_data[29:0]
                };

            end

        end

    end

    // =========================================================
    // FIFO OPERATIONS
    // =========================================================

    always @(posedge clk or negedge rst_n) begin
        integer i;
        integer j;

        if (!rst_n) begin

            for (i = 0; i < 5; i = i + 1) begin

                fifo_count[i] <= 3'd0;

                for (j = 0; j < FIFO_DEPTH; j = j + 1) begin

                    fifo_data[i][j]     <= 32'd0;
                    fifo_priority[i][j] <= 2'd0;
                    fifo_dst_x[i][j]    <= 3'd0;
                    fifo_dst_y[i][j]    <= 3'd0;
                    fifo_valid[i][j]    <= 1'b0;

                end

            end

        end

        else begin

            // =================================================
            // REMOVE SELECTED HEAD
            // =================================================

            if (selected_valid) begin

                case (selected_input)

                    3'd0: begin

                        for (j = 0; j < FIFO_DEPTH-1; j = j + 1) begin

                            fifo_data[0][j] <= fifo_data[0][j+1];
                            fifo_priority[0][j] <= fifo_priority[0][j+1];
                            fifo_dst_x[0][j] <= fifo_dst_x[0][j+1];
                            fifo_dst_y[0][j] <= fifo_dst_y[0][j+1];
                            fifo_valid[0][j] <= fifo_valid[0][j+1];

                        end

                        fifo_valid[0][FIFO_DEPTH-1] <= 1'b0;

                        fifo_count[0] <=
                            fifo_count[0] - 1'b1;

                    end

                    3'd1: begin

                        for (j = 0; j < FIFO_DEPTH-1; j = j + 1) begin

                            fifo_data[1][j] <= fifo_data[1][j+1];
                            fifo_priority[1][j] <= fifo_priority[1][j+1];
                            fifo_dst_x[1][j] <= fifo_dst_x[1][j+1];
                            fifo_dst_y[1][j] <= fifo_dst_y[1][j+1];
                            fifo_valid[1][j] <= fifo_valid[1][j+1];

                        end

                        fifo_valid[1][FIFO_DEPTH-1] <= 1'b0;

                        fifo_count[1] <=
                            fifo_count[1] - 1'b1;

                    end

                    3'd2: begin

                        for (j = 0; j < FIFO_DEPTH-1; j = j + 1) begin

                            fifo_data[2][j] <= fifo_data[2][j+1];
                            fifo_priority[2][j] <= fifo_priority[2][j+1];
                            fifo_dst_x[2][j] <= fifo_dst_x[2][j+1];
                            fifo_dst_y[2][j] <= fifo_dst_y[2][j+1];
                            fifo_valid[2][j] <= fifo_valid[2][j+1];

                        end

                        fifo_valid[2][FIFO_DEPTH-1] <= 1'b0;

                        fifo_count[2] <=
                            fifo_count[2] - 1'b1;

                    end

                    3'd3: begin

                        for (j = 0; j < FIFO_DEPTH-1; j = j + 1) begin

                            fifo_data[3][j] <= fifo_data[3][j+1];
                            fifo_priority[3][j] <= fifo_priority[3][j+1];
                            fifo_dst_x[3][j] <= fifo_dst_x[3][j+1];
                            fifo_dst_y[3][j] <= fifo_dst_y[3][j+1];
                            fifo_valid[3][j] <= fifo_valid[3][j+1];

                        end

                        fifo_valid[3][FIFO_DEPTH-1] <= 1'b0;

                        fifo_count[3] <=
                            fifo_count[3] - 1'b1;

                    end

                    3'd4: begin

                        for (j = 0; j < FIFO_DEPTH-1; j = j + 1) begin

                            fifo_data[4][j] <= fifo_data[4][j+1];
                            fifo_priority[4][j] <= fifo_priority[4][j+1];
                            fifo_dst_x[4][j] <= fifo_dst_x[4][j+1];
                            fifo_dst_y[4][j] <= fifo_dst_y[4][j+1];
                            fifo_valid[4][j] <= fifo_valid[4][j+1];

                        end

                        fifo_valid[4][FIFO_DEPTH-1] <= 1'b0;

                        fifo_count[4] <=
                            fifo_count[4] - 1'b1;

                    end

                    default: begin
                        // Invalid input index 5, 6, or 7.
                        // No FIFO operation is performed.
                    end

                endcase

            end

            // =================================================
            // APPEND NEW PACKETS
            // =================================================
            //
            // FIFO_DEPTH = 4, therefore the legal array indices
            // are 0,1,2,3. fifo_count is 3 bits because it must
            // also represent the full state 4. Explicit [1:0]
            // indexing removes the Verilator WIDTHTRUNC warning.
            // =================================================

            if (wr_en[0] &&
                (fifo_count[0] < FIFO_DEPTH)) begin

                fifo_data[0][fifo_count[0][1:0]] <= wr_data_0;
                fifo_priority[0][fifo_count[0][1:0]] <= wr_priority_0;
                fifo_dst_x[0][fifo_count[0][1:0]] <= dst_x_0;
                fifo_dst_y[0][fifo_count[0][1:0]] <= dst_y_0;
                fifo_valid[0][fifo_count[0][1:0]] <= 1'b1;

                fifo_count[0] <=
                    fifo_count[0] + 1'b1;

            end

            if (wr_en[1] &&
                (fifo_count[1] < FIFO_DEPTH)) begin

                fifo_data[1][fifo_count[1][1:0]] <= wr_data_1;
                fifo_priority[1][fifo_count[1][1:0]] <= wr_priority_1;
                fifo_dst_x[1][fifo_count[1][1:0]] <= dst_x_1;
                fifo_dst_y[1][fifo_count[1][1:0]] <= dst_y_1;
                fifo_valid[1][fifo_count[1][1:0]] <= 1'b1;

                fifo_count[1] <=
                    fifo_count[1] + 1'b1;

            end

            if (wr_en[2] &&
                (fifo_count[2] < FIFO_DEPTH)) begin

                fifo_data[2][fifo_count[2][1:0]] <= wr_data_2;
                fifo_priority[2][fifo_count[2][1:0]] <= wr_priority_2;
                fifo_dst_x[2][fifo_count[2][1:0]] <= dst_x_2;
                fifo_dst_y[2][fifo_count[2][1:0]] <= dst_y_2;
                fifo_valid[2][fifo_count[2][1:0]] <= 1'b1;

                fifo_count[2] <=
                    fifo_count[2] + 1'b1;

            end

            if (wr_en[3] &&
                (fifo_count[3] < FIFO_DEPTH)) begin

                fifo_data[3][fifo_count[3][1:0]] <= wr_data_3;
                fifo_priority[3][fifo_count[3][1:0]] <= wr_priority_3;
                fifo_dst_x[3][fifo_count[3][1:0]] <= dst_x_3;
                fifo_dst_y[3][fifo_count[3][1:0]] <= dst_y_3;
                fifo_valid[3][fifo_count[3][1:0]] <= 1'b1;

                fifo_count[3] <=
                    fifo_count[3] + 1'b1;

            end

            if (wr_en[4] &&
                (fifo_count[4] < FIFO_DEPTH)) begin

                fifo_data[4][fifo_count[4][1:0]] <= wr_data_4;
                fifo_priority[4][fifo_count[4][1:0]] <= wr_priority_4;
                fifo_dst_x[4][fifo_count[4][1:0]] <= dst_x_4;
                fifo_dst_y[4][fifo_count[4][1:0]] <= dst_y_4;
                fifo_valid[4][fifo_count[4][1:0]] <= 1'b1;

                fifo_count[4] <=
                    fifo_count[4] + 1'b1;

            end

        end

    end

endmodule
