# Team Member Contributions

This project was developed collaboratively by a team of five members. Specific engineering responsibilities and deliverables are distributed as documented below.

> **Note for Academic Evaluation:** The placeholders below should be edited by the team members prior to submission to record their student IDs and official names.

---

## Individual Contribution Breakdown

| Team Member | Role | Assigned Engineering Contributions & Deliverables | Signature / Verification |
|---|---|---|:---:|
| **Member 1**<br/>`[MEMBER 1 FULL NAME]`<br/>ID: `[STUDENT_ID_1]` | **System Architect & Integration Lead** | - Formulated system architecture and top-level integration (`mips_core.v`, `mips_system.v`).<br/>- Coordinated memory bus interfaces and top-level debug observability ports.<br/>- Authored `Makefile` automation rules for simulation, synthesis, and reporting.<br/>- Lead editor for IEEE Project Report Sections 1, 4, 6, 7, and 16. | `[Signature]` |
| **Member 2**<br/>`[MEMBER 2 FULL NAME]`<br/>ID: `[STUDENT_ID_2]` | **Control Unit & Decoder Specialist** | - Designed and implemented `mips_decoder.v` and `alu_control.v`.<br/>- Formulated control truth tables, default combinational assignments, and latch prevention.<br/>- Authored self-checking testbench `testbench/tb_decoder.v`.<br/>- Authored IEEE Project Report Section 10 (Control Unit Design). | `[Signature]` |
| **Member 3**<br/>`[MEMBER 3 FULL NAME]`<br/>ID: `[STUDENT_ID_3]` | **Datapath & ALU Engineer** | - Designed and implemented 32-bit ALU (`alu.v`), Sign Extension (`sign_extend.v`), and Write-Back Logic (`writeback_logic.v`).<br/>- Developed exhaustive unit testbench `testbench/tb_alu.v` covering signed SLT and boundary conditions.<br/>- Conducted Yosys RTL synthesis and cell distribution analysis.<br/>- Authored IEEE Project Report Sections 8, 9, and 11. | `[Signature]` |
| **Member 4**<br/>`[MEMBER 4 FULL NAME]`<br/>ID: `[STUDENT_ID_4]` | **Memory & Register File Engineer** | - Implemented $32 \times 32$ Register File (`register_file.v`) with $zero invariance and reset logic.<br/>- Developed `instruction_memory.v` and `data_memory.v` with bounds and alignment checking.<br/>- Authored testbenches `tb_register_file.v` and `tb_memory.v`.<br/>- Authored IEEE Project Report Sections 11 and 13. | `[Signature]` |
| **Member 5**<br/>`[MEMBER 5 FULL NAME]`<br/>ID: `[STUDENT_ID_5]` | **Verification & Software Tooling Engineer** | - Developed two-pass Python assembler (`tools/assemble.py`) with label and branch offset resolution.<br/>- Authored sample MIPS programs: Array Sum (`array_sum.asm`) and Maximum Search (`max_search.asm`).<br/>- Created master CPU integration testbenches (`tb_mips_cpu.v`, `tb_mips_cpu_max.v`, `tb_invalid_instr.v`).<br/>- Authored Demonstration Video Script (`docs/video_script.md`) and IEEE Report Sections 12 and 14. | `[Signature]` |
