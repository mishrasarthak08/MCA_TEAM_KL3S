# Synthesis and Hardware Implementation Report

## 1. Toolchain and Configuration

- **Synthesis Tool:** Yosys Open SYnthesis Suite (Version 0.71+post)
- **Host Target:** macOS Darwin (Apple Silicon arm64)
- **Top-Level Module:** `mips_core`
- **HDL Standard:** IEEE 1364-2001 (Verilog-2001)
- **Target Cell Library:** Generic / Technology-Independent Netlist primitives
- **Synthesis Command:**
  ```bash
  yosys -p "read_verilog rtl/program_counter.v rtl/mips_decoder.v rtl/alu_control.v \
                         rtl/register_file.v rtl/sign_extend.v rtl/alu.v \
                         rtl/branch_jump_logic.v rtl/writeback_logic.v rtl/mips_core.v; \
            hierarchy -check -top mips_core; \
            proc; opt; fsm; opt; memory; opt; techmap; opt; stat"
  ```

---

## 2. Synthesized Design Hierarchy and Cell Statistics

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

### Netlist Primitive Breakdown

| Cell Primitive Type | Description | Count | Function in Design |
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

- **Total State Elements (Flip-Flops):** 1,024
  - **Program Counter (`program_counter`):** 32 flip-flops (`pc_out[31:0]`).
  - **Register File (`register_file`):** 992 flip-flops (31 registers $\times$ 32 bits).
  - *Note on Register $0:* Register `$zero` (`$0`) is synthesized without flip-flops; reads to `$0` are tied to constant `32'b0`, and write strobes to index 0 are disabled in the decode logic, saving 32 flip-flops.
- **Memory Blocks:** 0 internal BRAMs inside `mips_core`. Memories (`instruction_memory` and `data_memory`) are separated into modular external interfaces adhering to Harvard architecture principles.

---

## 4. Synthesis Warnings and Diagnostics

- **Warning Count:** 1 warning (benign architectural confirmation):
  ```text
  Warning: Replacing memory \registers with list of registers. See rtl/register_file.v:39
  ```
  *Interpretation:* Yosys correctly identified that the 32-entry register file requires multi-ported asynchronous reads (two read ports concurrently reading independent addresses within the same clock cycle). Standard FPGA block RAMs (BRAMs) typically only provide synchronous read ports; therefore, synthesizing the register file as distributed flip-flops (`$_DFFE_PP0P_`) with combinational muxing is the architecturally correct hardware mapping for single-cycle execution.

- **Latch Analysis:** **0 unintended latches detected.**
  All `always @(*)` combinational processes in `mips_decoder`, `alu_control`, `alu`, and multiplexer logic feature complete default assignments and exhaustive case branches, ensuring pure combinational synthesis.

---

## 5. Hardware Readiness and FPGA Mapping Recommendations

### Target FPGA Resource Mapping (e.g., Xilinx Artix-7 / Spartan-7)
When targeting an FPGA such as the AMD Xilinx Artix-7 (XC7A35T or XC7A100T):
1. **Slice LUTs:** The 7,978 logic gates (`AND`, `OR`, `XOR`, `NOT`, `MUX`) map into approximately 1,200 to 1,600 6-input LUTs (LUT6), well within a standard 35T device (~20,800 LUTs, ~6–8% utilization).
2. **Slice Registers:** The 1,024 flip-flops occupy ~2.4% of available flip-flops (41,600 total).
3. **Block RAMs:** For standalone deployment, `instruction_memory` and `data_memory` can be mapped to on-chip Block RAMs (18Kb or 36Kb primitives) or distributed SelectRAM.
4. **Estimated Clock Period:** In typical -1 speed grade Artix-7 silicon, the single-cycle critical path (PC register $\to$ Instruction Memory $\to$ Register File read $\to$ ALU addition/SLT $\to$ Data Memory read $\to$ Write-back mux $\to$ Register File setup) achieves maximum operating frequencies between **25 MHz and 40 MHz** (period 25–40 ns), which is typical and well-understood for unpipelined educational MIPS architectures.
