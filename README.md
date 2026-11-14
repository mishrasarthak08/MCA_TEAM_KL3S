# Single-Cycle MIPS Processor with Memory Interface

[![Verilog-2001](https://img.shields.io/badge/HDL-Verilog--2001-blue.svg)](http://www.verilog.com/)
[![Simulation-Icarus](https://img.shields.io/badge/Simulation-Icarus_Verilog_13.0-brightgreen.svg)](https://steveicarus.github.io/iverilog/)
[![Synthesis-Yosys](https://img.shields.io/badge/Synthesis-Yosys_0.71-orange.svg)](https://yosyshq.net/yosys/)
[![Format-IEEEtran](https://img.shields.io/badge/Report-IEEEtran_Conference-purple.svg)](report/main.pdf)
[![License-MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Verification-100%_Pass](https://img.shields.io/badge/Tests-85%2F85_Passed-success.svg)](reports/simulation_results.md)

An intermediate-to-advanced Computer Architecture project implementing a functional, 32-bit Harvard-architecture Single-Cycle MIPS processor in synthesizable Verilog-2001. Designed for rigorous academic evaluation across three core deliverables:
1. **IEEE Project Report** (10 Marks): Located in [report/main.pdf](report/main.pdf) (compiled with official `IEEEtran` conference class).
2. **Prototype Demonstration Video** (15 Marks): Scripted in [docs/video_script.md](docs/video_script.md) (4m30s duration, < 5 min limit).
3. **GitHub Repository** (5 Marks): Complete reproducible codebase with automated Makefile tooling.

---

## 1. Project Overview & Objectives

The processor fetches, decodes, executes, performs memory transactions, and commits register state within **one clock cycle per instruction** ($\text{CPI} = 1.00$).

### Core Objectives
- **Instruction Execution:** Full hardware execution of arithmetic, logic, immediate, memory load/store, conditional branching, and unconditional jumps.
- **Modular Memory Architecture:** Physically segregated 32-bit Instruction Memory (ROM) and Data Memory (RAM) interfaces conforming to Harvard architecture.
- **Architectural Integrity:** Physical invariance of register `$0` (`$zero` reads `0x00000000`, writes dropped), sign-extension of 16-bit immediates, and word-alignment checking (`addr[1:0] == 2'b00`).
- **Hardware Robustness:** Automatic detection of illegal opcodes and invalid function codes, suppressing write strobes to prevent state corruption.
- **Benchmark Demonstrations:** Execution of two complete programs from machine-code hex files:
  1. **Array Sum:** Accumulates `[3, 1, 4, 1, 5]` to yield **14** at Memory[20].
  2. **Maximum Element Search:** Iterates `[7, 2, 11, 4, 9]` to yield **11** at Memory[20].

---

## 2. Supported Instruction Set Architecture (ISA)

The processor implements 11 educational MIPS32 instructions with zero branch delay slots:

| Instruction | Type | Format | Opcode / Funct | Operation |
|---|:---:|---|:---:|---|
| **ADD** | R | `ADD rd, rs, rt` | Op: `000000`, Funct: `100000` (`0x20`) | $R[rd] = R[rs] + R[rt]$ |
| **SUB** | R | `SUB rd, rs, rt` | Op: `000000`, Funct: `100010` (`0x22`) | $R[rd] = R[rs] - R[rt]$ |
| **AND** | R | `AND rd, rs, rt` | Op: `000000`, Funct: `100100` (`0x24`) | $R[rd] = R[rs] \ \& \ R[rt]$ |
| **OR** | R | `OR rd, rs, rt` | Op: `000000`, Funct: `100101` (`0x25`) | $R[rd] = R[rs] \ \| \ R[rt]$ |
| **XOR** | R | `XOR rd, rs, rt` | Op: `000000`, Funct: `100110` (`0x26`) | $R[rd] = R[rs] \ \oplus \ R[rt]$ |
| **SLT** | R | `SLT rd, rs, rt` | Op: `000000`, Funct: `101010` (`0x2A`) | $R[rd] = (\$signed(R[rs]) < \$signed(R[rt])) \ ? \ 1 : 0$ |
| **ADDI** | I | `ADDI rt, rs, imm` | Op: `001000` (`0x08`) | $R[rt] = R[rs] + \text{SignExt}(imm)$ |
| **LW** | I | `LW rt, offset(rs)` | Op: `100011` (`0x23`) | $R[rt] = \text{Memory}[R[rs] + \text{SignExt}(offset)]$ |
| **SW** | I | `SW rt, offset(rs)` | Op: `101011` (`0x2B`) | $\text{Memory}[R[rs] + \text{SignExt}(offset)] = R[rt]$ |
| **BEQ** | I | `BEQ rs, rt, label` | Op: `000100` (`0x04`) | $\text{if } R[rs] == R[rt]: \ PC = PC + 4 + (\text{SignExt}(imm) \ll 2)$ |
| **J** | J | `J target` | Op: `000010` (`0x02`) | $PC = \{ (PC + 4)[31:28], target[25:0], 2'b00 \}$ |

---

## 3. Microarchitecture & Block Diagram

```text
       +-------------------------------------------------------------------------+
       |                                                                         |
       v                                                                         |
   +-------+   PC    +--------------------+  Instruction  +-------------------+  |
   |  PC   |-------->| Instruction Memory |-------------->| Main Decoder &    |  |
   +-------+         | (256 x 32-bit ROM) |               | ALU Control Unit  |  |
       |             +--------------------+               +-------------------+  |
       | (PC+4)                |                                    |            |
       |                       | rs, rt, rd, imm                    | Controls   |
       v                       v                                    v            |
   +-------+         +--------------------+               +-------------------+  |
   | Adder |         |   Register File    |-------------->| 32-Bit ALU &      |  |
   +-------+         | (32 x 32-bit GPRs) |  Data1, Data2 | Sign-Extend Unit  |  |
       |             +--------------------+               +-------------------+  |
       |                       ^                                    |            |
       |                       | Write Data                         | ALU Result |
       |                       |                                    v            |
       |             +--------------------+  Read Data    +-------------------+  |
       |             | Write-Back Logic   |<--------------| Data Memory (RAM) |  |
       |             | (Multiplexers)     |               | (256 x 32-bit)    |  |
       |             +--------------------+               +-------------------+  |
       |                                                            |            |
       +-------------------> [ Branch & Jump Logic ] ---------------+            |
                                     |                                           |
                                     +------------------- Next PC ---------------+
```

Interactive Mermaid diagrams are available in [docs/block_diagram.mmd](docs/block_diagram.mmd) and [docs/datapath_diagram.mmd](docs/datapath_diagram.mmd).

---

## 4. Repository Structure

```text
MCA_TEAM_KL3S/
│
├── README.md                           # Master Project Documentation & Quickstart
├── LICENSE                             # MIT Open-Source License
├── Makefile                            # Unified Automation Script for Simulation, Synthesis, and Build
│
├── rtl/                                # Synthesizable Verilog-2001 RTL Source Files
│   ├── program_counter.v               # 32-bit Program Counter Register
│   ├── instruction_memory.v            # Word-aligned Instruction ROM ($readmemh supported)
│   ├── mips_decoder.v                  # Main Instruction Control Decoder
│   ├── alu_control.v                   # ALU Secondary Operation Decoder
│   ├── register_file.v                 # 32x32-bit Dual-Read Single-Write Register File
│   ├── sign_extend.v                   # 16-to-32 bit Arithmetic Sign Extender
│   ├── alu.v                           # 32-bit Arithmetic Logic Unit
│   ├── data_memory.v                   # Byte-addressed RAM with Bounds Protection
│   ├── branch_jump_logic.v             # Next-PC Calculation & Priority Multiplexers
│   ├── writeback_logic.v               # Destination & Data Write-Back Multiplexers
│   ├── mips_core.v                     # Complete Processor Core (Datapath + Control)
│   └── mips_system.v                   # Top-Level System with Memory & Debug Busses
│
├── testbench/                          # Self-Checking Verification Testbenches
│   ├── tb_alu.v                        # Unit Testbench for ALU (23 checks)
│   ├── tb_register_file.v              # Unit Testbench for Register File (19 checks)
│   ├── tb_decoder.v                    # Unit Testbench for Decoder & ALU Control (17 checks)
│   ├── tb_memory.v                     # Testbench for Memory Interfaces (12 checks)
│   ├── tb_branch_jump.v                # Testbench for Branch and Jump Logic (8 checks)
│   ├── tb_invalid_instr.v              # Robustness & Error Suppression Testbench (6 checks)
│   ├── tb_mips_cpu.v                   # Master CPU Integration Testbench: Array Sum (39 cycles)
│   └── tb_mips_cpu_max.v               # Master CPU Integration Testbench: Max Search (39 cycles)
│
├── programs/                           # MIPS Assembly Benchmarks & Machine Code
│   ├── array_sum.asm                   # Source Assembly: Array Accumulation
│   ├── array_sum.hex                   # Assembled Machine Code Hex (13 instructions)
│   ├── array_sum_data.hex              # Data Memory Initialization ([3, 1, 4, 1, 5])
│   ├── array_sum_listing.txt           # Disassembly Listing with Symbol Table
│   ├── max_search.asm                  # Source Assembly: Maximum Element Search
│   ├── max_search.hex                  # Assembled Machine Code Hex (16 instructions)
│   ├── max_search_data.hex             # Data Memory Initialization ([7, 2, 11, 4, 9])
│   └── max_search_listing.txt          # Disassembly Listing with Symbol Table
│
├── tools/
│   └── assemble.py                     # Custom Two-Pass MIPS Assembler with Label Resolution
│
├── docs/                               # Architectural & Verification Documentation
│   ├── architecture.md                 # Detailed Architectural Specification
│   ├── block_diagram.mmd               # Mermaid Block Diagram
│   ├── datapath_diagram.mmd            # Mermaid Datapath Diagram
│   ├── control_signals.md              # Control Signal Truth Tables & Encodings
│   ├── verification.md                 # Comprehensive Verification Plan & Coverage
│   ├── video_script.md                 # 4m30s Prototype Demonstration Video Script
│   ├── evaluation_checklist.md         # Academic Grading Rubric Compliance Matrix
│   └── team_contributions.md           # Individual Group Member Contribution Table
│
├── report/                             # Academic Project Report (Official IEEEtran Class)
│   ├── main.tex                        # LaTeX Source Code (\documentclass[conference]{IEEEtran})
│   ├── references.bib                  # BibTeX References (Authentic academic citations)
│   ├── figures/                        # Diagram Assets
│   └── main.pdf                        # Compiled Two-Column IEEE Project Report PDF
│
├── waveforms/                          # Simulation Waveform Dumps (VCD) & Configs
│   ├── README.md                       # Waveform Interpretation Guide
│   ├── mips_cpu.gtkw                   # Pre-configured GTKWave Signal Layout
│   ├── mips_cpu_array_sum.vcd          # Full Waveform Dump: Array Sum
│   ├── mips_cpu_max_search.vcd         # Full Waveform Dump: Maximum Search
│   ├── tb_alu.vcd                      # Waveform Dump: ALU Unit Test
│   ├── tb_register_file.vcd            # Waveform Dump: Register File Unit Test
│   ├── tb_decoder.vcd                  # Waveform Dump: Decoder Unit Test
│   ├── tb_memory.vcd                   # Waveform Dump: Memory Unit Test
│   ├── tb_branch_jump.vcd              # Waveform Dump: Branch/Jump Unit Test
│   └── tb_invalid_instr.vcd            # Waveform Dump: Robustness Unit Test
│
└── reports/                            # Hardware and Simulation Evaluation Artifacts
    ├── simulation_results.md           # Complete Execution Traces and Cycle Counts
    └── synthesis_report.md             # Yosys 0.71 RTL Synthesis Cell Statistics
```

---

## 5. Prerequisites & Toolchain Setup

To run simulations, synthesis, and report compilation on macOS or Linux:

```bash
# macOS (using Homebrew)
brew install icarus-verilog yosys tectonic python3

# Linux (Ubuntu / Debian)
sudo apt-get update
sudo apt-get install iverilog yosys python3
```

---

## 6. Execution Commands & Quickstart

All operations are automated via the root [Makefile](Makefile):

```bash
# 1. Assemble programs, run full test regression, run both demos, and run synthesis
make all

# 2. Assemble MIPS source files (.asm -> .hex)
make assemble

# 3. Execute all unit and system testbenches (85 assertions)
make test

# 4. Run Program 1 (Array Sum = 14) with live execution trace
make demo-sum

# 5. Run Program 2 (Maximum Search = 11) with live execution trace
make demo-max

# 6. Run Yosys RTL Synthesis on mips_core
make synth

# 7. Compile IEEE Project Report PDF
make report

# 8. Clean temporary compilation artifacts
make clean
```

---

## 7. Verification Summary

| Test Suite | Module | Total Checks | Outcome | Performance / Result |
|---|---|:---:|:---:|---|
| `tb_alu` | `alu.v` | 23 | **PASS** | Signed SLT, boundaries (`0x80000000` vs `0x7FFFFFFF`), zero flag verified |
| `tb_register_file` | `register_file.v` | 19 | **PASS** | Dual-port reads verified; `$zero` write drops verified; reset clears to 0 |
| `tb_decoder` | `mips_decoder.v`, `alu_control.v` | 17 | **PASS** | All opcodes, illegal opcodes (`0x3F`, `0x15`), and R-type funct verified |
| `tb_memory` | `instruction_memory.v`, `data_memory.v` | 12 | **PASS** | Byte-address alignment and memory bounds violations caught |
| `tb_branch_jump` | `branch_jump_logic.v` | 8 | **PASS** | Sequential PC+4, forward/backward BEQ, jump target, and priority verified |
| `tb_invalid_instr` | `mips_core.v` | 6 | **PASS** | Write enables deasserted on illegal opcodes; architectural state protected |
| `tb_mips_cpu` | `mips_system.v` | — | **PASS** | **Array Sum = 14** (39 clock cycles, $\text{CPI} = 1.00$) |
| `tb_mips_cpu_max` | `mips_system.v` | — | **PASS** | **Maximum Search = 11** (39 clock cycles, $\text{CPI} = 1.00$) |
| **Total** | — | **85 / 85** | **100% PASS** | Zero failures across all test suites |

---

## 8. Logic Synthesis Results (Yosys 0.71)

Synthesizing `mips_core.v` using Yosys targeting generic cell primitives produced:
- **Top-Level Module Synthesized:** `mips_core` (memories external via Harvard buses)
- **Total Netlist Cells:** **9,002**
- **State Flip-Flops (`$_DFFE_PP0P_`):** **1,024** (992 in Register File + 32 in PC)
- **Multiplexers (`$_MUX_`):** **365**
- **Logic Gates:** 3,547 AND, 3,630 OR, 216 XOR, 220 NOT
- **Unintended Latches:** **0** (pure combinational decoding confirmed)

*Hardware Feasibility Note:* No physical FPGA board was programmed or deployed. Detailed cell breakdowns and unverified theoretical FPGA projections are documented in [reports/synthesis_report.md](reports/synthesis_report.md).

---

## 9. Waveform Inspection

Open waveform artifacts in GTKWave:

```bash
# View Array Sum execution trace
gtkwave waveforms/mips_cpu_array_sum.vcd waveforms/mips_cpu.gtkw

# View Maximum Search execution trace
gtkwave waveforms/mips_cpu_max_search.vcd waveforms/mips_cpu.gtkw
```

Detailed signal walkthroughs and timing milestones are documented in [waveforms/README.md](waveforms/README.md).

---

## 10. Architectural Limitations

This processor implements an unpipelined educational subset of MIPS32:
- **Critical Path:** Clock cycle period is bounded by the total combinational latency from Instruction Fetch to Register Write-Back (~25–40 MHz on Artix-7 FPGA).
- **Branch Delay Slots:** Omitted; branches and jumps take effect immediately on the next clock cycle.
- **Excluded Features:** Hardware interrupts, exceptions, pipeline hazard units, multiplication/division coprocessor (HI/LO), and byte/halfword loads (`LB`, `LH`).

---

## 11. Team Information & Deliverables

| Group Member | Academic Role & Deliverables | Contact / ID Placeholder |
|---|---|---|
| **Member 1** | System Architect & Integration Lead (`mips_core.v`, `mips_system.v`, `Makefile`) | `[NAME_1]` / `[ID_1]` |
| **Member 2** | Control Systems Specialist (`mips_decoder.v`, `alu_control.v`) | `[NAME_2]` / `[ID_2]` |
| **Member 3** | Datapath & ALU Engineer (`alu.v`, `sign_extend.v`, `writeback_logic.v`, Synthesis) | `[NAME_3]` / `[ID_3]` |
| **Member 4** | Memory Subsystem Engineer (`register_file.v`, `instruction_memory.v`, `data_memory.v`) | `[NAME_4]` / `[ID_4]` |
| **Member 5** | Verification & Software Lead (`assemble.py`, `array_sum.asm`, `max_search.asm`, Testbenches) | `[NAME_5]` / `[ID_5]` |

### Deliverable Artifacts
- **IEEE Project Report:** [report/main.pdf](report/main.pdf) (official `IEEEtran` conference class; LaTeX source: [report/main.tex](report/main.tex)).
- **Demonstration Video Script:** [docs/video_script.md](docs/video_script.md) (Duration: 4m30s, max 5m).
- **Demonstration Video Link:** `https://youtu.be/[REPLACE_WITH_YOUR_UNLISTED_DEMO_VIDEO_ID]` (Pending team upload).
- **Evaluation Checklist:** [docs/evaluation_checklist.md](docs/evaluation_checklist.md).
