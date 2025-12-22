///Creating a 8 depth generap Purpose register file//
///R0, R1, R2, R3, R4 ,R5, R6, R7
module GenReg (
              input logic clk, rst,

  /// REGISTER WRITE
     input logic req_wr ,
  input logic [2:0] reg_wr_Addr,
  input logic [15:0] reg_wr_data,

  /// Register Read-1
    input logic reg_rd1;
  input logic [2:0] reg_rd1_addr,
  output logic [15:0] reg_Rd1_data,

  /// Register Read-2
      input logic reg_rd2;
  input logic [2:0] reg_rd2_addr,
  output logic [15:0] reg_rd2_data
);


  /// Defining the 8 depth 16 width register///
  logic [15:0] gpr [7:0] ; //// Register Definition 

  always@(posedge clk , posedge rst)
    if(rst)
      for(int i=0; i <8; i++)
        gpr[i] <= '0;
  else if(reg_wr)
    gpr[reg_Wr_addr] <= reg_wr_data ;

  /// Reading from Regster wont need a Clock
  assign  reg_rd1_data = reg_rd1 ? gpr[reg_rd1_addr] : '0;
  assign reg_rd2_data = reg_rd2 ? gpr[reg_rd2_addr] : '0;


endmodule 
    
