`timescale 1ns/1ps

module vga_must_tb;

reg sys_clk;
reg sys_rst_n;
wire hsync;
wire vsync;
wire [15:0] rgb;

// Instantiate the top module
vga_must uut (
    .sys_clk(sys_clk),
    .sys_rst_n(sys_rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .rgb(rgb)
);

// 50 MHz system clock = 20 ns period
initial begin
    sys_clk = 0;
    forever #10 sys_clk = ~sys_clk;
end

// 25 MHz VGA clock for reference (inside DUT it's generated, but we can observe)
// We will dump signals and check the VGA clock in GTKWave

// Stimulus
initial begin
    // 1. Assert reset at the beginning
    sys_rst_n = 0;
    
    // Dump waves for GTKWave
    $dumpfile("vga_must_tb.vcd");
    $dumpvars(0, vga_must_tb);
    
    // Wait for a few clocks (100ns)
    #100;
    
    // Release reset
    sys_rst_n = 1;
    
    // Let the system run for a bit to scan the screen
    // Full frame takes 16.8ms, we need enough time to reach the M box
    // The M box is around y = 208, x = 144. This takes roughly a few milliseconds.
    #20_000_000; // 20 ms simulation time (covers full frame)

    // 2. Test reset behavior again
    sys_rst_n = 0;
    #200;
    if (rgb !== 16'h0000) $display("ERROR: RGB not black during reset!");
    else $display("RESET CHECK PASSED: RGB is black during reset.");

    sys_rst_n = 1;
    #100;
    $display("Simulation finished.");
    $finish;
end

// 3. Probe specific pixel positions (Monitor specific coordinates)
// Because pix_x and pix_y are internal to vga_ctrl, we can access them via hierarchical reference
// Warning: This might be fragile if module names change, but works for verification.
wire [9:0] pix_x = uut.vga_ctrl_inst.pix_x;
wire [9:0] pix_y = uut.vga_ctrl_inst.pix_y;

// We use a "wait" statement to check specific pixel values when they are outputted
// Note: Because there is a 1-clock delay from pix_data_req, rgb is valid one clock after pix_x/y.
// We probe at the clock edge when rgb is valid.

integer check_m_passed = 0;
integer check_bg_passed = 0;

always @(posedge sys_clk) begin
    if (sys_rst_n && uut.vga_ctrl_inst.rgb_valid) begin
        // Check a point inside the "M" box that should be YELLOW (letter pixel)
        // M box is x:144-207, y:208-271. Let's pick x=144, y=208 (Top-left corner of M)
        // According to the bitmap, M_ROW_0[7] (leftmost) is 1, so it should be YELLOW.
        if (pix_x == 10'd144 && pix_y == 10'd208 && check_m_passed == 0) begin
            if (rgb == 16'hffe0) begin // YELLOW
                $display("PASS: M pixel at (144, 208) is YELLOW.");
                check_m_passed = 1;
            end else begin
                $display("FAIL: M pixel at (144, 208) is %h, expected YELLOW.", rgb);
            end
        end
        
        // Check a background pixel (e.g., x=0, y=0) inside valid window
        // Should be BLUE (0x001f)
        if (pix_x == 10'd0 && pix_y == 10'd0 && check_bg_passed == 0) begin
            if (rgb == 16'h001f) begin
                $display("PASS: Background pixel at (0, 0) is BLUE.");
                check_bg_passed = 1;
            end else begin
                $display("FAIL: Background pixel at (0, 0) is %h, expected BLUE.", rgb);
            end
        end
    end
end

endmodule