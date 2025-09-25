module register_file #()
(
    input wire clock, 
    input wire [4:0] rs1, 
    input wire [4:0] rs2, 
    input wire [4:0] rd,
    input wire [31:0] rd_data,
    output wire [31:0] rs1_data, 
    output wire [31:0] rs2_data, 
    input wire write_enable
);

reg [31:0] regFile [0:31];
assign rs1_data = (rs1==5'b00000)? 32'b0:regFile[rs1];
assign rs2_data = (rs2==5'b00000)? 32'b0:regFile[rs2];

always@(posedge clock)
begin
    if (write_enable&&(rd!=0))
        regFile[rd]<=rd_data;
end

initial begin
    regFile[0]=0;
    regFile[1]=0;
    regFile[2]=32'h01000000 + `MEM_DEPTH;
    for (integer i = 3; i<32;i = i +1)
    begin
        regFile[i]=0;
    end
end

endmodule
