//============================================================================
//  NeXT system glue: AP68040 CPU, address decode, devices
//
//  Target machine: NeXTcube 68040 25MHz, monochrome (SCR1 0x00012052),
//  the machine Previous calls NEXT_CUBE040 (non-turbo).
//
//  Memory map, from Previous src/cpu/memory.c:
//    0x00000000-0x0001FFFF  boot ROM (128 KB)
//    0x01000000-0x0101FFFF  boot ROM mirror (reset vectors point here)
//    0x02000000-0x0201FFFF  device space
//    0x020C0000-0x020CFFFF  BMAP chip (also aliased at 0x820C0000)
//    0x02100000-0x0211FFFF  device space mirror (BMAP access path)
//    0x04000000-0x07FFFFFF  main RAM, 4 banks (served by the ram_* port)
//    0x0B000000-0x0B03FFFF  VRAM
//    0x0C000000-0x0F03FFFF  VRAM mirrors for memory write functions 0-3
//    0x10000000-0x1FFFFFFF  RAM mirrors for memory write functions 0-3
//    everything else        bus error (empty NeXTbus slots and so on)
//
//  The MWF mirrors are plain accesses for now (MWF0 = copy); the raster
//  op write functions are a TODO documented in docs/PORTING.md.
//
//  The CPU is the AP68040 (rtl/ap68040, the pipelined core) on clk_cpu,
//  two processor clocks per system clock, driving the MC68040 external
//  bus.  next_cpu040 (rtl/next/next_cpu040.sv) is that bus's slave: a
//  transfer becomes one beat on the b_* port here (a line transfer four:
//  aligned longword beats with byte enables, b_req level-held per beat,
//  b_ack a one-clock pulse, berr aborts), it answers the interrupt
//  acknowledge cycles, marks everything outside RAM and ROM cache
//  inhibited, and snoops the DMA writes into the core's caches.  Main RAM
//  takes a beat as one ram_* transaction; the ROM, VRAM, BMAP and the
//  device registers are 16-bit and take it as one or two 16-bit
//  sub-cycles (upper half first), which is exactly the access sequence
//  the old 16-bit CPU bus produced, so every device keeps its 16-bit
//  register file (docs/PERF_PLAN.md stage 3).  docs/CPU_NEXT_PORT.md.
//============================================================================

module next_system #(
	parameter CLK_HZ      = 28000000,
	// CPU speed calibration.  The boot ROM's delay() is a calibrated
	// bare "dbf d0,*" loop, self-checked by the POST event counter test
	// against a 899..1100 us window for delay(1000): 6.25 loop
	// iterations per microsecond TICK of this module, i.e. the ROM
	// assumes a real 68040's 4 clocks per taken DBcc at 25 MHz, 160 ns.
	// The AP68040 runs that loop in 2-3 of its clocks, so the core is
	// told the floor (its dbcc_floor input): a DBcc following a taken
	// DBcc leaves the execute stage no earlier than DBCC_FLOOR processor
	// clocks after it (Previous's 68040 timing model does the same,
	// gencpu.c adjust_cycles: DBcc = 4 cycles), and no other instruction
	// is slowed.  With the processor clock at twice this module's clock
	// the calibration invariant is
	//     (CLK_HZ / 1e6) = 6.25 * DBCC_FLOOR / 2
	// clocks per microsecond tick: 28 (28 MHz) for a floor of 9, which
	// the ROM measures as delay(1000) = 1001 us.  CLK_HZ defines the
	// microsecond of every timer in this system, so it may be a VIRTUAL
	// microsecond: the FPGA build runs a 27.5 MHz clock (55 MHz CPU) with
	// CLK_HZ = 28 MHz, the machine uniformly 1.8 percent slower than real
	// time but internally consistent with the calibration.
	parameter DBCC_FLOOR   = 9,
	// physical clock rate, for the battery backed time of day
	parameter CLK_REAL_HZ = CLK_HZ,
	parameter ROM_INIT_EN = 0,
	parameter ROM_INIT    = "rom.hex",
	parameter DEBUG_EXCEPTIONS = 0,
	// 0 leaves the sound input (the codec input DMA channel and its
	// registers) out of the build: ~340 ALMs here plus the ADC in the emu
	// top.  The registers then read as zero and the channel never runs.
	parameter SND_IN_EN = 1
)
(
	input         clk,            // system clock: the bus, devices, RAM
	input         clk_cpu,        // the CPU's clock: 2 x clk, same PLL, edge aligned
	input  [10:0] ps2_key,       // MiSTer keyboard events (to the KMS)
	input  [24:0] ps2_mouse,     // MiSTer mouse packet (to the KMS)

	// boot device menu (to the NVRAM boot command, see next_scr)
	input   [2:0] boot_sel,
	input  [32:0] ts_host,       // host clock from hps_io TIMESTAMP (see next_scr)

	// external ethernet cable/backend state.  Internal loopback remains
	// available inside next_enet_dma when this is false.
	input         enet_connected,


	// floppy image (MiSTer SD block interface, slot 1)
	// optical drives (od0, od1)
	input   [1:0] oimg_mounted,
	input         oimg_readonly,
	input  [63:0] oimg_size,
	output        osd_unit,
	output [31:0] osd_lba,
	output        osd_rd,
	output        osd_wr,
	input         osd_ack,
	output  [7:0] osd_buff_din,

	input   [1:0] fimg_mounted,    // one per floppy drive (fd0, fd1)
	input         fimg_readonly,
	input  [63:0] fimg_size,
	output        fsd_unit,
	output [31:0] fsd_lba,
	output        fsd_rd,
	output        fsd_wr,
	input         fsd_ack,
	input   [8:0] fsd_buff_addr,
	input   [7:0] fsd_buff_dout,
	output  [7:0] fsd_buff_din,
	input         fsd_buff_wr,

	// SCSI disk image (MiSTer SD block interface)
	input   [5:0] img_mounted,     // one per SCSI target (0..5)
	input         img_readonly,
	input  [63:0] img_size,
	output  [2:0] sd_unit,         // which target's slot sd_* addresses
	output [31:0] sd_lba,
	output        sd_rd,
	output        sd_wr,
	output  [5:0] sd_blk_cnt,      // hps_io blocks-1 for the CD-ROM slot (audio frames)
	output  [5:0] osd_blk_cnt,     // ... for the MO slot (the ECC exchange)
	input         sd_ack,
	input  [12:0] sd_buff_addr,    // multi-block transfers reach 2560 bytes
	input   [7:0] sd_buff_dout,
	output  [7:0] sd_buff_din,
	input         sd_buff_wr,
	input         clk_vid,        // video clock: scan-out (100 MHz for
	                              // the 1600x912 pixel timing)
	input         reset,          // active high, synchronous

	// boot ROM download (byte stream)
	input         rom_wr,
	input  [16:0] rom_waddr,
	input   [7:0] rom_wdata,

	// video output (one pixel per clk)
	output        hsync,
	output        vsync,
	output        hblank,
	output        vblank,
	output  [7:0] gray,

	// main RAM port, 32 bit, 64 MB (level req, level ack; see NeXT.sv
	// and tb/ for the two implementations)
	output reg        ram_req,
	output reg        ram_we,
	output reg  [3:0] ram_be,     // [3] = MSB byte lane
	output reg [23:0] ram_addr,   // 32-bit word index
	output reg [31:0] ram_din,
	input      [31:0] ram_dout,
	input             ram_ack,
	// the line next_ddram retains (docs/PERF_PLAN.md stage 2b), offered
	// to the CPU cache's fills through the wrapper's cache_line_* sideband
	input             ram_line_valid,
	input      [21:0] ram_line_tag,    // ram_addr[23:2]
	input     [127:0] ram_line_data,   // word 0 in [127:96]

	output        led,

	// signed 16-bit stereo audio out (44.1 kHz sample rate)
	output signed [15:0] audio_l,
	output signed [15:0] audio_r,
	input signed [15:0] audio_in,

	// ethernet frame bridge (next_enet_bridge in the emu top)
	output        btx_req,
	output [10:0] btx_len,
	input  [10:0] btx_addr,
	input         btx_rd,
	output  [7:0] btx_q,
	output        btx_ack,
	input         btx_done,
	input         brx_start,
	input  [10:0] brx_len,
	input         brx_valid,
	input   [7:0] brx_data,
	output        brx_ready,
	output [47:0] enet_mac,

	// debug
	output [31:0] dbg_pc,
	output        dbg_halted,
	output  [2:0] dbg_ipl,
	output        dbg_exception_valid,
	output [511:0] dbg_exception
);

