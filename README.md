# Instruction and Data Memory Hierarchy

[![HDL](https://img.shields.io/badge/HDL-Verilog--2001-2563EB.svg)](https://standards.ieee.org/ieee/1364/2048/)
[![Simulator](https://img.shields.io/badge/Simulator-Icarus_Verilog_13-16A34A.svg)](https://steveicarus.github.io/iverilog/)
[![Synthesis](https://img.shields.io/badge/Synthesis-Yosys_0.71-EA580C.svg)](https://yosyshq.net/yosys/)
[![Report](https://img.shields.io/badge/Report-IEEEtran-7E22CE.svg)](report/main.pdf)
[![Regression](https://img.shields.io/badge/Checks-95%2F95_passed-15803D.svg)](reports/simulation_results.md)

Team KL3S implements a simplified Harvard-style memory organization with separate instruction and data paths, integrated into a 32-bit single-cycle educational MIPS processor. The repository includes synthesizable RTL, a shared-memory comparison reference, self-checking testbenches, two complete programs, VCD waveforms, a custom assembler, synthesis evidence, and a compiled IEEE conference-format report.

The Phase I submission deadline is **November 16, 2026 at 11:59 PM IST**.

## What the Project Demonstrates

- Independent 256-word instruction ROM and 256-word data RAM interfaces.
- Simultaneous instruction fetch and data access on separate Harvard paths.
- A single-port, data-priority arbiter as a shared-memory comparison reference.
- Word-alignment and address-bounds detection.
- An 11-instruction MIPS-like subset: ADD, SUB, AND, OR, XOR, SLT, ADDI, LW, SW, BEQ, and J.
- Safe suppression of register and memory writes for invalid instructions.
- End-to-end execution of Array Sum and Maximum Search programs.

The controlled memory trace performs five instruction fetches and two data reads. Separate Harvard paths complete the seven services in five processor cycles; the single shared port needs seven service slots. This is a memory-service comparison, not a whole-program speedup claim.

## Verified Results

| Evidence | Result |
|---|---:|
| Unit, robustness, and hierarchy checks | 91 / 91 passed |
| Program end-state checks | 4 / 4 passed |
| Complete regression | **95 / 95 passed** |
| Array Sum | `[3, 1, 4, 1, 5] -> 14` at byte address 20 |
| Maximum Search | `[7, 2, 11, 4, 9] -> 11` at byte address 20 |
| Observed cycles per program | 39, including three halt-loop samples |
| Yosys core synthesis | 9,002 generic cells, 1,024 flip-flops, 0 latches |

No FPGA board was programmed. No post-layout frequency, timing closure, power, or physical utilization result is claimed.

## Architecture

```text
 Program Counter ---> Instruction Memory ---> Decode / Register File / ALU
       ^                         |                         |
       |                         | instruction             | address + controls
       |                         v                         v
       +----------------- Branch / Jump <----------> Data Memory
                            next PC              independent data path
```

The complete diagrams are in [docs/block_diagram.mmd](docs/block_diagram.mmd) and [docs/datapath_diagram.mmd](docs/datapath_diagram.mmd). The IEEE report includes rendered architecture and memory-service figures.

## Quick Start

### Prerequisites

macOS with Homebrew:

```bash
brew install icarus-verilog yosys tectonic graphviz
```

Ubuntu or Debian:

```bash
sudo apt-get update
sudo apt-get install iverilog yosys graphviz python3 make
```

Install [Tectonic](https://tectonic-typesetting.github.io/en-US/) separately if it is not available from the Linux package repository.

### Run Everything

```bash
make all
```

This assembles both programs, executes the complete regression, runs core synthesis, generates report figures, and compiles `report/main.pdf`.

### Useful Targets

```bash
make assemble         # .asm -> .hex and annotated listings
make test             # all nine self-checking testbenches
make test-hierarchy   # Harvard vs shared-port comparison only
make demo-sum         # Array Sum execution trace
make demo-max         # Maximum Search execution trace
make synth            # generic Yosys synthesis of mips_core
make figures          # report figure generation with Graphviz
make report           # IEEE PDF build with repository-local Tectonic cache
make clean            # remove simulation binaries
```

## Instruction Set

| Instruction | Format | Opcode / Function | Behavior |
|---|:---:|:---:|---|
| ADD | R | `0x00 / 0x20` | `rd = rs + rt` |
| SUB | R | `0x00 / 0x22` | `rd = rs - rt` |
| AND | R | `0x00 / 0x24` | `rd = rs & rt` |
| OR | R | `0x00 / 0x25` | `rd = rs | rt` |
| XOR | R | `0x00 / 0x26` | `rd = rs ^ rt` |
| SLT | R | `0x00 / 0x2A` | signed less-than comparison |
| ADDI | I | `0x08` | `rt = rs + sign_extend(imm)` |
| LW | I | `0x23` | load aligned word from data memory |
| SW | I | `0x2B` | store aligned word to data memory |
| BEQ | I | `0x04` | branch when `rs == rt` |
| J | J | `0x02` | pseudo-direct jump |

Branch delay slots are intentionally omitted.

## Verification Matrix

| Testbench | Scope | Checks |
|---|---|---:|
| `tb_alu.v` | Arithmetic, logic, signed SLT, zero flag | 23 |
| `tb_register_file.v` | Writes, dual reads, reset, `$zero`, debug port | 19 |
| `tb_decoder.v` | Main decoder, ALU control, invalid encodings | 17 |
| `tb_memory.v` | Initialization, reads/writes, alignment, bounds | 12 |
| `tb_memory_hierarchy.v` | Concurrent Harvard service and shared-port contention | 6 |
| `tb_branch_jump.v` | Sequential, branch, and jump next-PC behavior | 8 |
| `tb_invalid_instr.v` | Illegal opcode/function write suppression | 6 |
| `tb_mips_cpu.v` | Array Sum memory and register end state | 2 |
| `tb_mips_cpu_max.v` | Maximum Search memory and register end state | 2 |
| **Total** | | **95** |

Detailed traces are recorded in [reports/simulation_results.md](reports/simulation_results.md). Generated VCD files are explained in [waveforms/README.md](waveforms/README.md).

## Repository Structure

```text
.
├── rtl/                    # processor, memories, and shared-port reference RTL
├── testbench/              # nine self-checking Verilog testbenches
├── programs/               # assembly, hex images, data images, listings
├── tools/assemble.py       # two-pass assembler
├── docs/                   # architecture, verification, video, rubric, sources
├── reports/                # simulation and synthesis evidence
├── waveforms/              # VCD files and GTKWave configuration
├── report/                 # IEEEtran LaTeX source, bibliography, figures, PDF
├── Makefile                # reproducible build and verification targets
└── LICENSE
```

## Phase I Deliverables

- IEEE report: [report/main.pdf](report/main.pdf)
- Editable report source: [report/main.tex](report/main.tex)
- Research source register: [docs/research_sources.md](docs/research_sources.md)
- Prototype video script: [docs/video_script.md](docs/video_script.md)
- Video link: **pending team recording and upload**
- Rubric checklist: [docs/evaluation_checklist.md](docs/evaluation_checklist.md)
- Contribution template: [docs/team_contributions.md](docs/team_contributions.md)

## Team

| Member | Enrolment Number | Email | Individual Contribution |
|---|---|---|---|
| Sarthak Mishra | `2401010421` | `sarthak.mishra2024@nst.rishihood.edu.in` | |
| Shitanshu Tiwari | `2401010440` | `shitanshu.tiwari2024@nst.rishihood.edu.in` | |
| Shane Joseph | `2401020062` | `Shane.2024@nst.rishihood.edu.in` | |
| Lakshay Yadav | `2401010250` | `Lakshay.yadav2024@nst.rishihood.edu.in` | |
| Kshitiz Surana | `2401010242` | `kshitiz.2024@nst.rishihood.edu.in` | |

Individual contributions are intentionally blank for the team to complete. The instructor will review Git history, so every member should make meaningful commits from their own GitHub account before submission. Do not fabricate or rewrite contribution history.

## Before Submission

- Complete the contribution table in the report and `docs/team_contributions.md`.
- Ensure all five members have meaningful, attributable Git commits.
- Record a video shorter than five minutes and introduce all five members by name.
- Show the project idea, block diagram, RTL, `make test-hierarchy`, a full program demo, and waveform evidence.
- Upload the video and replace the pending link in the README and video script.
- Run `make all` from a clean checkout and confirm `95 / 95` checks pass.
- Submit the repository URL and confirm `report/main.pdf` opens correctly.

*Minor edit by Lakshay*