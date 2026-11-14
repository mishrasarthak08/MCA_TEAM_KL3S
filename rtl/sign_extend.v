// =============================================================================
// Module: sign_extend
// Description: Converts a 16-bit immediate field from an I-type instruction
//              into a signed 32-bit two's complement value.
// =============================================================================

`timescale 1ns / 1ps

module sign_extend (
    input  wire [15:0] in16,
    output wire [31:0] out32
);

    assign out32 = {{16{in16[15]}}, in16};

endmodule
