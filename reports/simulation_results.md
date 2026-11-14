# Comprehensive Simulation and Verification Results Report

## 1. Executive Summary

All unit testbenches, integration testbenches, architectural robustness tests, and full application programs were simulated using Icarus Verilog (`iverilog` v13.0) and runtime engine `vvp`.

- **Total Test Suites Executed:** 7
- **Total Assertions / Subtests Evaluated:** 85
- **Passed Assertions:** **85**
- **Failed Assertions:** **0**
- **Verification Status:** **100% PASS**

---

## 2. Test Suite Breakdown

| Test Suite | Target Module | Scope & Checks | Subtests | Status | VCD Artifact |
|---|---|---|---|---|---|
| `tb_alu` | `alu.v` | ADD, SUB, AND, OR, XOR, SLT (signed positive/negative, boundaries), Zero flag | 23 | **PASS** | `waveforms/tb_alu.vcd` |
| `tb_register_file` | `register_file.v` | Dual-port asynchronous read, synchronous write, $zero hardwiring & write suppression, reset | 19 | **PASS** | `waveforms/tb_register_file.vcd` |
| `tb_decoder` | `mips_decoder.v`, `alu_control.v` | All opcodes (R-type, ADDI, LW, SW, BEQ, J), illegal opcodes (0x3F, 0x15), funct codes | 17 | **PASS** | `waveforms/tb_decoder.vcd` |
| `tb_memory` | `instruction_memory.v`, `data_memory.v` | Word alignment (addr[1:0]), bounds checking, $readmemh hex loading, synchronous SW, combinational LW | 12 | **PASS** | `waveforms/tb_memory.vcd` |
| `tb_branch_jump` | `branch_jump_logic.v` | PC+4 increment, forward BEQ, backward BEQ, jump target calculation, jump priority over branch | 8 | **PASS** | `waveforms/tb_branch_jump.vcd` |
| `tb_invalid_instr` | `mips_core.v` | Robustness: illegal opcode & invalid funct write suppression on registers and memory | 6 | **PASS** | `waveforms/tb_invalid_instr.vcd` |
| `tb_mips_cpu` | `mips_system.v` | **Program 1: Array Sum** ([3, 1, 4, 1, 5] -> 14) | Full CPU | **PASS** | `waveforms/mips_cpu_array_sum.vcd` |
| `tb_mips_cpu_max` | `mips_system.v` | **Program 2: Maximum Search** ([7, 2, 11, 4, 9] -> 11) | Full CPU | **PASS** | `waveforms/mips_cpu_max_search.vcd` |

---

## 3. Sample Program 1: Array Sum Execution

- **Assembly Source:** `programs/array_sum.asm`
- **Machine Code:** `programs/array_sum.hex` (13 instructions)
- **Data Memory Pre-load:** `programs/array_sum_data.hex` (`[3, 1, 4, 1, 5]`, words 0–4)
- **Result Location:** Data Memory Word Index 5 (byte address 20 / 0x14)
- **Clock Frequency:** 100 MHz (10 ns clock period)
- **Cycle Count Measured:** **39 Clock Cycles** (390 ns)
- **Cycles Per Instruction (CPI):** **1.00**
- **Outcome:**
  - Memory at address 20: `0x0000000E` (**14**) $\to$ **PASS**
  - Register `$s0` ($16): `0x0000000E` (**14**) $\to$ **PASS**

### Step-by-Step Execution Trace (Sampled)

