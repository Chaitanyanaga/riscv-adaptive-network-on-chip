`timescale 1ns/1ps

module priority_fifo #(
    parameter DATA_WIDTH     = 32,
    parameter PRIORITY_WIDTH = 2,
    parameter DEPTH          = 4
)(
    input wire                         clk,
    input wire                         rst_n,

    input wire                         wr_en,
    input wire [DATA_WIDTH-1:0]        wr_data,
    input wire [PRIORITY_WIDTH-1:0]    wr_priority,

    input wire                         rd_en,

    output reg [DATA_WIDTH-1:0]        rd_data,
    output reg [PRIORITY_WIDTH-1:0]    rd_priority,
    output reg                         rd_valid,

    output wire                        full,
    output wire                        empty,
    output wire [2:0]                  count
);

    reg [DATA_WIDTH-1:0]
        fifo_data [0:DEPTH-1];

    reg [PRIORITY_WIDTH-1:0]
        fifo_priority [0:DEPTH-1];

    reg valid [0:DEPTH-1];

    reg [2:0] fifo_count;

    integer i;
    integer selected;

    reg selected_valid;

    reg [PRIORITY_WIDTH-1:0]
        selected_priority;

    assign count = fifo_count;

    assign full =
        (fifo_count >= DEPTH);

    assign empty =
        (fifo_count == 3'd0);

    always @(
        valid[0],
        valid[1],
        valid[2],
        valid[3],

        fifo_priority[0],
        fifo_priority[1],
        fifo_priority[2],
        fifo_priority[3]
    ) begin

        selected = 0;

        selected_valid = 1'b0;

        selected_priority =
            {PRIORITY_WIDTH{1'b0}};

        for (i = 0; i < DEPTH; i = i + 1) begin

            if (valid[i]) begin

                if (!selected_valid) begin

                    selected = i;
                    selected_valid = 1'b1;
                    selected_priority =
                        fifo_priority[i];

                end
                else if (
                    fifo_priority[i] >
                    selected_priority
                ) begin

                    selected = i;
                    selected_priority =
                        fifo_priority[i];

                end

            end

        end

    end

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            fifo_count <= 3'd0;

            rd_data <=
                {DATA_WIDTH{1'b0}};

            rd_priority <=
                {PRIORITY_WIDTH{1'b0}};

            rd_valid <= 1'b0;

            for (i = 0; i < DEPTH; i = i + 1) begin

                fifo_data[i] <=
                    {DATA_WIDTH{1'b0}};

                fifo_priority[i] <=
                    {PRIORITY_WIDTH{1'b0}};

                valid[i] <= 1'b0;

            end

        end
        else begin

            rd_valid <= 1'b0;

            if (wr_en && !full) begin

                if (!valid[0]) begin

                    fifo_data[0] <= wr_data;
                    fifo_priority[0] <= wr_priority;
                    valid[0] <= 1'b1;

                end
                else if ((DEPTH > 1) && !valid[1]) begin

                    fifo_data[1] <= wr_data;
                    fifo_priority[1] <= wr_priority;
                    valid[1] <= 1'b1;

                end
                else if ((DEPTH > 2) && !valid[2]) begin

                    fifo_data[2] <= wr_data;
                    fifo_priority[2] <= wr_priority;
                    valid[2] <= 1'b1;

                end
                else if ((DEPTH > 3) && !valid[3]) begin

                    fifo_data[3] <= wr_data;
                    fifo_priority[3] <= wr_priority;
                    valid[3] <= 1'b1;

                end

            end

            if (rd_en && selected_valid) begin

                rd_data <= fifo_data[selected];

                rd_priority <=
                    fifo_priority[selected];

                rd_valid <= 1'b1;

                valid[selected] <= 1'b0;

            end

            case ({
                (wr_en && !full),
                (rd_en && selected_valid)
            })

                2'b10:
                    fifo_count <=
                        fifo_count + 1'b1;

                2'b01:
                    fifo_count <=
                        fifo_count - 1'b1;

                2'b11:
                    fifo_count <= fifo_count;

                default:
                    fifo_count <= fifo_count;

            endcase

        end

    end

endmodule
