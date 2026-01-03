`timescale 1ns/1ps
module dmem_model #(
  parameter int ADDR_W = 12,              // 4K words
  parameter int DATA_W = 32,
  parameter int DEPTH  = (1 << ADDR_W)
)(
  input  logic                 clk,

  // Write port
  input  logic                 dmem_wen,
  input  logic [ADDR_W-1:0]    dmem_waddr,
  input  logic [DATA_W-1:0]    dmem_wdata,

  // Read port
  input  logic                 dmem_ren,
  input  logic [ADDR_W-1:0]    dmem_raddr,
  output logic [DATA_W-1:0]    dmem_rdata
);

  logic [DATA_W-1:0] mem [0:DEPTH-1];

  // Write port (sync)
  always_ff @(posedge clk) begin
    if (dmem_wen) begin
      mem[dmem_waddr] <= dmem_wdata;
    end
  end

//  // Read port (sync, 1-cycle latency)
//  always_ff @(posedge clk) begin
//    if (dmem_ren) begin
//      if (dmem_wen && (dmem_waddr == dmem_raddr))
//        dmem_rdata <= dmem_wdata;   // write-through
//      else
//        dmem_rdata <= mem[dmem_raddr];
//    end
//  end
always_comb begin /// Making it combo for single cycle operation
  dmem_rdata = '0;
  if (dmem_ren) begin
    if (dmem_wen && (dmem_waddr == dmem_raddr))
      dmem_rdata = dmem_wdata;        // write-through / bypass
    else
      dmem_rdata = mem[dmem_raddr];
  end
end
  
  // TB helper: write memory directly
  task automatic write_word(input int addr, input logic [DATA_W-1:0] data);
    mem[addr] = data;
  endtask

  // TB helper: read memory directly
  function automatic logic [DATA_W-1:0] read_word(input int addr);
    return mem[addr];
  endfunction

endmodule
