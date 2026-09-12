// Sound-input DMA, channel 0x80. The codec supplies four 8-bit mu-law
// samples per memory word at 8012 samples/sec (Previous snd.c/kms.c).
// Keep ENABLE/COMPLETE real even when the codec is stopped: Mach's
// model-0x139 dma_abort polls for nonzero CSR before issuing RESET.
module next_snd_in #(
	parameter CLK_REAL_HZ = 100000000
)(
	input clk, reset,
	input active, clear_status,
	input signed [15:0] audio_in,
	output reg request_status, overrun,
	input sel_csr, sel_sptr, sel_ptr, sel_ini,
	input [3:0] addr,
	input we,
	input [1:0] be,
	input [15:0] wdata,
	output [15:0] rdata,
	output int_dma,
	output reg m_req,
	output m_we,
	output reg [29:0] m_addr,
	output [3:0] m_be,
	output reg [31:0] m_din,
	input m_ack, m_err
);
reg [7:0] csr;
reg [31:0] next_ptr, limit_ptr, start_ptr, stop_ptr;
reg [31:0] saved [0:3];
reg [31:0] sample_acc;
reg [1:0] sample_count;
reg [23:0] samples;
reg cancelled;
// Same-clock completion must survive an acknowledgement of an older one.
reg completion_event;

