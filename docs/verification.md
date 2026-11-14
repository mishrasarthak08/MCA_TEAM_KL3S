# Verification Plan and Results

## Strategy

Verification is layered from individual units to complete programs:

1. Unit tests cover the ALU, register file, decoders, memories, and next-PC logic.
2. Robustness tests inject invalid instructions and invalid memory accesses.
3. The hierarchy comparison exercises simultaneous Harvard reads and shared-port contention.
4. System tests execute two assembled programs and inspect architectural end state.
5. Every bench is self-checking and terminates with `$fatal` on failure.

## Test Matrix

| Testbench | Scope | Checks | Result |
|---|---|---:|:---:|
| `tb_alu.v` | Arithmetic, logic, signed comparisons, zero flag | 23 | Pass |
| `tb_register_file.v` | Writes, dual reads, reset, `$zero`, debug read | 19 | Pass |
| `tb_decoder.v` | Opcode and ALU-function decoding | 17 | Pass |
| `tb_memory.v` | Initialization, alignment, bounds, reads, writes | 12 | Pass |
| `tb_memory_hierarchy.v` | Harvard concurrency and shared-port arbitration | 6 | Pass |
| `tb_branch_jump.v` | PC+4, forward/backward branch, jump priority | 8 | Pass |
| `tb_invalid_instr.v` | Illegal opcode/function write suppression | 6 | Pass |
| `tb_mips_cpu.v` | Array Sum result in memory and `$s0` | 2 | Pass |
| `tb_mips_cpu_max.v` | Maximum Search result in memory and `$s0` | 2 | Pass |
| **Total** | | **95** | **Pass** |

## Memory Architecture Comparison

The comparison trace contains five instruction fetches and two data reads.

- Harvard paths: seven services across five processor cycles because two cycles service instruction and data together.
- Single shared port: seven service slots because at most one request is granted per slot.
- Observed difference: two fewer service slots for the Harvard organization in this controlled trace.

The comparison does not claim a whole-program performance improvement. A functional unified-memory processor would require a multi-cycle controller, a multi-ported memory, or another mechanism for resolving conflicts.

## Program Results

| Program | Input | Expected | Observed | Cycles |
|---|---|---:|---:|---:|
| Array Sum | `[3, 1, 4, 1, 5]` | 14 | 14 | 39 |
| Maximum Search | `[7, 2, 11, 4, 9]` | 11 | 11 | 39 |

The cycle count includes three observations of each program's terminal self-loop.

## Waveforms

All benches write VCD files to `waveforms/`. Use:

```bash
gtkwave waveforms/mips_cpu_array_sum.vcd waveforms/mips_cpu.gtkw
```

The VCD files are supporting evidence for signal inspection; the pass/fail decision comes from explicit self-checks in the testbenches.
