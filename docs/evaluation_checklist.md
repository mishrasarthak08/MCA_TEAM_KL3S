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
| Individual contributions | report table and `docs/team_contributions.md` | Ready |
| References | five verifiable sources with URLs | Ready |
| PDF render review | three Letter-size pages, visually inspected | Ready |

## Prototype Video

| Requirement | Evidence | Status |
|---|---|:---:|
| Duration below five minutes | `mca video.mp4` (4:30 duration, < 5:00 limit) | Ready |
| Project idea stated | opening segment | Ready |
| All five names introduced | team introduction segment | Ready |
| Working prototype demonstrated | regression, comparison, demos, waveforms | Ready |
| Uploaded video link | `mca video.mp4` in repo and Google Drive mirror | Ready |

## GitHub Repository

| Requirement | Evidence | Status |
|---|---|:---:|
| Report included | `report/main.pdf` | Ready |
| Prototype files included | `rtl/`, `testbench/`, `programs/`, `tools/` | Ready |
| Relevant artifacts included | `docs/`, `reports/`, `waveforms/` | Ready |
| Reproducible verification | `make all` | Ready |
| All five members contribute meaningfully | Git history (multi-member commits on `main`) | Ready |

## Reproduced Technical Evidence

- Icarus Verilog 13.0: 95 / 95 checks passed across nine testbenches.
- Memory comparison: seven services completed in five Harvard cycles versus seven single-port slots.
- Program 1: Array Sum stored 14 at byte address 20.
- Program 2: Maximum Search stored 11 at byte address 20.
- Yosys 0.71: 9,002 generic cells, 1,024 flip-flops, and zero inferred latches for `mips_core`.
- Tectonic 0.17: IEEE PDF compiled successfully.

## Verification Checklist Before Presentation

1. Confirm `make all` succeeds from clean state (`95 / 95` checks passed).
2. Open `report/main.pdf` to verify rendering of text and figures.
3. Confirm `mca video.mp4` plays cleanly with audio.
4. Have terminal open with `make test`, `make test-hierarchy`, `make demo-sum`, and `make demo-max` ready to demonstrate live.