wire [32:0] sample_sum = {1'b0, sample_acc} + 33'd8012;
wire sample_tick = sample_sum >= CLK_REAL_HZ;
wire [7:0] csr_cmd = (be[1] ? wdata[15:8] : 8'd0) |
                     (be[0] ? wdata[7:0] : 8'd0);
wire csr_write = sel_csr && we && !addr[1];
wire csr_reset = csr_write && csr_cmd[4];
wire bad_window = |next_ptr[1:0] || |limit_ptr[1:0] || next_ptr > limit_ptr;
wire [31:0] pointer_q = (addr[3:2] == 0) ? next_ptr :
                        (addr[3:2] == 1) ? limit_ptr :
                        (addr[3:2] == 2) ? start_ptr : stop_ptr;
wire [31:0] read_q = sel_sptr ? saved[addr[3:2]] : sel_ini ? next_ptr : pointer_q;
assign rdata = sel_csr ? (addr[1] ? 16'd0 : {csr, 8'd0}) :
               (addr[1] ? read_q[15:0] : read_q[31:16]);
assign int_dma = csr[3];
assign m_we = 1'b1;
assign m_be = 4'hf;

// G.711 mu-law, matching Previous's snd_make_ulaw (BIAS=132,
// CLIP=32635). Widen before negation so -32768 clips correctly.
function automatic [7:0] encode_ulaw;
	input signed [15:0] pcm;
	reg [16:0] magnitude;
	reg [2:0] exponent;
	reg [3:0] mantissa;
	integer bitpos;
	begin
		magnitude = pcm[15] ? -{pcm[15], pcm} : {1'b0, pcm};
		if (magnitude > 17'd32635) magnitude = 17'd32635;
		magnitude = magnitude + 17'd132;
		exponent = 0;
		for (bitpos=7; bitpos<15; bitpos=bitpos+1)
			if (magnitude[bitpos]) exponent = 3'(bitpos-7);
		mantissa = 4'(magnitude >> ({2'd0, exponent} + 5'd3));
		encode_ulaw = ~{pcm[15], exponent, mantissa};
	end
endfunction

function automatic [31:0] merge_word;
	input [31:0] old;
	input low_half;
	input [1:0] lanes;
	input [15:0] data;
	begin
		merge_word = old;
		if (low_half) begin
			if (lanes[1]) merge_word[15:8] = data[15:8];
			if (lanes[0]) merge_word[7:0] = data[7:0];
		end else begin
			if (lanes[1]) merge_word[31:24] = data[15:8];
			if (lanes[0]) merge_word[23:16] = data[7:0];
		end
	end
endfunction

task automatic complete_segment;
	begin
		completion_event = 1;
		csr[3] <= 1;
		if (csr[1]) begin
			next_ptr <= start_ptr;
			limit_ptr <= stop_ptr;
			csr[1] <= 0;
		end else begin
			csr[0] <= 0;
			if (active) overrun <= 1;
		end
	end
endtask

task automatic bus_exception;
	begin
		completion_event = 1;
		csr[0] <= 0;
		csr[3] <= 1;
		csr[4] <= 1;
	end
endtask

integer i;
always @(posedge clk) begin
	completion_event = 0;
	if (reset) begin
		csr <= 0;
		next_ptr <= 0; limit_ptr <= 0; start_ptr <= 0; stop_ptr <= 0;
		for (i=0; i<4; i=i+1) saved[i] <= 0;
		sample_acc <= 0; sample_count <= 0;
		samples <= 0; m_din <= 0;
		request_status <= 0; overrun <= 0;
		m_req <= 0; m_addr <= 0; cancelled <= 0;
	end else begin
		if (!active) begin
			sample_acc <= 0;
			sample_count <= 0;
		end else begin
			sample_acc <= sample_tick ? sample_sum[31:0] - CLK_REAL_HZ : sample_sum[31:0];
			if (sample_tick) begin
				sample_count <= sample_count + 1'd1;
				samples <= {samples[15:0], encode_ulaw(audio_in)};
				if (sample_count == 3) begin
					request_status <= 1;
					if (!csr[0] || m_req) overrun <= 1;
					else if (!bad_window && next_ptr < limit_ptr && !csr_reset) begin
						m_addr <= next_ptr[31:2];
						m_din <= {samples, encode_ulaw(audio_in)};
						m_req <= 1;
						cancelled <= 0;
					end
				end
			end
		end

		// Keep an outstanding RAM request stable through its response.
		// RESET cancels its bookkeeping, so a late ack cannot resurrect
		// the old completion or overwrite a newly programmed pointer.
		if (m_req && (m_ack || m_err)) begin
			m_req <= 0;
			cancelled <= 0;
			if (!cancelled && !csr_reset) begin
				if (m_err) bus_exception;
				else begin
					next_ptr <= next_ptr + 32'd4;
					saved[1] <= next_ptr + 32'd4;
					if (next_ptr + 32'd4 == limit_ptr) complete_segment;
				end
			end
		end else if (!m_req && csr[0] && !csr_reset) begin
			if (bad_window) bus_exception;
			else if (next_ptr == limit_ptr) complete_segment;
		end

		if (sel_sptr && we)
			saved[addr[3:2]] <= merge_word(saved[addr[3:2]], addr[1], be, wdata);
		if (sel_ptr && we) begin
			case (addr[3:2])
				0: next_ptr <= merge_word(next_ptr, addr[1], be, wdata);
				1: limit_ptr <= merge_word(limit_ptr, addr[1], be, wdata);
				2: start_ptr <= merge_word(start_ptr, addr[1], be, wdata);
				3: stop_ptr <= merge_word(stop_ptr, addr[1], be, wdata);
			endcase
		end
		if (sel_ini && we)
			next_ptr <= merge_word(next_ptr, addr[1], be, wdata);

		if (csr_write) begin
			if (csr_cmd[4]) begin
				csr <= csr & ~8'h0b;
				if (m_req && !m_ack && !m_err) cancelled <= 1;
			end
			if (csr_cmd[5]) sample_count <= 0;
			if (csr_cmd[1]) csr[1] <= 1;
			if (csr_cmd[0]) begin
				if (bad_window || !csr_cmd[2]) bus_exception;
				else csr[0] <= 1;
			end
			// Match the conditional acknowledgement needed by Mach's
			// late refill check; RESET acknowledges a stopped channel.
			if (csr_cmd[3] && (csr[0] || csr_cmd[0]) && !completion_event)
				csr[3] <= 0;
		end
		if (clear_status) begin request_status <= 0; overrun <= 0; end
	end
end
endmodule
