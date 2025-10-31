module ALU(
    input wire [31:0] src_a,
    input wire [31:0] src_b,
    input wire [3:0] alu_sel,
    output reg [31:0] alu_result
);


/*
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

*/

always@(*)begin
    alu_result = 32'b0;
    case(alu_sel)
        4'b0000: alu_result = src_a + src_b;
        4'b0001: alu_result = src_a - src_b;
        4'b0010: alu_result = src_a & src_b;
        4'b0011: alu_result = src_a | src_b;
        4'b0100: alu_result = src_a ^ src_b;
        4'b0101: alu_result = {31'b0, ($signed(src_a)<$signed(src_b))};
        4'b0110: alu_result = {31'b0, (src_a<src_b)};
        4'b0111: alu_result = src_a<<src_b[4:0];
        4'b1000: alu_result = src_a>>src_b[4:0];
        4'b1001: alu_result = $signed(src_a)>>>src_b[4:0];
        4'b1111: alu_result = src_b;
        default: alu_result = 32'b0;
    endcase
end

endmodule