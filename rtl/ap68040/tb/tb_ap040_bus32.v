//--------------------------------------------------------------------------//
// tb_ap040_bus32.v - directed test of ap040_bus32_adapter (the 32-bit beat //
// port): every size at every alignment, read and write, the beat count    //
// and byte enables of each, the split's tail beat, the instruction/FC     //
// pass-through, a bus error's abort with no acknowledge, and the same     //
// sequence under a clock enable that is gated on idle clocks only (the    //
// host policy: ce high whenever b_busy).                                   //
//--------------------------------------------------------------------------//

`timescale 1ns/1ps
`include "ap040_defs.svh"

module tb_ap040_bus32;

reg clk = 0;
always #5 clk = ~clk;

reg         nreset = 0;
reg         t_req = 0;
reg         t_write = 0;
reg         t_instr = 0;
reg   [1:0] t_size = 0;
reg  [31:0] t_addr = 0;
reg  [31:0] t_wdata = 0;
reg   [2:0] t_fc = 3'd1;
reg         t_berr = 0;
wire        t_ack;
wire [31:0] t_rdata;
wire        t_active;
wire        b_req, b_write, b_instr, b_busy;
wire [31:2] b_addr;
wire  [3:0] b_be;
wire [31:0] b_wdata;
wire  [2:0] b_fc;
reg         b_ack = 0;
reg  [31:0] b_rdata = 0;

// the host's clock-enable policy: gate idle clocks only
reg  gate = 0;          // +gate: every other idle clock is disabled
reg  tog = 0;
always @(posedge clk) tog <= ~tog;
wire ce = b_busy | !gate | tog;

ap040_bus32_adapter dut (
	.clk(clk), .nreset(nreset), .ce(ce),
	.t_req(t_req), .t_write(t_write), .t_instr(t_instr), .t_size(t_size),
	.t_addr(t_addr), .t_wdata(t_wdata), .t_fc(t_fc), .t_berr(t_berr),
	.t_ack(t_ack), .t_rdata(t_rdata), .t_active(t_active),
	.b_req(b_req), .b_write(b_write), .b_instr(b_instr), .b_addr(b_addr),
	.b_be(b_be), .b_wdata(b_wdata), .b_fc(b_fc), .b_ack(b_ack),
	.b_rdata(b_rdata), .b_busy(b_busy)
);

// platform memory: 32-bit words with byte lanes, [31:24] = byte 0
reg [31:0] mem [0:511];
integer accepts = 0;
integer beat_log_n = 0;
reg [31:2] log_addr [0:7];
reg  [3:0] log_be   [0:7];
reg [31:0] log_wd   [0:7];
reg        log_wr   [0:7];
reg        log_instr[0:7];
reg  [2:0] log_fc   [0:7];
reg [31:2] berr_addr = 30'h3FFF_FFFF;   // fault the beat at this address (one-shot)
integer    lat = 0;
integer    lat_cnt = 0;

always @(posedge clk) begin
	b_ack  <= 0;
	t_berr <= 0;
	if (b_req && !b_ack && !t_berr) begin
		if (lat_cnt < lat) lat_cnt <= lat_cnt + 1;
		else begin
			lat_cnt <= 0;
			log_addr[beat_log_n % 8]  = b_addr;
			log_be[beat_log_n % 8]    = b_be;
			log_wd[beat_log_n % 8]    = b_wdata;
			log_wr[beat_log_n % 8]    = b_write;
			log_instr[beat_log_n % 8] = b_instr;
			log_fc[beat_log_n % 8]    = b_fc;
			beat_log_n = beat_log_n + 1;
			accepts <= accepts + 1;
			if (b_addr == berr_addr) begin
				berr_addr <= 30'h3FFF_FFFF;
				t_berr <= 1;
			end
			else begin
				b_ack <= 1;
				if (b_write) begin
					if (b_be[3]) mem[b_addr[10:2]][31:24] <= b_wdata[31:24];
					if (b_be[2]) mem[b_addr[10:2]][23:16] <= b_wdata[23:16];
					if (b_be[1]) mem[b_addr[10:2]][15:8]  <= b_wdata[15:8];
					if (b_be[0]) mem[b_addr[10:2]][7:0]   <= b_wdata[7:0];
				end
				b_rdata <= mem[b_addr[10:2]];
			end
		end
	end
	else lat_cnt <= 0;
