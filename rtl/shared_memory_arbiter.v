// =============================================================================
// Module: shared_memory_arbiter
// Description: Reference arbiter for a single-ported shared instruction/data
//              memory. Data requests receive priority. A blocked instruction
//              requester must hold its request until a later service slot.
//              This module is used only for the Harvard-vs-shared comparison.
// =============================================================================

`timescale 1ns / 1ps

module shared_memory_arbiter (
    input  wire instruction_request,
    input  wire data_request,
    output wire instruction_grant,
    output wire data_grant,
    output wire contention
);

    assign contention        = instruction_request & data_request;
    assign data_grant        = data_request;
    assign instruction_grant = instruction_request & ~data_request;

endmodule
