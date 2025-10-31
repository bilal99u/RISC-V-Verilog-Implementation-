module control (
    input  wire [8:0]  operation_key,  
    input  wire        BrEq,           
    input  wire        BrLT,           
    output reg         PCSel,
    output reg  [2:0]  ImmSel,
    output reg         BrUn,
    output reg         ASel,
    output reg         BSel,
    output wire [3:0]  ALUSel,
    output reg         MemRW,
    output reg         RegWEn,
    output reg  [1:0]  WBSel,
    output reg branch_taken
    output reg [1:0] d_mem_access_size,
    output reg dmem_is_signed
);
wire [2:0] funct3 = operation_key[7:5]; // Extract funct3 from operation_key
wire funct7_5 = operation_key[8]; // Extract funct7[5] from operation_key
wire [4:0] opcode = operation_key[4:0]; // Extract opcode from operation_key
wire [7:0] opcode_plus_funct3 = {funct3, opcode};


control_alu control_alu0(
    .operation_key(operation_key),
    .alu_sel(ALUSel)
);

/*
Explaination of signals: 
PCSel: 0 -> PC = PC + 4
       1 -> PC = ALU result (for jalr)
ImmSel: 000 -> I-type immediate
        001 -> B-type immediate
        010 -> U-type immediate
        011 -> J-type immediate
        100 -> S-type immediate
BrUn: 0 -> signed comparison
      1 -> unsigned comparison
ASel: 0 -> mux at port A of ALU selects value from register
      1 -> mux at port A of ALU selects value from PC
BSel: 0 -> mux at port B of ALU selects value from register
      1 -> mux at port B of ALU selects value from immediate
MemRW: 0 -> read from data memory
       1 -> write to data memory
RegWEn: 0 -> don't write to register file
        1 -> write to register file
WBSel: 00 -> writeback mux selects data from data memory (for load instructions)
       01 -> writeback mux selects data from ALU (for R-type and I-type instructions)
       10 -> writeback mux selects data from PC + 4 (for jal and jalr instructions) 


*/

always@(*)
begin
    case(opcode_plus_funct3)
            8'b00000000: // LB
            begin
                dmem_is_signed = 1'b1; 
                d_mem_access_size = 2'b00;
            end
            8'b00100000: // LH
            begin 
                dmem_is_signed = 1'b1; 
                d_mem_access_size = 2'b01;
            end
            8'b01000000: // LW
            begin 
                dmem_is_signed = 1'b1; 
                d_mem_access_size = 2'b10;
            end
            8'b10000000: // LBU
            begin 
                dmem_is_signed = 1'b0; 
                d_mem_access_size = 2'b00;
            end
            8'b10100000: // LHU
            begin 
                dmem_is_signed = 1'b0; 
                d_mem_access_size = 2'b01;
            end
            8'b00001000: // SB
            begin 
                dmem_is_signed = 1'b1; 
                d_mem_access_size = 2'b00;
            end
            8'b00101000: // SH
            begin 
                dmem_is_signed = 1'b1; 
                d_mem_access_size = 2'b01;
            end
            8'b01001000: // SW
            begin 
                dmem_is_signed = 1'b1; 
                d_mem_access_size = 2'b10;
            end
            default:
            d_mem_access_size = 2'b10;

    endcase
end

