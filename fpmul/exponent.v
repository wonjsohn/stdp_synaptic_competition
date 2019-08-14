//////////////////////////////////////////////
// 
// exponent.v
//
// Version 1.2
// Modifed 08/02/01 Mark_Phair@hmc.edu
// Written 07/11/01 David_Harris@hmc.edu & Mark_Phair@hmc.edu
//
// Calculates the exponent
//
//////////////////////////////////////////////

//////////////////////////////////////////////
// Includes
//////////////////////////////////////////////

`include "fm_constants.v"				//global constants 


//////////////////////////////////////////////
// exponentsum module
//////////////////////////////////////////////

module exponent(expa, expb, expsum, twoormore, tiny);

  input	[`WEXPSUM-1:0]	expa, expb;	// the input exponents in 2's complement form
					//	to accomodate denorms that have been
					//	prenormalized
  input			twoormore;	// product is outside range [1,2)

  output [`WEXPSUM-1:0]	expsum;		// the sum of the exponents
  output		tiny;		// Result is tiny (denormalized #)

  // Sum the exponents, subtract the bias
  // 	and add 1 (twoormore) if multiply went out of [1,2) range
  assign expsum = expa + expb - `BIAS + twoormore;

  // The result is tiny if the exponent is less than 1.
  //	Because the exponent sum is in 2's-complement form,
  //	it is negative if the first bit is 1, and zero if
  //    all the bits are zero
  assign tiny	= ~|expsum[`WEXPSUM-2:0] | expsum[`WEXPSUM-1];


endmodule
