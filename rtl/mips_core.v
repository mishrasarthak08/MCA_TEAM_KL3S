// =============================================================================
// Module: mips_core
// Description: Fully integrated 32-bit Single-Cycle MIPS Core.
//              Contains Datapath and Control Units with modular memory interfaces.
//              Executes one instruction per clock cycle with zero branch delay slots.
// =============================================================================

`timescale 1ns / 1ps

module mips_core (
    input  wire        clk,
    input  wire        rst,
    input  wire        pc_en,

    // Instruction Memory Interface
    output wire [31:0] pc,
    input  wire [31:0] instruction,

    // Data Memory Interface
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_write_data,
    output wire        dmem_read,
    output wire        dmem_write,
    input  wire [31:0] dmem_read_data,

    // Debug and Introspection Interface
    output wire [31:0] debug_alu_result,
    output wire        debug_reg_write,
    output wire [4:0]  debug_write_reg,
    output wire [31:0] debug_write_data,
    output wire        debug_branch_taken,
    output wire        debug_jump_taken,
    output wire        debug_invalid_instruction,
    input  wire [4:0]  debug_reg_addr,
    output wire [31:0] debug_reg_data
);

    // -------------------------------------------------------------------------
    // Instruction Fields Breakdown
    // -------------------------------------------------------------------------
    wire [5:0]  opcode         = instruction[31:26];
    wire [4:0]  rs             = instruction[25:21];
    wire [4:0]  rt             = instruction[20:16];
    wire [4:0]  rd             = instruction[15:11];
    wire [5:0]  funct          = instruction[5:0];
    wire [15:0] imm16          = instruction[15:0];
    wire [25:0] jump_target_26 = instruction[25:0];

    // -------------------------------------------------------------------------
    // Control Signals
    // -------------------------------------------------------------------------
    wire       reg_dst;
    wire       alu_src;
    wire       mem_to_reg;
    wire       reg_write_raw;
    wire       mem_read_raw;
    wire       mem_write_raw;
    wire       branch;
    wire       jump;
    wire [1:0] alu_op;
    wire       invalid_opcode;

    mips_decoder decoder_inst (
        .opcode         (opcode),
        .reg_dst        (reg_dst),
        .alu_src        (alu_src),
        .mem_to_reg     (mem_to_reg),
        .reg_write      (reg_write_raw),
        .mem_read       (mem_read_raw),
        .mem_write      (mem_write_raw),
        .branch         (branch),
        .jump           (jump),
        .alu_op         (alu_op),
        .invalid_opcode (invalid_opcode)
    );

    wire [3:0] alu_ctrl;
    wire       invalid_funct;

    alu_control alu_control_inst (
        .alu_op        (alu_op),
        .funct         (funct),
        .alu_ctrl      (alu_ctrl),
        .invalid_funct (invalid_funct)
    );

    // Architectural safety: invalidate state writes on invalid instructions
    wire invalid_instr = invalid_opcode | (alu_op == 2'b10 && invalid_funct);
    wire safe_reg_write = reg_write_raw & ~invalid_instr;
    wire safe_mem_write = mem_write_raw & ~invalid_instr;
    wire safe_mem_read  = mem_read_raw  & ~invalid_instr;

    assign dmem_read  = safe_mem_read;
    assign dmem_write = safe_mem_write;

    // -------------------------------------------------------------------------
    // Program Counter and Next-PC Logic
    // -------------------------------------------------------------------------
    wire [31:0] next_pc;
    wire [31:0] pc_current;
    wire [31:0] pc_plus_4;
    wire [31:0] branch_target;
    wire [31:0] jump_target;
    wire        take_branch;
    wire        alu_zero;
    wire [31:0] sign_ext_imm;

    program_counter pc_inst (
        .clk    (clk),
        .rst    (rst),
        .pc_en  (pc_en),
        .pc_in  (next_pc),
        .pc_out (pc_current)
    );

    assign pc = pc_current;

    sign_extend sign_ext_inst (
        .in16 (imm16),
        .out32(sign_ext_imm)
    );

    branch_jump_logic branch_jump_inst (
        .pc             (pc_current),
        .sign_ext_imm   (sign_ext_imm),
        .jump_target_26 (jump_target_26),
        .branch         (branch),
        .zero           (alu_zero),
        .jump           (jump),
        .pc_plus_4      (pc_plus_4),
        .branch_target  (branch_target),
        .jump_target    (jump_target),
        .take_branch    (take_branch),
        .next_pc        (next_pc)
    );

    // -------------------------------------------------------------------------
    // Register File & Write-Back
    // -------------------------------------------------------------------------
    wire [4:0]  write_reg;
    wire [31:0] write_data;
    wire [31:0] reg_read_data1;
    wire [31:0] reg_read_data2;
    wire [31:0] alu_result;

    register_file reg_file_inst (
        .clk            (clk),
        .rst            (rst),
        .reg_write      (safe_reg_write),
        .read_reg1      (rs),
        .read_reg2      (rt),
        .write_reg      (write_reg),
        .write_data     (write_data),
        .read_data1     (reg_read_data1),
        .read_data2     (reg_read_data2),
        .debug_reg_addr (debug_reg_addr),
        .debug_reg_data (debug_reg_data)
    );

    writeback_logic wb_inst (
        .reg_dst       (reg_dst),
        .mem_to_reg    (mem_to_reg),
        .rt            (rt),
        .rd            (rd),
        .alu_result    (alu_result),
        .mem_read_data (dmem_read_data),
        .write_reg     (write_reg),
        .write_data    (write_data)
    );

    // -------------------------------------------------------------------------
    // ALU and Datapath Execution
    // -------------------------------------------------------------------------
    wire [31:0] alu_operand_b = (alu_src) ? sign_ext_imm : reg_read_data2;

    alu alu_inst (
        .a        (reg_read_data1),
        .b        (alu_operand_b),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),
        .zero     (alu_zero)
    );

    // Memory connections
    assign dmem_addr       = alu_result;
    assign dmem_write_data = reg_read_data2;

    // -------------------------------------------------------------------------
    // Debug and Visibility Outputs
    // -------------------------------------------------------------------------
    assign debug_alu_result          = alu_result;
    assign debug_reg_write           = safe_reg_write;
    assign debug_write_reg           = write_reg;
    assign debug_write_data          = write_data;
    assign debug_branch_taken        = take_branch;
    assign debug_jump_taken          = jump;
    assign debug_invalid_instruction = invalid_instr;

endmodule
