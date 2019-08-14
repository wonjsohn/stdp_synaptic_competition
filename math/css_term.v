`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:25:27 04/19/2011 
// Design Name: 
// Module Name:    css_term 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module css_term(
		input [31:0] in,
		output reg [31:0] out
    );

	wire [7:0] idx_exp;
	wire [22:0] idx_man;
	
	assign idx_exp = (in[30:23] < 8'hFE - 10) ? in[30:23] + 10 : 8'hFE;
	assign idx_man = in[22:0];
	
	wire [31:0] idx;
	
	floor floor1( .in( { in[31], idx_exp, idx_man} ), .out(idx) );
	
	always @ (in)
		begin
			case (idx[9:0])
				10'd0  : out = 32'h00000000;
				10'd1  : out = 32'h3eec9a9f;
				10'd2  : out = 32'h3f42f7d6;
				10'd3  : out = 32'h3f67b7cc;
				10'd4  : out = 32'h3f76ca83;
				10'd5  : out = 32'h3f7c92c1;
				10'd6  : out = 32'h3f7ebbe9;
				10'd7  : out = 32'h3f7f8896;
				10'd8  : out = 32'h3f7fd40c;
				10'd9  : out = 32'h3f7fefd4;
				10'd10  : out = 32'h3f7ffa0d;
				10'd11  : out = 32'h3f7ffdd0;
				10'd12  : out = 32'h3f7fff32;
				10'd13  : out = 32'h3f7fffb4;
				10'd14  : out = 32'h3f7fffe4;
				10'd15  : out = 32'h3f7ffff6;
				10'd16  : out = 32'h3f7ffffc;
				10'd17  : out = 32'h3f7fffff;
				10'd18  : out = 32'h3f7fffff;
				10'd19  : out = 32'h3f800000;
				10'd20  : out = 32'h3f800000;
				10'd21  : out = 32'h3f800000;
				10'd22  : out = 32'h3f800000;
				10'd23  : out = 32'h3f800000;
				10'd24  : out = 32'h3f800000;
				10'd25  : out = 32'h3f800000;
				10'd26  : out = 32'h3f800000;
				10'd27  : out = 32'h3f800000;
				10'd28  : out = 32'h3f800000;
				10'd29  : out = 32'h3f800000;
				10'd30  : out = 32'h3f800000;
				default : out = 32'h3f800000;
			endcase
		end
		
endmodule


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:39:49 04/19/2011 
// Design Name: 
// Module Name:    css_term_test 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module css_term_test
(
   input  wire [7:0]  hi_in,
   output wire [1:0]  hi_out,
   inout  wire [15:0] hi_inout,
   
   output wire        i2c_sda,
   output wire        i2c_scl,
   output wire        hi_muxsel,
   
   input  wire        clk1,
   input  wire        clk2,
   output wire [3:0]  led
   //input  wire [1:0]  button
);

parameter NN=8;

// Target interface bus:
wire        ti_clk;
wire [30:0] ok1;
wire [16:0] ok2;

// Endpoint connections:
wire [15:0] ep00wire;
wire signed [15:0]  ep01wire, ep02wire, ep50trig;  //inputs
wire [15:0] ep03wire, ep04wire;

wire signed [15:0]  ep20wire, ep21wire, ep22wire, ep23wire, ep24wire, ep25wire;  //outputs
wire signed [15:0]  ep26wire, ep27wire, ep28wire, ep29wire, ep2Awire, ep2Bwire;  //outputs
wire [15:0] ep30wire, ep31wire, ep32wire, ep33wire, ep34wire, ep35wire;
wire [15:0] ep36wire, ep37wire, ep38wire, ep39wire;

wire [31:0] out;
reg [31:0] in;

//wire [17:0]  ep61trig;
wire pipeO_read;
reg [15:0] pipeO_data;

assign i2c_sda = 1'bz;
assign i2c_scl = 1'bz;
assign hi_muxsel = 1'b0;

wire [31:0] Ia_pps, II_pps, outval_2, outval_3;
reg [31:0] pos_flex, pos_ext, vel_flex, vel_ext, gamma_sta_flex, gamma_sta_ext;
reg [31:0] gamma_dyn_flex, gamma_dyn_ext;

reg inputValid;
wire outputValid;
reg clk;
wire reset;

//input wires
assign reset     = ep00wire[0]; //~button[0]; 

always @(posedge ep50trig[3])
begin
	in	<= {ep02wire, ep01wire};  //[7:0]; //8'h1f;
	pos_ext <= {ep04wire, ep03wire}; //8'h1f;
end
always @(posedge ep50trig[4])
begin
	vel_flex <= {ep02wire, ep01wire};  //[7:0]; //8'h1f;
	vel_ext <= {ep04wire, ep03wire}; //8'h1f;
end
always @(posedge ep50trig[5])
begin
	gamma_sta_flex <= {ep02wire, ep01wire};  //[7:0]; //8'h1f;
	gamma_sta_ext <= {ep04wire, ep03wire}; //8'h1f;
end
always @(posedge ep50trig[6])
begin
	gamma_dyn_flex <= {ep02wire, ep01wire};  //[7:0]; //8'h1f;
	gamma_dyn_ext <= {ep04wire, ep03wire}; //8'h1f;
end

reg [17:0] delay_cnt;
always @(posedge ep50trig[7])  //number of hardware clock cycles +1 per neuron clock cycle
begin
	delay_cnt <= {2'b00, ep01wire};
end
//output wires


css_term	css1(.in(in), .out(out));

assign ep20wire	= out[15:0];
assign ep21wire	= out[31:16];
assign ep22wire	= II_pps[15:0];
assign ep23wire	= II_pps[31:16];
assign ep24wire	= outval_2[15:0];
assign ep25wire	= outval_2[31:16];
assign ep26wire	= outval_3[15:0];
assign ep27wire	= outval_3[31:16];

assign led        = ~Ia_pps[7:0]; //~count1;
//assign led = ~ext_torque[7:0];

reg [10:0] delayreg;
wire test_clk;

always @ (posedge clk1)
begin
	delayreg <= delayreg + 1;
end
assign test_clk = delayreg[delay_cnt];


// Instantiate the okHostInterface and connect endpoints to
// the target interface.
wire [17*22-1:0]  ok2x;
okWireOR # (.N(22)) wireOR 
    (   .ok2(ok2), .ok2s(ok2x));
okHost okHI
    (   .hi_in(hi_in), .hi_out(hi_out), .hi_inout(hi_inout),
        .ti_clk(ti_clk), .ok1(ok1), .ok2(ok2));

okWireIn ep00 (.ok1(ok1),  .ep_addr(8'h00), .ep_dataout(ep00wire));
okWireIn ep01 (.ok1(ok1),  .ep_addr(8'h01), .ep_dataout(ep01wire));
okWireIn ep02 (.ok1(ok1),  .ep_addr(8'h02), .ep_dataout(ep02wire));
okWireIn ep03 (.ok1(ok1),  .ep_addr(8'h03), .ep_dataout(ep03wire));
okWireIn ep04 (.ok1(ok1),  .ep_addr(8'h04), .ep_dataout(ep04wire));
//okWireIn ep05 (.ok1(ok1), .ok2(ok2), .ep_addr(8'h05), .ep_dataout(ep05wire));
okTriggerIn ep50 (.ok1(ok1),  .ep_addr(8'h50), .ep_clk(clk1), .ep_trigger(ep50trig));

/*
okWireOut ep20 (.ok1(ok1), .ok2(ok2), .ep_addr(8'h20), .ep_datain(ep20wire));
okWireOut ep21 (.ok1(ok1), .ok2(ok2), .ep_addr(8'h21), .ep_datain(ep21wire));
okWireOut ep22 (.ok1(ok1), .ok2(ok2), .ep_addr(8'h22), .ep_datain(ep22wire));
okWireOut ep23 (.ok1(ok1), .ok2(ok2), .ep_addr(8'h23), .ep_datain(ep23wire));
okWireOut ep24 (.ok1(ok1), .ok2(ok2), .ep_addr(8'h24), .ep_datain(ep24wire));
okWireOut ep25 (.ok1(ok1), .ok2(ok2), .ep_addr(8'h25), .ep_datain(ep25wire));
okWireOut ep26 (.ok1(ok1), .ok2(ok2), .ep_addr(8'h26), .ep_datain(ep26wire));
okWireOut ep27 (.ok1(ok1), .ok2(ok2), .ep_addr(8'h27), .ep_datain(ep27wire));
okWireOut ep28 (.ok1(ok1), .ok2(ok2), .ep_addr(8'h28), .ep_datain(ep28wire));
okWireOut ep29 (.ok1(ok1), .ok2(ok2), .ep_addr(8'h29), .ep_datain(ep29wire));
     
//okTriggerOut ep61 (.ok1(ok1), .ok2(ok2), .ep_addr(8'h61), .ep_clk(clk2), .ep_trigger(ep61trig));

okPipeOut epA1 (.ok1(ok1), .ok2(ok2), .ep_addr(8'ha1), .ep_read(pipeO_read), .ep_datain(pipeO_data));
*/
	okWireOut    ep20 (.ok1(ok1), .ok2(ok2x[ 0*17 +: 17 ]), .ep_addr(8'h20), .ep_datain(ep20wire));
	okWireOut    ep21 (.ok1(ok1), .ok2(ok2x[ 1*17 +: 17 ]), .ep_addr(8'h21), .ep_datain(ep21wire));
	okWireOut    ep22 (.ok1(ok1), .ok2(ok2x[ 2*17 +: 17 ]), .ep_addr(8'h22), .ep_datain(ep22wire));
	okWireOut    ep23 (.ok1(ok1), .ok2(ok2x[ 3*17 +: 17 ]), .ep_addr(8'h23), .ep_datain(ep23wire));
	okWireOut    ep24 (.ok1(ok1), .ok2(ok2x[ 4*17 +: 17 ]), .ep_addr(8'h24), .ep_datain(ep24wire));
	okWireOut    ep25 (.ok1(ok1), .ok2(ok2x[ 5*17 +: 17 ]), .ep_addr(8'h25), .ep_datain(ep25wire));
	okWireOut    ep26 (.ok1(ok1), .ok2(ok2x[ 6*17 +: 17 ]), .ep_addr(8'h26), .ep_datain(ep26wire));
	okWireOut    ep27 (.ok1(ok1), .ok2(ok2x[ 7*17 +: 17 ]), .ep_addr(8'h27), .ep_datain(ep27wire));
	okWireOut    ep28 (.ok1(ok1), .ok2(ok2x[ 8*17 +: 17 ]), .ep_addr(8'h28), .ep_datain(ep28wire));
	okWireOut    ep29 (.ok1(ok1), .ok2(ok2x[ 9*17 +: 17 ]), .ep_addr(8'h29), .ep_datain(ep29wire));
	
	okWireOut    ep30 (.ok1(ok1), .ok2(ok2x[ 10*17 +: 17 ]), .ep_addr(8'h30), .ep_datain(ep30wire));
	okWireOut    ep31 (.ok1(ok1), .ok2(ok2x[ 11*17 +: 17 ]), .ep_addr(8'h31), .ep_datain(ep31wire));
	okWireOut    ep32 (.ok1(ok1), .ok2(ok2x[ 12*17 +: 17 ]), .ep_addr(8'h32), .ep_datain(ep32wire));
	okWireOut    ep33 (.ok1(ok1), .ok2(ok2x[ 13*17 +: 17 ]), .ep_addr(8'h33), .ep_datain(ep33wire));
	okWireOut    ep34 (.ok1(ok1), .ok2(ok2x[ 14*17 +: 17 ]), .ep_addr(8'h34), .ep_datain(ep34wire));
	okWireOut    ep35 (.ok1(ok1), .ok2(ok2x[ 15*17 +: 17 ]), .ep_addr(8'h35), .ep_datain(ep35wire));
	okWireOut    ep36 (.ok1(ok1), .ok2(ok2x[ 16*17 +: 17 ]), .ep_addr(8'h36), .ep_datain(ep36wire));
	okWireOut    ep37 (.ok1(ok1), .ok2(ok2x[ 17*17 +: 17 ]), .ep_addr(8'h37), .ep_datain(ep37wire));
	okWireOut    ep38 (.ok1(ok1), .ok2(ok2x[ 18*17 +: 17 ]), .ep_addr(8'h38), .ep_datain(ep38wire));
	okWireOut    ep39 (.ok1(ok1), .ok2(ok2x[ 19*17 +: 17 ]), .ep_addr(8'h39), .ep_datain(ep39wire));
	
	okWireOut    ep2A (.ok1(ok1), .ok2(ok2x[ 20*17 +: 17 ]), .ep_addr(8'h2A), .ep_datain(ep2Awire));
	okWireOut    ep2B (.ok1(ok1), .ok2(ok2x[ 21*17 +: 17 ]), .ep_addr(8'h2B), .ep_datain(ep2Bwire));	
endmodule