/*
	Block Name:	mantadd.v
	Author:		Justin Schauer
	Date:		6/14/01
	
	Block Description:
	  This block determines the necessary operation to perform on two
	  floating point numbers (addition or subtraction) and then performs
	  that operation. It is a part of a floating point adder, so it takes two
	  properly shifted mantissae with/without leading ones and the signs of the
	  original numbers, and returns the result of the effective operation on the
	  mantissae (the "sum"). It also calculates the or of discarded bits for use
	  in rounding.
*/

`include "constants.v"

module mantadd(sa, sb, x, y, op, sum, presticky, guard, effop);

input				sa;		// sign of 1st FP operand
input				sb;		// sign of 2nd FP operand
input	[`WSIG+1:0]		x;		// the bigger mantissa
input	[`WSIG+`EXTRASIG+1:0]	y;		// the smaller mantissa
input				op;		// desired operation (addition = 0; subtraction = 1)
output	[`EXTRASIG:0]		sum;		// the result after the desired operation is performed on mantissae
output				presticky;	// keeps track of or of discarded bits
output				guard;		// bit that will be shifted into mantissa if MSB cancels on sub
output				effop;		// will hold the effective operation to perform on mantissae

wire	[`WSIG+3:0]		yinput;		// the version of y put into the adder (either y or ~y)
wire				carry;		// the carry input to the adder

assign effop = sa ^ sb ^ op;			// this is the effective operation (add=0; sub=1)

assign presticky = |y[`WSIG:0];			// if any discarded bits 1, this is high
assign guard = y[`WSIG+1];			// guard bit is just beyond cutoff point

assign yinput = effop ? ~{1'b0, y[`WSIG+`EXTRASIG+1:`EXTRASIG]} :
	y[`WSIG+`EXTRASIG+1:`EXTRASIG];		// choose between y for addition or ~y for subtraction
assign carry = ~(presticky | guard) & effop;	// sometimes have to add one for 2's complement

assign sum = x + yinput + carry;		// computing sum (25 bit adder with additional carry in)

endmodule
