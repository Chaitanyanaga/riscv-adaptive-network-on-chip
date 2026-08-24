`timescale 1ns/1ps

module fifo_bank_5port #(
    parameter DATA_WIDTH     = 32,
    parameter PACKET_WIDTH   = DATA_WIDTH,
    parameter PRIORITY_WIDTH = 2,
    parameter DEPTH          = 4
)(
    input wire clk,
    input wire rst_n,

    // =========================================================
    // WRITE ENABLE
    // =========================================================

    input wire [4:0] wr_en,

    // =========================================================
    // WRITE DATA
    // =========================================================

    input wire [DATA_WIDTH-1:0] wr_data_0,
    input wire [DATA_WIDTH-1:0] wr_data_1,
    input wire [DATA_WIDTH-1:0] wr_data_2,
    input wire [DATA_WIDTH-1:0] wr_data_3,
    input wire [DATA_WIDTH-1:0] wr_data_4,

    // =========================================================
    // WRITE PRIORITY
    // =========================================================

    input wire [PRIORITY_WIDTH-1:0] wr_priority_0,
    input wire [PRIORITY_WIDTH-1:0] wr_priority_1,
    input wire [PRIORITY_WIDTH-1:0] wr_priority_2,
    input wire [PRIORITY_WIDTH-1:0] wr_priority_3,
    input wire [PRIORITY_WIDTH-1:0] wr_priority_4,

    // =========================================================
    // READ ENABLE
    // =========================================================

    input wire [4:0] rd_en,

    // =========================================================
    // HEAD DATA
    // =========================================================

    output wire [DATA_WIDTH-1:0] rd_data_0,
    output wire [DATA_WIDTH-1:0] rd_data_1,
    output wire [DATA_WIDTH-1:0] rd_data_2,
    output wire [DATA_WIDTH-1:0] rd_data_3,
    output wire [DATA_WIDTH-1:0] rd_data_4,

    // =========================================================
    // HEAD PRIORITY
    // =========================================================

    output wire [PRIORITY_WIDTH-1:0] rd_priority_0,
    output wire [PRIORITY_WIDTH-1:0] rd_priority_1,
    output wire [PRIORITY_WIDTH-1:0] rd_priority_2,
    output wire [PRIORITY_WIDTH-1:0] rd_priority_3,
    output wire [PRIORITY_WIDTH-1:0] rd_priority_4,

    // =========================================================
    // DATA AVAILABLE
    // =========================================================

    output wire [4:0] rd_valid,

    // =========================================================
    // STATUS
    // =========================================================

    output wire [4:0] full,
    output wire [4:0] empty
);

    // =========================================================
    // FIFO STORAGE
    //
    // 5 independent FIFOs
    // =========================================================

    reg [DATA_WIDTH-1:0]
        data_mem [0:4][0:DEPTH-1];

    reg [PRIORITY_WIDTH-1:0]
        priority_mem [0:4][0:DEPTH-1];

    reg [2:0]
        fifo_count [0:4];

    integer i;
    integer j;

    // =========================================================
    // OUTPUT DATA
    //
    // FIFO[0] is always the HEAD.
    // =========================================================

    assign rd_data_0 =
        (fifo_count[0] != 0) ? data_mem[0][0] : {DATA_WIDTH{1'b0}};

    assign rd_data_1 =
        (fifo_count[1] != 0) ? data_mem[1][0] : {DATA_WIDTH{1'b0}};

    assign rd_data_2 =
        (fifo_count[2] != 0) ? data_mem[2][0] : {DATA_WIDTH{1'b0}};

    assign rd_data_3 =
        (fifo_count[3] != 0) ? data_mem[3][0] : {DATA_WIDTH{1'b0}};

    assign rd_data_4 =
        (fifo_count[4] != 0) ? data_mem[4][0] : {DATA_WIDTH{1'b0}};

    // =========================================================
    // OUTPUT PRIORITY
    // =========================================================

    assign rd_priority_0 =
        (fifo_count[0] != 0)
        ? priority_mem[0][0]
        : {PRIORITY_WIDTH{1'b0}};

    assign rd_priority_1 =
        (fifo_count[1] != 0)
        ? priority_mem[1][0]
        : {PRIORITY_WIDTH{1'b0}};

    assign rd_priority_2 =
        (fifo_count[2] != 0)
        ? priority_mem[2][0]
        : {PRIORITY_WIDTH{1'b0}};

    assign rd_priority_3 =
        (fifo_count[3] != 0)
        ? priority_mem[3][0]
        : {PRIORITY_WIDTH{1'b0}};

    assign rd_priority_4 =
        (fifo_count[4] != 0)
        ? priority_mem[4][0]
        : {PRIORITY_WIDTH{1'b0}};

    // =========================================================
    // VALID
    //
    // Valid means FIFO contains at least one entry.
    // =========================================================

    assign rd_valid[0] = (fifo_count[0] != 0);
    assign rd_valid[1] = (fifo_count[1] != 0);
    assign rd_valid[2] = (fifo_count[2] != 0);
    assign rd_valid[3] = (fifo_count[3] != 0);
    assign rd_valid[4] = (fifo_count[4] != 0);

    // =========================================================
    // FULL
    // =========================================================

    assign full[0] = (fifo_count[0] >= DEPTH);
    assign full[1] = (fifo_count[1] >= DEPTH);
    assign full[2] = (fifo_count[2] >= DEPTH);
    assign full[3] = (fifo_count[3] >= DEPTH);
    assign full[4] = (fifo_count[4] >= DEPTH);

    // =========================================================
    // EMPTY
    // =========================================================

    assign empty[0] = (fifo_count[0] == 0);
    assign empty[1] = (fifo_count[1] == 0);
    assign empty[2] = (fifo_count[2] == 0);
    assign empty[3] = (fifo_count[3] == 0);
    assign empty[4] = (fifo_count[4] == 0);

    // =========================================================
    // SEQUENTIAL FIFO LOGIC
    // =========================================================

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            for (i = 0; i < 5; i = i + 1) begin

                fifo_count[i] <= 3'd0;

                for (j = 0; j < DEPTH; j = j + 1) begin

                    data_mem[i][j] <= {DATA_WIDTH{1'b0}};

                    priority_mem[i][j] <=
                        {PRIORITY_WIDTH{1'b0}};

                end

            end

        end
        else begin

            // =================================================
            // FIFO 0
            // =================================================

            case ({wr_en[0], rd_en[0]})

                2'b10: begin

                    if (fifo_count[0] < DEPTH) begin

                        data_mem[0][fifo_count[0][1:0]]
                            <= wr_data_0;

                        priority_mem[0][fifo_count[0][1:0]]
                            <= wr_priority_0;

                        fifo_count[0]
                            <= fifo_count[0] + 1'b1;

                    end

                end

                2'b01: begin

                    if (fifo_count[0] != 0) begin

                        for (j = 0; j < DEPTH-1; j = j + 1) begin

                            data_mem[0][j]
                                <= data_mem[0][j+1];

                            priority_mem[0][j]
                                <= priority_mem[0][j+1];

                        end

                        data_mem[0][DEPTH-1] <=
                            {DATA_WIDTH{1'b0}};

                        priority_mem[0][DEPTH-1] <=
                            {PRIORITY_WIDTH{1'b0}};

                        fifo_count[0]
                            <= fifo_count[0] - 1'b1;

                    end

                end

                2'b11: begin

                    if (fifo_count[0] != 0 &&
                        fifo_count[0] < DEPTH) begin

                        for (j = 0; j < DEPTH-1; j = j + 1) begin

                            data_mem[0][j]
                                <= data_mem[0][j+1];

                            priority_mem[0][j]
                                <= priority_mem[0][j+1];

                        end

                        data_mem[0][fifo_count[0]-1]
                            <= wr_data_0;

                        priority_mem[0][fifo_count[0]-1]
                            <= wr_priority_0;

                    end
                    else if (fifo_count[0] == 0) begin

                        data_mem[0][0] <= wr_data_0;

                        priority_mem[0][0]
                            <= wr_priority_0;

                        fifo_count[0] <= 3'd1;

                    end

                end

                default: begin
                end

            endcase

            // =================================================
            // FIFO 1
            // =================================================

            case ({wr_en[1], rd_en[1]})

                2'b10: begin

                    if (fifo_count[1] < DEPTH) begin

                        data_mem[1][fifo_count[1][1:0]]
                            <= wr_data_1;

                        priority_mem[1][fifo_count[1][1:0]]
                            <= wr_priority_1;

                        fifo_count[1]
                            <= fifo_count[1] + 1'b1;

                    end

                end

                2'b01: begin

                    if (fifo_count[1] != 0) begin

                        for (j = 0; j < DEPTH-1; j = j + 1) begin

                            data_mem[1][j]
                                <= data_mem[1][j+1];

                            priority_mem[1][j]
                                <= priority_mem[1][j+1];

                        end

                        data_mem[1][DEPTH-1] <=
                            {DATA_WIDTH{1'b0}};

                        priority_mem[1][DEPTH-1] <=
                            {PRIORITY_WIDTH{1'b0}};

                        fifo_count[1]
                            <= fifo_count[1] - 1'b1;

                    end

                end

                2'b11: begin

                    if (fifo_count[1] != 0 &&
                        fifo_count[1] < DEPTH) begin

                        for (j = 0; j < DEPTH-1; j = j + 1) begin

                            data_mem[1][j]
                                <= data_mem[1][j+1];

                            priority_mem[1][j]
                                <= priority_mem[1][j+1];

                        end

                        data_mem[1][fifo_count[1]-1]
                            <= wr_data_1;

                        priority_mem[1][fifo_count[1]-1]
                            <= wr_priority_1;

                    end
                    else if (fifo_count[1] == 0) begin

                        data_mem[1][0] <= wr_data_1;

                        priority_mem[1][0]
                            <= wr_priority_1;

                        fifo_count[1] <= 3'd1;

                    end

                end

                default: begin
                end

            endcase

            // =================================================
            // FIFO 2
            // =================================================

            case ({wr_en[2], rd_en[2]})

                2'b10: begin

                    if (fifo_count[2] < DEPTH) begin

                        data_mem[2][fifo_count[2][1:0]]
                            <= wr_data_2;

                        priority_mem[2][fifo_count[2][1:0]]
                            <= wr_priority_2;

                        fifo_count[2]
                            <= fifo_count[2] + 1'b1;

                    end

                end

                2'b01: begin

                    if (fifo_count[2] != 0) begin

                        for (j = 0; j < DEPTH-1; j = j + 1) begin

                            data_mem[2][j]
                                <= data_mem[2][j+1];

                            priority_mem[2][j]
                                <= priority_mem[2][j+1];

                        end

                        data_mem[2][DEPTH-1] <=
                            {DATA_WIDTH{1'b0}};

                        priority_mem[2][DEPTH-1] <=
                            {PRIORITY_WIDTH{1'b0}};

                        fifo_count[2]
                            <= fifo_count[2] - 1'b1;

                    end

                end

                2'b11: begin

                    if (fifo_count[2] != 0 &&
                        fifo_count[2] < DEPTH) begin

                        for (j = 0; j < DEPTH-1; j = j + 1) begin

                            data_mem[2][j]
                                <= data_mem[2][j+1];

                            priority_mem[2][j]
                                <= priority_mem[2][j+1];

                        end

                        data_mem[2][fifo_count[2]-1]
                            <= wr_data_2;

                        priority_mem[2][fifo_count[2]-1]
                            <= wr_priority_2;

                    end
                    else if (fifo_count[2] == 0) begin

                        data_mem[2][0] <= wr_data_2;

                        priority_mem[2][0]
                            <= wr_priority_2;

                        fifo_count[2] <= 3'd1;

                    end

                end

                default: begin
                end

            endcase

            // =================================================
            // FIFO 3
            // =================================================

            case ({wr_en[3], rd_en[3]})

                2'b10: begin

                    if (fifo_count[3] < DEPTH) begin

                        data_mem[3][fifo_count[3][1:0]]
                            <= wr_data_3;

                        priority_mem[3][fifo_count[3][1:0]]
                            <= wr_priority_3;

                        fifo_count[3]
                            <= fifo_count[3] + 1'b1;

                    end

                end

                2'b01: begin

                    if (fifo_count[3] != 0) begin

                        for (j = 0; j < DEPTH-1; j = j + 1) begin

                            data_mem[3][j]
                                <= data_mem[3][j+1];

                            priority_mem[3][j]
                                <= priority_mem[3][j+1];

                        end

                        data_mem[3][DEPTH-1] <=
                            {DATA_WIDTH{1'b0}};

                        priority_mem[3][DEPTH-1] <=
                            {PRIORITY_WIDTH{1'b0}};

                        fifo_count[3]
                            <= fifo_count[3] - 1'b1;

                    end

                end

                2'b11: begin

                    if (fifo_count[3] != 0 &&
                        fifo_count[3] < DEPTH) begin

                        for (j = 0; j < DEPTH-1; j = j + 1) begin

                            data_mem[3][j]
                                <= data_mem[3][j+1];

                            priority_mem[3][j]
                                <= priority_mem[3][j+1];

                        end

                        data_mem[3][fifo_count[3]-1]
                            <= wr_data_3;

                        priority_mem[3][fifo_count[3]-1]
                            <= wr_priority_3;

                    end
                    else if (fifo_count[3] == 0) begin

                        data_mem[3][0] <= wr_data_3;

                        priority_mem[3][0]
                            <= wr_priority_3;

                        fifo_count[3] <= 3'd1;

                    end

                end

                default: begin
                end

            endcase

            // =================================================
            // FIFO 4
            // =================================================

            case ({wr_en[4], rd_en[4]})

                2'b10: begin

                    if (fifo_count[4] < DEPTH) begin

                        data_mem[4][fifo_count[4][1:0]]
                            <= wr_data_4;

                        priority_mem[4][fifo_count[4][1:0]]
                            <= wr_priority_4;

                        fifo_count[4]
                            <= fifo_count[4] + 1'b1;

                    end

                end

                2'b01: begin

                    if (fifo_count[4] != 0) begin

                        for (j = 0; j < DEPTH-1; j = j + 1) begin

                            data_mem[4][j]
                                <= data_mem[4][j+1];

                            priority_mem[4][j]
                                <= priority_mem[4][j+1];

                        end

                        data_mem[4][DEPTH-1] <=
                            {DATA_WIDTH{1'b0}};

                        priority_mem[4][DEPTH-1] <=
                            {PRIORITY_WIDTH{1'b0}};

                        fifo_count[4]
                            <= fifo_count[4] - 1'b1;

                    end

                end

                2'b11: begin

                    if (fifo_count[4] != 0 &&
                        fifo_count[4] < DEPTH) begin

                        for (j = 0; j < DEPTH-1; j = j + 1) begin

                            data_mem[4][j]
                                <= data_mem[4][j+1];

                            priority_mem[4][j]
                                <= priority_mem[4][j+1];

                        end

                        data_mem[4][fifo_count[4]-1]
                            <= wr_data_4;

                        priority_mem[4][fifo_count[4]-1]
                            <= wr_priority_4;

                    end
                    else if (fifo_count[4] == 0) begin

                        data_mem[4][0] <= wr_data_4;

                        priority_mem[4][0]
                            <= wr_priority_4;

                        fifo_count[4] <= 3'd1;

                    end

                end

                default: begin
                end

            endcase

        end

    end

endmodule
