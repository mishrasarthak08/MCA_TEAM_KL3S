// =============================================================================
// Testbench: tb_alu
// Description: Comprehensive self-checking testbench for 32-bit MIPS ALU.
//              Tests ADD, SUB, AND, OR, XOR, signed SLT (with positive/negative
//              combinations and extreme boundaries), and the Zero flag.
// =============================================================================

`timescale 1ns / 1ps

module tb_alu;

    reg  [31:0] a;
    reg  [31:0] b;
    reg  [3:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero;

    integer errors = 0;
    integer tests  = 0;

    // Instantiate Unit Under Test (UUT)
    alu uut (
        .a        (a),
        .b        (b),
        .alu_ctrl (alu_ctrl),
        .result   (result),
        .zero     (zero)
    );

    // ALU Operation Codes
    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_XOR = 4'b0011;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_SLT = 4'b0111;

    task check_alu(
        input [31:0] in_a,
        input [31:0] in_b,
        input [3:0]  ctrl,
        input [31:0] exp_res,
        input        exp_zero,
        input [127:0] test_name
    );
        begin
            tests = tests + 1;
            a = in_a;
            b = in_b;
            alu_ctrl = ctrl;
            #10;
            if (result !== exp_res || zero !== exp_zero) begin
                $display("FAIL: [%0s] a=0x%08h, b=0x%08h, ctrl=%b | Got: res=0x%08h, zero=%b | Expected: res=0x%08h, zero=%b",
                         test_name, in_a, in_b, ctrl, result, zero, exp_res, exp_zero);
                errors = errors + 1;
            end else begin
                $display("PASS: [%0s] a=0x%08h, b=0x%08h -> res=0x%08h, zero=%b",
                         test_name, in_a, in_b, result, zero);
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/tb_alu.vcd");
        $dumpvars(0, tb_alu);

        $display("=================================================");
        $display("Starting Self-Checking Testbench: tb_alu");
        $display("=================================================");

        // --- ADD Tests ---
        check_alu(32'd15, 32'd27, ALU_ADD, 32'd42, 1'b0, "ADD_Positive");
        check_alu(32'd0, 32'd0, ALU_ADD, 32'd0, 1'b1, "ADD_Zero");
        check_alu(32'hFFFFFFFF, 32'd1, ALU_ADD, 32'd0, 1'b1, "ADD_Overflow_Zero");
        check_alu(32'hFFFFFFFE, 32'd1, ALU_ADD, 32'hFFFFFFFF, 1'b0, "ADD_Negative");

        // --- SUB Tests ---
        check_alu(32'd50, 32'd20, ALU_SUB, 32'd30, 1'b0, "SUB_Positive");
        check_alu(32'd25, 32'd25, ALU_SUB, 32'd0, 1'b1, "SUB_Equal_Zero");
        check_alu(32'd10, 32'd20, ALU_SUB, -32'd10, 1'b0, "SUB_NegativeResult");

        // --- AND Tests ---
        check_alu(32'hA5A5A5A5, 32'h5A5A5A5A, ALU_AND, 32'h00000000, 1'b1, "AND_Disjoint");
        check_alu(32'hFFFF0000, 32'h00FFFF00, ALU_AND, 32'h00FF0000, 1'b0, "AND_Overlap");

        // --- OR Tests ---
        check_alu(32'hA5A50000, 32'h00005A5A, ALU_OR, 32'hA5A55A5A, 1'b0, "OR_Combine");
        check_alu(32'h00000000, 32'h00000000, ALU_OR, 32'h00000000, 1'b1, "OR_Zero");

        // --- XOR Tests ---
        check_alu(32'hFFFFFFFF, 32'hFFFFFFFF, ALU_XOR, 32'h00000000, 1'b1, "XOR_Same");
        check_alu(32'hAAAAAAAA, 32'h55555555, ALU_XOR, 32'hFFFFFFFF, 1'b0, "XOR_Alternating");

        // --- Signed SLT Tests ---
        // Positive vs Positive
        check_alu(32'd5, 32'd10, ALU_SLT, 32'd1, 1'b0, "SLT_Pos_Less");
        check_alu(32'd10, 32'd5, ALU_SLT, 32'd0, 1'b1, "SLT_Pos_Greater");
        check_alu(32'd7, 32'd7, ALU_SLT, 32'd0, 1'b1, "SLT_Pos_Equal");

        // Positive vs Negative
        check_alu(32'd5, -32'd10, ALU_SLT, 32'd0, 1'b1, "SLT_Pos_vs_Neg");
        check_alu(-32'd10, 32'd5, ALU_SLT, 32'd1, 1'b0, "SLT_Neg_vs_Pos");

        // Negative vs Negative
        check_alu(-32'd10, -32'd5, ALU_SLT, 32'd1, 1'b0, "SLT_Neg_MoreNeg");
        check_alu(-32'd5, -32'd10, ALU_SLT, 32'd0, 1'b1, "SLT_Neg_LessNeg");
        check_alu(-32'd8, -32'd8, ALU_SLT, 32'd0, 1'b1, "SLT_Neg_Equal");

        // Extreme Boundaries
        // 0x7FFFFFFF = +2,147,483,647 | 0x80000000 = -2,147,483,648
        check_alu(32'h80000000, 32'h7FFFFFFF, ALU_SLT, 32'd1, 1'b0, "SLT_MinNeg_MaxPos");
        check_alu(32'h7FFFFFFF, 32'h80000000, ALU_SLT, 32'd0, 1'b1, "SLT_MaxPos_MinNeg");

        $display("=================================================");
        if (errors == 0) begin
            $display("ALU TESTBENCH RESULT: ALL %0d TESTS PASSED!", tests);
            $display("=================================================");
            $finish;
        end else begin
            $display("ALU TESTBENCH RESULT: %0d / %0d TESTS FAILED!", errors, tests);
            $display("=================================================");
            $fatal(1);
        end
    end

endmodule
