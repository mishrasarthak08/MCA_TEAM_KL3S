# RTL Synthesis and Hardware Feasibility Report

## 1. Synthesis Configuration and Toolchain

- **Synthesis Engine:** Yosys Open SYnthesis Suite (Version 0.71+post)
- **Host Target:** macOS Darwin (Apple Silicon arm64)
- **Top-Level Module Synthesized:** `mips_core` (Processor Core only)
- **HDL Standard:** IEEE 1364-2001 (Verilog-2001)
- **Target Cell Library:** Generic / Technology-Independent Netlist Primitives
- **Execution Command:**
  ```bash
  yosys -p "read_verilog rtl/program_counter.v rtl/mips_decoder.v rtl/alu_control.v \
                         rtl/register_file.v rtl/sign_extend.v rtl/alu.v \
                         rtl/branch_jump_logic.v rtl/writeback_logic.v rtl/mips_core.v; \
            hierarchy -check -top mips_core; \
            proc; opt; fsm; opt; memory; opt; techmap; opt; stat"
  ```

> **Architectural Boundary Note:** Synthesis was performed exclusively on `mips_core`. In accordance with Harvard architecture design principles, `instruction_memory` and `data_memory` are external to the core and communicate across dedicated memory buses. Therefore, memories were excluded from this core synthesis run.

---

## 2. Actual Synthesized Netlist Statistics

The following cell counts were produced by Yosys 0.71 from the RTL source:

### Master Hierarchy Summary

| Module | Local Cells | Submodules Included | Total Cell Count |
|---|---|---|---|
| `mips_core` (Top) | 41 | 8 submodules | **9,002** |
| `register_file` | 7,530 | 0 | 7,530 |
| `alu` | 904 | 0 | 904 |
| `branch_jump_logic` | 349 | 0 | 349 |
| `alu_control` | 66 | 0 | 66 |
| `mips_decoder` | 43 | 0 | 43 |
| `writeback_logic` | 37 | 0 | 37 |
| `program_counter` | 32 | 0 | 32 |
| `sign_extend` | 0 | 0 | 0 (pure wiring) |

### Netlist Primitive Cell Breakdown

| Generic Primitive Type | Description | Count | Function in Microarchitecture |
|---|---|---|---|
| `$_DFFE_PP0P_` | Positive-edge D Flip-Flop with Clock Enable & Async Reset | **1,024** | 992 bits for General Purpose Registers ($1–$31) + 32 bits for Program Counter |
| `$_MUX_` | 2-to-1 Multiplexer | **365** | Operand selection, register read multiplexers, write-back selection, next-PC selection |
| `$_AND_` | 2-Input AND Gate | **3,547** | Decoder logic, ALU bitwise operations, address decode |
| `$_OR_` | 2-Input OR Gate | **3,630** | ALU bitwise logic, multiplexer trees, control signal generation |
| `$_XOR_` | 2-Input Exclusive-OR Gate | **216** | ALU subtraction/addition full adders, signed comparison SLT logic |
| `$_NOT_` | Inverter | **220** | Logic inversion, complement arithmetic |
| **Total Cells** | — | **9,002** | — |

---

## 3. Register and Storage Utilization

- **Total Sequential Elements (Flip-Flops):** 1,024
  - **Program Counter (`program_counter`):** 32 flip-flops (`pc_out[31:0]`).
  - **Register File (`register_file`):** 992 flip-flops (31 registers $\times$ 32 bits).
  - *Register $0 Optimization:* Register `$zero` (`$0`) is synthesized without flip-flops; read requests to `$0` are tied to constant `32'b0`, and write strobes to index 0 are disabled in the decode logic, saving 32 flip-flops.
- **Internal Core Memory:** 0 internal BRAMs inside `mips_core`.

---

## 4. Synthesis Diagnostics & Latch Freedom

- **Warning Count:** 1 benign informational message:
  ```text
  Warning: Replacing memory \registers with list of registers. See rtl/register_file.v:39
  ```
  *Technical Interpretation:* Yosys correctly recognized that the 32-entry register file requires multi-ported asynchronous reads (two read ports concurrently accessing independent addresses within the same clock period). Standard FPGA Block RAMs typically provide only synchronous reads; thus, synthesizing the register file as distributed flip-flops (`$_DFFE_PP0P_`) with multiplexer read trees is the architecturally correct hardware representation for single-cycle execution.

- **Latch Analysis:** **0 unintended latches detected.**
  All `always @(*)` combinational blocks in `mips_decoder`, `alu_control`, `alu`, and multiplexer logic utilize complete default assignments and exhaustive case branches, ensuring pure combinational logic.

---

## 5. Scope Disclosure & Theoretical Projections

### Important Academic Disclosure
- **No Physical FPGA Hardware Deployment:** The project was verified through RTL synthesis and simulation in EDA tools (Yosys and Icarus Verilog). No physical FPGA development board was programmed, deployed, or physically measured.
- **No Fabricated Measurements:** No physical power consumption, dynamic voltage, or physical silicon clock frequency was measured.
- **Theoretical Target Projections (Unverified Illustrative Estimates):**
  When mapping this generic netlist to a standard commercial FPGA architecture (such as an AMD Xilinx Artix-7):
  1. The 7,978 logic gates (`AND`, `OR`, `XOR`, `NOT`, `MUX`) are projected to map into approximately 1,200 to 1,600 6-input Look-Up Tables (LUT6).
  2. The 1,024 flip-flops would occupy ~2.4% of available slice registers on an XC7A35T device.
  3. Single-cycle unpipelined critical paths typically constrain operating frequencies to approximately 25 MHz to 40 MHz due to cumulative combinational delays from Instruction Fetch through Data Memory Write-Back.
