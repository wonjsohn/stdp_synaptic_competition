module integrator
(
		input wire [31:0] x,
        input wire [31:0] int_x,
        input wire reset,
		output wire [31:0] out // out = x*dt + int_x
);
	
    wire [31:0] int_x_F0;

	wire [4:0] int_adder_flags;
	wire [1:0] int_adder_error;
	wire [31:0] x_by_dt;
	wire [7:0] x_by_dt_exp;
	wire [22:0] x_by_dt_man;
	//reg x_by_dt_underflow;
	
	
	assign x_by_dt_exp = x[30:23] - 8'd10;
	assign x_by_dt_man = x[22:0];
	
	assign x_by_dt = ( x[30:23]<= 8'd10 ) ? 0 : {x[31], x_by_dt_exp, x_by_dt_man};
	
	
//	
//	
//	always @ (x or reset)
//	begin
//        if (reset) begin
//             x_by_dt <= 32'd0;
//            x_by_dt_underflow <= 0;
//        end
//		if ( x[30:23]<= 8'd10 )
//			begin
//				x_by_dt <= 0;
//				x_by_dt_underflow<=1;
//			end
//		else
//			begin
//				x_by_dt <= {x[31], x_by_dt_exp, x_by_dt_man};
//				x_by_dt_underflow <= 0;
//			end
//	end
	
	add int_adder
		(	.x(int_x), .y(x_by_dt), .out(int_x_F0) ); 

	assign out = int_x_F0;
    //assign out = 32'h3f67b7cc;
endmodule
