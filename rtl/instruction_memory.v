// =============================================================================
// Module: instruction_memory
// Description: ROM-based Instruction Memory for Single-Cycle MIPS.
//              Provides combinational read access indexed by byte address.
//              Handles word alignment (PC[31:2]) and out-of-bounds safety.
// =============================================================================

`timescale 1ns / 1ps

module instruction_memory #(
    parameter MEM_DEPTH = 256,             // Number of 32-bit instruction words
    parameter MEM_INIT_FILE = "",          // Path to initial hex file
    parameter MEM_INIT_WORDS = MEM_DEPTH   // Number of words present in the image
)(
    input  wire [31:0] addr,               // Byte address from Program Counter
    output wire [31:0] instruction,        // Fetched 32-bit instruction word
    output wire        alignment_error,    // Asserted if byte address is unaligned
    output wire        out_of_bounds       // Asserted if address exceeds memory depth
);

    // Memory array: MEM_DEPTH words of 32 bits
    reg [31:0] mem [0:MEM_DEPTH-1];

    // Word address derived from byte address
    wire [29:0] word_addr = addr[31:2];

    // Status / safety signals
    assign alignment_error = (addr[1:0] != 2'b00);
    assign out_of_bounds   = (word_addr >= MEM_DEPTH);

    // Combinational read with bounds checking; return NOP (32'h0) if out of bounds
    assign instruction = (!out_of_bounds && !alignment_error) ? mem[word_addr] : 32'h00000000;

    // Optional file initialization via $readmemh
    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem[i] = 32'h00000000;
        end
        if (MEM_INIT_FILE != "") begin
            $readmemh(MEM_INIT_FILE, mem, 0, MEM_INIT_WORDS - 1);
        end
    end

endmodule
