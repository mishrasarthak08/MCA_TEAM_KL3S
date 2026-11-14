// =============================================================================
// Module: data_memory
// Description: Synchronous-write, asynchronous-read RAM for Single-Cycle MIPS.
//              - Byte-addressed memory with 32-bit aligned accesses (addr[1:0] == 00).
//              - Word address = addr[31:2].
//              - Bounds and alignment checking with dedicated error flags.
//              - Parameterized depth and hex initialization support.
// =============================================================================

`timescale 1ns / 1ps

module data_memory #(
    parameter MEM_DEPTH = 256,              // Depth in 32-bit words (256 words = 1KB)
    parameter MEM_INIT_FILE = "",           // Path to initial hex file
    parameter MEM_INIT_WORDS = MEM_DEPTH    // Number of words present in the image
)(
    input  wire        clk,
    input  wire        mem_read,            // Memory read enable (from LW)
    input  wire        mem_write,           // Memory write enable (from SW)
    input  wire [31:0] addr,                // Byte address from ALU result
    input  wire [31:0] write_data,          // Data to write (from register rt)
    output wire [31:0] read_data,           // Read data to write-back multiplexer
    output wire        alignment_error,     // Flag for unaligned accesses
    output wire        out_of_bounds,       // Flag for access beyond MEM_DEPTH
    // Debug Inspection Port
    input  wire [31:0] debug_word_addr,
    output wire [31:0] debug_word_data
);

    reg [31:0] mem [0:MEM_DEPTH-1];

    wire [29:0] word_addr = addr[31:2];

    assign alignment_error = (mem_read | mem_write) && (addr[1:0] != 2'b00);
    assign out_of_bounds   = (mem_read | mem_write) && (word_addr >= MEM_DEPTH);

    // Combinational read: if mem_read asserted and address is valid, return data; else 0
    assign read_data = (mem_read && !out_of_bounds && !alignment_error) ? mem[word_addr] : 32'd0;

    // Debug port readout
    assign debug_word_data = (debug_word_addr < MEM_DEPTH) ? mem[debug_word_addr] : 32'd0;

    // Synchronous write
    always @(posedge clk) begin
        if (mem_write && !out_of_bounds && !alignment_error) begin
            mem[word_addr] <= write_data;
        end
    end

    // Hex file initialization
    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem[i] = 32'd0;
        end
        if (MEM_INIT_FILE != "") begin
            $readmemh(MEM_INIT_FILE, mem, 0, MEM_INIT_WORDS - 1);
        end
    end

endmodule
