# RTL Synthesis Report

## Configuration

- Synthesis engine: Yosys 0.71+post
- HDL: Verilog-2001
- Top module: `mips_core`
- Target: generic, technology-independent primitives
- Command: `make synth`

The synthesis boundary includes the processor core and its datapath/control submodules. Instruction memory, data memory, `mips_system`, and the shared-memory comparison arbiter are outside the selected hierarchy.

## Reproduced Statistics

| Module | Generic Cells |
|---|---:|
| `register_file` | 7,530 |
| `alu` | 904 |
| `branch_jump_logic` | 349 |
| `alu_control` | 66 |
| `mips_decoder` | 43 |
| `writeback_logic` | 37 |
| `program_counter` | 32 |
| `sign_extend` | 0 |
| `mips_core` local glue | 41 |
| **Hierarchy total** | **9,002** |

## Primitive Breakdown

| Primitive | Count |
|---|---:|
| `$_DFFE_PP0P_` | 1,024 |
| `$_MUX_` | 365 |
| `$_AND_` | 3,547 |
| `$_OR_` | 3,630 |
| `$_XOR_` | 216 |
| `$_NOT_` | 220 |
| **Total** | **9,002** |

The 1,024 sequential elements are 992 register-file bits for registers 1–31 plus 32 program-counter bits. Register 0 is implemented as a constant-zero read with writes suppressed.

## Diagnostics

Yosys reports one expected warning when the multi-read register array is lowered to registers. No unintended latches are inferred. The result is a generic netlist, not a placed-and-routed device implementation.

## Scope and Limitations

- No FPGA part or standard-cell library was targeted.
- No block-RAM inference result is reported because memories are outside `mips_core`.
- No static timing analysis was run.
- No maximum frequency, LUT count, power figure, or silicon area is claimed.
- No FPGA board was programmed.

Any device-specific estimate requires a selected target, constraints, technology mapping, place-and-route, and timing analysis.
