# 32Bit_RISC_Processor
>>> Register, Instruction & Memories everything is 32 bit.

Designing a Simpl RISC Processor .
No-Pipeline 

Instruction Sets:
Instruction            Code          Format
add                     00000         add rd, rs1, (rs2/imm) 
sub                     00001         sub rd, rs1, (rs2/imm)
mul                     00010         mul rd, rs1, (rs2/imm)
div                     00011         div rd, rs1, (rs2/imm)
mod                     00100         mod rd, rs1, (rs2/imm)
cmp                     00101         cmp rs1, (rs2/imm)
and                     00110         and rd, rs1, (rs2/imm)
or                      00111         or rd, rs1, (rs2/imm)
not                     01000         not rd, (rs2/imm)
move                    01000         not rd, (rs2/imm)
lsl                     01010         lsl rd, rs1, (rs2/imm)
lsr                     01011         lsr rd, rs1, (rs2/imm)
