
`include "fm_constants.v"

module SynTestbed(A,B,control,Out,flagout,clk,reset);

input [`WIDTH-1:0] A,B;
input [`WCONTROL-1:0] control;
input 	clk;
input 	reset;
output [`WIDTH-1:0] Out;
output [`WFLAG-1:0] flagout;

wire [`WFLAG-1:0] flags;
reg [`WFLAG-1:0] flags2;
reg [`WCONTROL-1:0] control2;
wire [`WIDTH-1:0] C,D,X;

flop flopA(clk,reset,A,C);
flop flopB(clk,reset,B,D);
flop flopOut(clk,reset,X,Out);

always @(posedge clk)
	control2 <= control;

fpmul multest(C,D,X,control2,flags);

always @(posedge clk)
	flags2 <= flags;

assign flagout = flags2;	

endmodule

module flop(clk, reset, d, q);

  input         clk;
  input         reset;
  input  [31:0] d;
  output [31:0] q;

  reg    [31:0] state;

  always @(posedge clk or posedge reset)
    begin
      if (reset) state <= #1 0;
	  else state <= #1 d;
	end

  assign #1 q = state;

endmodule
