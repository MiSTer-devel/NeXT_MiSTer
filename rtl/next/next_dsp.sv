//============================================================================
//  NeXT DSP56001: the host port, its DMA channel and the system glue around
//  the DSP block vendored from Falcon_MiSTer (rtl/dsp56k, dsp56k_core.sv
//  with MEMMAP 1 and dsp_periph.sv).  Behavioural reference: Previous
//  src/dsp/dsp.c (DSP_HandleHREQ, DSP_HandleDMA, DSP_SetIRQB, DSP_Start),
//  dsp_core.c (the host port), dma.c (CHANNEL_DSP), sysReg.c (the SCR2 DSP
//  bits), bmap.c (the interrupt enables), docs/DSP_INTEGRATION.md.
//
//  Host port, 0x02008000-0x02008007, one byte each: ICR, CVR, ISR, IVR,
//  TRX0 (reads 0; the fourth byte of an unpacked DMA word), TXH/RXH,
//  TXM/RXM, TXL/RXL.  The CPU's 16-bit sub-cycles map on the block's 68030
//  register bus: addr[2:1] and the two byte lanes.
//
//  DMA channel 0x020000d0 (CSR), 0x020040d0-0x020040df (next, limit, start,
//  stop), 0x020042d0 (init).  With ICR HM1:HM0 != 0 the host port is in DMA
//  mode: HREQ is a DMA request, not an interrupt, and the engine moves
//  4 - HM bytes per DSP word (3 = 24-bit, 2, 1) between memory and the
//  TX/RX bytes in address order, TXH first (DSP_HandleDMA); with the SCR2
//  "unpacked" bit a fourth byte goes to / comes from TRX0, so memory holds
//  one 32-bit word per DSP word.  Direction from ICR TREQ (memory -> DSP)
//  or RREQ (DSP -> memory).  At the limit the channel completes
//  (INT_DSP_DMA), chaining from start/stop when SUPDATE is set, and with
//  the SCR2 "block end" bit pulses IRQB into the DSP (dma_interrupt,
//  DSP_SetIRQB).  Memory is reached a byte at a time through the RAM
//  arbiter, like the printer channel.
//
//  SCR2 byte 0: bit 7 releases the DSP's reset and starts it in the mode
//  bits 4:3 give (inverted: mode (~scr2 >> 3) & 3; 0 loads P:$0000-$01FF
//  from external P:$C000, 1 bootstraps through the host port, 2 starts at
//  P:$E000), bit 6 IRQB at the DMA block end, bit 5 unpacked DMA.  Byte 3
//  bit 6 routes HREQ to INT_DSP_L4 (then gated by the BMAP enable) instead
//  of INT_DSP_L3; bit 5 is the external memory enable (non-Turbo: inverted,
//  and the memory is also enabled at the DSP start, SCR2_Write0).
//
//  The SSI (the DSP port / codec link) is left idle: no frame clock, the
//  DSP side waits for one.  The block runs on the system clock (27.5 MHz
//  against the NeXT's 25 MHz DSP clock).
//============================================================================

module next_dsp #(parameter CLK_HZ = 27500000)
(
	input         clk,
	input         reset,           // device reset

	// register access (16-bit sub-cycles of the CPU bus)
	input         sel_host,        // 0x02008000-0x02008007
	input         sel_csr,         // 0x020000d0 DMA CSR
	input         sel_ptr,         // 0x020040d0-0x020040df next/limit/start/stop
	input         sel_ini,         // 0x020042d0 init (writes NEXT)
	input  [15:0] addr,            // low bits of the access
	input         we,
	input   [1:0] be,              // [1] upper byte, [0] lower byte
	input  [15:0] wdata,
	output [15:0] rdata,

	// RAM master port (32-bit, level req / level ack), a byte at a time
	output reg        m_req,
	output reg        m_we,
	output reg [29:0] m_addr,
	output reg  [3:0] m_be,
	output reg [31:0] m_din,
	input      [31:0] m_dout,
	input             m_ack,
	input             m_err,

	// SCR2 (next_scr) and BMAP (next_bmap)
	input         dsp_run,         // SCR2 byte 0 bit 7: reset released, the DSP runs
	input   [1:0] dsp_mode,        // the start mode (SCR2 bits 4:3 inverted)
	input         dsp_blk_end,     // IRQB at the end of a DMA block
	input         dsp_unpacked,    // 32-bit DMA words (a fourth byte through TRX0)
	input         dsp_int_l4,      // HREQ at level 4 (BMAP-gated) instead of level 3
	input         dsp_mem_en,      // external DSP memory enabled
	input         bmap_hreq_en,    // BMAP register 3 bit 29
	input         bmap_txd_en,     // BMAP register 3 bit 28 (the SCI TXD line: not modelled)

	output        int_dsp_l3,      // INT_DSP_L3 level
	output        int_dsp_l4,      // INT_DSP_L4 level
	output        int_dsp_dma      // INT_DSP_DMA level (channel complete)
);

