// =============================================================================
// Testbench: tb_register_file
// Description: Self-checking testbench for 32x32 Register File.
//              Verifies:
//              - Synchronous write and asynchronous dual-port read.
//              - Independent simultaneous dual-port reads.
//              - Invariance of $zero ($0): reads 0, writes ignored.
//              - Active-high reset clears all registers.
//              - Debug inspection port.
// =============================================================================

`timescale 1ns / 1ps

module tb_register_file;

    reg         clk;
    reg         rst;
    reg         reg_write;
    reg  [4:0]  read_reg1;
    reg  [4:0]  read_reg2;
    reg  [4:0]  write_reg;
    reg  [31:0] write_data;
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    reg  [4:0]  debug_reg_addr;
    wire [31:0] debug_reg_data;

    integer errors = 0;
    integer tests  = 0;

    // Instantiate UUT
    register_file uut (
        .clk            (clk),
        .rst            (rst),
        .reg_write      (reg_write),
        .read_reg1      (read_reg1),
        .read_reg2      (read_reg2),
        .write_reg      (write_reg),
        .write_data     (write_data),
        .read_data1     (read_data1),
        .read_data2     (read_data2),
        .debug_reg_addr (debug_reg_addr),
        .debug_reg_data (debug_reg_data)
    );

    // 100 MHz Clock Generator (10 ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("waveforms/tb_register_file.vcd");
        $dumpvars(0, tb_register_file);

        clk            = 0;
        rst            = 1;
        reg_write      = 0;
        read_reg1      = 0;
        read_reg2      = 0;
        write_reg      = 0;
        write_data     = 0;
        debug_reg_addr = 0;

        $display("=================================================");
        $display("Starting Self-Checking Testbench: tb_register_file");
        $display("=================================================");

        // Reset check
        #20;
        rst = 0;
        #10;

        // Test 1: Write $0 with 0xDEADBEEF -> Must remain 0
        tests = tests + 1;
        @(posedge clk);
        reg_write  = 1;
        write_reg  = 5'd0;
        write_data = 32'hDEADBEEF;
        @(posedge clk);
        reg_write  = 0;
        read_reg1  = 5'd0;
        #5;
        if (read_data1 !== 32'd0) begin
            $display("FAIL: $zero written with 0xDEADBEEF was not ignored! Got: 0x%08h", read_data1);
            errors = errors + 1;
        end else begin
            $display("PASS: Register $zero write was ignored and reads 0x00000000");
        end

        // Test 2: Write registers $1 to $31 with test patterns
        begin : write_registers_loop
            integer idx;
            for (idx = 1; idx < 32; idx = idx + 1) begin
                @(posedge clk);
                reg_write  = 1;
                write_reg  = idx[4:0];
                write_data = 32'h10000000 + idx;
            end
        end
        @(posedge clk);
        reg_write = 0;

        // Test 3: Verify all 31 registers via read ports 1 & 2 simultaneously
        begin : verify_registers_loop
            integer idx;
            for (idx = 1; idx < 32; idx = idx + 2) begin
                tests = tests + 1;
                read_reg1 = idx[4:0];
                read_reg2 = (idx < 31) ? (idx[4:0] + 5'd1) : 5'd0;
                #5;
                if (read_data1 !== (32'h10000000 + idx)) begin
                    $display("FAIL: Reg $%0d read_data1 mismatch! Got: 0x%08h, Expected: 0x%08h",
                             idx, read_data1, 32'h10000000 + idx);
                    errors = errors + 1;
                end else if (idx < 31 && read_data2 !== (32'h10000000 + idx + 1)) begin
                    $display("FAIL: Reg $%0d read_data2 mismatch! Got: 0x%08h, Expected: 0x%08h",
                             idx + 1, read_data2, 32'h10000000 + idx + 1);
                    errors = errors + 1;
                end else begin
                    $display("PASS: Dual read Port1[$%0d]=0x%08h, Port2[$%0d]=0x%08h",
                             idx, read_data1, (idx < 31) ? idx + 1 : 0, read_data2);
                end
            end
        end

        // Test 4: Verify debug port
        tests = tests + 1;
        debug_reg_addr = 5'd17; // $s1
        #5;
        if (debug_reg_data !== (32'h10000000 + 17)) begin
            $display("FAIL: Debug port mismatch on $17! Got: 0x%08h", debug_reg_data);
            errors = errors + 1;
        end else begin
            $display("PASS: Debug Port[$17] successfully read 0x%08h", debug_reg_data);
        end

        // Test 5: Verify asynchronous reset clears all registers
        tests = tests + 1;
        rst = 1;
        #10;
        rst = 0;
        #10;
        read_reg1 = 5'd5;
        read_reg2 = 5'd20;
        #5;
        if (read_data1 !== 32'd0 || read_data2 !== 32'd0) begin
            $display("FAIL: Reset did not clear registers! $5=0x%08h, $20=0x%08h", read_data1, read_data2);
            errors = errors + 1;
        end else begin
            $display("PASS: Reset verified. Registers cleared to 0x00000000.");
        end

        $display("=================================================");
        if (errors == 0) begin
            $display("REGISTER FILE TESTBENCH: ALL %0d TESTS PASSED!", tests);
            $display("=================================================");
            $finish;
        end else begin
            $display("REGISTER FILE TESTBENCH: %0d / %0d TESTS FAILED!", errors, tests);
            $display("=================================================");
            $fatal(1);
        end
    end

endmodule
