///designinmg a ALU control unit//
///This ctroller sends Sigtnal to ALU unit to do some operation..\

module ALU_ctrl(
  input logic [1:0] alu_op;
  input logic [3:0] opcode ;

  output logic [2:0] alu_cnt);


  always_comb begin 

    case({alu_op, opcode})
      6'b10xxxx : alu_cnt = 3'b000;// Load/Store operationh.
      6'b01xxxx : alu_cnt = 3'b001; // Branch operation
      6'b000010: alu_cnt = 3'b000;  //Data Operation// ADD
      6'b000011: alu_cnt = 3'b001;  //Data Operation// SUB
      6'b000100: alu_cnt = 3'b010;  //Data Operation// INVERT
      6'b000101: alu_cnt = 3'b011;  //Data Operation// LSL
      6'b000110: alu_cnt = 3'b100;  //Data Operation// LSR
      6'b000111: alu_cnt = 3'b101;  //Data Operation// AND
      6'b001000: alu_cnt = 3'b110;  //Data Operation// OR
      6'b001001: alu_cnt = 3'b111;  //Data Operation// SLT
      defaylt: alu_cnt=3'b000;
    endcase
  end

endmodule
      
      
      
