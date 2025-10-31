module decoder (
    input wire [31:0] instr, 
    output wire [6:0] opcode, 
    output wire [4:0] rd, 
    output wire [2:0] funct3,
    output wire [4:0] rs1, 
    output wire [4:0] rs2, 
    output wire [6:0] funct7, 
    output wire [4:0] shamt,
    output reg [31:0] imm
);


wire sign_bit;
assign opcode = instr[6:0];
assign rd = instr[11:7];
assign funct3 = instr [14:12];
assign rs1 = instr[19:15];
assign rs2 =  instr[24:20];
assign funct7 = instr[31:25];
assign shamt = instr[24:20];
assign sign_bit = instr[31];  // sign bit for sign bit extension from a 12-bit immediate to a 32-bit immediate

always@(*)
begin 
    case(opcode)
        7'b0010011: imm = {{20{sign_bit}}, instr[31:20]}; // I-type
        7'b0000011: imm = {{20{sign_bit}}, instr[31:20]}; // I-type (load)
        7'b0100011: imm = {{20{sign_bit}}, instr[31:25], instr[11:7]}; // S-type
        7'b0110111: imm = {instr[31:12], 12'b0}; //LUI-- U type is sign-extended, but by left-shifting by 12 bits in RIScV
        7'b0010111: imm = {instr[31:12], 12'b0}; //AUIPC -- U type is sign-extended, but by left-shifting by 12 bits in RIScV
        7'b1100011: imm = {{19{sign_bit}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
        7'b1101111: imm = {{11{sign_bit}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; // JAL 
        7'b1100111: imm = {{20{sign_bit}}, instr[31:20]}; // I-type (JALR)
        default: imm = 32'b0; // Default case to avoid latches
    endcase

end

endmodule