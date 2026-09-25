//============================================================================
//  Main RAM in DDR3 through the MiSTer DDRAM interface
//
//  Serves the 32-bit ram_* port of next_system from the HPS DDR3 at byte
//  base 0x30000000 (the core-usable window).
//
//  A read miss fetches the whole aligned 16-byte line in one 2-beat burst
//  and retains it (line, line_tag, line_valid); the requested word is
//  acknowledged as soon as its beat has landed, and the other words of the
//  line (the rest of a cache fill, the second half of every longword) are
//  served from the copy without a DDR round trip (docs/PERF_PLAN.md stage
//  2).  Writes stay single-beat and update the retained word under the
//  byte enables, so the line stays useful across the write-through stores
//  of a stack frame.  Every writer (CPU, table walker, the DMA channels)
//  reaches memory through this one port, which is the whole coherence
//  story; the ethernet mailbox on the arbiter's port B lives outside the
//  RAM window.
//
//  Byte order: the ram_* port carries big-endian 68k words (bit 31 down
//  to bit 0 = ascending byte address), the DDR3 is little endian, so
//  bytes are swapped within each 32-bit half.  Word k of the line lives
//  at line[127-32k -: 32] (word 0 in [127:96]), the order ap040_cache
//  uses for its m_line_data.
//============================================================================

module next_ddram
(
	input             clk,
	input             reset,

	// ram port (level req, level ack: ack holds until req drops)
	input             ram_req,
	input             ram_we,
	input       [3:0] ram_be,      // [3] = MSB = lowest byte address
	input      [23:0] ram_addr,    // 32-bit word index (64 MB)
	input      [31:0] ram_din,
	output reg [31:0] ram_dout,
	output reg        ram_ack,

	// MiSTer DDRAM interface
	input             DDRAM_BUSY,
	output reg  [7:0] DDRAM_BURSTCNT,
	output reg [28:0] DDRAM_ADDR,
	input      [63:0] DDRAM_DOUT,
	input             DDRAM_DOUT_READY,
	output reg        DDRAM_RD,
	output reg [63:0] DDRAM_DIN,
	output reg  [7:0] DDRAM_BE,
	output reg        DDRAM_WE
);

function [31:0] bswap;
	input [31:0] x;
	bswap = {x[7:0], x[15:8], x[23:16], x[31:24]};
endfunction

wire [3:0] be_rev = {ram_be[0], ram_be[1], ram_be[2], ram_be[3]};

// the retained line
reg [127:0] line;
reg  [21:0] line_tag;
reg         line_valid;
wire        line_hit = line_valid && (line_tag == ram_addr[23:2]);
wire [31:0] line_word = (ram_addr[1:0] == 2'd0) ? line[127:96] :
                        (ram_addr[1:0] == 2'd1) ? line[95:64]  :
                        (ram_addr[1:0] == 2'd2) ? line[63:32]  : line[31:0];

// the burst in flight
reg         busy;       // a line read is out: no new request until its last beat
reg         beat;       // beats landed so far (0 or 1)
reg   [1:0] want;       // the word the requester asked for
reg  [21:0] want_tag;
reg         acked;      // its word has been acknowledged already

wire [31:0] w_lo = bswap(DDRAM_DOUT[31:0]);    // even word of the beat
wire [31:0] w_hi = bswap(DDRAM_DOUT[63:32]);   // odd word

always @(posedge clk) begin
	if (reset) begin
		DDRAM_RD   <= 0;
		DDRAM_WE   <= 0;
		DDRAM_BURSTCNT <= 8'd1;
		ram_ack    <= 0;
		busy       <= 0;
		beat       <= 0;
		acked      <= 0;
		line_valid <= 0;
	end
	else begin
		if (!DDRAM_BUSY) begin
			if (DDRAM_WE) begin
				DDRAM_WE <= 0;
				ram_ack  <= 1;      // write is done once accepted
			end
			if (DDRAM_RD) DDRAM_RD <= 0;
		end

		// the burst's beats: words 0/1 first, then 2/3
		if (busy && DDRAM_DOUT_READY) begin
			if (!beat) begin
				line[127:64] <= {w_lo, w_hi};
				if (!want[1] && !acked) begin
					ram_dout <= want[0] ? w_hi : w_lo;
					ram_ack  <= 1;
					acked    <= 1;
				end
				beat <= 1;
			end
			else begin
				line[63:0] <= {w_lo, w_hi};
				if (want[1] && !acked) begin
					ram_dout <= want[0] ? w_hi : w_lo;
					ram_ack  <= 1;
				end
				line_tag   <= want_tag;
				line_valid <= 1;
				busy       <= 0;
				beat       <= 0;
				acked      <= 0;
			end
		end

		if (!ram_req) ram_ack <= 0;
		else if (!ram_ack && !busy && !DDRAM_RD && !DDRAM_WE) begin
			if (ram_we) begin
				DDRAM_ADDR     <= {5'b00110, 1'b0, ram_addr[23:1]};
				DDRAM_BURSTCNT <= 8'd1;
				DDRAM_DIN      <= {2{bswap(ram_din)}};
				DDRAM_BE       <= ram_addr[0] ? {be_rev, 4'b0000} : {4'b0000, be_rev};
				DDRAM_WE       <= 1;
				// keep the retained copy current
				if (line_hit) begin
					case (ram_addr[1:0])
					2'd0: begin
						if (ram_be[3]) line[127:120] <= ram_din[31:24];
						if (ram_be[2]) line[119:112] <= ram_din[23:16];
						if (ram_be[1]) line[111:104] <= ram_din[15:8];
						if (ram_be[0]) line[103:96]  <= ram_din[7:0];
					end
					2'd1: begin
						if (ram_be[3]) line[95:88] <= ram_din[31:24];
						if (ram_be[2]) line[87:80] <= ram_din[23:16];
						if (ram_be[1]) line[79:72] <= ram_din[15:8];
						if (ram_be[0]) line[71:64] <= ram_din[7:0];
					end
					2'd2: begin
						if (ram_be[3]) line[63:56] <= ram_din[31:24];
						if (ram_be[2]) line[55:48] <= ram_din[23:16];
						if (ram_be[1]) line[47:40] <= ram_din[15:8];
						if (ram_be[0]) line[39:32] <= ram_din[7:0];
					end
					default: begin
						if (ram_be[3]) line[31:24] <= ram_din[31:24];
						if (ram_be[2]) line[23:16] <= ram_din[23:16];
						if (ram_be[1]) line[15:8]  <= ram_din[15:8];
						if (ram_be[0]) line[7:0]   <= ram_din[7:0];
					end
					endcase
				end
			end
			else if (line_hit) begin
				ram_dout <= line_word;
				ram_ack  <= 1;
			end
			else begin
				DDRAM_ADDR     <= {5'b00110, 1'b0, ram_addr[23:2], 1'b0};
				DDRAM_BURSTCNT <= 8'd2;
				DDRAM_BE       <= 8'hFF;
				DDRAM_RD       <= 1;
				busy           <= 1;
				beat           <= 0;
				acked          <= 0;
				want           <= ram_addr[1:0];
				want_tag       <= ram_addr[23:2];
			end
		end
	end
end

endmodule
