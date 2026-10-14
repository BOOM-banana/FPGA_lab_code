`timescale 1ns/1ps

module one_bit_comparator(
    input wire A,
    input wire B,
    output wire LED1,
    output wire LED2,
    output wire LED3
);

wire A1=~A;
wire B1=~B;

assign LED1 = (~A1) & B1;
assign LED2 = (A1 == B1);
assign LED3 = A1 & (~B1);

endmodule