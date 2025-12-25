/// data Path Design for RISC Processor



///Note
/// Alll the Signals coming from Control Unit(Cu ) is Prefixed with letter "Cu" .
////
//------Branch Unit Generator---------------//
///Deciding the Branch Value of Register////







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
