module mux2to1 #(
    parameter WIDTH = 32   // default data width
)(
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire             sel,
    output wire [WIDTH-1:0] out
);
//mux
    assign out = sel ? in1 : in0;
endmodule