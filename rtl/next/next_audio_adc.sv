// MiSTer ADC input to signed mono PCM in the core's clock domain.
// Use LTC2308 channel 0 (the audio/tape input), eight samples per NeXT
// codec sample. Remove the jack's DC bias and average each group of eight.
module next_audio_adc #(
	parameter CLK_REAL_HZ = 28000000
)(
	input clk, reset,
	inout [3:0] ADC_BUS,
	output reg signed [15:0] audio_in
);
wire [11:0] raw;
wire raw_sync;
ltc2308 #(.NUM_CH(1), .ADC_RATE(8012*8), .CLK_RATE(CLK_REAL_HZ)) adc
(
	.clk(clk), .reset(reset), .ADC_BUS(ADC_BUS),
	.dout(raw), .dout_sync(raw_sync)
);
reg sync_d;
reg [1:0] warmup;
reg have_bias;
reg signed [24:0] bias;
wire signed [24:0] raw_fixed = $signed({1'b0, raw, 12'd0});
wire signed [24:0] bias_error = raw_fixed - bias;
reg [2:0] count;
reg [14:0] total;
wire [14:0] sum = total + {3'd0, raw};
wire signed [12:0] centered = $signed({1'b0, sum[14:3]}) -
                              $signed({1'b0, bias[23:12]});
always @(posedge clk) begin
	if (reset) begin
		sync_d <= 0; warmup <= 0; have_bias <= 0;
		bias <= 0; count <= 0; total <= 0; audio_in <= 0;
	end else begin
		sync_d <= raw_sync;
		if (sync_d != raw_sync) begin
			// dout_sync marks the next conversion; raw holds the previous
			// result. Discard the startup pipeline before using a sample.
			if (warmup != 2) warmup <= warmup + 1'd1;
			else if (!have_bias) begin
				bias <= raw_fixed;
				have_bias <= 1;
			end else begin
				bias <= bias + (bias_error >>> 10);
				total <= sum;
				count <= count + 1'd1;
				if (count == 7) begin
					total <= 0;
					// Eight times the centered 12-bit amplitude fits signed
					// 16 bits even when the DC level is near an ADC rail.
					audio_in <= {centered, 3'b000};
				end
			end
		end
	end
end
endmodule
