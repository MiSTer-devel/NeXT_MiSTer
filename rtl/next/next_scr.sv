//============================================================================
//  NeXT system control registers and RTC/NVRAM
//
//  SCR1 (read only)          0x0200c000..3
//  Slot ID (read only)       0x0200c800..3
//  SCR2 (read/write)         0x0200d000..3
//
//  Modeled on Previous src/sysReg.c and src/rtcnvram.c.
//
//  SCR1 for a 25MHz NeXTcube 68040 with 100ns memory is 0x00012052
//  (SCR1_CUBE in sysReg.c: dma rev 1, cpu type 2 = NeXTcube, board rev 0,
//  vmem speed 0x40 | mem speed 0x10, cpu speed 2 = 25MHz).
//
//  SCR2 byte 2 implements the bit serial interface to the MC68HC68T1
//  real time clock chip (SCR2_RTDATA 0x04, SCR2_RTCLK 0x02, SCR2_RTCE
//  0x01), following oldrtc_interface_io() in rtcnvram.c: 8 address bits
//  (bit 7 = write, bit 5 = clock regs), then 8 data bits, MSB first,
//  advanced on each falling edge of RTCLK while RTCE is high.  The
//  address auto-increments for burst access (0x9F wraps to 0x00, 0xB2
//  wraps to 0x20).
//
//  NVRAM power-on content is the nvram_default[] image from rtcnvram.c,
//  which carries a valid checksum in bytes 30/31.
//============================================================================

module next_scr #(
	parameter CLK_HZ = 100000000,
	// The physical clock.  CLK_HZ is the virtual rate the CPU
	// calibration is built on, and the machine runs at 56 percent of
	// real time against it; a crystal driven battery clock does not,
	// so the time of day counts real seconds or it loses 26 minutes an
	// hour.  This sets the rate only - nothing seeds it.
	parameter CLK_REAL_HZ = CLK_HZ
)
(
	input         clk,
	input         reset,          // device reset, including a CPU RESET instruction
	input         config_reset,   // external/user reset: apply the OSD boot policy

	// register access
	input         sel,
	input   [1:0] reg_id,        // 0 = SCR1, 1 = SID, 2 = SCR2
	input         addr1,         // addr[1]: word within the register
	input         we,
	input   [1:0] be,            // {even byte, odd byte} lanes
	input  [15:0] wdata,
	output [15:0] rdata,

	// SCR1 value (machine id), default 25MHz Cube 040
	input  [31:0] scr1,


	// boot device menu: 0 = Auto, 1 = Disk, 2 = Floppy, 3 = Network,
	// 4 = ROM Default, 5 = Optical, 6 = CD-ROM probe.  Auto is resolved
	// when config_reset applies it: an HDD on targets 0-2, then a valid
	// floppy, otherwise the ROM's default order.  A CPU-only RESET leaves
	// the battery-backed NVRAM untouched.
	input   [2:0] boot_sel,
	input         floppy_mounted,
	input   [2:0] sd_lower_mounted,   // SCSI disks at targets 0-2, below the CD-ROM

	// the host's clock from hps_io: TIMESTAMP, Unix seconds (UTC) in
	// [31:0], bit 32 toggling on every update.  The time of day is seeded
	// from it once, on the first update after configuration, so the guest
	// sees the real date without any NVRAM persistence; after that the
	// clock free-runs and the guest may set it.  Tie to 0 for no seed.
	// NeXTSTEP reads the chip as UTC (a 12:00 seed prints as 05:00 PDT)
	// and wants the year as two plain BCD digits (0x24 = 2024; it
	// accepts 0xC4 too), which is why the calendar is derived here from
	// the epoch rather than taken from hps_io's local-time RTC bus.  The
	// kernel also only trusts an RTC within a window of the root
	// filesystem's last-write time (two days accepted, one year rejected,
	// measured 2026-09-24), so a fresh image takes the date once from the
	// guest (Preferences or `date`); from the next boot on the seed is
	// accepted.
	input  [32:0] ts_host,

	output        timer_ipl7,    // SCR2 byte 2 bit 7
	output        led,           // SCR2 byte 3 bit 0
	output        rom_overlay,   // SCR2 byte 3 bit 7 (not used by decode)

	// soft interrupt levels (INT_SOFT1/INT_SOFT2), level signals
	output        softint1,
	output        softint2
);

