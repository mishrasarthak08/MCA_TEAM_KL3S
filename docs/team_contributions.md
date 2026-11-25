# Individual Contributions

Complete this document before the final submission. Describe work that each member actually performed and can explain during the interview. Keep the entries consistent with the IEEE report and Git history.

| Member | Enrolment Number | Individual Contribution | Files or Evidence | Commit or Pull Request Links |
|---|---|---|---|---|
| Sarthak Mishra | `2401010421` | Lead System Architect, top-level core & SoC integration, two-pass Python assembler development, benchmark program design (Array Sum & Max Search), Makefile automation, documentation lead. | `rtl/mips_core.v`, `rtl/mips_system.v`, `tools/assemble.py`, `programs/array_sum.asm`, `programs/max_search.asm`, `Makefile` | Commits `c6be325`, `41bf5a4`, `8bbcb7f` |
| Shitanshu Tiwari | `2401010440` | Control Unit Specialist; designed and verified main instruction decoder and ALU control logic, formulated control truth tables, eliminated latches via default combinational assignments, authored decoder testbench. | `rtl/mips_decoder.v`, `rtl/alu_control.v`, `testbench/tb_decoder.v` (17 checks) | Commits `c6be325`, `41bf5a4` |
| Shane Joseph | `2401020062` | Memory Hierarchy & Verification Lead; designed shared-memory comparison arbiter, authored memory hierarchy testbench (95/95 checks), created Harvard vs. shared-port architecture diagrams, completed Phase I IEEE report update. | `rtl/shared_memory_arbiter.v`, `testbench/tb_memory_hierarchy.v`, `report/figures/`, `report/main.tex` | Commits `fa351a8`, `c6be325` |
| Lakshay Yadav | `2401010250` | Memory Subsystems & Branch/Jump Logic; implemented 32x32-bit register file with $zero invariance, Harvard instruction/data memories with alignment/bounds safety, branch/jump target logic, authored memory & RF unit testbenches. | `rtl/register_file.v`, `rtl/instruction_memory.v`, `rtl/data_memory.v`, `rtl/branch_jump_logic.v`, `testbench/tb_register_file.v`, `testbench/tb_memory.v` | Commits `3f5839d`, `c6be325` |
| Kshitiz Surana | `2401010242` | Datapath Execution & Synthesis Specialist, Prototype Video Lead; implemented 32-bit ALU with signed comparison, sign extension, writeback logic, ALU testbench (23 checks), Yosys generic cell synthesis, recorded & added demonstration video. | `rtl/alu.v`, `rtl/sign_extend.v`, `rtl/writeback_logic.v`, `testbench/tb_alu.v`, `reports/synthesis_report.md`, `mca video.mp4` | Commits `85d678f`, `c6be325` |

## Completion Rules

- Record only genuine work performed by the named member.
- Use concrete descriptions such as a module, testbench, analysis, diagram, or report section.
- Link evidence where possible.
- Make sure every member can explain both their own contribution and the complete system.
- Do not backdate, fabricate, or rewrite Git history to simulate participation.

## Sign-Off

| Member | Confirmed Accurate | Date |
|---|:---:|---|
| Sarthak Mishra | Yes | 16-Nov-2026 |
| Shitanshu Tiwari | Yes | 16-Nov-2026 |
| Shane Joseph | Yes | 16-Nov-2026 |
| Lakshay Yadav | Yes | 16-Nov-2026 |
| Kshitiz Surana | Yes | 16-Nov-2026 |
