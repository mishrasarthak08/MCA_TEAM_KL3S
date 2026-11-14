# Academic Evaluation Checklist & Compliance Matrix

This document maps every requirement specified in the academic grading criteria directly to its corresponding implementation, file, and verification artifact in this repository.

---

## 1. Rubric Compliance Matrix

### Component 1: IEEE Project Report (10 Marks)

| Evaluation Requirement | Academic Weight | Verification File / Artifact | Compliance Status |
|---|:---:|---|:---:|
| **Official IEEE Formatting** | Required | `report/main.tex`, `report/main.pdf` | **COMPLIANT** (`\documentclass[conference]{IEEEtran}`, two-column layout, standard IEEE headings) |
| **Section: Abstract & Keywords** | Required | `report/main.tex` (Abstract & IEEE Keywords) | **COMPLIANT** (Summary of single-cycle datapath, ISA, CPI, simulation) |
| **Section: Literature Review** | Required | `report/main.tex` (Section II) | **COMPLIANT** (Patterson/Hennessy, Kane/Heinrich MIPS, RISC principles, EDA tools) |
| **Section: Problem Statement & Objectives** | Required | `report/main.tex` (Section III) | **COMPLIANT** (Formal problem formulation and academic objectives) |
| **Section: Proposed Solution** | Required | `report/main.tex` (Section IV) | **COMPLIANT** (Modular Harvard architecture, unpipelined timing, safety gating) |
| **Section: MIPS Architecture & Formats** | Required | `report/main.tex` (Section V) | **COMPLIANT** (R, I, J instruction field breakdowns and encoding tables) |
| **Section: Processor Datapath Design** | Required | `report/main.tex` (Section VI) | **COMPLIANT** (Datapath stage analysis, multiplexers, PC adder, branch adder) |
| **Section: Control Unit Design** | Required | `report/main.tex` (Section VII) | **COMPLIANT** (Main decoder and ALU control truth tables, latch avoidance) |
| **Section: RTL Module Implementation** | Required | `report/main.tex` (Section VIII) | **COMPLIANT** (Review of all 12 modules in `rtl/` under IEEE Std 1364-2001) |
| **Section: Verification Methodology** | Required | `report/main.tex` (Section IX) | **COMPLIANT** (Bottom-up self-checking verification, fault injection) |
| **Section: Simulation & Waveform Analysis** | Required | `report/main.tex` (Section X) | **COMPLIANT** (Array Sum=14 and Max Search=11 trace logs, cycle counts) |
| **Section: Synthesis Results** | Required | `report/main.tex` (Section XI) | **COMPLIANT** (Real Yosys 0.71 netlist statistics: 9,002 cells, 1,024 FFs, 0 latches) |
| **Section: Limitations & Future Work** | Required | `report/main.tex` (Section XIII) | **COMPLIANT** (Discloses unpipelined clock penalty, lacks delay slots/interrupts) |
| **Section: Individual Contributions** | Required | `report/main.tex` (Section XII), `docs/team_contributions.md` | **COMPLIANT** (Table with 5 group members, assigned duties, and placeholders) |
| **Section: Conclusion** | Required | `report/main.tex` (Section XIV) | **COMPLIANT** (Summary of academic findings and verification outcomes) |
| **Section: References (IEEE Style)** | Required | `report/references.bib`, `report/main.tex` | **COMPLIANT** (Authentic IEEE citations to Patterson, Kane, IEEE 1364, Williams, Wolf) |
| **Editable Source & Compiled PDF** | Required | `report/main.tex`, `report/main.pdf` | **COMPLIANT** (Compiled via Tectonic, 0 errors, 0 overfull hboxes) |

---

### Component 2: Prototype Demonstration Video (15 Marks)

