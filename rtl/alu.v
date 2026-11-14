// =============================================================================
// Module: alu
// Description: 32-bit Arithmetic Logic Unit for MIPS32.
//              Supports ADD, SUB, AND, OR, XOR, signed SLT, and Zero flag.
// =============================================================================

`timescale 1ns / 1ps

module alu (
    input  wire [31:0] a,           // Operand A
    input  wire [31:0] b,           // Operand B
    input  wire [3:0]  alu_ctrl,    // 4-bit Operation Control
    output reg  [31:0] result,      // 32-bit ALU computation result
    output wire        zero         // Asserted when result is 0 (for BEQ)
);

    // ALU Operation Codes
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_XOR = 4'b0011;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_SLT = 4'b0111;

    always @(*) begin
        case (alu_ctrl)
            ALU_AND: result = a & b;
            ALU_OR:  result = a | b;
            ALU_ADD: result = a + b;
            ALU_XOR: result = a ^ b;
            ALU_SUB: result = a - b;
            ALU_SLT: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            default: result = 32'd0;
        endcase
    end

    // Zero flag output for branch evaluation
    assign zero = (result == 32'd0);

endmodule
