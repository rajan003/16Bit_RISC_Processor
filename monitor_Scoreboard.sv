`timescale 1ns/1ps

module monitor_scoreboard #(
  parameter int INST_ADDR_W = 12,
  parameter int INST_DATA_W = 32,
  parameter int DMEM_ADDR_W = 12,
  parameter int DMEM_DATA_W = 32
)(
  input  logic                    clk,
  input logic 					  rst,

  input  logic                    imem_en,
  input  logic [INST_ADDR_W-1:0]   imem_addr,
  input  logic [INST_DATA_W-1:0]   imem_instr,

  input  logic                    dmem_wen,
  input  logic [DMEM_ADDR_W-1:0]   dmem_waddr,
  input  logic [DMEM_DATA_W-1:0]   dmem_wdata,

  input  logic                    dmem_ren,
  input  logic [DMEM_ADDR_W-1:0]   dmem_raddr,
  input  logic [DMEM_DATA_W-1:0]   dmem_rdata,

  input  logic [3:0]              rf_wr_addr,
  input  logic [31:0]             rf_wr_data,
  input  logic                    rf_wr_en
);

  logic [31:0] ref_regfile [0:15];

  // pipeline the DMEM read request (1-cycle latency alignment)
  logic                   dmem_ren_q;
  logic [DMEM_ADDR_W-1:0] dmem_raddr_q;

  always_ff @(posedge clk) begin
    dmem_ren_q   <= dmem_ren;
    dmem_raddr_q <= dmem_raddr;
  end
  
  logic [INST_ADDR_WIDTH-1:0] imem_addr_q;
  logic                       imem_en_q;
  logic [INST_DATA_WIDTH-1:0] imem_instr_q;

  always_ff @(posedge clk) begin
    imem_addr_q <= imem_addr;
    imem_en_q   <= imem_en;
    imem_instr_q <= imem_instr;
  end

  // Monitor / scoreboard (testbench code → don't use always_ff)
  always @(posedge clk) begin
     if (rst && (imem_en_q === 1'b1)) begin
    // Use $strobe so value is printed after NBA updates
    $strobe("[%0t] IFETCH: imem_addr=%0d instr=0x%08h",
            $time, imem_addr_q, imem_instr_q); 
     end 

    if (rf_wr_en) begin
      $display("  RFWR: r%0d <= 0x%08h", rf_wr_addr, rf_wr_data);
      ref_regfile[rf_wr_addr] <= rf_wr_data;
    end

    if (dmem_wen) begin
      $display("  DMEM_WR: addr=%0d data=0x%08h", dmem_waddr, dmem_wdata);
    end

    if (dmem_ren_q) begin
      $display("  DMEM_RD: addr=%0d data=0x%08h", dmem_raddr_q, dmem_rdata);
    end
  end

  task automatic check_reg(input int addr, input logic [31:0] exp);
    logic [31:0] got;
    got = ref_regfile[addr];
    if (got !== exp)
      $error("REG CHECK FAIL: r%0d expected=0x%08h got=0x%08h", addr, exp, got);
    else
      $display("REG CHECK OK: r%0d == 0x%08h", addr, exp);
  endtask


endmodule