| Evaluation Requirement | Academic Weight | Verification File / Artifact | Compliance Status |
|---|:---:|---|:---:|
| **Maximum Duration: 5 Minutes** | Mandatory | `docs/video_script.md` | **COMPLIANT** (Scripted for 4 minutes 30 seconds) |
| **Project Objective Explained** | Required | `docs/video_script.md` (Segment 1: 0:00–0:25) | **COMPLIANT** (Clear overview of single-cycle MIPS goals) |
| **All Five Group Members Introduced** | Required | `docs/video_script.md` (Segment 2: 0:25–0:50) | **COMPLIANT** (Explicit introduction of Members 1 through 5) |
| **Processor Architecture Demonstrated** | Required | `docs/video_script.md` (Segment 3: 0:50–1:15) | **COMPLIANT** (11 instructions, Harvard memory, CPI=1.0) |
| **Block Diagram & Datapath Walkthrough** | Required | `docs/video_script.md` (Segment 4: 1:15–1:45) | **COMPLIANT** (Full datapath loop demonstrated) |
| **Verilog Implementation Demonstrated** | Required | `docs/video_script.md` (Segment 5: 1:45–2:15) | **COMPLIANT** (Code walkthrough of core, decoder, register file) |
| **Simulation Execution Demonstrated** | Required | `docs/video_script.md` (Segment 6: 2:15–2:45) | **COMPLIANT** (`make assemble` and `make test` automated runner) |
| **Array Sum Program Producing 14** | Required | `docs/video_script.md` (Segment 7: 2:45–3:15) | **COMPLIANT** (`make demo-sum`, 39 cycles, memory[20]=14) |
| **Maximum Search Program Producing 11** | Required | `docs/video_script.md` (Segment 8: 3:15–3:45) | **COMPLIANT** (`make demo-max`, 39 cycles, memory[20]=11) |
| **Waveform & Verification Analysis** | Required | `docs/video_script.md` (Segment 9: 3:45–4:10) | **COMPLIANT** (GTKWave inspection and Yosys synthesis breakdown) |
| **Conclusion & Repository Links** | Required | `docs/video_script.md` (Segment 10: 4:10–4:30) | **COMPLIANT** (Closing credits and GitHub repository link) |
| **Pre-Recording Checklist Provided** | Required | `docs/video_script.md` (Checklist section) | **COMPLIANT** (Screen sharing and terminal instructions provided) |
| **Video Link Placeholder** | Required | `README.md`, `docs/video_script.md` | **PENDING TEAM ACTION** (Video must be recorded by the human team) |

---

### Component 3: GitHub Repository (5 Marks)

| Evaluation Requirement | Verification File / Artifact | Compliance Status |
|---|---|:---:|
| **Clean Modular Organization** | `rtl/`, `testbench/`, `programs/`, `tools/`, `docs/`, `report/`, `reports/`, `waveforms/` | **COMPLIANT** |
| **Comprehensive README** | `README.md` | **COMPLIANT** (Covers all 17 specification items) |
| **Open Source License** | `LICENSE` (MIT License) | **COMPLIANT** |
| **Automated Build Tooling** | `Makefile` (targets: `all`, `assemble`, `test`, `demo-sum`, `demo-max`, `synth`, `report`, `clean`) | **COMPLIANT** |
| **Verilog RTL Implementation** | 12 modular Verilog-2001 files in `rtl/*.v` | **COMPLIANT** |
| **Complete Self-Checking Testbenches** | 7 testbenches in `testbench/*.v` (85/85 assertions passed) | **COMPLIANT** |
| **Assembly Source & Machine Code Hex** | `programs/*.asm`, `programs/*.hex`, `programs/*_listing.txt` | **COMPLIANT** |
| **Python Assembler Tool** | `tools/assemble.py` (executable two-pass assembler) | **COMPLIANT** |
| **Hardware Synthesis Statistics** | `reports/synthesis_report.md` (Real Yosys 0.71 statistics on `mips_core`) | **COMPLIANT** |
| **Simulation Results Report** | `reports/simulation_results.md` (Detailed trace logs) | **COMPLIANT** |
| **Waveform Artifacts & GTKWave Setup** | `waveforms/*.vcd`, `waveforms/mips_cpu.gtkw`, `waveforms/README.md` | **COMPLIANT** |
| **Block Diagrams & Diagrams** | `docs/block_diagram.mmd`, `docs/datapath_diagram.mmd` | **COMPLIANT** |
| **Reproducible Setup Instructions** | Detailed commands in `README.md` and `Makefile` | **COMPLIANT** |

---

## 2. Summary of Pending Manual Submission Tasks

The following tasks require personal inputs or physical actions from the student group:
1. **Enter Student Names & IDs:** Fill in placeholders `[Author X]` and `[ID_X]` in `report/main.tex`, `docs/team_contributions.md`, and `README.md`.
2. **Record the Prototype Video:** Follow the script in `docs/video_script.md` using screen recording software (target: 4m30s).
3. **Upload the Video:** Upload the recorded MP4 to YouTube (as Unlisted/Public) or Google Drive (accessible to evaluators).
4. **Update Video URL:** Replace the placeholder `https://youtu.be/[REPLACE_WITH_YOUR_UNLISTED_DEMO_VIDEO_ID]` in `README.md`, `docs/video_script.md`, and `report/main.tex`.
5. **Academic Portal Submission:** Submit the GitHub repository URL and `report/main.pdf` according to the instructor's submission portal.
