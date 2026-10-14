`timescale 1ns / 1ns
module FullAdder_tb();

reg A = 1, B = 1, Cin = 1;
wire S, Cout;

FullAdder FA(.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));
integer i = 7;

initial begin
    $dumpfile("FullAdder_tb.vcd");
    $dumpvars(0, FullAdder_tb);

for(i = 7; i >= 0; i = i-1) begin
    #20 {A, B, Cin} = i;
end

#20 $finish;
end

endmodule