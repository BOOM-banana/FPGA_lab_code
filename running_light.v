`timescale 1ns / 1ps
module running_light (
    input  wire sys_clk,     // 50 MHz system clock
    input  wire sys_rst_n,   // active-low async reset (B3)
    output reg  led1,        // LED0, active-low
    output reg  led2,        // LED1, active-low
    output reg  led3,        // LED2, active-low
    output reg  led4         // LED3, active-low
);

    // 0.5 s / 20 ns = 25_000_000 -> need 25 bits
    localparam integer CNT_MAX = 25_000_000 - 1;   // 24_999_999

    reg [24:0] cnt;      // 0.5 s timer
    reg [1:0]  led_idx;  // current LED index 0..3

    // ---- 0.5 s timer + LED index update ----
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            cnt     <= 25'd0;
            led_idx <= 2'd0;                // initial: LED0 (led1)
        end else if (cnt == CNT_MAX) begin
            cnt     <= 25'd0;
            led_idx <= led_idx + 2'd1;      // next LED (wraps 3 -> 0)
        end else begin
            cnt     <= cnt + 25'd1;
        end
    end

    // ---- one-hot decoding, active-low ----
    // led1..led4: 0 = ON, 1 = OFF
    // LED0 on: led1=0, led2=1, led3=1, led4=1
    // LED1 on: led1=1, led2=0, led3=1, led4=1
    // LED2 on: led1=1, led2=1, led3=0, led4=1
    // LED3 on: led1=1, led2=1, led3=1, led4=0
    always @(*) begin
        case (led_idx)
            2'd0: begin led1 = 1'b0; led2 = 1'b1; led3 = 1'b1; led4 = 1'b1; end
            2'd1: begin led1 = 1'b1; led2 = 1'b0; led3 = 1'b1; led4 = 1'b1; end
            2'd2: begin led1 = 1'b1; led2 = 1'b1; led3 = 1'b0; led4 = 1'b1; end
            2'd3: begin led1 = 1'b1; led2 = 1'b1; led3 = 1'b1; led4 = 1'b0; end
            default: begin led1 = 1'b0; led2 = 1'b1; led3 = 1'b1; led4 = 1'b1; end
        endcase
    end

endmodule