//----------------------------------------------------------------------------
// reset and start mode: the mode bits are sampled while the DSP is held in
// reset and apply at the release (DSP_Start(mode) in SCR2_Write0)
//----------------------------------------------------------------------------
wire       rst = reset | ~dsp_run;
reg  [1:0] mode_r;
always @(posedge clk) if (rst) mode_r <= dsp_mode;

//----------------------------------------------------------------------------
// the DSP block
//----------------------------------------------------------------------------
wire        bus_cs, bus_stb, bus_we, bus_uds, bus_lds;
wire  [2:1] bus_addr;
wire [15:0] bus_din, bus_dout;
wire        bus_ack;
wire        hreq;
wire  [7:0] ivr;
wire  [1:0] dma_mode;
wire        dma_treq;

wire        running, run_start, boot_we;
wire  [9:0] boot_pos;
wire  [8:0] boot_addr;
wire [23:0] boot_data;
wire        perx_rd, perx_wr, pery_rd, pery_wr;
wire  [5:0] perx_addr, pery_addr;
wire [23:0] perx_wdata, perx_rdata, pery_wdata, pery_rdata;
wire        soft_reset, hc_ack;
wire        int_host_rcv, int_host_trx, int_host_cmd, int_ssi_rcv, int_ssi_trx;
wire        msk_host_rcv, msk_host_trx, msk_host_cmd, msk_ssi_rcv, msk_ssi_trx;
wire [23:0] ipr;
wire  [4:0] hc_vector;
reg         irqb;

dsp56k_core #(.MEMMAP(1), .EXT_AW(13)) u_core (
	.clk(clk), .rst(rst),
	.run(running), .run_start(run_start), .boot_pos(boot_pos),
	.boot_mode(mode_r), .ext_en(dsp_mem_en), .irqb(irqb),
	.boot_we(boot_we), .boot_addr(boot_addr), .boot_data(boot_data),
	.perx_rd(perx_rd), .perx_wr(perx_wr), .perx_addr(perx_addr),
	.perx_wdata(perx_wdata), .perx_rdata(perx_rdata),
	.pery_rd(pery_rd), .pery_wr(pery_wr), .pery_addr(pery_addr),
	.pery_wdata(pery_wdata), .pery_rdata(pery_rdata),
	.per_soft_reset(soft_reset),
	.int_host_rcv(int_host_rcv), .int_host_trx(int_host_trx), .int_host_cmd(int_host_cmd),
	.int_ssi_rcv(int_ssi_rcv), .int_ssi_trx(int_ssi_trx),
	.msk_host_rcv(msk_host_rcv), .msk_host_trx(msk_host_trx), .msk_host_cmd(msk_host_cmd),
	.msk_ssi_rcv(msk_ssi_rcv), .msk_ssi_trx(msk_ssi_trx),
	.ipr(ipr), .hc_vector(hc_vector), .hc_ack(hc_ack),
	.retire());

