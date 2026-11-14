# Single-Cycle MIPS Processor Architectural Specification

## 1. Architectural Overview

The processor implemented in this project is an educational 32-bit Harvard-architecture Single-Cycle MIPS processor. In a single-cycle implementation, every instruction is fetched, decoded, executed, accesses memory (if applicable), and writes back results to the register file within exactly **one clock cycle**.

### Core Architectural Characteristics
- **Word Width:** 32 bits.
- **Instruction Width:** Fixed 32 bits.
- **Address Space:** Byte-addressed, 32-bit linear address space.
- **Memory Architecture:** Harvard architecture (physically segregated Instruction Memory and Data Memory buses), avoiding structural hazards on memory in a single cycle.
- **Clocking:** Positive-edge triggered sequential elements (Program Counter, Register File write port, Data Memory write port).
- **Branch Delay Slots:** **None.** (Unlike commercial MIPS I pipelines with delayed branches, this single-cycle processor updates the PC immediately at the end of the current cycle).

---

## 2. Supported Instruction Set Architecture (ISA)

The processor supports 11 core MIPS instructions categorized into R-type, I-type, and J-type formats:

### 2.1 R-Type Instructions
Format: `opcode[31:26] | rs[25:21] | rt[20:16] | rd[15:11] | shamt[10:6] | funct[5:0]`
- All R-type instructions have `opcode = 6'b000000`.
- Operands are read from registers `rs` and `rt`. The result is written to register `rd`.

| Instruction | Funct (bin) | Funct (hex) | RTL Semantic | Description |
|---|---|---|---|---|
| `ADD rd, rs, rt` | `100000` | `0x20` | `R[rd] <= R[rs] + R[rt]` | 32-bit addition |
| `SUB rd, rs, rt` | `100010` | `0x22` | `R[rd] <= R[rs] - R[rt]` | 32-bit subtraction |
| `AND rd, rs, rt` | `100100` | `0x24` | `R[rd] <= R[rs] & R[rt]` | Bitwise logical AND |
| `OR rd, rs, rt` | `100101` | `0x25` | `R[rd] <= R[rs] \| R[rt]` | Bitwise logical OR |
| `XOR rd, rs, rt` | `100110` | `0x26` | `R[rd] <= R[rs] ^ R[rt]` | Bitwise logical XOR |
| `SLT rd, rs, rt` | `101010` | `0x2A` | `R[rd] <= ($signed(R[rs]) < $signed(R[rt])) ? 1 : 0` | Signed set on less than |

### 2.2 I-Type Instructions
Format: `opcode[31:26] | rs[25:21] | rt[20:16] | immediate[15:0]`
- Immediate field is sign-extended to 32 bits: `sign_ext_imm = {{16{imm[15]}}, imm}`.

| Instruction | Opcode (bin) | Opcode (hex) | RTL Semantic | Description |
|---|---|---|---|---|
| `ADDI rt, rs, imm` | `001000` | `0x08` | `R[rt] <= R[rs] + sign_ext_imm` | Add immediate |
| `LW rt, offset(rs)` | `100011` | `0x23` | `R[rt] <= Memory[R[rs] + sign_ext_imm]` | Load 32-bit word from memory |
| `SW rt, offset(rs)` | `101011` | `0x2B` | `Memory[R[rs] + sign_ext_imm] <= R[rt]` | Store 32-bit word to memory |
| `BEQ rs, rt, label` | `000100` | `0x04` | `if (R[rs] == R[rt]) PC <= PC + 4 + (sign_ext_imm << 2)` | Branch if equal |

### 2.3 J-Type Instructions
Format: `opcode[31:26] | address[25:0]`

| Instruction | Opcode (bin) | Opcode (hex) | RTL Semantic | Description |
|---|---|---|---|---|
| `J target` | `000010` | `0x02` | `PC <= { (PC + 4)[31:28], address[25:0], 2'b00 }` | Unconditional jump |