//----------------------------------------------------------------------------
// CPU
//----------------------------------------------------------------------------

// the beat port next_cpu040 drives (rtl/next/next_cpu040.sv for the contract)
wire        b_req, b_write;
wire [31:2] b_addr;
wire  [3:0] b_be;
wire [31:0] b_wdata;
reg         b_ack;
reg  [31:0] b_rdata;
reg         berr_hold;

// snoop pulse for DMA writes into main RAM (one per acknowledged write),
// and the bridge's leave to grant another DMA transaction: none while a
// snoop is pending, none while the core holds the bus locked (bus_locked:
// a TAS/CAS or the MMU's locked descriptor update must see RAM unchanged
// between its read and its write)
reg        dma_snoop_stb;
reg [31:0] dma_snoop_addr;
wire       snoop_idle;

// ethernet DMA master port (driven by next_enet_dma below)
// ethernet DMA master port (driven by next_enet_dma below)
wire        en_m_req, en_m_we;
wire [29:0] en_m_addr;
wire  [3:0] en_m_be;
wire [31:0] en_m_din;
wire        en_m_ack, en_m_err;
wire        int_en_tx, int_en_rx, int_en_tx_dma, int_en_rx_dma;

// MO/ECC DMA master port (driven by next_mo below)
wire        mo_m_req, mo_m_we;
wire [29:0] mo_m_addr;
wire  [3:0] mo_m_be;
wire [31:0] mo_m_din;
wire        mo_m_ack, mo_m_err;
wire        int_disk, int_disk_dma;

// SCSI DMA master port (driven by next_scsi below)
wire        sc_m_req, sc_m_we;
wire [29:0] sc_m_addr;
wire  [3:0] sc_m_be;
wire [31:0] sc_m_din;
wire        sc_m_ack, sc_m_err;

// KMS/sound DMA master port (driven by next_kms_snd below)
wire        sn_m_req, sn_m_we;
wire [29:0] sn_m_addr;
wire  [3:0] sn_m_be;
wire [31:0] sn_m_din;
wire        sn_m_ack, sn_m_err;
wire        int_snd_ovrun, int_snd_out_dma, int_keymouse, int_power;

// Codec input DMA uses the same RAM arbiter and CPU cache snoop path.
wire        si_m_req, si_m_we, si_m_ack, si_m_err;
wire [29:0] si_m_addr;
wire [3:0]  si_m_be;
wire [31:0] si_m_din;
wire [15:0] sndin_rdata;
wire        sndin_active, sndin_clear, sndin_request, sndin_overrun;
wire        int_snd_in_dma;

// Printer DMA master port (driven by next_printer below)
wire        pr_m_req, pr_m_we;
wire [29:0] pr_m_addr;
wire  [3:0] pr_m_be;
wire [31:0] pr_m_din;
wire        ds_m_req, ds_m_we, ds_m_ack, ds_m_err;   // the DSP's DMA channel
wire [29:0] ds_m_addr;
wire  [3:0] ds_m_be;
wire [31:0] ds_m_din;
wire [15:0] dsp_rdata;
wire        pr_m_ack, pr_m_err;
wire        int_printer, int_printer_dma;
wire [15:0] pr_rdata;

wire  [2:0] ipl_level;
assign dbg_ipl = ipl_level;

// the 68040 bus between the core and next_cpu040
wire [31:0] c_a, c_do, c_di;
wire        c_a_oe, c_rw_n, c_ts_n, c_mi_n, c_rsto_n;
wire  [1:0] c_siz, c_tt;
wire  [2:0] c_tm;
wire        c_ta_n, c_tea_n, c_tci_n, c_tbi_n, c_avec_n, c_bg_n, c_lock_n, bus_locked;
wire [31:0] sn_a;
wire        sn_ts_n, sn_rw_n;
wire  [1:0] sn_siz, sn_tt, sn_sc;
wire        bclk_en;

