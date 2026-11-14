// =============================================================================
// Module: writeback_logic
// Description: Multiplexers for selecting the destination register address
//              (rt vs rd) and the data to write back to the register file
//              (ALU result vs Data Memory read data).
// =============================================================================

`timescale 1ns / 1ps

module writeback_logic (
    input  wire        reg_dst,         // 0 -> rt, 1 -> rd
    input  wire        mem_to_reg,      // 0 -> alu_result, 1 -> mem_read_data
    input  wire [4:0]  rt,              // instruction[20:16]
    input  wire [4:0]  rd,              // instruction[15:11]
    input  wire [31:0] alu_result,      // Output from ALU
    input  wire [31:0] mem_read_data,   // Output from Data Memory
    output wire [4:0]  write_reg,       // Destination register index
    output wire [31:0] write_data       // Data to be written to register file
);

    // Register destination mux
    assign write_reg  = (reg_dst) ? rd : rt;

    // Write-back data source mux
    assign write_data = (mem_to_reg) ? mem_read_data : alu_result;

endmodule
