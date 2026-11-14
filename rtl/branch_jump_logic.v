// =============================================================================
// Module: branch_jump_logic
// Description: Computes next-PC addresses for sequential increment (PC+4),
//              conditional branch (BEQ), and unconditional jump (J).
//              Selects the appropriate next PC based on control and status signals.
// =============================================================================

`timescale 1ns / 1ps

module branch_jump_logic (
    input  wire [31:0] pc,                  // Current Program Counter
    input  wire [31:0] sign_ext_imm,        // Sign-extended 32-bit immediate
    input  wire [25:0] jump_target_26,      // 26-bit jump target from instruction[25:0]
    input  wire        branch,              // Branch control signal (from decoder)
    input  wire        zero,                // Zero flag (from ALU)
    input  wire        jump,                // Jump control signal (from decoder)
    output wire [31:0] pc_plus_4,           // Sequential next PC (PC + 4)
    output wire [31:0] branch_target,       // PC + 4 + (sign_ext_imm << 2)
    output wire [31:0] jump_target,         // {PC+4[31:28], jump_target_26, 2'b00}
    output wire        take_branch,         // Asserted when branch is taken (branch & zero)
    output wire [31:0] next_pc              // Selected next PC for Program Counter register
);

    // Sequential PC increment (+4 bytes / 1 word)
    assign pc_plus_4 = pc + 32'd4;

    // Branch target calculation: PC + 4 + (sign_ext_imm << 2)
    assign branch_target = pc_plus_4 + (sign_ext_imm << 2);

    // Branch condition evaluation
    assign take_branch = branch & zero;

    // Jump target calculation: {PC+4[31:28], target[25:0], 2'b00}
    assign jump_target = {pc_plus_4[31:28], jump_target_26, 2'b00};

    // Next-PC multiplexer: Jump overrides branch, which overrides sequential PC+4
    assign next_pc = (jump)        ? jump_target :
                     (take_branch) ? branch_target :
                                     pc_plus_4;

endmodule
