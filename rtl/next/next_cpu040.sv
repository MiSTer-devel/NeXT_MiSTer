//============================================================================
//  next_cpu040: the NeXT side of the AP68040's MC68040 bus
//
//  The core (rtl/ap68040) runs on clk_cpu, two processor clocks per system
//  clock, and drives the real 68040 external bus (MC68040UM section 7):
//  every bus output of its is a flip-flop that changes only on a processor
//  clock edge with bclk_en high, and its inputs are sampled only there.
//  bclk_en is made here so that those edges ARE the system clock's rising
//  edges (clk and clk_cpu come from one PLL, edge aligned), which makes the
//  bus synchronous to this module: the core's pins are read directly at
//  clk edges, and what this module registers at a clk edge the core samples
//  at the next one.  NeXT.sdc declares the two clocks' 2:1 relationship.
//
//  This module is the bus slave:
//
//  - A transfer (TS low for one bus clock) becomes one beat on the b_*
//    port into next_system (the contract of the old 32-bit adapter: b_req
//    level-held, b_ack a one-clock pulse with b_rdata, berr aborts), or
//    four beats for a line transfer (SIZ 11: the core holds the line's
//    address and the slave counts A3:A2 up from the long word it asked
//    for, wrapping inside the line).  Byte lanes follow MC68040UM table
//    7-1.  TA answers each beat one clock after next_system acknowledges
//    it; TEA answers a bus error (an address nothing decodes).  The write
//    data of a line's next beat appears on the bus only after the core
//    has seen the current beat's TA, so a write burst leaves one idle
//    clock before each further beat; a read burst requests the next beat
//    while TA for the previous one is on the bus.
//  - TCI goes with the first TA of every transfer outside main RAM and the
//    ROM: devices, VRAM and the memory-write-function mirrors must not be
//    cached, whatever the MMU says (the ROM runs with translation off,
//    whose default cache mode is cacheable write-through).
//  - An interrupt acknowledge (TT 11, TM = the level) is answered here
//    with TA and AVEC: every NeXT interrupt is autovectored, and nothing
//    in next_system decodes the acknowledge address.  A breakpoint
//    acknowledge (TT 11, TM 0) gets TA; the core then takes the illegal
//    instruction exception, as a 68040 does.
//  - DMA writes into main RAM are snooped the 68040 way, so the core's
//    caches never hold a stale line: next_system reports each
//    acknowledged DMA write (snoop_stb/snoop_addr); this module takes the
//    bus from the core (BG negated, the core finishes its transfer and
//    releases: A no longer driven), runs the write as another master's
//    long-word transfer with SC 10 (invalidate) on the core's snoop
//    inputs, waits for the snooper to release MI, answers it with TA, and
//    gives the bus back.  While a snoop is pending or running snoop_idle
//    is low and next_system grants no DMA transaction, so one snoop is in
//    flight at a time and no DMA write can land before the previous one's
//    invalidation is done.  (The core only snoops transfers while it does
//    not own the bus: with BG held, it owns the bus for good after its
//    first transfer, hence the arbitration.)  DMA reads are not snooped:
//    the kernel pushes dirty lines before handing a buffer to a device.
//============================================================================

module next_cpu040 (
	input             clk,         // the bus clock: next_system's clock
	input             clk_cpu,     // the core's clock: 2 x clk, edge aligned
	input             reset,
	output            bclk_en,     // to the core (clk_cpu domain)

	// the 68040 bus as the core drives it (valid at clk edges)
	input      [31:0] a,
	input             a_oe,        // the core owns the bus
	input      [31:0] d_cpu,       // the core's write data (d_o)
	input             rw_n,
	input       [1:0] siz,
	input       [1:0] tt,
	input       [2:0] tm,
	input             ts_n,
	input             lock_n,      // a locked sequence (TAS, CAS, the MMU's descriptor updates)
	input             mi_n,        // the snooper: memory may answer when high

	// to the core (registered here, sampled by the core at the next edge)
	output     [31:0] d_mem,
	output            ta_n,
	output            tea_n,
	output            tci_n,
	output            tbi_n,
	output            avec_n,
	output            bg_n,

	// the snooped transfers: another master's bus, to the core's snoop inputs
	output     [31:0] sn_a,
	output            sn_ts_n,
	output            sn_rw_n,
	output      [1:0] sn_siz,
	output      [1:0] sn_tt,
	output      [1:0] sn_sc,

	// DMA writes into main RAM, one pulse per acknowledged write
	input             snoop_stb,
	input      [31:0] snoop_addr,
	output            snoop_idle,
	// the core holds a locked read-modify-write (LOCK asserted): next_system
	// grants no DMA transaction, so the RAM word cannot change between the
	// locked read and its write (a TAS/CAS, or the walker's U/M update)
	output            bus_locked,

	// the beat port into next_system
	output            b_req,
	output            b_write,
	output     [31:2] b_addr,
	output      [3:0] b_be,
	output     [31:0] b_wdata,
	input             b_ack,
	input      [31:0] b_rdata,
	input             berr
);

