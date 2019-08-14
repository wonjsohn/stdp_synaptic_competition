//////////////////////////////////////////////
// 
// flag.v
//
// Version 1.1
// Written 7/11/01 David_Harris@hmc.edu & Mark_Phair@hmc.edu
// Modifed 7/18/01 Mark_Phair@hmc.edu
//
// Compiles flag information
//
//////////////////////////////////////////////

//////////////////////////////////////////////
// Includes
//////////////////////////////////////////////

`include "fm_constants.v"			//global constants


//////////////////////////////////////////////
// flag module
//////////////////////////////////////////////


module flag (invalid, overflow, inexact, underflow, tiny, specialcase, flags);

  input			invalid;	// invalid operation
  input			overflow;	// the result was too large
  input			inexact;	// The result was rounded
  input			specialcase;	// Using special result, shouldn't throw flags
  input			underflow;	// Underflow detected
  input			tiny;		// The result is tiny

  output [`WFLAG-1:0]	flags;		// DIVZERO, INVALID, INEXACT, 
					// OVERFLOW, UNDERFLOW (defined in constant.v)

  // flags
  assign flags[`DIVZERO]	= 1'b0;
  assign flags[`INVALID]	= invalid;
  assign flags[`INEXACT]	= ~specialcase & (inexact | underflow | overflow);
  assign flags[`OVERFLOW]	= ~specialcase & overflow;
  assign flags[`UNDERFLOW]	= ~specialcase & tiny & underflow & ~overflow;

endmodule
