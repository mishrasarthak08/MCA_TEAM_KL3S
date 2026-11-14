# Team Member Contributions & Responsibility Matrix

**Project:** Single-Cycle MIPS Processor with Memory Interface
**Academic Module:** Computer Architecture Project Submission
**Team Repository:** `MCA_TEAM_KL3S`
**Branch:** `main`

---

## 1. Group Member Allocation

> **Important Academic Submission Notice:**
> The table below outlines the assigned engineering responsibilities and component ownership across the five group members. The placeholders `[FULL NAME]` and `[STUDENT_ID]` must be filled in with the official student credentials prior to final evaluation submission.

| Member | Assigned Engineering Role | Core Modules & Technical Ownership | IEEE Report Sections Authored | Verification & Deliverable Sign-off |
|---|---|---|---|:---:|
| **Member 1**<br/>`[MEMBER 1 FULL NAME]`<br/>ID: `[STUDENT_ID_1]` | **System Architecture & Integration Lead** | - Formulated top-level core and system architecture (`mips_core.v`, `mips_system.v`).<br/>- Designed Harvard memory bus interfaces and top-level debug observability ports.<br/>- Created automated `Makefile` targets for simulation, synthesis, and report compilation. | - Section I: Introduction<br/>- Section IV: Proposed Solution<br/>- Section VIII: RTL Architecture Integration<br/>- Section XIV: Conclusion | `[Pending Manual Signature]` |
| **Member 2**<br/>`[MEMBER 2 FULL NAME]`<br/>ID: `[STUDENT_ID_2]` | **Control Unit & Decoder Specialist** | - Designed and implemented `mips_decoder.v` and `alu_control.v`.<br/>- Developed control signal truth tables, default combinational assignments, and latch prevention.<br/>- Authored unit testbench `testbench/tb_decoder.v` (17 tests). | - Section VII: Control Unit Design | `[Pending Manual Signature]` |
| **Member 3**<br/>`[MEMBER 3 FULL NAME]`<br/>ID: `[STUDENT_ID_3]` | **Datapath & ALU Engineer** | - Implemented 32-bit ALU (`alu.v`), Sign Extension (`sign_extend.v`), and Write-Back Logic (`writeback_logic.v`).<br/>- Authored unit testbench `testbench/tb_alu.v` covering signed SLT and extreme numerical boundaries.<br/>- Executed Yosys RTL synthesis and cell distribution analysis. | - Section V: MIPS Architecture & Formats<br/>- Section VI: Processor Datapath Design<br/>- Section XI: Synthesis Results | `[Pending Manual Signature]` |
| **Member 4**<br/>`[MEMBER 4 FULL NAME]`<br/>ID: `[STUDENT_ID_4]` | **Memory & Register File Engineer** | - Implemented $32 \times 32$-bit Register File (`register_file.v`) with physical \$zero invariance and reset logic.<br/>- Developed `instruction_memory.v` and `data_memory.v` with word-alignment and bounds protection.<br/>- Authored unit testbenches `tb_register_file.v` (19 tests) and `tb_memory.v` (12 tests). | - Section VIII: Memory & Register Subsystems<br/>- Section XIII: Limitations and Future Work | `[Pending Manual Signature]` |
| **Member 5**<br/>`[MEMBER 5 FULL NAME]`<br/>ID: `[STUDENT_ID_5]` | **Verification & Software Tooling Engineer** | - Developed two-pass Python assembler (`tools/assemble.py`) with label and branch offset resolution.<br/>- Authored sample MIPS programs: Array Sum (`array_sum.asm`) and Maximum Search (`max_search.asm`).<br/>- Authored CPU system integration testbenches (`tb_mips_cpu.v`, `tb_mips_cpu_max.v`, `tb_invalid_instr.v`).<br/>- Authored Prototype Demonstration Video Script (`docs/video_script.md`). | - Section IX: Verification Methodology<br/>- Section X: Simulation & Waveform Analysis | `[Pending Manual Signature]` |

---

## 2. Check of Authorship Alignment

The table above is synchronized with Table II (*Assigned Group Member Responsibilities*) in the official IEEE project report ([report/main.pdf](file:///Users/SarMish/MCA_TEAM_KL3S/report/main.pdf) / [report/main.tex](file:///Users/SarMish/MCA_TEAM_KL3S/report/main.tex)).
