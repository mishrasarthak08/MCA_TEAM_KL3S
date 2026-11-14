// =============================================================================
// Testbench: tb_mips_cpu_max
// Description: Master Integration Testbench for Program 2: Maximum Element Search.
//              Input Array: [7, 2, 11, 4, 9] in Data Memory.
//              Verifies that the processor computes the maximum (11 = 0x0000000B)
//              and stores it at Data Memory Word 5 (byte offset 20).
//              Generates complete execution trace and VCD waveform.
// =============================================================================

`timescale 1ns / 1ps

module tb_mips_cpu_max;

    reg clk;
    reg rst;
    reg pc_en;

    // Observable debug ports
    wire [31:0] current_pc;
    wire [31:0] current_instruction;
    wire [31:0] alu_result;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_write_data;
    wire [31:0] dmem_read_data;
    wire        dmem_read;
    wire        dmem_write;
    wire        reg_write;
    wire [4:0]  write_reg;
    wire [31:0] write_data;
    wire        branch_taken;
    wire        jump_taken;
    wire        invalid_instruction;
    wire        imem_align_err;
    wire        imem_oob_err;
    wire        dmem_align_err;
    wire        dmem_oob_err;

    reg  [4:0]  debug_reg_addr;
    wire [31:0] debug_reg_data;
    reg  [31:0] debug_mem_addr;
    wire [31:0] debug_mem_data;

    integer cycle_count;
    integer errors = 0;
    integer overall_tests = 0;
    integer trap_counter = 0;

    // 100 MHz clock generation
    always #5 clk = ~clk;

    mips_system #(
        .IMEM_DEPTH     (256),
        .DMEM_DEPTH     (256),
        .IMEM_INIT_FILE ("programs/max_search.hex"),
        .DMEM_INIT_FILE ("programs/max_search_data.hex"),
        .IMEM_INIT_WORDS(16),
        .DMEM_INIT_WORDS(6)
    ) sys_inst (
        .clk                  (clk),
        .rst                  (rst),
        .pc_en                (pc_en),
        .current_pc           (current_pc),
        .current_instruction  (current_instruction),
        .alu_result           (alu_result),
        .dmem_addr            (dmem_addr),
        .dmem_write_data      (dmem_write_data),
        .dmem_read_data       (dmem_read_data),
        .dmem_read            (dmem_read),
        .dmem_write           (dmem_write),
        .reg_write            (reg_write),
        .write_reg            (write_reg),
        .write_data           (write_data),
        .branch_taken         (branch_taken),
        .jump_taken           (jump_taken),
        .invalid_instruction  (invalid_instruction),
        .imem_alignment_error (imem_align_err),
        .imem_out_of_bounds   (imem_oob_err),
        .dmem_alignment_error (dmem_align_err),
        .dmem_out_of_bounds   (dmem_oob_err),
        .debug_reg_addr       (debug_reg_addr),
        .debug_reg_data       (debug_reg_data),
        .debug_mem_addr       (debug_mem_addr),
        .debug_mem_data       (debug_mem_data)
    );

    initial begin
        $dumpfile("waveforms/mips_cpu_max_search.vcd");
        $dumpvars(0, tb_mips_cpu_max);

        clk            = 0;
        rst            = 1;
        pc_en          = 1;
        debug_reg_addr = 0;
        debug_mem_addr = 0;
        cycle_count    = 0;
        trap_counter   = 0;

        $display("================================================================================");
        $display("   MASTER MIPS PROCESSOR SIMULATION: PROGRAM 2 (MAXIMUM SEARCH)");
        $display("================================================================================");
        $display("Time(ns) | Cycle | PC         | Instruction | RegWrite | RegDest | RegData    | MemWrite | MemAddr    | MemData");
        $display("--------------------------------------------------------------------------------");

        // Apply Reset for 2 full cycles
        #20;
        @(negedge clk);
        rst = 0;

        // Run until halt trap at PC 0x0000003C (J end_loop)
        while (cycle_count < 100 && trap_counter < 3) begin
            @(posedge clk);
            #1;
            cycle_count = cycle_count + 1;

            $display("%8t | %5d | 0x%08h | 0x%08h  |    %b     |  $%2d   | 0x%08h |    %b     | 0x%08h | 0x%08h",
                     $time, cycle_count, current_pc, current_instruction,
                     reg_write, write_reg, write_data,
                     dmem_write, dmem_addr, dmem_write_data);

            if (current_pc === 32'h0000003C) begin
                trap_counter = trap_counter + 1;
            end
        end

        $display("--------------------------------------------------------------------------------");
        $display("Execution halted at Cycle %0d. Evaluating Program 2 Results...", cycle_count);

        // Verification of Program 2
        overall_tests = overall_tests + 1;
        debug_mem_addr = 32'd5; // Word index 5 (byte offset 20)
        #5;
        if (debug_mem_data === 32'h0000000B) begin
            $display("PASS: Data Memory Word 5 (byte 20) contains 11 (0x0000000B)!");
        end else begin
            $display("FAIL: Data Memory Word 5 mismatch! Got: 0x%08h (%0d), Expected: 0x0000000B (11)",
                     debug_mem_data, debug_mem_data);
            errors = errors + 1;
        end

        overall_tests = overall_tests + 1;
        debug_reg_addr = 5'd16; // $s0 (current max)
        #5;
        if (debug_reg_data === 32'h0000000B) begin
            $display("PASS: Register $s0 ($16) contains 11 (0x0000000B)!");
        end else begin
            $display("FAIL: Register $s0 mismatch! Got: 0x%08h, Expected: 0x0000000B", debug_reg_data);
            errors = errors + 1;
        end

        $display("Program 2 Performance Summary: %0d Clock Cycles, CPI = 1.00", cycle_count);
        $display("================================================================================\n");

        if (errors == 0) begin
            $display("PROGRAM 2 (MAXIMUM SEARCH) VERIFICATION: ALL %0d CHECKS PASSED!", overall_tests);
        end else begin
            $display("PROGRAM 2 (MAXIMUM SEARCH) VERIFICATION: FAILED with %0d errors!", errors);
            $fatal(1);
        end

        $finish;
    end

endmodule
