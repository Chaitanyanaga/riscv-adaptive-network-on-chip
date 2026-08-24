# ANOC-RV — Adaptive Network-on-Chip for RISC-V

## Overview

ANOC-RV is a 5×5 mesh-based Adaptive Network-on-Chip designed for scalable packet communication in a RISC-V SoC environment.

The design contains 25 nodes connected through North, South, East, West and Local ports.

## Main Features

- 5×5 mesh NoC
- 25 ANOC nodes
- 38-bit packet
- 30-bit payload
- 3-bit destination X/Y
- 2-bit priority
- Priority arbitration
- Priority-aware FIFO
- 5-port FIFO structure
- Even-Odd multi-hop routing
- RTL-to-GDSII implementation
- Sky130A technology

## Packet Format

```text
37:35  Destination X   3 bits
34:32  Destination Y   3 bits
31:30  Priority         2 bits
29:0   Payload         30 bits
