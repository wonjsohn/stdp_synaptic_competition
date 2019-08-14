/*
	Block Name:	fpalign.v
	Author:		Justin Schauer
	Date:		6/7/01
	
	Block Description:
	  This is an aligner for floating point addition.
	  It takes two single precision floating point numbers and spits out
	  two numbers: the large mantissa with a 1 in the MSB and the
	  smaller mantissa. Both mantissae also have assumed leading 1's
	  prepended, unless expa or expb is determined to be 0, in which case
	  no leading 1 is prepended.
*/

`include "constants.v"

module fpalign(a, b, x, y, biggerexp, abig);

input	[`WIDTH-2:0]		a;		// the 1st single precision FP input
input	[`WIDTH-2:0]		b;		// the 2nd FP input
output	[`WSIG+1:0]		x;		// the aligned mantissa of bigger
output	[`WSIG+`EXTRASIG+1:0]	y;		// the aligned mantissa of smaller
output	[`WEXP-1:0]		biggerexp;	// the bigger exponant
output				abig;		// high if expa bigger than expb

wire	[`WEXP-1:0]		expa;		// exponent of a
wire	[`WEXP-1:0]		expb;		// exponent of b
wire	[`WEXP-1:0]		smallerexp;	// the smaller of expa and expb
wire	[`WEXP-1:0]		shift;		// amount to shift smaller mantissa
wire				azero;		// is a or b 0 or denorm?
wire				bzero;
wire	[`SHIFT-1:0]		shiftamount;	// final amount to shift for alignment
wire				smallshift;	// high if shift is smaller than max necessary
wire	[`WSIG+1:0]		aval;		// mantissa of a
wire	[`WSIG+1:0]		bval;		// mantissa of b
wire	[2*`WSIG+4:0]		yprelim;	// y before alignment shift

assign azero = ~|a[`WIDTH-2:`WSIG];			// logic to see if expa or expb is 0
assign bzero = ~|b[`WIDTH-2:`WSIG];

// if expa or expb is 0, it is set to 1 for denorm handling
assign expa = azero ? `WEXP_1 : a[`WIDTH-2:`WSIG];	// put the exponent of a into expa
assign expb = bzero ? `WEXP_1 : b[`WIDTH-2:`WSIG];	// put exponent of b into expb

assign abig = (a[`WIDTH-2:0] > b[`WIDTH-2:0]);		// is expa bigger than expb
assign biggerexp = abig ? expa : expb;			// save whichever exponent is bigger
assign smallerexp = abig ? expb : expa;			// store smaller exponent

// to get shift amount, smaller subtracted from larger
assign shift = biggerexp - smallerexp;

// determines final amount to shift, never have to shift more than `EXTRASIG
assign smallshift = shift < (`EXTRASIG+1);
assign shiftamount = smallshift ? shift[`SHIFT-1:0] : `EXTRASIG;

assign aval = { ~azero, a[`WSIG-1:0], 1'b0};
assign bval = { ~bzero, b[`WSIG-1:0], 1'b0};

assign yprelim = { (abig ? bval : aval), `EXTRASIG_0};

// assigns smaller mantissa properly shifted. Doesn't prepend leading 1 if smaller is 0
assign y = yprelim >> shiftamount;

// assigns larger mantissa, so MSB is 1 unless larger is 0, in which case the leading 1
// is not prepended
assign x = abig ? aval : bval;

endmodule
