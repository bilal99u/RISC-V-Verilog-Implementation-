module ALU(
    input wire [31:0] src_a,
    input wire [31:0] src_b,
    input wire [3:0] alu_sel,
    output reg [31:0] alu_result
);


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