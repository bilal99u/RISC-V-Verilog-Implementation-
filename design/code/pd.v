
module pd(
  input clock,
  input reset
);
localparam Mem_Base = 32'h0100_0000;


reg [31:0] PC;        // program counter
wire [31:0] F_INSN;   // instruction fetched from instruction memory
wire [31:0] address;  // address to instruction memory
wire [31:0] pc_next;
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
wire [8:0] operation_key; 
wire BrEq;
wire BrLT;
wire PCSel;
wire [2:0] ImmSel;
wire BrUn;
wire ASel;
wire BSel;
wire [3:0] ALUSel;
wire MemRW; // Damata memory read = 0, write = 1
wire [1:0] WBSel;
wire [31:0] alu_result;
wire [31:0] alu_in_A;
wire [31:0] alu_in_B;
wire [31:0] pc_plus_4;
wire [31:0] immediate_extended;
wire [31:0] d_mem_out;  // Memory data out
wire [1:0] d_mem_access_size; // data memory access size, 
wire dmem_is_signed; // is data signed in data memory access
wire branch_taken;




assign data_in = 32'b00;
assign read_write = 1'b0;
assign gated_write_enable_regFile = write_enable_regFile&(~reset);
assign operation_key = {funct7[5], funct3, opcode[6:2]}; // this key will have the 9 bits which distinguishes operations


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
    .addr_rs1(rs1),                 
    .addr_rs2(rs2),                 
    .addr_rd(rd),                   
    .data_rd(rd_data),              
    .write_enable(gated_write_enable_regFile),
    .data_rs1(rs1_data),            
    .data_rs2(rs2_data)             
);
branch_compare_unit bcu (
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .BrUn(BrUn),
    .BrEq(BrEq),
    .BrLT(BrLT)
    
);
control control_unit (
    .operation_key(operation_key),
    .BrEq(BrEq),
    .BrLT(BrLT),
    .PCSel(PCSel),       
    .ImmSel(ImmSel),
    .BrUn(BrUn),
    .ASel(ASel),                 
    .BSel(BSel),                 
    .ALUSel(ALUSel),               
    .MemRW(MemRW),                
    .RegWEn(write_enable_regFile),
    .WBSel(WBSel),
    .branch_taken(branch_taken),
    .d_mem_access_size(d_mem_access_size),
    .dmem_is_signed(dmem_is_signed)             
);

mux2to1 #(.WIDTH(32)) mux_alu_A
(
  .in0(rs1_data),
  .in1(PC),
  .sel(ASel),
  .out(alu_in_A)
);
mux2to1 #(.WIDTH(32)) mux_alu_B
(
  .in0(rs2_data),
  .in1(imm),
  .sel(BSel),
  .out(alu_in_B)
);

assign pc_plus_4 = PC + 4;
wire [31:0] target_address; // target address calculated by ALU for branch and jump instructions
assign target_address = (opcode==7'b1100111)? {alu_result[31:1], 1'b0} : alu_result; // for JALR, make LSB 0)
//   fix below !!!!!!!!! FIX
mux2to1 #(.WIDTH(32)) pc_selector
(
  .in0(pc_plus_4),
  .in1(target_address), // NOT UPDATING PC TO JUMP AND BRANCH TARGET FOR SIMPLICITY, CHANGE LATER
  .sel(PCSel),
  .out(pc_next)
);
mux4to1 #(.WIDTH(32)) writeback_selector
(
  .in0(d_mem_out),        // from data memory
  .in1(alu_result),      // from ALU
  .in2(pc_plus_4),      // from PC + 4
  .in3(imm),         // from immediate (for auipc and lui), just default, not using this 
  .sel(WBSel),
  .out(rd_data)
);
ALU my_sweety_ALU (
  .src_a(alu_in_A),
  .src_b(alu_in_B), 
  .alu_sel(ALUSel),
  .alu_result(alu_result)
);

dmemory datamemory(
  .clock(clock),
  .address(alu_result),
  .data_in(rs2_data),
  .read_write(MemRW),
  .access_size(d_mem_access_size),
  .is_signed(dmem_is_signed),
  .data_out(d_mem_out) // data_out is inside data memory/ d mem out is data mem out sing in top
);


always @(posedge clock or posedge reset) begin
    if (reset) 
        PC   <= Mem_Base;   
    else 
        PC   <= pc_next;
end



// debug code 


endmodule
