// =============================================================================
// Testbench: tb_branch_jump
// Description: Self-checking testbench for Branch and Jump Logic.
//              Verifies:
//              - Sequential PC increment (PC + 4).
//              - BEQ taken (branch=1 & zero=1).
//              - BEQ not taken (branch=1 & zero=0).
//              - Negative branch offsets (backward branches / loops).
//              - Positive branch offsets (forward branches).
//              - Unconditional Jump target calculation and priority over branch.
// =============================================================================

`timescale 1ns / 1ps

module tb_branch_jump;

    reg  [31:0] pc;
    reg  [31:0] sign_ext_imm;
    reg  [25:0] jump_target_26;
    reg         branch;
    reg         zero;
    reg         jump;

    wire [31:0] pc_plus_4;
    wire [31:0] branch_target;
    wire [31:0] jump_target;
    wire        take_branch;
    wire [31:0] next_pc;

    integer errors = 0;
    integer tests  = 0;

    // Instantiate Unit Under Test
    branch_jump_logic uut (
        .pc             (pc),
        .sign_ext_imm   (sign_ext_imm),
        .jump_target_26 (jump_target_26),
        .branch         (branch),
        .zero           (zero),
        .jump           (jump),
        .pc_plus_4      (pc_plus_4),
        .branch_target  (branch_target),
        .jump_target    (jump_target),
        .take_branch    (take_branch),
        .next_pc        (next_pc)
    );

    task check_case(
        input [31:0] in_pc,
        input [31:0] in_imm,
        input [25:0] in_j26,
        input        in_branch,
        input        in_zero,
        input        in_jump,
        input [31:0] exp_next_pc,
        input        exp_take_branch,
        input [255:0] desc
    );
        begin
            tests = tests + 1;
            pc             = in_pc;
            sign_ext_imm   = in_imm;
            jump_target_26 = in_j26;
            branch         = in_branch;
            zero           = in_zero;
            jump           = in_jump;
            #10;
            if (next_pc !== exp_next_pc || take_branch !== exp_take_branch) begin
                $display("FAIL: [%0s] mismatch!", desc);
                $display("  Got:      next_pc=0x%08h, take_branch=%b", next_pc, take_branch);
                $display("  Expected: next_pc=0x%08h, take_branch=%b", exp_next_pc, exp_take_branch);
                errors = errors + 1;
            end else begin
                $display("PASS: [%0s] -> next_pc=0x%08h, take_branch=%b", desc, next_pc, take_branch);
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/tb_branch_jump.vcd");
        $dumpvars(0, tb_branch_jump);

        $display("=================================================");
        $display("Starting Self-Checking Testbench: tb_branch_jump");
        $display("=================================================");

        // 1. Sequential execution (PC+4)
        // PC = 0x00000000 -> Next PC = 0x00000004
        check_case(32'h00000000, 32'd0, 26'd0, 1'b0, 1'b0, 1'b0, 32'h00000004, 1'b0, "Sequential_PC0");

        // 2. Sequential execution at 0x00000040 -> 0x00000044
        check_case(32'h00000040, 32'd0, 26'd0, 1'b0, 1'b0, 1'b0, 32'h00000044, 1'b0, "Sequential_PC40");

        // 3. BEQ Not Taken (branch=1, zero=0)
        // PC = 0x00000010, imm = 5 (target if taken = 0x14 + 20 = 0x28). Since zero=0, next_pc = 0x14
        check_case(32'h00000010, 32'd5, 26'd0, 1'b1, 1'b0, 1'b0, 32'h00000014, 1'b0, "BEQ_Not_Taken");

        // 4. BEQ Taken Forward (branch=1, zero=1)
        // PC = 0x00000010, imm = 5 -> next_pc = 0x00000014 + (5 << 2) = 0x00000028
        check_case(32'h00000010, 32'd5, 26'd0, 1'b1, 1'b1, 1'b0, 32'h00000028, 1'b1, "BEQ_Taken_Forward");

        // 5. BEQ Taken Backward / Loop (imm = -4 = 32'hFFFFFFFC)
        // PC = 0x00000020. PC+4 = 0x24. target = 0x24 + (-4 << 2) = 0x24 - 16 = 0x14
        check_case(32'h00000020, -32'd4, 26'd0, 1'b1, 1'b1, 1'b0, 32'h00000014, 1'b1, "BEQ_Taken_Backward");

        // 6. Unconditional Jump
        // PC = 0x00000024. PC+4 = 0x00000028. jump_target_26 = 26'h0000004 (target = 0x00000010)
        // next_pc = { 4'h0, 26'h4, 2'b00 } = 32'h00000010
        check_case(32'h00000024, 32'd0, 26'h0000004, 1'b0, 1'b0, 1'b1, 32'h00000010, 1'b0, "Jump_Target_0x10");

        // 7. Jump with high address bits retention ({PC+4[31:28], target, 2'b00})
        // PC = 0x20000000. PC+4 = 0x20000004. Top nibble = 0x2. target_26 = 26'h0001000
        // next_pc = 32'h20004000
        check_case(32'h20000000, 32'd0, 26'h0001000, 1'b0, 1'b0, 1'b1, 32'h20004000, 1'b0, "Jump_High_Nibble");

        // 8. Jump Priority over Branch (if jump=1 and take_branch=1, jump wins)
        check_case(32'h00000010, 32'd5, 26'h0000008, 1'b1, 1'b1, 1'b1, 32'h00000020, 1'b1, "Jump_Priority_Over_Branch");

        $display("=================================================");
        if (errors == 0) begin
            $display("BRANCH/JUMP TESTBENCH: ALL %0d TESTS PASSED!", tests);
            $display("=================================================");
            $finish;
        end else begin
            $display("BRANCH/JUMP TESTBENCH: %0d / %0d TESTS FAILED!", errors, tests);
            $display("=================================================");
            $fatal(1);
        end
    end

endmodule
