/// ALU block///

module ALU(
  input logic [15:0] a,
  input logic [15:0] b,

  input logic [2:0] alu_ctrl,

  output logic [15:0] result,
  output logic zero 
);


  always_comb 
    begin 
      case(alu_ctrl)
        3'b000: result= a + b; // ADD
        3'b001: result = a-b ; // SUB
        3'b010: result = ~a ; // INMVERT
        3'b011: result = a << b // LSR
        3'b100: result = a >> b // LSL
        3'b101: result = a & b // AND
        3'b110: result= a | b // OR
        3'b111: result = a<b ? 16d'1 : 16d'0;
          default : result = a+ b;
      endcase
    end 
  assign zero = result = 16'd0 ? 1'b1: 1'b0;
endmodule 
