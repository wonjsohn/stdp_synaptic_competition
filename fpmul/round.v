//////////////////////////////////////////////
// 
// round.v
//
// Version 1.1
// Created 7/16/01 Mark_Phair@hmc.edu
// With code from David_Harris@hmc.edu and Mark_Phair@hmc.edu
// Modifed 08/20/01 Mark_Phair@hmc.edu
//
// Rounding decisions and operations.
//
//////////////////////////////////////////////

//////////////////////////////////////////////
// Includes
//////////////////////////////////////////////

`include "fm_constants.v" // global constants


//////////////////////////////////////////////
// round module
//////////////////////////////////////////////

module round(shiftprod, shiftexp, shiftloss, roundprod, roundexp, roundmode, 
		sign, tiny, inexact, overflow, stilltiny, denormround);

  // external signals
  input	[`SHIFTWIDTH-1:0] shiftprod;	// normalized and shifted product of mantissae
  input [`WEXPSUM-1:0]	shiftexp;	// shifted exponent
  input			shiftloss;	// bits were lost in the shifting process
  output [`WSIG-1:0] 	roundprod;	// rounded floating-point product
  output [`WEXP-1:0] 	roundexp;	// rounded exponent
  input  [1:0] 		roundmode;	// 00 = RN; 01 = RZ; 10 = RP; 11 = RM
  input			sign;		// sign bit for rounding mode direction
  input			tiny;		// denormalized number after rounding
  output		inexact;	// rounding occured
  output		overflow;	// overflow occured
  output		stilltiny;	// Result is tiny (denormalized #) after rounding
  output		denormround;	// result was rounded only because it was a denormalized number

  // internal signals
  wire			roundzero;	// rounding towards zero
  wire			roundinf;	// rounding towards infinity
  wire 			stickybit;	// there one or more 1 bits in the LS bits
  wire			denormsticky;	// sticky bit if this weren't a denorm
  wire [`WSIG-1:0] 	MSBits;		// most significant bits
  wire [`WSIG:0] 	MSBitsplus1; 	// most significant bits plus 1
					//	for rounding purposes. needs to be one
					//	bit bigger for overflow
  wire [1:0]		roundbits;	// bits used to compute rounding decision
  wire 			rounddecision;	// round up
  wire			roundoverflow;	// rounding overflow occured
  wire [`WEXPSUM-1:0]	tempexp;	// exponent after rounding

  //reduce round mode to three modes
  //	dont need round nearest, it is implied
  //	by roundzero and roundinf being false
  //assign roundnearest 	= ~&roundmode;
//  assign roundzero	= &roundmode || (^roundmode && (roundmode[0] || sign));
  assign roundzero	= (~roundmode[1] & roundmode[0]) | (roundmode[1] & (roundmode[0] ^ sign));
  assign roundinf	= roundmode[1] & ~(sign ^ roundmode[0]);

  // pull out the most significant bits for the product
  assign MSBits = shiftprod[`SHIFTWIDTH-1:`SHIFTWIDTH-`WSIG];

  // add a 1 to the end of MSBits for round up
  assign MSBitsplus1 = MSBits + 1;

  // pull out the last of the most significant bits 
  //	and the first of the least significant bits
  //	to use for calculating the rounding decision
  assign roundbits[1:0]	= shiftprod[`SHIFTWIDTH-`WSIG:`SHIFTWIDTH-`WSIG-1];

  // calculate the sticky bit. Are any of the least significant bits 1?
  //	also: was anything lost while shifting?
  // *** Optimization: some of these bits are already checked from the shiftloss ***
  // *** Optimization: stickybit can be calculated from denormsticky 
  //			with only 1 more gate, instead of duplication of effort ***
  assign stickybit 	= |shiftprod[`SHIFTWIDTH-`WSIG-2:0] | shiftloss;
  assign denormsticky 	= |shiftprod[`SHIFTWIDTH-`WSIG-3:0] | shiftloss;

  // Compute rounding decision
  assign rounddecision	= ~roundzero & 	( (roundbits[0]	& (roundinf | roundbits[1]))
					| (stickybit	& (roundinf | roundbits[0]))
					);

  // Was this only rounded because it is a denorm?
  assign denormround	= tiny & rounddecision & ~denormsticky & roundbits[0];

  // detect rounding "overflow." it only overflows if:
  // 1) the top bit of MSBitsplus1 is 1
  // 2) it decides to round up
  assign roundoverflow	= MSBitsplus1[`WSIG] & rounddecision;

  // assign significand (and postnormalize)
  //  rounddecision decides whether to use msbits+1 or msbits.
  //  if using msbits+1 and there is an rounding overflow (i.e. result=2),
  //  then should return 1 instead
  assign roundprod = rounddecision ? 
 			(roundoverflow ? 0 : 
			MSBitsplus1[`WSIG-1:0]) :
			MSBits;

  // detect inexact
  assign inexact	= rounddecision | stickybit | roundbits[0];

  // compensate for a rounding overflow
  assign tempexp 	= roundoverflow + shiftexp;

  // check for overflow in exponent
  //	overflow occured if the number
  //	is too large to be represented,
  //	i.e. can't fit in `WEXP bits, or
  //	all `WEXP bits are 1's
  assign overflow	= &tempexp[`WEXP-1:0] | |tempexp[`WEXPSUM-1:`WEXP];

  // two possible cases:
  //	1) Overflow: then exponent doesnt matter,
  //	it will be changed to infinity anyway
  //	2) not overflow: the leading bits will be 0
  assign roundexp	= tempexp[`WEXP-1:0];

  // The result is tiny if the exponent is less than 1.
  //	Because the exponent sum is NOT in 2's-complement form,
  //	it is only less than one if its is zero, i.e.
  //    all the bits are 0
  assign stilltiny	= ~|roundexp;

endmodule
