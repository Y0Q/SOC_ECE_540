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
	parameter integer	RESET_POLARITY_LOW		= 1,
	parameter integer 	CNTR_WIDTH 				= 32,
	
	parameter integer	SIMULATE_1					= 0,
	parameter integer	SIMULATE_2					= 0,
	parameter integer	SIMULATE_3					= 0,
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
	
    output reg	[7:0]	left_pos,
	output reg	[7:0]	right_pos
);

	// internal variables
//	reg [1:0] z,Z;

	// reset - asserted high
	wire reset_in = RESET_POLARITY_LOW ? ~reset : reset;
	
	// clock divider 
	reg			[CNTR_WIDTH-1:0]	clk_cnt_1;
	reg			[CNTR_WIDTH-1:0]	clk_cnt_2;
	reg			[CNTR_WIDTH-1:0]	clk_cnt_3;	
	wire		[CNTR_WIDTH-1:0]	top_cnt_1 = SIMULATE_1 ? SIMULATE_FREQUENCY_CNT_1 : ((CLK_FREQUENCY_HZ / UPDATE_FREQUENCY_HZ_1) - 1);
	wire		[CNTR_WIDTH-1:0]	top_cnt_2 = SIMULATE_2 ? SIMULATE_FREQUENCY_CNT_2 : ((CLK_FREQUENCY_HZ / UPDATE_FREQUENCY_HZ_2) - 1);
	wire		[CNTR_WIDTH-1:0]	top_cnt_3 = SIMULATE_3 ? SIMULATE_FREQUENCY_CNT_3 : ((CLK_FREQUENCY_HZ / UPDATE_FREQUENCY_HZ_3) - 1);
	reg								tick1hz;				// update clock enable	
	reg								tick5hz;				// update clock enable	
	reg								tick10hz;				// update clock enable	
    
	
//	parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100;
	
	// generate update clock enable
	always @(posedge clk) begin
		if (reset_in) begin
			clk_cnt_1 <= {CNTR_WIDTH{1'b0}};
			clk_cnt_2 <= {CNTR_WIDTH{1'b0}};
			clk_cnt_3 <= {CNTR_WIDTH{1'b0}};
		end
	
		else if (clk_cnt_2 == top_cnt_2) begin
		    tick5hz <= 1'b1;
		    clk_cnt_2 <= {CNTR_WIDTH{1'b0}};
		end	
			else begin
		    clk_cnt_2 <= clk_cnt_2 + 1'b1;
		    tick5hz <= 1'b0;
			end

	/*	
			
		 if (clk_cnt_2 == top_cnt_2) begin
		    tick5hz <= 1'b1;
		    clk_cnt_2 <= {CNTR_WIDTH{1'b0}};
		end
			else begin
		    clk_cnt_2 <= clk_cnt_2 + 1'b1;
		    tick5hz <= 1'b0;
			end
		
		 if (clk_cnt_3 == top_cnt_3) begin
		    tick10hz <= 1'b1;
		    clk_cnt_3 <= {CNTR_WIDTH{1'b0}};
		end
			else begin
		    clk_cnt_3 <= clk_cnt_3 + 1'b1;
		    tick10hz <= 1'b0;
			end
*/	
	end // update clock enable
    
    // inc/dec wheel position counters    
	always @(posedge clk) begin
		if (reset_in) begin
			left_pos <= 8'd0;
			right_pos <= 8'd0;
		end
		else if (tick5hz) begin
			case ({left_fwd, left_rev})
				2'b10: left_pos  <= left_pos + 1'b1;
				2'b01: left_pos  <= left_pos - 1'b1;
				
				default: left_pos <= left_pos;
			endcase
			case ({right_fwd, right_rev})
				2'b10: right_pos <= right_pos + 1'b1;
				2'b01: right_pos <= right_pos - 1'b1;
				
				default: right_pos <= right_pos;
			endcase
		end
		else begin
			left_pos <= left_pos;
			right_pos <= right_pos;
		end
	end  // inc/dec wheel position counters
      


//next state logic
	/*  
	always @(posedge clk) begin
	case (z)
	s0: if(reset_in)
		end
		*/
endmodule