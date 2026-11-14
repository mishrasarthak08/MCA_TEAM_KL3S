// =============================================================================
// Module: mips_decoder
// Description: Main Control Unit / Instruction Decoder for Single-Cycle MIPS.
//              Generates control signals from the 6-bit instruction opcode.
//              Uses safe combinational defaults to prevent unintended latches
//              and ensure invalid opcodes cannot alter processor state.
// =============================================================================

`timescale 1ns / 1ps

module mips_decoder (
    input  wire [5:0] opcode,
    output reg        reg_dst,
    output reg        alu_src,
    output reg        mem_to_reg,
    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg        branch,
    output reg        jump,
    output reg  [1:0] alu_op,
    output reg        invalid_opcode
);

    // MIPS Standard Primary Opcodes
    localparam OP_R_TYPE = 6'b000000; // 0x00: R-type instructions
    localparam OP_J      = 6'b000010; // 0x02: Unconditional Jump
    localparam OP_BEQ    = 6'b000100; // 0x04: Branch on Equal
    localparam OP_ADDI   = 6'b001000; // 0x08: Add Immediate
    localparam OP_LW     = 6'b100011; // 0x23: Load Word
    localparam OP_SW     = 6'b101011; // 0x2B: Store Word

    always @(*) begin
        // Safe default assignments (prevent latches and state mutation)
        reg_dst        = 1'b0;
        alu_src        = 1'b0;
        mem_to_reg     = 1'b0;
        reg_write      = 1'b0;
        mem_read       = 1'b0;
        mem_write      = 1'b0;
        branch         = 1'b0;
        jump           = 1'b0;
        alu_op         = 2'b00;
        invalid_opcode = 1'b0;

        case (opcode)
            OP_R_TYPE: begin
                reg_dst    = 1'b1;   // Destination register is rd
                alu_src    = 1'b0;   // Second ALU operand is rt register
                mem_to_reg = 1'b0;   // Write-back from ALU result
                reg_write  = 1'b1;   // Enable register file write
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                branch     = 1'b0;
                jump       = 1'b0;
                alu_op     = 2'b10;  // Decode funct field
            end

            OP_ADDI: begin
                reg_dst    = 1'b0;   // Destination register is rt
                alu_src    = 1'b1;   // Second ALU operand is sign-extended immediate
                mem_to_reg = 1'b0;   // Write-back from ALU result
                reg_write  = 1'b1;   // Enable register file write
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                branch     = 1'b0;
                jump       = 1'b0;
                alu_op     = 2'b00;  // Addition
            end

            OP_LW: begin
                reg_dst    = 1'b0;   // Destination register is rt
                alu_src    = 1'b1;   // Address calculation: rs + imm
                mem_to_reg = 1'b1;   // Write-back from Data Memory
                reg_write  = 1'b1;   // Enable register file write
                mem_read   = 1'b1;   // Read from data memory
                mem_write  = 1'b0;
                branch     = 1'b0;
                jump       = 1'b0;
                alu_op     = 2'b00;  // Addition for address calculation
            end

            OP_SW: begin
                reg_dst    = 1'b0;
                alu_src    = 1'b1;   // Address calculation: rs + imm
                mem_to_reg = 1'b0;
                reg_write  = 1'b0;   // No register write
                mem_read   = 1'b0;
                mem_write  = 1'b1;   // Enable memory write
                branch     = 1'b0;
                jump       = 1'b0;
                alu_op     = 2'b00;  // Addition for address calculation
            end

            OP_BEQ: begin
                reg_dst    = 1'b0;
                alu_src    = 1'b0;   // Compare rs with rt
                mem_to_reg = 1'b0;
                reg_write  = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                branch     = 1'b1;   // Enable branch evaluation
                jump       = 1'b0;
                alu_op     = 2'b01;  // Subtraction for equality check
            end

            OP_J: begin
                reg_dst    = 1'b0;
                alu_src    = 1'b0;
                mem_to_reg = 1'b0;
                reg_write  = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                branch     = 1'b0;
                jump       = 1'b1;   // Enable unconditional jump
                alu_op     = 2'b00;
            end

            default: begin
                // Invalid or unsupported opcode: keep all controls deasserted
                invalid_opcode = 1'b1;
            end
        endcase
    end

endmodule
