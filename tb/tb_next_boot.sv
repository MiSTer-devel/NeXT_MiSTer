//============================================================================
//  NeXT core boot test
//
//  Loads the real NeXTcube 68040 boot ROM (Rev 2.5 v66, from the Previous
//  submodule) into the real next_system with the real AP68040 core and
//  lets it execute from reset.  No mock logic: the only thing modeled
//  here is the main RAM (64 MB behind the ram_* port, as the DDR3 is on
//  hardware).
//
//  Milestones checked:
//    1. the CPU fetches the reset vectors from ROM addresses 0 and 4
//    2. the PC reaches the reset vector target 0x0100001E
//    3. the ROM reads SCR1 and receives 0x00012052 (machine id)
//    4. the ROM writes SCR2 (LED/RTC activity)
//    5. the CPU never halts (double fault)
//
//  All IO-space accesses are logged; the log is printed on failure and
//  with +iotrace on success too.
//============================================================================

`timescale 1ns/1ps

module tb_next_boot;

// The HPS side of the SCSI/MO windows: the real Main_MiSTer support/next
// code (tb/host/next_host_dpi.cpp, sources synced by tb/host/sync_main.sh).
import "DPI-C" function int  host_fill(input int slot, input int lba, input int sz);
import "DPI-C" function int  host_byte(input int i);
import "DPI-C" function void host_put(input int i, input int b);
import "DPI-C" function void host_exec(input int slot, input int lba, input int sz);
import "DPI-C" function int  host_mount_cd(input string path);
import "DPI-C" function int  host_mount_disk(input int slot, input longint bytes);

reg clk = 0;
reg clk_cpu = 0;
reg reset = 1;

// the bus (system) clock and the CPU's clock: two per bus clock, edge
// aligned, as the PLL makes them (the simulation rate is immaterial; the
// bench counts bus clocks as $time/10).  One process makes both edges in
// the same time step and the same active region, so a flop of either
// domain sees the other domain's pre-edge values, as in hardware; two
// independent always #delay clocks would be ordered arbitrarily by the
// simulator and the slow domain could see the fast domain's updated
// flops (the "bus clock enable" check below would catch that).
initial forever begin
	#2.5 clk_cpu = 1; clk = ~clk;
	#2.5 clk_cpu = 0;
end

// ram port
wire        ram_req, ram_we;
wire  [3:0] ram_be;
wire [23:0] ram_addr;
wire [31:0] ram_din;
wire [31:0] ram_dout;   // driven by next_ddram
wire        ram_ack;
wire        ram_line_valid;
wire [21:0] ram_line_tag;
wire [127:0] ram_line_data;

wire        hsync, vsync, hblank, vblank;
wire  [7:0] gray;
wire        led;
wire [31:0] dbg_pc;
wire        dbg_halted;
wire  [2:0] dbg_ipl;
reg  [10:0] ps2 = 0;
`ifdef NEXT_EXCEPTION_DIAG
localparam DEBUG_EXCEPTIONS = 2;
`else
localparam DEBUG_EXCEPTIONS = 0;
`endif
wire dbg_exception_valid;
wire [511:0] dbg_exception;

// exactly the FPGA parameterization: virtual microsecond of 28 bus clocks,
// DBcc period floor of 9 CPU clocks (the physical simulation clock rate
// is immaterial, the clock ratios are what the ROM's calibration checks
// measure).  -DNEXT_TB_CLK_HZ= and -DNEXT_TB_DBCC_FLOOR= override the two
// for experiments.
`ifdef NEXT_PROFILE
// bench-side cycle accounting (tb/next_profile_monitor.sv), -DNEXT_PROFILE
next_profile_monitor prof();
`endif

next_system #(
`ifdef NEXT_TB_CLK_HZ
	.CLK_HZ(`NEXT_TB_CLK_HZ),
`else
	.CLK_HZ(28000000),
`endif
`ifdef NEXT_TB_DBCC_FLOOR
	.DBCC_FLOOR(`NEXT_TB_DBCC_FLOOR),
`else
	.DBCC_FLOOR(9),
`endif
`ifdef NEXT_TB_SND_IN
	.SND_IN_EN(`NEXT_TB_SND_IN),
