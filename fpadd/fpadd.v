/*
	Block Name:	fpadd.v
	Author:		Justin Schauer
	Date:		6/15/01
	
	Block Description:
	  the top level of a floating point adder. It uses the following sub-blocks:
	  
	  fpalign - aligns the mantissae of the inputs according to their exponents and prepends leading 1
	  special - generates signals for special inputs (infinity, NaN, signaling NaN)
	  mantadd - adds (subtracts) the aligned mantissae, determines presticky bit (or of discarded mantissa)
	  normlize - finds the leading one and shifts it to the front producing a normalized sum. Determines
	  	if result is denormal and does proper denorm shifting. Also calulates round, and sticky bits
	  	as well as whether the sum is 0 or inexact.
	  rounder - rounds normalized mantissa according to selected rounding mode and calculates the final
	  	exponent.
	  final - this assembles all the pieces and uses special case information to determine correct final
	  	result. Also determines all exception flags.
*/

`include "constants.v"

module fpadd(a, b, result, control, flags);

input	[`WIDTH-1:0]		a;		// the 1st single-precision FP operand
input	[`WIDTH-1:0]		b;		// the 2nd FP operand
input	[`WCONTROL-1:0]		control;	// control field has traps, op, rounding mode, etc.
output	[`WIDTH-1:0]		result;		// the final, correctly rounded sum of the 2 operands
output	[`WFLAG-1:0]		flags;		// flag field outputs exception flags

wire	[1:0]			roundmode;	// rounding mode
wire				undertrap;	// trapped underflow
wire				overtrap;	// trapped overflow
wire				op;		// operation, 0 = add; 1 = sub
wire	[`WSIG+1:0]		x;		// aligned mantissa of larger operand
wire	[`WSIG+`EXTRASIG+1:0]	y;		// aligned mantissa of smaller operand
wire				ainf;		// a is infinity flag
wire				binf;		// b is infinity
wire				anan;		// a in NaN (Not a Number)
wire				bnan;		// b is NaN
wire				specinput;	// input was nan or infinity
wire				asignan, bsignan; // a/b signaling NaN
wire	[`WEXP-1:0]		biggerexp;	// the value of the larger exponent
wire				abig;		// high if expa > expb
wire	[`EXTRASIG:0]		sum;		// the un-normalized sum after mantissa addition
wire	[`WSIG-1:0]		normsum;	// the normalized sum
wire	[`SHIFT-1:0]		normalshift;	// the amount the un-normalized sum was shifted to get normalized sum
wire				presticky;	// or of all bits discarded during mantissa addition
wire				guard;		// guard bit
wire				effop;		// the effective operation (operation to be performed on mantissae)
wire				inex;		// inexact after rounding
wire	[`WEXP:0]		overexp;	// exponent with shifts and biases
wire				round;		// round bit
wire				sticky;		// sticky bit
wire				zero;		// high if final result is 0
wire				denorm;		// high if result is denormalized
wire				finalsign;	// final sign of FP result
wire	[`WSIG-1:0]		roundsum;	// the final sum rounded and without leading one
wire				roundshift;	// the total amount the sum has been shifted including post-normalization
wire				rm;		// round mode (round minus inf, round to 0, round plus inf, round to nearest)
wire				rz;
wire				rp;
wire				rn;
wire	[`WEXP:0]		exp;		// somewhat final exponent
wire				invalid, inexact, overflow, underflow;	// exception flags
wire    [`WIDTH-1:0]    result_unchk;

// breaking up the control field into usable components
assign roundmode = control[1:0];
assign undertrap = control[2];
assign overtrap = control[3];
assign op = control[4];

fpalign		fpalign(a[`WIDTH-2:0], b[`WIDTH-2:0], x, y, biggerexp, abig);

mantadd		mantadd(a[`WIDTH-1], b[`WIDTH-1], x, y, op, sum, presticky, guard, effop);

normlize	normlize(sum, biggerexp, presticky, guard, effop, undertrap, normsum,
			normalshift, round, sticky, zero, denorm, inex, overexp);
			
rounder		rounder(normsum, round, sticky, roundmode,
			finalsign, overexp[`WEXP-1:0], roundsum, roundshift, rm, rz, rp, rn, exp);
						
special		special(a[`WIDTH-2:0], b[`WIDTH-2:0], ainf, binf, anan, bnan, asignan, bsignan, specinput);

final		final(a[`WSIG-2:0], b[`WSIG-2:0], a[`WIDTH-1], b[`WIDTH-1], abig, ainf, binf, anan, bnan, asignan, bsignan,
			specinput, denorm, inex, overtrap, undertrap, overexp[`WEXP], exp[`WEXP:0], effop, op, zero,
			roundsum, rp, rm, rz, result_unchk, overflow, underflow, invalid, inexact);

// assembling exception flags into exception field
assign flags[`DIVZERO] = 0;
assign flags[`INVALID] = invalid;
assign flags[`INEXACT] = inexact;
assign flags[`OVERFLOW] = overflow;
assign flags[`UNDERFLOW] = underflow;

//assign result = (flags == 5'h00) ? result_unchk : 32'h0000_0000; 
assign result = result_unchk;
endmodule
