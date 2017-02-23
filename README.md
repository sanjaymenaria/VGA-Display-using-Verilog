# VGA-Display-using-Verilog
Objective: Display 8 colors sequentially on a 640x480 pixel VGA computer display using the Spartan development board. The displayed color should change when the push button PB_UP on the board is pressed. PB_ENTER is used to reset the VGA display.

Step 1: Created project Vga_display with verilog module vga_con.
Vga_con module consist this basic variable 
Vga_clk – clk signal for board which is 25MHz.
Pb_up –  push button to start dispay
Pb_enter – To reset dispay.
Red_comp – Switch to display Red on monitor
Greeen_comp - Switch to display Green on monitor
Blue_comp  Switch to display Blue on monitor
V_sync – vertiacal Syncronus pulse
H_sync – Horizontal synocronous pulse

Step 2:  Defined the parameter for horizontal timing and vertical timing. Horizontal and vertical parameters are front_porch, back_porch, sync_pulse and active pulse. 

Step 3: FSM state parameters are defined based on design requirement. Condition is added for posedge detection and pattern change control signal. Code is wriiten for below states:
•	Horizontal Front Porch Counter
•	Horizontal Pulse Counter
•	Horizontal Pulse Counter
•	Horizontal Active Counter
•	Vertical Front Porch Counter
•	Vertical Pulse Counter
•	Vertical Back Porch Counter
•	No of Rows Counter

Step 4: RGB generation is desgined and CASE are added for 8 color combination.
White – R:1 G:1 B:1
Black – R:0 G:0 B:0
Red– R:1 G:0 B:0
Green– R:0 G:1 B:0
blue– R:0 G:0 B:1
Magenta– R:1 G:0 B:1
Yellow– R:1 G:1 B:0
Cyan– R:0 G:1 B:1

Step 5: testbench is designed and code is added to generate clock signal, pb_up and pb_enter. 
