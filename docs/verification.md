# Verification Plan and Methodology

## 1. Verification Strategy

The verification strategy follows a layered, bottom-up methodology to guarantee functional correctness across all operational modes before full-system integration:

1. **Unit-Level Testing:**
   - Isolated verification of datapath and control components (`alu.v`, `register_file.v`, `mips_decoder.v`, `alu_control.v`, `instruction_memory.v`, `data_memory.v`, `branch_jump_logic.v`).
   - Exhaustive coverage of signed/unsigned arithmetic edge cases and control truth tables.
2. **Robustness & Fault Injection Testing:**
   - Illegal opcodes, unsupported funct codes, and unaligned memory addresses tested to verify write suppression and error flag assertion.
3. **Integration-Level Testing:**
   - Full CPU system simulations executing complete, non-trivial assembly programs (`array_sum.asm`, `max_search.asm`) assembled directly by our custom Python toolchain.
4. **Automated Regression and Self-Checking:**
   - Every testbench is fully self-checking, evaluating outputs against gold-standard mathematical models and emitting explicit `PASS` or `FAIL` messages. Any error halts the runner with a non-zero exit code (`$fatal`).

---

## 2. Test Matrix and Verification Results

| Testbench | Module Under Test | Specific Test Cases Evaluated | Result |
|---|---|---|:---:|
| `testbench/tb_alu.v` | `alu.v` | - Positive & negative addition, overflow wraparound<br/>- Positive, zero, and negative subtraction<br/>- Bitwise AND, OR, XOR across complementary patterns<br/>- Signed SLT: positive vs positive, positive vs negative, negative vs negative, equal operands, extreme min/max boundary values (`0x80000000` vs `0x7FFFFFFF`)<br/>- Zero flag activation on null results | **PASS** (23/23) |
| `testbench/tb_register_file.v` | `register_file.v` | - Synchronous write to registers $1 through $31<br/>- Dual-port simultaneous asynchronous read across all registers<br/>- Register $zero ($0) hardwired zero reading and write suppression<br/>- Asynchronous reset clearing all 32 registers<br/>- Dedicated debug read port inspection | **PASS** (19/19) |
| `testbench/tb_decoder.v` | `mips_decoder.v`, `alu_control.v` | - Decoding of all supported opcodes (R-type, ADDI, LW, SW, BEQ, J)<br/>- Combinational defaults on illegal opcodes (`0x3F`, `0x15`)<br/>- Funct decoding for ADD, SUB, AND, OR, XOR, SLT<br/>- Funct error detection on unsupported R-type codes | **PASS** (17/17) |
| `testbench/tb_memory.v` | `instruction_memory.v`, `data_memory.v` | - Word-aligned combinational instruction read from hex files<br/>- Detection of unaligned instruction addresses (`addr[1:0] != 00`)<br/>- Out-of-bounds address detection (`word_addr >= 256`)<br/>- Synchronous store word (SW) and combinational load word (LW)<br/>- Suppression of memory writes on unaligned byte addresses | **PASS** (12/12) |
| `testbench/tb_branch_jump.v` | `branch_jump_logic.v` | - Sequential PC+4 progression<br/>- Conditional branch taken when `Zero=1`<br/>- Conditional branch ignored when `Zero=0`<br/>- Backward branch calculations (negative 2's complement offsets)<br/>- Unconditional jump target concatenation (`{PC+4[31:28], target[25:0], 2'b00}`)<br/>- Jump priority resolution over concurrent branch conditions | **PASS** (8/8) |
| `testbench/tb_invalid_instr.v` | `mips_core.v` | - Injection of invalid opcode `0x3F`: write enables deasserted, $t0 unmodified<br/>- Injection of invalid funct `0x3F`: write enables deasserted, $t0 unmodified | **PASS** (6/6) |
| `testbench/tb_mips_cpu.v` | `mips_system.v` | - Execution of **Program 1: Array Sum**<br/>- Input: `[3, 1, 4, 1, 5]`<br/>- Expected: `14` at Data Memory offset 20<br/>- Actual: `14` (0x0000000E), 39 cycles, CPI = 1.00 | **PASS** |
| `testbench/tb_mips_cpu_max.v` | `mips_system.v` | - Execution of **Program 2: Maximum Search**<br/>- Input: `[7, 2, 11, 4, 9]`<br/>- Expected: `11` at Data Memory offset 20<br/>- Actual: `11` (0x0000000B), 39 cycles, CPI = 1.00 | **PASS** |

---

## 3. Waveform Artifacts

Waveforms are captured in Value Change Dump (`.vcd`) files located in `waveforms/`:
- `mips_cpu_array_sum.vcd`
- `mips_cpu_max_search.vcd`
- `tb_alu.vcd`
- `tb_register_file.vcd`
- `tb_decoder.vcd`
- `tb_memory.vcd`
- `tb_branch_jump.vcd`
- `tb_invalid_instr.vcd`

A GTKWave project configuration is provided at `waveforms/mips_cpu.gtkw`.
