module gen_clk(rawclk, half_cnt, clk_out1, clk_out2, clk_out3, int_neuron_cnt_out);
    input rawclk;
    input [31:0] half_cnt;
    output reg clk_out1, clk_out2, clk_out3;
    output [31:0] int_neuron_cnt_out;

    reg [31:0] delay_cnt;

    always @ (posedge rawclk) begin
        if (delay_cnt < half_cnt) begin
            clk_out1 <= clk_out1;
            delay_cnt <= delay_cnt + 1;
        end
        else begin
            clk_out1 <= ~clk_out1;
            delay_cnt <= 0;
        end
    end

	reg [7:0] neuronCounter;
	wire [6:0] neuronIndex;

	assign neuronIndex = neuronCounter[7:1];

	always @ (posedge clk_out1)
	begin	
		neuronCounter <= neuronCounter + 1'b1;
        clk_out2 <= {neuronCounter == 0};
        //clk_out3 <= {(neuronIndex == 0) || (neuronIndex == 7'd43) ||
        //            (neuronIndex == 7'd86)};
        clk_out3 <= {(neuronIndex == 1) || (neuronIndex == 7'd31) ||
                    (neuronIndex == 7'd62) || (neuronIndex == 7'd93)};
	end

    assign int_neuron_cnt_out = neuronCounter;
endmodule
