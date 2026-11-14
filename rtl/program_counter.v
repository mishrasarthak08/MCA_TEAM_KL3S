// =============================================================================
// Module: program_counter
// Description: 32-bit Program Counter register with asynchronous active-high reset.
//              Holds the byte address of the current instruction to be executed.
// =============================================================================

`timescale 1ns / 1ps

module program_counter (
    input  wire        clk,
    input  wire        rst,
    input  wire        pc_en,
    input  wire [31:0] pc_in,
    output reg  [31:0] pc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'h00000000;
        end else if (pc_en) begin
            pc_out <= pc_in;
        end
    end

endmodule