always@(*)
begin 
    if (opcode == 5'b11000) // Branch instructions
    begin
        BrUn = 1'b0;       // Default BrUn = 0 means signed comparison
        case (funct3)
            3'b110: BrUn = 1'b1;  // BLTU
            3'b111: BrUn = 1'b1;  // BGEU
            default: BrUn = 1'b0;         // BEQ, BNE, BLT, BGE
        endcase
    end
    else
        BrUn = 1'b0; // Not a branch instruction default
end

always@(*)
begin
    if (opcode == 5'b11000) // Branch instructions
    begin
        case (funct3)
            3'b000: branch_taken = BrEq;          // BEQ
            3'b001: branch_taken = ~BrEq;         // BNE
            3'b100: branch_taken = BrLT;          // BLT
            3'b101: branch_taken = ~BrLT;         // BGE
            3'b110: branch_taken =  BrLT;  // BLTU
            3'b111: branch_taken = ~BrLT;  // BGEU
            default: branch_taken = 1'b0;         // Default case to avoid latches
        endcase
    end
    else
        branch_taken = 1'b0; // Not a branch instruction, so not taken
end


always@(*)
begin
    PCSel = 1'b0;       // PCSel = 0 default means Pc = PC + 4
    ImmSel = 3'b001;    // ImmSel = 001 is for B-type instructions
    ASel = 1'b0;        // Default Asel = 0 means mux at port rs1 will select vale from register
    BSel = 1'b0;
    MemRW = 1'b0;       // Default 0 means read, 1 for write to data memory 
    RegWEn = 1'b0;      // Default 0 means don't write 
    WBSel = 2'b01;       // Default 01 mean, writeback mux will select to write result from ALU

    casez(operation_key)

    9'b?_???_01100: // R-type instructions
    begin 
        PCSel = 1'b0; 
        ASel = 1'b0; 
        BSel = 1'b0; 
        RegWEn = 1'b0; 
        WBSel = 2'b01;  // writeback from ALU
        MemRW = 1'b0;
    end
    9'b?_???_00100:  // I-type arithmetic instructions
    begin 
        PCSel = 1'b0; 
        ASel = 0; 
        BSel = 1; 
        RegWEn = 1'b0; 
        WBSel = 2'b01;  // writeback from ALU
        MemRW = 1'b0;
        ImmSel = 3'b000; // I-type immediate
    end
    9'b?_???_00000:  // Load instructions (LB/LH/LW/LBU/LHU)
    begin 
        PCSel = 1'b0;
        ASel = 0;
        BSel = 1;
        RegWEn = 1'b0;
        WBSel = 2'b00; // writeback from data memory
        MemRW = 0; 
        ImmSel = 3'b000;
    end
    9'b?_???_01000:  // Store instructions (SB/SH/SW)
    begin
        PCSel = 1'b0;
        ASel = 0;
        BSel = 1;
        RegWEn = 0;
        MemRW = 0;  // write to data memory CHANGE TO 1 LATER
        ImmSel = 3'b100; // S-type immediate
    end
    9'b?_???_11000:  // Branch instructions (BEQ/BNE/BLT/BGE/BLTU/BGEU)
    begin 
        PCSel = branch_taken; // If branch is taken, PC = PC + imm, else PC = PC + 4
        ImmSel = 3'b001; // B-type immediate
        ASel = 1; 
        BSel = 1; 
        RegWEn = 0; 
        WBSel = 2'b01; // writeback from ALU (though not used in branch)
        MemRW = 0;
    end
    
    9'b?_000_11001:  // JALR 
    begin
        PCSel = 1'b1;     // PC = rs1 + imm
        ImmSel = 3'b000; // I-type immediate
        ASel = 0; 
        BSel = 1; 
        RegWEn = 1'b0; 
        WBSel = 2'b10; // writeback from PC + 4
        MemRW = 0;
    end
    9'b?_000_11011:  // JAL 
    begin
        PCSel = 1'b1;     // PC = PC + imm
        ImmSel = 3'b011; // J-type immediate
        ASel = 1'b1; 
        BSel = 1'b1; 
        RegWEn = 1'b0; 
        WBSel = 2'b10; // writeback from PC + 4
        MemRW = 1'b0;
    end
    9'b?_???_01101:  // LUI
    begin
        PCSel = 1'b0;    // PC = PC + 4
        ImmSel = 3'b010; // U-type immediate
        ASel = 1'b0;     // 
        BSel = 1'b1; 
        RegWEn = 1'b0; 
        WBSel = 2'b01; // writeback from ALU as ALU passes immediate
        MemRW = 1'b0;
    end
    9'b?_???_00101:  // AUIPC
    begin
        PCSel = 1'b0;    // PC = PC + 4
        ImmSel = 3'b010; // U-type immediate
        ASel = 1'b1;     // mux at port A of ALU selects value from PC
        BSel = 1'b1; // mux at port B of ALU selects value from immediate
        RegWEn = 1'b0; 
        WBSel = 2'b01; // writeback from ALU as ALU does PC + immediate
        MemRW = 1'b0;
    end
    default: // Default case to avoid latches
    begin
        PCSel = 1'b0;
        ImmSel = 3'b000;
        ASel = 1'b0;
        BSel = 1'b0;
        MemRW = 1'b0;
        RegWEn = 1'b0;
        WBSel = 2'b01;   // writeback from ALU
    end
    endcase


end
endmodule