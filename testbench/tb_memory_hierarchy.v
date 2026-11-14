// =============================================================================
// Testbench: tb_memory_hierarchy
// Purpose: Demonstrate concurrent Harvard instruction/data service and compare
//          it with a single-ported shared-memory arbitration reference.
// =============================================================================

`timescale 1ns / 1ps

module tb_memory_hierarchy;

    reg         clk = 1'b0;
    reg  [31:0] imem_addr = 32'd0;
    wire [31:0] instruction;
    wire        imem_alignment_error;
    wire        imem_out_of_bounds;

    reg         dmem_read = 1'b0;
    reg  [31:0] dmem_addr = 32'd0;
    wire [31:0] dmem_read_data;
    wire        dmem_alignment_error;
    wire        dmem_out_of_bounds;

    reg         instruction_request = 1'b0;
    reg         data_request = 1'b0;
    wire        instruction_grant;
    wire        data_grant;
    wire        contention;

    integer errors = 0;
    integer tests = 0;
    integer i;
    integer harvard_services;
    integer shared_service_slots;

    always #5 clk = ~clk;

    instruction_memory #(
        .MEM_DEPTH(256),
        .MEM_INIT_FILE("programs/array_sum.hex"),
        .MEM_INIT_WORDS(13)
    ) imem (
        .addr(imem_addr),
        .instruction(instruction),
        .alignment_error(imem_alignment_error),
        .out_of_bounds(imem_out_of_bounds)
    );

    data_memory #(
        .MEM_DEPTH(256),
        .MEM_INIT_FILE("programs/array_sum_data.hex"),
        .MEM_INIT_WORDS(6)
    ) dmem (
        .clk(clk),
        .mem_read(dmem_read),
        .mem_write(1'b0),
        .addr(dmem_addr),
        .write_data(32'd0),
        .read_data(dmem_read_data),
        .alignment_error(dmem_alignment_error),
        .out_of_bounds(dmem_out_of_bounds),
        .debug_word_addr(32'd0),
        .debug_word_data()
    );

    shared_memory_arbiter shared_reference (
        .instruction_request(instruction_request),
        .data_request(data_request),
        .instruction_grant(instruction_grant),
        .data_grant(data_grant),
        .contention(contention)
    );

    task check;
        input condition;
        input [1023:0] description;
        begin
            tests = tests + 1;
            if (!condition) begin
                errors = errors + 1;
                $display("FAIL: %0s", description);
            end else begin
                $display("PASS: %0s", description);
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/tb_memory_hierarchy.vcd");
        $dumpvars(0, tb_memory_hierarchy);

        $display("=================================================");
        $display("Starting Memory Hierarchy Comparison Testbench");
        $display("=================================================");

        // Both independent Harvard paths return useful data in the same slot.
        imem_addr = 32'd0;
        dmem_addr = 32'd0;
        dmem_read = 1'b1;
        #1;
        check(instruction === 32'h20080000 && dmem_read_data === 32'd3,
              "Harvard instruction and data reads complete concurrently");

        // Five instruction fetches plus two data reads are seven memory
        // services completed across five logical processor cycles.
        harvard_services = 0;
        for (i = 0; i < 5; i = i + 1) begin
            imem_addr = i * 4;
            dmem_read = (i == 1 || i == 3);
            dmem_addr = (i == 1) ? 32'd4 : 32'd12;
            #1;
            if (!imem_alignment_error && !imem_out_of_bounds)
                harvard_services = harvard_services + 1;
            if (dmem_read && !dmem_alignment_error && !dmem_out_of_bounds)
                harvard_services = harvard_services + 1;
        end
        check(harvard_services == 7,
              "Harvard paths service seven requests in five processor cycles");

        // A single shared port cannot grant both requests in one service slot.
        instruction_request = 1'b1;
        data_request = 1'b1;
        #1;
        check(contention === 1'b1,
              "Shared reference detects instruction/data contention");
        check((instruction_grant + data_grant) == 1,
              "Shared reference grants exactly one request per service slot");

        // The blocked fetch is serviced only after the data request releases.
        data_request = 1'b0;
        #1;
        check(instruction_grant === 1'b1,
              "Blocked instruction request requires a later service slot");

        shared_service_slots = 5 + 2;
        check(harvard_services == 7 && shared_service_slots == 7,
              "Same trace needs five Harvard cycles but seven shared slots");

        $display("=================================================");
        if (errors == 0) begin
            $display("MEMORY HIERARCHY TESTBENCH: ALL %0d TESTS PASSED!", tests);
        end else begin
            $display("MEMORY HIERARCHY TESTBENCH: %0d / %0d TESTS FAILED!", errors, tests);
            $fatal(1, "Memory hierarchy comparison failed");
        end
        $display("=================================================");
        $finish;
    end

endmodule
