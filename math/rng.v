`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:25:56 04/02/2012 
// Design Name: 
// Module Name:    rng 
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
module rng(
            input wire clk1,
            input wire clk2,
            input wire reset,
            output wire [31:0] out,
            
            output wire [42:0] lfsr,
            output wire [36:0] casr
    );

    lfsr lfsr_0(
                .clk(clk1),
                .reset(reset),
                .out(lfsr)
                );
                
    casr casr_0(
                .clk(clk2),
                .reset(reset),
                .out(casr)
                );
                
    assign out = lfsr[42:11] ^ casr[36:5];


endmodule


module lfsr(
    input wire clk,
    input wire reset,
    output reg [42:0] out
    );
    
    
    always @ (posedge clk or posedge reset)
        if (reset) out<= 43'h400_0000_0000;
        else out <= { (out[42] ^ out[40]) ^ (out[19] ^ out[0]) , out[42:1]};


    
endmodule


  module casr(
      input wire clk,
      input wire reset,
      output wire [36:0] out
    );

  
	 casr_90 bit0( .clk(clk), .reset(reset), .in_left(out[1]), .in_right(1'b0), .out(out[0]) );
	 casr_90 bit1( .clk(clk), .reset(reset), .in_left(out[2]), .in_right(out[0]), .out(out[1]) );
	 casr_90 bit2( .clk(clk), .reset(reset), .in_left(out[3]), .in_right(out[1]), .out(out[2]) );
	 casr_90 bit3( .clk(clk), .reset(reset), .in_left(out[4]), .in_right(out[2]), .out(out[3]) );
	 casr_90 bit4( .clk(clk), .reset(reset), .in_left(out[5]), .in_right(out[3]), .out(out[4]) );
	 casr_90 bit5( .clk(clk), .reset(reset), .in_left(out[6]), .in_right(out[4]), .out(out[5]) );
	 casr_90 bit6( .clk(clk), .reset(reset), .in_left(out[7]), .in_right(out[5]), .out(out[6]) );
	 casr_90 bit7( .clk(clk), .reset(reset), .in_left(out[8]), .in_right(out[6]), .out(out[7]) );
	 casr_90 bit8( .clk(clk), .reset(reset), .in_left(out[9]), .in_right(out[7]), .out(out[8]) );
	 casr_90 bit9( .clk(clk), .reset(reset), .in_left(out[10]), .in_right(out[8]), .out(out[9]) );
	 casr_90 bit10( .clk(clk), .reset(reset), .in_left(out[11]), .in_right(out[9]), .out(out[10]) );
	 casr_90 bit11( .clk(clk), .reset(reset), .in_left(out[12]), .in_right(out[10]), .out(out[11]) );
	 casr_90 bit12( .clk(clk), .reset(reset), .in_left(out[13]), .in_right(out[11]), .out(out[12]) );
	 casr_90 bit13( .clk(clk), .reset(reset), .in_left(out[14]), .in_right(out[12]), .out(out[13]) );
	 casr_90 bit14( .clk(clk), .reset(reset), .in_left(out[15]), .in_right(out[13]), .out(out[14]) );
	 casr_90 bit15( .clk(clk), .reset(reset), .in_left(out[16]), .in_right(out[14]), .out(out[15]) );
	 casr_90 bit16( .clk(clk), .reset(reset), .in_left(out[17]), .in_right(out[15]), .out(out[16]) );
	 casr_90 bit17( .clk(clk), .reset(reset), .in_left(out[18]), .in_right(out[16]), .out(out[17]) );
	 casr_90 bit18( .clk(clk), .reset(reset), .in_left(out[19]), .in_right(out[17]), .out(out[18]) );
	 casr_90 bit19( .clk(clk), .reset(reset), .in_left(out[20]), .in_right(out[18]), .out(out[19]) );
	 casr_90 bit20( .clk(clk), .reset(reset), .in_left(out[21]), .in_right(out[19]), .out(out[20]) );
	 casr_90 bit21( .clk(clk), .reset(reset), .in_left(out[22]), .in_right(out[20]), .out(out[21]) );
	 casr_90 bit22( .clk(clk), .reset(reset), .in_left(out[23]), .in_right(out[21]), .out(out[22]) );
	 casr_90 bit23( .clk(clk), .reset(reset), .in_left(out[24]), .in_right(out[22]), .out(out[23]) );
	 casr_90 bit24( .clk(clk), .reset(reset), .in_left(out[25]), .in_right(out[23]), .out(out[24]) );
	 casr_90 bit25( .clk(clk), .reset(reset), .in_left(out[26]), .in_right(out[24]), .out(out[25]) );
	 casr_90 bit26( .clk(clk), .reset(reset), .in_left(out[27]), .in_right(out[25]), .out(out[26]) );
	 casr_90 bit27( .clk(clk), .reset(reset), .in_left(out[28]), .in_right(out[26]), .out(out[27]) );
	 casr_150 bit28( .clk(clk), .reset(reset), .in_left(out[29]), .in_right(out[27]), .out(out[28]) );
	 casr_90 bit29( .clk(clk), .reset(reset), .in_left(out[30]), .in_right(out[28]), .out(out[29]) );
	 casr_90 bit30( .clk(clk), .reset(reset), .in_left(out[31]), .in_right(out[29]), .out(out[30]) );
	 casr_90 bit31( .clk(clk), .reset(reset), .in_left(out[32]), .in_right(out[30]), .out(out[31]) );
	 casr_90 bit32( .clk(clk), .reset(reset), .in_left(out[33]), .in_right(out[31]), .out(out[32]) );
	 casr_90 bit33( .clk(clk), .reset(reset), .in_left(out[34]), .in_right(out[32]), .out(out[33]) );
	 casr_90 bit34( .clk(clk), .reset(reset), .in_left(out[35]), .in_right(out[33]), .out(out[34]) );
	 casr_90 bit35( .clk(clk), .reset(reset), .in_left(out[36]), .in_right(out[34]), .out(out[35]) );
	 casr_90 bit36( .clk(clk), .reset(reset), .in_left(1'b0), .in_right(out[35]), .out(out[36]) );
endmodule


module  casr_90(
        input wire clk,
        input wire reset,
        input wire in_left,
        input wire in_right,
        output reg out
    );
    
    
    always @ (posedge clk or posedge reset)
        if (reset) out <= 0;
        else out <= in_left ^ in_right;

endmodule

module casr_150 (
        input wire clk,
        input wire reset,
        input wire in_left,
        input wire in_right,
        output reg out
        );
        
    always @ (posedge clk or posedge reset)
        if (reset) out <= 1;
        else out <= in_left ^ ( out ^ in_right );
        
        
endmodule
