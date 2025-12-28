//Importing PAckages
///Package Importt/
import cpu_pkg::*;
/// data Path Design for RISC Processor
module DataPath (
                input logic clk,

                ///control signals from control unit ///
                input logic Cu_isSt, /// Store instruction 
                input logic Cu_isLd , // Load instruction 
                input logic Cu_isBeq, // Branch Equivalent
                input logic Cu_isBgt, /// branch Greater than
                input logic Cu_isRet, // Retention signa;l
                input logic Cu_isImmediate, // Immediate bit
                input logic Cu_isWb, /// Memory Write  //Possible in add, sub, mul,div,mod,and, or, not,mov, ld, lsl, lsr, asr, call
                input logic Cu_isUBranch, // Unconditiona Branch Instrcution : b, call, ret
                input logic Cu_isCall , // Call Instruction 
                input logic Cu_isAdd, /// add, ld, st
                input logic Cu_isSub, // sub
                input logic Cu_isCmp, // cmp
                input logic Cu_isMul, // mul
                input logic Cu_isDiv, // div
                input logic Cu_isMod, // mod
                input logic Cu_isLsl, // lsl
                input logic Cu_isLsr, // Lsr
                input logic Cu_isAsr, // ASR
                input logic Cu_isOr, // OR
                input logic Cu_isAnd, // AND
                input logic Cu_isNot, // Not
                input logic Cu_isMov, // Move

            /// Immediate bit output to Control Unit
                output logic Cu_imm, /// immediate indication bit

            /// Opcode to control unit
                output logic [4:0] Cu_opcode 
          ///Instruction SRAM wr Interface/// For loading SRAM 
               input logic inst_sram_wr ,
               input logic [INST_ADDR_WIDTH -1:0] inst_sram_addr,
               input logic [INST_DATA_WIDTH-1:0] inst_sram_data
) ;

  //--------------------------------------------------------------//
  //-------------Instruction fetch Unit--------------------------//
  //-------------------------------------------------------------//

  /// Logic to control the Rpogram Counter register that hold the Next instruction register///
  logic [31:0] pc , pc_nxt;  /// Programme counter value
  
   assign  pc_nxt = isBranchTaken ? BranchPC : pc + 32'd4 ; // /// Incrementing by 4 bytes for the next instruction
  
  //// Either PC points to same addrwss to move to Next , Depending on Enable.
  always@(posedge clk)
      pc <= pc_nxt ;

    //---------Instruction SRAM Controls-------------//
   logic wr_en ;
   logic [INST_ADDR_WIDTH-1:0] inst_addr;
     assign  wr_en= sram_wr ? 1'b1 : 1'b0 ; //For testing, loading SRAm with instructions and rest of time it a read.
        /// Here we will use the PC_nxt that is pointing the Next PC counter i.e when PC is actually loaded you have the instruction available
     assign inst_addr = wr_en ? inst_sram_addr : pc_nxt[INST_ADDR_WIDTH+1 : 2];  // 	•	PC[1:0] → byte offset (always 00) •	PC[2] → selects instruction 1
  /// Instrcution memory SRAM 
    sram_1p #(.ADDR_WIDTH(INST_ADDR_WIDTH), .DATA_WIDTH(INST_DATA_WIDTH) ) sram_instr (
      .clk(clk),
      .mem_en(1'b1),
      .we(wr_en),
      .addr(inst_addr),
      .wdata(inst_sram_data),
      .rdata(inst) /// Current Instruction 
    );
    
