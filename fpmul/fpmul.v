//////////////////////////////////////////////
// 
// fpmul.v
//
// Version 1.6
// Written 07/11/01 David_Harris@hmc.edu & Mark_Phair@hmc.edu
// Modifed 08/20/01 Mark_Phair@hmc.edu
//
// A parameterized floating point multiplier.
//
// BLOCK DESCRIPTIONS
//
// preprocess 	- general processing, such as zero detection, computing sign, NaN
//
// prenorm	- normalize denorms
//
// exponent	- sum the exponents, check for tininess before rounding
//
// multiply	- multiply the mantissae
//
// special	- calculate special cases, such as NaN and infinities
//
// shift	- shift the sig and exp if nesc.
//
// round	- round product
//
// normalize	- normalizes the result if appropriate (i.e. not a denormalized #)
//
// flag 	- general flag processing
//
// assemble	- assemble results
//
//////////////////////////////////////////////

//////////////////////////////////////////////
// Includes
//////////////////////////////////////////////

`include "fm_constants.v"			 // global constants


//////////////////////////////////////////////
// fpmul module
//////////////////////////////////////////////

module fpmul(a, b, y, control, flags) ;

  // external signals
  input	 [`WIDTH-1:0] 	a, b;		// floating-point inputs
  output [`WIDTH-1:0] 	y;		// floating-point product
  input  [`WCONTROL-1:0] control;	// control including rounding mode
  output [`WFLAG-1:0]	flags;		// DIVZERO, INVALID, INEXACT, 
					// OVERFLOW, UNDERFLOW (defined in constant.v)

  // internal signals
  wire			multsign;	// sign of product
  wire			specialsign;	// sign of special

  wire  [`WSIG:0] 	norma;		// normal-form mantissa a, 1 bit larger to hold leading 1
  wire  [`WSIG:0] 	normb;		// normal-form mantissa b, 1 bit larger to hold leading 1

  wire	[`WEXPSUM-1:0]	expa, expb;	// the two exponents, after prenormalization
  wire	[`WEXPSUM-1:0] 	expsum;		// sum of exponents (two's complement)
  wire	[`WEXPSUM-1:0] 	shiftexp;	// shifted exponent
  wire	[`WEXP-1:0] 	roundexp;	// rounded, correct exponent

  wire	[`PRODWIDTH-1:0] prod;		// product of mantissae
  wire	[`PRODWIDTH-1:0] normalized;	// Normalized product
  wire	[`SHIFTWIDTH-1:0] shiftprod;	// shifted product
  wire	[`WSIG-1:0]	roundprod;	// rounded product
  wire	[`WIDTH-2:0]	special;	// special case exponent and product

  wire			twoormore;	// product is outside range [1,2)
  wire			zero;		// zero detected
  wire			infinity;	// infinity detected
  wire			aisnan;		// NaN detected in A
  wire			bisnan;		// NaN detected in B
  wire			aisdenorm;	// Denormalized number detected in A
  wire			bisdenorm;	// Denormalized number detected in B
  wire			specialcase;	// This is a special case
  wire			specialsigncase; // Use the special case sign
  wire			roundoverflow;	// "overflow" in rounding, need to add 1 to exponent
  wire			invalid;	// invalid operation
  wire			overflow;	// exponent result too high, standard overflow
  wire			inexact;	// inexact flag
  wire			shiftloss;	// lost digits due to a shift, result inaccurate
  wire	[1:0]		roundmode;	// rounding mode information extracted from control field  
  wire			tiny;		// Result is tiny (denormalized #) after multiplication
  wire			stilltiny;	// Result is tiny (denormalized #) after rounding
  wire			denormround;	// rounding occured only because the initial result was
					//	a denormalized number. This is used to determine
					//	underflow in cases of denormalized numbers rounding
					//	up to normalized numbers

  preprocess	preprocesser(a, b, zero, aisnan, bisnan, 
				aisdenorm, bisdenorm, infinity, 
				control, roundmode, sign);  

  fm_special	specialer(a, b, special, specialsign, zero, 
				aisnan, bisnan, 
				infinity, invalid, 
				specialcase, specialsigncase);
  
  prenorm	prenormer(a, b, norma, normb, expa, expb, aisdenorm, bisdenorm);

  multiply	multiplier(norma, normb, prod, twoormore);

  exponent	exponenter(expa, expb, expsum, twoormore, tiny);

  fm_normalize	normalizer(prod, normalized, tiny, twoormore);  

  shift		shifter(normalized, expsum, shiftprod, 
			shiftexp, shiftloss);

  round		rounder(shiftprod, shiftexp, shiftloss,
			roundprod, roundexp, 
			roundmode, sign, tiny, inexact, 
			overflow, stilltiny, denormround);

		// *** To check for tininess before rounding, use tiny
		//	To check after rounding, use stilltiny
		// *** for underflow detect:
		//	To check for inexact result use (inexact | (shiftloss & stilltiny)), 
		//	To check for denormilization loss use (shiftloss & stilltiny)
  flag		flager(invalid, overflow, inexact | shiftloss, 
			shiftloss | inexact,
			/* tiny */ (stilltiny | (tiny & denormround)), 
			specialcase, flags);

  assemble	assembler(roundprod, special, y, 
			sign, specialsign, roundexp, 
			specialcase, specialsigncase,
			roundmode, flags[`OVERFLOW]);

endmodule 
