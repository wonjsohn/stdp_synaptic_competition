/*
	Block Name:	normlize.v
	Author:		Justin Schauer
	Date:		6/14/01
	
	Block Description:
	  This block is part of an FP adder. It takes a sum as an input, then shifts the sum so that
	  the MSB is 1. The shift is accomplished by using a priority encoder to encode the
	  position of the leading 1. The sum is then shifted either by this encoded amount, or by
	  biggerexp + 1 (if result is denormal) and the module outputs the amount of
	  the shift, the 23 bit mantissa, and the round and sticky bits. The result is also checked
	  for being zero or denormal, and the inex flag is set if there are round or sticky bits.
*/

`include "constants.v"

module normlize(sum, biggerexp, presticky, guard, effop, undertrap, normsum,
	normalshift, round, sticky, zero, denorm, inex, overexp);

input	[`EXTRASIG:0]		sum;		// the un-normalized sum
input	[`WEXP-1:0]		biggerexp;	// the larger of expa and expb
input				presticky;	// sticky bit
input				guard;		// guard bit, shifted into significand if MSB cancels
input				effop;		// effective operation
input				undertrap;	// trapped underflow
output	[`WSIG-1:0]		normsum;	// the normalized sum
output	[`SHIFT-1:0]		normalshift;	// this will hold the amount to shift sum for normalization
output				round;		// the rounding bit
output				sticky;		// sticky bit for rounding
output				zero;		// whether or not final mantissa is 0
output				denorm;		// high if result is denormal
output				inex;		// if there are round or sticky bits, the final result will be inexact
output	[`WEXP:0]		overexp;	// exponent with all shifts and biases taken into account

wire	[`WEXP-1:0]		biasexp;	// exponent with trapped under/overflow bias
wire	[`SHIFT-1:0]		shiftamount;	// amount to left shift sum
wire	[`EXTRASIG:0]		shiftedsum;	// holds sum shifted by normalization amount
wire				shifttwo;	// high if MSB cancels on subtraction

// this determines the amount to shift the sum based on where the first 1 is found in the sum
// it's basically a sort of priority encoder.
`include "lzencode.v"

assign overexp = biggerexp - normalshift;

// chooses whether to use denorm shifting or leading zero shifting
assign shiftamount = (overexp[`WEXP] & ~undertrap) ? biggerexp : normalshift;

// shift the sum the amount determined by number of leading 0's
// or by biggerexp+1 for denormalized numbers
assign shiftedsum = sum << shiftamount;

// determines whether the MSB will cancel when subtracting
assign shifttwo = effop & ~|normalshift[`SHIFT-1:2] & normalshift[1] & ~normalshift[0];

// these break the shifted sum into its componants: the 23 bits that will actually become the new FP # and the
// round and sticky bits, which will be used for rounding
assign normsum = shiftedsum[`EXTRASIG-1:2];
assign round = shifttwo ? (presticky ^ guard) : (~(|normalshift[`SHIFT-1:1] & effop) & shiftedsum[1]);
assign sticky = shifttwo ? presticky : (shiftedsum[0] | guard | presticky);

assign zero = ~|shiftedsum;		// tests to see if result is zero

// logic to determine if result is denormalized
assign denorm = overexp[`WEXP] & |normsum;

assign inex = round | sticky;		// if some non-0 bits were cut off, the result will be inexact

endmodule
