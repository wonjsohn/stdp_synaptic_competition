//////////////////////////////////////////////
// 
// shift.v
//
// Version 1.1
// Modified 08/27/01 Mark_Phair@hmc.edu
// Written 7/18/01 Mark_Phair@hmc.edu
// With code from David_Harris@hmc.edu & Mark_Phair@hmc.edu
//
// Shift results if needed
//
//////////////////////////////////////////////

//////////////////////////////////////////////
// Includes
//////////////////////////////////////////////

`include "fm_constants.v" // global constants


//////////////////////////////////////////////
// shift module
//////////////////////////////////////////////
module shift(normalized, selectedexp, shiftprod, shiftexp, shiftloss);

  // external signals
  input	[`PRODWIDTH-1:0] normalized;	// normalized product of mantissae
  input	[`WEXPSUM-1:0] 	selectedexp;	// sum of exponents
  output [`SHIFTWIDTH-1:0] shiftprod;	// shifted and normalized product
  output [`WEXPSUM-1:0]	shiftexp;	// shifted exponent
  output		shiftloss;	// loss of accuaracy due to shifting

  // internal signals
  wire	[`WEXPSUM-1:0]	roundedexp;		// selected exponent + 1 if rounding caused "overflow"
//  wire			negexp;		// exponent is negative
  wire	[`WEXPSUM-1:0]	shiftamt;		// theoretical amount to shift product by
  wire	[`WSHIFTAMT-1:0] actualshiftamt;	// actual amount to shift product by
  wire			tozero;		// need more shifts than possible with width of significand
  wire			doshift;	// only shift if value is nonnegative
  wire	[`SHIFTWIDTH-1:0] preshift; 	// value before shifting, with more room to ensure lossless shifting
  wire	[`SHIFTWIDTH-1:0] postshift;	// value after shifting, with more room to ensure lossless shifting

  // set up value for shifting
  assign preshift	= {normalized, `PRESHIFTZEROS};

  // determine shift amount
  assign shiftamt	=  -selectedexp;

  // make sure shift amount is nonnegative
  //	If the exponent is negative, the shift amount should
  //	come out positive, otherwise there shouldn't be any
  //	shifting to be done
  assign doshift	= ~shiftamt[`WEXPSUM-1];
  
  // Determine if the result must be shifted more than
  //	will show up in the significand, even if it rounds up
  assign tozero		= doshift & (shiftamt > `MAXSHIFT);

  // If the shift is big enough to shift all the bits out of the final significand,
  //	then it stops being relevent how much it has been shifted.
  assign actualshiftamt	= tozero ? `MAXSHIFT : shiftamt[`WSHIFTAMT-1:0];

  // shift significand
  assign postshift	= preshift >> actualshiftamt;

  // assign appropriate significand
  assign shiftprod	= doshift ? postshift :	preshift;

  // determine if any bits were "lost" from the shift
  //assign shiftloss	= tozero | (negexp & |postshift[`WSIG-1:0]); 
  assign shiftloss	= tozero | (doshift & |postshift[`SHIFTWIDTH-`PRODWIDTH-1:0]); 

  // assign appropriate exponent
  assign shiftexp	= doshift ? 0 : selectedexp;  

endmodule
