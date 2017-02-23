//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:02:53 11/01/2016 
// Design Name: 
// Module Name:    vga_con 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module vga_con
(
 input        vga_clk0       , // 25 MHz
 input        pb_enter      ,
 input        pb_up         ,
 output  	  red_comp      , 
 output  	  green_comp    , 
 output 	  blue_comp     ,
 output       v_sync        ,
 output       h_sync        ,
 output [2:0] color_pattern ,  // to the LED's
 output 	  vga_clk		,
 output 	  vga_clk_50
);

// Instantiate the module
dcm_25 instance_name (
    .CLKIN_IN(vga_clk0), 
    .RST_IN(pb_enter), 
	.CLKDV_OUT(vga_clk),
    .CLKIN_IBUFG_OUT(), 
    .CLK0_OUT(vga_clk_50), 
    .LOCKED_OUT()
    );
	 
/*------------------------------------------
  Parameter Declaration 
-------------------------------------------*/

// Horizontal Timing Parameters
parameter H_FRONT_PORCH = 16'd16  ;
parameter H_BACK_PORCH  = 16'd16  ;
parameter H_SYNC_PULSE  = 16'd128 ;
parameter H_ACT         = 16'd640 ; // No Pixels

// Vertical Timing Parameters
parameter V_FRONT_PORCH = 16'd10  ;
parameter V_BACK_PORCH  = 16'd29  ;
parameter V_SYNC_PULSE  = 16'd2   ;
parameter V_ACT         = 16'd480 ; // No Lines / No of Rows


// FSM STATES
parameter VFP_STATE     = 3'b000  ;
parameter VPULSE_STATE  = 3'b001  ;
parameter VBP_STATE     = 3'b010  ;
parameter HFP_STATE     = 3'b011  ;
parameter HPULSE_STATE  = 3'b100  ;
parameter HBP_STATE     = 3'b101  ;
parameter HACT_STATE    = 3'b110  ;




/*------------------------------------------
  Internal Declaration 
-------------------------------------------*/

reg [2:0]  color_pattern_r        ;
reg        pb_up_r                ;
wire       pattern_change_c       ;
reg        pb_enter_r             ;
wire       pattern_reset_c        ;
reg  	   red_comp_s             ;
reg  	   green_comp_s           ;
reg 	   blue_comp_s            ;
wire       h_blank_c              ; // Horizontal Front + Back Porch + Pulse
wire       v_blank_c              ; // Vertical Front + Back Porch + Pulse
wire       blanking_c             ; // when this is High
                                    // the RGB values will be driven as 0
reg [2:0]  fsm_state              ;
wire       vsync_c                ;
wire       hsync_c                ;
reg        hsync_r                ;
wire       line_start_c           ;

// Counters for individual States
reg [15:0] vfp_cntr_r             ;
reg [15:0] vpulse_cntr_r          ;
reg [15:0] vbp_cntr_r             ;
reg [15:0] hfp_cntr_r             ;
reg [15:0] hpulse_cntr_r          ;
reg [15:0] hbp_cntr_r             ;
reg [15:0] hact_cntr_r            ;
reg [15:0] vpos_cntr_r            ;


/*------------------------------------------
  Logic  
-------------------------------------------*/

// Posdge Detection
assign pattern_change_c = ( pb_up & (~pb_up_r) );
assign pattern_reset_c = ( pb_enter & (~pb_enter_r) );

assign line_start_c = ( hsync_c & (~hsync_r) ) ;

assign h_blank_c =(  ( fsm_state == HFP_STATE ) ||  
	             ( fsm_state == HBP_STATE ) || 
		     ( fsm_state == HPULSE_STATE ) )  ? 1'b1 : 1'b0 ;


assign v_blank_c =(  ( fsm_state == VFP_STATE ) ||  
	             ( fsm_state == VBP_STATE ) || 
		     ( fsm_state == VPULSE_STATE ) )  ? 1'b1 : 1'b0 ;


assign blanking_c = (h_blank_c | v_blank_c );

assign vsync_c = ( fsm_state == VPULSE_STATE ) ?  1'b0 : 1'b1 ;
assign hsync_c = ( fsm_state == HPULSE_STATE ) ? 1'b0 :1'b1 ;

// Registering the Pattern Change control Signal
always @( posedge vga_clk)
  begin
   pb_up_r <= pb_up;
   hsync_r <= hsync_c;
  end	  

// Registering the Pattern Change control Signal
always @( posedge vga_clk)
  begin
   pb_enter_r <= pb_enter;
  end	  


