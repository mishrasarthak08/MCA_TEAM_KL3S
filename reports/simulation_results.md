# Simulation and Verification Results

Toolchain used for the reproduced run:

- Icarus Verilog 13.0
- `vvp` simulation runtime
- Python 3.14 assembler invocation

## Regression Summary

| Category | Passed | Failed |
|---|---:|---:|
| Unit, robustness, and memory-architecture checks | 91 | 0 |
| Full-program end-state checks | 4 | 0 |
| **Total** | **95** | **0** |

## Testbench Results

| Testbench | Target | Checks | Result | VCD |
|---|---|---:|:---:|---|
| `tb_alu.v` | `alu.v` | 23 | Pass | `tb_alu.vcd` |
| `tb_register_file.v` | `register_file.v` | 19 | Pass | `tb_register_file.vcd` |
| `tb_decoder.v` | decoders | 17 | Pass | `tb_decoder.vcd` |
| `tb_memory.v` | instruction/data memories | 12 | Pass | `tb_memory.vcd` |
| `tb_memory_hierarchy.v` | Harvard paths and shared arbiter | 6 | Pass | `tb_memory_hierarchy.vcd` |
| `tb_branch_jump.v` | next-PC logic | 8 | Pass | `tb_branch_jump.vcd` |
| `tb_invalid_instr.v` | invalid instruction gating | 6 | Pass | `tb_invalid_instr.vcd` |
| `tb_mips_cpu.v` | Array Sum system | 2 | Pass | `mips_cpu_array_sum.vcd` |
| `tb_mips_cpu_max.v` | Maximum Search system | 2 | Pass | `mips_cpu_max_search.vcd` |

## Harvard and Shared-Port Comparison

The memory-hierarchy test uses a five-cycle logical trace:

| Cycle | Instruction Fetch | Data Read | Harvard Services |
|---:|:---:|:---:|---:|
| 1 | Yes | No | 1 |
| 2 | Yes | Yes | 2 |
| 3 | Yes | No | 1 |
| 4 | Yes | Yes | 2 |
| 5 | Yes | No | 1 |
| **Total** | **5** | **2** | **7 services in 5 cycles** |

The single-port reference grants at most one request per service slot, so the same seven requests require seven slots. A blocked instruction request is held until the data request releases the port.

This microbenchmark isolates port contention. It does not execute either full program on a unified-memory processor and therefore does not establish a whole-program speedup.

## Program 1: Array Sum

- Program image: `programs/array_sum.hex` (13 instructions)
- Data image: `[3, 1, 4, 1, 5, 0]`
- Result address: byte address 20, word index 5
- Observed result: `0x0000000E` (14)
- Register `$s0`: `0x0000000E` (14)
- Observed cycles: 39, including three halt-loop samples

Key events:

| Cycle | PC | Event |
|---:|---:|---|
| 30 | `0x18` | Final addition updates `$s0` to 14 |
| 34 | `0x10` | `BEQ` takes the exit branch |
| 36 | `0x2C` | `SW` stores 14 at byte address 20 |
| 37–39 | `0x30` | terminal jump loop sampled |

## Program 2: Maximum Search

- Program image: `programs/max_search.hex` (16 instructions)
- Data image: `[7, 2, 11, 4, 9, 0]`
- Result address: byte address 20, word index 5
- Observed result: `0x0000000B` (11)
- Register `$s0`: `0x0000000B` (11)
- Observed cycles: 39, including three halt-loop samples

Key events:

| Cycle | PC | Event |
|---:|---:|---|
| 16 | `0x24` | maximum candidate updates to 11 |
| 36 | `0x38` | `SW` stores 11 at byte address 20 |
| 37–39 | `0x3C` | terminal jump loop sampled |

## Reproduction

```bash
make test
```

The run is successful only if every bench prints a passing summary and `make` exits with status zero.
