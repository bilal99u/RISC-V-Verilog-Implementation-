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
wire [31:0] index = address;
reg [31:0] temp_mem [0:`LINE_COUNT-1]; 


initial begin
    $readmemh(`MEM_PATH, temp_mem);
    for (integer i = 0; i < `LINE_COUNT; i = i + 1) begin
        if ((i * 4) + 3 < `MEM_DEPTH) begin
            // little-endian: lowest byte at lowest address
            memory_array[(i * 4)] = temp_mem[i][7:0];
            memory_array[(i * 4) + 1] = temp_mem[i][15:8];
            memory_array[(i * 4) + 2] = temp_mem[i][23:16];
            memory_array[(i * 4) + 3] = temp_mem[i][31:24];
        end else begin
            $display("imemory init: temp_mem[%0d] would overflow memory, skipping", i);
        end
    end
    $display("Memory initialized, %h,%h,%h,%h", memory_array[0][3],memory_array[0][2],memory_array[0][1],memory_array[0][0] );
end


always@(*) begin 
    if (read_write==0) begin
        case (access_size)
            2'b00:
                data_out = (is_signed) ? {{24{memory_array[index][7]}}, memory_array[index]} : {24'b0, memory_array[index]};
            2'b01:
                data_out =(is_signed ? {{16{memory_array[index+1][7]}}, memory_array[index+1], memory_array[index]}:{16'b0, memory_array[index+1], memory_array[index]});
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
            default:
            begin 
                memory_array[index] <= data_in[7:0];
                memory_array[index+1] <= data_in[15:8];
                memory_array[index+2] <= data_in[23:16];
                memory_array[index+3] <= data_in[31:24];
            end
        endcase
    end
end
endmodule
