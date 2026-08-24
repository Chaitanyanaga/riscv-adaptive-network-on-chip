# ANOC-RV Verification & Synthesis Artifacts

## Verified RTL Blocks

- ANOC Packet
- ANOC Router
- Even-Odd Router
- Priority Arbiter
- Priority FIFO
- 5-Port FIFO Bank
- ANOC Node
- 5x5 ANOC Network

## Functional Verification

All RTL testbenches pass.

## Synthesis

Yosys synthesis completed successfully for `anoc_network_5x5`.

The synthesized design contains 25 ANOC node submodules.

## Diagrams

Readable gate/combinational diagrams are stored in `04_diagrams/`.

## Truth Tables

See `05_truth_tables/anoc_truth_tables.md`.

## Waveforms

VCD waveform artifacts are stored in `06_waveforms/`.