//----------------------------------------------------------------------------
// bclk_en: high in the processor clock cycle that ends on a system clock
// edge.  sys_tog changes on every clk edge; registered twice on clk_cpu it
// is seen one processor clock later (tog_q, changing on the edges between
// system clock edges) and two later (tog_q2, changing on the system clock
// edges), so the two differ exactly in the cycle before a system clock
// edge.  Both clocks come from one PLL, so Quartus times the sys_tog
// capture as a related-clock path.
//----------------------------------------------------------------------------
reg sys_tog = 0;
always @(posedge clk) sys_tog <= ~sys_tog;
reg tog_q = 0, tog_q2 = 0;
always @(posedge clk_cpu) begin
	tog_q  <= sys_tog;
	tog_q2 <= tog_q;
end
assign bclk_en = tog_q ^ tog_q2;

//----------------------------------------------------------------------------
// address attributes
//----------------------------------------------------------------------------
// main RAM (0x04-0x07) and the boot ROM (0x0000, 0x0100) are the only
// cacheable regions; everything else (device space, BMAP, VRAM and the
// memory-write-function mirrors of RAM and VRAM) answers with TCI
function automatic cacheable;
	input [31:0] addr;
	cacheable = (addr[31:26] == 6'b000001) ||
	            (addr[31:17] == 15'h0000) || (addr[31:17] == {8'h01, 7'd0});
endfunction

// byte lanes of a byte, word or long transfer (MC68040UM table 7-1);
// [3] is the byte at address 0 mod 4, D31-D24
function automatic [3:0] lanes;
	input [1:0] s;
	input [1:0] a10;
	case (s)
		2'b01:   lanes = 4'b1000 >> a10;                  // byte
		2'b10:   lanes = a10[1] ? 4'b0011 : 4'b1100;      // word
		default: lanes = 4'b1111;                         // long, line
	endcase
endfunction

//----------------------------------------------------------------------------
// the transfer in progress
//----------------------------------------------------------------------------
localparam X_IDLE = 3'd0, X_ACK = 3'd1, X_BEAT = 3'd2, X_GAP = 3'd3;
reg   [2:0] xst;
reg         active;       // b_req: a beat is requested
reg  [31:0] xa;           // the transfer's address, as the core drives it
reg   [1:0] xsiz;
reg   [2:0] xtm;
reg         xrd;          // a read
reg         xline;        // a line transfer: four beats
reg   [1:0] beat;         // the beat in progress, 0..3
reg         ta_r, tea_r, avec_r, tci_r;
reg  [31:0] dm_r;

wire  [1:0] a32 = xa[3:2] + beat;   // the long word of this beat

assign b_req   = active;
assign b_write = ~xrd;
assign b_addr  = xline ? {xa[31:4], a32} : xa[31:2];
assign b_be    = xline ? 4'b1111 : lanes(xsiz, xa[1:0]);
assign b_wdata = d_cpu;

always @(posedge clk) begin
	ta_r   <= 0;      // one-clock pulses
	tea_r  <= 0;
	avec_r <= 0;
	if (reset) begin
		xst    <= X_IDLE;
		active <= 0;
		beat   <= 0;
		tci_r  <= 0;
		xa     <= 0;
		xsiz   <= 0;
		xtm    <= 0;
		xrd    <= 1;
		xline  <= 0;
		dm_r   <= 0;
	end
	else case (xst)
		X_IDLE: begin
			// TS: the core starts a transfer (its address, size, kind
			// and write data are on the bus from the same edge and hold)
			if (a_oe && !ts_n) begin
				xa    <= a;
				xsiz  <= siz;
				xtm   <= tm;
				xrd   <= rw_n;
				xline <= (siz == 2'b11);
				beat  <= 0;
				tci_r <= !cacheable(a);
				if (tt == 2'b11) xst <= X_ACK;           // interrupt / breakpoint acknowledge
				else begin
					active <= 1;
					xst    <= X_BEAT;
				end
			end
		end

		X_ACK: begin
			// an autovectored interrupt: TA with AVEC; a breakpoint
			// acknowledge (TM 0): TA alone
			ta_r   <= 1;
			avec_r <= (xtm != 3'd0);
			xst    <= X_IDLE;
		end

		X_BEAT: begin
			if (berr) begin
				// nothing decodes the address: the beat is dropped (the
				// request falls, which also ends next_system's berr) and
				// the core sees TEA
				active <= 0;
				tea_r  <= 1;
				xst    <= X_IDLE;
			end
			else if (b_ack) begin
				dm_r <= b_rdata;
				ta_r <= 1;
				if (xline && beat != 2'd3) begin
					beat <= beat + 1'd1;
					if (!xrd) begin
						// the core puts the next beat's data on the bus
						// only after it has seen this TA: one idle clock
						active <= 0;
						xst    <= X_GAP;
					end
					// a read: the next beat is requested at once (b_req
					// stays high with the next address; next_system does
					// not accept during its own acknowledge clock)
				end
				else begin
					active <= 0;
					xst    <= X_IDLE;
				end
			end
		end

		X_GAP: begin
			active <= 1;
			xst    <= X_BEAT;
		end

		default: xst <= X_IDLE;
	endcase
end

//----------------------------------------------------------------------------
// DMA write snoops: take the bus, run the write as another master's
// transfer, give the bus back
//----------------------------------------------------------------------------
localparam A_IDLE = 3'd0, A_WAIT = 3'd1, A_TS = 3'd2, A_MI = 3'd3, A_TA = 3'd4, A_END = 3'd5;
reg   [2:0] ast;
reg         sn_pend;
reg  [31:0] sn_addr;
reg         bg_r;         // BG negated: the core must release the bus
reg         sn_ts_r;      // TS of the snooped transfer, one clock
reg         sn_ta_r;      // its TA, one clock

// (the report's own clock counts too: next_system decides a DMA grant in the
// clock the report arrives, and a second write's report would overwrite the
// address of a snoop still pending)
assign snoop_idle = !snoop_stb && !sn_pend && (ast == A_IDLE);
assign bus_locked = ~lock_n;
assign bg_n    = bg_r;
assign sn_a    = sn_addr;
assign sn_ts_n = ~sn_ts_r;
assign sn_rw_n = 1'b0;    // a write
assign sn_siz  = 2'b00;   // long
assign sn_tt   = 2'b00;   // normal
assign sn_sc   = 2'b10;   // snoop: invalidate the line

always @(posedge clk) begin
	sn_ts_r <= 0;
	sn_ta_r <= 0;
	if (reset) begin
		ast     <= A_IDLE;
		sn_pend <= 0;
		sn_addr <= 0;
		bg_r    <= 0;
	end
	else begin
		if (snoop_stb) begin
			// next_system grants no DMA while a snoop is pending, so this
			// never overwrites one
			sn_pend <= 1;
			sn_addr <= snoop_addr;
		end
		case (ast)
			A_IDLE: if (sn_pend) begin
				bg_r <= 1;
				ast  <= A_WAIT;
			end
			A_WAIT: begin
				// the core finishes the transfer in progress (if any) and
				// releases the bus: it stops driving the address
				if (!a_oe && xst == X_IDLE) ast <= A_TS;
			end
			A_TS: begin
				sn_ts_r <= 1;
				ast     <= A_MI;
			end
			A_MI: begin
				// the snooper looks the line up with MI asserted and
				// releases MI when memory may answer (a transfer it does
				// not snoop releases it at once).  MI is asserted while
				// the snooper idles and the core does not own the bus,
				// so this cannot fall through before the lookup.
				if (mi_n) ast <= A_TA;
			end
			A_TA: begin
				sn_ta_r <= 1;
				ast     <= A_END;
			end
			A_END: begin
				// the snooper has seen TA; the bus goes back to the core
				sn_pend <= 0;
				bg_r    <= 0;
				ast     <= A_IDLE;
			end
			default: ast <= A_IDLE;
		endcase
	end
end

//----------------------------------------------------------------------------
// to the core
//----------------------------------------------------------------------------
assign d_mem  = dm_r;
assign ta_n   = ~(ta_r | sn_ta_r);
assign tea_n  = ~tea_r;
assign tci_n  = ~tci_r;
assign tbi_n  = 1'b1;     // every target takes a line as four beats
assign avec_n = ~avec_r;

endmodule