///Calculaing the Immediate extensioj bits
logic [31:0] immx;
always_comb begin 
  case(instr[18:17])
    2'b00: immx = instr[16] ? ({16'hFFFF , instr[16:1]}) : ({16'h0000 , instr[16:1]}) ; ///Or// {{12{instr[16]}}, instr[16:1]}; // SIgn Extension 
    2'b01: immx = ({16'h0000 , instr[16:1]}); /// Filler are zero
    2'b10: immx = ({16'hFFFF, instr[16:1]});  /// Fillers are One
    default: immx = ({16'h0000 , instr[16:1]});
  endcase
end 



//---------------------------------------------------------//
//--------------- Decode: Register read and write----------//
//---------------------------------------------------------//
// Read Interface Control 
  logic [3:0] ra_addr ; /// Return Address Register
logic Cu_isRet, Cu_isSt ;
logic [3:0] rd_Addr1_int, rd_addr2_int ;
logic [31:0] op1, op2, op2_int ; /// Two Outputs from Register file.
  
assign ra_addr = 4'b1111 ; // the 16th regitser in GPR is reserved for storing PC value
assign rd_addr1_int = Cu_isret ? ra_addr : inst[19:22] ; ///  register Read Address Port-1
assign rd_addr2_int = Cu_isSt ? inst[19:22] : inst[15:18] ; /// Store instructure= RD , rest are Rs2 

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
  .rd_Data2(op2_int)
);
//------ Operand Generation for ALU----//
  // Format     Defition
  // branch     register op (28-32) offset (1-27) op )  
  // register   op (28-32) I (27) rd (23-26) rs1 (19-22) rs2 (15-18
  // immediate  op (28-32) I (27) rd (23-26) rs1 (19-22) imm (1-18)
  // op-> opcode, offset-> branch offset,  I-> immediate bit, rd -> destinaton register, rs1 -> source register 1, rs2 -> source register 2, imm -> immediate operand

 /// Operand one comes from 



//-------------------------------------------//
//-----Memory load and Store control---------//
//-------------------------------------------//
// In RISC-V , the only memory access possible is Load and Store.
  logic [31:0] mdr, mar, IdResult;
  assign mar = alu_result[7:0]; /// Address comnes from alu (op1+imm) for both load and store // 8 bits are selected 
  assign mdr = op2 ; /// This is the destination register which you want to store 

  ///Creating a 1kB size SRAM 
  sram_2p #(.ADDR_W(8) , .DATA_W(32) , .DEPTH(256))  DataMem_sram(
    // Write port  // Storing data to Memory
    .wclk(clk),
    .wen(Cu_isSt), /// Store Enable
    waddr(mar),
    wdata(mdr),
    // Read port /// Loading Data to GPR
    rclk(clk),
    ren(Cu_isLd), /// Load Enable 
    raddr(mar),
    rdata(IdResult) /// 32 bit data from 
    );

///---------------------------------------//
//-----------Execute Unit-----------------//
//----------------------------------------//
//Execution of instruction are 2 types

//-----------------------------------------------------------------------------//
//--------------Type-1 : Execution of Branched Instruction--------------------//
//----------------------------------------------------------------------------//

logic [31:0] BranchPC;
logic [31:0] BranchTarget ,BranchTarget_int ;
  
//Now on What condition you want PC to move to Branched instruction 
/// type-1 branch inst: Unconditional Brnahc ( b , call, ret )
/// type-2, Conditional branch : beq, bne >> they depend on Last instrcution (CMP) result i.e flag 
    always_comb begin 
      isBranchTaken = Cu_isUbranch | (Cu_isBgt & flags.GT) | (CU_isBeq & flags.E) ;  /// (Type-1 OR Type-2) 
  
        //// Calculating the Branch Instruction Offset(nneded in both Conditional and Uncondiional branch instr except ret )
       BranchTarget_int = inst[27:1] >> 2 ; // Shifted Offset , This is doen to amke it Word Addressing 
       BranchTarget = pc + ({{5{inst[26]}} , inst[26:0]}); /// Branch Target = PC + Sign-Extension of Shifted Offset
  
       BranchPC = CU_isRet ? op1 : BranchTarget ; //  Is the Instrcution is retention type You will read the RA register for Last saved Instruction Address to pick up 
    end 
  
//-----------------------------------------------------------------------------//
//--------------Type-2 : Execution of non-Branched Instruction--------------------//
//----------------------------------------------------------------------------//
aluctrl aluSignal ; /// ALU control signals
assign op2 = Cu_isImmediate ? immx : op2_int; /// Is Instruction is immediate than Immediate Value otherwise it's an register Instrcution(rs2)

ALU alu_unit #(.WIDTH(32))(
   .aluSignal(aluSignal) , //isAdd, isSub, isCmp, isMul, isDiv, isMod, isLsl, isLsr, isAsr, isOr, isAnd, isNot, isMov, //// ALu Signal
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
   .A(op1),
   .B(op2),

  .aluResult(aluResult),
  .flag(flag)
  //typedef struct {
                    // logic GT ;
                    // logic ET ;
  // } flg;
);



endmodule 










