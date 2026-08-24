# ANOC-RV Final ASIC Signoff

## Design
- Top module: anoc_network_5x5
- Architecture: 5x5 Adaptive Network-on-Chip
- Nodes: 25
- Process: Sky130A
- Standard-cell library: sky130_fd_sc_hd

## RTL Verification
- Verilator lint: 0 warnings, 0 errors
- 5x5 network regression: PASS
- Local routing: PASS
- East routing: PASS
- West routing: PASS
- North routing: PASS
- South routing: PASS
- Even-Odd multi-hop routing: PASS

## ASIC Flow
- OpenLane: 1.0.2
- Clock period: 12 ns
- Target frequency: 83.33 MHz
- Synthesis: PASS
- Placement: PASS
- CTS: PASS
- Routing: PASS
- Hold timing: PASS
- Setup timing: PASS
- DRC: PASS
- LVS: completed
- KLayout/Magic XOR: PASS
- Flow status: COMPLETED

## Remaining Warnings
- Maximum slew violations
- Maximum capacitance violations
- Some STA blackbox warnings
- IR-drop warning because VSRC_LOC_FILES is not defined

## Final Views
- GDSII
- DEF
- LEF
- SDC
- SPEF
- SDF
- Powered netlist / Verilog

