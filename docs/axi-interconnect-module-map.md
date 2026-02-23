# AXI Interconnect: Module-by-Module Guide

This document explains **each AXI-related module**, what it does, and how modules are connected in this repository.

---

## 1) Big picture

At the RTL level, this design is centered around one custom module:
- `axi/axi_interconnect.sv`

It connects:
- **2 initiator-side inputs into the interconnect** (named as AXI slaves in the module port list):
  - `axi_bus_s0`
  - `axi_bus_s1`
- **2 target-side outputs from the interconnect** (named as AXI masters in the module port list):
  - `axi_bus_m0`
  - `axi_bus_m1`

Address split policy in the interconnect:
- `M1_BASE_ADDRESS = 32'h1000_0000`
- addresses below base route to `m0`
- addresses at/above base route to `m1`
- when routed to `m1`, address is translated by subtracting `M1_BASE_ADDRESS`

---

## 2) AXI-related modules and their main tasks

## `axi/axi_interface.sv`

### Main task
Defines a SystemVerilog AXI interface bundle (`interface axi_interface`) so each module can pass one typed interface object instead of many individual wires.

### What it contains
- Write address channel signals (`aw*`)
- Write data channel signals (`w*`)
- Write response channel signals (`b*`)
- Read address channel signals (`ar*`)
- Read data channel signals (`r*`)

### How it connects
- `axi_interconnect.sv` uses this type on all four external ports (`m0`, `m1`, `s0`, `s1`).
- `axi_router.sv` uses `axi_interface.slave`.
- Helper arbiters are simple valid-bit arbiters and do not carry full interface objects.

---

## `axi/axi_interconnect.sv` (core module)

### Main task
Implements routing/arbitration/control for AXI read and write traffic between requesters (`s0`, `s1`) and targets (`m0`, `m1`).

### External connectivity
- Inputs: `clk`, `reset`, request channels from `s0/s1`
- Outputs: AXI requests to `m0/m1`, and responses back to the selected slave side

### Internal organization
The module has two mostly independent control paths:

1. **Write path FSM**
   - State enum: `STATE_ARBITRATE`, `STATE_ISSUE_ADDRESS`, `STATE_ACTIVE_BURST`
   - Tracks:
     - `write_slave_select` (which requester currently owns write burst)
     - `write_master_select` (which target receives burst)
     - `write_burst_address`, `write_burst_length`

2. **Read path FSM**
   - Reuses the same state labels for read flow
   - Tracks:
     - `read_selected_slave`
     - `read_selected_master`
     - `read_burst_address`, `read_burst_length`

### Write-path connection behavior
- If `s0` starts a write burst (`awvalid`), interconnect latches source and destination based on address.
- If `s1` starts a write burst, same logic applies.
- During active burst:
  - interconnect forwards `w*` channel to selected master
  - interconnect returns `awready/wready/bvalid` from selected master to selected slave side
- Address presented to:
  - `m0`: raw burst address
  - `m1`: `write_burst_address - M1_BASE_ADDRESS`

### Read-path connection behavior
- Arbitration order gives `s1` priority over `s0` when both request in same cycle.
- Selected requester’s `ar*` drives selected master (`m0` or `m1`).
- `rvalid/rdata` from selected master is returned only to selected slave side.
- Address presented to:
  - `m0`: raw read address
  - `m1`: `read_burst_address - M1_BASE_ADDRESS`

---

## `axi/axi_router.sv`

### Main task
Combinational one-bit route helper:
- output `0` for lower address range
- output `1` for upper address range

### How it connects
- Takes one `axi_interface.slave` plus `clk/reset`.
- Produces a one-bit `state` route output.
- In this repo’s main interconnect implementation, equivalent decode logic is directly in `axi_interconnect.sv`, so this module acts as a helper/alternate utility.

---

## `axi/axi_write_arbiter.sv`

### Main task
Chooses between two write address valids (`s0_awvalid`, `s1_awvalid`) and outputs one-bit `state` indicating winner.

### How it connects
- Input-only valid bits, output route state.
- In `axi_interconnect.sv`, there is commented-out instantiation of this helper, indicating current active design uses inlined write selection logic.

---

## `axi/axi_read_arbiter.sv`

### Main task
Sequential arbitration for read address valids (`s0_arvalid`, `s1_arvalid`) using registered `cur_state`.

### How it connects
- Input valid bits and output one-bit `state`.
- Similar to write helper: main interconnect currently performs read selection inlined in `axi_interconnect.sv`.

---

## 3) Integration modules around the core

## `hps_with axi_interconnect.qsys`

### Main task
Platform Designer system description that instantiates and wires:
- `clk_0` clock source
- `axi_interconnect_0` custom interconnect block
- clock/reset connections

### How it connects
- Drives interconnect clock from `clk_0.clk`
- Drives interconnect reset from `clk_0.clk_reset`

---

## `hps_with axi_interconnect/synthesis/hps_with axi_interconnect.v`

### Main task
Generated wrapper from Qsys.

### How it connects
- Instantiates `axi_interconnect axi_interconnect_0`
- Instantiates `altera_reset_controller`
- Wires external `reset_reset_n` through reset controller to interconnect reset

---

## 4) End-to-end connection map

```mermaid
flowchart LR
  subgraph Req[Request side into interconnect]
    S0["axi_bus_s0<br/>(JBush core)"]
    S1["axi_bus_s1<br/>(H2F bridge)"]
  end

  subgraph IC[axi_interconnect.sv]
    W[Write FSM\nARBITRATE→ISSUE→ACTIVE]
    R[Read FSM\nARBITRATE→ISSUE→ACTIVE]
    D[Address decode\nM1_BASE=0x1000_0000]
  end

  subgraph Tgt[Target side out of interconnect]
    M0["axi_bus_m0<br/>(SDRAM controller)"]
    M1["axi_bus_m1<br/>(F2H bridge)"]
  end

  S0 --> W
  S1 --> W
  S0 --> R
  S1 --> R

  W --> D
  R --> D

  D -->|addr < base| M0
  D -->|addr >= base\n(addr-base)| M1

  subgraph QSYS[Qsys wrapper context]
    CLK[clk_0]
    RST[altera_reset_controller]
  end

  CLK --> IC
  RST --> IC
```

---

## 5) Quick checklist for understanding signal flow

1. Follow write ownership vars: `write_slave_select`, `write_master_select`.
2. Follow read ownership vars: `read_selected_slave`, `read_selected_master`.
3. Check where `awready/wready/bvalid` are returned to requester side.
4. Check where `arready/rvalid/rdata` are returned to requester side.
5. Check address translation paths for all accesses routed to `m1`.
