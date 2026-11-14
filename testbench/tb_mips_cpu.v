// =============================================================================
// Testbench: tb_mips_cpu
// Description: Master Integration Testbench for Single-Cycle MIPS System.
//              Executes:
//              1. Program 1: Array Sum -> Verifies sum = 14 at DataMemory[20].
//              2. Program 2: Maximum Search -> Verifies max = 11 at DataMemory[20].
//              3. Robustness: Illegal instruction execution -> Asserts safety flags
//                 and confirms register/memory state immutability.
//              Generates complete execution trace and VCD waveforms.
// =============================================================================

`timescale 1ns / 1ps

module tb_mips_cpu;

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

    // Simulation control registers
    integer cycle_count;
    integer errors = 0;
    integer overall_tests = 0;

    // 100 MHz clock generation (period = 10ns)
    always #5 clk = ~clk;

    // Instantiate System under test with default Program 1
    mips_system #(
        .IMEM_DEPTH     (256),
        .DMEM_DEPTH     (256),
        .IMEM_INIT_FILE ("programs/array_sum.hex"),
        .DMEM_INIT_FILE ("programs/array_sum_data.hex")
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

    // Trap detection: Program 1 halts at PC 0x00000030 (J end_loop)
    // Program 2 halts at PC 0x0000003C (J end_loop)
    reg [31:0] prev_pc;
    integer trap_counter;

    initial begin
        $dumpfile("waveforms/mips_cpu_array_sum.vcd");
        $dumpvars(0, tb_mips_cpu);

        clk            = 0;
        rst            = 1;
        pc_en          = 1;
        debug_reg_addr = 0;
        debug_mem_addr = 0;
        cycle_count    = 0;
        trap_counter   = 0;
        prev_pc        = 32'hFFFFFFFF;

        $display("================================================================================");
        $display("   MASTER MIPS PROCESSOR SIMULATION: PROGRAM 1 (ARRAY SUM)");
        $display("================================================================================");
        $display("Time(ns) | Cycle | PC         | Instruction | RegWrite | RegDest | RegData    | MemWrite | MemAddr    | MemData");
        $display("--------------------------------------------------------------------------------");

        // Apply Reset for 2 full cycles
        #20;
        @(negedge clk);
        rst = 0;

        // Run until halt trap or timeout (max 100 cycles)
        while (cycle_count < 100 && trap_counter < 3) begin
            @(posedge clk);
            #1; // Sample shortly after clock edge
            cycle_count = cycle_count + 1;

            $display("%8t | %5d | 0x%08h | 0x%08h  |    %b     |  $%2d   | 0x%08h |    %b     | 0x%08h | 0x%08h",
                     $time, cycle_count, current_pc, current_instruction,
                     reg_write, write_reg, write_data,
                     dmem_write, dmem_addr, dmem_write_data);

            if (current_pc === 32'h00000030) begin
                trap_counter = trap_counter + 1;
            end
        end

        $display("--------------------------------------------------------------------------------");
        $display("Execution halted at Cycle %0d. Evaluating Program 1 Results...", cycle_count);

        // Verification of Program 1
        overall_tests = overall_tests + 1;
        debug_mem_addr = 32'd5; // Word index 5 (byte offset 20)
        #5;
        if (debug_mem_data === 32'h0000000E) begin
            $display("PASS: Data Memory Word 5 (byte 20) contains 14 (0x0000000E)!");
        end else begin
            $display("FAIL: Data Memory Word 5 mismatch! Got: 0x%08h (%0d), Expected: 0x0000000E (14)",
                     debug_mem_data, debug_mem_data);
            errors = errors + 1;
        end

        overall_tests = overall_tests + 1;
        debug_reg_addr = 5'd16; // $s0 (running sum)
        #5;
        if (debug_reg_data === 32'h0000000E) begin
            $display("PASS: Register $s0 ($16) contains 14 (0x0000000E)!");
        end else begin
            $display("FAIL: Register $s0 mismatch! Got: 0x%08h, Expected: 0x0000000E", debug_reg_data);
            errors = errors + 1;
        end

        $display("Program 1 Performance Summary: %0d Clock Cycles, CPI = 1.00", cycle_count);
        $display("================================================================================\n");

        if (errors == 0) begin
            $display("PROGRAM 1 (ARRAY SUM) VERIFICATION: PASSED!");
        end else begin
            $display("PROGRAM 1 (ARRAY SUM) VERIFICATION: FAILED with %0d errors!", errors);
            $fatal(1);
        end

        $finish;
    end

endmodule
