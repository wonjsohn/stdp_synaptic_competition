//////////////////////////////////////////////
// 
// normalize.v
//
// Version 1.0
// Created 7/24/01 Mark_Phair@hmc.edu
// With code from David_Harris@hmc.edu and Mark_Phair@hmc.edu
//
// Normalizes if number is not denormalized
// 	and selects the proper exponent
//////////////////////////////////////////////

//////////////////////////////////////////////
// Includes
//////////////////////////////////////////////

`include "fm_constants.v" // global constants


//////////////////////////////////////////////
// normalize module
//////////////////////////////////////////////

module fm_normalize(prod, normalized, tiny, twoormore);

  // external signals
  input  [`PRODWIDTH-1:0]	prod;		// Product of multiplication
  output [`PRODWIDTH-1:0]	normalized;	// Normalized product
  input				tiny;		// Result is tiny (denormalized #)
  input				twoormore;	// Product overflowed range [1,2)

  // normalize product if appropriate
  //	There are three possible cases here:
  //	1) tiny and prod overfl. [1,2)	-> take the whole prod, including the leading 1
  //	2) tiny or prod overfl. [1,2)	-> dont take the first bit. its zero if its tiny,
  //				 		and it's the implied 1 if its not
  //	3) neither tiny nor prod overfl.-> dont take the first 2 bits, the 2nd one is the
  //						implied 1
  assign normalized = (tiny & twoormore) ? prod[`PRODWIDTH-1:0] :
			((tiny ^ twoormore) ? {prod[`PRODWIDTH-2:0],1'b0} :
			{prod[`PRODWIDTH-3:0],2'b0});

endmodule
