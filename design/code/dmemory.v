module dmemory #()
(
    input wire clock,
    input wire [31:0] address,
    input wire [31:0] data_in,
    input wire read_write,  // 0 is for read, 1 is for write
    input wire [1:0] access_size, // 00 is byte, 01 is halfword, 10 is word
    input wire is_signed, // 0 is unsigned, 1 is signed
    output reg [31:0] data_out
);

reg [7:0] memory_array [0:`MEM_DEPTH-1];
localparam Mem_Base = 32'h0100_0000;
wire [31:0] index = address - Mem_Base;
wire out_of_range = (address < Mem_Base) || (address >= (Mem_Base + `MEM_DEPTH));

always@(*) begin 
    if (read_write==0) begin
        case (access_size)
            2'b00:
                data_out = (is_signed? {24'b{memory_array[index][7]}}:{24'b0, memory_array[index]});
            2'b01:
                (is_signed ? {{16{memory_array[index+1][7]}}, memory_array[index+1], memory_array[index]}:{16'b0, memory_array[index+1], memory_array[index]})

            2'b10:
                data_out = {memory_array[index+3], memory_array[index+2], memory_array[index+1], memory_array[index]};
            default:
                data_out = 32'b0;
        endcase
    end

end

always@(posedge clock) begin
    if (read_write==1) begin
        case (access_size)
            2'b00:
                memory_array[index] <= data_in[7:0];
            2'b01: 
            begin
                memory_array[index] <= data_in[7:0];
                memory_array[index+1] <= data_in[15:8];
            end
            2'b10:
            begin
                memory_array[index] <= data_in[7:0];
                memory_array[index+1] <= data_in[15:8];
                memory_array[index+2] <= data_in[23:16];
                memory_array[index+3] <= data_in[31:24];
            end
        endcase
    end
end

always@(posedge clock) begin
    if (out_of_range) begin
        $display("Data Memory Error: Address %h is out of range.", address);
        $finish;
    end
end

endmodule