reg [7:0] scr2_0, scr2_1, scr2_2, scr2_3;

assign timer_ipl7 = scr2_2[7];
assign led        = scr2_3[0];
assign rom_overlay= scr2_3[7];
assign softint1   = scr2_0[0];
assign softint2   = scr2_0[1];

//----------------------------------------------------------------------------
// MC68HC68T1 RTC and NVRAM
//----------------------------------------------------------------------------

reg  [7:0] nvram [0:31];
reg  [7:0] rtc_addr;
reg  [4:0] rtc_phase;            // 0..16, matches 'phase' in rtcnvram.c
reg  [7:0] rtc_val;

reg  [7:0] clkctrl;              // reg 0x31
reg  [7:0] intctrl;              // reg 0x32

// time of day, BCD (seeded from ts_host; the date does not roll over at
// midnight, the guest keeps its own calendar once booted)
reg  [7:0] t_sec = 8'h00, t_min = 8'h00, t_hour = 8'h00;
reg  [7:0] t_wday = 8'h01, t_mday = 8'h01, t_month = 8'h01, t_year = 8'h00;

// one second tick
localparam integer SEC_DIV = CLK_REAL_HZ;
reg [$clog2(SEC_DIV)-1:0] sec_presc = 0;
wire sec_tick = (sec_presc == SEC_DIV-1);

function [7:0] bcd_inc;
	input [7:0] v;
	bcd_inc = (v[3:0] == 4'd9) ? {v[7:4] + 4'd1, 4'd0} : {v[7:4], v[3:0] + 4'd1};
endfunction

// clock register read, rtc_get_clock() in rtcnvram.c
function [7:0] clock_get;
	input [7:0] a;
	case (a[6:0])
		7'h20: clock_get = t_sec;
		7'h21: clock_get = t_min;
		7'h22: clock_get = t_hour;
		7'h23: clock_get = t_wday;
		7'h24: clock_get = t_mday;
		7'h25: clock_get = t_month;
		7'h26: clock_get = t_year;
		7'h30: clock_get = 8'h00;      // status
		7'h31: clock_get = clkctrl;
		7'h32: clock_get = intctrl;
		default: clock_get = 8'h00;
	endcase
endfunction

// serial engine state advance happens on SCR2 byte 2 writes below

//----------------------------------------------------------------------------
// register access
//----------------------------------------------------------------------------

wire [15:0] scr1_hi = scr1[31:16];
wire [15:0] scr1_lo = scr1[15:0];

