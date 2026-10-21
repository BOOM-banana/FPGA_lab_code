`timescale 1ms/1us

module counter_tb();

reg clock;
reg rst;
wire led;

counter COUNT(.sys_rst_n(rst), .sys_clk(clock), .led_out(led));
initial begin
    $dumpfile("counter_tb.vcd");
    $dumpvars(0, counter_tb);
end

initial begin
    rst = 0;
    #100;
    rst = 1;
    #100;
    rst = 0;
    #100;
    rst = 1;
    
    #1000;
    $finish;
end

initial begin
    clock = 0;
end

always #50 clock = ~clock;

endmodule
