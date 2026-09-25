//============================================================================
// next_ddram directed test: the retained 16-byte line (docs/PERF_PLAN.md
// stage 2) against a DDR3 model that answers 2-beat bursts with a latency,
// random BUSY and an optional gap between the beats.
//
//   - a miss on word 2 costs one burst; words 3, 0, 1 of the line then hit
//     (no DDR read), in the wrap order the cache asks for
//   - a byte-enable write into the retained line (each of the 16 masks) is
//     seen by the next read, and reaches the DDR
//   - a write to another line does not disturb the retained one
//   - a DMA-style write (same port) to the retained line is seen by the
//     next read
//   - reset clears the line
//   - the port is per 32-bit word, so a read never straddles a line
//============================================================================

`timescale 1ns/1ps

module tb_next_ddram;

reg clk = 0;
always #5 clk = ~clk;
reg reset = 1;

reg         ram_req = 0, ram_we = 0;
reg   [3:0] ram_be = 4'hF;
reg  [23:0] ram_addr = 0;
reg  [31:0] ram_din = 0;
wire [31:0] ram_dout;
wire        ram_ack;

reg         ddr_busy = 0;
reg  [63:0] ddr_dout = 64'hDEADBEEF_BAD0CAFE;
reg         ddr_ready = 0;
wire  [7:0] ddr_burst;
wire [28:0] ddr_addr;
wire [63:0] ddr_din;
wire  [7:0] ddr_be;
wire        ddr_rd, ddr_we;

next_ddram dut
(
	.clk(clk), .reset(reset),
	.ram_req(ram_req), .ram_we(ram_we), .ram_be(ram_be), .ram_addr(ram_addr),
	.ram_din(ram_din), .ram_dout(ram_dout), .ram_ack(ram_ack),
	.DDRAM_BUSY(ddr_busy), .DDRAM_BURSTCNT(ddr_burst), .DDRAM_ADDR(ddr_addr),
	.DDRAM_DOUT(ddr_dout), .DDRAM_DOUT_READY(ddr_ready), .DDRAM_RD(ddr_rd),
	.DDRAM_DIN(ddr_din), .DDRAM_BE(ddr_be), .DDRAM_WE(ddr_we)
);

// the memory, as 32-bit big-endian 68k words indexed by ram_addr
reg [31:0] mem [0:4095];
function [31:0] bsw; input [31:0] x; bsw = {x[7:0], x[15:8], x[23:16], x[31:24]}; endfunction
integer mi;
initial for (mi = 0; mi < 4096; mi = mi + 1) mem[mi] = {mi[11:0], 4'hA, mi[11:0] ^ 12'hFFF, 4'h5};

// DDR3 model (the boot bench's shape): BUSY at random, a latency from the
// acceptance, beats back to back or split by gap_beats clocks of BUSY
reg  [7:0] left = 0;
reg [28:0] addr_r = 0;
reg  [5:0] lat = 0;
reg  [3:0] gap = 0, gap_beats = 0;
reg [31:0] lfsr = 32'h1234_5678;
integer reads = 0, writes = 0;
wire [22:0] w64 = ddr_addr[22:0];     // 64-bit word index inside the RAM window
always @(posedge clk) begin
	lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
	ddr_ready <= 0;
	ddr_dout <= 64'hDEADBEEF_BAD0CAFE;
	if (reset) begin
		left <= 0; lat <= 0; gap <= 0; ddr_busy <= 0;
	end
	else begin
		ddr_busy <= (left != 0) || (lfsr[3:0] == 4'd0);
		if (left == 0 && !ddr_busy) begin
			if (ddr_we) begin
				writes = writes + 1;
				if (ddr_be[0]) mem[{w64[10:0], 1'b0}][31:24] <= ddr_din[7:0];
				if (ddr_be[1]) mem[{w64[10:0], 1'b0}][23:16] <= ddr_din[15:8];
				if (ddr_be[2]) mem[{w64[10:0], 1'b0}][15:8]  <= ddr_din[23:16];
				if (ddr_be[3]) mem[{w64[10:0], 1'b0}][7:0]   <= ddr_din[31:24];
				if (ddr_be[4]) mem[{w64[10:0], 1'b1}][31:24] <= ddr_din[39:32];
				if (ddr_be[5]) mem[{w64[10:0], 1'b1}][23:16] <= ddr_din[47:40];
				if (ddr_be[6]) mem[{w64[10:0], 1'b1}][15:8]  <= ddr_din[55:48];
				if (ddr_be[7]) mem[{w64[10:0], 1'b1}][7:0]   <= ddr_din[63:56];
			end
			else if (ddr_rd) begin
				reads = reads + 1;
				addr_r <= ddr_addr;
				left <= (ddr_burst == 0) ? 8'd1 : ddr_burst;
				lat <= 6'd6;
			end
		end
		else if (left != 0) begin
			if (gap != 0) gap <= gap - 1'd1;
			else if (lat != 0) lat <= lat - 1'd1;
			else begin
				ddr_dout <= {bsw(mem[{addr_r[10:0], 1'b1}]), bsw(mem[{addr_r[10:0], 1'b0}])};
				ddr_ready <= 1;
				addr_r <= addr_r + 1'd1;
				left <= left - 1'd1;
				if (left != 1 && gap_beats != 0) gap <= gap_beats;
			end
		end
	end
end

integer errors = 0;
task check;
	input cond;
	input [511:0] name;
	begin
		if (cond) $display("PASS: %0s", name);
		else begin $display("FAIL: %0s", name); errors = errors + 1; end
	end
endtask

// one ram_* transaction: level req, wait for ack, drop req, wait for ack low
integer clocks;
task rd;
	input [23:0] a;
	output [31:0] d;
	output integer cost;
	begin
		@(posedge clk);
		ram_addr <= a; ram_we <= 0; ram_req <= 1;
		clocks = 0;
		@(posedge clk);
		while (!ram_ack && clocks < 200) begin @(posedge clk); clocks = clocks + 1; end
		d = ram_dout;
		cost = clocks + 1;
		ram_req <= 0;
		@(posedge clk);
		while (ram_ack) @(posedge clk);
	end
endtask

task wr;
	input [23:0] a;
	input [3:0] be;
	input [31:0] d;
	begin
		@(posedge clk);
		ram_addr <= a; ram_din <= d; ram_be <= be; ram_we <= 1; ram_req <= 1;
		clocks = 0;
		@(posedge clk);
		while (!ram_ack && clocks < 200) begin @(posedge clk); clocks = clocks + 1; end
		ram_req <= 0; ram_we <= 0;
		@(posedge clk);
		while (ram_ack) @(posedge clk);
	end
endtask

// the expected word after a masked write
function [31:0] merge;
	input [31:0] old, nw;
	input [3:0] be;
	merge = {be[3] ? nw[31:24] : old[31:24], be[2] ? nw[23:16] : old[23:16],
	         be[1] ? nw[15:8] : old[15:8],   be[0] ? nw[7:0] : old[7:0]};
endfunction

reg [31:0] d, ref_w;
integer cost, cost_miss, cost_hit, r0, k, i;
reg [31:0] exp_w;

initial begin
	repeat (5) @(posedge clk);
	reset = 0;
	repeat (2) @(posedge clk);

	// miss on word 2 of line 0x100 (words 0x400..0x403), then the wrap order
	r0 = reads;
	rd(24'h402, d, cost_miss);
	check(d == mem[24'h402], "miss: word 2 read back");
	check(reads == r0 + 1 && ddr_burst == 8'd2, "miss: one 2-beat burst");
	rd(24'h403, d, cost_hit);
	check(d == mem[24'h403] && reads == r0 + 1, "hit: word 3 from the retained line, no DDR read");
	check(cost_hit <= 2, "hit: acknowledged within 2 clocks");
	rd(24'h400, d, cost);
	check(d == mem[24'h400] && reads == r0 + 1, "hit: word 0 from the retained line");
	rd(24'h401, d, cost);
	check(d == mem[24'h401] && reads == r0 + 1, "hit: word 1 from the retained line");
	$display("  miss %0d clocks, hit %0d clocks (DDR latency 6)", cost_miss, cost_hit);

	// a miss on word 0 then the others, with a BUSY gap between the beats
	gap_beats = 4'd3;
	r0 = reads;
	rd(24'h500, d, cost);
	check(d == mem[24'h500] && reads == r0 + 1, "gap: word 0 served after beat 0");
	rd(24'h502, d, cost);
	check(d == mem[24'h502] && reads == r0 + 1, "gap: word 2 from the line after beat 1");
	rd(24'h503, d, cost);
	check(d == mem[24'h503] && reads == r0 + 1, "gap: word 3 from the line");
	gap_beats = 0;

	// the 16 byte-enable masks: write into the retained line, read back,
	// and check the DDR copy too (a later miss must see it)
	r0 = reads;
	for (k = 0; k < 16; k = k + 1) begin
		ref_w = mem[24'h501];
		exp_w = merge(ref_w, 32'h11223344 + k, k[3:0]);
		wr(24'h501, k[3:0], 32'h11223344 + k);
		rd(24'h501, d, cost);
		if (d != exp_w) begin
			$display("  mask %h: got %08x want %08x", k[3:0], d, exp_w);
			errors = errors + 1;
		end
		if (mem[24'h501] != exp_w) begin
			$display("  mask %h: DDR holds %08x want %08x", k[3:0], mem[24'h501], exp_w);
			errors = errors + 1;
		end
	end
	check(reads == r0, "masked writes: every read back came from the retained line");
	check(writes >= 16, "masked writes: every write reached the DDR");

	// a write to another line leaves the retained one alone
	wr(24'h601, 4'hF, 32'hA5A5A5A5);
	rd(24'h501, d, cost);
	check(d == mem[24'h501] && reads == r0, "write elsewhere: the retained line is intact");

	// DMA-style: a full-word write to the retained line, then a read of it
	wr(24'h503, 4'hF, 32'h0BADF00D);
	rd(24'h503, d, cost);
	check(d == 32'h0BADF00D && reads == r0, "DMA write: the next read sees it, from the line");

	// a read of another line replaces the retained one; the old line misses again
	r0 = reads;
	rd(24'h600, d, cost);
	check(reads == r0 + 1 && d == mem[24'h600], "replace: the new line misses once");
	rd(24'h601, d, cost);
	check(d == 32'hA5A5A5A5 && reads == r0 + 1, "replace: its other word hits (the earlier write landed)");
	rd(24'h500, d, cost);
	check(reads == r0 + 2, "replace: the old line misses again");

	// reset clears the line
	reset = 1; repeat (3) @(posedge clk); reset = 0; repeat (2) @(posedge clk);
	r0 = reads;
	rd(24'h500, d, cost);
	check(reads == r0 + 1 && d == mem[24'h500], "reset: the line is invalid afterwards");

	// back-to-back requests through the whole line: 1 burst per 4 words
	r0 = reads;
	for (i = 0; i < 16; i = i + 1) rd(24'h700 + i, d, cost);
	check(reads == r0 + 4, "sequential: 16 words cost 4 bursts");

	// the port is per 32-bit word: a request never straddles a line
	check(ddr_addr[0] == 1'b0 || ddr_burst == 8'd1, "line reads are 16-byte aligned");

	if (errors == 0) $display("ALL PASS");
	else $display("%0d FAILURES", errors);
	$finish;
end

endmodule