// color pattern Control Signal Generator
always @( posedge vga_clk)
  begin
      if ( pattern_reset_c ) begin  
       color_pattern_r <= 3'b000;
      end else if ( pattern_change_c) begin
	  color_pattern_r <= color_pattern_r + 3'b1;    
      end
  end	  

// R G B Generation
always @(*)
  begin
   if (blanking_c == 1'b1 ) begin
       red_comp_s = 1'b0;   
       green_comp_s = 1'b0;   
       blue_comp_s = 1'b0; 
   end else begin

    case (color_pattern_r)
	      3'b000 :   begin // white
		         red_comp_s = 1'b1;   
		         green_comp_s = 1'b1;   
		         blue_comp_s = 1'b1;   
			 end
	      3'b001 :   begin // Black
		         red_comp_s = 1'b0;   
		         green_comp_s = 1'b0;   
		         blue_comp_s = 1'b0;   
			 end
	      3'b010 :   begin // Red
		         red_comp_s = 1'b1;   
		         green_comp_s = 1'b0;   
		         blue_comp_s = 1'b0;   
			 end
	      3'b011 :   begin // Lime
		         red_comp_s = 1'b0;   
		         green_comp_s = 1'b1;   
		         blue_comp_s = 1'b0;   
			 end     
	      3'b100 :   begin // Blue
		         red_comp_s = 1'b0;   
		         green_comp_s = 1'b0;   
		         blue_comp_s = 1'b1;   
			 end
	      3'b101 :   begin // yellow
		         red_comp_s = 1'b1;   
		         green_comp_s = 1'b1;   
		         blue_comp_s = 1'b0;   
			 end
	      3'b110 :   begin // cyan
		         red_comp_s = 1'b0;   
		         green_comp_s = 1'b1;   
		         blue_comp_s = 1'b1;   
			 end
	      3'b111 :   begin // magneta
		         red_comp_s = 1'b1;   
		         green_comp_s = 1'b0;   
		         blue_comp_s = 1'b1;   
			 end  	
              default :   begin // white
		         red_comp_s = 1'b1;   
		         green_comp_s = 1'b1;   
		         blue_comp_s = 1'b1;   
			 end			 
       endcase 	      
      end	  
  end	  


// FSM generation
always @( posedge vga_clk)
  begin
    if ( pattern_reset_c ) begin  
       fsm_state <= VFP_STATE;
    end else begin
      case (fsm_state)
	      VFP_STATE : begin
		            if (vfp_cntr_r == V_FRONT_PORCH - 16'd1)begin
                              fsm_state <= VPULSE_STATE;
			    end else begin
                              fsm_state <= VFP_STATE;
			    end	    
		          end
	      VPULSE_STATE : begin
		            if (vpulse_cntr_r == V_SYNC_PULSE - 16'd1)begin
                              fsm_state <= VBP_STATE;
			    end else begin
                              fsm_state <= VPULSE_STATE;
			    end	    
		          end
	      VBP_STATE : begin
		            if (vbp_cntr_r == V_BACK_PORCH - 16'd1)begin
                              fsm_state <= HFP_STATE;
			    end else begin
                              fsm_state <= VBP_STATE;
			    end	    
		          end
	      HFP_STATE : begin
		            if (hfp_cntr_r == H_FRONT_PORCH - 16'd1)begin
                              fsm_state <= HPULSE_STATE;
			    end else begin
                              fsm_state <= HFP_STATE;
			    end	    
		          end
	      HPULSE_STATE : begin
		            if ( (vpos_cntr_r == V_ACT - 16'd1) && (hpulse_cntr_r == H_SYNC_PULSE - 1 ) )begin
                              fsm_state <= VFP_STATE;
			      end else if (hpulse_cntr_r == H_SYNC_PULSE - 1)begin
                              fsm_state <= HBP_STATE;
			    end else begin
                              fsm_state <= HPULSE_STATE;
			    end	    
		          end
	      HBP_STATE : begin
		            if (hbp_cntr_r == H_BACK_PORCH - 16'd1)begin
                              fsm_state <= HACT_STATE;
			    end else begin
                              fsm_state <= HBP_STATE;
			    end	    
		          end
	      HACT_STATE : begin
		            if (hact_cntr_r == H_ACT - 16'd1)begin
                              fsm_state <= HFP_STATE;
			    end else begin
                              fsm_state <= HACT_STATE;
			    end	    
		           end
	      default : begin
                          fsm_state <= VFP_STATE;
		        end			  
      endcase
    end
  end	  


// Vertical Front Porch Counter
always @( posedge vga_clk)
  begin
    if ( pattern_reset_c  == 1'b1 ) begin  
       vfp_cntr_r <= 16'b0;
    end else if ( vfp_cntr_r == V_FRONT_PORCH - 16'd1) begin
       vfp_cntr_r <= 16'b0;
    end else if ( fsm_state  == VFP_STATE) begin  
       vfp_cntr_r <= vfp_cntr_r + 16'd1;
      end
  end	


// Vertical Pulse Counter
always @( posedge vga_clk)
  begin
    if ( pattern_reset_c  == 1'b1 ) begin  
       vpulse_cntr_r <= 16'b0;
    end else if (vpulse_cntr_r == V_SYNC_PULSE - 16'd1)begin
       vpulse_cntr_r <= 16'b0;
    end else if ( fsm_state  == VPULSE_STATE) begin  
       vpulse_cntr_r <= vpulse_cntr_r + 16'd1;
      end
  end	


// Vertical Back Porch Counter
always @( posedge vga_clk)
  begin
    if ( pattern_reset_c  == 1'b1 ) begin  
       vbp_cntr_r <= 16'b0;
    end else if (vbp_cntr_r == V_BACK_PORCH - 16'd1)begin
       vbp_cntr_r <= 16'b0;
    end else if ( fsm_state  == VBP_STATE) begin  
       vbp_cntr_r <= vbp_cntr_r + 16'd1;
      end
  end	

// Horizontal Front Porch Counter
always @( posedge vga_clk)
  begin
    if ( pattern_reset_c  == 1'b1 ) begin  
       hfp_cntr_r <= 16'b0;
    end else if (hfp_cntr_r == H_FRONT_PORCH - 16'd1)begin
       hfp_cntr_r <= 16'b0;
    end else if ( fsm_state  == HFP_STATE) begin  
       hfp_cntr_r <= hfp_cntr_r + 16'd1;
      end
  end	

// Horizontal Pulse Counter
always @( posedge vga_clk)
  begin
    if ( pattern_reset_c  == 1'b1 ) begin  
       hpulse_cntr_r <= 16'b0;
    end else if (hpulse_cntr_r == H_SYNC_PULSE - 16'd1)begin
       hpulse_cntr_r <= 16'b0;
    end else if ( fsm_state  == HPULSE_STATE) begin  
       hpulse_cntr_r <= hpulse_cntr_r + 16'd1;
      end
  end	

// Horizontal Pulse Counter
always @( posedge vga_clk)
  begin
    if ( pattern_reset_c  == 1'b1 ) begin  
       hbp_cntr_r <= 16'b0;
    end else if (hbp_cntr_r == H_BACK_PORCH - 16'd1)begin
       hbp_cntr_r <= 16'b0;
    end else if ( fsm_state  == HBP_STATE) begin  
       hbp_cntr_r <= hbp_cntr_r + 16'd1;
      end
  end	

// Horizontal Active Counter 
always @( posedge vga_clk)
  begin
    if ( pattern_reset_c  == 1'b1 ) begin  
       hact_cntr_r <= 16'b0;
    end else if (hact_cntr_r == H_ACT - 16'd1)begin
       hact_cntr_r <= 16'b0;
    end else if ( fsm_state  == HACT_STATE) begin  
       hact_cntr_r <= hact_cntr_r + 16'd1;
      end
  end	



// No of Rows Conter 
always @( posedge vga_clk)
  begin
    if ( pattern_reset_c  == 1'b1 ) begin  
       vpos_cntr_r <= 16'b0;
    end else if ( (vpos_cntr_r == V_ACT - 16'd1) && (hpulse_cntr_r == H_SYNC_PULSE - 1) )begin
       vpos_cntr_r <= 16'b0;
    end else if ( line_start_c && (fsm_state  != VFP_STATE) )begin  
       vpos_cntr_r <= vpos_cntr_r + 16'd1;
      end
  end



/*------------------------------------------
  Output Port Assignment  
-------------------------------------------*/

assign color_pattern = color_pattern_r;
assign v_sync = vsync_c;
assign h_sync = hsync_c;
assign red_comp = red_comp_s;
assign green_comp = green_comp_s;
assign blue_comp = blue_comp_s;
assign red = 1'b1;
assign blue = 1'b1;
assign green = 1'b1;
endmodule
