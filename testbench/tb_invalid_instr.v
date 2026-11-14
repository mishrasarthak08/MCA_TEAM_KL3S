// =============================================================================
// Testbench: tb_invalid_instr
// Description: Architectural Robustness Testbench for MIPS Processor.
//              Verifies that illegal/unsupported instructions (e.g. invalid opcode
//              or invalid funct) assert the invalid_instruction flag,
//              suppress register write enable (reg_write) and memory write enable
//              (dmem_write), and leave architectural state completely unchanged.
// =============================================================================

`timescale 1ns / 1ps

module tb_invalid_instr;

    reg clk;
    reg rst;
    reg pc_en;
    reg [31:0] test_instruction;
    reg [31:0] test_dmem_rdata;

    wire [31:0] pc;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_write_data;
    wire        dmem_read;
    wire        dmem_write;
    wire [31:0] debug_alu_result;
    wire        debug_reg_write;
    wire [4:0]  debug_write_reg;
    wire [31:0] debug_write_data;
    wire        debug_branch_taken;
    wire        debug_jump_taken;
    wire        debug_invalid_instruction;
    reg  [4:0]  debug_reg_addr;
    wire [31:0] debug_reg_data;

    integer errors = 0;
    integer tests  = 0;

    always #5 clk = ~clk;

    // Direct instantiation of core to inject custom instruction sequences
    mips_core core_inst (
        .clk                       (clk),
        .rst                       (rst),
        .pc_en                     (pc_en),
        .pc                        (pc),
        .instruction               (test_instruction),
        .dmem_addr                 (dmem_addr),
        .dmem_write_data           (dmem_write_data),
        .dmem_read                 (dmem_read),
        .dmem_write                (dmem_write),
        .dmem_read_data            (test_dmem_rdata),
        .debug_alu_result          (debug_alu_result),
        .debug_reg_write           (debug_reg_write),
        .debug_write_reg           (debug_write_reg),
        .debug_write_data          (debug_write_data),
        .debug_branch_taken        (debug_branch_taken),
        .debug_jump_taken          (debug_jump_taken),
        .debug_invalid_instruction (debug_invalid_instruction),
        .debug_reg_addr            (debug_reg_addr),
        .debug_reg_data            (debug_reg_data)
    );

    initial begin
        $dumpfile("waveforms/tb_invalid_instr.vcd");
        $dumpvars(0, tb_invalid_instr);

        clk              = 0;
        rst              = 1;
        pc_en            = 1;
        test_instruction = 32'h00000000;
        test_dmem_rdata  = 32'h00000000;
        debug_reg_addr   = 5'd0;

        $display("=================================================");
        $display("Starting Robustness Testbench: tb_invalid_instr");
        $display("=================================================");

        #20;
        rst = 0;
        #10;

        // Step 1: Write a known value (0x12345678) into $t0 ($8) via valid ADDI
        // ADDI $t0, $zero, 0x1234 (sign extended) -> 32'h20081234
        @(posedge clk);
        test_instruction = 32'h20081234;
        #1;
        tests = tests + 1;
        if (debug_reg_write !== 1'b1 || debug_invalid_instruction !== 1'b0) begin
            $display("FAIL: Valid ADDI not recognized!");
            errors = errors + 1;
        end else begin
            $display("PASS: Valid ADDI instruction recognized (reg_write=1, invalid=0)");
        end

        @(posedge clk);
        #1;
        // Verify $t0 was updated
        debug_reg_addr = 5'd8;
        #2;
        tests = tests + 1;
        if (debug_reg_data !== 32'h00001234) begin
            $display("FAIL: $t0 write failed! Got: 0x%08h", debug_reg_data);
            errors = errors + 1;
        end else begin
            $display("PASS: $t0 holds 0x00001234");
        end

        // Step 2: Inject an Illegal Opcode (e.g. 0x3F: opcode 6'b111111 targeting $t0 with data)
        // 32'hFC08FFFF
        test_instruction = 32'hFC08FFFF;
        #2;
        tests = tests + 1;
        if (debug_invalid_instruction !== 1'b1 || debug_reg_write !== 1'b0 || dmem_write !== 1'b0) begin
            $display("FAIL: Illegal opcode not suppressed! invalid=%b, reg_write=%b, mem_write=%b",
                     debug_invalid_instruction, debug_reg_write, dmem_write);
            errors = errors + 1;
        end else begin
            $display("PASS: Illegal Opcode 0x3F safely flagged and suppressed writes (reg_write=0, dmem_write=0)");
        end

        @(posedge clk);
        #1;
        // Verify $t0 is unchanged
        debug_reg_addr = 5'd8;
        #2;
        tests = tests + 1;
        if (debug_reg_data !== 32'h00001234) begin
            $display("FAIL: State corrupted by illegal opcode! Got: 0x%08h", debug_reg_data);
            errors = errors + 1;
        end else begin
            $display("PASS: Architectural state ($t0) preserved across illegal opcode");
        end

        // Step 3: Inject an R-type with Illegal Funct field (opcode=0x00, funct=0x3F)
        // 32'h0109403F targeting $t0
        test_instruction = 32'h0109403F;
        #2;
        tests = tests + 1;
        if (debug_invalid_instruction !== 1'b1 || debug_reg_write !== 1'b0 || dmem_write !== 1'b0) begin
            $display("FAIL: Illegal R-type funct not suppressed! invalid=%b, reg_write=%b",
                     debug_invalid_instruction, debug_reg_write);
            errors = errors + 1;
        end else begin
            $display("PASS: Illegal Funct 0x3F safely flagged and suppressed writes");
        end

        @(posedge clk);
        #1;
        // Verify $t0 remains intact
        debug_reg_addr = 5'd8;
        #2;
        tests = tests + 1;
        if (debug_reg_data !== 32'h00001234) begin
            $display("FAIL: State corrupted by illegal funct! Got: 0x%08h", debug_reg_data);
            errors = errors + 1;
        end else begin
            $display("PASS: Architectural state ($t0) preserved across illegal funct");
        end

        $display("=================================================");
        if (errors == 0) begin
            $display("ROBUSTNESS TESTBENCH: ALL %0d TESTS PASSED!", tests);
            $display("=================================================");
            $finish;
        end else begin
            $display("ROBUSTNESS TESTBENCH: %0d / %0d TESTS FAILED!", errors, tests);
            $display("=================================================");
            $fatal(1);
        end
    end

endmodule
