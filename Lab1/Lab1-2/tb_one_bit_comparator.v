`timescale 1ns / 1ns

module tb_one_bit_comparator;

reg A;
reg B;

wire A1;
wire B1;

wire LED1;
wire LED2;
wire LED3;

assign A1 = ~A;
assign B1 = ~B;


initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_one_bit_comparator);
end

initial begin
    $monitor("Time=%0t ns | A=%b, B=%b | A1=%b, B1=%b | LED1=%b, LED2=%b, LED3=%b",
             $time, A, B, A1, B1, LED1, LED2, LED3);

    A = 1'b0; B = 1'b0;
    #10;
    A = 1'b0; B = 1'b1;
    #10;
    A = 1'b1; B = 1'b0;
    #10;
    A = 1'b1; B = 1'b1;
    #20;

    $finish;
end

one_bit_comparator DUT (
    .A(A),
    .B(B),
    .LED1(LED1),
    .LED2(LED2),
    .LED3(LED3)
);

endmodule

