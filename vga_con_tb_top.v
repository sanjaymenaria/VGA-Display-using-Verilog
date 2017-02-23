////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:04:18 11/01/2016
// Design Name:   vga_con
// Module Name:   D:/Proj_vga/vga_con_tb_top.v
// Project Name:  Proj_vga
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: vga_con
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module vga_con_tb_top;

reg vga_clk, pb_enter, pb_up;
wire red_comp; 
wire green_comp;
wire blue_comp;
wire v_sync;
wire h_sync;
wire [2:0] color_pattern;
wire red;
wire green;
wire blue;

initial begin
  vga_clk = 0;
  forever begin
    #20;
    vga_clk = ~vga_clk;
  end
end

initial begin
  pb_enter = 1'b0;
  #100;
  pb_enter = 1'b1;
  #100;
  pb_enter = 1'b0;
end


initial begin
  pb_up = 1'b0;
	 #100;
  pb_up = 1'b1;
     #100;
  pb_up = 1'b0;
     #100;
  pb_up = 1'b1;
     #100;
  pb_up = 1'b0;
end


vga_con vga_con_inst(
  .vga_clk            (vga_clk)       , 
  .pb_enter           (pb_enter)      ,
  .pb_up              (pb_up)         ,
  .red_comp           (red_comp)      , 
  .green_comp         (green_comp)    , 
  .blue_comp          (blue_comp)     ,
  .v_sync             (v_sync)        ,
  .h_sync             (h_sync)        ,
  .red				  (red)			  ,
  .green			  (green)		  ,
  .blue				  (blue)		  ,
  .color_pattern      (color_pattern)   
                     );

endmodule