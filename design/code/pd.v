
module pd(
  input clock,
  input reset
);
localparam Mem_Base = 32'h0100_0000;


reg [31:0] PC;        // program counter
wire [31:0] F_INSN;   // instruction fetched from instruction memory
wire [31:0] address;  // address to instruction memory
wire [31:0] data_in;  // data to be written to instruction memory
wire read_write;      // read/write signal to instruction memory
wire [31:0] data_out; // data read from instruction memory = F_INSN
wire [6:0] opcode;    // opcode field of instruction
wire [4:0] rd;        // rd field of instruction
wire [2:0] funct3;    // funct3 field of instruction
wire [4:0] rs1;       // rs1 field of instruction
wire [4:0] rs2;       // rs2 field of instruction
wire [6:0] funct7;    // funct7 field of instruction
wire [4:0] shamt;     // shamt field of instruction
wire [31:0] imm;      // immediate value after sign extension
wire [31:0] rd_data;
wire [31:0] rs1_data;
wire [31:0] rs2_data;
wire write_enable_regFile; 
wire gated_write_enable_regFile;


assign address = PC;
assign data_in = 32'b00;
assign read_write = 1'b0;
assign F_INSN = data_out; 
assign gated_write_enable_regFile = write_enable_regFile&(~reset);



imemory imem (
  .clock(clock),
  .address(PC),
  .data_in(data_in),
  .read_write(read_write),
  .data_out(F_INSN)
);

decoder decoder_obj(
    .instr(F_INSN),
    .opcode(opcode),
    .rd(rd),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7),
    .shamt(shamt),
    .imm(imm)
);

register_file rf (
    .clock(clock),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .rd_data(rd_data),
    .write_enable(gated_write_enable_regFile),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);

always @(posedge clock or posedge reset) begin
    if (reset) 
        PC   <= Mem_Base;   
    else 
        PC   <= PC + 4;
end

endmodule
