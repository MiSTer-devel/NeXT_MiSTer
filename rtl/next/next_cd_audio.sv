//============================================================================
//  CD-ROM audio front end (after MacQuadra800_MiSTer rtl/cd_audio.sv)
//
//  The playhead lives on the HPS: Main_MiSTer support/next/next_cdrom_play.cpp
//  executes every transport CDB next_scsi forwards through its command block
//  and serves "the next frame at the playhead, volume applied" from the
//  next-frame window 0x7C000000 of the CD-ROM slot: one 5-block (2560 byte)
//  read = 2352 bytes of 16-bit LE stereo PCM and a pad at 2352..2357
//  {state, have, flush generation}.  The HPS playhead advances per fetch,
//  so fetched == played.  What runs here is the part that has to run at
//  44.1 kHz:
//
//    FETCH  - fill the free half of a two-frame ping-pong while the HPS
//             says "playing"; a forwarded transport command (fwd_stb)
//             starts a fetch whose pad then reports the real state; a
//             generation change drops the stale half.
//    SAMPLE - the 44.1 kHz fractional cadence with linear interpolation,
//             588 stereo samples per frame.
//
//  The CD-ROM slot is shared with next_scsi: this engine asks for the
//  channel (ch_req) and starts only after a clock in which the target was
//  idle; next_scsi starts nothing while ch_req or ch_act is up.
//============================================================================

module next_cd_audio #(
	parameter CLK_HZ = 32'd28_000_000
)(
	input             clk,
	input             rst,

	input             mounted,     // a CD image is mounted
	input             fwd_stb,     // next_scsi forwarded a transport command
	input             stop_stb,    // bus reset / data read: drop the buffers

	// the CD-ROM slot, shared with next_scsi
	input             scsi_busy,
	output reg        ch_req,      // wants the channel next clock
	output reg        ch_act,      // owns the channel (request/ack window)
	output reg        io_rd,
	output     [31:0] io_lba,
	output      [5:0] io_blk_cnt,
	input             io_ack,
	input      [12:0] sd_buff_addr,
	input       [7:0] sd_buff_dout,
	input             sd_buff_wr,

	output reg signed [15:0] snd_l,
	output reg signed [15:0] snd_r
);

localparam [31:0] FRAME_BLK = 32'h7C00_0000;
localparam [23:0] HOLD_CLKS = CLK_HZ / 32'd75;

assign io_lba     = FRAME_BLK;
assign io_blk_cnt = 6'd4;

// frame ping-pong: 2 x 1176 words of 16 bits, one frame per half, filled
// byte-wise as the 5-block read streams past (pad bytes read on the fly)
reg         fr_cap;
reg         fr_half_w;
reg  [7:0]  lo_byte;
reg  [11:0] frame_ra;
wire [15:0] frame_q;
wire [10:0] pword = sd_buff_addr[11:1];
wire        pword_wr = fr_cap && sd_buff_wr && sd_buff_addr[0] && (sd_buff_addr < 13'd2352);
next_cd_sdp #(.DW(16), .AW(12)) frame_ram (
	.clock(clk),
	.waddr({fr_half_w, pword}), .wdata({sd_buff_dout, lo_byte}),
	.wr(pword_wr),
	.raddr(frame_ra), .q(frame_q)
);
always @(posedge clk) if (fr_cap && sd_buff_wr && !sd_buff_addr[0]) lo_byte <= sd_buff_dout;

reg old_ack;
always @(posedge clk) old_ack <= io_ack;
wire ack_fall = old_ack & ~io_ack;

