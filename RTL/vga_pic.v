`timescale 1ns/1ps
module vga_pic (
    input wire vga_clk,
    input wire sys_rst_n,
    input wire [9:0] pix_x,
    input wire [9:0] pix_y,
    output reg [15:0] pix_data
);

localparam [15:0] BLACK=16'h0000;
localparam [15:0] BLUE=16'h001f, YELLOW=16'hffe0;

localparam [7:0] M_ROW_0 = 8'b11000011;
localparam [7:0] M_ROW_1 = 8'b11100111;
localparam [7:0] M_ROW_2 = 8'b11111111;
localparam [7:0] M_ROW_3 = 8'b11011011;
localparam [7:0] M_ROW_4 = 8'b11000011;
localparam [7:0] M_ROW_5 = 8'b11000011;
localparam [7:0] M_ROW_6 = 8'b11000011;
localparam [7:0] M_ROW_7 = 8'b11000011;
localparam [7:0] U_ROW_0 = 8'b11000011;
localparam [7:0] U_ROW_1 = 8'b11000011;
localparam [7:0] U_ROW_2 = 8'b11000011;
localparam [7:0] U_ROW_3 = 8'b11000011;
localparam [7:0] U_ROW_4 = 8'b11000011;
localparam [7:0] U_ROW_5 = 8'b11000011;
localparam [7:0] U_ROW_6 = 8'b01100110;
localparam [7:0] U_ROW_7 = 8'b00111100;
localparam [7:0] S_ROW_0 = 8'b01111110;
localparam [7:0] S_ROW_1 = 8'b11000000;
localparam [7:0] S_ROW_2 = 8'b11000000;
localparam [7:0] S_ROW_3 = 8'b01111110;
localparam [7:0] S_ROW_4 = 8'b00000011;
localparam [7:0] S_ROW_5 = 8'b00000011;
localparam [7:0] S_ROW_6 = 8'b11000011;
localparam [7:0] S_ROW_7 = 8'b01111110;
localparam [7:0] T_ROW_0 = 8'b11111111;
localparam [7:0] T_ROW_1 = 8'b11111111;
localparam [7:0] T_ROW_2 = 8'b00011000;
localparam [7:0] T_ROW_3 = 8'b00011000;
localparam [7:0] T_ROW_4 = 8'b00011000;
localparam [7:0] T_ROW_5 = 8'b00011000;
localparam [7:0] T_ROW_6 = 8'b00011000;
localparam [7:0] T_ROW_7 = 8'b00011000;

wire [9:0] local_y = pix_y-10'd208;
wire [2:0] char_y = local_y[5:3];
wire in_m_box = (pix_x >= 10'd144) && (pix_x < 10'd208) &&
    (pix_y >= 10'd208) && (pix_y < 10'd272);
wire [9:0] local_m_x = pix_x-10'd144;
wire [2:0] m_col = local_m_x[5:3];
wire in_u_box = (pix_x >= 10'd240) && (pix_x < 10'd304) &&
    (pix_y >= 10'd208) && (pix_y < 10'd272);
wire [9:0] local_u_x = pix_x-10'd240;
wire [2:0] u_col = local_u_x[5:3];
wire in_s_box = (pix_x >= 10'd336) && (pix_x < 10'd400) &&
    (pix_y >= 10'd208) && (pix_y < 10'd272);
wire [9:0] local_s_x = pix_x-10'd336;
wire [2:0] s_col = local_s_x[5:3];
wire in_t_box = (pix_x >= 10'd432) && (pix_x < 10'd496) &&
    (pix_y >= 10'd208) && (pix_y < 10'd272);
wire [9:0] local_t_x = pix_x-10'd432;
wire [2:0] t_col = local_t_x[5:3];

function [7:0] bitmap_row;
    input [1:0] letter;
    input [2:0] row;
    begin
        bitmap_row = 8'h00;
        case ({letter,row})
            5'd0: bitmap_row = M_ROW_0;
            5'd1: bitmap_row = M_ROW_1;
            5'd2: bitmap_row = M_ROW_2;
            5'd3: bitmap_row = M_ROW_3;
            5'd4: bitmap_row = M_ROW_4;
            5'd5: bitmap_row = M_ROW_5;
            5'd6: bitmap_row = M_ROW_6;
            5'd7: bitmap_row = M_ROW_7;
            5'd8: bitmap_row = U_ROW_0;
            5'd9: bitmap_row = U_ROW_1;
            5'd10: bitmap_row = U_ROW_2;
            5'd11: bitmap_row = U_ROW_3;
            5'd12: bitmap_row = U_ROW_4;
            5'd13: bitmap_row = U_ROW_5;
            5'd14: bitmap_row = U_ROW_6;
            5'd15: bitmap_row = U_ROW_7;
            5'd16: bitmap_row = S_ROW_0;
            5'd17: bitmap_row = S_ROW_1;
            5'd18: bitmap_row = S_ROW_2;
            5'd19: bitmap_row = S_ROW_3;
            5'd20: bitmap_row = S_ROW_4;
            5'd21: bitmap_row = S_ROW_5;
            5'd22: bitmap_row = S_ROW_6;
            5'd23: bitmap_row = S_ROW_7;
            5'd24: bitmap_row = T_ROW_0;
            5'd25: bitmap_row = T_ROW_1;
            5'd26: bitmap_row = T_ROW_2;
            5'd27: bitmap_row = T_ROW_3;
            5'd28: bitmap_row = T_ROW_4;
            5'd29: bitmap_row = T_ROW_5;
            5'd30: bitmap_row = T_ROW_6;
            5'd31: bitmap_row = T_ROW_7;
            default: bitmap_row = 8'h00;
        endcase
    end
endfunction

function bitmap_on;
    input [1:0] letter;
    input [2:0] row;
    input [2:0] col;
    reg [7:0] row_bits;
    begin
        row_bits = bitmap_row(letter,row);
        bitmap_on = row_bits[7-col]; 
    end
endfunction

always @(posedge vga_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        pix_data <= BLACK;
    else if (in_m_box)
        pix_data <= bitmap_on(2'd0,char_y,m_col) ? YELLOW : BLUE;
    else if (in_u_box)
        pix_data <= bitmap_on(2'd1,char_y,u_col) ? YELLOW : BLUE;
    else if (in_s_box)
        pix_data <= bitmap_on(2'd2,char_y,s_col) ? YELLOW : BLUE;
    else if (in_t_box)
        pix_data <= bitmap_on(2'd3,char_y,t_col) ? YELLOW : BLUE;
    else if ((pix_x < 10'd640) && (pix_y < 10'd480))
        pix_data <= BLUE;
    else
        pix_data <= BLACK; 
end

endmodule
