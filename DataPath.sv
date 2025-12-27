/// data Path Design for RISC Processor



///Note
/// Alll the Signals coming from Control Unit(Cu ) is Prefixed with letter "Cu" .
////
//------Branch Unit Generator---------------//
///Deciding the Branch Value of Register////

//--------------------------------------//
//------ Register read and write-------//
//-------------------------------------//
// Read Interface Control 
logic isRet, isSt ;
logic [3:0] rd_Addr1_int, rd_addr2_int ;
logic [31:0] op1, op2 ; /// Two Outputs from Register file.
assign rd_addr1_int = isret ? ra : inst[19:22] ; ///  register Read Address Port-1
assign rd_addr2_int = isSt ? inst[19:22] : inst[15:18] ; /// Store instructure= RD , rest are Rs2 
/// Write interface controls and data//
logic Cu_isWb ; //// Registe write signa; from Control unit 
logic [3:0] wr_Addr_int;
logic [15:0] wr_data_int;
always_comb begin 
  wr_Addr_int = Cu_isCall ? ra[3:0] : inst[23:26] ; ///  Ra register addresss or Rd Register from Instruction 
  case({isCall, isLd}) 
    2'b00: wr_data_int = alu_result;  /// ALU result is saved here 
    2'b01: wr_data_int = Idresult ; /// Memory read reesult //Load instruction 
    2'b10: wr_data_int = pc + 4 ; ///Next address for PC i.e PC+ 4 Bytes 
      default: wr_data_int = alu_result;
  endcase
end 

reg2r1w #(.WIDTH(32), .DEPTH(16) )(     /// 16 * 32  REGister Space
  .clk(clk), 
  ///Write Ports///
  .wr_en(Cu_isWb),
  .wr_addr(wr_Addr_int),
  .wr_data(wr_data_int),

  //// Read Ports-0//////
  .rd_addr1(rd_Addr1_int),
  .rd_data1(op1),
  ///Read Port-1///
  .rd_addr2(rd_addr2_int),
  .rd_Data2(op2)
);
//------ Operand Generation for ALU----//
  // Format     Defition
  // branch     register op (28-32) offset (1-27) op )  
  // register   op (28-32) I (27) rd (23-26) rs1 (19-22) rs2 (15-18
  // immediate  op (28-32) I (27) rd (23-26) rs1 (19-22) imm (1-18)
  // op-> opcode, offset-> branch offset,  I-> immediate bit, rd -> destinaton register, rs1 -> source register 1, rs2 -> source register 2, imm -> immediate operand

 /// Operand one comes from 

/// Logic to control the Rpogram Counter register that hold the Next instruction register///
logic Cu_pc_en; /// PC enable signal
logic [31:0] Cu_IsBranch_pc ; /// PC value coming from Branch Instruction decode
logic [31:0] pc, pc_incr, pc_nxt;  /// Programme counter value
logic Cu_is_branch;

always_comb 
  begin 
    pc_nxt = pc + 32'd4 ; /// Incrementing by 4 bytes for the next instruction.
    pc = is_branch ? Branch_pc : pc_nxt ;
  end 

//// Either PC points to same addrwss to move to Next , Depending on Enable.
always@(posedge clk)
  if(pc_en)
    pc <= pc_nxt ;
//////

//-------------------------------------------//
//-----Memory load and Store control---------//
//-------------------------------------------//
// In RISC-V , the only memory access possible is Load and Store.
// Control signal load -- isLd >>> rd_en==1 ,
// Control Signal Store -- isSt
logic [31:0] mdr, mar;
assign mar = alu_result; /// Address comnes from alu (rs1+imm) for both load and store
assign mdr = op2 ; /// This is the destination register which you want to store 

sram_2p #(.ADDR_W(4) , .DATA_W(32) , .DEPTH(16))  DataMem_sram(
  // Write port  
  .wclk(clk),
  .wen(isSt), /// Store Enable
  waddr(mar),
  wdata(op2),
  // Read port
  rclk(clk),
  ren(isLd), /// Load Enable 
  raddr(mar),
  rdata(mem_Read)
  );

///---------------------------------------//
//-----------Execute Unit-----------------//
//----------------------------------------//
//Execution of instruction are 2 types
// Execution of Branched Instruction 






















