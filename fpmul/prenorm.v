//////////////////////////////////////////////
// 
// prenorm.v
//
// Version 1.1
// Written 08/02/01 Mark_Phair@hmc.edu
// With some code from David_Harris@hmc.edu & Mark_Phair@hmc.edu
//
// Normalizes inputs and readies them for multiplication
//
//////////////////////////////////////////////

//////////////////////////////////////////////
// Includes
//////////////////////////////////////////////

`include "fm_constants.v"				//global constants 


//////////////////////////////////////////////
// prenorm module
//////////////////////////////////////////////

module prenorm(a, b, norma, normb, modexpa, modexpb, aisdenorm, bisdenorm);

  input	[`WIDTH-1:0]	a, b;			// the input floating point numbers
  output [`WSIG:0]	norma, normb;		// the mantissae in normal form
  output [`WEXPSUM-1:0]	modexpa, modexpb;	// the output exponents, larger to accomodate
						//	two's complement form
  input			aisdenorm;		// a is a denormalized number
  input			bisdenorm;		// b is a denormalized nubmer

  // internal signals
  wire	[`WEXPSUM-1:0]	expa, expb;		// exponents in two's complement form
						//	are negative if shifted for a
						// 	denormalized number
  wire	[`SHIFT-1:0]	shifta, shiftb; 	// the shift amounts
  wire [`WSIG:0]	shifteda, shiftedb;	// the shifted significands

  // pull out the exponents
  assign expa 	= a[`WIDTH-2:`WIDTH-1-`WEXP];
  assign expb 	= b[`WIDTH-2:`WIDTH-1-`WEXP];

  // when breaking appart for paramaterizing:
  // ### RUN ./prenormshift.pl wsig_in ###
  `include "prenormshift.v"


  // If number is a denorm, the exponent must be 
  //	decremented by the shift amount
  assign modexpa = aisdenorm ? 1 - shifta : expa; 
  assign modexpb = bisdenorm ? 1 - shiftb : expb; 

  // If number is denorm, shift the significand the appropriate amount
  assign shifteda = a[`WSIG-1:0] << shifta;
  assign norma 	= aisdenorm ? shifteda : {1'b1, a[`WSIG-1:0]};

  assign shiftedb = b[`WSIG-1:0] << shiftb;
  assign normb 	= bisdenorm ? shiftedb : {1'b1, b[`WSIG-1:0]};

endmodule
