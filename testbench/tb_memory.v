// =============================================================================
// Testbench: tb_memory
// Description: Self-checking testbench for Instruction Memory and Data Memory.
//              Verifies:
//              - Combinational reads and word-aligned addressing.
//              - Synchronous memory writes (SW).
//              - Hex file initialization ($readmemh).
//              - Address bounds checking and unaligned access detection.
// =============================================================================

`timescale 1ns / 1ps

module tb_memory;

    // Clock
    reg clk;
    always #5 clk = ~clk;

    // Instruction Memory Wires
    reg  [31:0] imem_addr;
    wire [31:0] imem_data;
    wire        imem_align_err;
    wire        imem_oob_err;

    // Data Memory Wires
    reg         dmem_read;
    reg         dmem_write;
    reg  [31:0] dmem_addr;
    reg  [31:0] dmem_wdata;
    wire [31:0] dmem_rdata;
    wire        dmem_align_err;
    wire        dmem_oob_err;
    reg  [31:0] debug_mem_addr;
    wire [31:0] debug_mem_data;

    integer errors = 0;
    integer tests  = 0;

    // Instantiate Instruction Memory initialized with array_sum.hex
    instruction_memory #(
        .MEM_DEPTH     (256),
        .MEM_INIT_FILE ("programs/array_sum.hex"),
        .MEM_INIT_WORDS(13)
    ) uut_imem (
        .addr            (imem_addr),
        .instruction     (imem_data),
        .alignment_error (imem_align_err),
        .out_of_bounds   (imem_oob_err)
    );

    // Instantiate Data Memory initialized with array_sum_data.hex
    data_memory #(
        .MEM_DEPTH     (256),
        .MEM_INIT_FILE ("programs/array_sum_data.hex"),
        .MEM_INIT_WORDS(6)
    ) uut_dmem (
        .clk             (clk),
        .mem_read        (dmem_read),
        .mem_write       (dmem_write),
        .addr            (dmem_addr),
        .write_data      (dmem_wdata),
        .read_data       (dmem_rdata),
        .alignment_error (dmem_align_err),
        .out_of_bounds   (dmem_oob_err),
        .debug_word_addr (debug_mem_addr),
        .debug_word_data (debug_mem_data)
    );

    initial begin
        $dumpfile("waveforms/tb_memory.vcd");
        $dumpvars(0, tb_memory);

        clk            = 0;
        imem_addr      = 0;
        dmem_read      = 0;
        dmem_write     = 0;
        dmem_addr      = 0;
        dmem_wdata     = 0;
        debug_mem_addr = 0;

        $display("=================================================");
        $display("Starting Self-Checking Testbench: tb_memory");
        $display("=================================================");

        #15;

        // --- Instruction Memory Tests ---
        // Test 1: First instruction at byte address 0 (ADDI $t0, $zero, 0 = 0x20080000)
        tests = tests + 1;
        imem_addr = 32'h00000000;
        #5;
        if (imem_data !== 32'h20080000 || imem_align_err !== 1'b0 || imem_oob_err !== 1'b0) begin
            $display("FAIL: IMEM[0x0] mismatch! Got: 0x%08h, align=%b, oob=%b", imem_data, imem_align_err, imem_oob_err);
            errors = errors + 1;
        end else begin
            $display("PASS: IMEM[0x0] read correctly (0x%08h)", imem_data);
        end

        // Test 2: Fourth instruction at byte address 0x0C (ADDI $s0, $zero, 0 = 0x20100000)
        tests = tests + 1;
        imem_addr = 32'h0000000C;
        #5;
        if (imem_data !== 32'h20100000) begin
            $display("FAIL: IMEM[0xC] mismatch! Got: 0x%08h", imem_data);
            errors = errors + 1;
        end else begin
            $display("PASS: IMEM[0xC] read correctly (0x%08h)", imem_data);
        end

        // Test 3: Unaligned IMEM address (e.g. 0x00000002)
        tests = tests + 1;
        imem_addr = 32'h00000002;
        #5;
        if (imem_align_err !== 1'b1 || imem_data !== 32'h00000000) begin
            $display("FAIL: IMEM unaligned access did not flag alignment_error! Got: align=%b, data=0x%08h",
                     imem_align_err, imem_data);
            errors = errors + 1;
        end else begin
            $display("PASS: IMEM unaligned address (0x2) correctly flagged alignment error");
        end

        // Test 4: Out-of-bounds IMEM address (0x00002000 > 1024 bytes)
        tests = tests + 1;
        imem_addr = 32'h00002000;
        #5;
        if (imem_oob_err !== 1'b1 || imem_data !== 32'h00000000) begin
            $display("FAIL: IMEM out-of-bounds did not flag out_of_bounds! Got: oob=%b, data=0x%08h",
                     imem_oob_err, imem_data);
            errors = errors + 1;
        end else begin
            $display("PASS: IMEM out-of-bounds correctly flagged out_of_bounds error");
        end

        // --- Data Memory Tests ---
        // Test 5: Verify hex file initialization from array_sum_data.hex: [3, 1, 4, 1, 5]
        begin : check_dmem_init
            integer w;
            reg [31:0] expected_vals [0:4];
            expected_vals[0] = 32'd3;
            expected_vals[1] = 32'd1;
            expected_vals[2] = 32'd4;
            expected_vals[3] = 32'd1;
            expected_vals[4] = 32'd5;

            for (w = 0; w < 5; w = w + 1) begin
                tests = tests + 1;
                dmem_read = 1;
                dmem_addr = w * 4;
                #5;
                if (dmem_rdata !== expected_vals[w]) begin
                    $display("FAIL: DMEM byte addr 0x%02h read mismatch! Got: 0x%08h, Expected: 0x%08h",
                             w * 4, dmem_rdata, expected_vals[w]);
                    errors = errors + 1;
                end else begin
                    $display("PASS: DMEM byte addr 0x%02h read element %0d: %0d", w * 4, w, dmem_rdata);
                end
            end
        end

        // Test 6: Synchronous Store Word (SW) to byte address 20 (word 5)
        tests = tests + 1;
        @(posedge clk);
        dmem_read  = 0;
        dmem_write = 1;
        dmem_addr  = 32'd20;        // word 5
        dmem_wdata = 32'h0000000E;  // 14
        @(posedge clk);
        dmem_write = 0;
        dmem_read  = 1;
        #5;
        if (dmem_rdata !== 32'h0000000E) begin
            $display("FAIL: DMEM SW to byte 20 failed! Got: 0x%08h, Expected: 0x0000000E", dmem_rdata);
            errors = errors + 1;
        end else begin
            $display("PASS: DMEM SW to byte 20 verified: read back 0x%08h (%0d)", dmem_rdata, dmem_rdata);
        end

        // Test 7: Debug Port reads word 5 directly
        tests = tests + 1;
        debug_mem_addr = 32'd5;
        #5;
        if (debug_mem_data !== 32'h0000000E) begin
            $display("FAIL: Debug Port mismatch on word 5! Got: 0x%08h", debug_mem_data);
            errors = errors + 1;
        end else begin
            $display("PASS: Debug Port verified: word 5 = 0x%08h", debug_mem_data);
        end

        // Test 8: Unaligned SW attempt (addr = 21) -> must be blocked
        tests = tests + 1;
        @(posedge clk);
        dmem_write = 1;
        dmem_addr  = 32'd21;
        dmem_wdata = 32'hBAD0BAD0;
        #1;
        if (dmem_align_err !== 1'b1) begin
            $display("FAIL: DMEM unaligned write did not assert alignment_error!");
            errors = errors + 1;
        end
        @(posedge clk);
        dmem_write = 0;
        // Verify word 5 was not corrupted
        dmem_read = 1;
        dmem_addr = 32'd20;
        #5;
        if (dmem_rdata !== 32'h0000000E) begin
            $display("FAIL: Unaligned write corrupted adjacent word! Got: 0x%08h", dmem_rdata);
            errors = errors + 1;
        end else begin
            $display("PASS: Unaligned write blocked successfully; word 5 intact");
        end

        $display("=================================================");
        if (errors == 0) begin
            $display("MEMORY TESTBENCH: ALL %0d TESTS PASSED!", tests);
            $display("=================================================");
            $finish;
        end else begin
            $display("MEMORY TESTBENCH: %0d / %0d TESTS FAILED!", errors, tests);
            $display("=================================================");
            $fatal(1);
        end
    end

endmodule
