//============================================================================
//  NeXT SCSI subsystem: NCR53C90 (ESP), the SCSI disk target and the
//  NeXT DMA channel for SCSI, modeled after esp.c, scsi.c and dma.c of
//  the Previous emulator.  The disk itself is a MiSTer SD-card image
//  (hps_io block access, 512 byte blocks).
//
//  Registers:
//    sel_esp: ESP + DMA control  0x02014000-0x0201403F
//    sel_csr: DMA CSR            0x02000010-0x02000013
//    sel_ptr: DMA next/limit     0x02004010-0x0200401F
//    sel_ini: DMA init           0x02004210-0x02004213
//
//  The target's command responses (INQUIRY, READ CAPACITY, MODE SENSE,
//  READ TOC, READ SUB-CHANNEL) are built by the HPS (Main_MiSTer
//  support/next/next_scsi.cpp) and fetched as one block read of a window
//  LBA on the CD-ROM slot: 0x7E000000 | unit<<20 | flags<<16 | op<<8 | a,
//  bytes 510..511 carrying the response length.  CD audio transport
//  commands and MODE SELECT are forwarded as one block write of
//  0x7D000000 | unit<<20 | op<<8, the CDB at bytes 496..505 and the
//  parameter list at 0.  REQUEST SENSE stays here (the sense is this
//  engine's state), as do the sector data paths.
//
//  Selection reads the CDB from the FIFO; partial CDBs and selection
//  with ATN and stop continue through transfer information. TI moves
//  bytes in all six information phases through PIO or the DMA channel;
//  ICCS collects status and message; message accepted reports the ESP's
//  disconnected interrupt after the command-complete message is accepted.
//  Selecting an absent target times out with a disconnect interrupt.
//============================================================================

module next_scsi #(
	parameter CLK_HZ = 50000000,
	// One bit per SCSI target: set means the target is a CD-ROM (SONY
	// CDU-541: INQUIRY type 0x05, removable, 2048-byte sectors) instead of
	// a 512-byte fixed disk.  The NeXT install floppy scans the bus for a
	// type-0x05 device, so a data-CD image must present as one.
	parameter [5:0] CD_UNITS = 6'b000000
)
(
	input         clk,
	input         reset,

	input         sel_esp,
	input         sel_csr,
	input         sel_sptr,      // saved next/limit/start/stop
	input         sel_ptr,
	input         sel_ini,
	input   [5:0] addr,          // byte offset within the selected block
	input         we,
	input   [1:0] be,            // [1] = even byte, [0] = odd byte
	input  [15:0] wdata,
	output [15:0] rdata,

	// DMA master port (32-bit words in main RAM)
	output reg        m_req,
	output reg        m_we,
	// Preserve the complete word address through arbitration.  Truncating
	// this to the RAM aperture here silently wrapped bad DMA descriptors
	// into unrelated RAM, including MMU tables.
	output reg [29:0] m_addr,
	output reg  [3:0] m_be,
	output reg [31:0] m_din,
	input      [31:0] m_dout,
	input             m_ack,
	input             m_err,

	// The floppy shares this DMA channel: when the controller switches
	// it over, the engine moves the floppy's sector buffer instead of
	// its own, exactly as dma_esp_*_memory does on floppy_select.
	input         flp_select,
	input         flp_req,       // the floppy wants the channel
	input         flp_wr,        // 1 = floppy to memory
	input  [10:0] flp_len,       // bytes in the sector
	output  [9:0] flp_addr,
	output        flp_bwe,
	output  [7:0] flp_bwdata,
	input   [7:0] flp_bq,
	output reg    flp_done,

	output        int_scsi,      // level, for INT_SCSI
	output        int_scsi_dma,  // level, for INT_SCSI_DMA

	// MiSTer SD block interface: one slot per SCSI target (0 and 1).
	// The engine talks to one target at a time, so a single set of SD
	// signals is routed to the mounted slot the connected command
	// addresses; sd_unit says which.
	input   [5:0] img_mounted,
	input         img_readonly,
	input  [63:0] img_size,
	output  [2:0] sd_unit,
	output [31:0] sd_lba,
	output reg    sd_rd,
	output reg    sd_wr,
	input         sd_ack_in,
	input   [8:0] sd_buff_addr,
	input   [7:0] sd_buff_dout,
	output  [7:0] sd_buff_din,
	input         sd_buff_wr,
	// the CD audio engine shares the CD-ROM slot: it may only start a
	// transfer while sd_busy is low, and this engine starts none while
	// sd_hold is high
	output        sd_busy,
	input         sd_hold,
	output reg    cd_fwd_stb     // one clock: a CD transport command was forwarded
);

// an acknowledge on the shared slot belongs to the audio engine while it holds it
wire sd_ack = sd_ack_in & ~sd_hold;

localparam STAT_VGC = 8'h08, STAT_TC = 8'h10, STAT_PE = 8'h20,
           STAT_GE  = 8'h40, STAT_INT = 8'h80;

localparam INTR_SEL = 8'h01, INTR_SELATN = 8'h02, INTR_RESEL = 8'h04,
           INTR_FC  = 8'h08, INTR_BS     = 8'h10, INTR_DC    = 8'h20,
           INTR_ILL = 8'h40, INTR_RST    = 8'h80;

localparam PHASE_DO = 3'd0, PHASE_DI = 3'd1, PHASE_CD = 3'd2,
           PHASE_ST = 3'd3, PHASE_MO = 3'd6, PHASE_MI = 3'd7;

localparam STAT_GOOD = 8'h00, STAT_CHECK_COND = 8'h02;

localparam SC_NO_ERROR      = 8'h00, SC_INVALID_CMD = 8'h20,
	       SC_INVALID_LBA   = 8'h21, SC_INVALID_LUN = 8'h25,
	       SC_INVALID_CDB   = 8'h24, SC_SAVE_UNSUPP = 8'h39,
	       SC_WRITE_PROTECT = 8'h27, SC_NOT_READY   = 8'h3A;  // medium not present

//----------------------------------------------------------------------------
// ESP registers
//----------------------------------------------------------------------------

// The 16-byte ESP FIFO as a circular buffer: the head is fifo[fifo_rd],
// a push lands at fifo_wr.  It used to be a shift register (every pop
// moved all 16 bytes down), which cost a mux per stored bit; the pointers
// cost one 16:1 byte mux for the head.  Empty reads as zero, as before.
reg  [7:0] fifo [0:15];
reg  [3:0] fifo_rd = 0, fifo_wr = 0;
reg  [4:0] fifoflags;
wire [7:0] fifo_head = (fifoflags != 0) ? fifo[fifo_rd] : 8'h00;

reg  [7:0] wr_tcl, wr_tch;       // write staging (not changed by reset)
reg [16:0] counter;

reg  [7:0] command0, command1;
reg        cmd_inprogress, cmd_waiting;
// A TI/PAD completion belongs to the ESP command, not to the lifetime of
// bytes retained by the NeXT DMA channel. Route changes and later FLUSHes
// must not complete that same transfer again after its interrupt was sent.
reg        transfer_reported;
reg  [7:0] status;
reg  [7:0] intstatus;
reg  [7:0] seqstep;
reg  [7:0] syncperiod, syncoffset;
reg  [7:0] configuration, conf2;
reg  [7:0] clockconv;
reg  [7:0] selectbusid, selecttimeout;
reg  [7:0] dma_control, dma_status;
reg  [7:0] dma_buf [0:15];
reg  [4:0] dma_buf_size;        // valid bytes still held by the channel
reg  [4:0] dma_buf_limit;       // next fill position, including init offset
wire [3:0] dma_buf_fill = dma_buf_limit[3:0];
wire [4:0] dma_buf_head = dma_buf_limit - dma_buf_size;
reg        mode_dma;

reg  [2:0] phase;                // SCSIbus.phase, read in status[2:0]

assign int_scsi = dma_control[5] & status[7];   // ESPCTRL_ENABLE_INT & STAT_INT

//----------------------------------------------------------------------------
// SCSI disk target state
//----------------------------------------------------------------------------

