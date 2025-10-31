module control_alu (
    input wire [8:0] operation_key, 
    output reg [3:0] alu_sel
);

localparam [3:0]
ALU_OP_ADD   = 4'b0000,
ALU_OP_SUB   = 4'b0001,
ALU_OP_AND   = 4'b0010,
ALU_OP_OR    = 4'b0011,
ALU_OP_XOR   = 4'b0100,
ALU_OP_SLT   = 4'b0101,
ALU_OP_SLTU  = 4'b0110,
ALU_OP_SLL   = 4'b0111,
ALU_OP_SRL   = 4'b1000,
ALU_OP_SRA   = 4'b1001,
ALU_OP_PASSB = 4'b1111;


always@(*) begin
    alu_sel = ALU_OP_ADD;
    casez (operation_key)
        // function of alu in R-type instr
        9'b0_000_01100: alu_sel = ALU_OP_ADD;
        9'b1_000_01100: alu_sel = ALU_OP_SUB;
        9'b0_001_01100: alu_sel = ALU_OP_SLL;   // SLL
        9'b0_010_01100: alu_sel = ALU_OP_SLT;   // SLT
        9'b0_011_01100: alu_sel = ALU_OP_SLTU;  // SLTU
        9'b0_100_01100: alu_sel = ALU_OP_XOR;   
        9'b0_101_01100: alu_sel = ALU_OP_SRL;   
        9'b1_101_01100: alu_sel = ALU_OP_SRA;   
        9'b0_110_01100: alu_sel = ALU_OP_OR;    
        9'b0_111_01100: alu_sel = ALU_OP_AND; 
        // I-type instr
        9'b?_000_00100: alu_sel = ALU_OP_ADD;   // ADDI
        9'b?_010_00100: alu_sel = ALU_OP_SLT;   // SLTI
        9'b?_011_00100: alu_sel = ALU_OP_SLTU;  // SLTIU
        9'b?_100_00100: alu_sel = ALU_OP_XOR;   // XORI
        9'b?_110_00100: alu_sel = ALU_OP_OR;    // ORI
        9'b?_111_00100: alu_sel = ALU_OP_AND;   // ANDI
        9'b0_001_00100: alu_sel = ALU_OP_SLL;   // SLLI
        9'b0_101_00100: alu_sel = ALU_OP_SRL;   // SRLI
        9'b1_101_00100: alu_sel = ALU_OP_SRA;   // SRAI
        //  load instri
        9'b?_???_00000: alu_sel = ALU_OP_ADD;   // LOADs (LB/LH/LW/LBU/LHU)
        9'b?_???_01000: alu_sel = ALU_OP_ADD;   // STOREs (SB/SH/SW)
        // branch 
        9'b?_???_11000: alu_sel = ALU_OP_ADD;   // Branch B type instruction, ALU Adds PC+IMM for address calculation of target
        9'b?_000_11001: alu_sel = ALU_OP_ADD;   // JALR (rs1 + immI)
        9'b?_???_01101: alu_sel = ALU_OP_PASSB; // LUI  (immU<<12 should be on B)
        9'b?_???_00101: alu_sel = ALU_OP_ADD;   // AUIPC (PC + immU<<12)
        9'b?_???_11011: alu_sel = ALU_OP_ADD;   // JAL (ALU op unused; safe default)
        default: alu_sel = ALU_OP_ADD;
    endcase
end

endmodule