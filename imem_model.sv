// Instruction memory model: synchronous read on address change.
// Program is loaded through `$readmemh()` or by the load_program task in tb.sv.
`timescale 1ns/1ps
module imem_model #(parameter ADDR_WIDTH=12 , parameter DATA_WIDTH=32)(
    input  logic        clk,
   input  logic                  rst,     // active-low reset
    input  logic        imem_en,
  input  logic [ADDR_WIDTH-1:0] imem_addr,   // Address comes FROM CPU
    output logic [DATA_WIDTH-1:0] imem_instr   // Instruction goes TO CPU
);
  localparam integer DEPTH = 1 << ADDR_WIDTH;
    // 64K x 16-bit instruction memory
  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];  /// 32 bit instruction in each line instead of 8

    always_ff @(posedge clk or negedge rst) begin
    if (!rst)
      imem_instr <= '0;
    else if (imem_en)
      imem_instr <= mem[imem_addr];
    else
      imem_instr <= '0;
  end

    // Helper task to write a word into IMEM from TB
  task automatic write_word(input int addr, input logic [DATA_WIDTH-1:0] data);
        mem[addr] = data;
    endtask

    // Helper function to read mem from TB
  function logic [DATA_WIDTH-1:0] read_word(input int addr);
        return mem[addr];
    endfunction

endmodule
