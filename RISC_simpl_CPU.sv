// CPU Top (memory interfaces exported to top)
 //-- Package Import------//
`include "cpu_pkg.sv"
`include "DataPath.sv"
`include "CtrlUnit.sv"
`include "REG2R1W.sv"
`include "Adder.sv"
`include "Multiplier.sv"
`include "ALU.sv"
module CPU_Top (
  input  logic clk,
  input logic rst,
  input logic start,

  // -------------------------
  // Instruction memory (read-only)
  // -------------------------
  output logic                      imem_en,
  output logic [INST_ADDR_WIDTH-1:0] imem_addr,
  input  logic [INST_DATA_WIDTH-1:0] imem_data,

  // -------------------------
  // Data memory (true 2-port)
  // -------------------------
  // Write port
  output logic [MEM_ADDR_WIDTH-1:0]               dmem_waddr,
  output logic [MEM_DATA_WIDTH-1:0]               dmem_wdata,
  output logic                      dmem_wen,

  // Read port
  output logic [MEM_ADDR_WIDTH-1:0]               dmem_raddr,
  input  logic [MEM_DATA_WIDTH-1:0]               dmem_rdata,
  output logic                      dmem_ren,

  // -------------------------
  // Register-file write monitor (TB visibility)
  // -------------------------
  output logic [3:0]                rf_wr_addr,
  output logic [31:0]               rf_wr_data,
  output logic                      rf_wr_en
);
  
  // ---- Wires from DataPath -> Control Unit ----
  logic       imm;
  logic [4:0] opcode;

  // ---- Wires from Control Unit -> DataPath ----
  logic isSt, isLd, isBeq, isBgt, isRet;
  logic isImmediate, isWb, isUBranch, isCall;
  logic isAdd, isSub, isCmp, isMul, isDiv, isMod;
  logic isLsl, isLsr, isAsr, isOr, isAnd, isNot, isMov;

  // ---- DataPath instance ----
  DataPath u_datapath (
    .clk            (clk),
    .rst			(rst),
    .start			(start),
    // Control inputs (from CU)
    .Cu_isSt         (isSt),
    .Cu_isLd         (isLd),
    .Cu_isBeq        (isBeq),
    .Cu_isBgt        (isBgt),
    .Cu_isRet        (isRet),
    .Cu_isImmediate  (isImmediate),
    .Cu_isWb         (isWb),
    .Cu_isUBranch    (isUBranch),
    .Cu_isCall       (isCall),

    .Cu_isAdd        (isAdd),
    .Cu_isSub        (isSub),
    .Cu_isCmp        (isCmp),
    .Cu_isMul        (isMul),
    .Cu_isDiv        (isDiv),
    .Cu_isMod        (isMod),
    .Cu_isLsl        (isLsl),
    .Cu_isLsr        (isLsr),
    .Cu_isAsr        (isAsr),
    .Cu_isOr         (isOr),
    .Cu_isAnd        (isAnd),
    .Cu_isNot        (isNot),
    .Cu_isMov        (isMov),

    // Outputs to CU
    .Cu_imm          (imm),
    .Cu_opcode       (opcode),

    // -------------------------
    // IMEM interface up to top
    // -------------------------
    .imem_en         (imem_en),
    .imem_addr       (imem_addr),
    .imem_data       (imem_data),

    // -------------------------
    // RF monitor up to top
    // -------------------------
    .rf_wr_addr      (rf_wr_addr),
    .rf_wr_data      (rf_wr_data),
    .rf_wr_en        (rf_wr_en),

    // -------------------------
    // DMEM 2-port up to top
    // -------------------------
    .dmem_waddr      (dmem_waddr),
    .dmem_wdata      (dmem_wdata),
    .dmem_wen        (dmem_wen),

    .dmem_raddr      (dmem_raddr),
    .dmem_rdata      (dmem_rdata),
    .dmem_ren        (dmem_ren)
  );

  // ---- Control Unit instance ----
  Control_Unit u_ctrl (
    .imm            (imm),
    .opcode         (opcode),

    .isSt           (isSt),
    .isLd           (isLd),
    .isBeq          (isBeq),
    .isBgt          (isBgt),
    .isRet          (isRet),
    .isImmediate    (isImmediate),
    .isWb           (isWb),
    .isUBranch      (isUBranch),
    .isCall         (isCall),

    .isAdd          (isAdd),
    .isSub          (isSub),
    .isCmp          (isCmp),
    .isMul          (isMul),
    .isDiv          (isDiv),
    .isMod          (isMod),
    .isLsl          (isLsl),
    .isLsr          (isLsr),
    .isAsr          (isAsr),
    .isOr           (isOr),
    .isAnd          (isAnd),
    .isNot          (isNot),
    .isMov          (isMov)
  );

endmodule
