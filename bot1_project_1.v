// bot1.v - Reference design for ECE 540 Project 1
//
// Copyright John Lynch and Roy Kravitz, 2014-2015, 2016
// 
// Created By:		Roy Kravitz, John Lynch
// Last Modified:	21-Aug-2014 (RK)
//
// Revision History:
// -----------------
// Dec-2006		JL		Created this module for ECE 540
// Dec-2013		RK		Cleaned up the formatting.  No functional changes
// Aug-2014		RK		Parameterized module.  Modified for Vivado and Nexys4
//
// Description:
// ------------
// This module is the reference design for  ECE 540 Project 1.  It
// emulates a simple two-wheeled robot.  Each wheel is controlled independently by
// pushbuttons.  The "forward" buttons increase 8-bit wheel counters (one per wheel)
// The "reverse" buttons decrease the wheel counters.  The wheel counters are 
// incremented at 5Hz by dividing the system clock down to 5Hz.
// The "SIMULATE" parameter should be set to 1'b1 if the design is being
// simulated to keep the simulation time reasonable.

// Source : http://www.eng.utah.edu/~nmcdonal/Tutorials/BCDTutorial/BCDConversion.html
// 
///////////////////////////////////////////////////////////////////////////
`timescale  1 ns / 1 ns
module RojoBot1
#(
	// parameters
	parameter integer	CLK_FREQUENCY_HZ		= 100000000, 
	
	parameter integer	UPDATE_FREQUENCY_HZ_1		= 1,
	parameter integer	UPDATE_FREQUENCY_HZ_2		= 5,
	parameter integer	UPDATE_FREQUENCY_HZ_3		= 10,
	parameter integer	RESET_POLARITY_LOW			= 1,
	parameter integer 	CNTR_WIDTH 					= 32,
	
	parameter integer	SIMULATE					= 1'b0,
	parameter integer	SIMULATE_FREQUENCY_CNT_1	= 1,
	parameter integer	SIMULATE_FREQUENCY_CNT_2	= 5,
	parameter integer	SIMULATE_FREQUENCY_CNT_3	= 10
)
(
    input 				clk,
	input				reset,
	input				left_fwd,
	input				left_rev,
	input				right_fwd,
	input				right_rev,
	
    output wire	[10:0]	compass_val, //12- bit value for 0-360 degree
	output reg	[4:0]	motion_val,
	output reg	[7:0]	right_pos
);

	// internal variables
	
	 reg [9:0] binary;
	 reg [3:0] hundreds;
	 reg [3:0] tens;
	 reg [3:0] ones;
	integer i;
	
	// reset - asserted high
	wire reset_in = RESET_POLARITY_LOW ? ~reset : reset;
	
	// clock divider 
	reg			[CNTR_WIDTH-1:0]	clk_cnt_1;
	reg			[CNTR_WIDTH-1:0]	clk_cnt_2;
	reg			[CNTR_WIDTH-1:0]	clk_cnt_3;
	
	wire		[CNTR_WIDTH-1:0]	top_cnt_1 = SIMULATE ? SIMULATE_FREQUENCY_CNT_1 : ((CLK_FREQUENCY_HZ / UPDATE_FREQUENCY_HZ_1) - 1);
	wire		[CNTR_WIDTH-1:0]	top_cnt_2 = SIMULATE ? SIMULATE_FREQUENCY_CNT_2 : ((CLK_FREQUENCY_HZ / UPDATE_FREQUENCY_HZ_2) - 1);
	wire		[CNTR_WIDTH-1:0]	top_cnt_3 = SIMULATE ? SIMULATE_FREQUENCY_CNT_3 : ((CLK_FREQUENCY_HZ / UPDATE_FREQUENCY_HZ_3) - 1);
	reg								tick1hz;	// update clock enable
	reg								tick5hz;	
	reg								tick10hz;		
    

	
	//   assign compass_val = compass_val;
	
	
	// generate update clock enable
	always @(posedge clk) begin
		if (reset_in) begin
			clk_cnt_1 <= {CNTR_WIDTH{1'b0}};
			
		end
		
		else if (clk_cnt_1 == top_cnt_1) begin
		    tick1hz <= 1'b1;
		    clk_cnt_1 <= {CNTR_WIDTH{1'b0}};
		end
		else begin
		    clk_cnt_1 <= clk_cnt_1 + 1'b1;
		    tick1hz <= 1'b0;
	
		end
		
	end // update clock enable
	
	// generate update clock enable
	always @(posedge clk) begin
		if (reset_in) begin
			
			clk_cnt_2 <= {CNTR_WIDTH{1'b0}};
			
		end
		
		else if (clk_cnt_2 == top_cnt_2) begin
		    tick5hz <= 1'b1;
		    clk_cnt_2 <= {CNTR_WIDTH{1'b0}};
		end
		else begin
		   
	
		    clk_cnt_2 <= clk_cnt_2 + 1'b1;
		    tick5hz <= 1'b0;
			
		   
		end
		
	end // update clock enable
	
	
	// generate update clock enable
	always @(posedge clk) begin
		if (reset_in) begin
			
			clk_cnt_3 <= {CNTR_WIDTH{1'b0}};
			
		end
		
		else if (clk_cnt_3 == top_cnt_3) begin
		    tick10hz <= 1'b1;
		    clk_cnt_3 <= {CNTR_WIDTH{1'b0}};
		end
		else begin
		   
	
		    clk_cnt_3 <= clk_cnt_3 + 1'b1;
		    tick10hz <= 1'b0;
			
		   
		end
		
	end // update clock enable
	
    // inc/dec wheel position counters    
	always @(posedge clk) begin
		if (reset_in) begin
		
		
			binary <= 10'd0;
			motion_val <= 5'd00;
		
		end
				
	
			else  	if	((binary == 10'd361)  ) begin
						  binary <= 10'd0;
					end
		
				else if((binary != 10'd361) )	begin

					case ({left_fwd,right_rev,left_rev,right_fwd})
						
					// STOP 
								
					4'b0000:	if (tick1hz) begin
								motion_val <= 5'd22;  
								end
					//FORWARD
					
					4'b1001: 	if (tick1hz) begin
								
								
								if (motion_val == 5'd16) begin
								
								motion_val <=5'd30; // blank...go to default case
								end
								else begin
									
								motion_val <= 5'd16;
								
								end
							 end
							 
					//REVERSE		 
					4'b0110: 	if (tick1hz) begin
							
								if (motion_val == 5'd19) begin
								
								motion_val <=5'd30; // blank...go to default case
								end
								else begin
									
								motion_val <= 5'd19;
								
								end
							 end		 
					
					 // RIGHT 2X
					4'b1100: 	if (tick10hz) begin
								
								
								binary <= binary + 1'b1;
								
								if ( (motion_val < 5'd16) | (motion_val > 5'd20) ) begin
									motion_val <= 5'd16;
								end
								else begin
								 
								 motion_val <= motion_val + 1'd1;
								 
								end
								end
					
					// LEFT 2X					
					4'b0011:	if (tick10hz) begin
								
								if (binary == 10'd0) begin
								binary <= 10'd359;
								end
											
								else begin
								binary  <= binary - 1'b1;
								
								
								if ( (motion_val < 5'd17) | (motion_val > 5'd20) ) begin
									motion_val <= 5'd20;
								end
								else begin
								 
								 motion_val <= motion_val - 1'd1;
								end
								end
								end
								
					// LEFT 1X
							 
					4'b0001: if (tick5hz) begin
					
								if (binary == 10'd0) begin
								binary <= 10'd359;
								end
											
								else begin
								
								binary  <= binary - 1'b1;
								
								if ( (motion_val < 5'd17) | (motion_val > 5'd20) ) begin
									motion_val <= 5'd20;
								end
								else begin
								 
								 motion_val <= motion_val - 1'd1;
								end
								end
								end
							 
					// RIGHT 1X
					
					4'b1000: if (tick5hz) begin
								binary  <= binary + 1'b1;
								
								if ( (motion_val < 5'd16) | (motion_val > 5'd20) ) begin
									motion_val <= 5'd16;
								end
								else begin
								 
								 motion_val <= motion_val + 1'd1;
								 
								end
							 end		 	


			default: binary <= binary;
			endcase
			end
			end
			
		
		
	 // inc/dec wheel position counters
 	
			
assign compass_val = {hundreds,tens,ones};
			
		// Binary to BCD conversion
	
	always @(binary) begin
	
	hundreds = 4'd0;
	tens  = 4'd0;
	ones = 4'd0;
	
	
	for (i=8 ; i>=0; i=i-1)
	begin
	
	if (hundreds >= 5)
		hundreds = hundreds+3;
	if (tens >= 5)	
		tens =tens +3;
	if (ones >= 5)	
		ones = ones+3;
		
		hundreds= hundreds << 1;
		hundreds [0] =tens [3];
		tens =tens << 1;
		tens[0] = ones[3];
		ones =ones << 1;
		ones [0] = binary [i];
		end
		end

		
endmodule