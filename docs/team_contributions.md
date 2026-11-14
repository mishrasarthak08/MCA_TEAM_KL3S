# Team Member Contributions & Responsibility Matrix

**Project:** Single-Cycle MIPS Processor with Memory Interface
**Academic Module:** Computer Architecture Project Submission (MCA 2026)
**Institution:** Newton School of Technology, Rishihood University
**Department:** Department of Computer Science and Engineering
**Team Name:** `KL3S`
**Team Repository:** `MCA_TEAM_KL3S`
**Branch:** `main`

---

## 1. Group Member Allocation & Responsibilities

The table below outlines the assigned engineering responsibilities and component ownership across the five group members of Team KL3S.

| Member | Assigned Engineering Role | Core Modules & Technical Ownership | IEEE Report Sections Authored | Contact & Verification Sign-off |
|---|---|---|---|:---:|
| **Sarthak Mishra**<br/>Lead Engineer<br/>ID: `2401010421` | **Lead System Architect & Toolchain Lead** | - Formulated top-level core and system architecture (`mips_core.v`, `mips_system.v`).<br/>- Developed two-pass Python assembler (`tools/assemble.py`) and instruction set mapping.<br/>- Designed Harvard memory bus interfaces and top-level debug observability ports.<br/>- Authored benchmark assembly programs (`array_sum.asm`, `max_search.asm`).<br/>- Created master automated `Makefile` targets for simulation, synthesis, and report compilation.<br/>- Lead editor for technical documentation, Git repository release manager. | - Section I: Introduction<br/>- Section III: Problem Statement & Objectives<br/>- Section IV: Proposed Solution<br/>- Section VI: Processor Datapath Design<br/>- Section VIII: RTL Architecture Integration<br/>- Section XIV: Conclusion | `sarthak.mishra2024@nst.rishihood.edu.in`<br/>**[Signed - Sarthak Mishra]** |
| **Shitanshu Tiwari**<br/>Team Member<br/>ID: `2401010440` | **Control Unit & Decoder Specialist** | - Designed and implemented `mips_decoder.v` and `alu_control.v`.<br/>- Developed control signal truth tables, default combinational assignments, and latch prevention.<br/>- Authored unit testbench `testbench/tb_decoder.v` (17 tests). | - Section VII: Control Unit Design | `shitanshu.tiwari2024@nst.rishihood.edu.in`<br/>**[Signed - Shitanshu Tiwari]** |
| **Shane Joseph**<br/>Team Member<br/>ID: `2401020062` | **Verification & Testbench Lead** | - Authored CPU system integration testbenches (`tb_mips_cpu.v`, `tb_mips_cpu_max.v`, `tb_invalid_instr.v`).<br/>- Implemented self-checking assertion framework across testbenches (85/85 assertions passed).<br/>- Executed waveform validation in GTKWave and regression sign-off. | - Section IX: Verification Methodology<br/>- Section X: Simulation & Waveform Analysis | `Shane.2024@nst.rishihood.edu.in`<br/>**[Signed - Shane Joseph]** |
| **Lakshay Yadav**<br/>Team Member<br/>ID: `2401010250` | **Memory Subsystems & Branch/Jump Logic Engineer** | - Implemented $32 \times 32$-bit Register File (`register_file.v`) with physical \$zero invariance and reset logic.<br/>- Developed `instruction_memory.v` and `data_memory.v` with word-alignment and bounds protection.<br/>- Implemented branch and jump address calculation logic (`branch_jump_logic.v`).<br/>- Authored unit testbenches `tb_register_file.v` (19 tests) and `tb_memory.v` (12 tests). | - Section VIII: Memory & Register Subsystems<br/>- Section XIII: Limitations and Future Work | `Lakshay.yadav2024@nst.rishihood.edu.in`<br/>**[Signed - Lakshay Yadav]** |
| **Kshitiz Surana**<br/>Team Member<br/>ID: `2401010242` | **Datapath Execution, ALU & Synthesis Specialist** | - Implemented 32-bit ALU (`alu.v`), Sign Extension (`sign_extend.v`), and Write-Back Logic (`writeback_logic.v`).<br/>- Authored unit testbench `testbench/tb_alu.v` covering signed SLT and extreme numerical boundaries (23 tests).<br/>- Executed Yosys RTL synthesis and cell distribution analysis. | - Section V: MIPS Architecture & Formats<br/>- Section XI: Synthesis Results | `kshitiz.2024@nst.rishihood.edu.in`<br/>**[Signed - Kshitiz Surana]** |

---

## 2. Authorship Alignment

The table above is fully synchronized with Table II (*Assigned Group Member Responsibilities*) in the official IEEE project report ([report/main.pdf](file:///Users/SarMish/MCA_TEAM_KL3S/report/main.pdf) / [report/main.tex](file:///Users/SarMish/MCA_TEAM_KL3S/report/main.tex)).
