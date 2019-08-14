module add(x, y, out);

input wire [31:0] x, y;
output wire [31:0] out;
wire [4:0] flags;

fpadd add1( .a(x), .b(y), .result(out), .control(5'h00), .flags(flags) );

endmodule

module sub(x, y, out);

input wire [31:0] x, y;
output wire [31:0] out;
wire [4:0] flags;

fpadd sub1( .a(x), .b(y), .result(out), .control(5'h10), .flags(flags) );

endmodule

module mult(x, y, out);

input wire [31:0] x, y;
output wire [31:0] out;
wire [4:0] flags;

// Core 1 fp_mult = In-house multiplier, by Sirish Nandyala
//fp_mult mult1(.in1(x), .in2(y), .out(out), .mult_error(flags) );
// Core 2 fpmul = GPL open-source. Adapted from http://www.hmc.edu/chips/index.html, by Mark Phair
 fpmul mult1( .a(x), .b(y), .y(out), .control(5'h00), .flags(flags));
endmodule

module div(x, y, out);

input wire [31:0] x, y;
output wire [31:0] out;
wire [1:0] flags;

fp_div div1(.x(x), .y(y), .quotient(out), .div_error(flags) );

endmodule

module exp(x, out);

input wire [31:0] x;
output wire [31:0] out;
wire [4:0] flags;

exp_math exp1( .x(x), .exp_x(out));

endmodule

module fp_mult(out, mult_error, in1, in2);
	input	 wire [31:0]	in1, in2;
	output wire [31:0] 	out;
	output wire [1:0] 	mult_error;

	wire 			sign_out;
	wire [23:0] mant1;
	wire [23:0] mant2;
	wire signed [7:0]	exp1;
	wire signed [7:0]	exp2;
	wire [8:0] 	exp_out;
	wire [47:0] var;
	wire [15:0] shift;
	wire [22:0] mant_out;
	wire [47:0] prod;
	wire [8:0] err_test;
	wire [47:0] y;
	
	assign sign_out = in1[31] ^ in2[31];	//exclusive OR operation to determine sign of output
	//assign exponent and mantissa
	assign exp1 = in1[30:23];					
	assign exp2 = in2[30:23];
	assign mant1 = (exp1 == 8'b00) ? {1'b0, in1[22:0]} : {1'b1, in1[22:0]};
	assign mant2 = (exp2 == 8'b00) ? {1'b0, in2[22:0]} : {1'b1, in2[22:0]};
		
	fp_bitmult bitmult1(y, mant1, mant2);	
	assign prod = y;
	//assign prod = mant1 * mant2;
	
	//only three shift possibilities (0, 1 or 2)
	assign shift = prod[47] ? 8'h01 : (prod[46] ? 8'h02 : 8'h00);
	assign var = (prod <<< shift);		//dummy variable
	assign mant_out = var[47:25];			//take 23 most significant bits
	assign exp_out = {1'b0, exp1} + {1'b0, exp2} - {1'b0, shift} + 9'h02 - 9'h7f;  //add exponents, account for shift
	//- {1'b0, shift} + 9'h02 adjust exponent for the mantissa and the hidden 1
	// 9'h7f adjust for 127 bias in the exponent

	assign out = (mult_error == 2'b00) ? ((in1[30:0] == 31'h00000000 || in2[30:0] == 31'h00000000) ? 32'h00000000 : {sign_out, exp_out[7:0], mant_out}) : 0; // account for output of zero	

	assign err_test = {1'b0, exp1} + {1'b0, exp2} - {1'b0, shift} + 9'h02;	// check for exponent within limits

	//error code: 01-overflow, 10-underflow, 00-no error
	assign mult_error = (err_test > 9'h17d || (exp_out[7:0] == 8'hfe & prod > 48'h7fffff800000)) ? 2'b01 
								: ((err_test < 9'h80 && shift !=0) || (exp_out[7:0] == 8'h01 & prod < 48'h400000000000)) ? 2'b10 
								: 2'b00;

endmodule

module fp_bitmult(y,a,b);
output wire [47:0] y;
input wire [23:0] a, b;

wire [17:0] short_a, short_b;
wire [35:0] short_y;

assign short_a = a[23:6];
assign short_b = b[23:6];

assign short_y = short_a * short_b;

assign y = {short_y, 12'h000};

endmodule

/*
module fp_bitmult(y,a,b);
output [47:0] y;
input [23:0] a, b;

assign y = a * b;

endmodule
*/

/*
module fp_bitmult(y, a, b);
	output [47:0] y;
	input [23:0] a, b;
	
	assign y = 	((b[0] == 1)  ? a        : 48'h000000000000) +
					((b[1] == 1)  ? a <<< 1  : 48'h000000000000) +
					((b[2] == 1)  ? a <<< 2  : 48'h000000000000) +
					((b[3] == 1)  ? a <<< 3  : 48'h000000000000) +
					((b[4] == 1)  ? a <<< 4  : 48'h000000000000) +
					((b[5] == 1)  ? a <<< 5  : 48'h000000000000) +
					((b[6] == 1)  ? a <<< 6  : 48'h000000000000) +
					((b[7] == 1)  ? a <<< 7  : 48'h000000000000) +
					((b[8] == 1)  ? a <<< 8  : 48'h000000000000) +
					((b[9] == 1)  ? a <<< 9  : 48'h000000000000) +
					((b[10] == 1) ? a <<< 10 : 48'h000000000000) +
					((b[11] == 1) ? a <<< 11 : 48'h000000000000) +
					((b[12] == 1) ? a <<< 12 : 48'h000000000000) +
					((b[13] == 1) ? a <<< 13 : 48'h000000000000) +
					((b[14] == 1) ? a <<< 14 : 48'h000000000000) + 
					((b[15] == 1) ? a <<< 15 : 48'h000000000000) +
					((b[16] == 1) ? a <<< 16 : 48'h000000000000) +
					((b[17] == 1) ? a <<< 17 : 48'h000000000000) +
					((b[18] == 1) ? a <<< 18 : 48'h000000000000) +
					((b[19] == 1) ? a <<< 19 : 48'h000000000000) +
					((b[20] == 1) ? a <<< 20 : 48'h000000000000) + 
					((b[21] == 1) ? a <<< 21 : 48'h000000000000) + 
					((b[22] == 1) ? a <<< 22 : 48'h000000000000) + 
					((b[23] == 1) ? a <<< 23 : 48'h000000000000);
endmodule
*/

module exp_math( 
	output wire [31:0] exp_x,
	input wire [31:0] x
	);
	
	wire [31:0] k_n_r, y, exp_y, round_k_by_ln2, round_k_fp, round_k_int; 	//k not rounded
	wire [1:0] k_n_r_error, round_k_by_ln2_error;
	wire [4:0] y_flags;
	wire [31:0] log2e, ln2;

	assign ln2 = 32'h3F31_7217;
	assign log2e = 32'h3FB8_AA3B;   
	
	//fp_mult x_over_log2e(.out(k_n_r), .mult_error(k_n_r_error), .in1(x), .in2(log2e));
	mult	x_over_log2e(.x({1'b0, x[30:0]}), .y(log2e), .out(k_n_r));
	
	floor to_round_k(.in(k_n_r), .out(round_k_int));
	
	int_to_float to_round_k_fp(.in(round_k_int), .out(round_k_fp));
	
	//fp_mult to_round_k_by_ln2(	.out(round_k_by_ln2), .mult_error(round_k_by_ln2_error), 
	//									.in1(round_k_fp), .in2(ln2));
	mult	to_round_k_by_ln2(.x(round_k_fp), .y(ln2), .out(round_k_by_ln2));
	
	//fpadd	 gety(	.a(x), .b(round_k_by_ln2), .result(y), 
	//					.control(5'h1C), .flags(y_flags));
	sub	gety(.x({1'b0, x[30:0]}), .y(round_k_by_ln2), .out(y));
	
	taylor_exp to_exp_y (.exp_x(exp_y), .x(y));
	
	wire [31:0] raw_x, recip_raw_x, neg_exp_x;
	assign raw_x = {exp_y[31], exp_y[30:23] + round_k_int[7:0], exp_y[22:0]};
	rsqrt rinv_raw_x(.sqrt(recip_raw_x), .x(raw_x));
	mult get_exp_x(.x(recip_raw_x), .y(recip_raw_x), .out(neg_exp_x));
//	assign exp_x = k_n_r[31] ? {exp_y[31], exp_y[30:23] - round_k_int[7:0] , exp_y[22:0]}
//			: {exp_y[31], exp_y[30:23] + round_k_int[7:0], exp_y[22:0]};
	assign  exp_x = x[31]? neg_exp_x: raw_x;
	//assign  exp_x = x[31]? raw_x: raw_x;
endmodule

module floor(
	input wire [31:0] in, //float
	output wire [31:0] out //long int
	);
	
	wire [31:0] floor_a;
	wire [7:0] b;	//exp unbiased
	wire [31:0] a;	//mantissa with leading 1
	//wire flag;
	
	assign b = in[30:23]-8'd127;
	assign a = {9'b000000001, in[22:0]};
	
	//assign floor_a = a;
	shifter32 shift_a(.in(a), .op(2'b01), .s(5'd23-b[4:0]), .out(floor_a));
	//assign flag = b < 32'h0;
	
//	assign out = (in[30:23] < 8'd127) ? 32'h0 : floor_a;
	assign out = (in[30:23] < 8'd127) ? 32'h0 : 
						(in[31] ? {in[31], ~(floor_a[30:0] - 31'b1)} : floor_a);
	
endmodule

module int_to_float(
	output wire [31:0] out,
	input wire [31:0] in
);
wire [31:0] fp_shift;
wire [24:0] fp_mantissa;
wire [7:0] fp_exp;

assign fp_shift = in[24] ? 8'd1			
						: (in[23] ? 8'd2
						: (in[22] ? 8'd3
						: (in[21] ? 8'd4
						: (in[20] ? 8'd5
						: (in[19] ? 8'd6
						: (in[18] ? 8'd7
						: (in[17] ? 8'd8
						: (in[16] ? 8'd9
						: (in[15] ? 8'd10
						: (in[14] ? 8'd11
						: (in[13] ? 8'd12
						: (in[12] ? 8'd13
						: (in[11] ? 8'd14
						: (in[10] ? 8'd15
						: (in[9] ? 8'd16
						: (in[8] ? 8'd17
						: (in[7] ? 8'd18
						: (in[6] ? 8'd19
						: (in[5] ? 8'd20
						: (in[4] ? 8'd21
						: (in[3] ? 8'd22
						: (in[2] ? 8'd23
						: (in[1] ? 8'd24
						: (in[0] ? 8'd25
						: 8'd152)))))))))))))))))))))))); // this means the result is zero
	
	assign fp_exp = 9'd152-fp_shift;
	assign fp_mantissa = in[24:0] << fp_shift;
	assign out = {1'b0, fp_exp[7:0], fp_mantissa[24:2]};

endmodule



module taylor_exp(
	output wire [31:0] exp_x,
	input wire [31:0] x
);
	wire [4:0] x_flags;
	
	fpadd	 get_x_add_1(	.a(x), .b(32'h3F80_0000), .result(exp_x), 
								.control(5'h0C), .flags(x_flags)); 
endmodule


module fp_div(
	output wire [31:0] quotient,
	output wire [1:0] div_error,
	input wire [31:0] x,
	input wire [31:0] y
	);
	
	wire [31:0] y2, one_y;
	wire [1:0] y2_error;
		
	fp_mult multy2(.out(y2), .mult_error(y2_error), .in1(y), .in2(y));	//  Y^2
	rsqrt rsqrt1(.sqrt(one_y), .x(y2));					//  1/sqrt(Y^2)=1/Y
	
	fp_mult divide(.out(quotient), .mult_error(div_error), .in1(one_y), .in2(x));	//X*(1/Y) = X/Y
endmodule

module rsqrt(
    output wire [31:0] sqrt,
    input wire [31:0] x
    );

	wire [31:0] onehalf, threehalfs, magicnumber, y, x2;
	assign onehalf = 32'h3F00_0000;
	assign threehalfs = 32'h3FC0_0000;
//	assign magicnumber = 32'h5f37_59df; //quake3 magicnumber
	assign magicnumber = 32'h5f37_5a86; //chris lomont magicnumber (2000) Fast Inverse Square Root
	assign y = magicnumber - (x>>1);
	
	wire [1:0] xby2_error;
	fp_mult xby2(x2, xby2_error, x, onehalf);
	
	wire [31:0] y0, yy, x2yy;
	wire [1:0] sqrt_error, yy_error, x2yy_error;
	wire [4:0] sub_flags;
	
	fp_mult ytimesy(yy, yy_error, y, y);
	fp_mult x2timesyy(x2yy, x2yy_error, x2, yy);
	fpadd sub(threehalfs, x2yy, y0, 5'h10, sub_flags);
	fp_mult iterate(sqrt, sqrt_error, y, y0);
	
endmodule


module pow_25( 	output wire [31:0] out,
		input wire [31:0] x
		);

	wire [31:0] inv_sqrt;
	rsqrt rsqrt1(inv_sqrt,x);
	rsqrt rsqrt2(out, inv_sqrt);

endmodule