// Targets 0..3 have host slots (NeXT.sv VDNUM); selecting a target at or
// above SCSI_UNITS times out exactly like an unmounted one, so 4 and 5 are
// not modelled (150 ALMs and 190 registers of per-target state).
localparam SCSI_UNITS = 4;       // targets 0..3; the host is 7
// Two hard disks and the CD-ROM: targets 0, 1 and 3 are populated, target
// 2 is not (it times out like an unmounted one).  The per-unit state is
// stored for the three populated targets only (uidx: 0, 1, 3 -> 0, 1, 2),
// which keeps the OSD slot = target numbering the ROM, NeXTSTEP and Main
// (NEXT_CDROM_SLOT 3) all rely on while the fourth unit's state goes.
localparam N_UNITS = 3;
function automatic [1:0] uidx;
	input [2:0] t;
	uidx = (t == 3'd3) ? 2'd2 : t[1:0];
endfunction
function automatic has_unit;
	input [2:0] t;
	has_unit = (t < 3'd4) && (t != 3'd2);
endfunction
integer mk;                      // mount scan index
integer sk;                      // reset scan index

reg  [5:0] disk_present_v = 0;
// A CD-ROM's medium can be gone while the drive is still on the bus:
// after START STOP UNIT with LoEj (the eject NeXTSTEP's Workspace sends
// for "Eject"), or after the OSD unmounted the image.  The drive then
// answers selection, INQUIRY, REQUEST SENSE and MODE SENSE as before and
// every medium command with NOT READY / medium not present, until the
// OSD mounts an image again.  Without this the eject reported GOOD but
// the medium stayed, and NeXTSTEP kept asking the user to eject it.
reg  [5:0] ejected_v = 0;        // ejected by START STOP UNIT
reg  [5:0] cd_seen_v = 0;        // a CD unit that has had an image this session
// the command FSM's eject/load request (one driver per register: the
// mount block owns ejected_v, the FSM toggles eject_tog)
reg        eject_tog = 0, eject_tog_q = 0;
reg        eject_val = 0;
reg  [2:0] eject_unit = 0;
reg  [5:0] disk_ro_v = 0;
reg [31:0] img_blocks_v [0:N_UNITS-1];      // disk size in 512 byte blocks
reg  [2:0] t_unit = 0;           // target the connected command addresses
wire [1:0] t_uidx = uidx(t_unit);
assign sd_unit = win_act ? 3'd3 : t_unit;   // windows live on the CD-ROM slot

// The engine was written for one disk; keeping these names as views of
// the connected target leaves every user of them unchanged.
wire        disk_present = disk_present_v[t_unit];
wire        t_ejected    = ejected_v[t_unit] || (CD_UNITS[t_unit] && !disk_present);
wire        disk_ro      = disk_ro_v[t_unit];
wire [31:0] img_blocks   = img_blocks_v[t_uidx];
// A CD-ROM target reports the CD-ROM INQUIRY device type (0x05) so the
// install media scan finds it, and is read-only, but is otherwise a normal
// 512-byte-block target: the boot/installer reads SCSI devices in 512-byte
// blocks and a CD ISO reads back correctly that way.
wire        t_is_cd      = CD_UNITS[t_unit];

reg  [7:0] t_status;             // status byte for ICCS
reg  [7:0] t_message;            // message byte for ICCS
reg  [7:0] sense_code [0:N_UNITS-1];
reg        sense_valid [0:N_UNITS-1];
reg [31:0] sense_info [0:N_UNITS-1];
reg  [2:0] t_lun;

reg [31:0] lba;
reg [15:0] blockcounter;

//----------------------------------------------------------------------------
// DMA channel (CHANNEL_SCSI)
//----------------------------------------------------------------------------

reg  [7:0] d_csr;
// Same-edge scratch flag: a newly generated DMA completion wins over a
// CLRCOMPLETE write acknowledging an older segment (RESET still wins).
reg        dma_completion_event;
reg [31:0] d_next, d_limit, d_start, d_stop;
reg        d_dev2m;             // last DMA CSR write bit 2
// ESPCTRL_FLUSH is a CPU write but the RAM port is asynchronous.  The ROM
// can issue several pumps before the first RAM acknowledgement, so retain
// every write instead of collapsing them into one pending bit.
reg  [3:0] dma_flush_count;
reg  [5:0] dma_flush_return;
reg        dma_flush_active;    // current memory request is a queued FLUSH
reg  [1:0] dma_irq_resume;      // 1: retained DI bytes, 2: retained DO bytes
// saved registers: plain storage on the non-turbo board (the engine
// never writes them, DMA_Saved_*_Read/Write in dma.c)
reg [31:0] s_next, s_limit, s_start, s_stop;

assign int_scsi_dma = d_csr[3];

//----------------------------------------------------------------------------
// data buffer: one 512 byte sector, also carries the command responses.
// Single write site and single registered read (block RAM discipline).
//----------------------------------------------------------------------------

reg  [7:0] dbuf [0:511];
reg  [7:0] db_q;

reg  [9:0] buf_pos, buf_limit;
reg        buf_disk;             // 1 = buffer refills from the disk image

reg  [8:0] fill_idx;

// the HPS window (see the header): the response block lands in dbuf
localparam [31:0] WIN_RESP = 32'h7E00_0000, WIN_CMD = 32'h7D00_0000;
reg [31:0] win_lba;
reg  [9:0] win_alloc;            // the CDB's allocation length, clamped to a block
reg [15:0] win_len;              // bytes 510..511 of the response block
reg        win_act;              // a window transfer owns the CD-ROM slot
reg        msel;                 // the DATA OUT in flight is a MODE SELECT list
reg  [5:0] fwd_ret;              // state after a forwarded command's block write

// engine states
localparam X_IDLE    = 6'd0,  X_SEL_MSG = 6'd1,  X_SEL_CDB = 6'd2,
           X_DISPATCH= 6'd3,  X_FILL    = 6'd4,  X_POSTCMD = 6'd5,
           X_INT_WAIT= 6'd6,  X_RD_SECT = 6'd7,  X_SD_RD_GO= 6'd8,
           X_SD_RD_ACK=6'd9,  X_WR_SECT = 6'd10, X_SD_WR_GO= 6'd11,
           X_SD_WR_ACK=6'd12, X_DI_CHK  = 6'd13, X_DI_RD   = 6'd14,
           X_DI_GET  = 6'd15, X_DI_WR   = 6'd16, X_DO_CHK  = 6'd17,
	           X_DO_RD   = 6'd18, X_DO_PUT  = 6'd19, X_ICCS1   = 6'd20,
	           X_ICCS2   = 6'd21, X_PIO_RD  = 6'd22, X_PIO_GET = 6'd23,
	           X_PIO_WAIT= 6'd24, X_FDI_CHK = 6'd25, X_FDI_WAIT= 6'd26,
	           X_FDI_GET = 6'd27, X_FDO     = 6'd28,
	           X_TI_IN   = 6'd29, X_TI_OUT = 6'd30,
	           X_WIN_GO  = 6'd31, X_WIN_ACK = 6'd32, X_WIN_DONE= 6'd33,
	           X_CMD_FILL= 6'd34, X_CMD_GO  = 6'd35, X_CMD_ACK = 6'd36;
reg  [5:0] xst;

reg        sel_atn;              // current select has an identify message
reg  [7:0] cdb0, cdb1, cdb2, cdb3, cdb4, cdb5, cdb6, cdb7, cdb8, cdb9;
reg  [3:0] cdb_n;
reg        sel_stop, cdb_ti;
reg        ti_aux_in, ti_aux_out;
reg        ti_dma_started;
reg  [2:0] ti_phase;
reg        mi_held, msg_resume;
reg        msg_len_pending, msg_reject;
reg  [7:0] msg_left;

// SCSI-1 CDB groups: six, ten or twelve bytes. Reserved groups are
// consumed as six-byte commands and rejected by the target dispatcher.
function automatic [3:0] cdb_length;
	input [7:0] op;
	begin
		case (op[7:5])
			3'd1, 3'd2: cdb_length = 4'd10;
			3'd5: cdb_length = 4'd12;
			default: cdb_length = 4'd6;
		endcase
	end
endfunction

wire ti_out_fifo = (fifoflags != 0);
wire [7:0] ti_out_byte = ti_out_fifo ? fifo_head : dma_buf[dma_buf_head[3:0]];
wire ti_out_last = mode_dma ? (counter == 1) : (fifoflags == 1);

reg  [1:0] rd_ret;               // X_RD_SECT return: 0 = dispatch, 1 = DMA, 2 = PIO
reg        sd_ret;               // SD op return: 0 = read path, 1 = write path
reg        pad_mode;             // transfer without the memory channel
reg  [1:0] word_cnt;             // bytes gathered in the current DMA word
reg [31:0] word_buf;
reg  [2:0] do_rem;               // bytes left to unpack from a DMA word

reg        flp_active;         // a floppy sector is in flight
reg        cmd_busy;           // a SCSI command is connected
reg        flp_req_d;          // for the rising edge of a sector request
reg        flp_pend;           // a request seen but not yet taken
reg [24:0] dly_us;               // interrupt delay countdown
localparam ESP_DELAY_US = 25'd100;

// DMA pacing, matching the reference emulator: the first memory pass
// of a transfer waits a seek/sector time, and after every channel
// limit event (buffer complete, chain swap) the next pass waits the
// ESP_IO tick.  This is what gives the driver time to service the
// complete interrupt and program the next chain segment before data
// flows again; without it the engine outruns the CPU and fills a
// swapped-in buffer whose start/stop the driver has not refreshed yet.
localparam SECTOR_US = 9'd350;    // SCSI_SECTOR_TIME_HD
localparam GAP_US    = 9'd100;    // ESP_IO tick
reg  [8:0] gap_us;

reg [31:0] sd_lba_r;
// hps_io pipelines sd_buff_wr beyond the cycle which drops sd_ack.  Keep
// ownership through that falling edge so the final byte of the block is not
// discarded, while still rejecting the shared stream before our ack arrives.
reg        sd_read_owned;
assign sd_lba = win_act ? win_lba : sd_lba_r;

//----------------------------------------------------------------------------
// disk image mount and geometry (cylinders = blocks/128, rounded up).
// Outside the reset: the mount pulse
// fires once at OSD time, usually before the user resets the machine
// into the new configuration.
//----------------------------------------------------------------------------

always @(posedge clk) begin
	eject_tog_q <= eject_tog;
	if (eject_tog != eject_tog_q) ejected_v[eject_unit] <= eject_val;
	for (mk = 0; mk < SCSI_UNITS; mk = mk + 1) begin
		if (img_mounted[mk] && has_unit(mk[2:0])) begin
			disk_present_v[mk] <= (img_size != 0);
			disk_ro_v[mk] <= img_readonly;
			img_blocks_v[uidx(mk[2:0])] <= img_size[40:9];
			ejected_v[mk] <= 0;
			if (img_size != 0 && CD_UNITS[mk]) cd_seen_v[mk] <= 1;
		end
	end
end

// microsecond tick (a 1 MHz simulation clock degenerates to a tick
// every cycle; keep the counter width legal for that case)
localparam TICK = CLK_HZ / 1000000;
localparam TCW = (TICK > 1) ? $clog2(TICK) : 1;
reg [TCW-1:0] tickcnt;
wire tick = (tickcnt == TICK-1);

//----------------------------------------------------------------------------
// register read mux (byte offsets; each 16-bit word carries two regs).
// Plain nested ternaries over scalar registers: functions or array reads
// in combinational paths break sensitivity in some simulators.
//----------------------------------------------------------------------------

wire [5:0] a_even = {addr[5:1], 1'b0};
wire [5:0] a_odd  = {addr[5:1], 1'b1};

`define ESP_READ(a) ( \
	((a) == 6'h00) ? counter[7:0] : \
	((a) == 6'h01) ? counter[15:8] : \
	((a) == 6'h02) ? fifo_head : \
	((a) == 6'h03) ? command0 : \
	((a) == 6'h04) ? ((status & 8'hF8) | {5'd0, phase}) : \
	((a) == 6'h05) ? intstatus : \
	((a) == 6'h06) ? seqstep : \
	((a) == 6'h07) ? {3'd0, fifoflags} : \
	((a) == 6'h08) ? configuration : \
	((a) == 6'h0B) ? conf2 : \
	(((a) >= 6'h0C) && ((a) <= 6'h0F)) ? 8'h01 : \
	((a) == 6'h20) ? dma_control : \
	((a) == 6'h21) ? dma_status : 8'h00 )

wire [31:0] ptr_q = (addr[3:2] == 2'd0) ? d_next :
                    (addr[3:2] == 2'd1) ? d_limit :
                    (addr[3:2] == 2'd2) ? d_start : d_stop;

wire [31:0] sptr_q = (addr[3:2] == 2'd0) ? s_next :
                     (addr[3:2] == 2'd1) ? s_limit :
                     (addr[3:2] == 2'd2) ? s_start : s_stop;

assign rdata = sel_esp ? {`ESP_READ(a_even), `ESP_READ(a_odd)} :
               sel_csr ? (addr[1] ? 16'h0000 : {d_csr, 8'h00}) :
               sel_sptr ? (addr[1] ? sptr_q[15:0] : sptr_q[31:16]) :
               sel_ptr ? (addr[1] ? ptr_q[15:0] : ptr_q[31:16]) :
               sel_ini ? (addr[1] ? d_next[15:0] : d_next[31:16]) : 16'h0000;

//----------------------------------------------------------------------------
// data buffer port
//----------------------------------------------------------------------------

// The buffer bus from the host is one stream shared by every image slot.
// sd_ack identifies the owner at the start, then sd_read_owned covers the
// delayed final write strobe after hps_io has lowered sd_ack.
wire in_sd_rd = ((xst == X_SD_RD_GO) || (xst == X_SD_RD_ACK) ||
                 (xst == X_WIN_GO) || (xst == X_WIN_ACK)) &&
                (sd_ack || sd_read_owned);
wire in_sd_wr = (xst == X_SD_WR_GO) || (xst == X_SD_WR_ACK) ||
                (xst == X_CMD_GO) || (xst == X_CMD_ACK);
assign sd_busy = sd_rd | sd_wr | sd_read_owned | in_sd_wr | win_act;

reg        eng_we;
reg  [8:0] eng_addr;
reg  [7:0] eng_wd;

wire       db_we   = in_sd_rd ? sd_buff_wr   : eng_we;
wire [8:0] db_addr = in_sd_rd ? sd_buff_addr :
                     in_sd_wr ? sd_buff_addr : eng_addr;
wire [7:0] db_wd   = in_sd_rd ? sd_buff_dout : eng_wd;

// while the floppy owns the channel the engine addresses its buffer
wire fdma = flp_select & flp_active;
assign flp_addr   = {1'b0, eng_addr};
assign flp_bwe    = fdma & eng_we;
assign flp_bwdata = eng_wd;
wire [7:0] eng_q  = fdma ? flp_bq : db_q;

always @(posedge clk) begin
	if (db_we) dbuf[db_addr] <= db_wd;
	db_q <= dbuf[db_addr];
end

assign sd_buff_din = db_q;

//----------------------------------------------------------------------------
// response byte tables
//----------------------------------------------------------------------------

function automatic [7:0] sense_byte;
	input [7:0] i;
	begin
		case (i)
			8'd0: sense_byte = sense_valid[t_uidx] ? 8'hF0 : 8'h70;
			8'd2: sense_byte = {4'd0, key_of(sense_code[t_uidx])};
			8'd3: sense_byte = sense_valid[t_uidx] ? sense_info[t_uidx][31:24] : 8'h00;
			8'd4: sense_byte = sense_valid[t_uidx] ? sense_info[t_uidx][23:16] : 8'h00;
			8'd5: sense_byte = sense_valid[t_uidx] ? sense_info[t_uidx][15:8]  : 8'h00;
			8'd6: sense_byte = sense_valid[t_uidx] ? sense_info[t_uidx][7:0]   : 8'h00;
			8'd7: sense_byte = 8'd14;
			8'd12: sense_byte = sense_code[t_uidx];
			default: sense_byte = 8'h00;
		endcase
	end
endfunction

function automatic [3:0] key_of;
	input [7:0] code;
	begin
		case (code)
			SC_NO_ERROR:      key_of = 4'h0;  // no sense
			8'h04, SC_NOT_READY:
			                  key_of = 4'h2;  // not ready
			8'h03, SC_INVALID_CMD, SC_INVALID_LBA, SC_INVALID_CDB,
			SC_INVALID_LUN, SC_SAVE_UNSUPP:
			                  key_of = 4'h5;  // illegal request
			SC_WRITE_PROTECT: key_of = 4'h7;  // data protect
			default:          key_of = 4'h4;  // hardware error
		endcase
	end
endfunction

// the CDB as the command block carries it (bytes 496..505 of dbuf)
function automatic [7:0] cdb_byte;
	input [3:0] i;
	begin
		case (i)
			4'd0: cdb_byte = cdb0; 4'd1: cdb_byte = cdb1; 4'd2: cdb_byte = cdb2;
			4'd3: cdb_byte = cdb3; 4'd4: cdb_byte = cdb4; 4'd5: cdb_byte = cdb5;
			4'd6: cdb_byte = cdb6; 4'd7: cdb_byte = cdb7; 4'd8: cdb_byte = cdb8;
			4'd9: cdb_byte = cdb9;
			default: cdb_byte = 8'h00;
		endcase
	end
endfunction

//----------------------------------------------------------------------------
// FIFO helpers
//----------------------------------------------------------------------------

integer i;

task automatic fifo_clear;
	begin
		fifo_rd <= 4'd0;
		fifo_wr <= 4'd0;
		fifoflags <= 0;
	end
endtask

task automatic fifo_pop;
	begin
		if (fifoflags != 0) begin
			fifo_rd <= fifo_rd + 1'd1;
			fifoflags <= fifoflags - 1'd1;
		end
	end
endtask

task automatic fifo_push;
	input [7:0] v;
	begin
		if (fifoflags == 5'd16) begin
			fifo[fifo_wr - 1'd1] <= v;   // overflow overwrites the top
			status[6] <= 1'b1;           // STAT_GE
		end
		else begin
			fifo[fifo_wr] <= v;
			fifo_wr <= fifo_wr + 1'd1;
			fifoflags <= fifoflags + 1'd1;
		end
	end
endtask

// A full internal buffer changes hands once on every visit.  In particular,
// dma_esp_write_memory() revisits (and toggles for) a retained full buffer
// after software re-arms the channel.
task automatic dma_status_toggle;
	begin
		dma_status[7:6] <= (dma_status[7:6] == 2'b01) ? 2'b11 : 2'b01;
	end
endtask

// dma_interrupt(): call only once next has reached limit.  A chained window
// becomes live while ENABLE stays set; a single window disables the channel.
task automatic dma_hit_limit;
	begin
		dma_completion_event = 1;
		d_csr[3] <= 1;
		gap_us <= GAP_US;
		if (d_csr[1]) begin
			d_next <= d_start;
			d_limit <= d_stop;
			d_csr[1] <= 0;
		end
		else d_csr[0] <= 0;
	end
endtask

// Previous stops the channel and reports COMPLETE|BUSEXC when a DMA
// memory access faults.  Keep SUPDATE intact, as its DMA_CSR exception
// path does, but never advance NEXT or consume buffered data.
task automatic dma_bus_exception;
	begin
		dma_completion_event = 1;
		d_csr[0] <= 0;
		d_csr[3] <= 1;
		d_csr[4] <= 1;
		gap_us <= GAP_US;
	end
endtask

task automatic esp_disconnect_reset;
	begin
		cmd_busy <= 0;
		ti_aux_in <= 0; ti_aux_out <= 0;
		ti_dma_started <= 0;
		mi_held <= 0; msg_resume <= 0;
		phase <= PHASE_DO;
		intstatus <= INTR_DC;
		dma_flush_count <= 0;
		dma_flush_return <= X_IDLE;
		dma_flush_active <= 0;
		dma_irq_resume <= 0;
		dly_us <= ESP_DELAY_US;
		xst <= X_INT_WAIT;
		m_req <= 0;
		sd_rd <= 0;
		sd_wr <= 0;
		sd_read_owned <= 0;
		win_act <= 0;
		msel <= 0;
	end
endtask

task automatic hard_reset;
	begin
		cmd_busy <= 0;
		ti_aux_in <= 0; ti_aux_out <= 0;
		ti_dma_started <= 0;
		sel_stop <= 0; cdb_ti <= 0;
		mi_held <= 0; msg_resume <= 0;
		msg_len_pending <= 0; msg_reject <= 0; msg_left <= 0;
		// esp_reset_hard() + esp_reset_soft() in esp.c
		clockconv <= 8'h02;
		configuration <= configuration & 8'h07;
		fifo_clear;
		syncperiod <= 8'h05;
		syncoffset <= 8'h00;
		status <= status & ~(STAT_INT|STAT_VGC|STAT_PE|STAT_GE|STAT_TC);
		intstatus <= 8'h00;
		mode_dma <= 0;
		dma_flush_count <= 0;
		dma_flush_return <= X_IDLE;
		dma_flush_active <= 0;
		dma_irq_resume <= 0;
		counter <= 0;
		seqstep <= 8'h00;
		command0 <= 8'h00;
		command1 <= 8'h00;
		cmd_inprogress <= 0;
		cmd_waiting <= 0;
		transfer_reported <= 0;
		xst <= X_IDLE;
		m_req <= 0;
		sd_rd <= 0;
		sd_wr <= 0;
		sd_read_owned <= 0;
		win_act <= 0;
		msel <= 0;
	end
endtask

task automatic cdb_receive;
	input [7:0] v;
	begin
		case (cdb_n)
			4'd0: cdb0 <= v;
			4'd1: cdb1 <= v;
			4'd2: cdb2 <= v;
			4'd3: cdb3 <= v;
			4'd4: cdb4 <= v;
			4'd5: cdb5 <= v;
			4'd6: cdb6 <= v;
			4'd7: cdb7 <= v;
			4'd8: cdb8 <= v;
			4'd9: cdb9 <= v;
			default: ;
		endcase
		cdb_n <= cdb_n + 1'd1;
		if (cdb_n != 0 && cdb_n + 1'd1 == cdb_length(cdb0)) begin
			if (cdb_ti && mode_dma && d_csr[0] && d_next == d_limit) dma_hit_limit;
			ti_aux_out <= 0;
			xst <= X_DISPATCH;
		end
	end
endtask

// This asynchronous disk accepts IDENTIFY and NOP. Other messages,
// including complete extended negotiation messages, receive MESSAGE
// REJECT. Keep parsing across TI boundaries if the host splits a message.
task automatic message_receive;
	input [7:0] v;
	reg complete, reject;
	begin
		complete = 0;
		reject = msg_reject;
		if (msg_len_pending) begin
			msg_len_pending <= 0;
			msg_left <= v;
			complete = (v == 0);
		end
		else if (msg_left != 0) begin
			msg_left <= msg_left - 1'd1;
			complete = (msg_left == 1);
		end
		else if (v == 8'h01) begin
			msg_len_pending <= 1;
			reject = 1;
		end
		else begin
			complete = 1;
			if (v[7]) begin t_lun <= v[2:0]; sel_atn <= 1; end
			else if (v != 8'h08) reject = 1;
		end
		msg_reject <= reject;
		if (complete && ti_out_last) begin
			phase <= reject ? PHASE_MI : PHASE_CD;
			t_message <= reject ? 8'h07 : 8'h00;
			msg_resume <= reject;
			mi_held <= 0;
			msg_reject <= 0;
		end
	end
endtask

// stage an interrupt: status bits are set now, STAT_INT after the delay
task automatic esp_irq;
	input [24:0] us;
	begin
		dly_us <= us;
		xst <= X_INT_WAIT;
	end
endtask

// scsi_read_sector() entry
task automatic read_sector;
	input [1:0] ret;
	begin
		rd_ret <= ret;
		xst <= X_RD_SECT;
	end
endtask

// selection timeout in microseconds:
// (selecttimeout * 8192 * clockconv) / ESP_CLOCK_FREQ(20) ~ timeout*conv*410
wire [24:0] seltout_us = selecttimeout * clockconv * 25'd410;

//----------------------------------------------------------------------------
// main engine
//----------------------------------------------------------------------------

wire [7:0] csr_or = (be[1] ? wdata[15:8] : 8'h00) | (be[0] ? wdata[7:0] : 8'h00);

// LUN of the current command: from the identify message when present,
// else from the CDB
wire [2:0] cmd_lun = sel_atn ? t_lun : cdb1[7:5];

// A register access and an engine event may target the FIFO on the same
// clock.  The reference runs those calls serially.  Give the CPU operation
// priority and leave the engine state in place so it retries on the next
// clock, avoiding two helper calls updating the FIFO from one stale count.
wire cpu_fifo_access = sel_esp &&
	((be[1] && a_even == 6'h02) || (be[0] && a_odd == 6'h02));

wire cpu_flush_write = sel_esp && we && be[1] && (a_even == 6'h20) &&
                       wdata[10] && d_csr[0] && d_dev2m &&
                       (d_next < d_limit);
wire dma_flush_done = (xst == X_DI_WR) && m_req && m_ack &&
                      dma_flush_active;

// Execute the active (bottom) rank.  Writes to the command register are
// queued separately below so a command cannot preempt an in-flight one.
task automatic start_command;
	input [7:0] v;
	begin
		command0 <= v;
		cmd_inprogress <= 1;
		ti_aux_in <= 0; ti_aux_out <= 0;
		ti_dma_started <= 0;
		if (v[7]) begin
			counter <= ({wr_tch, wr_tcl} == 16'd0) ? 17'h10000
			                                       : {1'b0, wr_tch, wr_tcl};
			status[4] <= 1'b0;   // clear STAT_TC
			mode_dma <= 1;
			dma_irq_resume <= 0;
		end
		else begin
			mode_dma <= 0;
			dma_irq_resume <= 0;
		end

		case (v[6:0])
			7'h00: cmd_inprogress <= 0;  // NOP completes synchronously
			7'h01: begin                 // flush FIFO completes synchronously
				fifo_clear;
				cmd_inprogress <= 0;
			end
			7'h02: hard_reset;            // reset chip
			7'h03: begin                  // reset SCSI bus
				cmd_busy <= 0;
				mi_held <= 0; msg_resume <= 0;
				msg_len_pending <= 0; msg_reject <= 0; msg_left <= 0;
				mode_dma <= 0;
				dma_flush_count <= 0;
				dma_flush_active <= 0;
				dma_irq_resume <= 0;
				counter <= 0;
				seqstep <= 8'h00;
				command0 <= 0;
				command1 <= 0;
				cmd_waiting <= 0;
				xst <= X_IDLE;
				m_req <= 0;
				sd_rd <= 0;
				sd_wr <= 0;
				sd_read_owned <= 0;
				if (!configuration[6]) begin         // !CFG1_RESREPT
					intstatus <= INTR_RST;
					phase <= PHASE_DO;
					dly_us <= 25'd500;
					xst <= X_INT_WAIT;
				end
				else cmd_inprogress <= 0;
			end
			7'h10: begin                 // transfer information
				transfer_reported <= 0;
				// TI transfers information in every initiator phase. PIO
				// ignores the transfer counter; DMA counts bytes accepted
				// by the target/controller, including FIFO-routed DMA.
				pad_mode <= 0;
				word_cnt <= 0;
				gap_us <= v[7] ? SECTOR_US : 9'd0;
				ti_phase <= phase;
				if (!cmd_busy || (phase == PHASE_MI && mi_held)) begin
					intstatus <= INTR_ILL;
					esp_irq(ESP_DELAY_US);
				end
				else case (phase)
					PHASE_DI: xst <= !v[7] ? X_PIO_RD :
					                    dma_control[4] ? X_DI_CHK : X_FDI_CHK;
					PHASE_DO: xst <= v[7] && dma_control[4] ? X_DO_CHK : X_FDO;
					PHASE_ST, PHASE_MI: begin ti_aux_in <= 1; xst <= X_TI_IN; end
					PHASE_CD, PHASE_MO: begin
						ti_aux_out <= 1;
						if (phase == PHASE_CD) cdb_ti <= 1;
						xst <= X_TI_OUT;
					end
					default: begin intstatus <= INTR_ILL; esp_irq(ESP_DELAY_US); end
				endcase
			end
			7'h11: begin                 // initiator command complete
				dma_irq_resume <= 0;
				xst <= X_ICCS1;
			end
			7'h12: begin                 // message accepted
				if (msg_resume && mi_held) begin
					msg_resume <= 0; mi_held <= 0;
					phase <= PHASE_CD;
					intstatus <= INTR_BS;
					esp_irq(ESP_DELAY_US);
				end
				else esp_disconnect_reset;
			end
			7'h18: begin                 // transfer pad
				transfer_reported <= 0;
				pad_mode <= 1;
				word_cnt <= 0;
				xst <= (phase == PHASE_DI) ? X_DI_CHK :
				       (phase == PHASE_DO) ? X_DO_CHK : X_IDLE;
			end
			7'h41, 7'h42, 7'h43: begin   // select, select with ATN, ATN and stop
				// A select aborts whatever transfer state was left behind,
				// including an in-flight memory request.
				m_req <= 0;
				sd_rd <= 0;
				sd_wr <= 0;
				sd_read_owned <= 0;
				seqstep <= 8'h00;
				dma_flush_count <= 0;
				dma_flush_active <= 0;
				dma_irq_resume <= 0;
				sel_atn <= v[1];
				sel_stop <= (v[6:0] == 7'h43);
				cdb_ti <= 0;
				mi_held <= 0; msg_resume <= 0;
				msg_len_pending <= 0; msg_reject <= 0; msg_left <= 0;
				cdb_n <= 0;
				if (!has_unit(selectbusid[2:0]) ||
				    (!disk_present_v[selectbusid[2:0]] && !cd_seen_v[selectbusid[2:0]])) begin
					// esp_select() clears both command ranks on timeout.
					intstatus <= INTR_DC;
					command0 <= 0;
					command1 <= 0;
					cmd_waiting <= 0;
					cmd_busy <= 0;
					phase <= PHASE_ST;
					dly_us <= seltout_us;
					xst <= X_INT_WAIT;
				end
				else begin
					cmd_busy <= 1;
					t_unit <= selectbusid[2:0];
					xst <= v[1] ? X_SEL_MSG : X_SEL_CDB;
				end
			end
			7'h44: cmd_inprogress <= 0; // enable selection, no reselections
			default: begin              // unimplemented: illegal command
				// esp_command_clear() is immediate; command execution itself
				// remains in progress until software acknowledges INTR_ILL.
				command0 <= 0;
				command1 <= 0;
				cmd_waiting <= 0;
				intstatus <= intstatus | INTR_ILL;
				dly_us <= 25'd20;
				xst <= X_INT_WAIT;
			end
		endcase
	end
endtask

task automatic reg_write;
	input [5:0] a;
	input [7:0] v;
	begin
		case (a)
			6'h00: wr_tcl <= v;
			6'h01: wr_tch <= v;
			6'h02: fifo_push(v);
			6'h03: begin
				// RESET and BUSRESET execute immediately.  Every other command
				// occupies the top rank while the bottom rank is in progress.
				if (v[6:0] == 7'h02 || v[6:0] == 7'h03)
					start_command(v);
				else if (cmd_inprogress) begin
					command1 <= v;
					if (cmd_waiting) status[6] <= 1'b1;
					cmd_waiting <= 1;
				end
				else begin
					command1 <= 0;
					cmd_waiting <= 0;
					start_command(v);
				end
			end
			6'h04: selectbusid <= v;
			6'h05: selecttimeout <= v;
			6'h06: syncperiod <= v;
			6'h07: syncoffset <= v;
			6'h08: configuration <= v;
			6'h09: clockconv <= v;
			6'h0A: ;                     // test register
			6'h20: begin
				dma_control <= v;
				if (v[1]) hard_reset;    // ESPCTRL_RESET
				// dma_esp_flush_buffer(): only an enabled device-to-memory
				// channel with room in its window may drain one padded word.
				if (v[2] && d_csr[0] && d_dev2m && d_next < d_limit) begin
					if (dma_flush_count == 0)
						// An IRQ expiring on this edge has already been
						// raised by X_INT_WAIT; do not schedule it again.
						dma_flush_return <= (xst == X_INT_WAIT && dly_us == 0) ? X_IDLE : xst;
					xst <= X_DI_WR;
				end
			end
			6'h21: dma_status <= v;
			default: ;
		endcase
	end
endtask

always @(posedge clk) begin
	dma_completion_event = 0;
	if (reset) begin
		for (sk = 0; sk < N_UNITS; sk = sk + 1) begin
			sense_code[sk] <= SC_NO_ERROR;
			sense_valid[sk] <= 0;
			sense_info[sk] <= 0;
		end
		fifo_clear;
		wr_tcl <= 0; wr_tch <= 0;
		counter <= 0;
		command0 <= 0;
		command1 <= 0;
		cmd_inprogress <= 0;
		cmd_waiting <= 0;
		transfer_reported <= 0;
		status <= 0;
		intstatus <= 0;
		seqstep <= 0;
		syncperiod <= 8'h05;
		syncoffset <= 0;
		configuration <= 0;
		conf2 <= 0;
		clockconv <= 8'h02;
		selectbusid <= 0;
		selecttimeout <= 0;
		dma_control <= 0;
		dma_status <= 0;
		dma_buf_size <= 0;
		dma_buf_limit <= 0;
		mode_dma <= 0;
		phase <= PHASE_DO;
		t_status <= 0; t_message <= 0; t_lun <= 0;
		lba <= 0; blockcounter <= 0;
		d_csr <= 0;
		d_dev2m <= 0;
		dma_flush_count <= 0;
		dma_flush_return <= X_IDLE;
		dma_flush_active <= 0;
		dma_irq_resume <= 0;
		d_next <= 0; d_limit <= 0; d_start <= 0; d_stop <= 0;
		s_next <= 0; s_limit <= 0; s_start <= 0; s_stop <= 0;
		buf_pos <= 0; buf_limit <= 0; buf_disk <= 0;
		fill_idx <= 0;
		win_lba <= 0; win_alloc <= 0; win_len <= 0; win_act <= 0;
		msel <= 0; fwd_ret <= X_IDLE; cd_fwd_stb <= 0;
		xst <= X_IDLE;
		sel_atn <= 0;
		cdb0 <= 0; cdb1 <= 0; cdb2 <= 0; cdb3 <= 0; cdb4 <= 0;
		cdb5 <= 0; cdb6 <= 0; cdb7 <= 0; cdb8 <= 0; cdb9 <= 0;
		cdb_n <= 0;
		sel_stop <= 0; cdb_ti <= 0;
		ti_aux_in <= 0; ti_aux_out <= 0; ti_phase <= PHASE_DO;
		ti_dma_started <= 0;
		mi_held <= 0; msg_resume <= 0;
		msg_len_pending <= 0; msg_reject <= 0; msg_left <= 0;
		rd_ret <= 0; sd_ret <= 0; pad_mode <= 0;
		gap_us <= 0;
		flp_active <= 0;
		cmd_busy <= 0;
		flp_req_d <= 0;
		flp_pend <= 0;
		flp_done <= 0;
		word_cnt <= 0; word_buf <= 0; do_rem <= 0;
		dly_us <= 0;
		sd_lba_r <= 0;
		sd_rd <= 0; sd_wr <= 0;
		sd_read_owned <= 0;
		m_req <= 0; m_we <= 0; m_addr <= 0; m_be <= 0; m_din <= 0;
		eng_we <= 0; eng_addr <= 0; eng_wd <= 0;
		tickcnt <= 0;
	end
	else begin
		tickcnt <= tick ? 1'd0 : tickcnt + 1'd1;
		eng_we <= 0;
		flp_done <= 0;
		cd_fwd_stb <= 0;
		// the response length rides in the block's last two bytes
		if (in_sd_rd && win_act && sd_buff_wr) begin
			if (sd_buff_addr == 9'd510) win_len[15:8] <= sd_buff_dout;
			if (sd_buff_addr == 9'd511) win_len[7:0]  <= sd_buff_dout;
		end
		if (tick && gap_us != 0) gap_us <= gap_us - 1'd1;

		// A FLUSH write is synchronous in Previous, but this memory port can
		// stall for many CPU cycles.  Count each accepted write, including
		// writes arriving while an earlier flush is still outstanding.
		case ({cpu_flush_write, dma_flush_done})
			2'b10: if (dma_flush_count != 4'hF)
				dma_flush_count <= dma_flush_count + 1'd1;
			2'b01: dma_flush_count <= dma_flush_count - 1'd1;
			default: ;
		endcase

		// The floppy holds its request up until it sees the sector
		// completed, so a level test would restart the channel on the
		// buffer it has just handed over.  An edge test is worse: an
		// edge arriving before the channel is switched over, or while
		// the ESP has it, is consumed and never comes again, and the
		// drive waits for a completion that cannot happen.  Latch the
		// request instead and clear it when the sector is taken.
		if (flp_req && !flp_req_d) flp_pend <= 1;
		flp_req_d <= flp_req;
		if (!flp_req) flp_pend <= 0;

		// X_IDLE alone is not the channel being free: a connected SCSI
		// command sits in X_IDLE whenever it waits for the driver to
		// re-arm the channel.  Taking it there overwrote the command's
		// counter, phase and buffer, and the command then resumed and
		// abandoned the floppy transfer with flp_active still set -
		// after which the channel was closed to the floppy for good.
		// Hand over only between commands.
		if (flp_select && flp_pend && !flp_active && !cmd_busy &&
		    (xst == X_IDLE)) begin
			flp_pend <= 0;
			flp_active <= 1;
			buf_pos    <= 0;
			buf_limit  <= flp_len[9:0];
			buf_disk   <= 0;
			word_cnt   <= 0;
			pad_mode   <= 0;
			counter    <= {6'd0, flp_len};
			phase      <= flp_wr ? PHASE_DI : PHASE_DO;
			xst        <= flp_wr ? X_DI_CHK : X_DO_CHK;
		end

		//------------------------------------------------------------
		// execution engine
		//------------------------------------------------------------
		case (xst)
		X_IDLE: ;

		// select: pop the identify message
		X_SEL_MSG: begin
			phase <= PHASE_MO;
			seqstep <= 8'h01;
			if (cpu_fifo_access) ;
			else begin
				if (fifoflags != 0) begin
					t_lun <= fifo_head[2:0];
					fifo_pop;
				end
				else t_lun <= 0;
				if (sel_stop || fifoflags == 0) begin
					intstatus <= INTR_BS | INTR_FC;
					esp_irq(ESP_DELAY_US);
				end
				else xst <= X_SEL_CDB;
			end
		end

		// Selection may supply a partial CDB. Retain it for subsequent TI
		// commands rather than dispatching stale bytes when the FIFO empties.
		X_SEL_CDB: begin
			phase <= PHASE_CD;
			seqstep <= 8'h03;
			if (!sel_atn) t_lun <= 0;
			if (cpu_fifo_access) ;
			else if (fifoflags != 0) begin
				cdb_receive(fifo_head);
				fifo_pop;
			end
			else begin
				intstatus <= INTR_BS | INTR_FC;
				esp_irq(ESP_DELAY_US);
			end
		end

		// SCSI_Emulate_Command()
		X_DISPATCH: begin : dispatch
			reg [15:0] cnt6;
			reg [15:0] cnt10;
			// esp_select() clears the completed select command before
			// reporting its bus-service/function-complete interrupt.
			if (!cdb_ti) begin
				command0 <= 0;
				command1 <= 0;
				cmd_waiting <= 0;
			end
			cnt6  = (cdb4 == 0) ? 16'h0100 : {8'd0, cdb4};
			cnt10 = {cdb7, cdb8};
			// without an identify message the LUN comes from the CDB
			if (!sel_atn) t_lun <= cdb1[7:5];
			t_message <= 8'h00;              // MSG_COMPLETE
			xst <= X_POSTCMD;
			case (cdb0)
				8'h12: begin                 // INQUIRY (lun independent)
					win_lba <= WIN_RESP | {8'd0, 1'b0, t_unit, 20'd0} |
					           ((cmd_lun != 3'd0) ? 32'h0008_0000 : 32'd0) | 32'h1200;
					win_alloc <= {2'd0, cdb4};
					buf_disk <= 0;
					sense_code[t_uidx] <= SC_NO_ERROR;
					sense_valid[t_uidx] <= 0;
					xst <= X_WIN_GO;
				end
				8'h03: begin                 // REQUEST SENSE (lun independent)
					buf_limit <= (cdb4 == 0) ? 10'd4 :
					             (cdb4 > 8'd22) ? 10'd22 : {2'd0, cdb4};
					buf_pos <= 0;
					buf_disk <= 0;
					fill_idx <= 0;
					t_status <= STAT_GOOD;
					phase <= PHASE_DI;
					xst <= X_FILL;
				end
				default: begin
					if (cmd_lun != 3'd0) begin
						t_status <= STAT_CHECK_COND;
						sense_code[t_uidx] <= SC_INVALID_LUN;
						sense_valid[t_uidx] <= 0;
						phase <= PHASE_ST;
					end
					else if (t_ejected && cdb0 != 8'h1A && cdb0 != 8'h1B && cdb0 != 8'h1E) begin
						// no medium: TEST UNIT READY, the reads, the CD
						// audio commands all report NOT READY
						t_status <= STAT_CHECK_COND;
						sense_code[t_uidx] <= SC_NOT_READY;
						sense_valid[t_uidx] <= 0;
						phase <= PHASE_ST;
					end
					else case (cdb0)
						8'h00: begin         // TEST UNIT READY
							t_status <= STAT_GOOD;
							sense_code[t_uidx] <= SC_NO_ERROR;
							sense_valid[t_uidx] <= 0;
							phase <= PHASE_ST;
						end
						8'h25: begin         // READ CAPACITY
							win_lba <= WIN_RESP | {8'd0, 1'b0, t_unit, 20'd0} | 32'h2500;
							win_alloc <= 10'd8;
							buf_disk <= 0;
							sense_code[t_uidx] <= SC_NO_ERROR;
							sense_valid[t_uidx] <= 0;
							xst <= X_WIN_GO;
						end
						8'h08, 8'h28: begin  // READ (6) / READ (10)
							lba <= (cdb0 == 8'h08) ? {11'd0, cdb1[4:0], cdb2, cdb3}
							                       : {cdb2, cdb3, cdb4, cdb5};
							blockcounter <= (cdb0 == 8'h08) ? cnt6 : cnt10;
							buf_disk <= 1;
							buf_pos <= 0;
							buf_limit <= 0;
							t_status <= STAT_GOOD;
							sense_code[t_uidx] <= SC_NO_ERROR;
							sense_valid[t_uidx] <= 0;
							phase <= PHASE_DI;
							read_sector(2'd0);
						end
						8'h0A, 8'h2A: begin  // WRITE (6) / WRITE (10)
							lba <= (cdb0 == 8'h0A) ? {11'd0, cdb1[4:0], cdb2, cdb3}
							                       : {cdb2, cdb3, cdb4, cdb5};
							blockcounter <= (cdb0 == 8'h0A) ? cnt6 : cnt10;
							if (disk_ro || t_is_cd) begin
								t_status <= STAT_CHECK_COND;
								sense_code[t_uidx] <= SC_WRITE_PROTECT;
								sense_valid[t_uidx] <= 0;
								phase <= PHASE_ST;
							end
							else begin
								t_status <= STAT_GOOD;
								sense_code[t_uidx] <= SC_NO_ERROR;
								sense_valid[t_uidx] <= 0;
								buf_disk <= 1;
								buf_pos <= 0;
								if (cdb0 == 8'h2A && cnt10 == 0) begin
									buf_limit <= 0;
									phase <= PHASE_ST;
								end
								else begin
									buf_limit <= 10'd512;
									phase <= PHASE_DO;
								end
							end
						end
						8'h1A: begin         // MODE SENSE
							if (cdb2[7:6] == 2'd1 || cdb2[7:6] == 2'd3) begin
								t_status <= STAT_CHECK_COND;
								sense_code[t_uidx] <= (cdb2[7:6] == 2'd3) ?
								                          SC_SAVE_UNSUPP : SC_INVALID_CDB;
								sense_valid[t_uidx] <= 0;
								phase <= PHASE_ST;
							end
							else begin
								// flags[0] = DBD; an unknown page comes back as length 0
								win_lba <= WIN_RESP | {8'd0, 1'b0, t_unit, 20'd0} |
								           {15'd0, cdb1[3], 16'd0} | 32'h1A00 | {24'd0, cdb2};
								win_alloc <= {2'd0, cdb4};
								buf_disk <= 0;
								sense_code[t_uidx] <= SC_NO_ERROR;
								sense_valid[t_uidx] <= 0;
								xst <= X_WIN_GO;
							end
						end
						8'h43: begin         // READ TOC (CD-ROM only)
							if (!t_is_cd) begin
								t_status <= STAT_CHECK_COND;
								sense_code[t_uidx] <= SC_INVALID_CMD;
								sense_valid[t_uidx] <= 0;
								phase <= PHASE_ST;
							end
							else begin
								// flags[0] = MSF, flags[2:1] = format (MMC byte 2, else byte 9)
								win_lba <= WIN_RESP | {8'd0, 1'b0, t_unit, 20'd0} |
								           {15'd0, cdb1[1], 16'd0} |
								           ((cdb2[2:0] != 3'd0) ? {14'd0, cdb2[1:0], 16'd0}
								                                : {14'd0, cdb9[7:6], 16'd0}) |
								           32'h4300 | {24'd0, cdb6};
								win_alloc <= ({cdb7, cdb8} > 16'd512) ? 10'd512 : {cdb7[1:0], cdb8};
								buf_disk <= 0;
								sense_code[t_uidx] <= SC_NO_ERROR;
								sense_valid[t_uidx] <= 0;
								xst <= X_WIN_GO;
							end
						end
						8'h42: begin         // READ SUB-CHANNEL (CD-ROM only)
							if (!t_is_cd) begin
								t_status <= STAT_CHECK_COND;
								sense_code[t_uidx] <= SC_INVALID_CMD;
								sense_valid[t_uidx] <= 0;
								phase <= PHASE_ST;
							end
							else begin
								// flags[0] = MSF, flags[1] = SubQ; a = the sub-channel format
								win_lba <= WIN_RESP | {8'd0, 1'b0, t_unit, 20'd0} |
								           {14'd0, cdb2[6], cdb1[1], 16'd0} |
								           32'h4200 | {24'd0, cdb3};
								win_alloc <= ({cdb7, cdb8} > 16'd512) ? 10'd512 : {cdb7[1:0], cdb8};
								buf_disk <= 0;
								sense_code[t_uidx] <= SC_NO_ERROR;
								sense_valid[t_uidx] <= 0;
								xst <= X_WIN_GO;
							end
						end
						// CD audio transport: PLAY AUDIO (10/12/MSF/TRACK), PAUSE/RESUME,
						// STOP PLAY, REZERO, SEEK (6/10): the HPS playhead runs them
						8'h45, 8'h47, 8'h48, 8'h4B, 8'h4E, 8'hA5, 8'h01, 8'h0B, 8'h2B: begin
							if (!t_is_cd) begin
								t_status <= STAT_CHECK_COND;
								sense_code[t_uidx] <= SC_INVALID_CMD;
								sense_valid[t_uidx] <= 0;
								phase <= PHASE_ST;
							end
							else begin
								win_lba <= WIN_CMD | {8'd0, 1'b0, t_unit, 20'd0} | {16'd0, cdb0, 8'd0};
								fwd_ret <= X_POSTCMD;
								fill_idx <= 0;
								t_status <= STAT_GOOD;
								sense_code[t_uidx] <= SC_NO_ERROR;
								sense_valid[t_uidx] <= 0;
								phase <= PHASE_ST;
								xst <= X_CMD_FILL;
							end
						end
						8'h15: begin         // MODE SELECT (CD-ROM: the audio ports page)
							if (!t_is_cd) begin
								t_status <= STAT_CHECK_COND;
								sense_code[t_uidx] <= SC_INVALID_CMD;
								sense_valid[t_uidx] <= 0;
								phase <= PHASE_ST;
							end
							else begin
								win_lba <= WIN_CMD | {8'd0, 1'b0, t_unit, 20'd0} | 32'h1500;
								t_status <= STAT_GOOD;
								sense_code[t_uidx] <= SC_NO_ERROR;
								sense_valid[t_uidx] <= 0;
								buf_disk <= 0;
								buf_pos <= 0;
								if (cdb4 == 0) begin
									fwd_ret <= X_POSTCMD;
									fill_idx <= 0;
									phase <= PHASE_ST;
									xst <= X_CMD_FILL;
								end
								else begin
									buf_limit <= {2'd0, cdb4};
									msel <= 1;
									phase <= PHASE_DO;
								end
							end
						end
						8'h07: begin         // REASSIGN BLOCKS: reference no-op
							t_status <= STAT_GOOD;
							sense_code[t_uidx] <= SC_NO_ERROR;
							sense_valid[t_uidx] <= 0;
							phase <= PHASE_ST;
						end
						8'h1B: begin         // START/STOP (ship); the CD-ROM's stops audio
							t_status <= STAT_GOOD;
							sense_code[t_uidx] <= SC_NO_ERROR;
							sense_valid[t_uidx] <= 0;
							phase <= PHASE_ST;
							// LoEj: stop ejects the medium, start loads it again
							if (t_is_cd && cdb4[1]) begin
								eject_tog  <= ~eject_tog;
								eject_unit <= t_unit;
								eject_val  <= !cdb4[0];
							end
							if (t_is_cd) begin
								win_lba <= WIN_CMD | {8'd0, 1'b0, t_unit, 20'd0} | 32'h1B00;
								fwd_ret <= X_POSTCMD;
								fill_idx <= 0;
								xst <= X_CMD_FILL;
							end
						end
						8'h1E: begin         // PREVENT ALLOW MEDIUM REMOVAL: accepted, no lock
							t_status <= STAT_GOOD;
							sense_code[t_uidx] <= SC_NO_ERROR;
							sense_valid[t_uidx] <= 0;
							phase <= PHASE_ST;
						end
						8'h04: begin         // FORMAT DRIVE
							t_status <= STAT_GOOD;
							sense_code[t_uidx] <= SC_NO_ERROR;
							sense_valid[t_uidx] <= 0;
							phase <= PHASE_ST;
						end
						default: begin       // unknown command
							t_status <= STAT_CHECK_COND;
							sense_code[t_uidx] <= SC_INVALID_CMD;
							sense_valid[t_uidx] <= 0;
							phase <= PHASE_ST;
						end
					endcase
				end
			endcase
		end

		// fill the buffer with the sense data
		X_FILL: begin
			if ({1'b0, fill_idx} < buf_limit) begin
				eng_we <= 1;
				eng_addr <= fill_idx;
				eng_wd <= sense_byte(fill_idx[7:0]);
				fill_idx <= fill_idx + 1'd1;
			end
			else begin
				if (buf_limit == 0) phase <= PHASE_ST;
				xst <= X_POSTCMD;
			end
		end

		// fetch a response block from the HPS window into the buffer
		X_WIN_GO: begin
			if (sd_ack) begin
				sd_rd <= 0;
				sd_read_owned <= 1;
				xst <= X_WIN_ACK;
			end
			else if (!sd_hold && !win_act) begin
				sd_rd <= 1;
				win_act <= 1;
				win_len <= 0;
			end
		end

		X_WIN_ACK: begin
			if (!sd_ack) begin
				sd_read_owned <= 0;
				win_act <= 0;
				xst <= X_WIN_DONE;
			end
		end

		// the length landed with the last write strobe of the block
		X_WIN_DONE: begin
			buf_pos <= 0;
			if (win_len == 0) begin
				t_status <= STAT_CHECK_COND;
				sense_code[t_uidx] <= SC_INVALID_CDB;
				sense_valid[t_uidx] <= 0;
				phase <= PHASE_ST;
			end
			else begin
				t_status <= STAT_GOOD;
				phase <= (win_alloc == 0) ? PHASE_ST : PHASE_DI;
				buf_limit <= ({6'd0, win_alloc} < win_len) ? win_alloc :
				             (win_len > 16'd512) ? 10'd512 : win_len[9:0];
			end
			xst <= X_POSTCMD;
		end

		// forward a command: the CDB into bytes 496.., then the block write
		X_CMD_FILL: begin
			if (fill_idx < 9'd10) begin
				eng_we <= 1;
				eng_addr <= 9'd496 + fill_idx;
				eng_wd <= cdb_byte(fill_idx[3:0]);
				fill_idx <= fill_idx + 1'd1;
			end
			else xst <= X_CMD_GO;
		end

		X_CMD_GO: begin
			if (sd_ack) begin
				sd_wr <= 0;
				xst <= X_CMD_ACK;
			end
			else if (!sd_hold && !win_act) begin
				sd_wr <= 1;
				win_act <= 1;
			end
		end

		X_CMD_ACK: begin
			if (!sd_ack) begin
				win_act <= 0;
				cd_fwd_stb <= 1;
				xst <= fwd_ret;
			end
		end

		// select done: function complete plus bus service
		X_POSTCMD: begin
			if (!cdb_ti) seqstep <= 8'h04;
			intstatus <= cdb_ti ? INTR_BS : INTR_BS | INTR_FC;
			dly_us <= ESP_DELAY_US;
			xst <= X_INT_WAIT;
		end

		X_INT_WAIT: begin
			if (dly_us == 0) begin
				status[7] <= 1'b1;
				if (command0[6:0] == 7'h10 || command0[6:0] == 7'h18)
					transfer_reported <= 1;
				xst <= (dma_irq_resume == 2'd1) ? X_DI_CHK :
				       (dma_irq_resume == 2'd2) ? X_DO_CHK : X_IDLE;
			end
			else if (tick) dly_us <= dly_us - 1'd1;
		end

		// scsi_read_sector()
		X_RD_SECT: begin
			if (blockcounter == 0) begin
				phase <= PHASE_ST;
				xst <= (rd_ret == 2'd1 || rd_ret == 2'd3) ?
				       (dma_control[4] ? X_DI_CHK : X_FDI_CHK) :
				       (rd_ret == 2'd2) ? X_PIO_RD :
				       X_POSTCMD;
			end
			else if (lba < img_blocks) begin
				sd_lba_r <= lba;
				sd_ret <= 0;
				xst <= X_SD_RD_GO;
			end
			else begin
				t_status <= STAT_CHECK_COND;
				sense_code[t_uidx] <= SC_INVALID_LBA;
				sense_valid[t_uidx] <= 1;
				sense_info[t_uidx] <= lba;
				phase <= PHASE_ST;
				xst <= (rd_ret == 2'd1 || rd_ret == 2'd3) ?
				       (dma_control[4] ? X_DI_CHK : X_FDI_CHK) :
				       (rd_ret == 2'd2) ? X_PIO_RD :
				       X_POSTCMD;
			end
		end

		X_SD_RD_GO: begin
			sd_rd <= 1;
			if (sd_ack) begin
				sd_rd <= 0;
				sd_read_owned <= 1;
				xst <= X_SD_RD_ACK;
			end
		end

		X_SD_RD_ACK: begin
			if (!sd_ack) begin
				sd_read_owned <= 0;
				buf_pos <= 0;
				buf_limit <= 10'd512;
				t_status <= STAT_GOOD;
				sense_code[t_uidx] <= SC_NO_ERROR;
				sense_valid[t_uidx] <= 0;
				lba <= lba + 1'd1;
				blockcounter <= blockcounter - 1'd1;
				xst <= (rd_ret == 2'd1 || rd_ret == 2'd3) ?
				       (dma_control[4] ? X_DI_CHK : X_FDI_CHK) :
				       (rd_ret == 2'd2) ? X_PIO_RD :
				       X_POSTCMD;
			end
		end

		// scsi_write_sector()
		X_WR_SECT: begin
			if (lba < img_blocks) begin
				sd_lba_r <= lba;
				xst <= X_SD_WR_GO;
			end
			else begin
				t_status <= STAT_CHECK_COND;
				sense_code[t_uidx] <= SC_INVALID_LBA;
				sense_valid[t_uidx] <= 1;
				sense_info[t_uidx] <= lba;
				phase <= PHASE_ST;
				xst <= (!mode_dma || !dma_control[4] || fifoflags != 0) ? X_FDO : X_DO_CHK;
			end
		end

		X_SD_WR_GO: begin
			sd_wr <= 1;
			if (sd_ack) begin
				sd_wr <= 0;
				xst <= X_SD_WR_ACK;
			end
		end

		X_SD_WR_ACK: begin
			if (!sd_ack) begin
				buf_pos <= 0;
				t_status <= STAT_GOOD;
				sense_code[t_uidx] <= SC_NO_ERROR;
				sense_valid[t_uidx] <= 0;
				lba <= lba + 1'd1;
				blockcounter <= blockcounter - 1'd1;
				if (blockcounter == 16'd1) phase <= PHASE_ST;
				// The controller FIFO always precedes external-DMA residual
				// bytes, and MODE_DMA is sampled live at every I/O event.
				xst <= (!mode_dma || !dma_control[4] || fifoflags != 0) ? X_FDO : X_DO_PUT;
			end
		end

		//------------------------------------------------------------
		// transfer info, data in (disk to memory)
		//------------------------------------------------------------
		X_DI_CHK: begin
			if (ti_aux_in) xst <= X_TI_IN;
			else if (!flp_active && transfer_reported) begin
				// A completed TI may still own a full DMA buffer. Drain it
				// when the channel is rearmed; partial words await FLUSH.
				// MODE_DMA off must not reroute this retired command into
				// X_FDI_CHK and schedule its completion a second time.
				if (dma_control[4] && dma_buf_limit == 16 && d_csr[0] && gap_us == 0) begin
					dma_status_toggle;
					xst <= X_DI_WR;
				end
				else if (dma_buf_size == 0) begin
					dma_irq_resume <= 0;
					xst <= X_IDLE;
				end
			end
			else if (pad_mode) begin
				if (counter == 0) begin
					intstatus <= INTR_BS;
					status[4] <= 1'b1;
					esp_irq(ESP_DELAY_US);
				end
				else if (phase != PHASE_DI) begin
					intstatus <= INTR_BS;
					esp_irq(ESP_DELAY_US);
				end
				else if (buf_pos >= buf_limit) begin
					if (buf_disk) read_sector(2'd1);
					else phase <= PHASE_ST;
				end
				else begin
					eng_addr <= buf_pos[8:0];
					xst <= X_DI_RD;
				end
			end
			// A floppy sector ends only after its last internal-buffer word
			// has reached memory.
			else if (flp_active && (buf_pos >= buf_limit) &&
			         (dma_buf_size == 0)) begin
				if (d_csr[0] && d_next == d_limit) dma_hit_limit;
				flp_active <= 0;
				flp_done   <= 1;
				xst        <= X_IDLE;
			end
			// MODE_DMA is a live route in esp_dma_write_memory().  A switch
			// away from memory DMA retains any channel-buffer residual and
			// resumes producing target bytes through the controller FIFO.
			else if (!flp_active && !dma_control[4]) xst <= X_FDI_CHK;
			// A complete internal buffer changes hands before any channel-limit
			// decision.  This is the next<=limit read-ahead case in dma.c.
			else if (dma_buf_limit == 5'd16) begin
				if (d_csr[0] && gap_us == 0) begin
					dma_status_toggle;
					xst <= X_DI_WR;
				end
			end
			// After esp_transfer_done, a partial buffer waits for explicit
			// ESPCTRL_FLUSH; a retained full buffer was handled above.
			else if (dma_irq_resume == 2'd1) begin
				if (dma_buf_size == 0) begin
					dma_irq_resume <= 0;
					xst <= X_IDLE;
				end
			end
			else if (!d_csr[0] || gap_us != 0) ;
			// ESP_Send_Data() drains bytes already queued in the ESP FIFO
			// before requesting more from the target.  Those bytes consumed
			// the ESP counter when they were queued, so do not count them twice.
			else if (!flp_active && fifoflags != 0) begin
				if (!cpu_fifo_access) begin
					dma_buf[dma_buf_limit[3:0]] <= fifo_head;
					dma_buf_limit <= dma_buf_limit + 1'd1;
					dma_buf_size <= dma_buf_size + 1'd1;
					fifo_pop;
				end
			end
			// esp_transfer_done(): counter end first, then phase change.
			else if (!flp_active && (counter == 0 || phase != PHASE_DI)) begin
				intstatus <= INTR_BS;
				if (counter == 0) status[4] <= 1'b1;
				if (d_next == d_limit) dma_hit_limit;
				dma_irq_resume <= (dma_buf_size != 0) ? 2'd1 : 2'd0;
				esp_irq(ESP_DELAY_US);
			end
			else if (buf_pos >= buf_limit) begin
				if (buf_disk) read_sector(2'd1);
				else if (flp_active) begin
					flp_active <= 0;
					flp_done <= 1;
					xst <= X_IDLE;
				end
				else phase <= PHASE_ST;
			end
			else begin
				eng_addr <= buf_pos[8:0];
				xst <= X_DI_RD;
			end
		end

		X_DI_RD: xst <= X_DI_GET;        // buffer read settles

		X_DI_GET: begin
			buf_pos <= buf_pos + 1'd1;
			counter <= counter - 1'd1;
			if (!flp_active && buf_pos + 1'd1 >= buf_limit) begin
				if (!buf_disk || blockcounter == 0) phase <= PHASE_ST;
				else if (lba >= img_blocks) begin
					t_status <= STAT_CHECK_COND;
					sense_code[t_uidx] <= SC_INVALID_LBA;
					sense_valid[t_uidx] <= 1;
					sense_info[t_uidx] <= lba;
					phase <= PHASE_ST;
				end
			end
			if (!pad_mode) begin
				dma_buf[dma_buf_limit[3:0]] <= eng_q;
				dma_buf_limit <= dma_buf_limit + 1'd1;
				dma_buf_size <= dma_buf_size + 1'd1;
			end
			xst <= X_DI_CHK;
		end

		// Empty complete internal buffers to memory.  ESPCTRL_FLUSH shares
		// this state but writes exactly one padded word and then returns.
		X_DI_WR: begin
			if (!m_req) begin
				if (dma_flush_count != 0) begin
					m_req <= 1;
					m_we <= 1;
					m_addr <= d_next[31:2];
					m_be <= 4'hF;
					dma_flush_active <= 1;
					case (dma_buf_size)
						5'd0: m_din <= 32'h00000000;
						5'd1: m_din <= {dma_buf[dma_buf_head[3:0]], 24'h000000};
						5'd2: m_din <= {dma_buf[dma_buf_head[3:0]],
						                    dma_buf[dma_buf_head[3:0] + 1'd1], 16'h0000};
						5'd3: m_din <= {dma_buf[dma_buf_head[3:0]],
						                    dma_buf[dma_buf_head[3:0] + 1'd1],
						                    dma_buf[dma_buf_head[3:0] + 4'd2], 8'h00};
						default: m_din <= {dma_buf[dma_buf_head[3:0]],
						                  dma_buf[dma_buf_head[3:0] + 1'd1],
						                  dma_buf[dma_buf_head[3:0] + 4'd2],
						                  dma_buf[dma_buf_head[3:0] + 4'd3]};
					endcase
				end
				else if (d_csr[0] && gap_us == 0 && d_next < d_limit &&
				         dma_buf_size >= 4) begin
					m_req <= 1;
					m_we <= 1;
					m_addr <= d_next[31:2];
					m_be <= 4'hF;
					dma_flush_active <= 0;
					m_din <= {dma_buf[dma_buf_head[3:0]],
					          dma_buf[dma_buf_head[3:0] + 1'd1],
					          dma_buf[dma_buf_head[3:0] + 4'd2],
					          dma_buf[dma_buf_head[3:0] + 4'd3]};
				end
				else if (d_csr[0] && gap_us == 0 && d_next >= d_limit) begin
					dma_hit_limit;
					if (!ti_aux_in && !flp_active && !transfer_reported &&
					    (counter == 0 || phase != PHASE_DI)) begin
						intstatus <= INTR_BS;
						if (counter == 0) status[4] <= 1'b1;
						dma_irq_resume <= (dma_buf_size != 0) ? 2'd1 : 2'd0;
						esp_irq(ESP_DELAY_US);
					end
					else xst <= X_DI_CHK;
				end
			end
			else if (m_err) begin
				m_req <= 0;
				dma_flush_active <= 0;
				dma_bus_exception;
				dma_flush_count <= 0;
				dma_irq_resume <= 0;
				flp_active <= 0;
				xst <= X_IDLE;
			end
			else if (m_ack) begin
				m_req <= 0;
				dma_flush_active <= 0;
				// A malformed, non-word-aligned limit must not carry next past
				// the value software subtracts to calculate bytes transferred.
				d_next <= (d_next + 32'd4 > d_limit) ? d_limit
				                                      : d_next + 32'd4;
				if (dma_buf_size <= 4) begin
					dma_buf_size <= 0;
					dma_buf_limit <= 0;
				end
				else dma_buf_size <= dma_buf_size - 5'd4;
				if (dma_flush_active) begin
					if (d_next + 32'd4 >= d_limit) begin
						dma_hit_limit;
						// Further queued pumps cannot write this completed
						// window.  A chained window is re-armed by software.
						dma_flush_count <= 0;
						if (dma_irq_resume == 2'd1 && dma_buf_size <= 4)
							dma_irq_resume <= 0;
						xst <= (dma_flush_return == X_INT_WAIT) ? X_INT_WAIT :
						       (dma_irq_resume == 2'd1) ? X_IDLE
						                                     : dma_flush_return;
					end
					else if (dma_irq_resume == 2'd1) begin
						if (dma_buf_size <= 4) dma_irq_resume <= 0;
						// FLUSH can arrive after TC but before the delayed
						// interrupt. Retire the bytes without losing that IRQ.
						xst <= (dma_flush_count > 1) ? X_DI_WR :
						       (dma_flush_return == X_INT_WAIT) ? X_INT_WAIT : X_IDLE;
					end
					else xst <= (dma_flush_count > 1) ? X_DI_WR
					                                      : dma_flush_return;
				end
				else if (dma_irq_resume == 2'd1 && dma_buf_size <= 4) begin
					if (d_next + 32'd4 >= d_limit) dma_hit_limit;
					dma_irq_resume <= 0;
					xst <= X_IDLE;
				end
				else xst <= (dma_buf_size > 4) ? X_DI_WR : X_DI_CHK;
			end
		end

		//------------------------------------------------------------
		// transfer info, data out (memory to disk)
		//------------------------------------------------------------
		X_DO_CHK: begin
			if (!flp_active && transfer_reported) xst <= X_IDLE;
			else if (pad_mode) begin
				if (counter == 0) begin
					intstatus <= INTR_BS;
					status[4] <= 1'b1;
					esp_irq(ESP_DELAY_US);
				end
				else if (phase != PHASE_DO) begin
					intstatus <= INTR_BS;
					esp_irq(ESP_DELAY_US);
				end
				else begin
					do_rem <= 3'd1;
					word_buf <= 32'd0;
					xst <= X_DO_PUT;
				end
			end
			else if (flp_active && (buf_pos >= buf_limit) &&
			         dma_buf_size == 0) begin
				if (d_csr[0] && d_next == d_limit) dma_hit_limit;
				flp_active <= 0;
				flp_done   <= 1;
				xst        <= X_IDLE;
			end
			// esp_dma_read_memory() always empties the controller FIFO first.
			// With MODE_DMA clear it then waits there; with the bit set it
			// returns here and continues with the external DMA buffer.
			else if (!flp_active && (fifoflags != 0 || !dma_control[4]))
				xst <= X_FDO;
			else if (dma_irq_resume == 2'd2) ;
			else if (dma_buf_limit == 5'd16) begin
				if (d_csr[0] && gap_us == 0) begin
					dma_status_toggle;
					xst <= X_DO_PUT;
				end
			end
			else if (!flp_active && (counter == 0 || phase != PHASE_DO)) begin
				intstatus <= INTR_BS;
				if (counter == 0) status[4] <= 1'b1;
				if (d_csr[0] && d_next == d_limit) dma_hit_limit;
				dma_irq_resume <= (dma_buf_size != 0) ? 2'd2 : 2'd0;
				esp_irq(ESP_DELAY_US);
			end
			else if (!d_csr[0] || gap_us != 0) ;
			else if (d_next < d_limit) xst <= X_DO_RD;
			else begin
				dma_hit_limit;
				xst <= X_DO_CHK;
			end
		end

		X_DO_RD: begin
			if (!m_req) begin
				if (d_csr[0] && d_next < d_limit && gap_us == 0) begin
					m_req <= 1;
					m_we <= 0;
					m_addr <= d_next[31:2];
					m_be <= 4'hF;
				end
			end
			else if (m_err) begin
				m_req <= 0;
				dma_bus_exception;
				dma_irq_resume <= 0;
				flp_active <= 0;
				xst <= X_IDLE;
			end
			else if (m_ack) begin
				m_req <= 0;
				dma_buf[dma_buf_limit[3:0]] <= m_dout[31:24];
				dma_buf[dma_buf_limit[3:0] + 1'd1] <= m_dout[23:16];
				dma_buf[dma_buf_limit[3:0] + 4'd2] <= m_dout[15:8];
				dma_buf[dma_buf_limit[3:0] + 4'd3] <= m_dout[7:0];
				dma_buf_limit <= dma_buf_limit + 5'd4;
				dma_buf_size <= dma_buf_size + 5'd4;
				d_next <= (d_next + 32'd4 > d_limit) ? d_limit
				                                      : d_next + 32'd4;
				xst <= ti_aux_out ? X_TI_OUT : X_DO_CHK;
			end
		end

		X_DO_PUT: begin
			if (pad_mode) begin
				if (do_rem == 0 || counter == 0 || phase != PHASE_DO)
					xst <= X_DO_CHK;
				else begin
					eng_we <= 1;
					eng_addr <= buf_pos[8:0];
					eng_wd <= word_buf[31:24];
					word_buf <= {word_buf[23:0], 8'h00};
					do_rem <= do_rem - 1'd1;
					buf_pos <= buf_pos + 1'd1;
					counter <= counter - 1'd1;
					if (buf_pos + 1'd1 == buf_limit) begin
						if (buf_disk) xst <= X_WR_SECT;
						else if (msel) begin msel <= 0; fill_idx <= 0; fwd_ret <= X_DO_CHK; phase <= PHASE_ST; xst <= X_CMD_FILL; end
						else begin phase <= PHASE_ST; xst <= X_DO_CHK; end
					end
				end
			end
			else if (dma_buf_size == 0) begin
				dma_buf_limit <= 0;
				xst <= X_DO_CHK;
			end
			else if (!flp_active && (counter == 0 || phase != PHASE_DO)) begin
				intstatus <= INTR_BS;
				if (counter == 0) status[4] <= 1'b1;
				if (d_csr[0] && d_next == d_limit) dma_hit_limit;
				dma_irq_resume <= 2'd2;
				esp_irq(ESP_DELAY_US);
			end
			else begin
				eng_we <= 1;
				eng_addr <= buf_pos[8:0];
				eng_wd <= dma_buf[dma_buf_head[3:0]];
				dma_buf_size <= dma_buf_size - 1'd1;
				if (dma_buf_size == 1) dma_buf_limit <= 0;
				buf_pos <= buf_pos + 1'd1;
				counter <= counter - 1'd1;
				if (buf_pos + 1'd1 == buf_limit) begin
					if (buf_disk) xst <= X_WR_SECT;
					else if (msel) begin msel <= 0; fill_idx <= 0; fwd_ret <= X_DO_CHK; phase <= PHASE_ST; xst <= X_CMD_FILL; end
					else begin
						phase <= PHASE_ST;
						xst <= X_DO_CHK;
					end
				end
			end
		end

		//------------------------------------------------------------
		// DMA-tagged transfer information with ESPCTRL_MODE_DMA clear.
		// The command still owns the transfer counter, but bytes travel
		// through the controller FIFO rather than the memory DMA channel.
		//------------------------------------------------------------
		X_FDI_CHK: begin
			if (transfer_reported || dma_control[4]) xst <= X_DI_CHK;
			else if (gap_us != 0) ;
			else if (counter == 0) begin
				intstatus <= INTR_BS;
				status[4] <= 1'b1;       // STAT_TC
				esp_irq(ESP_DELAY_US);
			end
			else if (phase != PHASE_DI) begin
				intstatus <= INTR_BS;
				esp_irq(ESP_DELAY_US);
			end
			else if (fifoflags == 5'd16) begin
				// The reference retries its I/O event until software makes
				// room.  Holding this state has the same visible contract.
			end
			else if (buf_pos >= buf_limit) begin
				if (buf_disk) read_sector(2'd3);
				else begin
					phase <= PHASE_ST;
					xst <= X_FDI_CHK;
				end
			end
			else begin
				eng_addr <= buf_pos[8:0];
				xst <= X_FDI_WAIT;
			end
		end

		X_FDI_WAIT: xst <= X_FDI_GET;    // registered buffer read settles

		X_FDI_GET: begin
			if (cpu_fifo_access) ;
			else if (fifoflags == 5'd16) xst <= X_FDI_CHK;
			else begin
				fifo_push(eng_q);
				buf_pos <= buf_pos + 1'd1;
				counter <= counter - 1'd1;
				if (buf_pos + 1'd1 >= buf_limit) begin
					if (!buf_disk || blockcounter == 0) phase <= PHASE_ST;
					else if (lba >= img_blocks) begin
						t_status <= STAT_CHECK_COND;
						sense_code[t_uidx] <= SC_INVALID_LBA;
						sense_valid[t_uidx] <= 1;
						sense_info[t_uidx] <= lba;
						phase <= PHASE_ST;
					end
				end
				xst <= X_FDI_CHK;
			end
		end

		X_FDO: begin
			if (cpu_fifo_access) ;
			else if (transfer_reported) xst <= X_IDLE;
			else if (mode_dma && gap_us != 0) ;
			else if (mode_dma && counter == 0) begin
				intstatus <= INTR_BS;
				status[4] <= 1'b1;       // STAT_TC
				esp_irq(ESP_DELAY_US);
			end
			else if (phase != PHASE_DO) begin
				intstatus <= INTR_BS;
				esp_irq(ESP_DELAY_US);
			end
			else if (fifoflags != 0) begin
				eng_we <= 1;
				eng_addr <= buf_pos[8:0];
				eng_wd <= fifo_head;
				fifo_pop;
				buf_pos <= buf_pos + 1'd1;
				if (mode_dma) counter <= counter - 1'd1;
				if (buf_pos + 1'd1 == buf_limit) begin
					if (buf_disk) xst <= X_WR_SECT;
					else if (msel) begin msel <= 0; fill_idx <= 0; fwd_ret <= X_FDO; phase <= PHASE_ST; xst <= X_CMD_FILL; end
					else begin
						phase <= PHASE_ST;
						xst <= X_FDO;
					end
				end
			end
			else if (!mode_dma) begin
				intstatus <= INTR_BS;
				esp_irq(ESP_DELAY_US);
			end
			else if (dma_control[4]) xst <= X_DO_CHK;
		end

		// Command and message output use the same FIFO / memory-DMA
		// sources as data output. Finish only on count/FIFO exhaustion or
		// a real target phase change, preserving any unsent bytes.
		X_TI_OUT: begin
			if (cpu_fifo_access || (mode_dma && gap_us != 0)) ;
			else if (phase != ti_phase || (mode_dma && counter == 0) ||
			         (!mode_dma && fifoflags == 0)) begin
				intstatus <= INTR_BS;
				if (mode_dma && counter == 0) status[4] <= 1;
				if (mode_dma && d_csr[0] && d_next == d_limit) dma_hit_limit;
				ti_aux_out <= 0;
				esp_irq(ESP_DELAY_US);
			end
			else if (ti_out_fifo || (mode_dma && dma_control[4] && d_csr[0] &&
			         dma_buf_limit == 16 && dma_buf_size != 0)) begin
				if (ti_out_fifo) fifo_pop;
				else begin
					if (!ti_dma_started) dma_status_toggle;
					ti_dma_started <= 1;
					dma_buf_size <= dma_buf_size - 1'd1;
					if (dma_buf_size == 1) begin dma_buf_limit <= 0; ti_dma_started <= 0; end
				end
				if (mode_dma) begin
					counter <= counter - 1'd1;
					if (counter == 1) status[4] <= 1;
				end
				if (phase == PHASE_CD) cdb_receive(ti_out_byte);
				else message_receive(ti_out_byte);
			end
			else if (mode_dma && dma_control[4] && d_csr[0]) begin
				if (d_next < d_limit) xst <= X_DO_RD;
				else dma_hit_limit;
			end
		end

		// Status and message bytes also pass through the actual data path.
		// The NeXT DMA buffer may retain a partial word for ESPCTRL_FLUSH,
		// exactly as for short DATA IN transfers. A message byte holds ACK
		// until MESSAGE ACCEPTED; it reports FC, not BS.
		X_TI_IN: begin
			if (cpu_fifo_access || (mode_dma && gap_us != 0)) ;
			else if (mode_dma && dma_control[4] && dma_buf_limit == 16) begin
				if (d_csr[0]) begin dma_status_toggle; xst <= X_DI_WR; end
			end
			else if (mode_dma && dma_control[4] && !d_csr[0]) ;
			else if (mode_dma && dma_control[4] && fifoflags != 0) begin
				dma_buf[dma_buf_limit[3:0]] <= fifo_head;
				dma_buf_limit <= dma_buf_limit + 1'd1;
				dma_buf_size <= dma_buf_size + 1'd1;
				fifo_pop;
			end
			else if (fifoflags == 16 && !(mode_dma && dma_control[4])) ;
			else begin
				if (mode_dma && dma_control[4]) begin
					dma_buf[dma_buf_limit[3:0]] <= (phase == PHASE_ST) ? t_status : t_message;
					dma_buf_limit <= dma_buf_limit + 1'd1;
					dma_buf_size <= dma_buf_size + 1'd1;
					dma_irq_resume <= 1;
				end
				else fifo_push((phase == PHASE_ST) ? t_status : t_message);
				if (mode_dma) begin
					counter <= counter - 1'd1;
					if (counter == 1) status[4] <= 1;
				end
				intstatus <= (phase == PHASE_ST) ? INTR_BS : INTR_FC;
				if (phase == PHASE_MI) mi_held <= 1;
				phase <= PHASE_MI;
				ti_aux_in <= 0;
				esp_irq(ESP_DELAY_US);
			end
		end

		//------------------------------------------------------------
		// initiator command complete: status byte, then message byte
		//------------------------------------------------------------
		X_ICCS1: begin
			if (!cpu_fifo_access) begin
				fifo_push(t_status);
				phase <= PHASE_MI;           // SCSIdisk_Send_Status()
				xst <= X_ICCS2;
			end
		end

		X_ICCS2: begin
			if (!cpu_fifo_access) begin
				fifo_push(t_message);
				mi_held <= 1;
				intstatus <= INTR_FC;
				dly_us <= ESP_DELAY_US;
				xst <= X_INT_WAIT;
			end
		end

		//------------------------------------------------------------
		// PIO transfer info, data in: one byte to the FIFO
		//------------------------------------------------------------
		X_PIO_RD: begin
			if (buf_pos >= buf_limit) begin
				if (buf_disk) read_sector(2'd2);
				else begin
					phase <= PHASE_ST;
					intstatus <= INTR_BS;
					esp_irq(25'd1);
				end
			end
			else begin
				eng_addr <= buf_pos[8:0];
				xst <= X_PIO_WAIT;
			end
		end

		X_PIO_WAIT: xst <= X_PIO_GET;     // registered buffer read settles

		X_PIO_GET: begin
			if (!cpu_fifo_access && fifoflags != 16) begin
				fifo_push(eng_q);
				buf_pos <= buf_pos + 1'd1;
				if (buf_pos + 1'd1 >= buf_limit) begin
					if (!buf_disk || blockcounter == 0) phase <= PHASE_ST;
					else if (lba >= img_blocks) begin
						// SCSIdisk_Send_Data() attempts the next disk read
						// as it returns this last byte, so an end crossing
						// becomes visible before software issues another TI.
						t_status <= STAT_CHECK_COND;
						sense_code[t_uidx] <= SC_INVALID_LBA;
						sense_valid[t_uidx] <= 1;
						sense_info[t_uidx] <= lba;
						phase <= PHASE_ST;
					end
				end
				intstatus <= INTR_BS;
				esp_irq(25'd1);
			end
		end

		default: xst <= X_IDLE;
		endcase

		//------------------------------------------------------------
		// register access (after the engine so that resets win)
		//------------------------------------------------------------
		if (sel_esp) begin
			if (we) begin
				if (be[1]) reg_write(a_even, wdata[15:8]);
				if (be[0]) reg_write(a_odd, wdata[7:0]);
			end
			else begin
				// read side effects
				if ((be[1] && a_even == 6'h02) || (be[0] && a_odd == 6'h02))
					fifo_pop;
				if (((be[1] && a_even == 6'h05) || (be[0] && a_odd == 6'h05)) && status[7]) begin
					intstatus <= 8'h00;
					status <= status & ~(STAT_INT|STAT_VGC|STAT_PE|STAT_GE);
					// Lowering the interrupt finishes the active rank.  If a
					// command is waiting, promote and start the newest queued byte.
					if (cmd_waiting) begin
						command1 <= 0;
						cmd_waiting <= 0;
						start_command(command1);
					end
					else cmd_inprogress <= 0;
				end
			end
		end

		// DMA_CSR_Write is a 32-bit register whose command byte is in the
		// upper 16-bit bus beat.  The 68040 follows that with a zero lower
		// beat at addr+2; treating that second beat as another CSR write
		// cleared DEV2M just before the ROM pumped ESPCTRL_FLUSH.
		if (sel_csr & we & !addr[1]) begin
			d_dev2m <= csr_or[2];
			if (csr_or != 0) begin
				if (csr_or[4]) d_csr <= d_csr & ~8'b00001011; // RESET
				if (csr_or[5]) begin                            // INITBUF
					dma_status <= 0;
					dma_buf_size <= 0;
					dma_buf_limit <= 0;
					dma_flush_count <= 0;
					dma_flush_active <= 0;
					dma_flush_return <= X_IDLE;
					dma_irq_resume <= 0;
				end
				if (csr_or[1]) d_csr[1] <= 1;                 // SETSUPDATE
				if (csr_or[0]) begin                            // SETENABLE
					// Previous rejects a non-longword NEXT or a LIMIT that is
					// not on its 16-byte burst boundary.  Report it through
					// the hardware-visible exception bits instead of allowing
					// a partial/wrapped transfer.
					if (d_next[1:0] != 0 || d_limit[3:0] != 0)
						dma_bus_exception;
					else d_csr[0] <= 1;
				end
				// CLRCOMPLETE acknowledges a running chain conditionally.
				// If the next segment stopped while software prepared its
				// replacement, retain COMPLETE: the driver's post-write CSR
				// check needs it to detect that race and restart the channel.
				// Explicit re-enable may acknowledge a retained completion;
				// a new limit/fault on this edge must remain visible.
				if (csr_or[3] && (d_csr[0] || csr_or[0]) && !dma_completion_event)
					d_csr[3] <= 0;
			end
		end

		if (sel_sptr & we) begin
			case (addr[3:2])
				2'd0: begin if (!addr[1]) begin if (be[1]) s_next[31:24] <= wdata[15:8]; if (be[0]) s_next[23:16] <= wdata[7:0]; end else begin if (be[1]) s_next[15:8] <= wdata[15:8]; if (be[0]) s_next[7:0] <= wdata[7:0]; end end
				2'd1: begin if (!addr[1]) begin if (be[1]) s_limit[31:24] <= wdata[15:8]; if (be[0]) s_limit[23:16] <= wdata[7:0]; end else begin if (be[1]) s_limit[15:8] <= wdata[15:8]; if (be[0]) s_limit[7:0] <= wdata[7:0]; end end
				2'd2: begin if (!addr[1]) begin if (be[1]) s_start[31:24] <= wdata[15:8]; if (be[0]) s_start[23:16] <= wdata[7:0]; end else begin if (be[1]) s_start[15:8] <= wdata[15:8]; if (be[0]) s_start[7:0] <= wdata[7:0]; end end
				2'd3: begin if (!addr[1]) begin if (be[1]) s_stop[31:24] <= wdata[15:8]; if (be[0]) s_stop[23:16] <= wdata[7:0]; end else begin if (be[1]) s_stop[15:8] <= wdata[15:8]; if (be[0]) s_stop[7:0] <= wdata[7:0]; end end
			endcase
		end

		if (sel_ptr & we) begin
			case (addr[3:2])
				2'd0: begin if (!addr[1]) begin if (be[1]) d_next[31:24] <= wdata[15:8]; if (be[0]) d_next[23:16] <= wdata[7:0]; end else begin if (be[1]) d_next[15:8] <= wdata[15:8]; if (be[0]) d_next[7:0] <= wdata[7:0]; end end
				2'd1: begin if (!addr[1]) begin if (be[1]) d_limit[31:24] <= wdata[15:8]; if (be[0]) d_limit[23:16] <= wdata[7:0]; end else begin if (be[1]) d_limit[15:8] <= wdata[15:8]; if (be[0]) d_limit[7:0] <= wdata[7:0]; end end
				2'd2: begin if (!addr[1]) begin if (be[1]) d_start[31:24] <= wdata[15:8]; if (be[0]) d_start[23:16] <= wdata[7:0]; end else begin if (be[1]) d_start[15:8] <= wdata[15:8]; if (be[0]) d_start[7:0] <= wdata[7:0]; end end
				2'd3: begin if (!addr[1]) begin if (be[1]) d_stop[31:24] <= wdata[15:8]; if (be[0]) d_stop[23:16] <= wdata[7:0]; end else begin if (be[1]) d_stop[15:8] <= wdata[15:8]; if (be[0]) d_stop[7:0] <= wdata[7:0]; end end
			endcase
		end
		// DMA_Init_Write: a write to the init register loads next
		if (sel_ini & we) begin
			dma_status <= 0;
			dma_buf_size <= 0;
			dma_buf_limit <= 0;
			dma_flush_count <= 0;
			dma_flush_return <= X_IDLE;
			dma_flush_active <= 0;
			dma_irq_resume <= 0;
			if (!addr[1]) begin if (be[1]) d_next[31:24] <= wdata[15:8]; if (be[0]) d_next[23:16] <= wdata[7:0]; end
			else begin
				if (be[1]) d_next[15:8] <= wdata[15:8];
				if (be[0]) begin
					d_next[7:0] <= wdata[7:0];
					dma_buf_limit <= {1'b0, wdata[3:0]};
				end
			end
		end

		// SCSI_Insert(): sense belongs to the medium in the selected slot,
		// so replacement media must not inherit the previous image's error.
		// Keep these assignments in this process (the sole sense owner), and
		// last so a mount pulse wins over any command completing this cycle.
		for (sk = 0; sk < SCSI_UNITS; sk = sk + 1) begin
			if (img_mounted[sk] && has_unit(sk[2:0])) begin
				sense_code[uidx(sk[2:0])] <= SC_NO_ERROR;
				sense_valid[uidx(sk[2:0])] <= 0;
				sense_info[uidx(sk[2:0])] <= 0;
			end
		end
	end
end

endmodule
