// =============================================================================
// Module: alu_control
// Description: ALU Control Unit for Single-Cycle MIPS.
//              Combines the 2-bit ALUOp control signal from the main decoder
//              with the 6-bit instruction funct field (for R-type instructions)
//              to determine the 4-bit ALU operation selector.
// =============================================================================

`timescale 1ns / 1ps

module alu_control (
    input  wire [1:0] alu_op,
    input  wire [5:0] funct,
    output reg  [3:0] alu_ctrl,
    output reg        invalid_funct
);

    // MIPS R-Type Function Codes
    localparam FUNCT_ADD = 6'b100000; // 0x20
    localparam FUNCT_SUB = 6'b100010; // 0x22
    localparam FUNCT_AND = 6'b100100; // 0x24
    localparam FUNCT_OR  = 6'b100101; // 0x25
    localparam FUNCT_XOR = 6'b100110; // 0x26
    localparam FUNCT_SLT = 6'b101010; // 0x2A

    // Internal ALU Operation Codes
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_XOR = 4'b0011;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_SLT = 4'b0111;
    localparam ALU_NOP = 4'b1111;

    always @(*) begin
        alu_ctrl      = ALU_NOP;
        invalid_funct = 1'b0;

        case (alu_op)
            2'b00: begin
                // Load / Store / Addi -> Addition
                alu_ctrl = ALU_ADD;
            end

            2'b01: begin
                // Branch Equal -> Subtraction for comparison
                alu_ctrl = ALU_SUB;
            end

            2'b10: begin
                // R-Type -> Inspect Funct code
                case (funct)
                    FUNCT_ADD: alu_ctrl = ALU_ADD;
                    FUNCT_SUB: alu_ctrl = ALU_SUB;
                    FUNCT_AND: alu_ctrl = ALU_AND;
                    FUNCT_OR:  alu_ctrl = ALU_OR;
                    FUNCT_XOR: alu_ctrl = ALU_XOR;
                    FUNCT_SLT: alu_ctrl = ALU_SLT;
                    default: begin
                        alu_ctrl      = ALU_NOP;
                        invalid_funct = 1'b1;
                    end
                endcase
            end

            default: begin
                alu_ctrl      = ALU_NOP;
                invalid_funct = 1'b1;
            end
        endcase
    end

endmodule
