//============================================================================
// DDRAM arbiter regression.
//
// 1. Port-B read data is valid for only the Avalon DOUT_READY cycle.  The
//    req/ack client samples it later, after ownership has returned to A, so
//    the arbiter must retain the completed word.
// 2. Port A's reads are bursts (next_ddram's 2-beat line fill): a port-B
//    request arriving between the beats must wait, both beats must reach A,
//    a BUSY between the beats must not confuse the accounting, and an A
//    write while B waits keeps A's priority.
//============================================================================

`timescale 1ns/1ps

module tb_next_ddram_arb;

reg clk = 0;
always #5 clk = ~clk;

reg reset = 1;

reg         a_rd = 0, a_we = 0;
reg  [28:0] a_addr = 0;
reg  [63:0] a_din = 0;
reg   [7:0] a_be = 8'hff, a_burst = 1;
wire        a_busy;
wire [63:0] a_dout;
wire        a_dout_ready;

reg         b_req = 0, b_we = 0;
reg  [28:0] b_addr = 0;
reg  [63:0] b_wdata = 0;
wire [63:0] b_rdata;
wire        b_ack;

reg         ddr_busy = 0;
reg  [63:0] ddr_dout = 0;
reg         ddr_ready = 0;
wire  [7:0] ddr_burst;
wire [28:0] ddr_addr;
wire [63:0] ddr_din;
wire  [7:0] ddr_be;
wire        ddr_rd, ddr_we;

next_ddram_arb dut
(
	.clk(clk), .reset(reset),
	.a_rd(a_rd), .a_we(a_we), .a_addr(a_addr), .a_din(a_din),
	.a_be(a_be), .a_burst(a_burst), .a_busy(a_busy),
	.a_dout(a_dout), .a_dout_ready(a_dout_ready),
	.b_req(b_req), .b_we(b_we), .b_addr(b_addr), .b_wdata(b_wdata),
	.b_rdata(b_rdata), .b_ack(b_ack),
	.DDRAM_BUSY(ddr_busy), .DDRAM_BURSTCNT(ddr_burst),
	.DDRAM_ADDR(ddr_addr), .DDRAM_DOUT(ddr_dout),
	.DDRAM_DOUT_READY(ddr_ready), .DDRAM_RD(ddr_rd),
	.DDRAM_DIN(ddr_din), .DDRAM_BE(ddr_be), .DDRAM_WE(ddr_we)
);

localparam [63:0] B_WORD = 64'h0123456789abcdef;
localparam [63:0] A_WORD = 64'hfedcba9876543210;
localparam [63:0] POISON = 64'hdeadbeefbad0cafe;

// DDR model: a read of N beats returns beat k as (base word + k) one beat
// per clock after a latency, with an optional BUSY gap between the beats
// (gap_beats).  DOUT is poisoned outside DOUT_READY.
reg  [7:0] pending = 0;
reg  [3:0] lat = 0;
reg  [3:0] gap = 0;
reg  [3:0] gap_beats = 0;     // clocks of BUSY inserted after the first beat
reg [63:0] pending_data;
integer    writes = 0;
reg [28:0] last_wr_addr;

always @(posedge clk) begin
	ddr_ready <= 0;
	ddr_dout <= POISON;
	if (reset) begin
		ddr_busy <= 0;
		pending <= 0;
	end
	else begin
		if (pending != 0) begin
			if (gap != 0) begin
				gap <= gap - 1'd1;
				ddr_busy <= 1;
			end
			else if (lat != 0) lat <= lat - 1'd1;
			else begin
				ddr_ready <= 1;
				ddr_dout <= pending_data;
				pending_data <= pending_data + 64'd1;
				pending <= pending - 1'd1;
				if (pending == 1) ddr_busy <= 0;
				else if (gap_beats != 0) gap <= gap_beats;
			end
		end
		else if (ddr_rd && !ddr_busy) begin
			ddr_busy <= 1;
			pending <= (ddr_burst == 0) ? 8'd1 : ddr_burst;
			lat <= 4'd2;
			pending_data <= (ddr_addr == 29'h03fe0002) ? B_WORD : A_WORD;
		end
		else if (ddr_we && !ddr_busy) begin
			writes = writes + 1;
			last_wr_addr <= ddr_addr;
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

// count port A's beats and note whether B ever owned the bus while a beat
// was still owed
integer a_beats_seen = 0;
reg     b_stole = 0;
reg [63:0] a_beat0, a_beat1;
always @(posedge clk) begin
	if (a_dout_ready) begin
		if (a_beats_seen == 0) a_beat0 <= a_dout;
		if (a_beats_seen == 1) a_beat1 <= a_dout;
		a_beats_seen = a_beats_seen + 1;
	end
	if (dut.b_owns && dut.a_read_pending) b_stole <= 1;
end

integer n;
initial begin
	repeat (5) @(posedge clk);
	reset = 0;

	// Port B read: its client sees ack after the raw DDR word has expired.
	@(posedge clk);
	b_addr <= 29'h03fe0002;
	b_req <= 1;
	n = 0;
	while (!b_ack && n < 20) begin @(posedge clk); n = n + 1; end
	check(b_ack, "port B read acknowledged");
	check(b_rdata == B_WORD, "port B retained ready-cycle data");
	b_req <= 0;

	// Let A replace the raw DDR output, then prove B's completed value is
	// still stable for the bridge return state.
	@(posedge clk);
	a_addr <= 29'h0600000;
	a_rd <= 1;
	n = 0;
	while (!a_dout_ready && n < 20) begin @(posedge clk); n = n + 1; end
	check(a_dout_ready && a_dout == A_WORD, "port A read still passes through");
	a_rd <= 0;
	repeat (3) @(posedge clk);
	check(b_rdata == B_WORD, "port B data survives later traffic");

	//--------------------------------------------------------------------
	// (a) a 2-beat A read with a B request arriving between the beats
	//--------------------------------------------------------------------
	repeat (3) @(posedge clk);
	a_beats_seen = 0; b_stole = 0;
	a_burst <= 2;
	a_addr <= 29'h0600010;
	a_rd <= 1;
	@(posedge clk);
	while (a_busy) @(posedge clk);      // accepted
	a_rd <= 0;
	// B asks right after acceptance, before any beat has landed
	b_addr <= 29'h03fe0002;
	b_req <= 1;
	n = 0;
	while (a_beats_seen < 2 && n < 40) begin @(posedge clk); n = n + 1; end
	check(a_beats_seen == 2, "burst: both beats of the A read reach port A");
	check(a_beat0 == A_WORD && a_beat1 == A_WORD + 64'd1, "burst: the beats arrive in order");
	check(!b_stole, "burst: port B did not take the bus between the beats");
	n = 0;
	while (!b_ack && n < 40) begin @(posedge clk); n = n + 1; end
	check(b_ack && b_rdata == B_WORD, "burst: port B is served after the last beat");
	b_req <= 0;
	repeat (3) @(posedge clk);

	//--------------------------------------------------------------------
	// (b) BUSY asserted between the two beats
	//--------------------------------------------------------------------
	gap_beats <= 4'd3;
	a_beats_seen = 0; b_stole = 0;
	a_addr <= 29'h0600020;
	a_rd <= 1;
	@(posedge clk);
	while (a_busy) @(posedge clk);
	a_rd <= 0;
	b_req <= 1;
	n = 0;
	while (a_beats_seen < 2 && n < 60) begin @(posedge clk); n = n + 1; end
	check(a_beats_seen == 2 && a_beat1 == A_WORD + 64'd1, "busy gap: both beats reach port A");
	check(!b_stole, "busy gap: port B waited for the last beat");
	n = 0;
	while (!b_ack && n < 40) begin @(posedge clk); n = n + 1; end
	check(b_ack, "busy gap: port B served afterwards");
	b_req <= 0;
	gap_beats <= 0;
	repeat (3) @(posedge clk);

	//--------------------------------------------------------------------
	// (c) an A write while B waits: A keeps priority, B follows
	//--------------------------------------------------------------------
	b_req <= 1;
	a_addr <= 29'h0600030;
	a_we <= 1;
	a_burst <= 1;
	@(posedge clk);
	n = 0;
	while (a_busy && n < 20) begin @(posedge clk); n = n + 1; end
	a_we <= 0;
	n = 0;
	while (!b_ack && n < 40) begin @(posedge clk); n = n + 1; end
	check(writes == 1 && last_wr_addr == 29'h0600030, "write: the A write reached the DDR");
	check(b_ack, "write: port B served after the A write");
	b_req <= 0;

	if (errors == 0) $display("ALL PASS");
	else $display("%0d FAILURES", errors);
	$finish;
end

endmodule
