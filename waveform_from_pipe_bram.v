`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:18:04 04/03/2012 
// Design Name: 
// Module Name:    waveform_from_pipe_bram 
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

module waveform_from_pipe_bram_2s(
                                input wire reset,
                                input wire pipe_clk,
                                input wire pipe_in_write,
                                input wire [15:0] pipe_in_data,
                                input wire is_from_trigger,
                                input wire [31:0] data_from_trig,	// data from one of ep50 channel
                                input wire pipe_out_read,
                                output wire [15:0] pipe_out_data,
                                input wire pop_clk,
                                output wire [31:0] wave
                                
                             
    );


assign wave = (is_from_trigger)? data_from_trig : wave_temp  ;


// Pipe in functionality
reg [11:0] pipe_addr;
always @(posedge pipe_clk) begin
	if (reset == 1'b1) begin
		pipe_addr <= 11'd0;
	end else begin
		if (pipe_in_write == 1'b1 || pipe_out_read == 1'b1)
			pipe_addr <= pipe_addr + 1;
	end
end

// Wave out functionality
reg [11:1] pop_addr;
always @ (posedge pop_clk) begin
    if (reset == 1'b1) begin
        pop_addr <= 10'd0;
    end else begin
        pop_addr <= pop_addr + 1;
    end
end

wire [31:0] wave_temp;
bram_2048 block_ram (
  .clka(pipe_clk), // input clka
  .wea(pipe_in_write), // input [0 : 0] wea
  .addra(pipe_addr), // input [11 : 0] addra
  .dina(pipe_in_data), // input [15 : 0] dina
  .douta(pipe_out_data), // output [15 : 0] douta
  .clkb(pop_clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(pop_addr), // input [10 : 0] addrb
  .dinb(31'd0), // input [31 : 0] dinb
  .doutb(wave_temp) // output [31 : 0] doutb
);
/*
wire [31:0] ram_0_data;
wire [31:0] ram_1_data;
wire [31:0] ram_2_data;
wire [31:0] ram_3_data;

wire [15:0] ram_0_pipe_data;
wire [15:0] ram_1_pipe_data;
wire [15:0] ram_2_pipe_data;
wire [15:0] ram_3_pipe_data;


reg [3:0] ram_ena;

always @ (pipe_addr[11:10])
    case (pipe_addr[11:10])
            0:  ram_ena = 4'b0001;
            1:  ram_ena = 4'b0010;
            2:  ram_ena = 4'b0100;
            3:  ram_ena = 4'b1000;
            default: ram_ena = 0;
    endcase
    
always @ (pipe_addr[11:10])
    case (pipe_addr[11:10])
            0:  pipe_out_data = ram_0_pipe_data;
            1:  pipe_out_data = ram_1_pipe_data;
            2:  pipe_out_data = ram_2_pipe_data;
            3:  pipe_out_data = ram_3_pipe_data;
            default: pipe_out_data = 0;
    endcase



reg [3:0] ram_enb;
always @ (pop_addr[11:10])
    case (pop_addr[11:10])
            0:  ram_enb = 4'b0001;
            1:  ram_enb = 4'b0010;
            2:  ram_enb = 4'b0100;
            3:  ram_enb = 4'b1000;
            default: ram_enb = 0;
    endcase            

always @ (pop_addr[11:10])
            case (pop_addr[11:10])
                0:  wave = ram_0_data;
                1:  wave = ram_1_data;
                2:  wave = ram_2_data;
                3:  wave = ram_3_data;
                default: wave = 0;
             endcase


RAMB16_S18_S36 ram_0(.CLKA(pipe_clk), .SSRA(1'b0), .ENA(ram_ena[0]),
                     .WEA(pipe_in_write), .ADDRA(pipe_addr[9:0]),
                     .DIA(pipe_in_data), .DIPA(2'b0), .DOA(ram_0_pipe_data), .DOPA(),
                     .CLKB(pop_clk), .SSRB(1'b0), .ENB(1'b1),
                     .WEB(1'b0), .ADDRB(pop_addr[9:1]),
                     .DIB(32'b0), .DIPB(4'b0), .DOB(ram_0_data), .DOPB()); 

RAMB16_S18_S36 ram_1(.CLKA(pipe_clk), .SSRA(1'b0), .ENA(ram_ena[1]),
                     .WEA(pipe_in_write), .ADDRA(pipe_addr[9:0]),
                     .DIA(pipe_in_data), .DIPA(2'b0), .DOA(ram_1_pipe_data), .DOPA(),
                     .CLKB(pop_clk), .SSRB(1'b0), .ENB(1'b1),
                     .WEB(1'b0), .ADDRB(pop_addr[9:1]),
                     .DIB(32'b0), .DIPB(4'b0), .DOB(ram_1_data), .DOPB()); 

RAMB16_S18_S36 ram_2(.CLKA(pipe_clk), .SSRA(1'b0), .ENA(ram_ena[2]),
                     .WEA(pipe_in_write), .ADDRA(pipe_addr[9:0]),
                     .DIA(pipe_in_data), .DIPA(2'b0), .DOA(ram_2_pipe_data), .DOPA(),
                     .CLKB(pop_clk), .SSRB(1'b0), .ENB(1'b1),
                     .WEB(1'b0), .ADDRB(pop_addr[9:1]),
                     .DIB(32'b0), .DIPB(4'b0), .DOB(ram_2_data), .DOPB());

RAMB16_S18_S36 ram_3(.CLKA(pipe_clk), .SSRA(1'b0), .ENA(ram_ena[3]),
                     .WEA(pipe_in_write), .ADDRA(pipe_addr[9:0]),
                     .DIA(pipe_in_data), .DIPA(2'b0), .DOA(ram_3_pipe_data), .DOPA(),
                     .CLKB(pop_clk), .SSRB(1'b0), .ENB(1'b1),
                     .WEB(1'b0), .ADDRB(pop_addr[9:1]),
                     .DIB(32'b0), .DIPB(4'b0), .DOB(ram_3_data), .DOPB());                     
*/                     
endmodule

module waveform_from_pipe_bram_16s(
                                input wire reset,
                                input wire pipe_clk,
                                input wire pipe_in_write,
                                input wire [15:0] pipe_in_data,
                                input wire is_from_trigger,
                                input wire [31:0] data_from_trig,	// data from one of ep50 channel
                                input wire pipe_out_read,
                                output wire [15:0] pipe_out_data,
                                input wire pop_clk,
                                output wire [31:0] wave
                                
                             
    );


assign wave = (is_from_trigger)? data_from_trig : wave_temp  ;


// Pipe in functionality
reg [14:0] pipe_addr;
always @(posedge pipe_clk) begin
	if (reset == 1'b1) begin
		pipe_addr <= 15'd0;
	end else begin
		if (pipe_in_write == 1'b1 || pipe_out_read == 1'b1)
			pipe_addr <= pipe_addr + 1;
	end
end

// Wave out functionality
reg [14:1] pop_addr;
always @ (posedge pop_clk) begin
    if (reset == 1'b1) begin
        pop_addr <= 14'd0;
    end else begin
        pop_addr <= pop_addr + 1;
    end
end

wire [31:0] wave_temp;
bram_16s waveform_memory (
  .clka(pipe_clk), // input clka
  .wea(pipe_in_write), // input [0 : 0] wea
  .addra(pipe_addr), // input [14 : 0] addra
  .dina(pipe_in_data), // input [15 : 0] dina
  .douta(pipe_out_data), // output [15 : 0] douta
  .clkb(pop_clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(pop_addr), // input [13 : 0] addrb
  .dinb(31'd0), // input [31 : 0] dinb
  .doutb(wave_temp) // output [31 : 0] doutb
);           
endmodule
