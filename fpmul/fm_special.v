//////////////////////////////////////////////
// 
// special.v
//
// Version 1.0
// Written 7/16/01 Mark_Phair@hmc.edu
//
// Determine the special case
//    deals with NaN, infinity and zero
//////////////////////////////////////////////

//////////////////////////////////////////////
// Includes
//////////////////////////////////////////////

`include "fm_constants.v"			//global constants


//////////////////////////////////////////////
// special module
//////////////////////////////////////////////

module fm_special (a, b, special, specialsign, 
		zero, aisnan, bisnan, infinity, 
		invalid, specialcase, specialsigncase);

  // external signals
  input	[`WIDTH-1:0] 	a, b;		// floating-point inputs
  output [`WIDTH-2:0]	special;	// special case output, exp + sig
  output		specialsign;	// the special-case sign
  input			zero;		// is there a zero?
  input			aisnan;		// NaN detected in A
  input			bisnan;		// NaN detected in B
  input			infinity;	// infinity detected
  output		invalid;	// invalid operation
  output		specialcase;	// this is a special case
  output		specialsigncase; // Use the special sign

  // internal signals
  wire			infandzero;	// infinity and zero detected
  wire	[`WIDTH-2:0]	highernan;	// holds inputed NaN, the higher if two are input,
					// and dont care if neither a nor b are NaNs
  wire			aishighernan;	// a is the higher NaN

  assign infandzero	= (infinity & zero);

  //#######SPECIAL ASSIGNMENT######
  // #######return higher NaN##########
  // Use this block if you want to return the higher of two NaNs

  assign aishighernan = (aisnan & ((a[`WSIG-1:0] >= b[`WSIG-1:0]) | ~bisnan));

  assign highernan[`WIDTH-2:0] = aishighernan ? a[`WIDTH-2:0] : b[`WIDTH-2:0];

  assign special[`WIDTH-2:0] = (aisnan | bisnan) ? (highernan[`WIDTH-2:0]) : 
			(zero ? 
			(infinity ? (`CONSTNAN) : (`CONSTZERO)) : (`CONSTINFINITY));
  // #######return first NaN##########
  // Use this block to return the first NaN encountered
//  assign special	= aisnan ? (a[`WIDTH-2:0]) : 
//			(bisnan ? (b[`WIDTH-2:0]) : 
//			(zero ? 
//			(infinity ? (`CONSTNAN) : (`CONSTZERO)) : (`CONSTINFINITY)));
  //######END SPECIAL ASSIGNMENT#######

  assign specialcase	= zero | aisnan | bisnan | infinity;

  assign invalid	= infandzero; //*** need to include something about signaling NaNs here

  // dont need to check if b is NaN, if it defaults to that point, and b isnt NAN
  // then it wont be used anyway
  assign specialsign	= infandzero ? (1'b1) : (aishighernan ? a[`WIDTH-1] : b[`WIDTH-1]);

  assign specialsigncase = infandzero | aisnan | bisnan;

endmodule
