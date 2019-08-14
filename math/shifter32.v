module shifter32(in, op, s, out);
input [31:0] in;
input [4:0] s;
input [1:0] op;
//SHL 00 Logic left shift
//SHR 01 Logic Right shift
//ASR 10 Arithmic Right shift 
//ROR 11 Rotational Right shift

output [31:0] out;

wire [31:0] tmp1, tmp2, tmp3, tmp4, op1, in1, revin, out1, revout;
wire op2, op3;
wire [3:0] in2, op4, op5;
wire [7:0] in3, op6, op7;
wire [15:0] in4, op8, op9;

assign in1 = (in&~op1)|(revin&op1);
assign out = (out1&~op1)|(revout&op1);
assign op2 = op[1]&op[0];
assign op3 = op[1]&~op[0];

reverse
	reverse1(.in(in), .out(revin)),
	reverse2(.in(out1), .out(revout));
extend_to_32
	e32_1(.in(op[0]|op[1]), .out(op1));
extend_to_4
	e4_1(.in(op2), .out(op4)),
	e4_2(.in(in1[0]), .out(in2)),
	e4_3(.in(op3), .out(op5));
extend_to_8
	e8_1(.in(op2), .out(op6)),
	e8_2(.in(in1[0]), .out(in3)),
	e8_3(.in(op3), .out(op7));
extend_to_16
	ex_1(.in(op2), .out(op8)),
	ex_2(.in(in1[0]), .out(in4)),
	ex_3(.in(op3), .out(op9));
	
levellink
	levellink1(.in1(in1), .in2({in1[30:0],(in1[31]&op2)|(in1[0]&op3)}), .s(s[0]), .out(tmp1)),
	levellink2(.in1(tmp1), .in2({tmp1[29:0],(tmp1[31:30]&{op2,op2})|({in1[0],in1[0]}&{op3,op3})}), .s(s[1]), .out(tmp2)),
	levellink3(.in1(tmp2), .in2({tmp2[27:0],(tmp2[31:28]&op4)|(in2&op5)}), .s(s[2]), .out(tmp3)),
	levellink4(.in1(tmp3), .in2({tmp3[23:0],(tmp3[31:24]&op6)|(in3&op7)}), .s(s[3]), .out(tmp4)),
	levellink5(.in1(tmp4), .in2({tmp4[15:0],(tmp4[31:16]&op8)|(in4&op9)}), .s(s[4]), .out(out1));

endmodule


module mux22(in, c, out);
input [1:0] in;
input c;
output out;

assign out = (c&in[0])|(~c&in[1]);

endmodule



module levellink(in1, in2, s, out);
input [31:0] in1, in2;
input s;
output [31:0] out;

mux22 mux21_1_0(.in({in1[0], in2[0]}), .c(s), .out(out[0])),
	mux21_1_1(.in({in1[1], in2[1]}), .c(s), .out(out[1])),
	mux21_1_2(.in({in1[2], in2[2]}), .c(s), .out(out[2])),
	mux21_1_3(.in({in1[3], in2[3]}), .c(s), .out(out[3])),
	mux21_1_4(.in({in1[4], in2[4]}), .c(s), .out(out[4])),
	mux21_1_5(.in({in1[5], in2[5]}), .c(s), .out(out[5])),
	mux21_1_6(.in({in1[6], in2[6]}), .c(s), .out(out[6])),
	mux21_1_7(.in({in1[7], in2[7]}), .c(s), .out(out[7])),
	mux21_1_8(.in({in1[8], in2[8]}), .c(s), .out(out[8])),
	mux21_1_9(.in({in1[9], in2[9]}), .c(s), .out(out[9])),
	mux21_1_10(.in({in1[10], in2[10]}), .c(s), .out(out[10])),
	mux21_1_11(.in({in1[11], in2[11]}), .c(s), .out(out[11])),
	mux21_1_12(.in({in1[12], in2[12]}), .c(s), .out(out[12])),
	mux21_1_13(.in({in1[13], in2[13]}), .c(s), .out(out[13])),
	mux21_1_14(.in({in1[14], in2[14]}), .c(s), .out(out[14])),
	mux21_1_15(.in({in1[15], in2[15]}), .c(s), .out(out[15])),
	mux21_1_16(.in({in1[16], in2[16]}), .c(s), .out(out[16])),
	mux21_1_17(.in({in1[17], in2[17]}), .c(s), .out(out[17])),
	mux21_1_18(.in({in1[18], in2[18]}), .c(s), .out(out[18])),
	mux21_1_19(.in({in1[19], in2[19]}), .c(s), .out(out[19])),
	mux21_1_20(.in({in1[20], in2[20]}), .c(s), .out(out[20])),
	mux21_1_21(.in({in1[21], in2[21]}), .c(s), .out(out[21])),
	mux21_1_22(.in({in1[22], in2[22]}), .c(s), .out(out[22])),
	mux21_1_23(.in({in1[23], in2[23]}), .c(s), .out(out[23])),
	mux21_1_24(.in({in1[24], in2[24]}), .c(s), .out(out[24])),
	mux21_1_25(.in({in1[25], in2[25]}), .c(s), .out(out[25])),
	mux21_1_26(.in({in1[26], in2[26]}), .c(s), .out(out[26])),
	mux21_1_27(.in({in1[27], in2[27]}), .c(s), .out(out[27])),
	mux21_1_28(.in({in1[28], in2[28]}), .c(s), .out(out[28])),
	mux21_1_29(.in({in1[29], in2[29]}), .c(s), .out(out[29])),
	mux21_1_30(.in({in1[30], in2[30]}), .c(s), .out(out[30])),
	mux21_1_31(.in({in1[31], in2[31]}), .c(s), .out(out[31]));

endmodule


module reverse(in, out);
input [31:0] in;
output [31:0] out;

assign out = {in[0],in[1],in[2],in[3],
in[4],in[5],in[6],in[7],in[8],in[9],
in[10],in[11],in[12],in[13],in[14],in[15],
in[16],in[17],in[18],in[19],in[20],in[21],
in[22],in[23],in[24],in[25],in[26],in[27],
in[28],in[29],in[30],in[31]};

endmodule

module extend_to_16(in, out);
input in;
output [15:0] out;

assign out = {in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in};

endmodule

module extend_to_8(in, out);
input in;
output [7:0] out;

assign out = {in,in,in,in,in,in,in,in};

endmodule

module extend_to_4(in, out);
input in;
output [3:0] out;

assign out = {in,in,in,in};

endmodule


module extend_to_32(in, out);
input in;
output [31:0] out;

assign out = {in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in,in};

endmodule