
module unsigned_mult32 (out, a, b);
	output 	[31:0]	out;
	input 	[31:0] 	a;
	input 	[31:0] 	b;
    	wire    [63:0]   temp_out; 

	assign temp_out = a * b;
	assign out = temp_out[31:0];	
endmodule
