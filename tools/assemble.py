#!/usr/bin/env python3
"""
tools/assemble.py: Assembler for Educational Single-Cycle MIPS32 Processor.
Converts MIPS assembly source code (.asm) into 32-bit hexadecimal machine code (.hex)
suitable for Verilog $readmemh initialization.

Supported Instructions:
  R-Type: ADD, SUB, AND, OR, XOR, SLT
  I-Type: ADDI, LW, SW, BEQ
  J-Type: J
"""

import sys
import re
import os

# Register Name Mapping to 5-bit integer
REGISTER_MAP = {
    "$zero": 0, "$0": 0,
    "$at": 1,   "$1": 1,
    "$v0": 2,   "$v1": 3,   "$2": 2,   "$3": 3,
    "$a0": 4,   "$a1": 5,   "$a2": 6,  "$a3": 7,
    "$4": 4,    "$5": 5,    "$6": 6,   "$7": 7,
    "$t0": 8,   "$t1": 9,   "$t2": 10, "$t3": 11,
    "$t4": 12,  "$t5": 13,  "$t6": 14, "$t7": 15,
    "$8": 8,    "$9": 9,    "$10": 10, "$11": 11,
    "$12": 12,  "$13": 13,  "$14": 14, "$15": 15,
    "$s0": 16,  "$s1": 17,  "$s2": 18, "$s3": 19,
    "$s4": 20,  "$s5": 21,  "$s6": 22, "$s7": 23,
    "$16": 16,  "$17": 17,  "$18": 18, "$19": 19,
    "$20": 20,  "$21": 21,  "$22": 22, "$23": 23,
    "$t8": 24,  "$t9": 25,  "$24": 24, "$25": 25,
    "$k0": 26,  "$k1": 27,  "$26": 26, "$27": 27,
    "$gp": 28,  "$28": 28,
    "$sp": 29,  "$29": 29,
    "$fp": 30,  "$s8": 30,  "$30": 30,
    "$ra": 31,  "$31": 31,
}

R_FUNCT = {
    "ADD": 0x20, # 100000
    "SUB": 0x22, # 100010
    "AND": 0x24, # 100100
    "OR":  0x25, # 100101
    "XOR": 0x26, # 100110
    "SLT": 0x2A  # 101010
}

I_OPCODES = {
    "BEQ":  0x04, # 000100
    "ADDI": 0x08, # 001000
    "LW":   0x23, # 100011
    "SW":   0x2B  # 101011
}

J_OPCODES = {
    "J": 0x02    # 000010
}

def parse_reg(reg_str):
    reg_clean = reg_str.strip().lower()
    if reg_clean in REGISTER_MAP:
        return REGISTER_MAP[reg_clean]
    raise ValueError(f"Unknown register name: '{reg_str}'")

def parse_imm(imm_str):
    imm_clean = imm_str.strip()
    if imm_clean.startswith("0x") or imm_clean.startswith("0X"):
        val = int(imm_clean, 16)
    else:
        val = int(imm_clean, 10)
    return val

