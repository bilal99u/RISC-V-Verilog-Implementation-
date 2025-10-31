module imemory #()
(
    input wire clock,
    input wire [31:0] address,
    input wire [31:0] data_in,
    input wire read_write,  // 0 is for read, 1 is for write
    output wire [31:0] data_out
);


localparam Mem_Base = 32'h0100_0000;
reg [7:0] memory [0:`MEM_DEPTH-1];
reg [31:0] temp_mem [0:`LINE_COUNT-1]; 
wire [31:0] index = address - Mem_Base; 
wire out_of_range = (address < Mem_Base) || (address >= (Mem_Base + `MEM_DEPTH));
wire aligned = (address[1:0] == 2'b00);  


initial begin
    $readmemh(`MEM_PATH, temp_mem);
    for (integer i = 0; i < `LINE_COUNT; i = i + 1) begin
        if ((i * 4) + 3 < `MEM_DEPTH) begin
            // little-endian: lowest byte at lowest address
            memory[(i * 4)] = temp_mem[i][7:0];
            memory[(i * 4) + 1] = temp_mem[i][15:8];
            memory[(i * 4) + 2] = temp_mem[i][23:16];
            memory[(i * 4) + 3] = temp_mem[i][31:24];
        end else begin
            $display("imemory init: temp_mem[%0d] would overflow memory, skipping", i);
        end
    end
end



wire [7:0] b0 = (index < `MEM_DEPTH) ? memory[index] : 8'b0;
wire [7:0] b1 = (index+1 < `MEM_DEPTH) ? memory[index+1] : 8'b0;
wire [7:0] b2 = (index+2 < `MEM_DEPTH) ? memory[index+2] : 8'b0;
wire [7:0] b3 = (index+3 < `MEM_DEPTH) ? memory[index+3] : 8'b0;
assign data_out = (!out_of_range) ? {b3, b2, b1, b0} : 32'b0;


always @(posedge clock) begin
    if (read_write) begin
        if (!out_of_range) begin
            memory[index]   <= data_in[7:0];
            memory[index+1] <= data_in[15:8];
            memory[index+2] <= data_in[23:16];
            memory[index+3] <= data_in[31:24];
        end else if (read_write && out_of_range) begin
            $display("Warning: out-of-range write at %h ignored", address);
        end
    end
end

endmodule
