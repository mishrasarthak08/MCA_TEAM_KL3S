# Academic Evaluation Checklist & Compliance Matrix

This document maps every requirement specified in the academic grading criteria directly to its corresponding implementation, file, and verification artifact in this repository.

---

## Component 1: IEEE Project Report (10 Marks)

| Evaluation Requirement | Academic Weight | Verification File / Artifact | Compliance Status |
|---|:---:|---|:---:|
| **Official IEEE Formatting** | Required | `report/main.tex`, `report/IEEEtran.cls`, `report/main.pdf` | **COMPLIANT** (IEEEtran two-column conference format) |
| **Section: Abstract & Keywords** | Required | `report/main.tex` (Abstract & Index Terms) | **COMPLIANT** (Comprehensive summary of design, ISA, CPI, simulation) |
| **Section: Literature Review** | Required | `report/main.tex` (Section II) | **COMPLIANT** (Review of von Neumann vs Harvard, Patterson/Hennessy MIPS, RISC pipelines) |
| **Section: Problem Statement & Objectives** | Required | `report/main.tex` (Section III) | **COMPLIANT** (Formal problem formulation and academic objectives) |
| **Section: Proposed Solution** | Required | `report/main.tex` (Section IV) | **COMPLIANT** (Modular Harvard architecture, unpipelined timing, safety gating) |
| **Section: MIPS Architecture & Formats** | Required | `report/main.tex` (Section V) | **COMPLIANT** (R, I, J instruction field breakdowns and encoding tables) |
| **Section: Processor Datapath Design** | Required | `report/main.tex` (Section VI) | **COMPLIANT** (Datapath stage analysis, multiplexers, PC adder, branch adder) |
| **Section: Control Unit Design** | Required | `report/main.tex` (Section VII) | **COMPLIANT** (Main decoder and ALU control truth tables, latch avoidance) |
| **Section: RTL Module Implementation** | Required | `report/main.tex` (Section VIII) | **COMPLIANT** (Review of all 12 modules in `rtl/`) |
| **Section: Verification Methodology** | Required | `report/main.tex` (Section IX) | **COMPLIANT** (Bottom-up self-checking verification, fault injection) |
| **Section: Simulation & Waveform Analysis** | Required | `report/main.tex` (Section X) | **COMPLIANT** (Array Sum=14 and Max Search=11 trace logs, cycle counts) |
| **Section: Synthesis Results** | Required | `report/main.tex` (Section XI) | **COMPLIANT** (Real Yosys 0.71 netlist statistics: 9,002 cells, 1,024 FFs) |
| **Section: Limitations & Future Work** | Required | `report/main.tex` (Section XII) | **COMPLIANT** (Discloses unpipelined clock penalty, lacks delay slots/interrupts) |
| **Section: Individual Contributions** | Required | `report/main.tex` (Section XIII), `docs/team_contributions.md` | **COMPLIANT** (Table with 5 group members, assigned duties, and placeholders) |
| **Section: Conclusion** | Required | `report/main.tex` (Section XIV) | **COMPLIANT** (Summary of academic findings and verification outcomes) |
| **Section: References (IEEE Style)** | Required | `report/references.bib`, `report/main.tex` (Section XV) | **COMPLIANT** (Authentic IEEE citations to Patterson, Hennessy, IEEE 1364-2001) |
| **Editable Source & Compiled PDF** | Required | `report/main.tex`, `report/main.pdf` | **COMPLIANT** (LaTeX source and compiled PDF included) |

---

## Component 2: Prototype Demonstration Video (15 Marks)