def assemble_file(input_path, output_path=None, listing_path=None):
    with open(input_path, "r") as f:
        lines = f.readlines()

    # Pass 1: Strip comments, collect labels and instructions
    symbol_table = {}
    instructions = []
    current_byte_address = 0

    for line_num, raw_line in enumerate(lines, 1):
        # Remove comments (# or //)
        line = re.sub(r"(#|//).*$", "", raw_line).strip()
        if not line:
            continue

        # Check for labels (e.g. "loop:" or "loop: addi $t0, $t0, 1")
        while ":" in line:
            label_part, line = line.split(":", 1)
            label = label_part.strip()
            if not re.match(r"^[a-zA-Z_][a-zA-Z0-9_]*$", label):
                raise SyntaxError(f"Line {line_num}: Invalid label syntax: '{label}'")
            if label in symbol_table:
                raise ValueError(f"Line {line_num}: Duplicate label definition: '{label}'")
            symbol_table[label] = current_byte_address
            line = line.strip()

        if not line:
            continue

        instructions.append((line_num, current_byte_address, line))
        current_byte_address += 4

    # Pass 2: Encode instructions into 32-bit machine code
    machine_codes = []
    listing_lines = []

    for line_num, byte_addr, line in instructions:
        tokens = re.split(r"[\s,]+", line.strip())
        mnemonic = tokens[0].upper()
        args = tokens[1:]

        word = 0

        if mnemonic in R_FUNCT:
            # Format: mnemonic rd, rs, rt
            if len(args) != 3:
                raise SyntaxError(f"Line {line_num}: {mnemonic} requires 3 arguments (rd, rs, rt). Found: {args}")
            rd = parse_reg(args[0])
            rs = parse_reg(args[1])
            rt = parse_reg(args[2])
            shamt = 0
            funct = R_FUNCT[mnemonic]
            opcode = 0x00

            word = (opcode << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (shamt << 6) | funct

        elif mnemonic == "ADDI":
            # Format: ADDI rt, rs, imm
            if len(args) != 3:
                raise SyntaxError(f"Line {line_num}: ADDI requires 3 arguments (rt, rs, imm). Found: {args}")
            rt = parse_reg(args[0])
            rs = parse_reg(args[1])
            imm = parse_imm(args[2]) & 0xFFFF
            opcode = I_OPCODES["ADDI"]

            word = (opcode << 26) | (rs << 21) | (rt << 16) | imm

        elif mnemonic in ("LW", "SW"):
            # Format: LW rt, offset(rs) OR LW rt, imm, rs
            if len(args) == 2:
                # offset(rs) format
                match = re.match(r"^([+-]?[0-9xX]+)?\((.*)\)$", args[1].strip())
                if not match:
                    raise SyntaxError(f"Line {line_num}: Invalid memory addressing syntax: '{args[1]}'")
                offset_str, rs_str = match.groups()
                offset = parse_imm(offset_str) if offset_str else 0
                rs = parse_reg(rs_str)
            elif len(args) == 3:
                offset = parse_imm(args[1])
                rs = parse_reg(args[2])
            else:
                raise SyntaxError(f"Line {line_num}: {mnemonic} requires (rt, offset(rs)) format.")
            
            rt = parse_reg(args[0])
            imm = offset & 0xFFFF
            opcode = I_OPCODES[mnemonic]

            word = (opcode << 26) | (rs << 21) | (rt << 16) | imm

        elif mnemonic == "BEQ":
            # Format: BEQ rs, rt, label_or_imm
            if len(args) != 3:
                raise SyntaxError(f"Line {line_num}: BEQ requires 3 arguments (rs, rt, label). Found: {args}")
            rs = parse_reg(args[0])
            rt = parse_reg(args[1])
            target_str = args[2]

            if target_str in symbol_table:
                target_addr = symbol_table[target_str]
                # Branch offset = (target_addr - (current_pc + 4)) >> 2
                offset_words = (target_addr - (byte_addr + 4)) >> 2
            else:
                offset_words = parse_imm(target_str)

            imm = offset_words & 0xFFFF
            opcode = I_OPCODES["BEQ"]

            word = (opcode << 26) | (rs << 21) | (rt << 16) | imm

        elif mnemonic == "J":
            # Format: J label_or_target
            if len(args) != 1:
                raise SyntaxError(f"Line {line_num}: J requires 1 argument (target). Found: {args}")
            target_str = args[0]

            if target_str in symbol_table:
                target_addr = symbol_table[target_str]
                target_field = (target_addr >> 2) & 0x03FFFFFF
            else:
                target_field = (parse_imm(target_str) >> 2) & 0x03FFFFFF

            opcode = J_OPCODES["J"]
            word = (opcode << 26) | target_field

        else:
            raise ValueError(f"Line {line_num}: Unsupported instruction mnemonic '{mnemonic}'")

        hex_str = f"{word:08x}"
        machine_codes.append(hex_str)
        listing_lines.append(f"0x{byte_addr:04x} [0x{byte_addr//4:02x}]: {hex_str}    {line}")

    # Write output hex file
    if output_path:
        with open(output_path, "w") as f:
            for code in machine_codes:
                f.write(f"{code}\n")

    # Write listing file if requested
    if listing_path:
        with open(listing_path, "w") as f:
            f.write(f"=== MIPS32 Assembly Listing: {os.path.basename(input_path)} ===\n")
            f.write(f"Symbol Table:\n")
            for lbl, addr in symbol_table.items():
                f.write(f"  {lbl:16s} -> 0x{addr:04x} (Word {addr//4})\n")
            f.write("\nAssembly & Machine Code:\n")
            for item in listing_lines:
                f.write(f"  {item}\n")

    return machine_codes, listing_lines, symbol_table

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 assemble.py <input.asm> [output.hex] [listing.txt]")
        sys.exit(1)

    in_file = sys.argv[1]
    out_file = sys.argv[2] if len(sys.argv) > 2 else in_file.rsplit(".", 1)[0] + ".hex"
    list_file = sys.argv[3] if len(sys.argv) > 3 else in_file.rsplit(".", 1)[0] + "_listing.txt"

    codes, listing, syms = assemble_file(in_file, out_file, list_file)
    print(f"Successfully assembled {len(codes)} instructions from '{in_file}' -> '{out_file}'")
