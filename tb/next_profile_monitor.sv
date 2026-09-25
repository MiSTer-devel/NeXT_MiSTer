// Cycle-accounting monitor for tb_next_boot (bench only, no RTL changes).
//
// Instantiated by tb_next_boot under -DNEXT_PROFILE.  Every counter is
// sampled on the free-running clock and split in two phases: before and
// after the kernel entry the bench detects (saw_kernel), so the ROM's
// POST/loader and the NeXTSTEP kernel are reported separately.  A bin
// summary line is printed every BIN clocks so the mix over the run is
// visible; the totals and the histograms are printed at the end.
//
// What is counted (all in clocks unless noted):
//   int_run    busstate idle and clkena high: the core took an internal step
//   int_gated  busstate idle and clkena low: the step lost to CPU_PACE
//   bus_*      busstate not idle, by the host's bus FSM state:
//              arb   waiting in S_IDLE (walker/DMA holds the RAM port, or
//                    the one-clock decode)
//              ram   S_RAM waiting for the DDR3 round trip
//              dmae  S_RAM_E: a DMA beat owns the port while the CPU waits
//              int   S_INT: the on-chip ROM/device/VRAM read cycle
//   gap        clocks the 16-bit adapter spends in its sub-cycle gap
//   fill       clocks the cache spends in C_FILL/C_TAGW (line fills)
//   pass       clocks in C_PASS (uncached / bypassed accesses)
//   core acc   core-level mem_req -> mem_ack latency, by kind (I/D/W)
//   ram lat    ram_req -> ram_ack latency by master (CPU / walker / DMA)
//   ddr        DDRAM_RD/WE issued, and clocks a request waits on BUSY
//   pc_rom     clocks with the PC in the boot ROM (kernel phase: ROM calls)
module next_profile_monitor;
`define TB  tb_next_boot
`define DUT tb_next_boot.dut
`define CCH tb_next_boot.dut.cpu.g_cache.cache

localparam longint BIN = 64'd50_000_000;

integer ph;                       // 0 = ROM (POST, loader), 1 = kernel
longint clocks   [0:1];
longint int_run  [0:1];
longint int_gate [0:1];
longint bus_arb  [0:1];
longint bus_ram  [0:1];
longint bus_dmae [0:1];
longint bus_int  [0:1];
longint gap_clk  [0:1];
longint fill_clk [0:1];
longint fill_n   [0:1];
longint fill_i   [0:1];
longint pass_clk [0:1];
longint post_clk [0:1];
longint walker_clk [0:1];
longint pc_rom   [0:1];
// bus cycles (16-bit completions) by target
longint cyc_ram [0:1], cyc_rom [0:1], cyc_io [0:1], cyc_vram [0:1], cyc_wr [0:1];
// core-level accesses: kind 0 = instr, 1 = data read, 2 = write
longint acc_n   [0:1][0:2];
longint acc_clk [0:1][0:2];
longint acc_hist[0:1][0:2][0:9];
// RAM port transactions: master 0 = CPU, 1 = walker, 2 = DMA
longint ram_n   [0:1][0:2];
longint ram_clk [0:1][0:2];
longint ram_hist[0:1][0:63];
longint dma_by_src [0:1][0:7];
longint ddr_rd [0:1], ddr_we [0:1], ddr_busy [0:1];
longint cstate [0:1][0:255];

integer i, j, k;
initial begin
	for (i = 0; i < 2; i = i + 1) begin
		clocks[i] = 0; int_run[i] = 0; int_gate[i] = 0; bus_arb[i] = 0;
		bus_ram[i] = 0; bus_dmae[i] = 0; bus_int[i] = 0; gap_clk[i] = 0;
		fill_clk[i] = 0; fill_n[i] = 0; fill_i[i] = 0; pass_clk[i] = 0;
		post_clk[i] = 0; walker_clk[i] = 0; pc_rom[i] = 0;
		cyc_ram[i] = 0; cyc_rom[i] = 0; cyc_io[i] = 0; cyc_vram[i] = 0; cyc_wr[i] = 0;
		ddr_rd[i] = 0; ddr_we[i] = 0; ddr_busy[i] = 0;
		for (j = 0; j < 3; j = j + 1) begin
			acc_n[i][j] = 0; acc_clk[i][j] = 0; ram_n[i][j] = 0; ram_clk[i][j] = 0;
			for (k = 0; k < 10; k = k + 1) acc_hist[i][j][k] = 0;
		end
		for (k = 0; k < 64; k = k + 1) ram_hist[i][k] = 0;
		for (k = 0; k < 8; k = k + 1) dma_by_src[i][k] = 0;
		for (k = 0; k < 256; k = k + 1) cstate[i][k] = 0;
	end
end

function integer bucket;
	input longint n;
	begin
		if (n <= 1) bucket = 0;
		else if (n == 2) bucket = 1;
		else if (n == 3) bucket = 2;
		else if (n == 4) bucket = 3;
		else if (n <= 8) bucket = 4;
		else if (n <= 16) bucket = 5;
		else if (n <= 32) bucket = 6;
		else if (n <= 64) bucket = 7;
		else if (n <= 128) bucket = 8;
		else bucket = 9;
	end
endfunction

// the current kind of a core-level access
reg     acc_active = 0;
longint acc_t = 0;
integer acc_kind = 0;
// RAM port transaction in flight
reg     ram_active = 0;
longint ram_t = 0;
integer ram_master = 0;
reg [2:0] cst_prev = 0;

// bin bookkeeping: snapshot of the phase totals at the last bin boundary
longint bin_clk = 0;
longint s_int_run = 0, s_int_gate = 0, s_bus = 0, s_fill = 0, s_filln = 0,
        s_pass = 0, s_accI = 0, s_accIn = 0, s_accD = 0, s_accDn = 0,
        s_accW = 0, s_accWn = 0, s_ram = 0, s_ramn = 0, s_dma = 0, s_gap = 0,
        s_rom = 0, s_walk = 0, s_dmae = 0, s_arb = 0;

wire        idle    = (`DUT.busstate == 2'b01);
wire        busy    = !idle;
wire [1:0]  hst     = `DUT.state;
wire        cinstr  = `DUT.cpu.mem_instr;
wire        cwrite  = `DUT.cpu.mem_write;

always @(posedge `TB.clk) if (!`TB.reset) begin : count
	longint lat;
	integer b;
	ph = `TB.saw_kernel ? 1 : 0;
	clocks[ph] = clocks[ph] + 1;

	if (idle) begin
		if (`DUT.clkena) int_run[ph] = int_run[ph] + 1;
		else             int_gate[ph] = int_gate[ph] + 1;
	end
	else begin
		case (hst)
			2'd0: bus_arb[ph]  = bus_arb[ph] + 1;
			2'd1: bus_int[ph]  = bus_int[ph] + 1;
			2'd2: bus_ram[ph]  = bus_ram[ph] + 1;
			2'd3: bus_dmae[ph] = bus_dmae[ph] + 1;
		endcase
	end
	if (`DUT.cpu.bus16.subcycle_gap) gap_clk[ph] = gap_clk[ph] + 1;
	if (`DUT.walker_busy) walker_clk[ph] = walker_clk[ph] + 1;
	if (`DUT.cpu.cache_posting) post_clk[ph] = post_clk[ph] + 1;
	if (`TB.dbg_pc[31:24] == 8'h01 || `TB.dbg_pc[31:17] == 15'd0) pc_rom[ph] = pc_rom[ph] + 1;

	// 16-bit bus cycle completions by target
	if (`DUT.mem_ready) begin
		if (`DUT.is_write) cyc_wr[ph] = cyc_wr[ph] + 1;
		if (`DUT.d_ram)       cyc_ram[ph]  = cyc_ram[ph] + 1;
		else if (`DUT.d_rom)  cyc_rom[ph]  = cyc_rom[ph] + 1;
		else if (`DUT.d_vram) cyc_vram[ph] = cyc_vram[ph] + 1;
		else                  cyc_io[ph]   = cyc_io[ph] + 1;
	end

	// cache FSM
	if (`CCH.cst == 3'd4 || `CCH.cst == 3'd5) fill_clk[ph] = fill_clk[ph] + 1;
	if (`CCH.cst == 3'd4 && cst_prev != 3'd4) begin
		fill_n[ph] = fill_n[ph] + 1;
		if (`CCH.r_bank) fill_i[ph] = fill_i[ph] + 1;
	end
	if (`CCH.cst == 3'd6) pass_clk[ph] = pass_clk[ph] + 1;
	cst_prev = `CCH.cst;

	// core-level access latency
	if (!acc_active && `DUT.cpu.mem_req) begin
		acc_active = 1; acc_t = 1;
		acc_kind = cinstr ? 0 : cwrite ? 2 : 1;
	end
	else if (acc_active) acc_t = acc_t + 1;
	if (acc_active && `DUT.cpu.mem_ack) begin
		acc_n[ph][acc_kind] = acc_n[ph][acc_kind] + 1;
		acc_clk[ph][acc_kind] = acc_clk[ph][acc_kind] + acc_t;
		b = bucket(acc_t);
		acc_hist[ph][acc_kind][b] = acc_hist[ph][acc_kind][b] + 1;
		acc_active = 0;
	end

	// RAM port transactions
	if (!ram_active && `DUT.ram_req) begin
		ram_active = 1; ram_t = 1;
		ram_master = (hst == 2'd3) ? 2 : `DUT.walker_busy ? 1 : 0;
		if (hst == 2'd3) dma_by_src[ph][`DUT.dma_grant] = dma_by_src[ph][`DUT.dma_grant] + 1;
	end
	else if (ram_active) ram_t = ram_t + 1;
	if (ram_active && `DUT.ram_ack) begin
		ram_n[ph][ram_master] = ram_n[ph][ram_master] + 1;
		ram_clk[ph][ram_master] = ram_clk[ph][ram_master] + ram_t;
		if (ram_master == 0) begin
			b = (ram_t > 63) ? 63 : ram_t;
			ram_hist[ph][b] = ram_hist[ph][b] + 1;
		end
		ram_active = 0;
	end
	if (!`DUT.ram_req) ram_active = 0;

	// DDR side
	if (`TB.dr_rd && !`TB.dr_busy) ddr_rd[ph] = ddr_rd[ph] + 1;
	if (`TB.dr_we && !`TB.dr_busy) ddr_we[ph] = ddr_we[ph] + 1;
	if ((`TB.dr_rd || `TB.dr_we) && `TB.dr_busy) ddr_busy[ph] = ddr_busy[ph] + 1;

	cstate[ph][`DUT.cpu.core.state] = cstate[ph][`DUT.cpu.core.state] + 1;

	// bin summary (deltas since the last boundary, whichever phase)
	bin_clk = bin_clk + 1;
	if (bin_clk == BIN) begin : binrep
		longint t_run, t_gate, t_bus, t_fill, t_filln, t_pass, t_accI, t_accIn,
		        t_accD, t_accDn, t_accW, t_accWn, t_ram, t_ramn, t_dma, t_gap,
		        t_rom, t_walk, t_dmae, t_arb;
		t_run  = int_run[0] + int_run[1];   t_gate = int_gate[0] + int_gate[1];
		t_bus  = bus_arb[0] + bus_arb[1] + bus_int[0] + bus_int[1] +
		         bus_ram[0] + bus_ram[1] + bus_dmae[0] + bus_dmae[1];
		t_arb  = bus_arb[0] + bus_arb[1];   t_dmae = bus_dmae[0] + bus_dmae[1];
		t_fill = fill_clk[0] + fill_clk[1]; t_filln = fill_n[0] + fill_n[1];
		t_pass = pass_clk[0] + pass_clk[1];
		t_accI = acc_clk[0][0] + acc_clk[1][0]; t_accIn = acc_n[0][0] + acc_n[1][0];
		t_accD = acc_clk[0][1] + acc_clk[1][1]; t_accDn = acc_n[0][1] + acc_n[1][1];
		t_accW = acc_clk[0][2] + acc_clk[1][2]; t_accWn = acc_n[0][2] + acc_n[1][2];
		t_ram  = ram_clk[0][0] + ram_clk[1][0]; t_ramn = ram_n[0][0] + ram_n[1][0];
		t_dma  = ram_n[0][2] + ram_n[1][2];
		t_gap  = gap_clk[0] + gap_clk[1];  t_rom = pc_rom[0] + pc_rom[1];
		t_walk = walker_clk[0] + walker_clk[1];
		$display("[%0t] PROF bin ph=%0d pc=%08x | int %0d%% gated %0d%% bus %0d%% (arb %0d%% ram %0d%% dmae %0d%%) gap %0d%% | fills %0d (I %0d) avg %0d clk, pass %0d%% | acc I %0d x%0d D %0d x%0d W %0d x%0d (avg clk) | ram cpu %0d x%0d avg %0d, dma %0d | rom-pc %0d%% walker %0d%%",
			$time, ph, `TB.dbg_pc,
			(t_run - s_int_run) * 100 / BIN, (t_gate - s_int_gate) * 100 / BIN,
			(t_bus - s_bus) * 100 / BIN, (t_arb - s_arb) * 100 / BIN,
			(t_ram - s_ram) * 100 / BIN, (t_dmae - s_dmae) * 100 / BIN,
			(t_gap - s_gap) * 100 / BIN,
			t_filln - s_filln, (fill_i[0] + fill_i[1]),
			(t_filln - s_filln) > 0 ? (t_fill - s_fill) / (t_filln - s_filln) : 64'd0,
			(t_pass - s_pass) * 100 / BIN,
			(t_accIn - s_accIn) > 0 ? (t_accI - s_accI) / (t_accIn - s_accIn) : 64'd0, t_accIn - s_accIn,
			(t_accDn - s_accDn) > 0 ? (t_accD - s_accD) / (t_accDn - s_accDn) : 64'd0, t_accDn - s_accDn,
			(t_accWn - s_accWn) > 0 ? (t_accW - s_accW) / (t_accWn - s_accWn) : 64'd0, t_accWn - s_accWn,
			t_ramn - s_ramn, 64'd0,
			(t_ramn - s_ramn) > 0 ? (t_ram - s_ram) / (t_ramn - s_ramn) : 64'd0,
			t_dma - s_dma,
			(t_rom - s_rom) * 100 / BIN, (t_walk - s_walk) * 100 / BIN);
		s_int_run = t_run; s_int_gate = t_gate; s_bus = t_bus; s_arb = t_arb; s_dmae = t_dmae;
		s_fill = t_fill; s_filln = t_filln; s_pass = t_pass;
		s_accI = t_accI; s_accIn = t_accIn; s_accD = t_accD; s_accDn = t_accDn;
		s_accW = t_accW; s_accWn = t_accWn; s_ram = t_ram; s_ramn = t_ramn;
		s_dma = t_dma; s_gap = t_gap; s_rom = t_rom; s_walk = t_walk;
		bin_clk = 0;
	end
end

task report;
	input integer p;
	integer n, m, best, bi;
	longint bus;
	begin
		bus = bus_arb[p] + bus_int[p] + bus_ram[p] + bus_dmae[p];
		$display("=== PROF phase %0d (%s): %0d clocks ===", p, p ? "kernel" : "ROM", clocks[p]);
		if (clocks[p] == 0) return;
		$display("  internal run   %12d  %5.1f%%", int_run[p], 100.0 * int_run[p] / clocks[p]);
		$display("  internal gated %12d  %5.1f%%   (lost to CPU_PACE)", int_gate[p], 100.0 * int_gate[p] / clocks[p]);
		$display("  bus total      %12d  %5.1f%%", bus, 100.0 * bus / clocks[p]);
		$display("    arb/decode   %12d  %5.1f%%", bus_arb[p], 100.0 * bus_arb[p] / clocks[p]);
		$display("    ram wait     %12d  %5.1f%%", bus_ram[p], 100.0 * bus_ram[p] / clocks[p]);
		$display("    dma owns     %12d  %5.1f%%", bus_dmae[p], 100.0 * bus_dmae[p] / clocks[p]);
		$display("    on-chip int  %12d  %5.1f%%", bus_int[p], 100.0 * bus_int[p] / clocks[p]);
		$display("  subcycle gap   %12d  %5.1f%%", gap_clk[p], 100.0 * gap_clk[p] / clocks[p]);
		$display("  walker busy    %12d  %5.1f%%", walker_clk[p], 100.0 * walker_clk[p] / clocks[p]);
		$display("  posted drain   %12d  %5.1f%%", post_clk[p], 100.0 * post_clk[p] / clocks[p]);
		$display("  PC in ROM      %12d  %5.1f%%", pc_rom[p], 100.0 * pc_rom[p] / clocks[p]);
		$display("  cache fills    %12d  (instr %0d)  %0d clocks, avg %0.1f", fill_n[p], fill_i[p], fill_clk[p],
		         fill_n[p] ? 1.0 * fill_clk[p] / fill_n[p] : 0.0);
		$display("  cache pass clk %12d  %5.1f%%", pass_clk[p], 100.0 * pass_clk[p] / clocks[p]);
		$display("  bus cycles: ram %0d rom %0d io %0d vram %0d (writes %0d)",
		         cyc_ram[p], cyc_rom[p], cyc_io[p], cyc_vram[p], cyc_wr[p]);
		for (n = 0; n < 3; n = n + 1) begin
			$display("  core acc %s: n=%0d avg %0.2f clk  hist[1,2,3,4,5-8,9-16,17-32,33-64,65-128,>128]=",
			         n == 0 ? "I" : n == 1 ? "D" : "W", acc_n[p][n],
			         acc_n[p][n] ? 1.0 * acc_clk[p][n] / acc_n[p][n] : 0.0);
			$write("     ");
			for (m = 0; m < 10; m = m + 1) $write(" %0d", acc_hist[p][n][m]);
			$write("\n");
		end
		for (n = 0; n < 3; n = n + 1)
			$display("  ram port %s: n=%0d avg %0.2f clk", n == 0 ? "CPU" : n == 1 ? "walker" : "DMA",
			         ram_n[p][n], ram_n[p][n] ? 1.0 * ram_clk[p][n] / ram_n[p][n] : 0.0);
		$write("  ram CPU latency hist (clk:count):");
		for (m = 0; m < 64; m = m + 1) if (ram_hist[p][m]) $write(" %0d:%0d", m, ram_hist[p][m]);
		$write("\n");
		$display("  dma beats by source [enet mo snd scsi print sndin]: %0d %0d %0d %0d %0d %0d",
		         dma_by_src[p][0], dma_by_src[p][1], dma_by_src[p][2], dma_by_src[p][3], dma_by_src[p][4], dma_by_src[p][5]);
		$display("  ddr: rd %0d we %0d busy-wait clk %0d", ddr_rd[p], ddr_we[p], ddr_busy[p]);
		$display("  core state histogram (top 16):");
		for (n = 0; n < 16; n = n + 1) begin
			best = -1; bi = 0;
			for (m = 0; m < 256; m = m + 1) if (cstate[p][m] > best) begin best = cstate[p][m]; bi = m; end
			if (best <= 0) break;
			$display("    state %3d  %12d  %5.1f%%", bi, best, 100.0 * best / clocks[p]);
			cstate[p][bi] = -1;
		end
	end
endtask

final begin
	report(0);
	report(1);
end

endmodule
