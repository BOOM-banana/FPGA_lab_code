`timescale 1ns / 1ps

module tb_running_light;

    reg  sys_clk;
    reg  sys_rst_n;
    wire led1, led2, led3, led4;

    // ---- DUT ----
    running_light u_running_light (
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .led1      (led1),
        .led2      (led2),
        .led3      (led3),
        .led4      (led4)
    );

    // ---- 50 MHz clock: period 20 ns ----
    initial sys_clk = 1'b0;
    always #10 sys_clk = ~sys_clk;

    // ---- stimulus ----
    initial begin
        $dumpfile("tb_running_light.vcd");
        $dumpvars(0, tb_running_light);

        // apply reset
        sys_rst_n = 1'b0;
        #100;
        sys_rst_n = 1'b1;

        // run long enough to see wrap-around (see note below on shortened count)
        #2_100_000_000;   // 2.1 s simulated time

        // mid-count reset test
        sys_rst_n = 1'b0;
        #30;
        sys_rst_n = 1'b1;

        #1_100_000_000;   // 1.1 s after reset

        $finish;
    end

    // ---- print for quick checking ----
    initial begin
        $timeformat(-9, 0, " ns", 6);
        $monitor("t=%t | rst_n=%b | led1..4=%b%b%b%b | idx=%0d",
                 $time, sys_rst_n, led1, led2, led3, led4,
                 u_running_light.led_idx);
    end

endmodule
