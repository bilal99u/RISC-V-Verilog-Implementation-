module register_file
(
    input wire clock, 
    input wire [4:0] addr_rs1, 
    input wire [4:0] addr_rs2, 
    input wire [4:0] addr_rd,
    input wire [31:0] data_rd,
    output wire [31:0] data_rs1, 
    output wire [31:0] data_rs2, 
    input wire write_enable
);

reg [31:0] regFile [0:31];
assign data_rs1 = (addr_rs1==5'b00000)? 32'b0:regFile[addr_rs1];
assign data_rs2 = (addr_rs2==5'b00000)? 32'b0:regFile[addr_rs2];

always@(posedge clock)
begin
    if (write_enable&&(addr_rd!=0))
        regFile[addr_rd]<=data_rd;
end

initial begin
    regFile[0]=0;
    regFile[1]=0;
    regFile[2]=32'h01000000 + `MEM_DEPTH;
end

endmodule
