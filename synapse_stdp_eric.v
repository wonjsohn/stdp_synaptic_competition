`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:57:07 05/30/2012 
// Design Name: 
// Module Name:    synapse 
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

// max frequency 88.746 MHz
module synapse_stdp_eric(
                input wire clk,
                input wire reset,
                input wire spike_in,
                input wire [31:0] lut2_index,
                input wire postsynaptic_spike_in,
                input wire i_synaptic_decay,
                
                
                output reg signed [31:0] I_out,  // updates once per population (scaling factor 1024) 
                output reg signed [31:0] each_I, // updates on each synapse
                
                output reg [31:0] synaptic_strength, //synaptic weight
                output wire [31:0] delta_w_ltp,            //  
                
                input wire [31:0] base_strength, // baseline synaptic strength
                
                input wire [31:0] ltp_scale,              // long term potentiation delta (stdp)
                input wire [31:0] ltd_scale,              // long term depression delta   (stdp)
                input wire [31:0] p_delta,           // probability of synaptic weight decay event
                input wire [31:0] p_growth,          // probability of synaptic weight change by STDP 
                input wire [31:0] i_weightUpperCap  // upper cap in synaptic weight
    );

// COMPUTE EACH SYNAPTIC CURRENT /////////////////////////////////////////////////////////////////
//wire [31:0] ltp;
//assign ltp = 32'd10;
//wire [31:0] ltd;
//assign ltd = 32'd5;
//wire [31:0] p_delta;
//assign p_delta= 32'd0;

wire [31:0] synapticW;

reg spike;
reg postsynaptic_spike;
//assign synapticW = spike ? 31'd1024 : 0; // 1(unit?) current per spike
//assign synapticW = spike ? 31'd10240 : 0; // 10(unit?) c urrent per spike
assign synapticW = spike ? synapticW_mem_in : 0;  


wire [31:0] i_mem;
wire [31:0] i_mem_in;// I_out

//i_mem updates every neuron_clk
//  current of >>>2 decay is too fast 
// I(n+1) = 0.95* I(n+1) : 20ms time constant (form 1ms time interval)
//assign i_mem_in = first_pass ? 0 : i_mem - (i_mem >>> 3) + synapticW; //I = 0.875*I + synapticW  (current decay+synapticW)  

wire [31:0] i_mem_up;
assign i_mem_up = i_mem + synapticW;  
assign i_mem_in = first_pass ? 0 : i_mem_up - (i_mem_up >>> 4); //I = 1/2^4*I + synapticW  (current decay+synapticW, tau~=15ms.   
//assign i_mem_in = first_pass ? 0 : i_mem - (i_mem >>> 4) + synapticW; //I = 0.9365*I + synapticW  (current decay+synapticW) 

wire [31:0] spike_history_mem;
wire [31:0] spike_history_mem_in;

assign spike_history_mem_in = first_pass ? 0 : {spike_history_mem[30:0], spike};

wire [31:0] spike_history_mem_64ms;
wire [31:0] spike_history_mem_in_64ms;

assign spike_history_mem_in_64ms = first_pass ? 0 : {spike_history_mem_64ms[30:0], spike_history_mem[31]};

//wire [31:0] delta_w_ltp;

//assign delta_w_ltp = postsynaptic_spike ? ((spike_history_mem == 32'd0) ? 0 : ltp) : 0 ; // make a LookupTabe STDP curve & check last spike only. 
wire [31:0] delta_w_ltp_pre;
//assign delta_w_ltp = delta_w_ltp_pre*ltp_scale;
unsigned_mult32 multltp(.out(delta_w_ltp), .a(delta_w_ltp_pre), .b(ltp_scale));

//// linear STDP curve
//assign delta_w_ltp_pre = postsynaptic_spike ? 
//                           ((spike_history_mem[31]? 1:0)+
//                                (spike_history_mem[30]? 2 :0) +
//                                (spike_history_mem[29]?3:0)+
//                                (spike_history_mem[28]?4:0)+
//                                (spike_history_mem[27]?5:0)+
//                                (spike_history_mem[26]?6:0)+
//                                (spike_history_mem[25]?7:0)+
//                                (spike_history_mem[24]?8:0)+
//                                (spike_history_mem[23]?9:0)+
//                                (spike_history_mem[22]?10:0)+
//                                (spike_history_mem[21]?11:0)+
//                                (spike_history_mem[20]?12:0)+
//                                (spike_history_mem[19]?13:0)+
//                                (spike_history_mem[18]?14:0)+
//                                (spike_history_mem[17]?15:0)+
//                                (spike_history_mem[16]?16:0)+
//                                (spike_history_mem[15]?17:0)+
//                                (spike_history_mem[14]?18:0)+
//                                (spike_history_mem[13]?19:0)+
//                                (spike_history_mem[12]?20:0)+
//                                (spike_history_mem[11]?21:0)+
//                                (spike_history_mem[10]?22:0)+
//                                (spike_history_mem[9]?23:0)+
//                                (spike_history_mem[8]?24:0)+
//                                (spike_history_mem[7]?25:0)+
//                                (spike_history_mem[6]?26:0)+
//                                (spike_history_mem[5]?27:0)+
//                                (spike_history_mem[4]?28:0)+
//                                (spike_history_mem[3]?29:0)+
//                                (spike_history_mem[2]?30:0)+
//                                (spike_history_mem[1]?31:0)) : 0;


// exponential STDP curve (parameters from Izhekevich & Desai 2003 ) 
assign delta_w_ltp_pre = postsynaptic_spike ? 

                           (   
                           //64ms or less
                               // REST AND UP IS ALL ZERO IN STDP CURVE
//                        
//                                (spike_history_mem_64ms[18]?1:0)+
//                                (spike_history_mem_64ms[17]?1:0)+
//                                (spike_history_mem_64ms[16]?1:0)+
//                                (spike_history_mem_64ms[15]?1:0)+
//                                (spike_history_mem_64ms[14]?1:0)+
//                                (spike_history_mem_64ms[13]?1:0)+
//                                (spike_history_mem_64ms[12]?1:0)+
//                                (spike_history_mem_64ms[11]?1:0)+
//                                (spike_history_mem_64ms[10]?1:0)+
//                                (spike_history_mem_64ms[9]?1:0)+
//                                (spike_history_mem_64ms[8]?2:0)+
//                                (spike_history_mem_64ms[7]?2:0)+
//                                (spike_history_mem_64ms[6]?2:0)+
//                                (spike_history_mem_64ms[5]?2:0)+
//                                (spike_history_mem_64ms[4]?2:0)+
//                                (spike_history_mem_64ms[3]?3:0)+
//                                (spike_history_mem_64ms[2]?3:0)+
//                                (spike_history_mem_64ms[1]?3:0)+
                           
                           
                             // 32ms or less     
//                                (spike_history_mem[31]? 3:0)+
//                                (spike_history_mem[30]? 4 :0) +
//                                (spike_history_mem[29]?4:0)+
//                                (spike_history_mem[28]?4:0)+
//                                (spike_history_mem[27]?4:0)+
//                                (spike_history_mem[26]?5:0)+


                        // line ->  1:1.4 = ltp: ltd 
                                (spike_history_mem[25]?5:0)+
                                (spike_history_mem[24]?6:0)+
                                (spike_history_mem[23]?6:0)+
                         
                         // if you comment out above this line, it is Exponential STDP curve with equal area for Pos and Neg
                         
                                (spike_history_mem[22]?7:0)+
                                (spike_history_mem[21]?7:0)+
                               (spike_history_mem[20]?8:0)+
                                (spike_history_mem[19]?8:0)+
                                (spike_history_mem[18]?9:0)+
                                (spike_history_mem[17]?10:0)+
                                (spike_history_mem[16]?10:0)+
                                (spike_history_mem[15]?11:0)+
                                (spike_history_mem[14]?12:0)+
                                (spike_history_mem[13]?13:0)+
                                (spike_history_mem[12]?14:0)+
                                (spike_history_mem[11]?15:0)+
                                (spike_history_mem[10]?16:0)+
                                (spike_history_mem[9]?18:0)+
                                (spike_history_mem[8]?19:0)+
                                (spike_history_mem[7]?20:0)+
                                (spike_history_mem[6]?22:0)+
                                (spike_history_mem[5]?24:0)+
                                (spike_history_mem[4]?25:0)+
                                (spike_history_mem[3]?27:0)+
                                (spike_history_mem[2]?29:0)+
                                (spike_history_mem[1]?31:0)
                                 ) : 0;


////(Nearest neighbor) exponential STDP curve (parameters from Izhekevich & Desai 2003 ) 
//assign delta_w_ltp_pre = postsynaptic_spike ? 
//                                (spike_history_mem[1]?31:
//                                spike_history_mem[2]?29:
//                                spike_history_mem[3]?27:
//                                spike_history_mem[4]?25:
//                                spike_history_mem[5]?24:
//                                spike_history_mem[6]?22:
//                                spike_history_mem[7]?20:
//                                spike_history_mem[8]?19:
//                                spike_history_mem[9]?18:
//                                spike_history_mem[10]?16:
//                                spike_history_mem[11]?15:
//                                spike_history_mem[12]?14:
//                                spike_history_mem[13]?13:
//                                spike_history_mem[14]?12:
//                                spike_history_mem[15]?11:
//                                spike_history_mem[16]?10:
//                                spike_history_mem[17]?10:
//                                spike_history_mem[18]?9:
//                                spike_history_mem[19]?8:
//                                spike_history_mem[20]?8:
//                                spike_history_mem[21]?7:
//                                spike_history_mem[22]?7:
//                                spike_history_mem[23]?6:
//                                spike_history_mem[24]?6:
//                                spike_history_mem[25]?5:
//                                spike_history_mem[26]?5:
//                                spike_history_mem[27]?4:
//                                spike_history_mem[28]?4:
//                                spike_history_mem[29]?4:
//                                spike_history_mem[30]? 4: 
//                                spike_history_mem[31]? 3:0):0;




wire [31:0] ps_spike_history_mem;
wire [31:0] ps_spike_history_mem_in;


assign ps_spike_history_mem_in = first_pass ? 0 : {ps_spike_history_mem[30:0], postsynaptic_spike};

wire [31:0] ps_spike_history_mem_64ms;
wire [31:0] ps_spike_history_mem_in_64ms;

assign ps_spike_history_mem_in_64ms = first_pass ? 0 : {ps_spike_history_mem_64ms[30:0], ps_spike_history_mem[31]};



wire [31:0] delta_w_ltd;

//assign delta_w_ltd = spike ? ((ps_spike_history_mem == 32'd0) ? 0 : ltd) : 0 ; // make a LookupTable STDP curve
wire [31:0] delta_w_ltd_pre;
//assign delta_w_ltd = delta_w_ltd_pre*ltd_scale;
unsigned_mult32 multltd(.out(delta_w_ltd), .a(delta_w_ltd_pre), .b(ltd_scale));

// linear STDP curve 
//assign delta_w_ltd_pre = spike ? 
//                                ((ps_spike_history_mem[31]? 1:0)+
//                                (ps_spike_history_mem[30]? 2 :0) +
//                                (ps_spike_history_mem[29]?3:0)+
//                                (ps_spike_history_mem[28]?4:0)+
//                                (ps_spike_history_mem[27]?5:0)+
//                                (ps_spike_history_mem[26]?6:0)+
//                                (ps_spike_history_mem[25]?7:0)+
//                                (ps_spike_history_mem[24]?8:0)+
//                                (ps_spike_history_mem[23]?9:0)+
//                                (ps_spike_history_mem[22]?10:0)+
//                                (ps_spike_history_mem[21]?11:0)+
//                                (ps_spike_history_mem[20]?12:0)+
//                                (ps_spike_history_mem[19]?13:0)+
//                                (ps_spike_history_mem[18]?14:0)+
//                                (ps_spike_history_mem[17]?15:0)+
//                                (ps_spike_history_mem[16]?16:0)+
//                                (ps_spike_history_mem[15]?17:0)+
//                                (ps_spike_history_mem[14]?18:0)+
//                                (ps_spike_history_mem[13]?19:0)+
//                                (ps_spike_history_mem[12]?20:0)+
//                                (ps_spike_history_mem[11]?21:0)+
//                                (ps_spike_history_mem[10]?22:0)+
//                                (ps_spike_history_mem[9]?23:0)+
//                                (ps_spike_history_mem[8]?24:0)+
//                                (ps_spike_history_mem[7]?25:0)+
//                                (ps_spike_history_mem[6]?26:0)+
//                                (ps_spike_history_mem[5]?27:0)+
//                                (ps_spike_history_mem[4]?28:0)+
//                                (ps_spike_history_mem[3]?29:0)+
//                                (ps_spike_history_mem[2]?30:0)+
//                                (ps_spike_history_mem[1]?31:0)) : 0;

                              
// exponential STDP curve (parameters from Izhekevich & Desai 2003)                               
assign delta_w_ltd_pre = spike ? 
                                (
                                //64ms and less
                                (ps_spike_history_mem_64ms[31]?3:0)+
                                (ps_spike_history_mem_64ms[30]?3:0) +
                                (ps_spike_history_mem_64ms[29]?3:0)+
                                (ps_spike_history_mem_64ms[28]?4:0)+
                                (ps_spike_history_mem_64ms[27]?4:0)+
                                (ps_spike_history_mem_64ms[26]?4:0)+
                                (ps_spike_history_mem_64ms[25]?4:0)+
                                (ps_spike_history_mem_64ms[24]?4:0)+
                                (ps_spike_history_mem_64ms[23]?4:0)+
                                (ps_spike_history_mem_64ms[22]?4:0)+
                                (ps_spike_history_mem_64ms[21]?4:0)+
                                (ps_spike_history_mem_64ms[20]?4:0)+
                                (ps_spike_history_mem_64ms[19]?5:0)+
                                (ps_spike_history_mem_64ms[18]?5:0)+
                                (ps_spike_history_mem_64ms[17]?5:0)+
                                (ps_spike_history_mem_64ms[16]?5:0)+
                                (ps_spike_history_mem_64ms[15]?5:0)+
                                (ps_spike_history_mem_64ms[14]?5:0)+
                                (ps_spike_history_mem_64ms[13]?5:0)+
                                (ps_spike_history_mem_64ms[12]?5:0)+
                                (ps_spike_history_mem_64ms[11]?6:0)+
                                (ps_spike_history_mem_64ms[10]?6:0)+
                                (ps_spike_history_mem_64ms[9]?6:0)+
                                (ps_spike_history_mem_64ms[8]?6:0)+
                                (ps_spike_history_mem_64ms[7]?6:0)+
                                (ps_spike_history_mem_64ms[6]?6:0)+
                                (ps_spike_history_mem_64ms[5]?7:0)+
                                (ps_spike_history_mem_64ms[4]?7:0)+
                                (ps_spike_history_mem_64ms[3]?7:0)+
                                (ps_spike_history_mem_64ms[2]?7:0)+
                                (ps_spike_history_mem_64ms[1]?7:0) +
                                
                                
                                // 32ms and less
                                (ps_spike_history_mem[31]?7:0)+
                                (ps_spike_history_mem[30]?8:0) +
                                (ps_spike_history_mem[29]?8:0)+
                                (ps_spike_history_mem[28]?8:0)+
                                (ps_spike_history_mem[27]?8:0)+
                                (ps_spike_history_mem[26]?8:0)+
                                (ps_spike_history_mem[25]?9:0)+
                                (ps_spike_history_mem[24]?9:0)+
                                (ps_spike_history_mem[23]?9:0)+
                                (ps_spike_history_mem[22]?9:0)+
                                (ps_spike_history_mem[21]?10:0)+
                                (ps_spike_history_mem[20]?10:0)+
                                (ps_spike_history_mem[19]?10:0)+
                                (ps_spike_history_mem[18]?11:0)+
                                (ps_spike_history_mem[17]?11:0)+
                                (ps_spike_history_mem[16]?11:0)+
                                (ps_spike_history_mem[15]?11:0)+
                                (ps_spike_history_mem[14]?12:0)+
                                (ps_spike_history_mem[13]?12:0)+
                                (ps_spike_history_mem[12]?12:0)+
                                (ps_spike_history_mem[11]?13:0)+
                                (ps_spike_history_mem[10]?13:0)+
                                (ps_spike_history_mem[9]?14:0)+
                                (ps_spike_history_mem[8]?14:0)+
                                (ps_spike_history_mem[7]?14:0)+
                                (ps_spike_history_mem[6]?15:0)+
                                (ps_spike_history_mem[5]?15:0)+
                                (ps_spike_history_mem[4]?16:0)+
                                (ps_spike_history_mem[3]?16:0)+
                                (ps_spike_history_mem[2]?17:0)+
                                (ps_spike_history_mem[1]?17:0)
                                ) : 0;                                
                                

                              
// (Nearest neighbor) exponential STDP curve (parameters from Izhekevich & Desai 2003)                               
//assign delta_w_ltd_pre = spike ? 
//                                (ps_spike_history_mem[1]?17:
//                                ps_spike_history_mem[2]?17:
//                                ps_spike_history_mem[3]?16:
//                                ps_spike_history_mem[4]?16:
//                                ps_spike_history_mem[5]?15:
//                                ps_spike_history_mem[6]?15:
//                                ps_spike_history_mem[7]?14:
//                                ps_spike_history_mem[8]?14:
//                                ps_spike_history_mem[9]?14:
//                                ps_spike_history_mem[10]?13:
//                                ps_spike_history_mem[11]?13:
//                                ps_spike_history_mem[12]?12:
//                                ps_spike_history_mem[13]?12:
//                                ps_spike_history_mem[14]?12:
//                                ps_spike_history_mem[15]?11:
//                                ps_spike_history_mem[16]?11:
//                                ps_spike_history_mem[17]?11:
//                                ps_spike_history_mem[18]?11:
//                                ps_spike_history_mem[19]?10:
//                                ps_spike_history_mem[20]?10:
//                                ps_spike_history_mem[21]?10:
//                                ps_spike_history_mem[22]?9:
//                                ps_spike_history_mem[23]?9:
//                                ps_spike_history_mem[24]?9:
//                                ps_spike_history_mem[25]?9:
//                                ps_spike_history_mem[26]?8:
//                                ps_spike_history_mem[27]?8:
//                                ps_spike_history_mem[28]?8:
//                                ps_spike_history_mem[29]?8:
//                                ps_spike_history_mem[30]?8:
//                                ps_spike_history_mem[31]?7:0):0;
//                                
                                
                     
                               
                            
                        
wire [31:0] random_out;
wire [31:0] synapticW_decay;
wire [31:0] synapticW_change;

//assign synapticW_decay = (random_out <= p_delta) ? synapticW_mem >>> 12 : 0; // possion delay? 
 

 
    rng decay_rng(
            .clk1(clk),
            .clk2(clk),
            .reset(reset),
            .out(random_out),
            
            .lfsr(),
            .casr()
    );
   wire [31:0] random_out_cut;
   assign random_out_cut = {12'b0,random_out[19:0]};
   // random chance for synapticW decay 
   assign synapticW_decay = (random_out_cut < p_delta) ? synapticW_mem >>> 12 : 0; // possion delay? 
 
   /// random chance for synapticW change by STDP 
   assign synapticW_change = (random_out_cut < p_growth) ? delta_w_ltp - delta_w_ltd : 0; 
 
 
 
    
wire [31:0] synapticW_mem;
wire [31:0] synapticW_mem_in;
wire [31:0] synapticW_stdp_decay;

wire [31:0] synapticW_stdp;
wire [31:0] lut_out32_F0;
assign lut_out32_F0 = {27'b0, lut_out}; 
//wire [31:0] synapticW_bcm;
//reg [31:0] synapticW_bcm;

//assign synapticW_mem_in = first_pass ? 32'd10240 : synapticW_mem+delta_w+delta_w_ltd-synapticW_decay;
//assign synapticW_stdp = first_pass ? 32'd10240 : synapticW_mem+delta_w+delta_w_ltd-synapticW_decay;
//assign synapticW_stdp = first_pass ? base_strength : synapticW_mem+delta_w-delta_w_ltd-synapticW_decay;  

//assign synapticW_stdp = first_pass ? base_strength : synapticW_mem - (synapticW_mem >>> 12) + delta_w_ltp - delta_w_ltd; //-synapticW strength_decay; // small decay. modified by eric
//assign synapticW_stdp = first_pass ? base_strength :  (synapticW_mem <= 4096)? synapticW_mem-1+ delta_w_ltp - delta_w_ltd:   synapticW_mem - (synapticW_mem >>> 12) + delta_w_ltp - delta_w_ltd; //-synapticW strength_decay; // small decay. 060614

// Zero synapticW decay. (lambda = 0)
//assign synapticW_stdp = first_pass ? base_strength : synapticW_mem  + delta_w_ltp - delta_w_ltd; //-synapticW strength_decay; // No decay

//synapticW decay selection option 0: no decay, 1: yes decay.
assign synapticW_stdp = first_pass ? base_strength : (i_synaptic_decay)? synapticW_mem - synapticW_decay + synapticW_change:  synapticW_mem  + synapticW_change;//-synaptic strength_decay; // No decay


//assign synapticW_mem_in = synapticW_mem;

//assign synapticW_mem_in = (synapticW_stdp >= base_strength)? synapticW_stdp: base_strength;  // set minimum synaptic strength
// Place upper cap in synaptic weight in case needed. 
assign synapticW_mem_in =(synapticW_stdp <= 32'd5120)? 32'd5120 :(synapticW_stdp >= i_weightUpperCap)?i_weightUpperCap: synapticW_stdp; ////minimum strenth =5120 
//assign synapticW_mem_in = synapticW_stdp;


// STATE MACHINE //////////////////////////////////////////////////////////////////////////////////////
    
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
            spike <= 0;
            postsynaptic_spike <= 0;
            neuron_index<=0;
        end else begin
            case(state)
                0:  begin
                    neuron_index <= neuron_index + 1;  
                    write <= 0;
                    state <= 1;
                    spike <= spike;   //Eric: putting spike_in here doesn't change much. 
                    postsynaptic_spike <= postsynaptic_spike; //Eric: putting postsynapti_spike_in here doesn't change much. 
                    end
                1:  begin
                    neuron_index <= neuron_index; 
                    write <= 1;
                    state <= 0;
                    spike <= spike_in; 
                    postsynaptic_spike <= postsynaptic_spike_in; 
                    end
             endcase
        end
    end
    
    
//    // purpose: synapticW added to current for 1 neuron clk cycle only. 
//    reg spike_pos_edge;
//    always @ (posedge clk or posedge reset)
//    begin
//        if (reset) begin
//            spike_pos_edge <= spike;
//        end else if (spike) begin
//            spike_pos_edge <= 0;
//        end
//    end
            
        
    
    
    // PERFORM READ/COMPUTE/WRITE CYCLE ON RAM CONTENTS


wire reset_bar;
assign reset_bar = ~reset;
always @ (negedge clk or negedge reset_bar) begin
    if (~reset_bar) begin
       first_pass <= 1;
       I_out <= 0;
       each_I <= 0;
       synaptic_strength <= 0;
       //lut_out32 <= 0;
    end else begin
        if (state) begin
            each_I <= i_mem_in;
            if (neuron_index == 7'h7f) begin  //every 128 neuron_clk
                first_pass <= 0;
                I_out <= i_mem_in;
                synaptic_strength <= synapticW_mem_in; // 
               // lut_out32 <= lut_out32_F0;
            end
        end
    end
end

    
    neuron_ram i_ram (
  .clka(~clk), // input clka
  .wea(write), // input [0 : 0] wea
  .addra(neuron_index), // input [6 : 0] addra
  .dina(i_mem_in), // input [31 : 0] dina
  .douta(i_mem), // output [31 : 0] douta
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
    
     neuron_ram ps_spike_history_ram (
  .clka(~clk), // input clka
  .wea(write), // input [0 : 0] wea
  .addra(neuron_index), // input [6 : 0] addra
  .dina(ps_spike_history_mem_in), // input [31 : 0] dina
  .douta(ps_spike_history_mem), // output [31 : 0] douta
  .clkb(clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(7'd0), // input [6 : 0] addrb
  .dinb(32'd0), // input [31 : 0] dinb
  .doutb() // output [31 : 0] doutb
    );

    neuron_ram synapticW_ram (
  .clka(~clk), // input clka
  .wea(write), // input [0 : 0] wea
  .addra(neuron_index), // input [6 : 0] addra
  .dina(synapticW_mem_in), // input [31 : 0] dina
  .douta(synapticW_mem), // output [31 : 0] douta
  .clkb(clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(7'd0), // input [6 : 0] addrb
  .dinb(32'd0), // input [31 : 0] dinb
  .doutb() // output [31 : 0] doutb
    );
    
     neuron_ram spike_history_ram_64ms (
  .clka(~clk), // input clka
  .wea(write), // input [0 : 0] wea
  .addra(neuron_index), // input [6 : 0] addra
  .dina(spike_history_mem_in_64ms), // input [31 : 0] dina
  .douta(spike_history_mem_64ms), // output [31 : 0] douta
  .clkb(clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(7'd0), // input [6 : 0] addrb
  .dinb(32'd0), // input [31 : 0] dinb
  .doutb() // output [31 : 0] doutb
    );
    
     neuron_ram ps_spike_history_ram_64ms (
  .clka(~clk), // input clka
  .wea(write), // input [0 : 0] wea
  .addra(neuron_index), // input [6 : 0] addra
  .dina(ps_spike_history_mem_in_64ms), // input [31 : 0] dina
  .douta(ps_spike_history_mem_64ms), // output [31 : 0] douta
  .clkb(clk), // input clkb
  .web(1'b0), // input [0 : 0] web
  .addrb(7'd0), // input [6 : 0] addrb
  .dinb(32'd0), // input [31 : 0] dinb
  .doutb() // output [31 : 0] doutb
    );
    
    
    // STDP LUT (not used)
    wire [4:0] lut_out;
    wire [4:0] lut2_index5;
    assign lut2_index5 = lut2_index[4:0];
   blk_mem_gen_LUT2 stdp_manual(
  .clka(~clk),  //input clka;
  .addra(lut2_index5), //input [4 : 0] addra;
  .douta(lut_out)  //output [4 : 0] douta;
);





    
endmodule


