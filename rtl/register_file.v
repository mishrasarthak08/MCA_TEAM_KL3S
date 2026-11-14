// =============================================================================
// Module: register_file
// Description: 32 x 32-bit General Purpose Register File for MIPS32.
//              - Two combinational/asynchronous read ports (RS, RT).
//              - One synchronous write port (RD / RT) gated by reg_write.
//              - Register $zero ($0) hardwired to 0; write attempts to $0 are ignored.
//              - Dedicated debug port for external verification and introspection.
// =============================================================================

`timescale 1ns / 1ps

module register_file (
    input  wire        clk,
    input  wire        rst,
    input  wire        reg_write,
    input  wire [4:0]  read_reg1,       // rs address
    input  wire [4:0]  read_reg2,       // rt address
    input  wire [4:0]  write_reg,       // write destination address
    input  wire [31:0] write_data,      // data to write
    output wire [31:0] read_data1,      // rs data out
    output wire [31:0] read_data2,      // rt data out
    // Debug Inspection Port
    input  wire [4:0]  debug_reg_addr,
    output wire [31:0] debug_reg_data
);

    reg [31:0] registers [0:31];
    integer i;

    // Asynchronous read ports: $zero is permanently 0
    assign read_data1 = (read_reg1 == 5'd0) ? 32'd0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 5'd0) ? 32'd0 : registers[read_reg2];
    assign debug_reg_data = (debug_reg_addr == 5'd0) ? 32'd0 : registers[debug_reg_addr];

    // Synchronous write port with asynchronous active-high reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'd0;
            end
        end else begin
            if (reg_write && (write_reg != 5'd0)) begin
                registers[write_reg] <= write_data;
            end
        end
    end

endmodule
