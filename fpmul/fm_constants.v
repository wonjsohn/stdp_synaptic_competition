//////////////////////////////////////////////
// 
// constants.v
//
// Version 1.3
// Written 7/11/01 David_Harris@hmc.edu & Mark_Phair@hmc.edu
// Modifed 8/20/01 Mark_Phair@hmc.edu and Justin_Schauer@hmc.edu
//
// A set of constants for a parameterized floating point multiplier and adder.
//
//////////////////////////////////////////////

//////////////////////////////////////////////
// FREE VARIABLES
//////////////////////////////////////////////

// Widths of Fields
`define WEXP	8
`define WSIG	23
`define WFLAG	5
`define WCONTROL 5

// output flag select (flags[x])
`define DIVZERO 	0
`define INVALID 	1
`define INEXACT 	2
`define OVERFLOW 	3
`define UNDERFLOW	4

//////////////////////////////////////////////
// DEPENDENT VARIABLES
//////////////////////////////////////////////

`define WIDTH 		32 	//(`WEXP + `WSIG + 1)
`define PRODWIDTH	48 	//(2 * (`WSIG + 1))
`define SHIFTWIDTH	96 	//(2 * `PRODWIDTH))
`define WPRENORM	24	// `WSIG + 1
`define WEXPSUM		10	// `WEXP + 2
`define BIAS		127	// (2^(`WEXP)) - 1
`define WSIGMINUS1	22	// `WSIG - 1, used for rounding
`define WSHIFTAMT	5	// log2(`WSIG + 1) rounded up

// for trapped over/underflow
`define UNDERBIAS	192	// 3 * 2 ^ (`WEXP -2)
`define OVERBIAS	-192	// -`UNDERBIAS

// specialized constants for fpadd
`define	EXTRASIG	25		// `WSIG+2 this is the amount of precision needed so no
					// subtraction errors occur
`define	SHIFT		5		// # bits the max alignment shift will fit in (log2(`WSIG+2)
					// rounded up to nearest int)
`define	MAX_EXP		8'b11111110	// the maximum non-infinite exponent,
					// `WEXP bits, the most significant
					// `WEXP-1 bits are 1, the LSB is 0
`define	INF_EXP		8'b11111111	// Infinity exponent, `WEXP bits, all 1
// Max significand, `WSIG bits, all 1
`define	MAX_SIG		23'b11111111111111111111111
`define	WEXP_0		8'b0		// Exponent equals `WEXP'b0
`define	WEXP_1		8'b1		// Exponent equals one `WEXP'b1
`define	WSIG_0		23'b0		// Significand equals zero `WSIG'b0
`define	WSIG_1		23'b1		// Significand equals one `WSIG'b1
`define	EXTRASIG_0	25'b0		// All result bits for adder zero `EXTRASIG'b0

// specialized constants for fpmul
`define	MAXSHIFT	24		// `WSIG + 1

// GENERAL SPECIAL NUMBERS - Exp + Significand of special numbers
// plain NaN `WIDTH-1, all 1
`define CONSTNAN	{9'b1111_1111_1,22'b0}
// zero `WIDTH-1, all 0
`define CONSTZERO	31'b0
// infinity `WEXP all 1, `WSIG all 0
`define CONSTINFINITY	{8'b1111_1111, 23'b0}
// largest number maximum exponent(all 1's - 1) and maximum significand (all 1's)
`define CONSTLARGEST	{`MAX_EXP, `MAX_SIG}
`define PRESHIFTZEROS  48'b0 // `PRODWIDTH'b0