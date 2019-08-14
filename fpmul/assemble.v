//////////////////////////////////////////////
// 
// assemble.v
//
// Version 1.2
// Written 7/11/01 David_Harris@hmc.edu & Mark_Phair@hmc.edu
// Modifed 7/18/01 Mark_Phair@hmc.edu
//
// Assemble results of floating point multiplier and make
//   decision of special vs. rounded product vs. overflow
//
//////////////////////////////////////////////

//////////////////////////////////////////////
// Includes
//////////////////////////////////////////////

`include "fm_constants.v" // global constants


//////////////////////////////////////////////
// assemble module
//////////////////////////////////////////////
module assemble(roundprod, special, y, sign, specialsign, 
		shiftexp, specialcase, specialsigncase,
		roundmode, overflow);

  // external signals
  input	[`WSIG-1:0] 	roundprod;	// shifted, rounded and normalized 
					// 	product of mantissae
  input	[`WIDTH-2:0]	special;	// special case product + exponent
  output [`WIDTH-1:0] 	y;		// floating-point product
  input			sign;		// sign of product (+ = 0, - = 1)
  input			specialsign;	// special case sign
  input	[`WEXP-1:0] 	shiftexp;	// shifted exponent
  input			specialcase;	// this is a special case
  input			specialsigncase; // use the special case sign
  input	[1:0]		roundmode;	// rounding mode information extracted from control field  
  input			overflow;	// overflow detected
  
  // internal signals
  wire	[`WIDTH-2:0]	rounded;	// final product + exponent
  wire	[`WIDTH-2:0]	overflowvalue;	// product + exponent for overflow condition
  wire			undenormed;	// the result was denormalized before rounding, but rounding 
					//	caused it to become a small normalized number.

  // SET UP ROUNDED PRODUCT + EXPONENT
  
  // assign significand
  assign rounded[`WSIG-1:0]	= roundprod;

  // assign exponent
  assign rounded[`WIDTH-2:`WIDTH-`WEXP-1] = shiftexp;

  // SET UP OVERFLOW CONDITION
  assign overflowvalue[`WIDTH-2:0] = roundmode[1] ? 
				(sign ^ roundmode[0] ? `CONSTLARGEST : `CONSTINFINITY) :
				(roundmode[0] ? `CONSTLARGEST: `CONSTINFINITY);

  // FINAL PRODUCT ASSIGN 

  // assign sign
  assign y[`WIDTH-1]	= specialsigncase ? specialsign : sign;

  // assign product vs special vs overflowed
  assign y[`WIDTH-2:0]	= specialcase ? special[`WIDTH-2:0] :
				(overflow ? overflowvalue[`WIDTH-2:0] :
				rounded[`WIDTH-2:0]);

endmodule
