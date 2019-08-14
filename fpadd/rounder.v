/*
	Block Name:	rounder.v
	Author:		Justin Schauer
	Date:		6/14/01
	
	Block Description:
	  This is the rounding module for an FP adder. It takes as inputs the normalized sum,
	  the round bit, the sticky bit, the amount the sum has been shifted so far, the sign of
	  the final result, and the rounding mode, and uses these to determine the appropriate
	  rounding procedure. It also calculates the final exponent, taking into account if there
	  was overflow during rounding.
*/

`include "constants.v"

module rounder(normsum, round, sticky, roundmode,
		finalsign, overexp, roundsum, roundshift, rm, rz, rp, rn, exp);
		
input	[`WSIG-1:0]		normsum;	// the normalized sum
input				round;		// round bit
input				sticky;		// the sticky bit
input	[1:0]			roundmode;	// round mode selection
input				finalsign;	// final sign of FP result from final
input	[`WEXP-1:0]		overexp;	// the exponent calculated in normlize with shifting
output	[`WSIG-1:0]		roundsum;	// the correctly rounded sum in significand form (no leading 1)
output				roundshift;	// indicates whether there was overflow during mantissa addition
output				rm, rz, rp, rn;	// rounding mode selection
output	[`WEXP:0]		exp;		// the final, non special-case exponent

wire				addone;		// high if will have to add 1 during rounding
wire	[`WSIG:0]		overflowsum;	// sum with extra bit for overflow
wire	[1:0]			overshift;	// correction amount, 2 if overflow during round

// decode round mode
assign rn = ~roundmode[1] & ~roundmode[0];	// 00 = round to nearest even
assign rz = ~roundmode[1] & roundmode[0];	// 01 = round to zero
assign rp = roundmode[1] & ~roundmode[0];	// 10 = round to plus infinity
assign rm = roundmode[1] & roundmode[0];	// 11 = round to minus infinity

// this is the logic that determines what to do during rounding
assign addone = (rn & round & (sticky | normsum[0]) ) |
                (rp & ~finalsign & (round | sticky)) | 
	        (rm & finalsign & (round | sticky));

// result in the event of rounding up
assign overflowsum = normsum + 1;

// determines if the exponent overflows for use in overflow determination
assign roundshift = overflowsum[`WSIG] & addone;

// this changes the normalized mantissa to what is dictated by the rounding mode
assign roundsum = addone ? overflowsum[`WSIG-1:0] : normsum;

assign overshift = roundshift ? 2 : 1;		// overshift logic

assign exp = overexp + overshift;		// formula to calculate final exponent
		
endmodule
