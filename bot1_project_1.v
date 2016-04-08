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
	
    output wire	[9:0]	compass_val, //12- bit value for 0-360 degree
	output reg	[4:0]	motion_val,
	output reg	[7:0]	right_pos
);

	// internal variables
	
	 reg [8:0]  binary;
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
    
	reg incr,decr;
	wire inc,dec;
	
	
	
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
		
			incr <= 1'b0;
			decr <= 1'b0;
			binary <= 1'b0;
			motion_val <= 5'd00;
		//	val <= 12'd0;
		end
				
	/*
			else  	if	(binary == 10'd360) begin
						 binary <= 10'd0;
					end	
					
			else    if  (binary == 10'd0 )  begin
						 binary <= 10'360;
					end
	*/
	//		else if (binary ~= 10'd360) begin
			
				else case ({left_fwd,right_rev,left_rev,right_fwd})
						
					4'b1100: 	if (tick10hz) begin
								
								
								binary <= binary + 1'b1;
								
								if ( (motion_val < 5'd16) | (motion_val > 5'd20) ) begin
									motion_val <= 5'd16;
								end
								else begin
								 
								 motion_val <= motion_val + 1'd1;
								end
								end
								
					4'b0011:	if (tick10hz) begin
								
								binary  <= binary - 1'b1;
								
									if ( (motion_val < 5'd17) | (motion_val > 5'd20) ) begin
									motion_val <= 5'd20;
								end
								else begin
								 
								 motion_val <= motion_val - 1'd1;
								end
								end
								
					4'b1000: if (tick5hz) begin
								binary  <= binary - 1'b1;
							 end
							 
					4'b0100: if (tick5hz) begin
								binary  <= binary - 1'b1;
							 end		 
						
					
							
				default: binary <= binary;
			endcase
			end
			
			
assign compass_val = {hundreds,tens,ones};
			
		// Binary to BCD conversion
	
	always @(binary) begin
	
	hundreds = 4'd0;
	tens  = 4'd0;
	ones = 4'd0;
	
	for (i=9 ; i>=0; i=i-1)
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
	
		
	 // inc/dec wheel position counters
        
	 /*
	
// BCD counter (count from 0-9)
	always @(clk) begin
	if (reset_in) begin
		
			compass_val <= 1'b0;
		
		end
									
				else if (inc) begin
					
			
				
									if 	(compass_val[3:0] == 12'b1001) begin
										 compass_val[3:0]  <= 4'b0;
									if 	(compass_val[7:4] == 12'b1001) begin
										 compass_val[7:4]  <= 4'b0;
									if 	(compass_val[11:8] == 12'b1001)
										 compass_val[11:8]  <= 4'b0;
									else 
										
										compass_val[11:8]  <= compass_val[11:8] + 1'b1;
									end	
									
									else begin
										compass_val[7:4]  <= compass_val[7:4] + 1'b1;
									end	
									end
									else begin
										
										compass_val[3:0]  <= compass_val[3:0] + 1'b1;
								end
												
								end				
									
									
		else	if (dec) begin 
				if	(compass_val == 12'd0) begin
					 compass_val <= 12'd360;
				end	
				else begin
				compass_val  <= compass_val - 1'b1;
				end
				end
				end
						
// BCD counter (count from 0-9)
*/
		
endmodule