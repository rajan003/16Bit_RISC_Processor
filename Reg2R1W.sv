//// Creating a N register field with 2 read and 1 Write port////
/// The N/DEPTH register field with M/WIDTH bit Width 
/// Adress Add_width = $clog2(N) ;
module #(parameter WIDTH=8 , DEPTH=16 ) reg2r1w(

  input logic clk, 

          ///Write Ports///
  input logic wr_en,
  input logic [$clog2(DEPTH)-1:0] wr_addr,
  input logic [WIDTH-1:0] wr_data,

  //// Read Ports-0//////
  input logic [$clog2(DEPTH)-1:0] rd_addr1,
  output logic rd_data1,


  ///Read Port-1///
  input logic [$clog2(DEPTH)-1:0]rd_addr2,
  output logic rd_Data2
);

  ////---------Register BAsed---------------///
  //// DEPTH=16 & WIDTH=8)

  logic [WIDTH-1:0] mem [DEPTH-1:0] //// DEPTH * WIDTH storage

  always@(posedge clk)
    if(wr_en) mem[wr_addr] <= wr_data ;


  assign rd_data1 = mem[rd_Addr1] ; // Port-1 Read
  assign rd_data2 = mem[rd_Addr2] ; /// Port-2 read

endmodule 
