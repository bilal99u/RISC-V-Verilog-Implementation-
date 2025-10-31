module branch_compare_unit(
    input wire [31:0] rs1_data,
    input wire [31:0] rs2_data,
    input wire BrUn,
    output reg BrEq,
    output reg BrLT
);

always@(*)
begin 
    BrEq = rs1_data == rs2_data;
    if (BrUn==1'b1)
        BrLT = (rs1_data < rs2_data);
    else 
        BrLT = ($signed(rs1_data) < $signed(rs2_data));
end

endmodule