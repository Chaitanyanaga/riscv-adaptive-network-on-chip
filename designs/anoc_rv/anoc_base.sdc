# ANOC-RV custom timing constraints

set_output_delay 0.0 \
    -clock [get_clocks clk] \
    [all_outputs]
