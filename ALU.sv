///Package Importt/
import cpu_pkg::*;

/// ALU block///

module ALU(
  input aluctrl aluSignal , //isAdd, isSub, isCmp, isMul, isDiv, isMod, isLsl, isLsr, isAsr, isOr, isAnd, isNot, isMov, //// ALu Signal
  //where 
  //typedef struct {
  //                logic isAdd;
  //                logic isSub;
  //                logic isCmp;
  //                logic isMul;
  //                logic isDiv;
  //                logic isMod;
  //                logic isLsl;
  //                logic isLsr;
  //                logic isAsr;
  //                logic isOr;
  //                logic isAnd;
  //                logic isNot;
  //                logic isMov } aluctrl ;
  input logic [31:0] A,
  input logic [31:0] B,

  output logic [31:0] aluResult,
  output logic  flg flag
  //typedef struct {
                    // logic GT ;
                    // logic ET ;
  // } flg;
);

  always_comb 
    begin 
      case(aluSignal.aluctrl)
        isAdd:  ADDER(.A(A), .B(B), .ctrl(2'b00), .result(aluResult), .flag(flag))  ;// Instantiating the Adder module which Do ADD, Sb and Comparison 
        isSub, isCMp:  ADDER(.A(A), .B(B), .ctrl(2'b01), .result(aluResult), .flag(flag))  ;// Instantiating the Adder module which Do ADD, Sb and Comparison 
        isMul:  Multiplier(.A(A), .B(B), .Result(aluResult), .flag(flag))  ;// Multiplier module  
        isDiv, isMod:  Dividor(.A(A), .B(B), .Result(aluResult), .flag(flag))  ;// Divider module: Division and Modulas
        isLsl, isLsr, isAsr:  Shifter(.A(A), .B(B), .Result(aluResult), .flag(flag))  ;// Instantiating the Adder module which Do ADD, Sb and Comparison 
        isOr, isAnd, isNot:  Logical(.A(A), .B(B), .Result(aluResult), .flag(flag))  ;// Instantiating the Adder module which Do ADD, Sb and Comparison 
        isMov:  Movement(.A(A), .B(B), .Result(aluResult), .flag(flag))  ;// Instantiating the Adder module which Do ADD, Sb and Comparison 
          default : begin flag = 2'b00;
            result = a+ b; end 
      endcase
    end 

endmodule 
