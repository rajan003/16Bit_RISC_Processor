module Data_Path(
            input clk,

            ///Control Signals
            // Data Memory control
            input logic mem_rd,
            input logic mem_wr,

            input logic mem_to_reg,
  
            input logic reg_write,
            input logic reg_dst,

            /// Branch and jump 
            input logic jump, beq, bne,

        /// Alu 
          input logic alu_Src,
          input logic [1:0] alu_op,

  ////Instrcution decode Opcode
  output logic [3:0] opcode );

  ////Program Counter and Inbstrcution emmory
  logic [15:0]  pc_current, pc_nxt ;
  always@(posedge clk)
    pc_current <= pc_nxt ;

  //// Finding the Next PC Count value
  logic [15:0] pc2, ext_im, pc_j;
  assign pc2 = pc_current + 16'd2 ; /// Next pointer since Instruction is 24 bits ..
  /// For immediate Address Reference
  assign ext_im = {{10{instr[5]}}, instr[5:0]}; //// Extending the 5th sign bit to 16 // Initial 4 bit from instr is extension

  ////Binary Equivalent
  ////BEQ r1 r2 offset >>> when r1==r2 JUMp to PC_offset 
  /// IN BEQ,BNE , we subtract the two operands in ALu and than chekc the flag if its zero.
  logic beq_control, bne_control;
  assign beq_control = beq & zero_flag ;
  assign bne_control = bne & (~zero_flag) ;

  assign PC_beq = pc2 + {ext_im[14:0],1'b0}; 
 assign PC_bne = pc2 + {ext_im[14:0],1'b0};
  
  logic [15:0] pc_beq,pc_2beq, pc_bne, pc_2bne;
  assign pc_2beq= beq_control==1'b1 ? PC_beq : pc2;
  assign pc_2bne = bne_control == 1'b1 ? PC_bne : pc_2beq ;

  ///// For Jump Isntruction/////
  assign jump_shift = {instr[11:0],1'b0};
  assign pc_j = {pc2[15:13], jump_shift};

  assign pc_nxt = (jump==1'b1) ? pc_j : pc_2bne;

  /////////////////////////PC control ends//////

  ///Instruction Memory////

  Instruction_mem im(.pc(pc_current) . instruction(instr));
  //// Here you get the Instruction corresponnding to pc_current;
  
//// The Generatl Perpose register/////
  reg_rd_Addr1 = instr[11:9] ;
  reg_rd_addr2 = instr[8:6] ;
  GPR reg_file (
    .clk(clk),
    .wr_en(re_write),
    .wr_addr(reg_write_dest), /// Address in Register write
    .wr_data(reg_Write_data),
    /// Read Ports//
    .rd_en1(1'b1),
    .rd_addr1(reg_rd_addr1),  // Comes from Instruction
    .rd_data1(reg_rd_data1),  /// for ALU input 
    .rd_en2(1'b1),
    .rd_addr2(reg_rd_addr2), /// Comes from Instruction
    .rd_data2(reg_rd_dsta2) //For ALu input b
          );


  ////// ALu = ALU_control + ALU//////////
  alu_control ALu_ctrl(.alu_op(alu_op) , //// ALU-opcode from Control Unit
                       .opcode (instr[15:12]), /// Top 4 bit from instruction register
                       .alu_ctrl(alu_ctrl) );

  ALU alu_unit (.a(reg_read_data1) , /// First Input comes from GPR read 1
                .b(reg_read_data2) , /// Second Input comes from GPR read 2
                .result(alu_out),
                .zero(zero) ) ;


  //////////// Data Memory //////////////////////
  Data_memory dm_unit (
    .clk(clk),
    .mem_wr_en(mem_Write), /// Comes from Control Unit
    .mem_wr_addr(ALU_out), //
    .mem_wr_data(reg_read_data_2) /// GPR Register Datqa

    /// Memory Load////
    .mem_rd(meme_rd), /// from COntrol Unit
    .mem_Read_data(mem_read_Data)
  );

  assign reg_write_data = (mem_to_reg==1'b1) ? mem_read_Data : alu_out ;

  assign opcode = instr[15:12] ;

endmodule 







  
  
