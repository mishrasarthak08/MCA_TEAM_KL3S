// =============================================================================
// Testbench: tb_decoder
// Description: Self-checking testbench for Main Instruction Decoder and ALU Control.
//              Verifies all supported opcodes, invalid opcode defaults,
//              and all R-type funct field decodings.
// =============================================================================

`timescale 1ns / 1ps

module tb_decoder;

    reg  [5:0] opcode;
    wire       reg_dst;
    wire       alu_src;
    wire       mem_to_reg;
    wire       reg_write;
    wire       mem_read;
    wire       mem_write;
    wire       branch;
    wire       jump;
    wire [1:0] alu_op;
    wire       invalid_opcode;

    reg  [1:0] ctrl_alu_op;
    reg  [5:0] funct;
    wire [3:0] alu_ctrl;
    wire       invalid_funct;

    integer errors = 0;
    integer tests  = 0;

    // Instantiate Main Decoder
    mips_decoder uut_decoder (
        .opcode         (opcode),
        .reg_dst        (reg_dst),
        .alu_src        (alu_src),
        .mem_to_reg     (mem_to_reg),
        .reg_write      (reg_write),
        .mem_read       (mem_read),
        .mem_write      (mem_write),
        .branch         (branch),
        .jump           (jump),
        .alu_op         (alu_op),
        .invalid_opcode (invalid_opcode)
    );

    // Instantiate ALU Control
    alu_control uut_alu_ctrl (
        .alu_op        (ctrl_alu_op),
        .funct         (funct),
        .alu_ctrl      (alu_ctrl),
        .invalid_funct (invalid_funct)
    );

    task check_decoder(
        input [5:0]   op,
        input         e_reg_dst,
        input         e_alu_src,
        input         e_mem_to_reg,
        input         e_reg_write,
        input         e_mem_read,
        input         e_mem_write,
        input         e_branch,
        input         e_jump,
        input [1:0]   e_alu_op,
        input         e_invalid,
        input [255:0] desc
    );
        begin
            tests = tests + 1;
            opcode = op;
            #10;
            if (reg_dst !== e_reg_dst || alu_src !== e_alu_src || mem_to_reg !== e_mem_to_reg ||
                reg_write !== e_reg_write || mem_read !== e_mem_read || mem_write !== e_mem_write ||
                branch !== e_branch || jump !== e_jump || alu_op !== e_alu_op || invalid_opcode !== e_invalid) begin
                $display("FAIL: Decoder [%0s] (opcode 6'b%b) mismatch!", desc, op);
                $display("  Got:      reg_dst=%b, alu_src=%b, mem_to_reg=%b, reg_write=%b, mem_read=%b, mem_write=%b, branch=%b, jump=%b, alu_op=%b, invalid=%b",
                         reg_dst, alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch, jump, alu_op, invalid_opcode);
                $display("  Expected: reg_dst=%b, alu_src=%b, mem_to_reg=%b, reg_write=%b, mem_read=%b, mem_write=%b, branch=%b, jump=%b, alu_op=%b, invalid=%b",
                         e_reg_dst, e_alu_src, e_mem_to_reg, e_reg_write, e_mem_read, e_mem_write, e_branch, e_jump, e_alu_op, e_invalid);
                errors = errors + 1;
            end else begin
                $display("PASS: Decoder [%0s] (opcode 6'b%b)", desc, op);
            end
        end
    endtask

    task check_alu_ctrl(
        input [1:0]   op_type,
        input [5:0]   fn,
        input [3:0]   e_ctrl,
        input         e_invalid,
        input [255:0] desc
    );
        begin
            tests = tests + 1;
            ctrl_alu_op = op_type;
            funct       = fn;
            #10;
            if (alu_ctrl !== e_ctrl || invalid_funct !== e_invalid) begin
                $display("FAIL: ALU Control [%0s] (alu_op=%b, funct=6'b%b) mismatch!", desc, op_type, fn);
                $display("  Got: alu_ctrl=%b, invalid=%b | Expected: alu_ctrl=%b, invalid=%b",
                         alu_ctrl, invalid_funct, e_ctrl, e_invalid);
                errors = errors + 1;
            end else begin
                $display("PASS: ALU Control [%0s] -> ctrl=4'b%b", desc, alu_ctrl);
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/tb_decoder.vcd");
        $dumpvars(0, tb_decoder);

        $display("=================================================");
        $display("Starting Self-Checking Testbench: tb_decoder");
        $display("=================================================");

        // --- Opcode Decoding Tests ---
        // R-Type: opcode=0x00
        check_decoder(6'b000000, 1'b1, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b10, 1'b0, "R-Type");

        // ADDI: opcode=0x08
        check_decoder(6'b001000, 1'b0, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, "ADDI");

        // LW: opcode=0x23
        check_decoder(6'b100011, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 2'b00, 1'b0, "LW");

        // SW: opcode=0x2B
        check_decoder(6'b101011, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 2'b00, 1'b0, "SW");

        // BEQ: opcode=0x04
        check_decoder(6'b000100, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 2'b01, 1'b0, "BEQ");

        // J: opcode=0x02
        check_decoder(6'b000010, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00, 1'b0, "J");

        // Invalid Opcode: 0x3F (6'b111111)
        check_decoder(6'b111111, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b1, "Invalid_3F");

        // Invalid Opcode: 0x15 (6'b010101)
        check_decoder(6'b010101, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00, 1'b1, "Invalid_15");

        // --- ALU Control Tests ---
        // alu_op=00 -> ADD (4'b0010)
        check_alu_ctrl(2'b00, 6'b000000, 4'b0010, 1'b0, "ALUOp00_LW_SW_ADDI");

        // alu_op=01 -> SUB (4'b0110)
        check_alu_ctrl(2'b01, 6'b000000, 4'b0110, 1'b0, "ALUOp01_BEQ");

        // alu_op=10 -> Funct checks
        check_alu_ctrl(2'b10, 6'b100000, 4'b0010, 1'b0, "R_ADD");
        check_alu_ctrl(2'b10, 6'b100010, 4'b0110, 1'b0, "R_SUB");
        check_alu_ctrl(2'b10, 6'b100100, 4'b0000, 1'b0, "R_AND");
        check_alu_ctrl(2'b10, 6'b100101, 4'b0001, 1'b0, "R_OR");
        check_alu_ctrl(2'b10, 6'b100110, 4'b0011, 1'b0, "R_XOR");
        check_alu_ctrl(2'b10, 6'b101010, 4'b0111, 1'b0, "R_SLT");
        check_alu_ctrl(2'b10, 6'b111111, 4'b1111, 1'b1, "R_InvalidFunct");

        $display("=================================================");
        if (errors == 0) begin
            $display("DECODER TESTBENCH: ALL %0d TESTS PASSED!", tests);
            $display("=================================================");
            $finish;
        end else begin
            $display("DECODER TESTBENCH: %0d / %0d TESTS FAILED!", errors, tests);
            $display("=================================================");
            $fatal(1);
        end
    end

endmodule
