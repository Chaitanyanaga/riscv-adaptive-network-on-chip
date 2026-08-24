`timescale 1ns/1ps

module priority_arbiter #(
    parameter NUM_INPUTS = 5,
    parameter PRIORITY_WIDTH = 2
)(
    input wire [NUM_INPUTS-1:0] req,

    input wire [NUM_INPUTS*PRIORITY_WIDTH-1:0] pkt_priority,

    output reg [NUM_INPUTS-1:0] grant,

    output reg grant_valid,

    output reg [2:0] grant_index
);

    reg [PRIORITY_WIDTH-1:0] priority_value;

    integer i;

    always @(*) begin

        grant = {NUM_INPUTS{1'b0}};

        grant_valid = 1'b0;

        grant_index = 3'd0;

        priority_value =
            {PRIORITY_WIDTH{1'b0}};

        /*
         * Scan all requesting inputs.
         *
         * Higher priority wins.
         *
         * Equal priority:
         * lower input number wins.
         */

        for (i = 0; i < NUM_INPUTS; i = i + 1) begin

            if (req[i]) begin

                if (!grant_valid ||
                    (pkt_priority[
                        i*PRIORITY_WIDTH +: PRIORITY_WIDTH
                    ] > priority_value)) begin

                    grant = {NUM_INPUTS{1'b0}};

                    grant[i] = 1'b1;

                    grant_valid = 1'b1;

                    grant_index = i[2:0];

                    priority_value =
                        pkt_priority[
                            i*PRIORITY_WIDTH +: PRIORITY_WIDTH
                        ];

                end

            end

        end

    end

endmodule