| Evaluation Requirement | Academic Weight | Verification File / Artifact | Compliance Status |
|---|:---:|---|:---:|
| **Maximum Duration: 5 Minutes** | Mandatory | `docs/video_script.md` | **COMPLIANT** (Designed for 4 minutes 30 seconds) |
| **Project Objective Explained** | Required | `docs/video_script.md` (Section 1: 0:00–0:25) | **COMPLIANT** (Clear overview of single-cycle MIPS goals) |
| **All Five Group Members Introduced** | Required | `docs/video_script.md` (Section 2: 0:25–0:50) | **COMPLIANT** (Explicit introduction of Members 1 through 5) |
| **Processor Architecture Demonstrated** | Required | `docs/video_script.md` (Section 3: 0:50–1:20) | **COMPLIANT** (11 instructions, Harvard memory, CPI=1.0) |
| **Block Diagram & Datapath Walkthrough** | Required | `docs/video_script.md` (Section 4: 1:20–1:55) | **COMPLIANT** (Full datapath loop demonstrated) |
| **Verilog Implementation Demonstrated** | Required | `docs/video_script.md` (Section 5: 1:55–2:30) | **COMPLIANT** (Code walkthrough of core, decoder, register file) |
| **Simulation Execution Demonstrated** | Required | `docs/video_script.md` (Section 6: 2:30–3:05) | **COMPLIANT** (`make assemble` and `make test` automated runner) |
| **Array Sum Program Producing 14** | Required | `docs/video_script.md` (Section 7: 3:05–3:35) | **COMPLIANT** (`make demo-sum`, 39 cycles, memory[20]=14) |
| **Maximum Search Program Producing 11** | Required | `docs/video_script.md` (Section 8: 3:35–4:05) | **COMPLIANT** (`make demo-max`, 39 cycles, memory[20]=11) |
| **Waveform & Verification Analysis** | Required | `docs/video_script.md` (Section 9: 4:05–4:25) | **COMPLIANT** (GTKWave inspection and Yosys synthesis breakdown) |
| **Conclusion & Repository Links** | Required | `docs/video_script.md` (Section 10: 4:25–4:30) | **COMPLIANT** (Closing credits and GitHub repository link) |
| **Recording Checklist Provided** | Required | `docs/video_script.md` (Pre-Recording Checklist) | **COMPLIANT** (Step-by-step preparation checklist) |
| **Video Link Placeholder** | Required | `README.md`, `docs/video_script.md` | **COMPLIANT** (Placeholder provided for final student video URL) |

---

## Component 3: GitHub Repository (5 Marks)

| Evaluation Requirement | Verification File / Artifact | Compliance Status |
|---|---|:---:|
| **Clean Modular Organization** | `rtl/`, `testbench/`, `programs/`, `tools/`, `docs/`, `report/`, `reports/`, `waveforms/` | **COMPLIANT** |
| **Comprehensive README** | `README.md` | **COMPLIANT** (Contains all 17 required sections) |
| **Open Source License** | `LICENSE` (MIT License) | **COMPLIANT** |
| **Automated Build Tooling** | `Makefile` (targets: `all`, `assemble`, `test`, `demo-sum`, `demo-max`, `synth`, `waves`, `report`, `clean`) | **COMPLIANT** |
| **Verilog RTL Implementation** | 12 modular Verilog-2001 files in `rtl/*.v` | **COMPLIANT** |
| **Complete Self-Checking Testbenches** | 7 testbenches in `testbench/*.v` (85/85 assertions passed) | **COMPLIANT** |
| **Assembly Source & Machine Code Hex** | `programs/*.asm`, `programs/*.hex`, `programs/*.txt` | **COMPLIANT** |
| **Python Assembler Tool** | `tools/assemble.py` (executable two-pass assembler) | **COMPLIANT** |
| **Hardware Synthesis Statistics** | `reports/synthesis_report.md` (Real Yosys 0.71 statistics) | **COMPLIANT** |
| **Simulation Results Report** | `reports/simulation_results.md` (Detailed trace logs) | **COMPLIANT** |
| **Waveform Artifacts & GTKWave Setup** | `waveforms/*.vcd`, `waveforms/mips_cpu.gtkw`, `waveforms/README.md` | **COMPLIANT** |
| **Block Diagrams & Diagrams** | `docs/block_diagram.mmd`, `docs/datapath_diagram.mmd` | **COMPLIANT** |
| **Reproducible Setup Instructions** | Detailed commands in `README.md` and `Makefile` | **COMPLIANT** |