assign rdata = (reg_id == 2'd0) ? (addr1 ? scr1_lo : scr1_hi) :
               (reg_id == 2'd1) ? 16'h0000 :                     // slot ID
               (addr1 ? {scr2_2, scr2_3} : {scr2_0, scr2_1});

wire       scr2_we    = sel && we && (reg_id == 2'd2);
wire [7:0] w_scr2_2   = wdata[15:8];

// falling edge of RTCLK with RTCE high, sampled from the written value as
// in Previous SCR2_Write2 (old RTCLK=1, new RTCLK=0)
wire rtc_step = scr2_we && addr1 && be[1] && w_scr2_2[0] && scr2_2[1] && !w_scr2_2[1];
wire rtc_bit_in = w_scr2_2[2];

wire [4:0] next_phase = rtc_phase + 5'd1;
wire       rtc_is_write = rtc_addr[7];
wire       rtc_is_clock = rtc_addr[5];
wire [7:0] rtc_load = rtc_is_clock ? clock_get(rtc_addr) : nvram[rtc_addr[4:0]];
`ifdef VERILATOR
// +rtctrace: every clock-register access the guest makes
always @(posedge clk) if (rtc_step && next_phase == 5'd16 && rtc_is_write && rtc_is_clock && $test$plusargs("rtctrace"))
	$display("[%0t] RTC: guest WRITES reg %h = %h", $time, rtc_addr, {rtc_val_cur[6:0], rtc_bit_in});
always @(posedge clk) if (rtc_step && next_phase == 5'd9 && !rtc_is_write && rtc_is_clock && $test$plusargs("rtctrace"))
	$display("[%0t] RTC: guest reads reg %h = %h", $time, rtc_addr, rtc_load);
`endif

// output bit for read transfers: bit (16 - phase) of the value
wire [7:0] rtc_val_cur = (next_phase == 5'd9 && !rtc_is_write) ? rtc_load : rtc_val;
wire [3:0] rtc_bit_idx = 5'd16 - next_phase;
wire       rtc_bit_out = rtc_is_write ? rtc_bit_in : rtc_val_cur[rtc_bit_idx[2:0]];
wire [7:0] rtc_wr_byte = {rtc_val_cur[6:0], rtc_bit_in};

integer i;

// 0 = Auto, 1 = Disk, 2 = Floppy, 3 = Network, 4 = ROM Default,
// 5 = Optical, 6 = CD-ROM.  nvram_init() in the reference spells the
// devices sd, fd, en and od, with an empty command for the ROM.  Auto
// prefers a mounted fixed SCSI disk, then a mounted floppy, and otherwise
// leaves the command empty for the ROM's own device order.
//
// A bare "sd" boots the first SCSI disk the ROM finds, which with a
// disk on target 0 and the CD-ROM on target 3 is always the disk.  The
// ROM's qualified form, "sd(unit,lun,part)" in its usage text, numbers
// disks in SCAN ORDER, not by SCSI target: the first disk found is unit
// 0, the next unit 1, and the second field is the LUN.  (Booting
// "sd(0,3,0)" therefore selects the FIRST disk and asks it for LUN 3,
// which a real single-LUN drive - and this model - answers with "LUN
// not supported"; NeXTSTEP itself reports a CD-ROM behind one disk as
// sd(1,0,0).)  So the CD-ROM entry spells "sd(N,0,0)" with N the number
// of SCSI disks mounted below target 3: sd(0,0,0) for a CD-ROM alone,
// sd(1,0,0) beside a disk on target 0, and so on.
wire [1:0] cd_unit = {1'b0, sd_lower_mounted[0]} + {1'b0, sd_lower_mounted[1]} +
                     {1'b0, sd_lower_mounted[2]};
wire       hdd_mounted = |sd_lower_mounted;
wire [2:0] bootdev = (boot_sel == 3'd0)
	                     ? (hdd_mounted    ? 3'd1 :
	                        floppy_mounted ? 3'd2 : 3'd4)
	                     : boot_sel;

// Bytes 18-29 are the monitor's boot command.  Keep their construction
// separate from the rest of NVRAM so applying an OSD choice cannot erase
// guest-owned volume, brightness, network or diagnostic state.
function automatic [7:0] boot_byte;
	input [4:0] a;
	input [2:0] dev;
	input [1:0] cdu;      // CD-ROM scan-order unit, the N of "sd(N,0,0)"
	begin
		case (a)
			5'd18: boot_byte = (dev == 3'd1) ? "s" :
			                 (dev == 3'd2) ? "f" :
			                 (dev == 3'd3) ? "e" :
			                 (dev == 3'd5) ? "o" :
			                 (dev == 3'd6) ? "s" : 8'h00;
			5'd19: boot_byte = (dev == 3'd1) ? "d" :
			                 (dev == 3'd2) ? "d" :
			                 (dev == 3'd3) ? "n" :
			                 (dev == 3'd5) ? "d" :
			                 (dev == 3'd6) ? "d" : 8'h00;
			// CD-ROM: the rest of "sd(N,0,0)", bytes 20-26; N is the digit
			// at byte 21 (0-3), and the LUN at byte 23 is always 0
			5'd20: boot_byte = (dev == 3'd6) ? "(" : 8'h00;
			5'd21: boot_byte = (dev == 3'd6) ? ("0" + {6'd0, cdu}) : 8'h00;
			5'd22: boot_byte = (dev == 3'd6) ? "," : 8'h00;
			5'd23: boot_byte = (dev == 3'd6) ? "0" : 8'h00;
			5'd24: boot_byte = (dev == 3'd6) ? "," : 8'h00;
			5'd25: boot_byte = (dev == 3'd6) ? "0" : 8'h00;
			5'd26: boot_byte = (dev == 3'd6) ? ")" : 8'h00;
			default: boot_byte = 8'h00;
		endcase
	end
endfunction

// Previous's nvram_checksum(): 16-bit one's-complement sum over bytes
// 0-29, complemented.  Computed one 16-bit add per clock over the live
// image after the command bytes have landed (15 clocks plus the fold,
// far inside the ROM's first RTC access); the combinational version was
// fifteen adders for a value written once per reset.
reg         ck_run = 1'b0;
reg   [4:0] ck_k = 5'd0;
reg  [19:0] ck_sum = 20'd0;
wire [16:0] ck_f1  = {1'b0, ck_sum[15:0]} + {13'd0, ck_sum[19:16]};
wire [16:0] ck_f2  = {1'b0, ck_f1[15:0]} + {16'd0, ck_f1[16]};
wire [15:0] ck_out = ~ck_f2[15:0];

// Full defaults exist only at FPGA configuration, just as battery-backed
// storage acquires an initial image only when the core itself starts.
integer init_i;
initial begin
	for (init_i = 0; init_i < 32; init_i = init_i + 1) nvram[init_i] = 8'h00;
	nvram[0]  = 8'h94;
	nvram[1]  = 8'h0F;
	nvram[2]  = 8'h40;
	// POST options: the ROM's own factory default (written at $01000ac8 when
	// it finds an invalid NVRAM): self test on and the DRAM test, without
	// the verbose listing, the extended (SCSI) test and the sound test that
	// Previous's 0x4B enables.  The ROM `p` command can change it for a
	// session.
	nvram[14] = 8'h11;
`ifdef VERILATOR
	// +verbosepot: Previous's 0x4B (verbose, extended, sound test) so the
	// kernel boots in its text panel and its console lines can be read from
	// the framebuffer dump
	if ($test$plusargs("verbosepot")) nvram[14] = 8'h4B;
`endif
	nvram[30] = 8'hE0;
	nvram[31] = 8'hEF;
end

reg boot_init = 1'b1;
reg rtc_seeded = 1'b0;
reg ts_flag = 1'b0;
// epoch -> calendar, one subtraction per clock (about 21,000 clocks for
// 2026, well inside the ROM's first RTC access): days and the weekday,
// then hours, minutes, seconds, then years from 1970 and months
localparam CV_IDLE = 3'd0, CV_DAYS = 3'd1, CV_HOURS = 3'd2, CV_MINS = 3'd3,
           CV_YEARS = 3'd4, CV_MONTHS = 3'd5, CV_DONE = 3'd6;
reg  [2:0] cv_st = CV_IDLE;
reg [31:0] cv_secs = 0;
reg [15:0] cv_days = 0;
reg  [2:0] cv_wday = 0;    // 0 = Sunday
reg  [4:0] cv_hour = 0;
reg  [5:0] cv_min = 0;
reg  [7:0] cv_year = 0;    // years since 1970
reg  [3:0] cv_mon = 0;     // 0 = January
wire [11:0] cv_yfull = 12'd1970 + {4'd0, cv_year};
wire        cv_leap  = (cv_yfull[1:0] == 2'd0) && (cv_yfull != 12'd2100);
wire  [8:0] cv_ylen  = cv_leap ? 9'd366 : 9'd365;
reg   [4:0] cv_mlen;
always @(*) case (cv_mon)
	4'd1: cv_mlen = cv_leap ? 5'd29 : 5'd28;
	4'd3, 4'd5, 4'd8, 4'd10: cv_mlen = 5'd30;
	default: cv_mlen = 5'd31;
endcase
function [7:0] to_bcd;   // 0..99
	input [6:0] v;
	reg [3:0] tens;
	reg [6:0] rest;
	begin
		tens = (v >= 7'd90) ? 4'd9 : (v >= 7'd80) ? 4'd8 : (v >= 7'd70) ? 4'd7 :
		       (v >= 7'd60) ? 4'd6 : (v >= 7'd50) ? 4'd5 : (v >= 7'd40) ? 4'd4 :
		       (v >= 7'd30) ? 4'd3 : (v >= 7'd20) ? 4'd2 : (v >= 7'd10) ? 4'd1 : 4'd0;
		rest = v - {tens, 3'd0} - {2'd0, tens, 1'b0};   // v - tens*10
		to_bcd = {tens, rest[3:0]};
	end
endfunction
wire [7:0] cv_yy = (cv_year >= 8'd130) ? cv_year - 8'd130 :
                   (cv_year >= 8'd30)  ? cv_year - 8'd30  : cv_year + 8'd70;   // (1970+y) mod 100

always @(posedge clk) begin
	//------------------------------------------------------------
	// The NVRAM is battery backed on the real machine: it survives a
	// reset, and dev_reset here carries the CPU's RESET instruction,
	// which both the ROM and the system software execute during
	// start-up.  Apply the external OSD policy only at FPGA power-on or
	// a user/configuration reset.  Preserve bytes 0-17, replace only the
	// command, and checksum the resulting live image.
	//------------------------------------------------------------
	boot_init <= 1'b0;
	if (boot_init || config_reset) begin
		for (i = 18; i < 30; i = i + 1)
			nvram[i] <= boot_byte(i[4:0], bootdev, cd_unit);
		ck_run <= 1'b1;
		ck_k   <= 5'd0;
		ck_sum <= 20'd0;
	end
	else if (ck_run) begin
		if (ck_k < 5'd30) begin
			ck_sum <= ck_sum + {4'd0, nvram[ck_k], nvram[ck_k + 5'd1]};
			ck_k   <= ck_k + 5'd2;
		end
		else begin
			nvram[30] <= ck_out[15:8];
			nvram[31] <= ck_out[7:0];
			ck_run <= 1'b0;
		end
	end

	// The time of day keeps counting across a reset.  dev_reset carries
	// the CPU's RESET instruction, and the ROM's clock test waits up to
	// 1100 milliseconds for the seconds register to change: restarting
	// the prescaler on every RESET stops it ever getting there, which
	// is POST error 91.
	sec_presc <= sec_tick ? 1'd0 : sec_presc + 1'd1;
	if (sec_tick) begin
		if (t_sec == 8'h59) begin
			t_sec <= 0;
			if (t_min == 8'h59) begin
				t_min <= 0;
				t_hour <= (t_hour == 8'h23) ? 8'h00 : bcd_inc(t_hour);
			end
			else t_min <= bcd_inc(t_min);
		end
		else t_sec <= bcd_inc(t_sec);
	end

	// seed the clock from the host once (the first hps_io update)
	ts_flag <= ts_host[32];
	if (!rtc_seeded && cv_st == CV_IDLE && (ts_flag != ts_host[32])) begin
		cv_secs <= ts_host[31:0];
		cv_days <= 0; cv_wday <= 3'd4;   // 1970-01-01 was a Thursday
		cv_hour <= 0; cv_min <= 0; cv_year <= 0; cv_mon <= 0;
		cv_st <= CV_DAYS;
	end
	case (cv_st)
		CV_DAYS:   if (cv_secs >= 32'd86400) begin
				cv_secs <= cv_secs - 32'd86400; cv_days <= cv_days + 1'd1;
				cv_wday <= (cv_wday == 3'd6) ? 3'd0 : cv_wday + 1'd1;
			end else cv_st <= CV_HOURS;
		CV_HOURS:  if (cv_secs >= 32'd3600) begin cv_secs <= cv_secs - 32'd3600; cv_hour <= cv_hour + 1'd1; end
		           else cv_st <= CV_MINS;
		CV_MINS:   if (cv_secs >= 32'd60) begin cv_secs <= cv_secs - 32'd60; cv_min <= cv_min + 1'd1; end
		           else cv_st <= CV_YEARS;
		CV_YEARS:  if (cv_days >= {7'd0, cv_ylen}) begin cv_days <= cv_days - {7'd0, cv_ylen}; cv_year <= cv_year + 1'd1; end
		           else cv_st <= CV_MONTHS;
		CV_MONTHS: if (cv_days >= {11'd0, cv_mlen}) begin cv_days <= cv_days - {11'd0, cv_mlen}; cv_mon <= cv_mon + 1'd1; end
		           else cv_st <= CV_DONE;
		CV_DONE: begin
			rtc_seeded <= 1'b1;
			cv_st <= CV_IDLE;
			t_sec   <= to_bcd({1'b0, cv_secs[5:0]});
			t_min   <= to_bcd({1'b0, cv_min});
			t_hour  <= to_bcd({2'd0, cv_hour});
			t_mday  <= to_bcd({2'd0, cv_days[4:0]} + 7'd1);
			t_month <= to_bcd({3'd0, cv_mon} + 7'd1);
			t_year  <= to_bcd(cv_yy[6:0]);
			t_wday  <= {5'd0, cv_wday} + 8'd1;   // NeXT counts Sunday as 1
`ifdef VERILATOR
			$display("[%0t] RTC: seeded from host epoch %0d -> %02x/%02x/%02x %02x:%02x:%02x wday %0d", $time, ts_host[31:0],
			         to_bcd(cv_yy[6:0]), to_bcd({3'd0, cv_mon} + 7'd1), to_bcd({2'd0, cv_days[4:0]} + 7'd1),
			         to_bcd({2'd0, cv_hour}), to_bcd({1'b0, cv_min}), to_bcd({1'b0, cv_secs[5:0]}), cv_wday + 1);
`endif
		end
		default: ;
	endcase

	if (reset) begin
		scr2_0 <= 8'h00;
		scr2_1 <= 8'h00;
		scr2_2 <= 8'h00;   // non-turbo reset values, SCR_Reset() in sysReg.c
		scr2_3 <= 8'h00;
		rtc_phase <= 0;
		rtc_addr <= 0;
		rtc_val <= 0;
		clkctrl <= 8'h00;
		intctrl <= 8'h00;
	end
	else begin

		// SCR2 writes
		if (scr2_we) begin
			if (!addr1) begin
				if (be[1]) scr2_0 <= wdata[15:8];
				if (be[0]) scr2_1 <= wdata[7:0];
			end
			else begin
				if (be[1]) scr2_2 <= w_scr2_2;
				if (be[0]) scr2_3 <= wdata[7:0];
			end
		end

		// RTC serial interface, oldrtc_interface_io() in rtcnvram.c
		if (scr2_we && addr1 && be[1] && !w_scr2_2[0]) begin
			// RTCE low resets the interface
			rtc_phase <= 0;
			rtc_addr <= 0;
		end
		else if (rtc_step) begin
			if (next_phase <= 5'd8) begin
				rtc_addr <= {rtc_addr[6:0], rtc_bit_in};
				rtc_phase <= next_phase;
			end
			else begin
				if (rtc_is_write) rtc_val <= {rtc_val_cur[6:0], rtc_bit_in};
				else              rtc_val <= rtc_val_cur;

				// reflect the interface data bit in SCR2 byte 2 readback
				scr2_2 <= {w_scr2_2[7:3], rtc_bit_out, w_scr2_2[1:0]};

				if (next_phase == 5'd16) begin
					if (rtc_is_write) begin
						if (rtc_is_clock) begin
							case (rtc_addr[6:0])
								7'h20: t_sec  <= rtc_wr_byte;
								7'h21: t_min  <= rtc_wr_byte;
								7'h22: t_hour <= rtc_wr_byte;
								7'h24: t_mday <= rtc_wr_byte;
								7'h25: t_month<= rtc_wr_byte;
								7'h26: t_year <= rtc_wr_byte;
								7'h31: clkctrl<= rtc_wr_byte;
								7'h32: intctrl<= rtc_wr_byte;
								default: ;
							endcase
						end
						else nvram[rtc_addr[4:0]] <= {rtc_val_cur[6:0], rtc_bit_in};
					end
					// address auto-increment with the wrap rules from
					// oldrtc_interface_io()
					case (rtc_addr)
						8'h9F:   rtc_addr <= 8'h00;
						8'hB2:   rtc_addr <= 8'h20;
						default: rtc_addr <= rtc_addr + 8'd1;
					endcase
					rtc_phase <= 5'd8;
				end
				else rtc_phase <= next_phase;
			end
		end
	end
end

endmodule