`endif
	.ROM_INIT_EN(1),
	.ROM_INIT("build/rom.hex"),
	.DEBUG_EXCEPTIONS(DEBUG_EXCEPTIONS)
) dut
(
	.clk(clk),
	.clk_cpu(clk_cpu),
	.clk_vid(clk),   // both domains on one clock in simulation
	.reset(reset),
		.ps2_key(ps2),
		.ps2_mouse(25'd0),
	.boot_sel(bootfd ? 3'd2 : bootcd ? 3'd6 : bootsd ? 3'd1 : 3'd0),
	.ts_host(ts_host),
	.enet_connected(net_enable),
	.fimg_mounted(fimg_mounted), .fsd_unit(), .fimg_readonly(1'b0),
	.fimg_size(fimg_bytes),
	.fsd_lba(fsd_lba), .fsd_rd(fsd_rd), .fsd_wr(fsd_wr), .fsd_ack(fsd_ack),
	.fsd_buff_addr(fsd_buff_addr), .fsd_buff_dout(fsd_buff_dout),
	.fsd_buff_din(fsd_buff_din), .fsd_buff_wr(fsd_buff_wr),
	.img_mounted({2'b00, cimg_mounted, img_mounted}),   // bit 3 = CD-ROM slot (target 3)
	.sd_unit(),
	.img_readonly(1'b0),
	.img_size(img_bytes),
	.sd_lba(sd_lba),
	.sd_rd(sd_rd),
	.sd_wr(sd_wr),
	.sd_ack(sd_ack),
	.sd_blk_cnt(sd_blk_cnt),
	.osd_blk_cnt(osd_blk_cnt),
	.oimg_mounted(2'b00), .oimg_readonly(1'b0), .oimg_size(64'd0),
	.osd_unit(), .osd_lba(osd_lba), .osd_rd(osd_rd), .osd_wr(osd_wr),
	.osd_ack(osd_ack), .osd_buff_din(osd_buff_din),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din(sd_buff_din),
	.sd_buff_wr(sd_buff_wr),

	.rom_wr(1'b0),
	.rom_waddr(17'd0),
	.rom_wdata(8'd0),

	.hsync(hsync), .vsync(vsync), .hblank(hblank), .vblank(vblank),
	.gray(gray),

	.ram_req(ram_req),
	.ram_we(ram_we),
	.ram_be(ram_be),
	.ram_addr(ram_addr),
	.ram_din(ram_din),
	.ram_dout(ram_dout),
	.ram_ack(ram_ack),
	.ram_line_valid(ram_line_valid),
	.ram_line_tag(ram_line_tag),
	.ram_line_data(ram_line_data),

	.led(led),
	.audio_l(), .audio_r(),
	.audio_in(16'sd0),

	.btx_req(btx_req), .btx_len(btx_len), .btx_addr(btx_addr), .btx_rd(btx_rd),
	.btx_q(btx_q), .btx_ack(btx_ack), .btx_done(btx_done),
	.brx_start(brx_start), .brx_len(brx_len), .brx_valid(brx_valid),
	.brx_data(brx_data), .brx_ready(brx_ready), .enet_mac(enet_mac),

	.dbg_pc(dbg_pc),
	.dbg_halted(dbg_halted),
	.dbg_ipl(dbg_ipl),
	.dbg_exception_valid(dbg_exception_valid),
	.dbg_exception(dbg_exception)
);

//----------------------------------------------------------------------------
// Main RAM model with the level req / level ack protocol.
//
// A 4 MB SIMM set in bank 0, banks 1-3 empty: a machine configuration a
// real cube supports, and small enough that the ROM's full-memory clear
// pass stays fast in simulation.  A 4 MB bank aliases through its 16 MB
// decode window (address lines above the SIMM size are not connected),
// which is what the ROM's sizing probe detects.  Reads from the empty
// banks return the address (open bus), writes are dropped, matching
// mem_ram_empty_*() in Previous src/cpu/memory.c.
//----------------------------------------------------------------------------

// Main memory, 64 MB, as the 32-bit words the machine sees.  The DDR3
// model below reads and writes it in 64-bit pairs through next_ddram's
// byte lanes, so the adapter's lane and endian handling is exercised.
reg [31:0] ram_mem [0:16777215];
integer    ram_init_i;
initial for (ram_init_i = 0; ram_init_i < 16777216; ram_init_i = ram_init_i + 1)
	ram_mem[ram_init_i] = 32'h00000000;

//----------------------------------------------------------------------------
// The real DDR3 path: next_ddram and next_ddram_arb, wired as the emu
// top wires them.  The bench used to hang its own RAM model straight on
// next_system's port, so the entire DDR3 chain - the adapter, the
// arbiter, its colour and mailbox ports, its read latch - had never
// executed a single instruction of POST.
//----------------------------------------------------------------------------

wire        ga_rd, ga_we, ga_busy, ga_dout_ready;
wire [28:0] ga_addr;
wire [63:0] ga_din, ga_dout;
wire  [7:0] ga_be, ga_burst;

wire        eb_req, eb_we, eb_ack;
wire [28:0] eb_addr;
wire [63:0] eb_wdata, eb_rdata;

wire mb_req, mb_we, mb_ack;
wire [28:0] mb_addr;
wire [63:0] mb_wdata, mb_rdata;
generate if (DEBUG_EXCEPTIONS) begin : g_exception_diag
	wire capture_valid;
	wire [511:0] capture_data;
	next_exception_trigger exception_trigger (
		.clk(clk), .reset(reset),
		.event_valid(dbg_exception_valid), .event_data(dbg_exception),
		.capture_valid(capture_valid), .capture_data(capture_data)
	);
	next_exception_mailbox #(.INPUT_HELD(1)) exception_mailbox (
		.clk(clk), .reset(reset),
		.event_valid(capture_valid), .event_data(capture_data),
		.b_req(eb_req), .b_we(eb_we), .b_addr(eb_addr),
		.b_wdata(eb_wdata), .b_rdata(eb_rdata), .b_ack(eb_ack),
		.m_req(mb_req), .m_we(mb_we), .m_addr(mb_addr),
		.m_wdata(mb_wdata), .m_rdata(mb_rdata), .m_ack(mb_ack)
	);
end else begin : g_no_exception_diag
	assign mb_req = eb_req;
	assign mb_we = eb_we;
	assign mb_addr = eb_addr;
	assign mb_wdata = eb_wdata;
	assign eb_rdata = mb_rdata;
	assign eb_ack = mb_ack;
end endgenerate

wire        dr_busy, dr_dout_ready, dr_rd, dr_we;
wire [28:0] dr_addr;
wire [63:0] dr_dout, dr_din;
wire  [7:0] dr_be, dr_burst;

next_ddram ddram
(
	.clk(clk), .reset(reset),
	.ram_req(ram_req), .ram_we(ram_we), .ram_be(ram_be),
	.ram_addr(ram_addr), .ram_din(ram_din),
	.ram_dout(ram_dout), .ram_ack(ram_ack),
	.ram_line_valid(ram_line_valid), .ram_line_tag(ram_line_tag), .ram_line_data(ram_line_data),
	.DDRAM_BUSY(ga_busy), .DDRAM_BURSTCNT(ga_burst), .DDRAM_ADDR(ga_addr),
	.DDRAM_DOUT(ga_dout), .DDRAM_DOUT_READY(ga_dout_ready),
	.DDRAM_RD(ga_rd), .DDRAM_DIN(ga_din), .DDRAM_BE(ga_be), .DDRAM_WE(ga_we)
);

next_ddram_arb ddram_arb
(
	.clk(clk), .reset(reset),
	.a_rd(ga_rd), .a_we(ga_we), .a_addr(ga_addr), .a_din(ga_din),
	.a_be(ga_be), .a_burst(ga_burst), .a_busy(ga_busy),
	.a_dout(ga_dout), .a_dout_ready(ga_dout_ready),
	.b_req(mb_req), .b_we(mb_we), .b_addr(mb_addr),
	.b_wdata(mb_wdata), .b_rdata(mb_rdata), .b_ack(mb_ack),
	.DDRAM_BUSY(dr_busy), .DDRAM_BURSTCNT(dr_burst), .DDRAM_ADDR(dr_addr),
	.DDRAM_DOUT(dr_dout), .DDRAM_DOUT_READY(dr_dout_ready),
	.DDRAM_RD(dr_rd), .DDRAM_DIN(dr_din), .DDRAM_BE(dr_be), .DDRAM_WE(dr_we)
);

//----------------------------------------------------------------------------
// The ethernet mailbox bridge, on the arbiter's port B, against a
// mailbox the host never wrote (the DDR3 model starts those words as
// rubbish).  With the network off it must read none of it: reading is
// how a stale ring pointer becomes frames the guest never asked for.
//----------------------------------------------------------------------------

wire        btx_req, btx_rd, btx_ack, btx_done;
wire [10:0] btx_len, btx_addr;
wire  [7:0] btx_q;
wire        brx_start, brx_valid, brx_ready;
wire [10:0] brx_len;
wire  [7:0] brx_data;
wire [47:0] enet_mac;

reg         net_enable = 1;
// +rtc: seed the NeXT clock as the HPS would, one TIMESTAMP update shortly
// after reset; +rtcts=<unix seconds> chooses the moment (default
// 1718884800 = Thu 2024-06-20 12:00:00 UTC, inside this image's window).
// Without +rtc the RTC starts at zero as it did before the seed existed.
reg  [32:0] ts_host = 33'd0;
reg  [31:0] rtc_ts = 32'd1718884800;
initial if ($value$plusargs("rtcts=%d", rtc_ts)) ;
reg         rtc_pulsed = 0;
always @(posedge clk) if (!reset && !rtc_pulsed && $test$plusargs("rtc")) begin
	rtc_pulsed <= 1;
	ts_host <= {1'b1, rtc_ts};
end

next_enet_bridge #(.CLK_HZ(50000000)) bridge
(
	.clk(clk), .reset(reset), .enable(net_enable),
	.btx_req(btx_req), .btx_len(btx_len), .btx_addr(btx_addr),
	.btx_rd(btx_rd), .btx_q(btx_q), .btx_ack(btx_ack), .btx_done(btx_done),
	.brx_start(brx_start), .brx_len(brx_len), .brx_valid(brx_valid),
	.brx_data(brx_data), .brx_ready(brx_ready),
	.guest_mac(enet_mac),
	.m_req(eb_req), .m_we(eb_we), .m_addr(eb_addr), .m_wdata(eb_wdata),
	.m_rdata(eb_rdata), .m_ack(eb_ack)
);

integer injected = 0;
always @(posedge clk) if (!reset && brx_start) injected = injected + 1;

// DDR3 model: throttles with BUSY, answers reads after a latency, and
// returns bursts back to back.  A memory that always accepts instantly
// is the memory that hides handshake bugs.  Each window has its own
// storage so an access landing in the wrong one is visible.
localparam [28:0] W_RAM  = 29'h0600_0000;   // byte 0x30000000
localparam [28:0] W_VRAM = 29'h0680_0000;   // byte 0x34000000
localparam [28:0] W_MBOX = 29'h03FE_0000;   // byte 0x1FF00000

reg [63:0] vram64 [0:262143];
reg [63:0] mbox   [0:8191]; // full 64 KB HPS mailbox, including diagnostics
integer diag_writes = 0;
integer    mb_i;
initial begin
	for (mb_i = 0; mb_i < 8192; mb_i = mb_i + 1)
		mbox[mb_i] = {32'hDEADBEEF, mb_i[15:0], 16'hFACE};
	for (mb_i = 0; mb_i < 262144; mb_i = mb_i + 1) vram64[mb_i] = 64'd0;
end

integer mbox_reads = 0, mbox_writes = 0, stray_ddr = 0;

wire in_ram  = (dr_addr[28:23] == W_RAM[28:23]);
wire in_vram = (dr_addr[28:18] == W_VRAM[28:18]);
wire in_mbox = (dr_addr[28:13] == W_MBOX[28:13]);

function [31:0] bsw; input [31:0] x; bsw = {x[7:0], x[15:8], x[23:16], x[31:24]}; endfunction

reg  [7:0] d3_left = 0;
reg [28:0] d3_addr = 0;
reg  [5:0] d3_lat = 0;
// +ddrlat=<n>: clocks from the read's acceptance to its first data word
// (12 by default; the MiSTer DDRAM port answers in ~20 clocks at 100 MHz,
// about 6 at 28 MHz, when the HPS leaves it alone)
integer ddr_lat = 12;
initial if ($value$plusargs("ddrlat=%d", ddr_lat)) ;
reg [31:0] d3_lfsr = 32'h1234_5678;
reg        d3_busy_r = 0;
reg        d3_dv = 0;
reg [63:0] d3_dout = 0;

assign dr_busy       = d3_busy_r;
assign dr_dout_ready = d3_dv;
assign dr_dout       = d3_dout;

always @(posedge clk) begin
	d3_lfsr <= {d3_lfsr[30:0], d3_lfsr[31] ^ d3_lfsr[21] ^ d3_lfsr[1] ^ d3_lfsr[0]};
	d3_dv   <= 0;

	if (reset) begin
		d3_left   <= 0;
		d3_lat    <= 0;
		d3_busy_r <= 0;
	end
	else begin
		d3_busy_r <= (d3_left != 0) || (d3_lfsr[3:0] == 4'd0);

		if (d3_left == 0 && !d3_busy_r) begin
			if (dr_we) begin
				if (in_ram) begin
					if (dr_be[0]) ram_mem[{dr_addr[22:0], 1'b0}][31:24] <= dr_din[7:0];
					if (dr_be[1]) ram_mem[{dr_addr[22:0], 1'b0}][23:16] <= dr_din[15:8];
					if (dr_be[2]) ram_mem[{dr_addr[22:0], 1'b0}][15:8]  <= dr_din[23:16];
					if (dr_be[3]) ram_mem[{dr_addr[22:0], 1'b0}][7:0]   <= dr_din[31:24];
					if (dr_be[4]) ram_mem[{dr_addr[22:0], 1'b1}][31:24] <= dr_din[39:32];
					if (dr_be[5]) ram_mem[{dr_addr[22:0], 1'b1}][23:16] <= dr_din[47:40];
					if (dr_be[6]) ram_mem[{dr_addr[22:0], 1'b1}][15:8]  <= dr_din[55:48];
					if (dr_be[7]) ram_mem[{dr_addr[22:0], 1'b1}][7:0]   <= dr_din[63:56];
				end
				else if (in_vram) vram64[dr_addr[17:0]] <= dr_din;
				else if (in_mbox) begin
					mbox[dr_addr[12:0]] <= dr_din;
					if (dr_addr >= W_MBOX + 29'h0a00 && dr_addr < W_MBOX + 29'h0a0a)
						diag_writes = diag_writes + 1;
					else mbox_writes = mbox_writes + 1;
				end
				else stray_ddr = stray_ddr + 1;
			end
			else if (dr_rd) begin
				d3_addr <= dr_addr;
				d3_left <= dr_burst;
				d3_lat  <= ddr_lat[5:0];
				if (in_mbox) mbox_reads = mbox_reads + 1;
				else if (!in_ram && !in_vram) stray_ddr = stray_ddr + 1;
			end
		end
		else if (d3_left != 0) begin
			if (d3_lat != 0) d3_lat <= d3_lat - 1'd1;
			else begin
				d3_dout <= (d3_addr[28:23] == W_RAM[28:23])
				           ? {bsw(ram_mem[{d3_addr[22:0], 1'b1}]),
				              bsw(ram_mem[{d3_addr[22:0], 1'b0}])} :
				           (d3_addr[28:18] == W_VRAM[28:18]) ? vram64[d3_addr[17:0]] :
				           (d3_addr[28:13] == W_MBOX[28:13]) ? mbox[d3_addr[12:0]] :
				                                               64'hBADD_BADD_BADD_BADD;
				d3_dv   <= 1;
				d3_addr <= d3_addr + 1'd1;
				d3_left <= d3_left - 1'd1;
			end
		end
	end
end


//----------------------------------------------------------------------------
// bus monitor
//----------------------------------------------------------------------------

// the CPU's beat port: mem_ready is one completion per aligned longword
// beat (b_ack), with the address, byte enables and data of that beat
wire [31:0] cpu_addr  = {dut.b_addr, 2'b00};
wire  [3:0] cpu_be    = dut.b_be;
wire        mem_ready = dut.b_ack;
wire [31:0] cpu_din   = dut.b_rdata;
wire [31:0] cpu_dout  = dut.b_wdata;
wire        is_write  = dut.b_write;
wire        berr_hold = dut.berr_hold;
// the 16-bit half a narrow access carries (device registers are 16-bit)
wire [15:0] cpu_data16 = (cpu_be[3:2] != 2'b00) ? (is_write ? cpu_dout[31:16] : cpu_din[31:16])
                                                : (is_write ? cpu_dout[15:0]  : cpu_din[15:0]);

integer access_count = 0;
reg [31:0] first_addr [0:3];

reg        seen_vec_lo = 0;      // read at 0x0
reg        seen_vec_pc = 0;      // read at 0x4
reg        seen_entry  = 0;      // pc reached 0x0100001E
reg        seen_scr1   = 0;      // SCR1 read observed
reg        scr1_ok     = 0;      // ... with correct data
reg        seen_scr2_wr= 0;
integer    berr_count  = 0;

// IO access log
integer iolog_n = 0;
reg [63:0] iolog [0:1023];       // {we, addr[30:0], data[15:0], pc[15:0]}

wire is_io_cyc = (cpu_addr[31:24] == 8'h02);

always @(posedge clk) begin
	if (!reset) begin
		if (mem_ready) begin
			if (access_count < 4) begin
				first_addr[access_count] <= cpu_addr;
				access_count = access_count + 1;
			end
			if (cpu_addr == 32'h00000000 && !is_write) seen_vec_lo <= 1;
			if (cpu_addr == 32'h00000004 && !is_write) seen_vec_pc <= 1;

			if ((cpu_addr[31:17] == 15'h0100 || cpu_addr[31:17] == 15'h0108) &&
			    (cpu_addr[16:0] >= 17'h0c000 && cpu_addr[16:0] < 17'h0c004) && !is_write) begin
				seen_scr1 <= 1;
				if (cpu_be[3:2] != 2'b00 && cpu_din[31:16] == 16'h0001) scr1_ok <= 1;
				if (cpu_be[1:0] != 2'b00 && cpu_din[15:0]  == 16'h2052) scr1_ok <= 1;
			end

			if ((cpu_addr[31:24] == 8'h02) &&
			    (cpu_addr[16:12] == 5'h0d) && is_write) seen_scr2_wr <= 1;

			// After a second bus error the machine is in the monitor,
			// which bit-bangs the RTC forever: recording that scrolls
			// the conversation that caused the fault out of the ring.
			if (is_io_cyc && berr_count < 2) begin
				iolog[iolog_n % 1024] <= {is_write, cpu_addr[30:0], cpu_data16, dbg_pc[15:0]};
				iolog_n = iolog_n + 1;
			end
		end
		if (dbg_pc == 32'h0100001E) seen_entry <= 1;
	end
end

// count distinct bus error events and log the faulting addresses
reg berr_d;
reg [31:0] berr_log [0:63];
reg [31:0] berr_pc  [0:63];
always @(posedge clk) begin
	berr_d <= berr_hold;
	if (berr_hold && !berr_d) begin
		if (berr_count < 64) begin
			berr_log[berr_count] <= cpu_addr;
			berr_pc[berr_count]  <= dbg_pc;
		end
		berr_count = berr_count + 1;
	end
end

time delay_t0 = 0;
reg trace_post_delay = 0;
initial trace_post_delay = $test$plusargs("postdelaytrace");

// POST sub-test tracing: entry PCs and the return-value check PCs of
// the system test master at 0x469c (see ROMV66 listing), logging D0
// The CPU as the bench sees it (rtl/ap68040): an instruction retires when
// its last uop commits in WB (cpu_retire, with its PC cpu_rpc; dbg_pc is
// the PC of whatever uop is in WB), the SR, a shadow of the register file
// kept from the back end's two write ports (D0-D7 0-7, A0-A6 8-14, USP
// 15, ISP 16, MSP 17), and the exception entries (x_go with the vector).
// All of it lives on the CPU's clock: a WB stage holds a uop for one CPU
// clock, so anything keyed on a PC must be sampled there, not on clk.
wire        cpu_retire = dut.cpu.be.wb_bound;
wire [31:0] cpu_rpc    = dut.cpu.be.wb_u.pc;
wire [15:0] cpu_sr     = dut.cpu.sr;
reg  [31:0] cpu_reg [0:31];
integer     cpu_reg_i;
initial for (cpu_reg_i = 0; cpu_reg_i < 32; cpu_reg_i = cpu_reg_i + 1) cpu_reg[cpu_reg_i] = 0;
always @(posedge clk_cpu) begin
	if (dut.cpu.be.bwe[0]) cpu_reg[dut.cpu.be.bwa[0]] <= dut.cpu.be.bwd[0];
	if (dut.cpu.be.bwe[1]) cpu_reg[dut.cpu.be.bwa[1]] <= dut.cpu.be.bwd[1];
end
wire [31:0] dbg_d0 = cpu_reg[0];
wire [31:0] cpu_a7 = cpu_sr[13] ? (cpu_sr[12] ? cpu_reg[17] : cpu_reg[16]) : cpu_reg[15];
// bclk_en must mark exactly the CPU clocks that end on a bus clock edge:
// seen from a bus clock edge it is always high (bclk_bad counts the
// edges where it is not)
integer bclk_bad = 0;
always @(posedge clk) if (!reset && !dut.bclk_en) bclk_bad = bclk_bad + 1;
task post_trace;
	input [31:0] pc;
	begin
		case (pc)
			32'h010031b4: $display("[%0t] POST: FPU test entry", $time);
			32'h010031fa: $display("[%0t] POST: SCC test entry", $time);
			32'h0100337e: $display("[%0t] POST: SCSI test entry", $time);
			32'h01003548: $display("[%0t] POST: Enet test entry", $time);
			32'h0100381a: $display("[%0t] POST: ECC test entry", $time);
			32'h01003b1a: $display("[%0t] POST: RTC test entry", $time);
			32'h01003b98: $display("[%0t] POST: Timer test entry", $time);
			32'h01003c7e: $display("[%0t] POST: Event counter test entry", $time);
			32'h01003f74: $display("[%0t] POST: Sound out test entry", $time);
			32'h01003430: $display("[%0t] POST: Extended SCSI test entry", $time);
			32'h010046f2: $display("[%0t] POST: FPU test returned d0=%08x", $time, dbg_d0);
			32'h0100471c: $display("[%0t] POST: SCC test returned d0=%08x", $time, dbg_d0);
			32'h01004746: $display("[%0t] POST: SCSI test returned d0=%08x", $time, dbg_d0);
			32'h01004764: $display("[%0t] POST: Enet test returned d0=%08x", $time, dbg_d0);
			32'h0100479c: $display("[%0t] POST: ECC test returned d0=%08x", $time, dbg_d0);
			32'h010047c6: $display("[%0t] POST: RTC test returned d0=%08x", $time, dbg_d0);
			32'h010047f0: $display("[%0t] POST: Timer test returned d0=%08x", $time, dbg_d0);
			32'h0100481a: $display("[%0t] POST: Event counter test returned d0=%08x", $time, dbg_d0);
			32'h01004852: $display("[%0t] POST: Sound out test returned d0=%08x", $time, dbg_d0);
			32'h01004884: $display("[%0t] POST: Extended SCSI test returned d0=%08x", $time, dbg_d0);
			32'h01001308: begin
				$display("[%0t] POST: SYSTEM TEST FAILED, error code %02x", $time, dbg_d0[7:0]);
				$display("  enet: est=%0d stopped=%b tx_mode=%02x tx_status=%02x rx_status=%02x",
				         dut.enet.est, dut.enet.en_stopped, dut.enet.tx_mode,
				         dut.enet.tx_status, dut.enet.rx_status);
				$display("  enet: tx_csr=%02x tx_next=%08x tx_limit=%08x tx_len=%0d",
				         dut.enet.tx_csr, dut.enet.tx_next, dut.enet.tx_limit, dut.enet.tx_len);
				$display("  enet: rx_csr=%02x rx_next=%08x rx_limit=%08x rx_len=%0d rx_slimit=%08x",
				         dut.enet.rx_csr, dut.enet.rx_next, dut.enet.rx_limit, dut.enet.rx_len,
				         dut.enet.rx_slimit);
				dump_state;
			end
			32'h01001330: $display("[%0t] POST: system test passed path", $time);
			32'h01003d78: $display("[%0t] POST: event counter measured delay(1000) = %0d us", $time, dbg_d0);
				32'h010024d2: if (trace_post_delay) delay_t0 = $time;   // delay() body entry
				32'h010024fc: if (trace_post_delay && delay_t0 != 0) begin
				$display("[%0t] POST: delay() took %0d ns", $time, ($time - delay_t0) / 1000);
				delay_t0 = 0;
			end
			default: ;
		endcase
	end
endtask

// heartbeat for long runs
integer hb_cycles = 0;
always @(posedge clk) begin
	hb_cycles = hb_cycles + 1;
	if (hb_cycles % 10000000 == 0)
		$display("[%0t] heartbeat: pc=%08x", $time, dbg_pc);
end

// dedicated ethernet trace: every access to the enet register ranges,
// and the engine state transitions
wire [16:0] en_off = cpu_addr[16:0];
wire is_enet_cyc = (cpu_addr[31:24] == 8'h02) &&
	((en_off[15:4]  == 12'h600)  ||
	 (en_off[15:2]  == 14'h044)  ||
	 (en_off[15:2]  == 14'h054)  ||
	 (en_off[15:5]  == 11'h208)  ||
	 (en_off[15:5]  == 11'h20A)  ||
	 (en_off[15:2]  == 14'h10C4) ||
	 (en_off[15:2]  == 14'h10D4));

always @(posedge clk) begin
	if (!reset && mem_ready && is_enet_cyc && $test$plusargs("entrace"))
		$display("[%0t] EN %s %08x be=%b data=%08x pc=%08x",
		         $time, is_write ? "WR" : "RD", cpu_addr, cpu_be,
		         is_write ? cpu_dout : cpu_din, dbg_pc);
end

reg [2:0] en_est_prev;
always @(posedge clk) begin
	en_est_prev <= dut.enet.est;
	if (!reset && dut.enet.est != en_est_prev && $test$plusargs("entrace"))
		$display("[%0t] EN est %0d -> %0d (tx_len=%0d rx_len=%0d rx_pos=%0d tx_next=%08x rx_next=%08x)",
		         $time, en_est_prev, dut.enet.est, dut.enet.tx_len,
		         dut.enet.rx_len, dut.enet.rx_pos, dut.enet.tx_next, dut.enet.rx_next);
end

// PC trace ring buffer: the last 64 retired instructions
reg [31:0] pc_ring [0:63];
integer pc_ring_n = 0;
always @(posedge clk_cpu) begin
	if (!reset && cpu_retire) begin
		pc_ring[pc_ring_n % 64] <= cpu_rpc;
		pc_ring_n = pc_ring_n + 1;
		post_trace(cpu_rpc);
	end
	// +loopdump: time every looped call of the ROM's delay(n) (entry
	// $010024CC, its dbf $010024F0, rts $010024FC): the iterations are
	// D0 + 1 at the first dbf, the clocks run to the rts, so clocks per
	// iteration is what the DBcc floor must hold at 9 (CPU clocks) for
	// the ROM's calibration.
	if ($test$plusargs("loopdump") && cpu_retire) begin
		if (cpu_rpc == 32'h010024cc && loop_t0 == 0) begin loop_t0 = $time; loop_n = 0; loop_nw = 0; end
		if (loop_t0 != 0 && cpu_rpc == 32'h010024f0 && loop_nw < 1) begin
			loop_n = dbg_d0 + 1; loop_nw = loop_nw + 1;
		end
		if (cpu_rpc == 32'h010024fc && loop_t0 != 0) begin
			if (($time - loop_t0) / 5 > 40)   // n <= 3 returns before the loop
				$display("[%0t] LOOP iterations=%0d cpu_clocks=%0d", $time, loop_n, ($time - loop_t0) / 5);
			loop_t0 = 0;
		end
	end
end
time loop_t0 = 0;
reg [31:0] loop_n;
integer loop_nw;

task dump_state;
	integer i, k;
	begin
		$display("--- state dump ---");
		$display("pc=%08x halted=%b ipl=%0d berr_events=%0d", dbg_pc, dbg_halted, dbg_ipl, berr_count);
		$display("last PCs:");
		k = (pc_ring_n > 64) ? 64 : pc_ring_n;
		for (i = 0; i < k; i = i + 1)
			$display("  %08x", pc_ring[(pc_ring_n - k + i) % 64]);
		$display("bus errors:");
		for (i = 0; i < berr_count && i < 64; i = i + 1)
			$display("  addr=%08x pc=%08x", berr_log[i], berr_pc[i]);
		$display("IO accesses (last %0d of %0d):", (iolog_n > 1024) ? 1024 : iolog_n, iolog_n);
		k = (iolog_n > 1024) ? 1024 : iolog_n;
		for (i = 0; i < k; i = i + 1)
			$display("  %s %08x data=%04x pc=xxxx%04x",
			         iolog[(iolog_n - k + i) % 1024][63] ? "WR" : "RD",
			         {1'b0, iolog[(iolog_n - k + i) % 1024][62:32]},
			         iolog[(iolog_n - k + i) % 1024][31:16],
			         iolog[(iolog_n - k + i) % 1024][15:0]);
	end
endtask

integer errors = 0;
longint run_cycles;
reg     halt_run = 0;
reg     stop_at_kernel = 0;
reg     saw_kernel = 0;
reg [31:0] kernel_entry = 32'h040002cc; // LC_UNIXTHREAD PC in NeXTSTEP 3.3 /sdmach
integer typew_delay_mc = 0;
integer typesd_delay_mc = 0;

initial begin
	stop_at_kernel = $test$plusargs("stopkernel");
	if ($value$plusargs("kernelentry=%h", kernel_entry)) ;
end

//----------------------------------------------------------------------------
// Optional physical-memory write watch.
//
// The former default 0x04014740..0x0401aa4f is the kernel's reclaimed
// initialization text: _init_TEXT_BEGIN.._init_TEXT_END.  Writes there are
// legitimate after initialization.  Also, executing from RAM first enters
// the disk bootloader, which must finish loading /sdmach before this arms.
// An explicitly selected window is a diagnostic watch, not by itself proof
// of corruption.  See docs/PANIC_AUDIT.md for the symbol/disassembly evidence.
//
//   +guardlo=<hex byte>  window start (required to enable the watch)
//   +guardhi=<hex byte>  window end, inclusive (required)
//   +guardhalt           stop the run on the first hit (freeze for inspection)
//----------------------------------------------------------------------------
reg [31:0] guard_lo = 32'hffffffff;
reg [31:0] guard_hi = 32'h00000000;
reg        guard_enable = 0;
reg        guard_halt = 0;
reg        guard_armed = 0;         // set once the kernel is executing
integer    guard_hits = 0;
// first offending writes: {master[2:0], addr[28:0]} plus data and pc
reg [31:0] guard_addr [0:31];
reg [31:0] guard_data [0:31];
reg [31:0] guard_pc   [0:31];
reg [2:0]  guard_who  [0:31];       // 0 CPU, 1 walker, 2 ENET, 3 MO, 4 SND, 5 SCSI
reg [31:0] guard_va   [0:31];       // CPU logical (pre-translate) addr at the hit
reg [31:0] guard_pa   [0:31];       // CPU MMU physical output at the hit
// ring of recent CPU RAM writes, to see the access pattern into the window
integer    cwr_n = 0;
reg [31:0] cwr_pa   [0:63];
reg [31:0] cwr_va   [0:63];
reg [31:0] cwr_data [0:63];
reg [31:0] cwr_pc   [0:63];

initial begin
	integer have_lo, have_hi;
	have_lo = $value$plusargs("guardlo=%h", guard_lo);
	have_hi = $value$plusargs("guardhi=%h", guard_hi);
	guard_halt = $test$plusargs("guardhalt");
	if ((have_lo != 0) != (have_hi != 0) ||
	    (guard_halt && !have_lo) || (have_lo && guard_lo > guard_hi))
		$fatal(1, "write watch needs +guardlo and +guardhi defining an ordered window");
	guard_enable = have_lo && have_hi;
end

// Arm only once the kernel is running: the ROM's SCSI load legitimately fills
// this text during boot, so the window is fair game until control transfers.
always @(posedge clk) if (!reset && saw_kernel) guard_armed <= 1;

// Match the reported panic PC.  dbg_pc is VIRTUAL: comparing it against the
// physical RAM/ROM map wrongly diagnoses valid user mappings as wild jumps.
reg        wildpc_seen = 0;
reg [31:0] wildpc_val = 0;
reg        wildpc_halt = 0;
reg [31:0] wildpc_target = 32'h3c014d9c;
reg panic_trace = 0;
initial begin
	wildpc_halt = $test$plusargs("wildhalt");
	panic_trace = $test$plusargs("panictrace");
	if ($value$plusargs("wildpc=%h", wildpc_target)) ;
end
wire wild_pc = cpu_retire && cpu_rpc == wildpc_target && cpu_sr[13];
always @(posedge clk_cpu) if (!reset && saw_kernel && wild_pc && !wildpc_seen) begin
	wildpc_seen <= 1;
	wildpc_val  <= cpu_rpc;
	$display("[%0t] WILDPC: supervisor PC reached panic target %08x  A2=%08x A3=%08x", $time, cpu_rpc, cpu_reg[10], cpu_reg[11]);
	dump_panic_trace;
	if (memring_en) dump_memring;
	if (dump_en) dump_files;
	if (wildpc_halt) halt_run <= 1;
end

always @(posedge clk) if (!reset && guard_armed) begin : guard_watch
	reg [31:0] gaddr;
	reg [2:0]  who;
	if (dut.ram_req && dut.ram_we && dut.ram_ack) begin
		gaddr = 32'h04000000 | ({8'd0, dut.ram_addr} << 2);
		// classify the master owning this acknowledged RAM write
		if (dut.state == 2'd3) begin           // S_RAM_E: a DMA channel
			who = (dut.dma_grant == 2'd0) ? 3'd2 :   // ENET
			      (dut.dma_grant == 2'd1) ? 3'd3 :   // MO
			      (dut.dma_grant == 2'd2) ? 3'd4 :   // SND
			                                3'd5;    // SCSI
		end
		else who = 3'd0;                       // the CPU (table walks included)
		// keep a rolling history of CPU stores to RAM (the suspect master);
		// the 68040 bus carries physical addresses only
		if (who == 3'd0) begin
			cwr_pa[cwr_n % 64]   <= gaddr;
			cwr_va[cwr_n % 64]   <= gaddr;
			cwr_data[cwr_n % 64] <= dut.ram_din;
			cwr_pc[cwr_n % 64]   <= dbg_pc;
			cwr_n = cwr_n + 1;
		end
		if (guard_enable && gaddr >= guard_lo && gaddr <= guard_hi) begin
			if (guard_hits < 32) begin
				guard_addr[guard_hits] <= gaddr;
				guard_data[guard_hits] <= dut.ram_din;
				guard_pc[guard_hits]   <= dbg_pc;
				guard_who[guard_hits]  <= who;
				guard_va[guard_hits]   <= gaddr;
				guard_pa[guard_hits]   <= gaddr;
			end
			$display("[%0t] GUARD: watched write addr=%08x data=%08x master=%0d pc=%08x",
			         $time, gaddr, dut.ram_din, who, dbg_pc);
			guard_hits = guard_hits + 1;
			if (guard_halt) halt_run <= 1;
		end
	end
end

// +memring: the core's last 4096 memory operations as the execute stage
// sees them (PC, effective address, size, load value or store data),
// armed at the kernel entry, dumped when the wild PC is reached (point
// +wildpc at the kernel's panic() to catch a panic): every entry within
// 64 bytes of the address in +memwatch=<hex> (default: A2 at the halt,
// the kernel's vm_fault keeps its vm_page there), then the last 48.
reg        memring_en = 0;
reg [31:0] memwatch = 0;
initial begin
	memring_en = $test$plusargs("memring");
	if (!$value$plusargs("memwatch=%h", memwatch)) memwatch = 0;
end
reg [31:0] mr_pc [0:4095], mr_ea [0:4095], mr_v [0:4095];
reg  [3:0] mr_k  [0:4095];      // {store, rmw, msz[1:0]}
longint    mr_t  [0:4095];
integer    mr_n = 0;
always @(posedge clk_cpu) if (!reset && memring_en && saw_kernel && !wildpc_seen &&
                             dut.cpu.be.adv_ex && dut.cpu.be.ex_u.mem != 2'd0) begin
	mr_pc[mr_n % 4096] <= dut.cpu.be.ex_u.pc;
	mr_ea[mr_n % 4096] <= dut.cpu.be.ex_ea;
	mr_v [mr_n % 4096] <= (dut.cpu.be.ex_u.mem == 2'd1) ? dut.cpu.be.ex_ld : dut.cpu.be.ex_st;
	mr_k [mr_n % 4096] <= {dut.cpu.be.ex_u.mem != 2'd1, dut.cpu.be.ex_u.mem == 2'd3, dut.cpu.be.ex_u.msz};
	mr_t [mr_n % 4096] <= $time / 5;
	mr_n = mr_n + 1;
end
// +snoopdirty: every DMA-write snoop that finds the line DIRTY in the CPU's
// data cache (the bridge snoops with SC 10, invalidate: the CPU's dirty
// bytes of that line are discarded), with the DMA master and address
integer snoop_dirty_n = 0, snoop_hit_n = 0, snoop_n = 0;
reg     snoopdirty_en = 0;
initial snoopdirty_en = $test$plusargs("snoopdirty");
always @(posedge clk_cpu) if (!reset && dut.cpu.sn_look) begin
	snoop_n = snoop_n + 1;
	if (dut.cpu.sn_hit) snoop_hit_n = snoop_hit_n + 1;
	if (dut.cpu.sn_hit && dut.cpu.sn_dirty && !dut.cpu.snoop.s_rd) begin
		snoop_dirty_n = snoop_dirty_n + 1;
		if (snoopdirty_en && snoop_dirty_n <= 2000)
			$display("[%0t] SNOOP-DIRTY #%0d pa=%08x grant=%0d pc=%08x (snoops %0d, hits %0d)", $time, snoop_dirty_n,
			         dut.cpu.sn_pa, dut.dma_grant, cpu_rpc, snoop_n, snoop_hit_n);
	end
end

// +linewatch=<hex address>: from the kernel entry, everything that touches
// that 16-byte line: the core's memory operations on it (execute stage,
// virtual address; the kernel's own memory is mapped 1:1), the bus beats
// and DMA writes to it, and every change in the data cache's four ways of
// its set (tag, valid, dirty, the four long words)
reg [31:0] lw_a = 0;
reg        lw_en = 0;
initial lw_en = $value$plusargs("linewatch=%h", lw_a);
wire [5:0]  lw_set = lw_a[9:4];
wire [21:0] lw_tag = lw_a[31:10];
reg  [21:0] lw_ptag [0:3];
reg   [1:0] lw_pvd  [0:3];
reg [127:0] lw_pdat [0:3];
integer lw_i;
always @(posedge clk_cpu) if (!reset && lw_en && saw_kernel && !wildpc_seen) begin : linewatch
	reg [21:0] t; reg [1:0] vd; reg [127:0] dt; reg [7:0] w;
	if (dut.cpu.be.adv_ex && dut.cpu.be.ex_u.mem != 2'd0 && dut.cpu.be.ex_ea[31:4] == lw_a[31:4])
		$display("[%0t] LW cpu pc=%08x %s sz=%0d ea=%08x v=%08x", $time, dut.cpu.be.ex_u.pc,
		         dut.cpu.be.ex_u.mem == 2'd1 ? "LD" : dut.cpu.be.ex_u.mem == 2'd3 ? "RMW" : "ST",
		         dut.cpu.be.ex_u.msz, dut.cpu.be.ex_ea,
		         dut.cpu.be.ex_u.mem == 2'd1 ? dut.cpu.be.ex_ld : dut.cpu.be.ex_st);
	w = dut.cpu.dmu.lsw[lw_set];
	for (lw_i = 0; lw_i < 4; lw_i = lw_i + 1) begin
		case (lw_i)
			0: begin t = dut.cpu.dmu.g_way[0].tag.mem[lw_set];
			   dt = {dut.cpu.dmu.g_way[0].dat.g_sl[0].sl.mem[lw_set], dut.cpu.dmu.g_way[0].dat.g_sl[1].sl.mem[lw_set],
			         dut.cpu.dmu.g_way[0].dat.g_sl[2].sl.mem[lw_set], dut.cpu.dmu.g_way[0].dat.g_sl[3].sl.mem[lw_set]}; end
			1: begin t = dut.cpu.dmu.g_way[1].tag.mem[lw_set];
			   dt = {dut.cpu.dmu.g_way[1].dat.g_sl[0].sl.mem[lw_set], dut.cpu.dmu.g_way[1].dat.g_sl[1].sl.mem[lw_set],
			         dut.cpu.dmu.g_way[1].dat.g_sl[2].sl.mem[lw_set], dut.cpu.dmu.g_way[1].dat.g_sl[3].sl.mem[lw_set]}; end
			2: begin t = dut.cpu.dmu.g_way[2].tag.mem[lw_set];
			   dt = {dut.cpu.dmu.g_way[2].dat.g_sl[0].sl.mem[lw_set], dut.cpu.dmu.g_way[2].dat.g_sl[1].sl.mem[lw_set],
			         dut.cpu.dmu.g_way[2].dat.g_sl[2].sl.mem[lw_set], dut.cpu.dmu.g_way[2].dat.g_sl[3].sl.mem[lw_set]}; end
			default: begin t = dut.cpu.dmu.g_way[3].tag.mem[lw_set];
			   dt = {dut.cpu.dmu.g_way[3].dat.g_sl[0].sl.mem[lw_set], dut.cpu.dmu.g_way[3].dat.g_sl[1].sl.mem[lw_set],
			         dut.cpu.dmu.g_way[3].dat.g_sl[2].sl.mem[lw_set], dut.cpu.dmu.g_way[3].dat.g_sl[3].sl.mem[lw_set]}; end
		endcase
		vd = {w[4 + lw_i], w[lw_i]};
		if ((t == lw_tag || lw_ptag[lw_i] == lw_tag) &&
		    (t != lw_ptag[lw_i] || vd != lw_pvd[lw_i] || (t == lw_tag && dt != lw_pdat[lw_i])))
			$display("[%0t] LW way%0d tag=%06x%s v=%0d d=%0d data=%032x  (e_st=%0d pc=%08x)", $time, lw_i, t,
			         t == lw_tag ? "(match)" : "(other)", vd[0], vd[1], dt, dut.cpu.dmu.e_st, cpu_rpc);
		lw_ptag[lw_i] = t; lw_pvd[lw_i] = vd; lw_pdat[lw_i] = dt;
	end
end
always @(posedge clk) if (!reset && lw_en && saw_kernel && !wildpc_seen) begin
	if (mem_ready && cpu_addr[31:4] == lw_a[31:4])
		$display("[%0t] LW bus %s %08x be=%b data=%08x tm=%0d", $time, is_write ? "WR" : "RD", cpu_addr, cpu_be,
		         is_write ? cpu_dout : cpu_din, dut.cpubus.xtm);
	if (dut.ram_req && dut.ram_we && dut.ram_ack && dut.state == 3'd3 &&
	    {6'b000001, dut.ram_addr, 2'b00} >> 4 == lw_a >> 4)
		$display("[%0t] LW DMA WR %08x be=%b data=%08x grant=%0d", $time, {6'b000001, dut.ram_addr, 2'b00},
		         dut.ram_be, dut.ram_din, dut.dma_grant);
end

// +pwin=<start>:<end> (clk_cpu cycles, the memory ring's t): every clock
// in that window, the DMU's DC1/DC2 state -- the lookup set the RAMs are
// reading, DC1's address, tags and valid bits as compared, the hit vector,
// the stale/steal/snoop/engine holds, DC2's record and the fast-path data
// (to see where a load took its value from)
longint pw_s = 0, pw_e = 0;
reg     pw_en = 0;
initial begin
	string pw;
	if ($value$plusargs("pwin=%s", pw)) begin
		pw_en = 1;
		$sscanf(pw, "%d:%d", pw_s, pw_e);
	end
end
always @(posedge clk_cpu) if (pw_en && ($time / 5) >= pw_s && ($time / 5) <= pw_e) begin
	$display("[%0t] PW c=%0d be: ag=%b dc1=%b/%0d dc2=%b/%0d/%08x ex=%b/%0d wb=%b kill=%b | ag=%b req=%b va=%08x | dc1 adv=%b v=%b a=%08x mem=%0d stale=%b tp=%b hold=%b atc=%b set=%02x tq=%06x/%06x/%06x/%06x lvd=%b mj=%b x.hit=%b way=%0d pa=%08x ok=%b walk=%b | sn=%0d req=%b steal=%b/%b stset=%02x dw=%b/%02x/%0d/%0d twb=%b/%02x e_st=%0d job=%b bus=%b%b%b | dc2 adv=%b rdy=%b v=%b a=%08x hit=%b way=%0d pa=%08x fast=%b new=%b dq2=%016x fd=%08x e_done=%b ld=%08x | ex adv=%b pc=%08x rpc=%08x",
	         $time, $time / 5,
	         dut.cpu.be.ag_v, dut.cpu.be.dc1_v, dut.cpu.be.dc1_u.mem, dut.cpu.be.dc2_v, dut.cpu.be.dc2_u.mem, dut.cpu.be.dc2_u.pc,
	         dut.cpu.be.ex_v, dut.cpu.be.ex_u.mem, dut.cpu.be.wb_v, dut.cpu.be.kill_now,
	         dut.cpu.dmu.adv_ag, dut.cpu.dmu.dm_req, dut.cpu.dmu.dm_va,
	         dut.cpu.dmu.adv_dc1, dut.cpu.dmu.m1.v, dut.cpu.dmu.m1.a, dut.cpu.dmu.m1.mem,
	         dut.cpu.dmu.m1_stale, dut.cpu.dmu.m1_tp, dut.cpu.dmu.dm_hold1, dut.cpu.dmu.atc_hit,
	         dut.cpu.dmu.g_way[0].la_set_n,
	         dut.cpu.dmu.tq_r[0], dut.cpu.dmu.tq_r[1], dut.cpu.dmu.tq_r[2], dut.cpu.dmu.tq_r[3],
	         dut.cpu.dmu.lvd_q, dut.cpu.dmu.d1_mj,
	         dut.cpu.dmu.x_dc1.hit, dut.cpu.dmu.x_dc1.way, dut.cpu.dmu.x_dc1.pa, dut.cpu.dmu.x_dc1.ok, dut.cpu.dmu.x_dc1.walk,
	         dut.cpu.dmu.sn_ph, dut.cpu.dmu.sn_req, dut.cpu.dmu.steal, dut.cpu.dmu.steal_q, dut.cpu.dmu.st_set,
	         dut.cpu.dmu.dw, dut.cpu.dmu.dw_set, dut.cpu.dmu.dw_way, dut.cpu.dmu.dw_src,
	         dut.cpu.dmu.tw_b, dut.cpu.dmu.tset_b, dut.cpu.dmu.e_st, dut.cpu.dmu.e_job,
	         dut.cpu.dmu.b_req, dut.cpu.dmu.b_gnt, dut.cpu.dmu.b_done,
	         dut.cpu.dmu.adv_dc2, dut.cpu.dmu.dc2_rdy, dut.cpu.dmu.m2.r.v, dut.cpu.dmu.m2.r.a, dut.cpu.dmu.m2.x.hit, dut.cpu.dmu.m2.x.way,
	         dut.cpu.dmu.m2.x.pa, dut.cpu.dmu.m2.fast, dut.cpu.dmu.dq_new, dut.cpu.dmu.dq2, dut.cpu.dmu.fast_data,
	         dut.cpu.dmu.e_dc2_done, dut.cpu.dmu.ldata,
	         dut.cpu.be.adv_ex, dut.cpu.be.ex_u.pc, cpu_rpc);
end

// the DMU mirrors the back end's DC1 and DC2: a memory uop the back end
// advances out of either stage must have its record there, else the DMU
// answers "ready" for an empty DC2 (dc2_rdy = !m2.r.v) with whatever is on
// its fast-path data bus
integer dmu_lost = 0;
always @(posedge clk_cpu) if (!reset && saw_kernel && !wildpc_seen) begin
	if (dut.cpu.be.adv_dc1 && dut.cpu.be.dc1_u.mem != 2'd0 && dut.cpu.be.dc1_u.exc == 8'd0 && !dut.cpu.dmu.m1.v) begin
		dmu_lost = dmu_lost + 1;
		if (dmu_lost <= 50) $display("[%0t] DMU-LOST dc1: pc=%08x mem=%0d (back end advances DC1, DMU m1.v=0, m1.a=%08x)",
		                             $time, dut.cpu.be.dc1_u.pc, dut.cpu.be.dc1_u.mem, dut.cpu.dmu.m1.a);
	end
	if (dut.cpu.be.adv_dc2 && dut.cpu.be.dc2_u.mem != 2'd0 && dut.cpu.be.dc2_u.exc == 8'd0 && !dut.cpu.dmu.m2.r.v) begin
		dmu_lost = dmu_lost + 1;
		if (dmu_lost <= 50) $display("[%0t] DMU-LOST dc2: pc=%08x mem=%0d ea=%08x ldata=%08x (back end advances DC2, DMU m2.r.v=0)",
		                             $time, dut.cpu.be.dc2_u.pc, dut.cpu.be.dc2_u.mem, dut.cpu.be.dc2_ea, dut.cpu.dmu.ldata);
	end
end

// +dumpdir=<dir>: at the panic trap, write <dir>/ram.bin (the 64 MB of
// guest RAM as the bench memory holds it, big endian, lines still dirty in
// the CPU's data cache NOT included), <dir>/memring.txt (the whole memory
// ring), <dir>/walks.txt (the core's last 4096 table-walk descriptor
// evaluations: VA, level, descriptor address and value, cache hit, and how
// each walk ended) and <dir>/excs.txt (the last 4096 exceptions).
reg [8*256-1:0] dumpdir;
reg            dump_en = 0;
initial dump_en = $value$plusargs("dumpdir=%s", dumpdir);
// table walks: E_TW_EVAL is DMU state 42, E_TW_DONE 46 (ap68040_dmu.sv est_t)
reg [31:0] tw_va_r [0:4095], tw_da_r [0:4095], tw_d_r [0:4095];
reg  [7:0] tw_k_r  [0:4095];    // {done, fail, berr, hit, s, wr, lvl[1:0]}
longint    tw_t_r  [0:4095];
integer    tw_n = 0;
always @(posedge clk_cpu) if (!reset && dump_en && saw_kernel && !wildpc_seen) begin
	if (dut.cpu.dmu.e_st == 6'd42 || dut.cpu.dmu.e_st == 6'd46) begin
		tw_va_r[tw_n % 4096] <= dut.cpu.dmu.tw_va;
		tw_da_r[tw_n % 4096] <= dut.cpu.dmu.tw_da;
		tw_d_r [tw_n % 4096] <= dut.cpu.dmu.tw_d;
		tw_k_r [tw_n % 4096] <= {dut.cpu.dmu.e_st == 6'd46, dut.cpu.dmu.tw_fail, dut.cpu.dmu.tw_berr,
		                         dut.cpu.dmu.tw_hhq, dut.cpu.dmu.tw_s, dut.cpu.dmu.tw_wr, 2'(dut.cpu.dmu.tw_lvl)};
		tw_t_r [tw_n % 4096] <= $time / 5;
		tw_n = tw_n + 1;
	end
end
// exceptions
reg [31:0] xe_pc [0:4095], xe_addr [0:4095], xe_rpc [0:4095];
reg [15:0] xe_ssw [0:4095], xe_sr [0:4095];
reg  [7:0] xe_vec [0:4095];
longint    xe_t [0:4095];
integer    xe_n = 0;
always @(posedge clk_cpu) if (!reset && dump_en && saw_kernel && !wildpc_seen && dut.cpu.be.x_go) begin
	xe_vec [xe_n % 4096] <= dut.cpu.be.x_vec;
	xe_pc  [xe_n % 4096] <= dut.cpu.be.x_pc;
	xe_addr[xe_n % 4096] <= dut.cpu.be.x_addr;
	xe_ssw [xe_n % 4096] <= dut.cpu.be.x_ssw;
	xe_sr  [xe_n % 4096] <= cpu_sr;
	xe_rpc [xe_n % 4096] <= cpu_rpc;
	xe_t   [xe_n % 4096] <= $time / 5;
	xe_n = xe_n + 1;
end
task dump_files;
	integer fd, i, j;
	reg [31:0] w;
	begin
		fd = $fopen({dumpdir, "/ram.bin"}, "wb");
		for (i = 0; i < 16777216; i = i + 1) begin
			w = ram_mem[i];
			$fwrite(fd, "%c%c%c%c", w[31:24], w[23:16], w[15:8], w[7:0]);
		end
		$fclose(fd);
		fd = $fopen({dumpdir, "/memring.txt"}, "w");
		for (i = (mr_n > 4096 ? mr_n - 4096 : 0); i < mr_n; i = i + 1)
			$fwrite(fd, "t=%0d pc=%08x %s%s sz=%0d ea=%08x v=%08x\n", mr_t[i % 4096], mr_pc[i % 4096],
			        mr_k[i % 4096][3] ? "ST" : "LD", mr_k[i % 4096][2] ? "/RMW" : "", mr_k[i % 4096][1:0],
			        mr_ea[i % 4096], mr_v[i % 4096]);
		$fclose(fd);
		fd = $fopen({dumpdir, "/walks.txt"}, "w");
		for (i = (tw_n > 4096 ? tw_n - 4096 : 0); i < tw_n; i = i + 1)
			if (tw_k_r[i % 4096][7])
				$fwrite(fd, "t=%0d DONE va=%08x fail=%0d berr=%0d s=%0d wr=%0d\n", tw_t_r[i % 4096], tw_va_r[i % 4096],
				        tw_k_r[i % 4096][6], tw_k_r[i % 4096][5], tw_k_r[i % 4096][3], tw_k_r[i % 4096][2]);
			else
				$fwrite(fd, "t=%0d EVAL va=%08x lvl=%0d da=%08x d=%08x hit=%0d s=%0d wr=%0d\n", tw_t_r[i % 4096],
				        tw_va_r[i % 4096], tw_k_r[i % 4096][1:0], tw_da_r[i % 4096], tw_d_r[i % 4096],
				        tw_k_r[i % 4096][4], tw_k_r[i % 4096][3], tw_k_r[i % 4096][2]);
		$fclose(fd);
		fd = $fopen({dumpdir, "/excs.txt"}, "w");
		for (i = (xe_n > 4096 ? xe_n - 4096 : 0); i < xe_n; i = i + 1)
			$fwrite(fd, "t=%0d vec=%0d pc=%08x xpc=%08x addr=%08x ssw=%04x sr=%04x\n", xe_t[i % 4096], xe_vec[i % 4096],
			        xe_rpc[i % 4096], xe_pc[i % 4096], xe_addr[i % 4096], xe_ssw[i % 4096], xe_sr[i % 4096]);
		$fclose(fd);
		$display("[%0t] DUMP: ram.bin, memring.txt (%0d), walks.txt (%0d), excs.txt (%0d) in %0s", $time, mr_n, tw_n, xe_n, dumpdir);
	end
endtask

task dump_memring;
	integer i, base;
	reg [31:0] w;
	begin
		w = memwatch ? memwatch : cpu_reg[10];
		base = mr_n > 4096 ? mr_n - 4096 : 0;
		$display("--- memory operations within 64 bytes of %08x (of the last %0d) ---", w, mr_n - base);
		for (i = base; i < mr_n; i = i + 1)
			if (mr_ea[i % 4096] >= w - 64 && mr_ea[i % 4096] < w + 64)
				$display("  t=%0d pc=%08x %s%s sz=%0d ea=%08x (+%02x) v=%08x", mr_t[i % 4096], mr_pc[i % 4096],
				         mr_k[i % 4096][3] ? "ST" : "LD", mr_k[i % 4096][2] ? "/RMW" : "", mr_k[i % 4096][1:0],
				         mr_ea[i % 4096], mr_ea[i % 4096] - w, mr_v[i % 4096]);
		$display("--- the last 48 memory operations ---");
		for (i = (mr_n > 48 ? mr_n - 48 : 0); i < mr_n; i = i + 1)
			$display("  t=%0d pc=%08x %s%s sz=%0d ea=%08x v=%08x", mr_t[i % 4096], mr_pc[i % 4096],
			         mr_k[i % 4096][3] ? "ST" : "LD", mr_k[i % 4096][2] ? "/RMW" : "", mr_k[i % 4096][1:0],
			         mr_ea[i % 4096], mr_v[i % 4096]);
	end
endtask

// +panictrace: the last 64 retired instructions before the bad jump, with
// the SR and the active stack pointer at each (the bus monitor above has
// the bus beats; cache hits leave no bus trace)
reg [31:0] ptr_pc [0:63], ptr_a7 [0:63];
reg [15:0] ptr_sr [0:63];
integer ptr_n = 0;
always @(posedge clk_cpu) if (!reset && panic_trace && saw_kernel && !wildpc_seen && cpu_retire) begin
	ptr_pc[ptr_n % 64] <= cpu_rpc;
	ptr_sr[ptr_n % 64] <= cpu_sr;
	ptr_a7[ptr_n % 64] <= cpu_a7;
	ptr_n <= ptr_n + 1;
end

// +exctrace: log exception entries once the kernel runs (the vector, the
// PC of the instruction, the exception's own PC and address arguments,
// SR, the active A7) and, on a processor halt (double fault), the core's
// state, the words around the halting PC in physical RAM and the
// +panictrace retirements.
reg exctrace = 0;
initial exctrace = $test$plusargs("exctrace");
reg halted_prev = 0;
integer exc_n = 0, ex_i;
always @(posedge clk_cpu) if (!reset) begin
	if (exctrace && saw_kernel && dut.cpu.be.x_go && exc_n < 400) begin
		$display("[%0t] EXC: vec=%0d pc=%08x xpc=%08x addr=%08x sr=%04x sp=%08x",
		         $time, dut.cpu.be.x_vec, cpu_rpc, dut.cpu.be.x_pc,
		         dut.cpu.be.x_addr, cpu_sr, cpu_a7);
		exc_n = exc_n + 1;
	end
	halted_prev <= dbg_halted;
	if (exctrace && dbg_halted && !halted_prev) begin
		$display("[%0t] HALT: double fault. pc=%08x sr=%04x sp=%08x vbr=%08x last exception vec=%0d xpc=%08x addr=%08x",
		         $time, cpu_rpc, cpu_sr, cpu_a7, dut.cpu.vbr,
		         dut.cpu.be.x_vec, dut.cpu.be.x_pc, dut.cpu.be.x_addr);
		$display("  RAM around pc (physical = pc - 0x04000000 assumed):");
		for (ex_i = -8; ex_i < 8; ex_i = ex_i + 1)
			$display("    %08x: %08x", cpu_rpc + ex_i*4,
			         ram_mem[((cpu_rpc - 32'h04000000) >> 2) + ex_i]);
		$display("  RAM around sp:");
		for (ex_i = -4; ex_i < 12; ex_i = ex_i + 1)
			$display("    %08x: %08x", cpu_a7 + ex_i*4,
			         ram_mem[((cpu_a7 - 32'h04000000) >> 2) + ex_i]);
		// NS3.3 vm_page_lookup: the bucket table pointer and hash mask live at
		// $040c4338/$040c433c; an empty bucket is a self-pointer, never 0
		begin : buckets
			reg [31:0] tab, mask; integer zeros, k;
			tab = ram_mem[(32'h040c4338 - 32'h04000000) >> 2];
			mask = ram_mem[(32'h040c433c - 32'h04000000) >> 2];
			zeros = 0;
			for (k = 0; k <= mask && k < 65536; k = k + 1)
				if (ram_mem[((tab - 32'h04000000) >> 2) + 2*k] == 0) zeros = zeros + 1;
			$display("  vm_page_buckets=%08x mask=%08x: %0d of %0d buckets read 0 in RAM", tab, mask, zeros, mask + 1);
			for (k = 0; k < 8; k = k + 1)
				$display("    bucket %0d @%08x: next=%08x prev=%08x", k, tab + 8*k,
				         ram_mem[((tab - 32'h04000000) >> 2) + 2*k], ram_mem[((tab - 32'h04000000) >> 2) + 2*k + 1]);
		end
		dump_panic_trace;
		halt_run <= 1;
	end
end

task dump_panic_trace;
	integer i, base;
	begin
		$display("CPU: pc=%08x sr=%04x sp=%08x halted=%b", cpu_rpc, cpu_sr, cpu_a7, dbg_halted);
		base = ptr_n > 64 ? ptr_n - 64 : 0;
		$display("--- last %0d retired instructions (enable with +panictrace) ---", ptr_n - base);
		for (i = base; i < ptr_n; i = i + 1)
			$display("pc=%08x sr=%04x sp=%08x", ptr_pc[i % 64], ptr_sr[i % 64], ptr_a7[i % 64]);
	end
endtask

task key_event;
	input make;
	input ext;
	input [7:0] code;
	begin
		@(posedge clk);
		ps2 <= {~ps2[10], make, ext, code};
		repeat (1000000) @(posedge clk);
	end
endtask

task type_key;
	input ext;
	input [7:0] code;
	begin
		key_event(1'b1, ext, code);
		key_event(1'b0, ext, code);
	end
endtask

// Short events for the interrupt-wiring test; no ROM UI pacing is needed.
task power_key_event;
	input make;
	input ext;
	input [7:0] code;
	begin
		@(negedge clk);
		ps2 = {~ps2[10], make, ext, code};
		repeat (8) @(negedge clk);
	end
endtask

task type_shift_key;
	input [7:0] code;
	begin
		key_event(1'b1, 1'b0, 8'h12); // left shift down
		type_key(1'b0, code);
		key_event(1'b0, 1'b0, 8'h12); // left shift up
	end
endtask

initial begin
	if ($value$plusargs("typew_mc=%d", typew_delay_mc)) begin
		repeat (typew_delay_mc) begin
			repeat (1000000) @(posedge clk);
		end
		$display("[%0t] BOOT: typing w<return>", $time);
		type_key(1'b0, 8'h1D); // w
		type_key(1'b0, 8'h5A); // return
	end
end

initial begin
	if ($value$plusargs("typesd_mc=%d", typesd_delay_mc)) begin
		repeat (typesd_delay_mc) begin
			repeat (1000000) @(posedge clk);
		end
		$display("[%0t] BOOT: typing sd(0,0,0)<return>", $time);
		type_key(1'b0, 8'h1B);       // s
		type_key(1'b0, 8'h23);       // d
		type_shift_key(8'h46);       // (
		type_key(1'b0, 8'h45);       // 0
		type_key(1'b0, 8'h41);       // ,
		type_key(1'b0, 8'h45);       // 0
		type_key(1'b0, 8'h41);       // ,
		type_key(1'b0, 8'h45);       // 0
		type_shift_key(8'h45);       // )
		type_key(1'b0, 8'h5A);       // return
	end
end

// The disk bootloader also executes at 0x04xxxxxx (e.g. 0x04381930).
// Only the kernel's actual entry point establishes a completed kernel load.
always @(posedge clk_cpu) if (!reset && (bootsd || bootcd) && cpu_retire && cpu_rpc == kernel_entry && !saw_kernel) begin
	$display("[%0t] BOOT: kernel entry %08x", $time, kernel_entry);
	saw_kernel <= 1;
	if (stop_at_kernel) halt_run <= 1;
end

task check;
	input cond;
	input [639:0] name;
	begin
		if (cond) $display("PASS: %0s", name);
		else begin
			$display("FAIL: %0s", name);
			errors = errors + 1;
		end
	end
endtask

//----------------------------------------------------------------------------
// +bootsd: a 2048 block disk image on the SD model and the boot device
// menu at Disk, to drive the ROM's SCSI boot path ("sd" boot command).
// The image carries a byte pattern, not a real filesystem: the pass
// criteria are that the ROM selects the disk, the target serves sector
// reads and the DMA channel lands them in memory.
//----------------------------------------------------------------------------


reg        bootsd = 0;

//----------------------------------------------------------------------------
// +bootcd: the block image on BOTH the disk slot (target 0) and the
// CD-ROM slot (target 3) with the boot device menu at CD-ROM.  The
// ROM's "sd(unit,lun,part)" numbers disks in scan order, so the CD-ROM
// behind a disk is unit 1 and the NVRAM must carry "sd(1,0,0)" (what
// NeXTSTEP itself calls it).  This is a selection/probe test: the v66
// ROM must consume that exact command and issue an INQUIRY to target 3.
// It does not read a boot sector from a type-05 CD-ROM.
//----------------------------------------------------------------------------

reg        bootcd = 0;
reg        cimg_mounted = 0;
reg        bootcd_nvram_ok = 0;

// +mountpolicy exercises next_system's per-slot media bookkeeping while
// reset is held.  The state is restored to empty before the ROM starts.
reg        mountpolicy = 0;

//----------------------------------------------------------------------------
// +bootfd: a 1.44 MB floppy on the second image slot with the boot
// device set to Floppy, so the ROM's own floppy driver runs - which is
// the only way to see what it programs into the shared DMA channel.
//----------------------------------------------------------------------------

reg         bootfd = 0;
reg   [1:0] fimg_mounted = 0;
reg  [63:0] fimg_bytes = 0;
wire [31:0] fsd_lba;
wire        fsd_rd, fsd_wr;
reg         fsd_ack = 0;
reg   [8:0] fsd_buff_addr = 0;
reg   [7:0] fsd_buff_dout = 0;
wire  [7:0] fsd_buff_din;
reg         fsd_buff_wr = 0;

reg  [7:0] fdisk [0:2880*512-1];
integer    fdi;
initial for (fdi = 0; fdi < 2880*512; fdi = fdi + 1)
	fdisk[fdi] = fdi[7:0] ^ {fdi[16:9], 1'b0};

reg fsd_act = 0;
integer fsd_reads = 0;
always @(posedge clk) begin
	fsd_buff_wr <= 0;
	if (fsd_rd && !fsd_ack && !fsd_act) begin
		fsd_ack <= 1; fsd_act <= 1; fsd_buff_addr <= 0;
		fsd_reads = fsd_reads + 1;
		if (fsd_reads < 40)
			$display("[%0t] FD: read lba %0d", $time, fsd_lba);
	end
	else if (fsd_ack && fsd_act) begin
		if (!fsd_buff_wr) begin
			fsd_buff_dout <= fdisk[{fsd_lba[11:0], 9'd0} + {23'd0, fsd_buff_addr}];
			fsd_buff_wr <= 1;
			if (fsd_buff_addr == 9'd511) begin fsd_ack <= 0; fsd_act <= 0; end
		end
		else begin
			if (fsd_buff_addr != 9'd511) fsd_buff_addr <= fsd_buff_addr + 1'd1;
		end
	end
end

// every register the ROM's floppy driver touches, and the controller's
// answer: this is the conversation the "DMA buf overflow" ends
integer fdreg_n = 0;
always @(posedge clk) if (bootfd && !reset && dut.io_flp && dut.state == 2'd1) begin
	if (fdreg_n < 120) begin
		if (is_write)
			$display("[%0t] FDREG wr +%0d = %04x", $time, dut.io_off[3:0],
			         cpu_dout);
		else
			$display("[%0t] FDREG rd +%0d -> %04x", $time, dut.io_off[3:0],
			         cpu_din);
	end
	fdreg_n = fdreg_n + 1;
end

// what the ROM programs into the shared channel, and what the transfer
// does with it: this is the accounting the ROM checks afterwards
reg [31:0] dnext_d = 0, dlimit_d = 0;
reg [31:0] scdma_addr [0:63];
reg [31:0] scdma_data [0:63];
integer scdma_n = 0;
reg  [7:0] dcsr_d = 0;
always @(posedge clk) if (bootfd && !reset) begin
	// SCSI DMA channel writes to memory: address and data, frozen at
	// the fatal bus error, to see what READ CAPACITY delivered.
	if (berr_count < 2 && dut.scsi.m_req && dut.scsi.m_we && dut.scsi.m_ack
	    && scdma_n < 64) begin
		scdma_addr[scdma_n] <= {dut.scsi.m_addr, 2'b00};
		scdma_data[scdma_n] <= dut.scsi.m_din;
		scdma_n = scdma_n + 1;
	end
	if (dut.scsi.d_next != dnext_d && dut.scsi.flp_active)
		dnext_d <= dut.scsi.d_next;
	if (dut.scsi.d_limit != dlimit_d) begin
		dlimit_d <= dut.scsi.d_limit;
		$display("[%0t] FD chan: next %08x limit %08x csr %02x", $time,
		         dut.scsi.d_next, dut.scsi.d_limit, dut.scsi.d_csr);
	end
	if (dut.scsi.d_csr != dcsr_d) begin
		dcsr_d <= dut.scsi.d_csr;
		$display("[%0t] FD csr: %02x  next %08x limit %08x", $time,
		         dut.scsi.d_csr, dut.scsi.d_next, dut.scsi.d_limit);
	end
end

reg  [2:0] img_mounted = 0;
wire [31:0] sd_lba;
wire        sd_rd, sd_wr;
reg         sd_ack = 0;
reg  [12:0] sd_buff_addr = 0;     // one buffer bus for the SCSI and MO slots
reg   [7:0] sd_buff_dout = 0;
wire  [7:0] sd_buff_din;
reg         sd_buff_wr = 0;
wire  [5:0] sd_blk_cnt, osd_blk_cnt;
// the MO slot: no cartridge, only the ECC exchange (a 3-block window)
wire [31:0] osd_lba;
wire        osd_rd, osd_wr;
wire  [7:0] osd_buff_din;
reg         osd_ack = 0;

reg  [7:0] disk [0:2048*512-1];

// +img=<path>: a raw disk image file backs the SD model instead of
// the built-in pattern (copy the image first, writes go back to it)
string     img_path;
integer    img_fd = 0;
integer    img_blk = 0;
reg [63:0] img_bytes = 64'd1048576;
reg  [7:0] fbuf [0:511];
integer    fr;

initial begin
	if ($value$plusargs("img=%s", img_path)) begin
		img_fd = $fopen(img_path, "rb+");
		if (img_fd == 0) begin
			$display("cannot open %0s", img_path);
			$finish;
		end
		// size: +imgblk=<512-byte blocks> is authoritative (robust across
		// simulators); fall back to seek/tell
		if ($value$plusargs("imgblk=%d", img_blk))
			img_bytes = {32'd0, img_blk} * 64'd512;
		else begin
			fr = $fseek(img_fd, 0, 2);
			img_bytes = $ftell(img_fd);
		end
		fr = $fseek(img_fd, 0, 0);
		// confirm the data path: read sector 0 and show the disklabel
		fr = $fread(fbuf, img_fd);
		$display("BOOT: disk image %0s, %0d bytes; label %02x %02x %02x %02x '%c%c%c%c'",
		         img_path, img_bytes,
		         fbuf[0], fbuf[1], fbuf[2], fbuf[3],
		         fbuf[0], fbuf[1], fbuf[2], fbuf[3]);
	end
end

function [7:0] dpat;
	input [31:0] blk;
	input [31:0] off;
	begin
		dpat = blk[7:0] ^ off[7:0] ^ {off[10:8], 5'd0};
	end
endfunction

integer sdi;
initial for (sdi = 0; sdi < 2048*512; sdi = sdi + 1)
	disk[sdi] = dpat(sdi / 512, sdi % 512);

reg sd_rd_act = 0, sd_wr_act = 0, sd_rphase = 0, img_flush = 0;
integer sd_reads = 0;
reg sd_lba0 = 0;
// A window transaction (lba >= 0x7C000000) is served by the HPS model;
// the MO slot shares the buffer bus and only ever carries windows.
reg         sd_win = 0;
reg  [12:0] sd_last = 13'd511;
reg         osd_rd_act = 0, osd_wr_act = 0;
integer     hr;
// +hostlat=<clocks>: the HPS answers a window request only after this many
// clocks (Main's poll cadence is milliseconds; the default answers at once)
integer     hostlat = 0;
integer     hl_cnt = 0;
initial if ($value$plusargs("hostlat=%d", hostlat)) ;
wire        hl_ok = (hl_cnt >= hostlat);
always @(posedge clk) begin
	if ((sd_rd && sd_lba >= 32'h7C00_0000) || (sd_wr && sd_lba >= 32'h7C00_0000) || osd_rd || osd_wr) begin
		if (!sd_ack && !osd_ack && hl_cnt < hostlat) hl_cnt <= hl_cnt + 1;
	end
	else hl_cnt <= 0;
	if (sd_ack || osd_ack) hl_cnt <= 0;
end

// the mounts, as user_io's mount hook reports them to the HPS
always @(negedge clk) begin
	if (img_mounted[0]) hr = host_mount_disk(0, img_bytes);
	if (img_mounted[2]) hr = host_mount_disk(2, img_bytes);
	if (cimg_mounted) begin
		if (img_fd != 0) hr = host_mount_cd(img_path);
		else hr = host_mount_disk(3, img_bytes);
	end
end

always @(posedge clk) begin
	sd_buff_wr <= 0;
	if (!sd_ack && !osd_ack && sd_rd && (sd_lba < 32'h7C00_0000 || hl_ok)) begin
		sd_ack <= 1;
		sd_rd_act <= 1;
		sd_buff_addr <= 0;
		sd_win <= (sd_lba >= 32'h7C00_0000);
		sd_last <= ({7'd0, sd_blk_cnt} + 13'd1) * 13'd512 - 13'd1;
		if (sd_lba >= 32'h7C00_0000)
			hr = host_fill(3, sd_lba, ({26'd0, sd_blk_cnt} + 32'd1) * 32'd512);
		else begin
			sd_reads = sd_reads + 1;
			if (sd_lba == 0) sd_lba0 <= 1;
			if (img_fd != 0) begin
				fr = $fseek(img_fd, {sd_lba, 9'd0}, 0);
				fr = $fread(fbuf, img_fd);
			end
			if (sd_reads < 200 || (sd_reads % 256) == 0)
				$display("[%0t] BOOT: SD read lba %0d", $time, sd_lba);
		end
	end
	else if (sd_ack && sd_rd_act) begin
		if (!sd_buff_wr) begin
			sd_buff_dout <= sd_win ? host_byte(sd_buff_addr) :
			                (img_fd != 0) ? fbuf[sd_buff_addr[8:0]]
			              : disk[{sd_lba[10:0], 9'd0} + {23'd0, sd_buff_addr[8:0]}];
			sd_buff_wr <= 1;
			if (sd_buff_addr == sd_last) begin
				sd_ack <= 0;
				sd_rd_act <= 0;
			end
		end
		else begin
			if (sd_buff_addr != sd_last) sd_buff_addr <= sd_buff_addr + 1'd1;
		end
	end
	else if (!sd_ack && !osd_ack && sd_wr && (sd_lba < 32'h7C00_0000 || hl_ok)) begin
		sd_ack <= 1;
		sd_wr_act <= 1;
		sd_buff_addr <= 0;
		sd_rphase <= 0;
		sd_win <= (sd_lba >= 32'h7C00_0000);
		sd_last <= ({7'd0, sd_blk_cnt} + 13'd1) * 13'd512 - 13'd1;
		if (sd_lba < 32'h7C00_0000)
			$display("[%0t] BOOT: SD write lba %0d", $time, sd_lba);
	end
	else if (sd_ack && sd_wr_act) begin
		if (sd_rphase) begin
			if (sd_win) host_put(sd_buff_addr, sd_buff_din);
			else if (img_fd != 0) fbuf[sd_buff_addr[8:0]] <= sd_buff_din;
			else disk[{sd_lba[10:0], 9'd0} + {23'd0, sd_buff_addr[8:0]}] <= sd_buff_din;
			sd_rphase <= 0;
			if (sd_buff_addr == sd_last) begin
				sd_ack <= 0;
				sd_wr_act <= 0;
				if (sd_win) host_exec(3, sd_lba, {19'd0, sd_last} + 32'd1);
				else if (img_fd != 0) img_flush <= 1;
			end
			else sd_buff_addr <= sd_buff_addr + 1'd1;
		end
		else sd_rphase <= 1;
	end
	// the MO slot's ECC exchange
	else if (!sd_ack && !osd_ack && osd_rd && hl_ok) begin
		osd_ack <= 1;
		osd_rd_act <= 1;
		sd_buff_addr <= 0;
		sd_last <= ({7'd0, osd_blk_cnt} + 13'd1) * 13'd512 - 13'd1;
		hr = host_fill(5, osd_lba, ({26'd0, osd_blk_cnt} + 32'd1) * 32'd512);
	end
	else if (osd_ack && osd_rd_act) begin
		if (!sd_buff_wr) begin
			sd_buff_dout <= host_byte(sd_buff_addr);
			sd_buff_wr <= 1;
			if (sd_buff_addr == sd_last) begin
				osd_ack <= 0;
				osd_rd_act <= 0;
			end
		end
		else if (sd_buff_addr != sd_last) sd_buff_addr <= sd_buff_addr + 1'd1;
	end
	else if (!sd_ack && !osd_ack && osd_wr && hl_ok) begin
		osd_ack <= 1;
		osd_wr_act <= 1;
		sd_buff_addr <= 0;
		sd_rphase <= 0;
		sd_last <= ({7'd0, osd_blk_cnt} + 13'd1) * 13'd512 - 13'd1;
	end
	else if (osd_ack && osd_wr_act) begin
		if (sd_rphase) begin
			host_put(sd_buff_addr, osd_buff_din);
			sd_rphase <= 0;
			if (sd_buff_addr == sd_last) begin
				osd_ack <= 0;
				osd_wr_act <= 0;
				host_exec(5, osd_lba, {19'd0, sd_last} + 32'd1);
			end
			else sd_buff_addr <= sd_buff_addr + 1'd1;
		end
		else sd_rphase <= 1;
	end
	if (img_flush) begin : wrback
		integer k;
		img_flush <= 0;
		fr = $fseek(img_fd, {sd_lba, 9'd0}, 0);
		for (k = 0; k < 512; k = k + 1) $fwrite(img_fd, "%c", fbuf[k]);
		$fflush(img_fd);
	end
end

// +walktrace: every table-walk beat of the CPU (the 68040 reads and
// updates its descriptors on the bus, transfer modifier 3 or 4; the
// bridge holds the modifier of the transfer in progress).  An invalid
// descriptor is an access error that +exctrace shows as vector 2.
reg wtrace = 0;
initial wtrace = $test$plusargs("walktrace");
always @(posedge clk) if (!reset && wtrace && mem_ready &&
                         (dut.cpubus.xtm == 3'd3 || dut.cpubus.xtm == 3'd4))
	$display("[%0t] WALK %s %08x %s %08x pc=%08x", $time, is_write ? "wr" : "rd", cpu_addr,
	         is_write ? "=" : "->", is_write ? cpu_dout : cpu_din, dbg_pc);

// ESP activity trace: selection commands and DMA writes to memory
reg saw_esp_sel = 0;
integer scsi_dma_writes = 0;
integer scsi_cmds = 0;             // SCSI commands traced after the boot selection
reg [7:0] esp_cmd_d = 0;
always @(posedge clk) if (!reset && (bootsd || bootcd)) begin
	if (dut.scsi.command0 != esp_cmd_d) begin
		esp_cmd_d <= dut.scsi.command0;
		if ((dut.scsi.command0 & 8'h7F) == 8'h41 ||
		    (dut.scsi.command0 & 8'h7F) == 8'h42) begin
			if (!saw_esp_sel) begin
				$display("[%0t] BOOT: ESP select command %02x, target %0d (present %0d)",
				         $time, dut.scsi.command0, dut.scsi.selectbusid[2:0],
				         dut.scsi.disk_present_v[dut.scsi.selectbusid[2:0]]);
			end
			else if (scsi_cmds <= 24)
				$display("[%0t] SCSI: select target %0d (present %0d)", $time,
				         dut.scsi.selectbusid[2:0],
				         dut.scsi.disk_present_v[dut.scsi.selectbusid[2:0]]);
			saw_esp_sel <= 1;
		end
	end
	if (dut.sc_m_req && dut.sc_m_we && dut.sc_m_ack)
		scsi_dma_writes = scsi_dma_writes + 1;
end

// +bootcd verifies the NVRAM boot command: sd(1,0,0) must steer the ROM to
// SELECT and INQUIRY SCSI target 3 (unit 1 in scan order, behind the disk on
// target 0).  It does not assert a completed boot: the Rev 2.5 v66 ROM's
// sd() blk0-boot path drives a direct-access (type 0) device, and re-issues
// INQUIRY without reading a sector when the target reports the CD-ROM type
// (0x05) - which the CD must report so the floppy installer's "Searching
// for CD-ROM drives" scan finds it.  Booting the install medium therefore
// runs the documented way: boot the floppy, root on the CD (sd1a).
reg saw_t3_inquiry = 0;
always @(posedge clk) if (!reset && bootcd && saw_esp_sel &&
                          dut.scsi.phase == 3'd3 && dut.scsi.t_unit == 3'd3 &&
                          dut.scsi.cdb0 == 8'h12 && dut.scsi.cdb1[7:5] == 3'd0)
	saw_t3_inquiry <= 1;

// SCSI conversation trace after the ROM's boot selection: one line per
// command as the target enters its status phase (opcode + status), and
// every ESP interrupt-status change (a selection timeout shows up as the
// disconnect bit with no command behind it).  POST's own SCSI tests run
// before saw_esp_sel and are excluded.
reg [2:0] scsi_phase_d = 0;
reg [7:0] scsi_ist_d = 0;
always @(posedge clk) if (!reset && (bootsd || bootcd) && saw_esp_sel) begin
	scsi_phase_d <= dut.scsi.phase;
	if (dut.scsi.phase == 3'd3 && scsi_phase_d != 3'd3) begin
		scsi_cmds = scsi_cmds + 1;
		if (scsi_cmds <= 24)
			$display("[%0t] SCSI: target %0d cmd %02x %02x %02x %02x %02x %02x -> status %02x",
			         $time, dut.scsi.t_unit,
			         dut.scsi.cdb0, dut.scsi.cdb1, dut.scsi.cdb2,
			         dut.scsi.cdb3, dut.scsi.cdb4, dut.scsi.cdb5, dut.scsi.t_status);
	end
	scsi_ist_d <= dut.scsi.intstatus;
	if (dut.scsi.intstatus != scsi_ist_d && dut.scsi.intstatus != 0 && scsi_cmds <= 24)
		$display("[%0t] SCSI: ESP intstatus %02x", $time, dut.scsi.intstatus);
end

// 1120x832 2bpp NeXT gray to PGM: 0 = white, 3 = black, line pitch
// 288 bytes (1120/4 active plus 8 pad), even address byte in mem_hi
string fb_path;   // +fbout=<path> chooses the dump file (parallel runs)
task fb_dump;
	integer fd, y, xb, p;
	reg [7:0] b;
	begin
		if (!$value$plusargs("fbout=%s", fb_path)) fb_path = "build/fb.pgm";
		fd = $fopen(fb_path, "wb");
		$fwrite(fd, "P5\n1120 832\n255\n");
		for (y = 0; y < 832; y = y + 1) begin
			for (xb = 0; xb < 280; xb = xb + 1) begin : row
				integer ba;
				ba = y * 288 + xb;
				b = ba[0] ? dut.vram.mem_lo.mem[ba >> 1]
				          : dut.vram.mem_hi.mem[ba >> 1];
				for (p = 3; p >= 0; p = p - 1)
					$fwrite(fd, "%c", 8'd255 - {6'd0, b[2*p +: 2]} * 8'd85);
			end
		end
		$fclose(fd);
		$display("BOOT: framebuffer written to build/fb.pgm");
	end
endtask

initial begin
	if ($test$plusargs("dump")) begin
		$dumpfile("build/tb_next_boot.vcd");
		$dumpvars(0, tb_next_boot);
	end

	if ($test$plusargs("bootfd")) begin
		bootfd = 1;
		fimg_bytes = 64'd1474560;
	end
	if ($test$plusargs("mountpolicy")) mountpolicy = 1;
	if ($test$plusargs("netoff")) net_enable = 0;

	if (mountpolicy) begin
		// HDD targets retain independent state: ejecting target 0 must not
		// erase target 2, and the CD event at target 3 must not count as an
		// HDD for Auto boot policy.
		img_bytes = 64'd1048576;
		@(posedge clk); img_mounted <= 3'b001;
		@(posedge clk); img_mounted <= 3'b000;
		repeat (2) @(posedge clk);
		check(dut.sd_lower_mounted == 3'b001,
		      "mount policy: target-0 HDD state is recorded");

		@(posedge clk); img_mounted <= 3'b100;
		@(posedge clk); img_mounted <= 3'b000;
		repeat (2) @(posedge clk);
		check(dut.sd_lower_mounted == 3'b101,
		      "mount policy: multiple HDD targets are retained independently");

		img_bytes = 64'd0;
		@(posedge clk); img_mounted <= 3'b001;
		@(posedge clk); img_mounted <= 3'b000;
		repeat (2) @(posedge clk);
		check(dut.sd_lower_mounted == 3'b100,
		      "mount policy: ejecting one HDD preserves another target");

		img_bytes = 64'd1048576;
		@(posedge clk); cimg_mounted <= 1'b1;
		@(posedge clk); cimg_mounted <= 1'b0;
		repeat (2) @(posedge clk);
		check(dut.sd_lower_mounted == 3'b100,
		      "mount policy: target-3 CD is excluded from Auto HDD state");

		img_bytes = 64'd0;
		@(posedge clk); img_mounted <= 3'b100;
		@(posedge clk); img_mounted <= 3'b000;
		repeat (2) @(posedge clk);
		check(dut.sd_lower_mounted == 3'b000,
		      "mount policy: HDD state is empty while the CD remains mounted");
		check(dut.scr.nvram[18] == 8'h00 && dut.scr.nvram[19] == 8'h00,
		      "mount policy: CD-only Auto leaves the boot command empty");

		@(posedge clk); cimg_mounted <= 1'b1;
		@(posedge clk); cimg_mounted <= 1'b0;
		repeat (2) @(posedge clk);
		check(!dut.scsi.disk_present_v[3],
		      "mount policy: target-3 CD state is cleared by its eject event");
		img_bytes = 64'd1048576;

		// The two floppy drives are independent as well; Auto remains on
		// floppy until the last valid image is ejected.
		fimg_bytes = 64'd1474560;
		@(posedge clk); fimg_mounted <= 2'b01;
		@(posedge clk); fimg_mounted <= 2'b00;
		repeat (2) @(posedge clk);
		check(dut.floppy_mounted_v == 2'b01 && dut.floppy_mounted,
		      "mount policy: first floppy state is recorded");

		@(posedge clk); fimg_mounted <= 2'b10;
		@(posedge clk); fimg_mounted <= 2'b00;
		repeat (2) @(posedge clk);
		check(dut.floppy_mounted_v == 2'b11 && dut.floppy_mounted,
		      "mount policy: both floppy states are retained independently");

		fimg_bytes = 64'd0;
		@(posedge clk); fimg_mounted <= 2'b01;
		@(posedge clk); fimg_mounted <= 2'b00;
		repeat (2) @(posedge clk);
		check(dut.floppy_mounted_v == 2'b10 && dut.floppy_mounted,
		      "mount policy: ejecting one floppy preserves the other");

		@(posedge clk); fimg_mounted <= 2'b10;
		@(posedge clk); fimg_mounted <= 2'b00;
		repeat (2) @(posedge clk);
		check(dut.floppy_mounted_v == 2'b00 && !dut.floppy_mounted,
		      "mount policy: floppy state returns empty after the final eject");

		fimg_bytes = 64'd12345;
		@(posedge clk); fimg_mounted <= 2'b01;
		@(posedge clk); fimg_mounted <= 2'b00;
		repeat (2) @(posedge clk);
		check(dut.floppy_mounted_v == 2'b00 && !dut.floppy_mounted,
		      "mount policy: unsupported floppy size is not treated as mounted");
		fimg_bytes = bootfd ? 64'd1474560 : 64'd0;
	end

	if ($test$plusargs("bootsd")) begin
		bootsd = 1;
		@(posedge clk);
		img_mounted <= 3'b001;
		@(posedge clk);
		img_mounted <= 3'b000;
	end

	if ($test$plusargs("bootcd")) begin
		bootcd = 1;
		// a disk on target 0 as well, so the CD-ROM is the SECOND disk in
		// the ROM's scan order and the NVRAM command must be sd(1,0,0)
		@(posedge clk);
		img_mounted <= 3'b001;
		@(posedge clk);
		img_mounted <= 3'b000;
		@(posedge clk);
		cimg_mounted <= 1;
		@(posedge clk);
		cimg_mounted <= 0;
	end


	repeat (20) @(posedge clk);
	if (bootcd) begin
		// Capture the command while the external reset is still applying the
		// boot policy, before the ROM gets an opportunity to modify NVRAM.
		bootcd_nvram_ok = dut.scr.nvram[18] == "s" &&
		                     dut.scr.nvram[19] == "d" &&
		                     dut.scr.nvram[20] == "(" &&
		                     dut.scr.nvram[21] == "1" &&
		                     dut.scr.nvram[22] == "," &&
		                     dut.scr.nvram[23] == "0" &&
		                     dut.scr.nvram[24] == "," &&
		                     dut.scr.nvram[25] == "0" &&
		                     dut.scr.nvram[26] == ")" &&
		                     dut.scr.nvram[27] == 8'h00 &&
		                     dut.scr.nvram[28] == 8'h00 &&
		                     dut.scr.nvram[29] == 8'h00;
		$display("BOOT: NVRAM command %02x %02x %02x %02x %02x %02x %02x %02x %02x",
		         dut.scr.nvram[18], dut.scr.nvram[19], dut.scr.nvram[20],
		         dut.scr.nvram[21], dut.scr.nvram[22], dut.scr.nvram[23],
		         dut.scr.nvram[24], dut.scr.nvram[25], dut.scr.nvram[26]);
	end
	reset = 0;

	if ($test$plusargs("powerkey")) begin
		// Exercise the real KMS -> next_system edge detection -> interrupt
		// controller path. Only the mask is forced, to isolate IPL encoding
		// from any firmware writes; neither request nor status is forced.
		repeat (8) @(negedge clk);
		force dut.intc.mask = 32'd0;
		power_key_event(1, 0, 8'h09);
		check(dut.intc.stat[2], "F10 sets INT_POWER bit 2 through system wiring");
		check(!dut.intc.stat[3], "F10 does not set INT_KEYMOUSE");
		check(dbg_ipl == 0, "masked power request does not raise IPL");
		force dut.intc.mask = 32'h00000004;
		repeat (2) @(negedge clk);
		check(dbg_ipl == 3, "unmasked power request raises IPL 3");
		power_key_event(1, 1, 8'h71);
		power_key_event(0, 1, 8'h71);
		check(dut.intc.stat[2] && dbg_ipl == 3,
		      "Delete make/break cannot release F10 power request");
		power_key_event(0, 0, 8'h09);
		check(!dut.intc.stat[2] && dbg_ipl == 0,
		      "F10 release clears INT_POWER and IPL");
		power_key_event(1, 1, 8'h71);
		power_key_event(0, 1, 8'h71);
		check(!dut.intc.stat[2] && !dut.intc.stat[3] && dbg_ipl == 0,
		      "Delete alone is neither power nor a keyboard event");
		power_key_event(1, 0, 8'h09);
		check(dut.intc.stat[2], "power request can be asserted again");
		reset = 1;
		repeat (8) @(negedge clk);
		check(!dut.intc.stat[2], "device reset clears INT_POWER");
		reset = 0;
		repeat (8) @(negedge clk);
		check(!dut.intc.stat[2], "reset release does not create a phantom power press");
		power_key_event(0, 0, 8'h09);
		check(!dut.intc.stat[2], "stale F10 release after reset remains inactive");
		release dut.intc.mask;
		if (errors == 0) $display("ALL PASS");
		else            $display("%0d FAILURES", errors);
		$finish;
	end

	// the medium arrives once the machine is running, the way the OSD
	// delivers it: a mount pulse during reset is simply not seen
	if (bootfd) begin
		repeat (20) @(posedge clk);
		fimg_mounted <= 2'b01;
		@(posedge clk);
		fimg_mounted <= 2'b00;
	end

	// run length: +cycles=<n> for a small count, or +mcycles=<n> for
	// n million cycles (avoids the 32-bit cap of %d for long boots)
	begin : runlen
		integer mc;
		if ($value$plusargs("mcycles=%d", mc))
			run_cycles = mc * 1000000;
		else if (!$value$plusargs("cycles=%d", run_cycles))
			run_cycles = 300000;
	end
	while (run_cycles > 0 && !halt_run) begin
		@(posedge clk);
		run_cycles = run_cycles - 1;
	end

	$display("");
	$display("=== tb_next_boot results ===");
	$display("first accesses: %08x %08x %08x %08x",
	         first_addr[0], first_addr[1], first_addr[2], first_addr[3]);

	check(seen_vec_lo,  "reset SP fetched from ROM address 0");
	check(seen_vec_pc,  "reset PC fetched from ROM address 4");
	check(seen_entry,   "PC reached reset vector target 0x0100001E");
	check(bclk_bad == 0,  "bus clock enable marks every bus clock edge");
	check(seen_scr1,    "ROM read SCR1");
	check(scr1_ok,      "SCR1 returned machine id 0x00012052");
	check(seen_scr2_wr, "ROM wrote SCR2");
	check(!dbg_halted,  "CPU not halted");

	$display("mailbox: %0d reads, %0d writes, %0d frames pushed at the guest",
	         mbox_reads, mbox_writes, injected);
	if (DEBUG_EXCEPTIONS) begin
		check(mbox['ha00] == 64'h4e58544449414731, "diagnostic mailbox initialized");
		check(mbox['ha01] == 0 && diag_writes == 3,
		      "ROM boot leaves unhandled-trap latch armed");
	end
	if (!net_enable) begin
		// The bridge may invalidate the mailbox once so the host daemon
		// sees no magic, but it must never READ it: reading is how a
		// stale ring pointer left in DDR3 turns into frames the guest
		// never asked for.
		check(mbox_reads == 0,
		      "network off: the bridge reads no mailbox state");
		check(mbox_writes <= 8,
		      "network off: at most a one-off invalidation is written");
		check(injected == 0,
		      "network off: no frame reaches the guest");
	end
	else begin
		check(injected == 0,
		      "a stale mailbox injects no frames into the guest");
	end

	if (saw_kernel && guard_enable) begin : guard_report
		integer gg;
		reg [8*6:1] mname;
		$display("=== physical write watch %08x..%08x: %0d write(s) after kernel entry ===",
		         guard_lo, guard_hi, guard_hits);
		for (gg = 0; gg < guard_hits && gg < 32; gg = gg + 1) begin
			case (guard_who[gg])
				3'd0: mname = "CPU   "; 3'd1: mname = "WALKER";
				3'd2: mname = "ENET  "; 3'd3: mname = "MO    ";
				3'd4: mname = "SND   "; 3'd5: mname = "SCSI  ";
				default: mname = "?     ";
			endcase
			$display("  [%0d] %0s pa=%08x data=%08x pc=%08x va=%08x mmu_pa=%08x",
			         gg, mname, guard_addr[gg], guard_data[gg], guard_pc[gg],
			         guard_va[gg], guard_pa[gg]);
		end
		begin : cwr_dump
			integer q, base;
			base = (cwr_n > 24) ? cwr_n - 24 : 0;
			$display("--- last %0d CPU RAM stores before the trip (va -> pa) ---",
			         cwr_n - base);
			for (q = base; q < cwr_n; q = q + 1)
				$display("    va=%08x -> pa=%08x data=%08x pc=%08x",
				         cwr_va[q % 64], cwr_pa[q % 64], cwr_data[q % 64], cwr_pc[q % 64]);
		end
		check(guard_hits == 0, "no writes to the explicitly watched window after kernel entry");
	end


	if (bootfd) begin
		$display("floppy register accesses: %0d, sectors fetched: %0d",
		         fdreg_n, fsd_reads);
		fb_dump;
	end

	if (bootcd) begin
		check(bootcd_nvram_ok,
		      "CD probe: config reset generated exact NVRAM command sd(1,0,0)");
		check(saw_t3_inquiry,
		      "CD probe: ROM issued a LUN-0 INQUIRY to SCSI target 3");
	end

	if (bootsd) begin : scdma_dump
		integer kk;
		check(!wildpc_seen, "supervisor PC did not reach the panic target");
		$display("=== SCSI DMA channel writes to memory (frozen at berr) ===");
		for (kk = 0; kk < scdma_n && kk < 64; kk = kk + 1)
			$display("  [%0d] addr=%08x data=%08x", kk, scdma_addr[kk], scdma_data[kk]);
		$display("SD reads: %0d, SCSI DMA words to memory: %0d",
		         sd_reads, scsi_dma_writes);
		check(saw_esp_sel, "boot: ROM selected the SCSI disk");
		check(sd_lba0, "boot: sector 0 fetched from the SD image");
		check(scsi_dma_writes >= 128, "boot: a full sector reached memory by DMA");
		if (img_fd != 0)
			check(saw_kernel, "boot: real disk image transferred control to the kernel");
		fb_dump;
	end

	if (errors != 0 || $test$plusargs("iotrace")) dump_state;

	if (errors == 0) $display("ALL PASS");
	else             $display("%0d FAILURES", errors);
	$finish;
end

endmodule
