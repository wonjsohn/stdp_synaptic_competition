/*
	Block Name:	final.v
	Author:		Justin Schauer
	Date:		6/21/01
	
	Block Description:
	  The final step in this FP adder. It takes the calculated significand, exponent
	  and sign, and using a multitude of flags such as infinities and overflows determines
	  special cases and finally puts together the end floating point result. It also
	  determines all the applicable exceptions: overflow, underflow, invalid, and inexact.
*/

`include "constants.v"

module final(a, b, sa, sb, abig, ainf, binf, anan, bnan, asignan, bsignan, specinput, denorm,
	inex, overtrap, undertrap, expneg, exp, effop, op, zero, roundsum,
	rp, rm, rz, result, overflow, underflow, invalid, inexact);

input	[`WSIG-2:0]		a;				// operand a
input	[`WSIG-2:0]		b;				// operand b
input				sa;				// sign of a
input				sb;				// sign if b
input				abig;				// a > b ?
input				ainf;				// high if a infinite
input				binf;				// high if b infinite
input				anan;				// high if a is not a number
input				bnan;				// high if b is NaN
input				asignan, bsignan;		// is a or b a signaling NaN
input				specinput;			// a or b is NaN or infinity
input				denorm;				// result is denormal
input				inex;				// there were round or sticky bits
input				overtrap;			// overflow trap implemented
input				undertrap;			// underflow trap implemented
input				expneg;				// normalshift > biggerexp
input	[`WEXP:0]		exp;				// calculated final exponent
input				effop;				// effective operation
input				op;				// 0 = add; 1 = sub
input				zero;				// result is 0
input	[`WSIG-1:0]		roundsum;			// the calculated final significand
input				rp, rm, rz;			// rounding mode flags
output	[`WIDTH-1:0]		result;				// resulting FP number
output				overflow;			// result overflow flag
output				underflow;			// result underflow flag
output				invalid;			// high if result invalid
output				inexact;			// result inexact flag

wire	[`WEXP-1:0]		biasexp;			// exponent with over/underflow bias
wire				preover;			// pre-overflow calculation
wire	[`WEXP-1:0]		finalexp;			// the truly final exponent
wire	[`WSIG-1:0]		finalmant;			// the truly final significand
wire				finalsign;			// the final sign of the result
// these wires are all just mux results
wire	[`WEXP-1:0]		specialexp;
wire	[`WSIG-1:0]		mantover;
wire	[`WSIG-1:0]		mantanan;
wire	[`WSIG-1:0]		nantests;
wire				signmux;

assign biasexp = exp[`WEXP-1:0] + ((overflow & overtrap) ? `OVERBIAS : `UNDERBIAS);

// logic to see if there is overflow. Takes into account whether there was post-normalization shift
assign preover = exp[`WEXP] | &exp[`WEXP-1:0];

// makes sure overflow isn't conflicting other situations
assign overflow = preover & ~expneg & ~specinput & ~zero;

// underflow detect logic. An underflow will result when there is a 0 sum or the
// normalization shift is bigger than the larger exponent with this adder
assign underflow = (expneg & inex) | (undertrap & expneg);

// if effective operation is inf - inf, or one of the operands is a signlaing NaN, result is invalid
assign invalid = (ainf & binf & effop) | asignan | bsignan;

// inexact flag is set for inexact rounding or untrapped overflow
assign inexact = (inex | (overflow & ~overtrap)) & ~specinput;

// this is the formula to calculate the final sign
// basically, there are a lot of special cases for the rounding modes that have to be taken
// into account. See IEEE-754 specification sections 4.1, 4.2, and 6.3 for these special cases.
assign signmux = zero ? (sa & sb & ~op) : (abig & sa) | ( (sb ^ op) & (~abig | sa) );
assign finalsign = (zero & rm & (sa ^ sb)) | signmux;

// logic to determine final exponent. If there is underflow in certain modes the result
// is supposed to be 0 or -inf. If there is overflow in certain modes, the result is supposed
// to be 7f7fffff or +inf. Otherwise, the exponent is just whatever was calculated
assign specialexp = ((underflow | zero | denorm) & ~invalid) ? `WEXP_0 :
	((rp & overflow & finalsign) | (rz & overflow) | (rm & overflow & ~finalsign)) ? `MAX_EXP : `INF_EXP;
assign finalexp = ((overflow & overtrap) | ((underflow | denorm) & undertrap)) ? biasexp :
	(specinput | overflow | underflow | zero | denorm) ? specialexp : exp[`WEXP-1:0];

// logic to determine final mantissa. The same rounding mode complexities apply here
// as above in the exponent calculation, except the significand for infinity happens to be
// the same as the significand for 0, so these cases are combined.
assign mantover = ((rp & overflow & finalsign) | (rz & overflow) | (rm & overflow & ~finalsign)) ? `MAX_SIG : `WSIG_0;
assign mantanan = {1'b1, (anan ? a[`WSIG-2:0] : b[`WSIG-2:0]) };
assign nantests = (anan | bnan | invalid) ? mantanan : mantover;
assign finalmant = (specinput | overflow | underflow | invalid) ? nantests : roundsum;

assign result = {finalsign, finalexp, finalmant};		// putting the pieces together

endmodule
