# Phase I Submission Readiness

Deadline: **November 16, 2026 at 11:59 PM IST**

## IEEE Project Report

| Requirement | Evidence | Status |
|---|---|:---:|
| IEEE conference format | `report/main.tex`, `report/main.pdf` | Ready |
| Abstract | `report/main.tex` | Ready |
| Literature review | `report/main.tex`, `report/references.bib`, `docs/research_sources.md` | Ready |
| Proposed solution | `report/main.tex` | Ready |
| Block diagram | `report/figures/harvard_architecture.png` | Ready |
| Simulation evidence | `reports/simulation_results.md`, `waveforms/*.vcd` | Ready |
| Shared-memory comparison | `rtl/shared_memory_arbiter.v`, `tb_memory_hierarchy.v` | Ready |
| Individual contributions | report table and `docs/team_contributions.md` | **Team action** |
| References | five verifiable sources with URLs | Ready |
| PDF render review | three Letter-size pages, visually inspected | Ready |

## Prototype Video

| Requirement | Evidence | Status |
|---|---|:---:|
| Duration below five minutes | `docs/video_script.md` targets 4:30 | Script ready |
| Project idea stated | opening segment | Script ready |
| All five names introduced | team introduction segment | Script ready |
| Working prototype demonstrated | regression, comparison, demos, waveforms | Script ready |
| Uploaded video link | README and script | **Team action** |

## GitHub Repository

| Requirement | Evidence | Status |
|---|---|:---:|
| Report included | `report/main.pdf` | Ready |
| Prototype files included | `rtl/`, `testbench/`, `programs/`, `tools/` | Ready |
| Relevant artifacts included | `docs/`, `reports/`, `waveforms/` | Ready |
| Reproducible verification | `make all` | Ready |
| All five members contribute meaningfully | Git history | **Critical team action** |

## Reproduced Technical Evidence

- Icarus Verilog 13.0: 95 / 95 checks passed across nine testbenches.
- Memory comparison: seven services completed in five Harvard cycles versus seven single-port slots.
- Program 1: Array Sum stored 14 at byte address 20.
- Program 2: Maximum Search stored 11 at byte address 20.
- Yosys 0.71: 9,002 generic cells, 1,024 flip-flops, and zero inferred latches for `mips_core`.
- Tectonic 0.17: IEEE PDF compiled successfully.

## Remaining Actions

1. Fill the individual-contribution entries with accurate, interview-ready descriptions.
2. Have every member make meaningful commits from their own account. The repository currently needs multi-member history before it satisfies that part of the rubric.
3. Record and upload the prototype video, then replace the pending link.
4. Run `make all` from a clean checkout and review the generated PDF and VCD files.
5. Submit the repository URL through the instructor's Google Form.