// playback state as the HPS last reported it
reg  [7:0] ast;                        // 0 play, 1 paused, 3 end, 5 idle
wire       playing = (ast == 8'd0);
reg  [1:0] fr_valid;
wire       run = playing || ((ast == 8'd3) && (|fr_valid));
wire       frame_done;
reg        frame_done_half_r;

//----------------------------------------------------------------------------
// FETCH
//----------------------------------------------------------------------------
localparam [1:0] F_IDLE = 2'd0, F_REQ = 2'd1, F_WAIT = 2'd2;
reg  [1:0] fst;
reg  [7:0] pad_ast;
reg        pad_have;
reg [31:0] pad_gen, gen_r;
reg [23:0] hold;
reg        flush;
reg        flush_half;

always @(posedge clk) begin
	if (rst) begin
		fst <= F_IDLE; fr_cap <= 0; fr_valid <= 2'b00; fr_half_w <= 0;
		io_rd <= 0; ch_req <= 0; ch_act <= 0;
		ast <= 8'd5; gen_r <= 0; pad_ast <= 8'd5; pad_have <= 0; pad_gen <= 0;
		hold <= 0; flush <= 0; flush_half <= 0;
	end else begin
		flush <= 1'b0;
		if (hold != 0) hold <= hold - 1'b1;

		// the pad as it streams past
		if (fr_cap && sd_buff_wr) begin
			case (sd_buff_addr)
			13'd2352: pad_ast       <= sd_buff_dout;
			13'd2353: pad_have      <= sd_buff_dout[0];
			13'd2354: pad_gen[7:0]  <= sd_buff_dout;
			13'd2355: pad_gen[15:8] <= sd_buff_dout;
			13'd2356: pad_gen[23:16]<= sd_buff_dout;
			13'd2357: pad_gen[31:24]<= sd_buff_dout;
			default: ;
			endcase
		end

		if (frame_done) fr_valid[frame_done_half_r] <= 1'b0;

		case (fst)
		F_IDLE: begin
			fr_cap <= 1'b0;
			ch_req <= 1'b0;
			if (playing && mounted && !(&fr_valid) && hold == 0) begin
				fr_half_w <= fr_valid[0] ? 1'b1 : 1'b0;
				fst <= F_REQ;
			end
		end
		F_REQ:
			if (!playing || !mounted) begin ch_req <= 1'b0; fst <= F_IDLE; end
			else if (scsi_busy) ch_req <= 1'b0;
			else if (!ch_req) ch_req <= 1'b1;   // announce, then start a clock later
			else begin
				io_rd  <= 1'b1;
				ch_act <= 1'b1;
				fr_cap <= 1'b1;
				fst <= F_WAIT;
			end
		F_WAIT: begin
			if (io_ack) io_rd <= 1'b0;
			if (ack_fall && ch_act) begin
				ch_act <= 1'b0; ch_req <= 1'b0;
				fr_cap <= 1'b0;
				ast <= pad_ast;
				if (pad_have) begin
					if (pad_gen != gen_r) begin
						gen_r      <= pad_gen;
						fr_valid   <= fr_half_w ? 2'b10 : 2'b01;
						flush      <= 1'b1;
						flush_half <= fr_half_w;
					end
					else fr_valid[fr_half_w] <= 1'b1;
				end
				else hold <= HOLD_CLKS;
				fst <= F_IDLE;
			end
		end
		default: fst <= F_IDLE;
		endcase

		// a forwarded transport command: assume playing and ask for a frame,
		// whose pad then carries the HPS's actual state
		if (fwd_stb) begin
			ast <= 8'd0;
			hold <= 0;
			fr_valid <= 2'b00;
			flush <= 1'b1; flush_half <= 1'b0;
		end

		if (stop_stb || !mounted) begin
			if (ast != 8'd5 || (|fr_valid)) begin
				ast <= 8'd5; fr_valid <= 2'b00;
				flush <= 1'b1; flush_half <= 1'b0;
			end
		end
	end
end

//----------------------------------------------------------------------------
// SAMPLE: 44.1 kHz cadence, a frame = 588 stereo samples = 1176 words
//----------------------------------------------------------------------------
reg [31:0] acc;
reg [10:0] widx;
reg  [1:0] sph;
reg        frame_done_r;
reg        fr_half_r;
assign frame_done = frame_done_r;

reg signed [15:0] snd_l_t, snd_r_t;
reg signed [15:0] snd_l_p, snd_r_p;
reg        [16:0] frac16;              // Q16 segment phase; 65536 * 44100 / CLK_HZ per clock

always @(posedge clk) begin
	if (rst) begin
		acc <= 0; widx <= 0; sph <= 0; frame_done_r <= 0; frame_done_half_r <= 0;
		snd_l_t <= 0; snd_r_t <= 0; snd_l_p <= 0; snd_r_p <= 0;
		frac16 <= 0; fr_half_r <= 0; frame_ra <= 0;
	end else begin
		frame_done_r <= 1'b0;
		if (!frac16[16]) frac16 <= frac16 + 17'd103;
		if (flush) begin
			widx <= 0; acc <= 0; sph <= 0; fr_half_r <= flush_half;
		end
		else if (run && fr_valid[fr_half_r]) begin
			if (sph == 2'd0) begin
				acc <= acc + 32'd44_100;
				if (acc >= (CLK_HZ - 32'd44_100)) begin
					acc <= acc + 32'd44_100 - CLK_HZ;
					frame_ra <= {fr_half_r, widx};
					sph <= 2'd1;
				end
			end else begin
				sph <= sph + 2'd1;
				case (sph)
				2'd1: frame_ra <= {fr_half_r, widx + 11'd1};
				2'd2: begin snd_l_p <= snd_l_t; snd_l_t <= frame_q; end
				default: begin
					snd_r_p <= snd_r_t; snd_r_t <= frame_q;
					frac16 <= 0; sph <= 2'd0;
					if (widx == 11'd1174) begin
						widx <= 0;
						fr_half_r <= ~fr_half_r;
						frame_done_r <= 1'b1;
						frame_done_half_r <= fr_half_r;
					end else widx <= widx + 11'd2;
				end
				endcase
			end
		end
		else if (!run) begin
			snd_l_t <= 0; snd_r_t <= 0; snd_l_p <= 0; snd_r_p <= 0;
			acc <= 0;
		end
	end
end

// interpolated output, committed every 8th clock so the framework's
// stability filter accepts each step
wire        [15:0] seg_f  = frac16[16] ? 16'hFFFF : frac16[15:0];
wire signed [16:0] seg_dl = {snd_l_t[15], snd_l_t} - {snd_l_p[15], snd_l_p};
wire signed [16:0] seg_dr = {snd_r_t[15], snd_r_t} - {snd_r_p[15], snd_r_p};
wire signed [33:0] seg_ml = seg_dl * $signed({1'b0, seg_f});
wire signed [33:0] seg_mr = seg_dr * $signed({1'b0, seg_f});
wire signed [16:0] sum_l  = {snd_l_p[15], snd_l_p} + $signed(seg_ml[32:16]);
wire signed [16:0] sum_r  = {snd_r_p[15], snd_r_p} + $signed(seg_mr[32:16]);
reg  [2:0] odiv;
always @(posedge clk) begin
	if (rst || !run) begin
		snd_l <= 0; snd_r <= 0; odiv <= 0;
	end else begin
		odiv <= odiv + 3'd1;
		if (odiv == 3'd0) begin
			snd_l <= sum_l[15:0];
			snd_r <= sum_r[15:0];
		end
	end
end

endmodule

// simple dual port RAM for the frame buffer (one write, one registered read)
module next_cd_sdp #(parameter DW = 16, AW = 12)
(
	input           clock,
	input  [AW-1:0] waddr,
	input  [DW-1:0] wdata,
	input           wr,
	input  [AW-1:0] raddr,
	output reg [DW-1:0] q
);
(* ramstyle = "M10K,no_rw_check" *) reg [DW-1:0] ram [0:(1<<AW)-1];
always @(posedge clock) if (wr) ram[waddr] <= wdata;
always @(posedge clock) q <= ram[raddr];
endmodule
