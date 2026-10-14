`timescale 1ns / 1ns

module FullAdder(
input A, 
input B, 
input Cin,
output wire S, 
output wire Cout
);

wire [1:0] tem;

assign tem = {1'b0, ~A} + {1'b0, ~B} + {1'b0, ~Cin};
assign {Cout, S} = ~tem;

endmodule