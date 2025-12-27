// CPU Top:
import cpu_pkg::*;

module CPU_Top (
  input  logic clk
);

  // ---- Wires from DataPath -> Control Unit ----
  logic       cu_imm;
  logic [4:0] cu_opcode;

  // ---- Wires from Control Unit -> DataPath ----
  logic isSt, isLd, isBeq, isBgt, isRet;
  logic isImmediate, isWb, isUBranch, isCall;
  logic isAdd, isSub, isCmp, isMul, isDiv, isMod;
  logic isLsl, isLsr, isAsr, isOr, isAnd, isNot, isMov;

  // ---- DataPath instance ----
  DataPath u_datapath (
    .clk          (clk),

    // Control inputs (from CU)
    .Cu_isSt       (isSt),
    .Cu_isLd       (isLd),
    .Cu_isBeq      (isBeq),
    .Cu_isBgt      (isBgt),
    .Cu_isRet      (isRet),
    .Cu_isImmediate(isImmediate),
    .Cu_isWb       (isWb),
    .Cu_isUBranch  (isUBranch),
    .Cu_isCall     (isCall),

    .Cu_isAdd      (isAdd),
    .Cu_isSub      (isSub),
    .Cu_isCmp      (isCmp),
    .Cu_isMul      (isMul),
    .Cu_isDiv      (isDiv),
    .Cu_isMod      (isMod),
    .Cu_isLsl      (isLsl),
    .Cu_isLsr      (isLsr),
    .Cu_isAsr      (isAsr),
    .Cu_isOr       (isOr),
    .Cu_isAnd      (isAnd),
    .Cu_isNot      (isNot),
    .Cu_isMov      (isMov),

    // Outputs to CU
    .Cu_imm        (cu_imm),
    .Cu_opcode     (cu_opcode)
  );

  // ---- Control Unit instance ----
  Control_Unit u_ctrl (
    .imm          (cu_imm),
    .opcode       (cu_opcode),

    .isSt         (isSt),
    .isLd         (isLd),
    .isBeq        (isBeq),
    .isBgt        (isBgt),
    .isRet        (isRet),
    .isImmediate  (isImmediate),
    .isWb         (isWb),
    .isUBranch    (isUBranch),
    .isCall       (isCall),

    .isAdd        (isAdd),
    .isSub        (isSub),
    .isCmp        (isCmp),
    .isMul        (isMul),
    .isDiv        (isDiv),
    .isMod        (isMod),
    .isLsl        (isLsl),
    .isLsr        (isLsr),
    .isAsr        (isAsr),
    .isOr         (isOr),
    .isAnd        (isAnd),
    .isNot        (isNot),
    .isMov        (isMov)
  );

endmodule