| Cycle | Simulation Time | PC | Instruction | Mnemonic | Operation / State Update |
|---|---|---|---|---|---|
| 1 | 26 ns | 0x0004 | `0x20090000` | `ADDI $t1, $zero, 0` | Initialize loop counter $t1 = 0$ |
| 2 | 36 ns | 0x0008 | `0x200a0005` | `ADDI $t2, $zero, 5` | Initialize bound $t2 = 5$ |
| 3 | 46 ns | 0x000c | `0x20100000` | `ADDI $s0, $zero, 0` | Initialize sum accumulator $s0 = 0$ |
| 4 | 56 ns | 0x0010 | `0x112a0005` | `BEQ $t1, $t2, done` | Iteration 0: $t1(0) \neq t2(5)$, not taken |
| 5 | 66 ns | 0x0014 | `0x8d0b0000` | `LW $t3, 0($t0)` | Load element 0: $t3 = 3$ |
| 6 | 76 ns | 0x0018 | `0x020b8020` | `ADD $s0, $s0, $t3` | Accumulate: $s0 = 0 + 3 = 3$ |
| 7 | 86 ns | 0x001c | `0x21080004` | `ADDI $t0, $t0, 4` | Advance pointer: $t0 = 4$ |
| 8 | 96 ns | 0x0020 | `0x21290001` | `ADDI $t1, $t1, 1` | Increment counter: $t1 = 1$ |
| 9 | 106 ns | 0x0024 | `0x08000004` | `J loop` | Unconditional jump to PC 0x10 |
| ... | ... | ... | ... | ... | ... |
| 30 | 316 ns | 0x0018 | `0x020b8020` | `ADD $s0, $s0, $t3` | Final element: $s0 = 9 + 5 = 14$ (`0x0E`) |
| 34 | 356 ns | 0x0010 | `0x112a0005` | `BEQ $t1, $t2, done` | $t1(5) == t2(5) \to$ Branch Taken to `done` |
| 35 | 366 ns | 0x0028 | `0x200c0014` | `ADDI $t4, $zero, 20` | Set target address $t4 = 20$ |
| 36 | 376 ns | 0x002c | `0xad900000` | `SW $s0, 0($t4)` | Write sum (14) to Data Memory[20] |
| 37 | 386 ns | 0x0030 | `0x0800000c` | `J end_loop` | Trap halt reached |

---

## 4. Sample Program 2: Maximum Element Search Execution

- **Assembly Source:** `programs/max_search.asm`
- **Machine Code:** `programs/max_search.hex` (16 instructions)
- **Data Memory Pre-load:** `programs/max_search_data.hex` (`[7, 2, 11, 4, 9]`, words 0–4)
- **Result Location:** Data Memory Word Index 5 (byte address 20 / 0x14)
- **Clock Frequency:** 100 MHz (10 ns clock period)
- **Cycle Count Measured:** **39 Clock Cycles** (390 ns)
- **Cycles Per Instruction (CPI):** **1.00**
- **Outcome:**
  - Memory at address 20: `0x0000000B` (**11**) $\to$ **PASS**
  - Register `$s0` ($16): `0x0000000B` (**11**) $\to$ **PASS**

### Search Iteration Trace

1. **Initialization:** Element 0 (`7`) loaded into `$s0`. Initial maximum = `7`. Pointer set to word 1 (`$t0=4`).
2. **Iteration 1 (Element = 2):**
   `SLT $t4, $s0, $t3` $\to$ `SLT(7, 2) = 0`.
   `BEQ $t4, $zero, skip` $\to$ Branch taken! Maximum remains `7`.
3. **Iteration 2 (Element = 11):**
   `SLT $t4, $s0, $t3` $\to$ `SLT(7, 11) = 1`.
   `BEQ $t4, $zero, skip` $\to$ Branch not taken.
   `ADD $s0, $zero, $t3` executed at cycle 16 $\to$ Maximum updated to **11** (`0x0B`).
4. **Iteration 3 (Element = 4):**
   `SLT $t4, $s0, $t3` $\to$ `SLT(11, 4) = 0`. Skip taken. Maximum remains `11`.
5. **Iteration 4 (Element = 9):**
   `SLT $t4, $s0, $t3` $\to$ `SLT(11, 9) = 0`. Skip taken. Maximum remains `11`.
6. **Termination:**
   `BEQ` detects $i == 5$ and branches to `done`.
   `SW $s0, 0($t5)` stores `11` into memory address 20.

---

## 5. Architectural Robustness and Error Suppression

The processor was subjected to adversarial and illegal instruction inputs to confirm no state corruption occurs:

1. **Illegal Opcode (0x3F = `6'b111111`):**
   - Result: `invalid_instruction` asserted (`1'b1`).
   - `reg_write` forced to `0`.
   - `dmem_write` forced to `0`.
   - Architectural register `$t0` preserved intact without corruption.
2. **Illegal R-Type Funct (0x3F = `6'b111111` with opcode `6'b000000`):**
   - Result: `invalid_funct` asserted, propagating to `invalid_instruction`.
   - `reg_write` forced to `0`.
   - Architectural state preserved.
3. **Register `$zero` Invariance:**
   - Over 100 cycles of simulation across all programs and testbenches, `$0` was targeted with writes and permanently evaluated to `32'h00000000`.