dsp_periph #(.HOST_DMA(1)) u_periph (
	.clk(clk), .rst(rst),
	.bus_cs(bus_cs), .bus_stb(bus_stb), .bus_we(bus_we), .bus_addr(bus_addr),
	.bus_uds(bus_uds), .bus_lds(bus_lds), .bus_din(bus_din), .bus_dout(bus_dout),
	.bus_ack(bus_ack), .hreq(hreq), .ivr(ivr), .dma_mode(dma_mode), .dma_treq(dma_treq),
	.boot_mode(mode_r),
	.running(running), .run_start(run_start), .boot_pos(boot_pos),
	.boot_we(boot_we), .boot_addr(boot_addr), .boot_data(boot_data),
	.perx_rd(perx_rd), .perx_wr(perx_wr), .perx_addr(perx_addr),
	.perx_wdata(perx_wdata), .perx_rdata(perx_rdata),
	.pery_rd(pery_rd), .pery_wr(pery_wr), .pery_addr(pery_addr),
	.pery_wdata(pery_wdata), .pery_rdata(pery_rdata),
	.soft_reset(soft_reset), .hc_ack(hc_ack),
	.int_host_rcv(int_host_rcv), .int_host_trx(int_host_trx), .int_host_cmd(int_host_cmd),
	.int_ssi_rcv(int_ssi_rcv), .int_ssi_trx(int_ssi_trx),
	.msk_host_rcv(msk_host_rcv), .msk_host_trx(msk_host_trx), .msk_host_cmd(msk_host_cmd),
	.msk_ssi_rcv(msk_ssi_rcv), .msk_ssi_trx(msk_ssi_trx),
	.ipr_out(ipr), .hc_vector(hc_vector),
	// the SSI: no slot clock on the NeXT side (the DSP port is not wired)
	.ssi_slot_stb(1'b0), .ssi_tx_en(1'b0), .ssi_frame(1'b0),
	.ssi_rx_en(1'b0), .ssi_rx_frame(1'b0), .ssi_rx_data(16'd0),
	.ssi_tx_data(), .ssi_tx_valid(), .ssi_hs_play_req());

wire unused_ok = &{1'b0, ivr, bus_ack, bmap_txd_en};

//----------------------------------------------------------------------------
// the host port bus: the CPU's sub-cycle has it in its own clock; the DMA
// engine takes any other clock it needs one
//----------------------------------------------------------------------------
reg        eng_cyc, eng_we;
reg  [2:0] eng_addr;
reg  [7:0] eng_byte;
wire       cpu_cyc = sel_host;

assign bus_cs   = cpu_cyc | eng_cyc;
assign bus_stb  = cpu_cyc | eng_cyc;
assign bus_we   = cpu_cyc ? we : eng_we;
assign bus_addr = cpu_cyc ? addr[2:1] : eng_addr[2:1];
assign bus_uds  = cpu_cyc ? be[1] : ~eng_addr[0];
assign bus_lds  = cpu_cyc ? be[0] :  eng_addr[0];
assign bus_din  = cpu_cyc ? wdata : {eng_byte, eng_byte};
wire [7:0] eng_rbyte = eng_addr[0] ? bus_dout[7:0] : bus_dout[15:8];

//----------------------------------------------------------------------------
// DMA channel registers (the NeXT channel shape, as next_printer)
//----------------------------------------------------------------------------
reg  [7:0] d_csr;                     // [0] enable [1] supdate [3] complete [4] busexc
reg        d_dev2m;                   // the CSR's direction bit (DEV2M), informational
reg [31:0] d_next, d_limit, d_start, d_stop;

wire [31:0] ptr_q = (addr[3:2] == 2'd0) ? d_next :
                    (addr[3:2] == 2'd1) ? d_limit :
                    (addr[3:2] == 2'd2) ? d_start : d_stop;

assign rdata = sel_host ? bus_dout :
               sel_csr  ? (addr[1] ? 16'h0000 : {d_csr, 8'h00}) :
               sel_ptr  ? (addr[1] ? ptr_q[15:0] : ptr_q[31:16]) :
               sel_ini  ? (addr[1] ? d_next[15:0] : d_next[31:16]) : 16'h0000;

wire [7:0] csr_or = (be[1] ? wdata[15:8] : 8'h00) | (be[0] ? wdata[7:0] : 8'h00);

assign int_dsp_dma = d_csr[3];

//----------------------------------------------------------------------------
// interrupts: HREQ is an interrupt only outside DMA mode (DSP_HandleHREQ);
// level 4 with the BMAP enable when SCR2 says so, else level 3
//----------------------------------------------------------------------------
wire hreq_int = hreq && (dma_mode == 2'd0);
wire dma_req  = hreq && (dma_mode != 2'd0);
assign int_dsp_l3 = !dsp_int_l4 && hreq_int;
assign int_dsp_l4 =  dsp_int_l4 && hreq_int && bmap_hreq_en;

//----------------------------------------------------------------------------
// the DMA engine: one DSP word at a time, a byte per memory access
//----------------------------------------------------------------------------
localparam E_IDLE = 3'd0, E_MRD = 3'd1, E_MRDA = 3'd2, E_HWR = 3'd3,
           E_HRD = 3'd4, E_MWR = 3'd5, E_MWRA = 3'd6;
reg  [2:0] est;
reg  [2:0] k;                         // byte within the word
wire [2:0] npk = 3'd4 - {1'b0, dma_mode};             // packed bytes per word
wire [2:0] nb  = npk + {2'd0, dsp_unpacked};          // bytes per word in memory
wire [2:0] host_a = (k < npk) ? (3'd0 - npk) + k : 3'd4;   // TXH..TXL, then TRX0
wire       to_dsp = dma_treq;                         // memory -> DSP
wire [3:0] lane_be = 4'b1000 >> d_next[1:0];
wire [7:0] m_byte  = m_dout[31 - 8 * d_next[1:0] -: 8];
wire       last_byte = (k == nb - 3'd1);

task automatic dma_bus_exception;
	begin
		d_csr[0] <= 0;
		d_csr[3] <= 1;
		d_csr[4] <= 1;
		m_req <= 0;
		est <= E_IDLE;
	end
endtask

// one byte moved: advance, and at the limit complete the channel
task automatic dma_advance;
	begin
		d_next <= d_next + 32'd1;
		if (d_next + 32'd1 == d_limit) begin
			d_csr[3] <= 1;                        // COMPLETE
			if (d_csr[1]) begin                   // chaining
				d_next  <= d_start;
				d_limit <= d_stop;
				d_csr[1] <= 0;
			end
			else d_csr[0] <= 0;
			if (dsp_blk_end) irqb <= 1;
			k   <= 0;
			est <= E_IDLE;
		end
		else if (last_byte) begin
			k   <= 0;
			est <= E_IDLE;                        // the next word waits for HREQ again
		end
		else begin
			k   <= k + 3'd1;
			est <= to_dsp ? E_MRD : E_HRD;
		end
	end
endtask

always @(posedge clk) begin
	irqb <= 0;
	if (reset) begin
		d_csr <= 0; d_dev2m <= 0;
		d_next <= 0; d_limit <= 0; d_start <= 0; d_stop <= 0;
		est <= E_IDLE; k <= 0;
		m_req <= 0; m_we <= 0; m_addr <= 0; m_be <= 0; m_din <= 0;
		eng_cyc <= 0; eng_we <= 0; eng_addr <= 0; eng_byte <= 0;
	end
	else begin
		eng_cyc <= 0;

		//----------------------------------------------------------------
		// DMA CSR write (0x020000d0): SETENABLE / SETSUPDATE / RESET /
		// INITBUF / CLRCOMPLETE and the direction bit, as DMA_CSR_Write
		//----------------------------------------------------------------
		if (sel_csr & we & !addr[1]) begin
			d_dev2m <= csr_or[2];
			if (csr_or[4]) d_csr <= d_csr & ~8'b00001011;          // RESET
			if (csr_or[5]) d_csr[3] <= 0;                           // INITBUF
			if (csr_or[1]) d_csr[1] <= 1;                           // SETSUPDATE
			if (csr_or[0]) d_csr[0] <= 1;                           // SETENABLE
			if (csr_or[3]) d_csr[3] <= 0;                           // CLRCOMPLETE
		end

		//----------------------------------------------------------------
		// pointer register writes
		//----------------------------------------------------------------
		if (sel_ptr & we) begin
			case (addr[3:2])
				2'd0: if (!addr[1]) begin if (be[1]) d_next[31:24] <= wdata[15:8]; if (be[0]) d_next[23:16] <= wdata[7:0]; end
				      else begin if (be[1]) d_next[15:8] <= wdata[15:8]; if (be[0]) d_next[7:0] <= wdata[7:0]; end
				2'd1: if (!addr[1]) begin if (be[1]) d_limit[31:24] <= wdata[15:8]; if (be[0]) d_limit[23:16] <= wdata[7:0]; end
				      else begin if (be[1]) d_limit[15:8] <= wdata[15:8]; if (be[0]) d_limit[7:0] <= wdata[7:0]; end
				2'd2: if (!addr[1]) begin if (be[1]) d_start[31:24] <= wdata[15:8]; if (be[0]) d_start[23:16] <= wdata[7:0]; end
				      else begin if (be[1]) d_start[15:8] <= wdata[15:8]; if (be[0]) d_start[7:0] <= wdata[7:0]; end
				default: if (!addr[1]) begin if (be[1]) d_stop[31:24] <= wdata[15:8]; if (be[0]) d_stop[23:16] <= wdata[7:0]; end
				      else begin if (be[1]) d_stop[15:8] <= wdata[15:8]; if (be[0]) d_stop[7:0] <= wdata[7:0]; end
			endcase
		end
		if (sel_ini & we) begin
			if (!addr[1]) begin if (be[1]) d_next[31:24] <= wdata[15:8]; if (be[0]) d_next[23:16] <= wdata[7:0]; end
			else begin if (be[1]) d_next[15:8] <= wdata[15:8]; if (be[0]) d_next[7:0] <= wdata[7:0]; end
		end

		//----------------------------------------------------------------
		// the engine
		//----------------------------------------------------------------
		case (est)
			E_IDLE: begin
				if (d_csr[0] && dma_req && (d_next < d_limit)) begin
					k   <= 0;
					est <= to_dsp ? E_MRD : E_HRD;
				end
			end

			// memory -> DSP: a byte from memory, then into TXH/TXM/TXL (TRX0)
			E_MRD: begin
				m_req  <= 1;
				m_we   <= 0;
				m_be   <= lane_be;
				m_addr <= d_next[31:2];
				est    <= E_MRDA;
			end
			E_MRDA: begin
				if (m_err) dma_bus_exception;
				else if (m_ack) begin
					m_req    <= 0;
					eng_byte <= m_byte;
					est      <= E_HWR;
				end
			end
			E_HWR: begin
				// the host-port write happens in the clock eng_cyc is high;
				// the CPU's own sub-cycle has priority on the port
				if (!cpu_cyc && !eng_cyc) begin
					eng_cyc  <= 1;
					eng_we   <= 1;
					eng_addr <= host_a;
				end
				else if (eng_cyc) dma_advance;
			end

			// DSP -> memory: a byte from RXH/RXM/RXL (TRX0), then into memory
			E_HRD: begin
				if (!cpu_cyc && !eng_cyc) begin
					eng_cyc  <= 1;
					eng_we   <= 0;
					eng_addr <= host_a;
				end
				else if (eng_cyc) begin
					eng_byte <= eng_rbyte;
					est      <= E_MWR;
				end
			end
			E_MWR: begin
				m_req  <= 1;
				m_we   <= 1;
				m_be   <= lane_be;
				m_addr <= d_next[31:2];
				m_din  <= {4{eng_byte}};
				est    <= E_MWRA;
			end
			E_MWRA: begin
				if (m_err) dma_bus_exception;
				else if (m_ack) begin
					m_req <= 0;
					dma_advance;
				end
			end

			default: est <= E_IDLE;
		endcase
	end
end

endmodule