ap68040 #(
	// Match Previous's non-Turbo 040: old Mach expects 44-byte FPU frames.
	.FPU_REVISION(8'h40),
	// the core's area options off (rtl/ap68040/doc/STATUS.md for their cost)
	.FPU_PIPE(0), .LOOP_PRED(0), .EARLY_RES(0), .DC1_ATC(0), .SKID(0), .DIV_STEPS(2)
) cpu
(
	.clk(clk_cpu),
	.bclk_en(bclk_en),
	.rsti_n(~reset),
	.dbcc_floor(4'(DBCC_FLOOR)),

	// the bus it drives
	.a_o(c_a), .a_oe(c_a_oe), .d_o(c_do), .d_oe(),
	.rw_n(c_rw_n), .siz(c_siz), .tt(c_tt), .tm(c_tm), .tln(), .upa(),
	.ciout_n(), .lock_n(c_lock_n), .locke_n(), .ts_n(c_ts_n), .tip_n(c_tip_n),
	// the slave's answers
	.d_i(c_di), .ta_n(c_ta_n), .tea_n(c_tea_n), .tci_n(c_tci_n), .tbi_n(c_tbi_n),
	// interrupts: next_intc's level, autovectored by the bridge
	.ipl_n(~ipl_level), .avec_n(c_avec_n), .ipend_n(),
	// arbitration: the bridge takes the bus for the DMA write snoops
	.br_n(), .bg_n(c_bg_n), .bb_n_i(1'b1), .bb_n_o(), .bb_oe(),
	// the snooped transfers
	.a_i(sn_a), .ts_n_i(sn_ts_n), .rw_n_i(sn_rw_n), .siz_i(sn_siz), .tt_i(sn_tt), .sc(sn_sc),
	.mi_n(c_mi_n), .ta_n_o(), .ta_oe(),
	.rsto_n(c_rsto_n), .cdis_n(1'b1), .mdis_n(1'b1), .pst(),
	.dbg_pc(dbg_pc), .dbg_retire(), .dbg_halted(dbg_halted)
);
wire c_tip_n;

next_cpu040 cpubus
(
	.clk(clk), .clk_cpu(clk_cpu), .reset(reset), .bclk_en(bclk_en),
	.a(c_a), .a_oe(c_a_oe), .d_cpu(c_do), .rw_n(c_rw_n), .siz(c_siz), .tt(c_tt), .tm(c_tm),
	.ts_n(c_ts_n), .lock_n(c_lock_n), .mi_n(c_mi_n),
	.d_mem(c_di), .ta_n(c_ta_n), .tea_n(c_tea_n), .tci_n(c_tci_n), .tbi_n(c_tbi_n),
	.avec_n(c_avec_n), .bg_n(c_bg_n),
	.sn_a(sn_a), .sn_ts_n(sn_ts_n), .sn_rw_n(sn_rw_n), .sn_siz(sn_siz), .sn_tt(sn_tt), .sn_sc(sn_sc),
	.snoop_stb(dma_snoop_stb), .snoop_addr(dma_snoop_addr), .snoop_idle(snoop_idle),
	.bus_locked(bus_locked),
	.b_req(b_req), .b_write(b_write), .b_addr(b_addr), .b_be(b_be), .b_wdata(b_wdata),
	.b_ack(b_ack), .b_rdata(b_rdata), .berr(berr_hold)
);

// This core has no exception diagnostic block (the old wrapper's
// debug_exception record).  The mailbox outputs are quiet, and a build
// that asks for the diagnostics (NEXT_EXCEPTION_DIAG) fails at
// elaboration instead of silently reporting nothing.
assign dbg_exception_valid = 1'b0;
assign dbg_exception       = 512'd0;
generate if (DEBUG_EXCEPTIONS != 0) begin : g_no_exception_diag
	next_exception_diag_not_available_on_ap68040 no_diag();
end endgenerate

// devices also see the RESET instruction (RSTO, 512 bus clocks)
// registered: a global-routed net (NeXT.qsf), ~4,000 device registers
reg  dev_reset = 1;
always @(posedge clk) dev_reset <= reset | ~c_rsto_n;

//----------------------------------------------------------------------------
// address decode
//----------------------------------------------------------------------------

localparam S_IDLE = 3'd0, S_INT = 3'd1, S_RAM = 3'd2, S_RAM_E = 3'd3, S_GAP = 3'd4;
reg  [2:0] state;

// The 16-bit view of the beat for the ROM, VRAM, BMAP and the device
// registers: a beat is served to them as one or two 16-bit sub-cycles
// (S_INT), the upper half (bytes 0-1, b_be[3:2]) first, then after an
// idle clock (S_GAP) the lower half (b_be[1:0]); a half with no byte
// enabled is skipped.  cpu_addr/lanes/cpu_dout/is_write are the same
// signals the old 16-bit CPU bus drove, so the devices see the same
// accesses in the same order (a longword read of the event counter still
// latches on its first half, the ESP FIFO still sees one 16-bit access
// per half).  The address is valid in the clock before S_INT for the
// ROM's and the VRAM's synchronous read.
reg         half_r;
wire        half     = half_r | ((state == S_IDLE) && (b_be[3:2] == 2'b00));
wire [31:0] cpu_addr = {b_addr, half, 1'b0};
wire  [1:0] lanes    = half ? b_be[1:0] : b_be[3:2];
wire [15:0] cpu_dout = half ? b_wdata[15:0] : b_wdata[31:16];
wire        is_write = b_write;

wire d_rom  = (cpu_addr[31:17] == 15'h0000) || (cpu_addr[31:17] == {8'h01, 7'd0});
wire d_io   = (cpu_addr[31:24] == 8'h02) &&
              ((cpu_addr[23:17] == 7'd0) || (cpu_addr[23:17] == 7'd8));
wire d_bmap = (cpu_addr[31:16] == 16'h020C) || (cpu_addr[31:16] == 16'h820C);
wire d_ram  = (cpu_addr[31:26] == 6'b000001) ||   // 0x04-0x07
              (cpu_addr[31:28] == 4'h1);          // 0x10-0x1F MWF mirrors
wire d_vram = (cpu_addr[31:24] == 8'h0B) ||
              (cpu_addr[31:26] == 6'b000011);     // 0x0C-0x0F MWF mirrors

wire d_any  = d_rom | d_io | d_bmap | d_ram | d_vram;

//----------------------------------------------------------------------------
// bus cycle state machine
//----------------------------------------------------------------------------

localparam G_ENET = 3'd0, G_MO = 3'd1, G_SND = 3'd2, G_SCSI = 3'd3, G_PRINT = 3'd4, G_SNDIN = 3'd5, G_DSP = 3'd6;
reg  [2:0] dma_grant;
reg        sel_rom, sel_vram, sel_io, sel_bmap;

// a beat to serve: not the retire clock of the one just acknowledged (the
// bridge still shows it under b_ack), not while a bus error is reported
wire cpu_req = b_req && !b_ack && !berr_hold;



// internal read data mux (valid in cycle S_INT)
wire [15:0] rom_q, vram_q, io_rdata, bmap_rdata;
wire        bmap_tpe_select;
wire [15:0] int_rdata = sel_rom  ? rom_q :
                        sel_vram ? vram_q :
                        sel_bmap ? bmap_rdata : io_rdata;

assign en_m_ack = (state == S_RAM_E) && (dma_grant == G_ENET) && ram_ack;
assign mo_m_ack = (state == S_RAM_E) && (dma_grant == G_MO) && ram_ack;
assign sn_m_ack = (state == S_RAM_E) && (dma_grant == G_SND) && ram_ack;
assign sc_m_ack = (state == S_RAM_E) && (dma_grant == G_SCSI) && ram_ack;
assign pr_m_ack = (state == S_RAM_E) && (dma_grant == G_PRINT) && ram_ack;
assign si_m_ack = (state == S_RAM_E) && (dma_grant == G_SNDIN) && ram_ack;
assign ds_m_ack = (state == S_RAM_E) && (dma_grant == G_DSP) && ram_ack;

// DMA can reach physical main RAM only.  Keep the six high address
// bits emitted by the controller until here; otherwise any invalid pointer
// aliases modulo 64 MB and can overwrite unrelated data or MMU tables.
wire en_m_is_ram = en_m_addr[29:24] == 6'b000001;
wire mo_m_is_ram = mo_m_addr[29:24] == 6'b000001;
wire sn_m_is_ram = sn_m_addr[29:24] == 6'b000001;
wire sc_m_is_ram = sc_m_addr[29:24] == 6'b000001;
wire pr_m_is_ram = pr_m_addr[29:24] == 6'b000001;
wire ds_m_is_ram = ds_m_addr[29:24] == 6'b000001;
wire si_m_is_ram = si_m_addr[29:24] == 6'b000001;
assign en_m_err = en_m_req && !en_m_is_ram;
assign mo_m_err = mo_m_req && !mo_m_is_ram;
assign sn_m_err = sn_m_req && !sn_m_is_ram;
assign sc_m_err = sc_m_req && !sc_m_is_ram;
assign pr_m_err = pr_m_req && !pr_m_is_ram;
assign ds_m_err = ds_m_req && !ds_m_is_ram;
assign si_m_err = si_m_req && !si_m_is_ram;

always @(posedge clk) begin
	b_ack <= 0;
	dma_snoop_stb <= 0;
	if (reset) begin
		state <= S_IDLE;
		berr_hold <= 0;
		{sel_rom, sel_vram, sel_io, sel_bmap} <= 0;
		ram_req <= 0;
		half_r <= 0;
	end
	else begin
		// the adapter drops the faulted beat on the next enabled clock;
		// berr stays up until it has (two clocks, as on the 16-bit bus)
		if (berr_hold && !b_req) berr_hold <= 0;

		case (state)
		S_IDLE: begin
			{sel_rom, sel_vram, sel_io, sel_bmap} <= 0;
			if (en_m_req && !cpu_req && !berr_hold && snoop_idle && !bus_locked) begin
				if (en_m_is_ram) begin
					ram_req  <= 1;
					ram_we   <= en_m_we;
					ram_be   <= en_m_be;
					ram_addr <= en_m_addr[23:0];
					ram_din  <= en_m_din;
					dma_grant <= G_ENET;
					state    <= S_RAM_E;
				end
			end
			else if (mo_m_req && !cpu_req && !berr_hold && snoop_idle && !bus_locked) begin
				if (mo_m_is_ram) begin
					ram_req  <= 1;
					ram_we   <= mo_m_we;
					ram_be   <= mo_m_be;
					ram_addr <= mo_m_addr[23:0];
					ram_din  <= mo_m_din;
					dma_grant <= G_MO;
					state    <= S_RAM_E;
				end
			end
			else if (sn_m_req && !cpu_req && !berr_hold && snoop_idle && !bus_locked) begin
				if (sn_m_is_ram) begin
					ram_req  <= 1;
					ram_we   <= sn_m_we;
					ram_be   <= sn_m_be;
					ram_addr <= sn_m_addr[23:0];
					ram_din  <= sn_m_din;
					dma_grant <= G_SND;
					state    <= S_RAM_E;
				end
			end
			else if (sc_m_req && !cpu_req && !berr_hold && snoop_idle && !bus_locked) begin
				if (sc_m_is_ram) begin
					ram_req  <= 1;
					ram_we   <= sc_m_we;
					ram_be   <= sc_m_be;
					ram_addr <= sc_m_addr[23:0];
					ram_din  <= sc_m_din;
					dma_grant <= G_SCSI;
					state    <= S_RAM_E;
				end
			end
			else if (pr_m_req && !cpu_req && !berr_hold && snoop_idle && !bus_locked) begin
				if (pr_m_is_ram) begin
					ram_req  <= 1;
					ram_we   <= pr_m_we;
					ram_be   <= pr_m_be;
					ram_addr <= pr_m_addr[23:0];
					ram_din  <= pr_m_din;
					dma_grant <= G_PRINT;
					state    <= S_RAM_E;
				end
			end
			else if (si_m_req && !cpu_req && !berr_hold && snoop_idle && !bus_locked) begin
				if (si_m_is_ram) begin
					ram_req <= 1;
					ram_we <= si_m_we;
					ram_be <= si_m_be;
					ram_addr <= si_m_addr[23:0];
					ram_din <= si_m_din;
					dma_grant <= G_SNDIN;
					state <= S_RAM_E;
				end
			end
			else if (ds_m_req && !cpu_req && !berr_hold && snoop_idle && !bus_locked) begin
				if (ds_m_is_ram) begin
					ram_req <= 1;
					ram_we <= ds_m_we;
					ram_be <= ds_m_be;
					ram_addr <= ds_m_addr[23:0];
					ram_din <= ds_m_din;
					dma_grant <= G_DSP;
					state <= S_RAM_E;
				end
			end
			else if (cpu_req) begin
				if (!d_any) berr_hold <= 1;
				else if (d_ram) begin
					// one 32-bit transaction per beat
					ram_req  <= 1;
					ram_we   <= b_write;
					ram_be   <= b_be;
					ram_addr <= b_addr[25:2];
					ram_din  <= b_wdata;
					state    <= S_RAM;
				end
				else begin
					// 16-bit target: first sub-cycle (the upper half unless
					// it has no byte enabled)
					sel_rom  <= d_rom;
					sel_vram <= d_vram;
					sel_io   <= d_io;
					sel_bmap <= d_bmap;
					half_r   <= half;
					state    <= S_INT;
				end
			end
		end

		S_INT: begin
			// the sub-cycle: the selected target sees sel/we/lanes/wdata
			// in this clock and its read data is taken at the end of it
			{sel_rom, sel_vram, sel_io, sel_bmap} <= 0;
			if (half_r) b_rdata[15:0]  <= int_rdata;
			else        b_rdata[31:16] <= int_rdata;
			if (!half_r && (b_be[1:0] != 2'b00)) begin
				half_r <= 1;
				state  <= S_GAP;
			end
			else begin
				half_r <= 0;
				b_ack  <= 1;
				state  <= S_IDLE;
			end
		end

		S_GAP: begin
			// one idle clock between the two halves (the address of the
			// lower half settles for the ROM's and the VRAM's read)
			sel_rom  <= d_rom;
			sel_vram <= d_vram;
			sel_io   <= d_io;
			sel_bmap <= d_bmap;
			state    <= S_INT;
		end

		S_RAM: begin
			if (ram_ack) begin
				ram_req <= 0;
				b_rdata <= ram_dout;
				b_ack   <= 1;
				state <= S_IDLE;
			end
		end

		S_RAM_E: begin
			if (ram_ack) begin
				ram_req <= 0;
				state <= S_IDLE;
				if (ram_we) begin
					dma_snoop_stb <= 1;
					dma_snoop_addr <= {6'b000001, ram_addr, 2'b00};
				end
			end
		end

		default: state <= S_IDLE;
		endcase
	end
end

//----------------------------------------------------------------------------
// boot ROM
//----------------------------------------------------------------------------

next_rom #(.ROM_INIT_EN(ROM_INIT_EN), .ROM_INIT(ROM_INIT)) rom
(
	.clk(clk),
	.a_addr(cpu_addr[16:1]),
	.a_q(rom_q),
	.wr(rom_wr),
	.w_addr(rom_waddr),
	.w_din(rom_wdata)
);

//----------------------------------------------------------------------------
// VRAM and video
//----------------------------------------------------------------------------

wire [16:0] scan_addr;
wire [15:0] scan_q;

next_vram vram
(
	.clk_a(clk),
	.a_addr(cpu_addr[17:1]),
	.a_we({2{sel_vram & is_write}} & lanes),
	.a_din(cpu_dout),
	.a_q(vram_q),
	.clk_b(clk_vid),
	.b_addr(scan_addr),
	.b_q(scan_q)
);

next_video video
(
	.clk(clk_vid),
	.hsync(hsync),
	.vsync(vsync),
	.hblank(hblank),
	.vblank(vblank),
	.gray(gray),
	.vbl(),
	.vram_addr(scan_addr),
	.vram_q(scan_q)
);

// vertical blank into the system clock domain: synchronize the level,
// pulse on the rising edge
reg [2:0] vblank_sync;
always @(posedge clk) vblank_sync <= {vblank_sync[1:0], vblank};
wire vbl = vblank_sync[1] & ~vblank_sync[2];

//----------------------------------------------------------------------------
// device space
//----------------------------------------------------------------------------

wire [16:0] io_off = cpu_addr[16:0];

wire io_enet  = sel_io && !io_off[16] && (
                (io_off[15:4]  == 12'h600)  ||                  // 0x6000-0x600f MB8795
                (io_off[15:2]  == 14'h044)  ||                  // 0x0110 EN_TX CSR
                (io_off[15:2]  == 14'h054)  ||                  // 0x0150 EN_RX CSR
                (io_off[15:5]  == 11'h208)  ||                  // 0x4100-0x411f
                (io_off[15:5]  == 11'h20A)  ||                  // 0x4140-0x415f
                (io_off[15:2]  == 14'h10C4) ||                  // 0x4310
                (io_off[15:2]  == 14'h10D4));                   // 0x4350
wire io_mo_osp = sel_io && (io_off[16:5] == 12'h900);           // 0x12000-0x1201f
wire io_mo_csr = sel_io && (io_off[16:2] == 15'h0014);          // 0x00050-0x00053
wire io_mo_ptr = sel_io && (io_off[16:4] == 13'h405);           // 0x04050-0x0405f
wire io_mo_ini = sel_io && (io_off[16:2] == 15'h1094);          // 0x04250-0x04253
wire io_mo     = io_mo_osp | io_mo_csr | io_mo_ptr | io_mo_ini;
wire io_kms    = sel_io && (io_off[16:4] == 13'hE00);           // 0x0e000-0x0e00f
wire io_sn_csr = sel_io && (io_off[16:2] == 15'h0010);          // 0x00040-0x00043
wire io_sn_sptr= sel_io && (io_off[16:4] == 13'h403);           // 0x04030-0x0403f
wire io_sn_ptr = sel_io && (io_off[16:4] == 13'h404);           // 0x04040-0x0404f
wire io_sn_ini = sel_io && (io_off[16:2] == 15'h1090);          // 0x04240-0x04243
wire io_snd    = io_kms | io_sn_csr | io_sn_sptr | io_sn_ptr | io_sn_ini;
wire io_si_csr = sel_io && (io_off[16:2] == 15'h0020);          // 0x00080-0x00083
wire io_si_sptr= sel_io && (io_off[16:4] == 13'h407);           // 0x04070-0x0407f
wire io_si_ptr = sel_io && (io_off[16:4] == 13'h408);           // 0x04080-0x0408f
wire io_si_ini = sel_io && (io_off[16:2] == 15'h10a0);          // 0x04280-0x04283
wire io_sndin  = io_si_csr | io_si_sptr | io_si_ptr | io_si_ini;
wire io_sc_csr = sel_io && (io_off[16:2] == 15'h0004);          // 0x00010-0x00013
wire io_sc_sptr= sel_io && (io_off[16:4] == 13'h400);           // 0x04000-0x0400f
wire io_sc_ptr = sel_io && (io_off[16:4] == 13'h401);           // 0x04010-0x0401f
wire io_sc_ini = sel_io && (io_off[16:2] == 15'h1084);          // 0x04210-0x04213
wire io_scsi   = io_sc_csr | io_sc_sptr | io_sc_ptr | io_sc_ini;
wire io_lp     = sel_io && (io_off[16:4] == 13'hF00);           // 0x0f000-0x0f00f LP CSR
wire io_pr_csr = sel_io && (io_off[16:2] == 15'h0024);          // 0x00090-0x00093
wire io_pr_ptr = sel_io && (io_off[16:4] == 13'h409);           // 0x04090-0x0409f
wire io_pr_ini = sel_io && (io_off[16:2] == 15'h10A4);          // 0x04290-0x04293
wire io_printer= io_lp | io_pr_csr | io_pr_ptr | io_pr_ini;
wire io_dsp_host = sel_io && (io_off[16:3] == 14'h1000);        // 0x08000-0x08007 DSP host port
wire io_dsp_csr  = sel_io && (io_off[16:2] == 15'h0034);        // 0x000d0-0x000d3
wire io_dsp_ptr  = sel_io && (io_off[16:4] == 13'h40d);         // 0x040d0-0x040df
wire io_dsp_ini  = sel_io && (io_off[16:2] == 15'h10b4);        // 0x042d0-0x042d3
wire io_dsp    = io_dsp_host | io_dsp_csr | io_dsp_ptr | io_dsp_ini;
wire io_dma   = sel_io && (io_off[16:12] < 5'h05) && !io_enet && !io_mo && !io_snd && !io_sndin && !io_scsi && !io_printer && !io_dsp; // 0x00000-0x04FFF
wire io_intc  = sel_io && (io_off[16:12] == 5'h07);             // 0x07000-0x07FFF
wire io_scr1  = sel_io && (io_off[16:11] == 6'h18);             // 0x0c000-0x0c7ff
wire io_sid   = sel_io && (io_off[16:11] == 6'h19);             // 0x0c800-0x0cfff
wire io_scr2  = sel_io && (io_off[16:11] == 6'h1A);             // 0x0d000-0x0d7ff
wire io_timer = sel_io && (io_off[16:12] == 5'h16);             // 0x16000-0x16fff
wire io_scc   = sel_io && (io_off[16:3]  == 14'h3000);          // 0x18000-0x18007
wire io_esp   = sel_io && (io_off[16:6]  == 11'h500);           // 0x14000-0x1403f
wire io_flp   = sel_io && (io_off[16:4]  == 13'h1410);          // 0x14100-0x1410f
wire io_evt   = sel_io && (io_off[16:12] == 5'h1a);             // 0x1a000-0x1afff
wire io_scr   = io_scr1 | io_sid | io_scr2;

wire [15:0] scr_rdata, intc_rdata, timer_rdata, dma_rdata, scc_rdata, esp_rdata, enet_rdata, mo_rdata, snd_rdata;
wire [15:0] flp_rdata;

// event counter: 20-bit microsecond counter, latched when its first byte
// is read, reset by a write (System_Timer_Read/Write in Previous
// src/sysReg.c: value is (host_time_us() - offset) & 0xFFFFF)
localparam US_DIV = CLK_HZ / 1000000;
reg [$clog2(US_DIV)-1:0] us_presc;
wire us_tick = (us_presc == US_DIV-1);
reg [19:0] us_counter;
reg [19:0] evt_latch;

always @(posedge clk) begin
	if (reset) begin
		us_presc <= 0;
		us_counter <= 0;
		evt_latch <= 0;
	end
	else begin
		us_presc <= us_tick ? 1'd0 : us_presc + 1'd1;
		if (us_tick) us_counter <= us_counter + 1'd1;
		if (io_evt && !is_write && !cpu_addr[1]) evt_latch <= us_counter;
		if (io_evt && is_write) us_counter <= 0;
	end
end

wire [15:0] evt_rdata = cpu_addr[1] ? evt_latch[15:0] : {12'd0, us_counter[19:16]};

assign io_rdata = io_enet  ? enet_rdata :
                  io_mo    ? mo_rdata :
                  io_snd   ? snd_rdata :
                  io_sndin ? sndin_rdata :
                  io_printer ? pr_rdata :
                  io_dsp   ? dsp_rdata :
                  io_scsi  ? esp_rdata :
                  io_dma   ? dma_rdata :
                  io_intc  ? intc_rdata :
                  io_scr   ? scr_rdata :
                  io_timer ? timer_rdata :
                  io_scc   ? scc_rdata :
                  io_esp   ? esp_rdata :
                  io_flp   ? flp_rdata :
                  io_evt   ? evt_rdata :
                  16'h0000;

// system control registers and RTC
wire timer_ipl7, softint1, softint2;
wire dsp_run, dsp_blk_end, dsp_unpacked, dsp_int_l4, dsp_mem_en;
wire [1:0] dsp_mode;
wire bmap_dsp_hreq_en, bmap_dsp_txd_en;

// SCSI disks mounted below the CD-ROM's target 3 (OSD slots S0-S2 are
// targets 0-2).  The ROM's "sd(unit,lun,part)" numbers disks in scan
// order, so the CD-ROM's unit is the count of these; next_scr uses it
// to spell the CD-ROM boot command.  This state survives reset: the
// mount pulse fires once at OSD time, usually before the user resets into
// the new configuration.  It is also the authoritative Auto-boot HDD
// presence, so target 3's CD-ROM can never be mistaken for a fixed disk.
reg [2:0] sd_lower_mounted = 3'b000;
integer smk;
always @(posedge clk)
	for (smk = 0; smk < 3; smk = smk + 1)
		if (img_mounted[smk]) sd_lower_mounted[smk] <= (img_size != 0);

// Keep each floppy's insertion state independently.  A mount event names
// only the drive that changed, and a later eject from the other drive must
// not clear Auto's view of this one.  Match next_floppy's accepted media
// exactly; a nonzero file of an unsupported size is still an empty drive.
wire floppy_image_valid = (fimg_size == 64'd737280)  ||
                           (fimg_size == 64'd1474560) ||
                           (fimg_size == 64'd2949120);
reg [1:0] floppy_mounted_v = 2'b00;
integer fmk;
always @(posedge clk)
	for (fmk = 0; fmk < 2; fmk = fmk + 1)
		if (fimg_mounted[fmk]) floppy_mounted_v[fmk] <= floppy_image_valid;

wire floppy_mounted = |floppy_mounted_v;

next_scr #(.CLK_HZ(CLK_HZ), .CLK_REAL_HZ(CLK_REAL_HZ)) scr
(
	.clk(clk),
	.reset(dev_reset),
	.config_reset(reset),
	.sel(io_scr),
	.reg_id(io_scr1 ? 2'd0 : io_sid ? 2'd1 : 2'd2),
	.addr1(cpu_addr[1]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(scr_rdata),
	.scr1(32'h00012052),         // 25MHz NeXTcube 68040, 100ns memory
	.boot_sel(boot_sel),
	.ts_host(ts_host),
	.floppy_mounted(floppy_mounted),
	.sd_lower_mounted(sd_lower_mounted),
	.timer_ipl7(timer_ipl7),
	.led(led),
	.rom_overlay(),
	.softint1(softint1),
	.softint2(softint2),
	.dsp_run(dsp_run),
	.dsp_mode(dsp_mode),
	.dsp_blk_end(dsp_blk_end),
	.dsp_unpacked(dsp_unpacked),
	.dsp_int_l4(dsp_int_l4),
	.dsp_mem_en(dsp_mem_en)
);

// hardclock
wire timer_set, timer_clr;

next_timer #(.CLK_HZ(CLK_HZ)) timer
(
	.clk(clk),
	.reset(dev_reset),
	.sel(io_timer),
	.addr(cpu_addr[2:0]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(timer_rdata),
	.rd(~is_write),
	.int_set(timer_set),
	.int_clr(timer_clr)
);

// DMA stub with the frame interrupt path
wire vid_int_set, vid_int_clr;

next_dma_stub dma
(
	.clk(clk),
	.reset(dev_reset),
	.sel(io_dma),
	.addr(io_off[14:0]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(dma_rdata),
	.vbl(vbl),
	.vid_int_set(vid_int_set),
	.vid_int_clr(vid_int_clr)
);

next_enet_dma #(.CLK_HZ(CLK_HZ)) enet
(
	.clk(clk),
	.reset(dev_reset),
	.sel(io_enet),
	.addr(io_off[14:0]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(enet_rdata),
	.m_req(en_m_req),
	.m_we(en_m_we),
	.m_addr(en_m_addr),
	.m_be(en_m_be),
	.m_din(en_m_din),
	.m_dout(ram_dout),
	.m_ack(en_m_ack),
	.m_err(en_m_err),
	.tpe_select(bmap_tpe_select),
	.cable_connected(enet_connected),
	.btx_req(btx_req),
	.btx_len(btx_len),
	.btx_addr(btx_addr),
	.btx_rd(btx_rd),
	.btx_q(btx_q),
	.btx_ack(btx_ack),
	.btx_done(btx_done),
	.brx_start(brx_start),
	.brx_len(brx_len),
	.brx_valid(brx_valid),
	.brx_data(brx_data),
	.brx_ready(brx_ready),
	.enet_mac(enet_mac),
	.int_en_tx(int_en_tx),
	.int_en_rx(int_en_rx),
	.int_en_tx_dma(int_en_tx_dma),
	.int_en_rx_dma(int_en_rx_dma)
);

// MO drive controller with the ECC buffer engine (a RAM bus master)
next_mo #(.CLK_HZ(CLK_HZ), .DRIVE_CONNECTED(2'b01)) mo
(
	.clk(clk),
	.reset(dev_reset),
	.sel_osp(io_mo_osp),
	.sel_csr(io_mo_csr),
	.sel_ptr(io_mo_ptr),
	.sel_ini(io_mo_ini),
	.addr(io_off[4:0]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(mo_rdata),
	.m_req(mo_m_req),
	.m_we(mo_m_we),
	.m_addr(mo_m_addr),
	.m_be(mo_m_be),
	.m_din(mo_m_din),
	.m_dout(ram_dout),
	.m_ack(mo_m_ack),
	.m_err(mo_m_err),
	.int_disk(int_disk),
	.int_disk_dma(int_disk_dma),
	.mo_gpo(),
	.img_mounted(oimg_mounted),
	.img_readonly(oimg_readonly),
	.img_size(oimg_size),
	.sd_unit(osd_unit),
	.sd_lba(osd_lba),
	.sd_rd(osd_rd),
	.sd_wr(osd_wr),
	.sd_ack(osd_ack),
	.sd_buff_addr(sd_buff_addr[10:0]),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din(osd_buff_din),
	.sd_buff_wr(sd_buff_wr),
	.sd_blk_cnt(osd_blk_cnt)
);

// KMS and sound out DMA (a RAM bus master)
next_kms_snd #(.CLK_HZ(CLK_HZ), .CLK_REAL_HZ(CLK_REAL_HZ)) kms_snd
(
	.clk(clk),
	.reset(dev_reset),
	.ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse),
	.sel_kms(io_kms),
	.sel_csr(io_sn_csr),
	.sel_sptr(io_sn_sptr),
	.sel_ptr(io_sn_ptr),
	.sel_ini(io_sn_ini),
	.addr(io_off[3:0]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(snd_rdata),
	.m_req(sn_m_req),
	.m_we(sn_m_we),
	.m_addr(sn_m_addr),
	.m_be(sn_m_be),
	.m_din(sn_m_din),
	.m_dout(ram_dout),
	.m_ack(sn_m_ack),
	.m_err(sn_m_err),
	.int_snd_ovrun(int_snd_ovrun),
	.int_snd_out_dma(int_snd_out_dma),
	.sndin_active(sndin_active), .sndin_clear(sndin_clear),
	.sndin_request(sndin_request), .sndin_overrun(sndin_overrun),
	.int_keymouse(int_keymouse),
	.int_power(int_power),
	.audio_l(kms_l),
	.audio_r(kms_r)
);

// the CD-ROM's audio is summed into the sound output with saturation
wire signed [15:0] kms_l, kms_r, cd_l, cd_r;
wire signed [16:0] mix_l = {kms_l[15], kms_l} + {cd_l[15], cd_l};
wire signed [16:0] mix_r = {kms_r[15], kms_r} + {cd_r[15], cd_r};
assign audio_l = (mix_l[16] != mix_l[15]) ? (mix_l[16] ? 16'h8000 : 16'h7FFF) : mix_l[15:0];
assign audio_r = (mix_r[16] != mix_r[15]) ? (mix_r[16] ? 16'h8000 : 16'h7FFF) : mix_r[15:0];

generate if (SND_IN_EN != 0) begin : g_snd_in
	next_snd_in #(.CLK_REAL_HZ(CLK_REAL_HZ)) snd_in
	(
		.clk(clk), .reset(dev_reset),
		.active(sndin_active), .clear_status(sndin_clear),
		.audio_in(audio_in),
		.request_status(sndin_request), .overrun(sndin_overrun),
		.sel_csr(io_si_csr), .sel_sptr(io_si_sptr), .sel_ptr(io_si_ptr), .sel_ini(io_si_ini),
		.addr(io_off[3:0]), .we(is_write), .be(lanes), .wdata(cpu_dout), .rdata(sndin_rdata),
		.int_dma(int_snd_in_dma),
		.m_req(si_m_req), .m_we(si_m_we), .m_addr(si_m_addr), .m_be(si_m_be), .m_din(si_m_din),
		.m_ack(si_m_ack), .m_err(si_m_err)
	);
end
else begin : g_no_snd_in
	// no sound input: its registers read as zero, no DMA, no interrupt
	assign sndin_rdata    = 16'd0;
	assign sndin_request  = 1'b0;
	assign sndin_overrun  = 1'b0;
	assign int_snd_in_dma = 1'b0;
	assign si_m_req  = 1'b0;
	assign si_m_we   = 1'b0;
	assign si_m_addr = 30'd0;
	assign si_m_be   = 4'd0;
	assign si_m_din  = 32'd0;
	wire unused_snd_in = sndin_active | sndin_clear | (|audio_in) | si_m_ack | si_m_err;
end
endgenerate

// Laser printer interface and its memory-to-device DMA channel
next_printer #(.CLK_HZ(CLK_HZ)) printer
(
	.clk(clk),
	.reset(dev_reset),
	.sel_lp(io_lp),
	.sel_csr(io_pr_csr),
	.sel_ptr(io_pr_ptr),
	.sel_ini(io_pr_ini),
	.addr(io_off[15:0]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(pr_rdata),
	.m_req(pr_m_req),
	.m_we(pr_m_we),
	.m_addr(pr_m_addr),
	.m_be(pr_m_be),
	.m_din(pr_m_din),
	.m_dout(ram_dout),
	.m_ack(pr_m_ack),
	.m_err(pr_m_err),
	.int_printer(int_printer),
	.int_printer_dma(int_printer_dma)
);

// DSP56001: the host port, its DMA channel (a seventh RAM master) and the
// SCR2/BMAP/interrupt glue around the vendored Falcon block (rtl/dsp56k)
next_dsp #(.CLK_HZ(CLK_HZ)) dsp
(
	.clk(clk),
	.reset(dev_reset),
	.sel_host(io_dsp_host),
	.sel_csr(io_dsp_csr),
	.sel_ptr(io_dsp_ptr),
	.sel_ini(io_dsp_ini),
	.addr(io_off[15:0]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(dsp_rdata),
	.m_req(ds_m_req),
	.m_we(ds_m_we),
	.m_addr(ds_m_addr),
	.m_be(ds_m_be),
	.m_din(ds_m_din),
	.m_dout(ram_dout),
	.m_ack(ds_m_ack),
	.m_err(ds_m_err),
	.dsp_run(dsp_run),
	.dsp_mode(dsp_mode),
	.dsp_blk_end(dsp_blk_end),
	.dsp_unpacked(dsp_unpacked),
	.dsp_int_l4(dsp_int_l4),
	.dsp_mem_en(dsp_mem_en),
	.bmap_hreq_en(bmap_dsp_hreq_en),
	.bmap_txd_en(bmap_dsp_txd_en),
	.int_dsp_l3(int_dsp_l3),
	.int_dsp_l4(int_dsp_l4),
	.int_dsp_dma(int_dsp_dma)
);

// Floppy drive: an 82077 whose sector data rides the SCSI DMA channel
wire        int_floppy, flp_select;
wire        flp_req, flp_wr, flp_bwe, flp_done;
wire [10:0] flp_len;
wire  [9:0] flp_addr;
wire  [7:0] flp_bwdata, flp_bq;

next_floppy #(.CLK_HZ(CLK_HZ)) floppy
(
	.clk(clk),
	.reset(dev_reset),
	.sel(io_flp),
	.addr(io_off[3:0]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(flp_rdata),
	.int_floppy(int_floppy),
	.flp_select(flp_select),
	// This system is the Cube040.  Previous routes the OSP GPO to the
	// shared floppy/SCSI DMA select only on a Cube030.
	.mo_gpo(1'b0),
	.buf_addr(flp_addr),
	.buf_we(flp_bwe),
	.buf_wdata(flp_bwdata),
	.buf_q(flp_bq),
	.buf_len(flp_len),
	.dma_req(flp_req),
	.dma_wr(flp_wr),
	.dma_done(flp_done),
	.img_mounted(fimg_mounted),
	.img_readonly(fimg_readonly),
	.img_size(fimg_size),
	.sd_unit(fsd_unit),
	.sd_lba(fsd_lba),
	.sd_rd(fsd_rd),
	.sd_wr(fsd_wr),
	.sd_ack(fsd_ack),
	.sd_buff_addr(fsd_buff_addr),
	.sd_buff_dout(fsd_buff_dout),
	.sd_buff_din(fsd_buff_din),
	.sd_buff_wr(fsd_buff_wr)
);

// SCSI controller, disk target and DMA channel
wire esp_int_scsi, int_scsi_dma;

next_scsi #(.CLK_HZ(CLK_HZ), .CD_UNITS(6'b001000)) scsi   // target 3 is the CD-ROM (NeXT convention)
(
	.clk(clk),
	.reset(dev_reset),
	.sel_esp(io_esp),
	.sel_csr(io_sc_csr),
	.sel_sptr(io_sc_sptr),
	.sel_ptr(io_sc_ptr),
	.sel_ini(io_sc_ini),
	.addr(io_off[5:0]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(esp_rdata),
	.m_req(sc_m_req),
	.m_we(sc_m_we),
	.m_addr(sc_m_addr),
	.m_be(sc_m_be),
	.m_din(sc_m_din),
	.m_dout(ram_dout),
	.m_ack(sc_m_ack),
	.m_err(sc_m_err),
	.flp_select(flp_select),
	.flp_req(flp_req),
	.flp_wr(flp_wr),
	.flp_len(flp_len),
	.flp_addr(flp_addr),
	.flp_bwe(flp_bwe),
	.flp_bwdata(flp_bwdata),
	.flp_bq(flp_bq),
	.flp_done(flp_done),
	.int_scsi(esp_int_scsi),
	.int_scsi_dma(int_scsi_dma),
	.img_mounted(img_mounted),
	.img_readonly(img_readonly),
	.img_size(img_size),
	.sd_unit(scsi_sd_unit),
	.sd_lba(scsi_sd_lba),
	.sd_rd(scsi_sd_rd),
	.sd_wr(sd_wr),
	.sd_ack_in(sd_ack),
	.sd_buff_addr(sd_buff_addr[8:0]),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din(sd_buff_din),
	.sd_buff_wr(sd_buff_wr),
	.sd_busy(scsi_sd_busy),
	.sd_hold(ca_req | ca_act),
	.cd_fwd_stb(cd_fwd_stb)
);

// The CD-ROM's audio front end shares the CD-ROM slot with the target:
// while it owns the channel the slot sees its frame request.
wire  [2:0] scsi_sd_unit;
wire [31:0] scsi_sd_lba, ca_lba;
wire        scsi_sd_rd, scsi_sd_busy, ca_req, ca_act, ca_rd, cd_fwd_stb;
wire  [5:0] ca_blk_cnt;
assign sd_unit    = ca_act ? 3'd3 : scsi_sd_unit;
assign sd_lba     = ca_act ? ca_lba : scsi_sd_lba;
assign sd_rd      = scsi_sd_rd | ca_rd;
assign sd_blk_cnt = ca_act ? ca_blk_cnt : 6'd0;

next_cd_audio #(.CLK_HZ(CLK_REAL_HZ)) cd_audio
(
	.clk(clk),
	.rst(dev_reset),
	.mounted(cd_mounted),
	.fwd_stb(cd_fwd_stb),
	.stop_stb(1'b0),
	.scsi_busy(scsi_sd_busy),
	.ch_req(ca_req),
	.ch_act(ca_act),
	.io_rd(ca_rd),
	.io_lba(ca_lba),
	.io_blk_cnt(ca_blk_cnt),
	.io_ack(sd_ack),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_wr(sd_buff_wr),
	.snd_l(cd_l),
	.snd_r(cd_r)
);

// the CD-ROM slot's mount state, from its mount pulses
reg cd_mounted = 0;
always @(posedge clk) if (img_mounted[3]) cd_mounted <= (img_size != 0);

// SCC serial controller
next_scc scc_dev
(
	.clk(clk),
	.reset(dev_reset),
	.sel(io_scc),
	.addr1(cpu_addr[1]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(scc_rdata)
);

// BMAP
next_bmap bmap
(
	.clk(clk),
	.reset(dev_reset),
	.sel(sel_bmap),
	.addr(cpu_addr[5:0]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(bmap_rdata),
	.tpe_link(enet_connected),
	.tpe_select(bmap_tpe_select),
	.dsp_hreq_en(bmap_dsp_hreq_en),
	.dsp_txd_en(bmap_dsp_txd_en)
);

// interrupt controller
reg soft1_d, soft2_d, scsi_d, flp_d, power_d;
reg entx_d, enrx_d, entxd_d, enrxd_d, disk_d, diskd_d, sndo_d, sndd_d, km_d;
reg scsid_d;
reg pr_d, prd_d, sndi_d;
reg dspl3_d, dspl4_d, dspd_d;
wire int_dsp_l3, int_dsp_l4, int_dsp_dma;
always @(posedge clk) begin
	soft1_d <= softint1;
	soft2_d <= softint2;
	power_d <= dev_reset ? 1'b0 : int_power;
	scsi_d  <= esp_int_scsi;
	flp_d   <= int_floppy;
	scsid_d <= int_scsi_dma;
	entx_d  <= int_en_tx;
	enrx_d  <= int_en_rx;
	entxd_d <= int_en_tx_dma;
	enrxd_d <= int_en_rx_dma;
	disk_d  <= int_disk;
	diskd_d <= int_disk_dma;
	sndo_d  <= int_snd_ovrun;
	sndd_d  <= int_snd_out_dma;
	sndi_d  <= int_snd_in_dma;
	km_d    <= int_keymouse;
	pr_d    <= int_printer;
	prd_d   <= int_printer_dma;
	dspl3_d <= int_dsp_l3;
	dspl4_d <= int_dsp_l4;
	dspd_d  <= int_dsp_dma;
end

wire [31:0] int_set =
	(32'd1  & {31'd0,  softint1 & ~soft1_d}) |
	({31'd0, softint2 & ~soft2_d} << 1) |
	({31'd0, int_power & ~power_d} << 2) |
	({31'd0, int_keymouse & ~km_d} << 3) |
	({31'd0, vid_int_set} << 5) |
	({31'd0, int_dsp_l3 & ~dspl3_d} << 6) |
	({31'd0, int_floppy & ~flp_d} << 7) |
	({31'd0, int_snd_ovrun & ~sndo_d} << 8) |
	({31'd0, int_en_rx & ~enrx_d} << 9) |
	({31'd0, int_en_tx & ~entx_d} << 10) |
	({31'd0, int_printer & ~pr_d} << 11) |
	({31'd0, esp_int_scsi & ~scsi_d} << 12) |
	({31'd0, int_disk & ~disk_d} << 13) |
	({31'd0, int_dsp_l4 & ~dspl4_d} << 14) |
	({31'd0, int_dsp_dma & ~dspd_d} << 20) |
	({31'd0, int_snd_in_dma & ~sndi_d} << 22) |
	({31'd0, int_snd_out_dma & ~sndd_d} << 23) |
	({31'd0, int_printer_dma & ~prd_d} << 24) |
	({31'd0, int_disk_dma & ~diskd_d} << 25) |
	({31'd0, int_scsi_dma & ~scsid_d} << 26) |
	({31'd0, int_en_rx_dma & ~enrxd_d} << 27) |
	({31'd0, int_en_tx_dma & ~entxd_d} << 28) |
	({31'd0, timer_set} << 29);

wire [31:0] int_clr =
	({31'd0, ~softint1 & soft1_d}) |
	({31'd0, ~softint2 & soft2_d} << 1) |
	({31'd0, ~int_power & power_d} << 2) |
	({31'd0, ~int_keymouse & km_d} << 3) |
	({31'd0, vid_int_clr} << 5) |
	({31'd0, ~int_dsp_l3 & dspl3_d} << 6) |
	({31'd0, ~int_floppy & flp_d} << 7) |
	({31'd0, ~int_snd_ovrun & sndo_d} << 8) |
	({31'd0, ~int_en_rx & enrx_d} << 9) |
	({31'd0, ~int_en_tx & entx_d} << 10) |
	({31'd0, ~int_printer & pr_d} << 11) |
	({31'd0, ~esp_int_scsi & scsi_d} << 12) |
	({31'd0, ~int_disk & disk_d} << 13) |
	({31'd0, ~int_dsp_l4 & dspl4_d} << 14) |
	({31'd0, ~int_dsp_dma & dspd_d} << 20) |
	({31'd0, ~int_snd_in_dma & sndi_d} << 22) |
	({31'd0, ~int_snd_out_dma & sndd_d} << 23) |
	({31'd0, ~int_printer_dma & prd_d} << 24) |
	({31'd0, ~int_disk_dma & diskd_d} << 25) |
	({31'd0, ~int_scsi_dma & scsid_d} << 26) |
	({31'd0, ~int_en_rx_dma & enrxd_d} << 27) |
	({31'd0, ~int_en_tx_dma & entxd_d} << 28) |
	({31'd0, timer_clr} << 29);

next_intc intc
(
	.clk(clk),
	.reset(dev_reset),
	.int_set(int_set),
	.int_clr(int_clr),
	.timer_ipl7(timer_ipl7),
	.sel(io_intc),
	.reg_mask(io_off[11]),
	.addr1(cpu_addr[1]),
	.we(is_write),
	.be(lanes),
	.wdata(cpu_dout),
	.rdata(intc_rdata),
	.ipl(ipl_level)
);

endmodule
