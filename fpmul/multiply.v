//////////////////////////////////////////////
// 
// multiply.v
//
// Version 1.3
// Modified 08/02/01 Mark_Phair@hmc.edu
// Written 7/11/01 Mark_Phair@hmc.edu
// With code borrowed from David_Harris@hmc.edu & Mark_Phair@hmc.edu
// Modified 7/18/01 Mark_Phair@hmc.edu
//
// The multiply portion of a parameterized floating point multiplier.
//
//////////////////////////////////////////////

//////////////////////////////////////////////
// Includes
//////////////////////////////////////////////

`include "fm_constants.v"			//global constants

//////////////////////////////////////////////
// multiply module
//////////////////////////////////////////////

module multiply (norma, normb, prod, twoormore);

  input	 [`WSIG:0]		norma, normb;	// normalized mantissae

  output [`PRODWIDTH-1:0] 	prod;		// product of mantissae
  output			twoormore;	// Product overflowed range [1,2)

  // multiplier array 
  //	(*** need a more effecient multiplier, 
  //	designware might work, though)
  assign prod		= norma * normb;

  // did the multiply overflow the range [1,2)?
  assign twoormore	= prod[`PRODWIDTH-1];

endmodule
