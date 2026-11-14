// =============================================================================
// Module: mips_system
// Description: Top-Level System for Single-Cycle MIPS.
//              Integrates MIPS Core, Instruction Memory (Harvard architecture),
//              and Data Memory, exposing comprehensive debug ports.
// =============================================================================

`timescale 1ns / 1ps

module mips_system #(
    parameter IMEM_DEPTH     = 256,
    parameter DMEM_DEPTH     = 256,
    parameter IMEM_INIT_FILE = "",
    parameter DMEM_INIT_FILE = ""
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        pc_en,

    // Core Observable Debug Ports
    output wire [31:0] current_pc,
    output wire [31:0] current_instruction,
    output wire [31:0] alu_result,
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_write_data,
    output wire [31:0] dmem_read_data,
    output wire        dmem_read,
    output wire        dmem_write,
    output wire        reg_write,
    output wire [4:0]  write_reg,
    output wire [31:0] write_data,
    output wire        branch_taken,
    output wire        jump_taken,
    output wire        invalid_instruction,

    // Memory Safety / Status Ports
    output wire        imem_alignment_error,
    output wire        imem_out_of_bounds,
    output wire        dmem_alignment_error,
    output wire        dmem_out_of_bounds,

    // Selectable Register Debug Port
    input  wire [4:0]  debug_reg_addr,
    output wire [31:0] debug_reg_data,

    // Selectable Data Memory Word Debug Port
    input  wire [31:0] debug_mem_addr,
    output wire [31:0] debug_mem_data
);

    // -------------------------------------------------------------------------
    // Core <-> Memory Interconnect Wires
    // -------------------------------------------------------------------------
    wire [31:0] core_pc;
    wire [31:0] core_instruction;
    wire [31:0] core_dmem_addr;
    wire [31:0] core_dmem_wdata;
    wire [31:0] core_dmem_rdata;
    wire        core_dmem_read;
    wire        core_dmem_write;

    // -------------------------------------------------------------------------
    // Core Instance
    // -------------------------------------------------------------------------
    mips_core core_inst (
        .clk                       (clk),
        .rst                       (rst),
        .pc_en                     (pc_en),
        .pc                        (core_pc),
        .instruction               (core_instruction),
        .dmem_addr                 (core_dmem_addr),
        .dmem_write_data           (core_dmem_wdata),
        .dmem_read                 (core_dmem_read),
        .dmem_write                (core_dmem_write),
        .dmem_read_data            (core_dmem_rdata),
        .debug_alu_result          (alu_result),
        .debug_reg_write           (reg_write),
        .debug_write_reg           (write_reg),
        .debug_write_data          (write_data),
        .debug_branch_taken        (branch_taken),
        .debug_jump_taken          (jump_taken),
        .debug_invalid_instruction (invalid_instruction),
        .debug_reg_addr            (debug_reg_addr),
        .debug_reg_data            (debug_reg_data)
    );

    assign current_pc          = core_pc;
    assign current_instruction = core_instruction;
    assign dmem_addr           = core_dmem_addr;
    assign dmem_write_data     = core_dmem_wdata;
    assign dmem_read_data      = core_dmem_rdata;
    assign dmem_read           = core_dmem_read;
    assign dmem_write          = core_dmem_write;

    // -------------------------------------------------------------------------
    // Instruction Memory Instance
    // -------------------------------------------------------------------------
    instruction_memory #(
        .MEM_DEPTH     (IMEM_DEPTH),
        .MEM_INIT_FILE (IMEM_INIT_FILE)
    ) imem_inst (
        .addr            (core_pc),
        .instruction     (core_instruction),
        .alignment_error (imem_alignment_error),
        .out_of_bounds   (imem_out_of_bounds)
    );

    // -------------------------------------------------------------------------
    // Data Memory Instance
    // -------------------------------------------------------------------------
    data_memory #(
        .MEM_DEPTH     (DMEM_DEPTH),
        .MEM_INIT_FILE (DMEM_INIT_FILE)
    ) dmem_inst (
        .clk             (clk),
        .mem_read        (core_dmem_read),
        .mem_write       (core_dmem_write),
        .addr            (core_dmem_addr),
        .write_data      (core_dmem_wdata),
        .read_data       (core_dmem_rdata),
        .alignment_error (dmem_alignment_error),
        .out_of_bounds   (dmem_out_of_bounds),
        .debug_word_addr (debug_mem_addr),
        .debug_word_data (debug_mem_data)
    );

endmodule