end

integer checks = 0, fails = 0, last_cycles = 0;
reg [31:0] got;
reg        got_ack;

task check(input cond, input [8*64-1:0] what);
	begin
		checks = checks + 1;
		if (!cond) begin
			fails = fails + 1;
			$display("FAIL  %0s", what);
		end
	end
endtask

// one transaction, held until t_ack (or `limit` clocks)
task automatic transact(input wr, input instr, input [1:0] size_i, input [31:0] addr_i, input [31:0] wdata_i);
	integer n;
	begin
		@(negedge clk);
		t_size  = size_i;
		t_addr  = addr_i;
		t_write = wr;
		t_instr = instr;
		t_wdata = wdata_i;
		t_req   = 1;
		n = 0;
		got_ack = 0;
		while (!got_ack && n < 60) begin
			@(negedge clk);
			n = n + 1;
			if (t_ack) begin
				got = t_rdata;
				got_ack = 1;
				t_req = 0;
			end
			// the core withdraws a faulted request on the clock it samples
			// berr; a held request would be re-accepted (and complete)
			if (t_berr) begin
				t_req = 0;
				n = 100;
			end
		end
		if (n == 100) begin
			n = 5;
			repeat (3) @(negedge clk);
		end
		if (!got_ack) t_req = 0;
		last_cycles = n;
		// let the host drain (the ack retire clock)
		@(negedge clk);
	end
endtask

// the big-endian reference: bytes of the 32-bit words in mem
function [7:0] mbyte(input [31:0] a);
	mbyte = mem[a[10:2]] >> (8 * (3 - a[1:0]));
