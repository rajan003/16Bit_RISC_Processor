///Creating a Reg based data memory//
/// Write 1 cycle//
// read immediate
module Data_Mem(
            input logic clk, 

          input logic mem_wr_en,

  input logic [15:0] mem_wr_Addr,
  input logic [15:0] mem_wr_data,

  input logic mem_read_en,
  input logic [15:0] mem_rd_Addr,
  output logic [15:0] mem_rd_data
);

  /// creating a 8* 16 memory
  logic [15:0] mem [7:0] ;

  always@(posedge clk)
    if(mem_wr_en) mem[mem_Wr_Addr[2:0]] <= mem_wr_data;


  mem_rd_data = mem_rd_en ? mem[mem_rd_Addr[2:0]] : '0;

endmodule 
      
