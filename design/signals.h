
/* Your Code Below! Enable the following define's 
 * and replace ??? with actual wires */
// ----- signals -----
// You will also need to define PC properly
`define F_PC                PC
`define F_INSN              F_INSN

`define D_PC                PC
`define D_OPCODE            opcode
`define D_RD                rd
`define D_RS1               rs1
`define D_RS2               rs2
`define D_FUNCT3            funct3
`define D_FUNCT7            funct7
`define D_IMM               imm
`define D_SHAMT             shamt

`define R_WRITE_ENABLE      write_enable_regFile
`define R_WRITE_DESTINATION rd
`define R_WRITE_DATA        rd_data
`define R_READ_RS1          rs1
`define R_READ_RS2          rs2
`define R_READ_RS1_DATA     rs1_data
`define R_READ_RS2_DATA     rs2_data

`define E_PC                PC
`define E_ALU_RES           alu_result
`define E_BR_TAKEN          branch_taken

`define M_PC                PC
`define M_ADDRESS           alu_result
`define M_RW                MemRW
`define M_SIZE_ENCODED      d_mem_access_size
`define M_DATA              rs2_data

`define W_PC                PC
`define W_ENABLE            write_enable_regFile
`define W_DESTINATION       rd
`define W_DATA              rd_data

// ----- signals -----

// ----- design -----
`define TOP_MODULE                 pd
// ----- design -----
