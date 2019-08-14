`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:57:58 04/06/2012 
// Design Name: 
// Module Name:    izneuron 
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

// max frequency 36.547MHz

module izneuron_th_control(
                input wire clk,
                input wire reset,
                input wire signed [31:0] I_in,
                input wire [31:0] th_scaled, 
                output reg signed [31:0] v_out,
                output reg spike,
                output reg each_spike,
                
                output reg [127:0] population
    );

    reg [127:0] history;
    reg signed [31:0] I;
    wire signed [31:0] v;
    wire signed [31:0] u;
    
    wire signed [31:0] a;
    wire signed [31:0] b;
    wire signed [31:0] c;
    wire signed [31:0] d;
    
    assign a = 32'd82; // a = 0.02      (scaling factor 4096)
    assign b = 32'd205; // b = 0.2      (scaling factor 1024)
    assign c = -32'd65560; // c = -65   (scaling factor 1024)
    assign d = 32'd2048; // d = 2       (scaling factor 1024)
    
    wire signed [31:0] c04;
    wire signed [31:0] c140;
    //wire signed [31:0] c30;
    
    assign c04 = 32'd41;  // 0.04
    assign c140 = 32'd143360; // 140
    //assign c30 = 32'd30720; //30
    
    wire signed [31:0] u_init;
    wire signed [31:0] v_init;
    assign u_init = -32'd13125; // b*v = 0.2*-65 = -13
    assign v_init = -32'd65560; // -65

    
    // Calculate V'
    wire signed [63:0] vxv_unscaled;
    assign vxv_unscaled = (v*v);
    
    wire signed [31:0] vxv;
    assign vxv = vxv_unscaled[41:10];
    
    wire signed [63:0] vxvxc04_unscaled;
    assign vxvxc04_unscaled = vxv * c04;
    
    wire signed [31:0] vxvxc04;
    assign vxvxc04 = vxvxc04_unscaled[41:10];
    
    
    wire signed [31:0] v4;
    assign v4 = { v[31], v[28:0], 2'b00};
    
    wire signed [31:0] vprime;
    assign vprime = vxvxc04 + v4 + v + c140 - u + I;
    
    // Calculate U'
    wire signed [63:0] bxv_unscaled;
    assign bxv_unscaled = b*v;
    
    wire signed [31:0] bxv;
    assign bxv = bxv_unscaled[41:10];
    
    wire signed [31:0] bxvmu;
    assign bxvmu = bxv - u;
    
    wire signed [63:0] uprime_unscaled;
    assign uprime_unscaled = bxvmu*a;
    
    wire signed [31:0] uprime;
    assign uprime = uprime_unscaled[43:12];

    // Compare current membrane potential to spike threshold
    wire signed [31:0] th_scaled_mv;
    assign th_scaled_mv = th_scaled - v;
    
    wire fired;
    assign fired = th_scaled_mv[31];
    
    // u plus d
    wire signed [31:0] upd;
    assign upd = u + d;
    
    // integrate u and v
    wire signed [31:0] upuprime;
    assign upuprime = u + uprime; 
    
    // Integrate membrane potential (max membrane potential capped at +100mV)
    wire signed [31:0] vpvprime;
    wire signed [31:0] integrated_vpvprime;
    assign integrated_vpvprime = v + vprime;
    
    wire signed [31:0] max_vpvprime;
    assign max_vpvprime = 32'd102400;
    
    wire signed [31:0] check_vpvprime;
    assign check_vpvprime = max_vpvprime - integrated_vpvprime;
    
    assign vpvprime = check_vpvprime[31] ? max_vpvprime : integrated_vpvprime;
    
    wire [31:0] u_mem;
    wire [31:0] v_mem;
    
    assign u = first_pass ? u_init : u_mem;
    assign v = first_pass ? v_init : v_mem;
    
    wire [31:0] u_mem_in;
    wire [31:0] v_mem_in;
    
    assign u_mem_in = fired ? upd : upuprime;
    assign v_mem_in = fired ? c : vpvprime;
    
    wire [31:0] spike_history_mem;
    wire [31:0] spike_history_mem_in;

    assign spike_history_mem_in = first_pass ? 0 : {spike_history_mem[30:0], fired};
    
    reg state;
    reg read;
    reg write;
    reg first_pass;
    reg [6:0] neuron_index;
    
    always @ (posedge clk or posedge reset)
    begin
        if (reset) begin
            state <= 1;
            write <= 0;
            I <= I_in;
            neuron_index<=0;
        end else begin
            case(state)
                0:  begin
                    neuron_index <= neuron_index + 1;
                    write <= 0;
                    state <= 1;
                    I <= I_in;
                    end
                1:  begin
                    neuron_index <= neuron_index;
                    write <= 1;
                    state <= 0;
                    I <= I;

                    end
             endcase
        end
    end
    
    // PERFORM READ/COMPUTE/WRITE CYCLE ON RAM CONTENTS


wire reset_bar;
assign reset_bar = ~reset;
always @ (negedge clk or negedge reset_bar) begin
    if (~reset_bar) begin
       spike<=0;
       each_spike<=0;
       first_pass <= 1;
       v_out <= 0;
    end else begin
        if (state) begin
            //each_spike <= fired;
            each_spike <= spike_history_mem[14];  // was 14 
            history[neuron_index] <= fired;
            if (neuron_index == 7'h7f) begin
                first_pass <= 0;
                v_out <= v_mem_in;
                //spike <= fired;
                spike <= spike_history_mem[14];  // was 14 
                //population <= {fired, history[126:0]};
                population <= history;
            end
        end
    end
end

    
    neuron_ram u_ram (
  .clka(~clk), // input clka
  .wea(write), // input [0 : 0] wea
  .addra(neuron_index), // input [6 : 0] addra
  .dina(u_mem_in), // input [31 : 0] dina
  .douta(u_mem), // output [31 : 0] douta
  .clkb(clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(7'd0), // input [6 : 0] addrb
  .dinb(32'd0), // input [31 : 0] dinb
  .doutb() // output [31 : 0] doutb
    );

    neuron_ram v_ram (
  .clka(~clk), // input clka
  .wea(write), // input [0 : 0] wea
  .addra(neuron_index), // input [6 : 0] addra
  .dina(v_mem_in), // input [31 : 0] dina
  .douta(v_mem), // output [31 : 0] douta
  .clkb(clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(7'd0), // input [6 : 0] addrb
  .dinb(32'd0), // input [31 : 0] dinb
  .doutb() // output [31 : 0] doutb
    );    
    
    neuron_ram spike_history_ram (
  .clka(~clk), // input clka
  .wea(write), // input [0 : 0] wea
  .addra(neuron_index), // input [6 : 0] addra
  .dina(spike_history_mem_in), // input [31 : 0] dina
  .douta(spike_history_mem), // output [31 : 0] douta
  .clkb(clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(7'd0), // input [6 : 0] addrb
  .dinb(32'd0), // input [31 : 0] dinb
  .doutb() // output [31 : 0] doutb
    );
    
endmodule







//module izneuron(
//                input wire clk,
//                input wire reset,
//                input wire signed [31:0] I_in,
//                output reg signed [31:0] v_out,
//                output reg spike,
//                output reg each_spike,
//                
//                output reg [127:0] population
//    );
//
//    reg [127:0] history;
//    reg signed [31:0] I;
//    wire signed [31:0] v;
//    wire signed [31:0] u;
//    
//    wire signed [31:0] a;
//    wire signed [31:0] b;
//    wire signed [31:0] c;
//    wire signed [31:0] d;
//    
//    assign a = 32'd82; // a = 0.02      (scaling factor 4096)
//    assign b = 32'd205; // b = 0.2      (scaling factor 1024)
//    assign c = -32'd65560; // c = -65   (scaling factor 1024)
//    assign d = 32'd2048; // d = 2       (scaling factor 1024)
//    
//    wire signed [31:0] c04;
//    wire signed [31:0] c140;
//    wire signed [31:0] c30;
//    
//    assign c04 = 32'd41;  // 0.04
//    assign c140 = 32'd143360; // 140
//    assign c30 = 32'd30720; //30
//    
//    wire signed [31:0] u_init;
//    wire signed [31:0] v_init;
//    assign u_init = -32'd13125; // b*v = 0.2*-65 = -13
//    assign v_init = -32'd65560; // -65
//
//    
//    // Calculate V'
//    wire signed [63:0] vxv_unscaled;
//    assign vxv_unscaled = (v*v);
//    
//    wire signed [31:0] vxv;
//    assign vxv = vxv_unscaled[41:10];
//    
//    wire signed [63:0] vxvxc04_unscaled;
//    assign vxvxc04_unscaled = vxv * c04;
//    
//    wire signed [31:0] vxvxc04;
//    assign vxvxc04 = vxvxc04_unscaled[41:10];
//    
//    
//    wire signed [31:0] v4;
//    assign v4 = { v[31], v[28:0], 2'b00};
//    
//    wire signed [31:0] vprime;
//    assign vprime = vxvxc04 + v4 + v + c140 - u + I;
//    
//    // Calculate U'
//    wire signed [63:0] bxv_unscaled;
//    assign bxv_unscaled = b*v;
//    
//    wire signed [31:0] bxv;
//    assign bxv = bxv_unscaled[41:10];
//    
//    wire signed [31:0] bxvmu;
//    assign bxvmu = bxv - u;
//    
//    wire signed [63:0] uprime_unscaled;
//    assign uprime_unscaled = bxvmu*a;
//    
//    wire signed [31:0] uprime;
//    assign uprime = uprime_unscaled[43:12];
//
//    // Compare current membrane potential to spike threshold
//    wire signed [31:0] c30mv;
//    assign c30mv = c30 - v;
//    
//    wire fired;
//    assign fired = c30mv[31];
//    
//    // u plus d
//    wire signed [31:0] upd;
//    assign upd = u + d;
//    
//    // integrate u and v
//    wire signed [31:0] upuprime;
//    assign upuprime = u + uprime; 
//    
//    // Integrate membrane potential (max membrane potential capped at +100mV)
//    wire signed [31:0] vpvprime;
//    wire signed [31:0] integrated_vpvprime;
//    assign integrated_vpvprime = v + vprime;
//    
//    wire signed [31:0] max_vpvprime;
//    assign max_vpvprime = 32'd102400;
//    
//    wire signed [31:0] check_vpvprime;
//    assign check_vpvprime = max_vpvprime - integrated_vpvprime;
//    
//    assign vpvprime = check_vpvprime[31] ? max_vpvprime : integrated_vpvprime;
//    
//    wire [31:0] u_mem;
//    wire [31:0] v_mem;
//    
//    assign u = first_pass ? u_init : u_mem;
//    assign v = first_pass ? v_init : v_mem;
//    
//    wire [31:0] u_mem_in;
//    wire [31:0] v_mem_in;
//    
//    assign u_mem_in = fired ? upd : upuprime;
//    assign v_mem_in = fired ? c : vpvprime;
//    
//    wire [31:0] spike_history_mem;
//    wire [31:0] spike_history_mem_in;
//
//    assign spike_history_mem_in = first_pass ? 0 : {spike_history_mem[30:0], fired};
//    
//    reg state;
//    reg read;
//    reg write;
//    reg first_pass;
//    reg [6:0] neuron_index;
//    
//    always @ (posedge clk or posedge reset)
//    begin
//        if (reset) begin
//            state <= 1;
//            write <= 0;
//            I <= I_in;
//            neuron_index<=0;
//        end else begin
//            case(state)
//                0:  begin
//                    neuron_index <= neuron_index + 1;
//                    write <= 0;
//                    state <= 1;
//                    I <= I_in;
//                    end
//                1:  begin
//                    neuron_index <= neuron_index;
//                    write <= 1;
//                    state <= 0;
//                    I <= I;
//
//                    end
//             endcase
//        end
//    end
//    
//    // PERFORM READ/COMPUTE/WRITE CYCLE ON RAM CONTENTS
//
//
//wire reset_bar;
//assign reset_bar = ~reset;
//always @ (negedge clk or negedge reset_bar) begin
//    if (~reset_bar) begin
//       spike<=0;
//       each_spike<=0;
//       first_pass <= 1;
//       v_out <= 0;
//    end else begin
//        if (state) begin
//            //each_spike <= fired;
//            each_spike <= spike_history_mem[14];
//            history[neuron_index] <= fired;
//            if (neuron_index == 7'h7f) begin
//                first_pass <= 0;
//                v_out <= v_mem_in;
//                //spike <= fired;
//                spike <= spike_history_mem[14];
//                //population <= {fired, history[126:0]};
//                population <= history;
//            end
//        end
//    end
//end
//
//    
//    neuron_ram u_ram (
//  .clka(~clk), // input clka
//  .wea(write), // input [0 : 0] wea
//  .addra(neuron_index), // input [6 : 0] addra
//  .dina(u_mem_in), // input [31 : 0] dina
//  .douta(u_mem), // output [31 : 0] douta
//  .clkb(clk), // input clkb
//  .web(1'b0), // input [0 : 0] web
//  .addrb(7'd0), // input [6 : 0] addrb
//  .dinb(32'd0), // input [31 : 0] dinb
//  .doutb() // output [31 : 0] doutb
//    );
//
//    neuron_ram v_ram (
//  .clka(~clk), // input clka
//  .wea(write), // input [0 : 0] wea
//  .addra(neuron_index), // input [6 : 0] addra
//  .dina(v_mem_in), // input [31 : 0] dina
//  .douta(v_mem), // output [31 : 0] douta
//  .clkb(clk), // input clkb
//  .web(1'b0), // input [0 : 0] web
//  .addrb(7'd0), // input [6 : 0] addrb
//  .dinb(32'd0), // input [31 : 0] dinb
//  .doutb() // output [31 : 0] doutb
//    );    
//    
//    neuron_ram spike_history_ram (
//  .clka(~clk), // input clka
//  .wea(write), // input [0 : 0] wea
//  .addra(neuron_index), // input [6 : 0] addra
//  .dina(spike_history_mem_in), // input [31 : 0] dina
//  .douta(spike_history_mem), // output [31 : 0] douta
//  .clkb(clk), // input clkb
//  .web(1'b0), // input [0 : 0] web
//  .addrb(7'd0), // input [6 : 0] addrb
//  .dinb(32'd0), // input [31 : 0] dinb
//  .doutb() // output [31 : 0] doutb
//    );
//    
//endmodule


// Max frequency after synthesis 7.925MHz
/*
module izneuron_floating_point(
                input wire clk,
                input wire reset,
                input wire [31:0] I,
                output reg [31:0] v,
                output reg spike
    );

    wire [31:0] a;
    wire [31:0] b;
    wire [31:0] c;
    wire [31:0] d;
    
    assign a = 32'h3CA3D70A; // a = 0.02
    assign b = 32'h3E4CCCCD; // b = 0.2
    assign c = 32'hC2820000; // c = -65
    assign d = 32'h40000000; // d = 2
    
    wire [31:0] c04;
    wire [31:0] c140;
    wire [31:0] c5;
    wire [31:0] c30;
    
    assign c04 = 32'h3D23D70A;  // 0.04
    assign c140 = 32'h430C0000; // 140
    assign c5 = 32'h40A00000;   // 5
    assign c30 = 32'h41F00000; //30
    
    wire [31:0] u_init;
    wire [31:0] v_init;
    assign u_init = 32'hC1500000; // b*v = 0.2*-65 = -13
    assign v_init = 32'hC2820000; // -65
    
    reg [31:0] u;
    
    
    // Calculate V'
    wire [31:0] vxv;
    mult m_vxv( .x(v), .y(v), .out(vxv) );
    
    wire [31:0] vxvxc04;
    mult m_vxvxc04( .x(vxv), .y(c04), .out(vxvxc04) );
    
    wire [31:0] vxfive;
    mult m_vxfive( .x(v), .y(c5), .out(vxfive) );
    
    wire [31:0] add1;
    add a_add1( .x(vxvxc04), .y(vxfive), .out(add1) );
    
    wire [31:0] add2;
    add a_add2( .x(c140), .y(I), .out(add2) );
    
    wire [31:0] add3;
    add a_add3( .x(add1), .y(add2), .out(add3) );
    
    wire [31:0] vprime;
    sub s_vprime( .x(add3), .y(u), .out(vprime) );
    
    // Calculate U'
    wire [31:0] bxv;
    mult m_bxv( .x(b), .y(v), .out(bxv) );
    
    wire [31:0] bxvmu;
    sub s_bxvmu( .x(bxv), .y(u), .out( bxvmu) );
    
    wire [31:0] uprime;
    mult m_uprime( .x(a), .y(bxvmu), .out(uprime) );
    
    
    // Compare current membrane potential to spike threshold
    wire [31:0] c30mv;
    wire fired;
    sub s_c30mv( .x(c30), .y(v), .out(c30mv) );
    assign fired = c30mv[31];
    
    // u plus d
    wire [31:0] upd;
    add a_upd( .x(u), .y(d), .out(upd) );
    
    // integrate u and v
    wire [31:0] upuprime;
    add a_upuprime( .x(u), .y(uprime), .out(upuprime) );
    
    wire [31:0] vpvprime;
    add a_vpvprime( .x(v), .y(vprime), .out(vpvprime) );
    
    
    
    
    
    always @ (posedge clk or posedge reset)
    begin
        if (reset) begin
            u <= u_init;
            v <= v_init;
            spike <= 0;
        end else begin
            if (fired) begin
                spike <= 1;
                u <= upd;
                v <= c;
            end else begin
                spike <= 0;
                u <= upuprime;
                v <= vpvprime;
            end
        end
    end

endmodule
*/