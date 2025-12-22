//Creating a Instruction memkory 
module Instruction_Mmeory (
  input logic [15:0] PC,
  output logoc [15:0] instruction );

  /////Register bases Instructiuon memory///
  reg [15:0] inst_mem [15:0] ; /// 15 Depth Instruction ..///

  assign instruction = inst_mem[PC[3:0]] ; /// Only the LSB 4 bits are used to decode the Instrcutions 

endmodule 
