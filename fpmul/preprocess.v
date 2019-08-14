//////////////////////////////////////////////
// 
// preprocess.v
//
// Version 1.2
// Written 7/16/01 Mark_Phair@hmc.edu
// With code borrowed from David_Harris@hmc.edu & Mark_Phair@hmc.edu
// Modified 7/18/01 Mark_Phair@hmc.edu
//
// The preprocessing for a parameterized floating point multiplier.
//
//////////////////////////////////////////////

//////////////////////////////////////////////
// Includes
//////////////////////////////////////////////

`include "fm_constants.v"			//global constants

//////////////////////////////////////////////
// preprocess module
//////////////////////////////////////////////

module preprocess(a, b, zero, aisnan, bisnan, aisdenorm, bisdenorm, infinity, control, roundmode, sign);

  // external signals
  input	[`WIDTH-1:0] 	a, b;		// floating-point inputs
  output 		zero;		// is there a zero?
  input	[`WCONTROL-1:0]	control;	// control field
  output [1:0]		roundmode;	// 00 = RN; 01 = RZ; 10 = RP; 11 = RM 
  output		aisnan;		// NaN detected in A
  output		bisnan;		// NaN detected in B
  output		aisdenorm;	// denormalized number detected in A
  output		bisdenorm;	// denormalized number detected in B
  output		infinity;	// infinity detected in A
  output		sign;		// sign of product

  // internal signals
  wire			signa, signb;	// sign of a and b
  wire [`WEXP-1:0]	expa, expb;	// the exponents of a and b
  wire [`WSIG-1:0]	siga, sigb;	// the significands of a and b
  wire			aexpfull;	// the exponent of a is all 1's
  wire			bexpfull;	// the exponent of b is all 1's
  wire			aexpzero;	// the exponent of a is all 0's
  wire			bexpzero;	// the exponent of b is all 0's
  wire			asigzero;	// the significand of a is all 0's
  wire			bsigzero;	// the significand of b is all 0's

  // Sign calculation
  assign signa 		= a[`WIDTH-1];
  assign signb 		= b[`WIDTH-1];
  assign sign = signa ^ signb;

  // Significand calcuations

  assign siga		= a[`WSIG-1:0];
  assign sigb		= b[`WSIG-1:0];
  // Are the significands all 0's?
  assign asigzero	= ~|siga;
  assign bsigzero	= ~|sigb;

  // Exponent calculations

  assign expa		= a[`WIDTH-2:`WIDTH-`WEXP-1];
  assign expb		= b[`WIDTH-2:`WIDTH-`WEXP-1];
  // Are the exponents all 0's?
  assign aexpzero	= ~|expa;
  assign bexpzero	= ~|expb;
  // Are the exponents all 1's?
  assign aexpfull	= &expa;
  assign bexpfull	= &expb;

  // General calculations

  // Zero Detect
  assign zero 		= (aexpzero & asigzero) | (bexpzero & bsigzero);

  // NaN detect
  assign aisnan		= aexpfull & ~asigzero;
  assign bisnan		= bexpfull & ~bsigzero;

  // Infinity detect
  assign infinity	= (aexpfull & asigzero) | (bexpfull & bsigzero);

  // Denorm detect
  assign aisdenorm	= aexpzero & ~asigzero;
  assign bisdenorm	= bexpzero & ~bsigzero;

  // Round mode extraction
  assign roundmode	= control[1:0];

endmodule