endfunction
function [31:0] ref_read(input [1:0] size_i, input [31:0] a);
	case (size_i)
		`AP040_SZ_B: ref_read = {24'd0, mbyte(a)};
		`AP040_SZ_W: ref_read = {16'd0, mbyte(a), mbyte(a + 1)};
		default:     ref_read = {mbyte(a), mbyte(a + 1), mbyte(a + 2), mbyte(a + 3)};
	endcase
endfunction

integer i, a0, sz, off, n_expect;
reg [31:0] w;
reg [31:0] snap [0:511];
integer pass_n = 0;

initial begin
	if ($test$plusargs("gate")) gate = 1;
	if ($value$plusargs("lat=%d", lat)) ;
	for (i = 0; i < 512; i = i + 1) mem[i] = {i[7:0], 8'h10 + i[7:0], 8'h20 + i[7:0], 8'h30 + i[7:0]};
	repeat (3) @(posedge clk);
	nreset = 1;

	// reads: every size at every offset
	for (sz = 0; sz < 3; sz = sz + 1)
		for (off = 0; off < 4; off = off + 1) begin
			a0 = accepts;
			transact(0, 0, sz[1:0], 32'h0000_0100 + 4 * (sz * 4 + off) + off, 0);
			w = 32'h0000_0100 + 4 * (sz * 4 + off) + off;
			n_expect = ((off + ((sz == 0) ? 1 : (sz == 1) ? 2 : 4)) > 4) ? 2 : 1;
			check(got_ack, "read acknowledged");
			check(got == ref_read(sz[1:0], w), "read data");
			check(accepts == a0 + n_expect, "read beat count");
			if (fails != pass_n) $display("  sz=%0d off=%0d got=%08x want=%08x beats=%0d", sz, off, got, ref_read(sz[1:0], w), accepts - a0);
			pass_n = fails;
		end

	// byte enables and write lanes: every size at every offset, then
	// read the words back through the 32-bit port and compare
	for (i = 0; i < 512; i = i + 1) snap[i] = mem[i];
	for (sz = 0; sz < 3; sz = sz + 1)
		for (off = 0; off < 4; off = off + 1) begin
			w = 32'h0000_0200 + 8 * (sz * 4 + off) + off;
			a0 = accepts;
			transact(1, 0, sz[1:0], w, 32'hA5B6_C7D8);
			check(got_ack, "write acknowledged");
			n_expect = ((off + ((sz == 0) ? 1 : (sz == 1) ? 2 : 4)) > 4) ? 2 : 1;
			check(accepts == a0 + n_expect, "write beat count");
			// the first beat's enables cover the bytes from off to the
			// longword end (or the operand end)
			case (sz)
				0: check(log_be[(beat_log_n - n_expect) % 8] == (4'b1000 >> off), "byte write be");
				1: check(log_be[(beat_log_n - n_expect) % 8] == ((off == 3) ? 4'b0001 : (4'b1100 >> off)), "word write be");
				default: check(log_be[(beat_log_n - n_expect) % 8] == (4'b1111 >> off), "long write be");
			endcase
			// the memory image: the operand's bytes landed, nothing else moved
			transact(0, 0, sz[1:0], w, 0);
			check(got == ((sz == 0) ? 32'h0000_00D8 : (sz == 1) ? 32'h0000_C7D8 : 32'hA5B6_C7D8), "write read-back");
		end
	// a neighbour word that no write touched
	check(mem[8'h80 >> 2] == snap[8'h80 >> 2], "untouched word intact");

	// instruction fetch and FC pass through to the beat
	t_fc = 3'd6;
	transact(0, 1, `AP040_SZ_L, 32'h0000_0300, 0);
	check(log_instr[(beat_log_n - 1) % 8] == 1'b1, "instr flag on the beat");
	check(log_fc[(beat_log_n - 1) % 8] == 3'd6, "fc on the beat");
	t_fc = 3'd1;
	transact(0, 0, `AP040_SZ_W, 32'h0000_0302, 0);
	check(log_instr[(beat_log_n - 1) % 8] == 1'b0, "data flag on the beat");
	check(log_fc[(beat_log_n - 1) % 8] == 3'd1, "fc data on the beat");

	// a bus error: no acknowledge, the request is dropped, the next one runs
	berr_addr = 30'h100;                    // byte address 0x400
	transact(0, 0, `AP040_SZ_L, 32'h0000_0400, 0);
	check(!got_ack, "faulted transaction is not acknowledged");
	check(!t_active && !b_req, "faulted transaction dropped");
	check(last_cycles < 10, "faulted transaction released promptly");
	transact(0, 0, `AP040_SZ_L, 32'h0000_0404, 0);
	check(got_ack && got == mem[32'h404 >> 2], "transaction after the fault completes");
	// a fault on the tail beat of a split (0x40A..0x40D: beats 0x408, 0x40C)
	berr_addr = 30'h103;
	transact(0, 0, `AP040_SZ_L, 32'h0000_040A, 0);
	check(!got_ack, "fault on the tail beat: no acknowledge");
	check(!t_active && !b_req, "tail-faulted transaction dropped");
	transact(0, 0, `AP040_SZ_W, 32'h0000_0410, 0);
	check(got_ack && got == mem[32'h410 >> 2][31:16], "next transaction after the tail fault");

	// a fill: four longword beats with the request held, addresses wrapping
	a0 = accepts;
	for (i = 0; i < 4; i = i + 1) transact(0, 0, `AP040_SZ_L, 32'h0000_0500 + 4 * ((2 + i) % 4), 0);
	check(accepts == a0 + 4, "four fill beats");

	$display("tb_ap040_bus32: %0d checks, %0d failures (gate=%0d lat=%0d)", checks, fails, gate, lat);
	if (fails == 0) $display("ALL TESTS PASSED");
	else            $display("TEST FAILED");
	$finish;
end

initial begin
	#200000;
	$display("TEST FAILED: timeout");
	$finish;
end

endmodule
