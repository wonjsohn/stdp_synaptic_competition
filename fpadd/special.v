/*
	Block Name:	special.v
	Author:		Justin Schauer
	Date:		6/18/01
	
	Block Description:
	  This is part of a FP adder (although perhaps it could be used elsewhere) which
	  sets special flags for FP inputs: infinity, NaN, signaling NaN.
*/

`include "constants.v"

module special(a, b, ainf, binf, anan, bnan, asignan, bsignan, specinput);

input	[`WIDTH-2:0]		a;			// 1st operand
input	[`WIDTH-2:0]		b;			// 2nd operand
output				ainf;			// a is infinity
output				binf;			// b is infinity
output				anan;			// a is not a number
output				bnan;			// b is NaN
output				asignan, bsignan;	// a or b is signaling NaN
output				specinput;		// a or b is NaN or infinite

wire				aexpones;		// a exp all ones
wire				bexpones;		// b exp all ones
wire				asignon0;		// a sig is non-zero
wire				bsignon0;		// b sig is non-zero

assign aexpones = &a[`WIDTH-2:`WSIG];
assign bexpones = &b[`WIDTH-2:`WSIG];
assign asignon0 = |a[`WSIG-1:0];
assign bsignon0 = |b[`WSIG-1:0];

// if the exponent is all 1's and the significand is all 0's, the number is inf
assign ainf = aexpones & ~asignon0;
assign binf = bexpones & ~bsignon0;

// if exp all 1's and sig is not all 0's, the number is NaN
assign anan = aexpones & ~ainf;
assign bnan = bexpones & ~binf;
// if nuumber is NaN and the MSB of the significand is 0, it's a signaling NaN
assign asignan = anan & ~a[`WSIG-1];
assign bsignan = bnan & ~b[`WSIG-1];

assign specinput = ainf | binf | anan | bnan;

endmodule