---

## 3. Modular RTL Structure and Interfaces

The implementation separates datapath and control into distinct, synthesizable Verilog modules:

1. **`program_counter` (`rtl/program_counter.v`):**
   - 32-bit synchronous register with asynchronous active-high reset.
   - Clears to `0x00000000` on reset.

2. **`instruction_memory` (`rtl/instruction_memory.v`):**
   - Combinational read access indexed by byte address `addr[31:0]`.
   - Word address translation: `addr[31:2]`.
   - Alignment check (`addr[1:0] == 2'b00`) and boundary check (`word_addr < MEM_DEPTH`).
   - Supports `$readmemh` file loading.

3. **`mips_decoder` (`rtl/mips_decoder.v`):**
   - Combinational logic generating primary control signals (`RegDst`, `ALUSrc`, `MemToReg`, `RegWrite`, `MemRead`, `MemWrite`, `Branch`, `Jump`, `ALUOp`).
   - Safe default assignments preventing latches and suppressing writes on illegal opcodes.

4. **`alu_control` (`rtl/alu_control.v`):**
   - Decodes 2-bit `ALUOp` and 6-bit `funct` into a 4-bit `alu_ctrl` word.

5. **`register_file` (`rtl/register_file.v`):**
   - $32 \times 32$-bit register array.
   - Dual asynchronous read ports (`rs`, `rt`).
   - Single synchronous write port (`write_reg`, `write_data`, `reg_write`).
   - Hardware enforcement: Register `$0` permanently reads `32'd0`, and writes targeting `$0` are dropped.
   - Independent debug port for verification without disturbing core ports.

6. **`sign_extend` (`rtl/sign_extend.v`):**
   - Arithmetic sign extension: replicates bit 15 across the upper 16 bits.

7. **`alu` (`rtl/alu.v`):**
   - 32-bit execution unit with dedicated operations (ADD, SUB, AND, OR, XOR, signed SLT).
   - Generates 1-bit `zero` flag when `result == 32'd0`.

8. **`data_memory` (`rtl/data_memory.v`):**
   - Synchronous write on `posedge clk` gated by `mem_write`.
   - Combinational/asynchronous read enabled by `mem_read`.
   - Alignment and boundary checking. Supports `$readmemh`.

9. **`branch_jump_logic` (`rtl/branch_jump_logic.v`):**
   - Calculates sequential next PC (`PC + 4`).
   - Calculates branch target (`PC + 4 + (sign_ext_imm << 2)`).
   - Evaluates branch taken condition (`branch & zero`).
   - Calculates jump target (`{PC+4[31:28], target[25:0], 2'b00}`).
   - Multiplexes the next PC with Jump taking priority over Branch.

10. **`writeback_logic` (`rtl/writeback_logic.v`):**
    - Multiplexes destination register index (`rt` vs `rd`).
    - Multiplexes register write data (`alu_result` vs `mem_read_data`).

11. **`mips_core` (`rtl/mips_core.v`):**
    - Structural top of the processor datapath and control.
    - Exposes separate instruction memory and data memory bus interfaces.

12. **`mips_system` (`rtl/mips_system.v`):**
    - Complete Harvard system integrating core with memories and debug visibility taps.

---

## 4. Single-Cycle Timing and Critical Path

In single-cycle execution, the entire datapath must settle before the rising clock edge:

$$\text{Critical Path (Load Word): } T_{clk} \ge T_{PC\_clk\_to\_q} + T_{IMEM\_read} + T_{RF\_read} + T_{ALU} + T_{DMEM\_read} + T_{WB\_mux} + T_{RF\_setup}$$

This critical path dictates the maximum operating frequency ($f_{max} \approx 25\text{--}40\text{ MHz}$ on typical FPGAs). Since each instruction completes in 1 cycle, the CPI (Cycles Per Instruction) is always exactly 1.00.
