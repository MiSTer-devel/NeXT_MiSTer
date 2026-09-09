//============================================================================
//  NeXT laser printer interface, modeled on printer.c of the Previous
//  emulator.
//
//  The NeXT 400 dpi laser printer is a "dumb" raster device: the host
//  rasterizes a page and streams the bitmap out through a dedicated DMA
//  channel.  This module presents the two pieces the driver drives:
//
//    - LP CSR at 0x0200F000 (LP_CSR0..3, byte addressed): the DMA-out
//      enable/request/underrun bits, the printer on/off and interface
//      enable bits, and the trailing command byte.  Modeled as a plain
//      register with the read-only request/status bits synthesized.
//
//    - LP data at 0x0200F004, separate from the CSR. There is no
//      attached printer supplying command responses: writes are consumed,
//      reads return zero, and LP_DATA remains clear. The driver's printer
//      probe can therefore time out normally.
//
//    - the printer DMA channel (memory -> device): CSR 0x02000090,
//      pointers 0x02004090-0x0200409C, init 0x02004250-relative 0x04290,
//      the standard NeXT DMA channel.  With DMA-out enabled the channel
//      reads the raster from memory a word at a time and hands it to the
//      printer; there is no physical printer on MiSTer, so the raster is
//      consumed (the print job completes) rather than imaged.
//
//  The channel completes with COMPLETE (INT_PRINTER_DMA) when the buffer
//  is drained, chain-reloading from start/stop when SUPDATE is set, as
//  dma_interrupt(CHANNEL_PRINTER) does.  INT_PRINTER is the printer event
//  line (held clear here: no printer feeds status back).
//============================================================================

module next_printer #(parameter CLK_HZ = 50000000)
(
	input         clk,
	input         reset,

	// register access
	input         sel_lp,          // 0x0200F000-0x0200F00F  LP CSR/data window
	input         sel_csr,         // 0x02000090 DMA CSR
	input         sel_ptr,         // 0x02004090-0x0200409F next/limit/start/stop
	input         sel_ini,         // 0x02004290 init (writes NEXT + buffer offset)
	input  [15:0] addr,            // low bits of the access (addr[3:0] used)
	input         we,
	input   [1:0] be,              // [1] upper byte, [0] lower byte
	input  [15:0] wdata,
	output [15:0] rdata,

	// RAM master port (32-bit, level req / level ack), memory -> device
	output reg        m_req,
	output reg        m_we,
	output reg [29:0] m_addr,
	output reg  [3:0] m_be,
	output reg [31:0] m_din,
	input      [31:0] m_dout,
	input             m_ack,
	input             m_err,

	output        int_printer,     // INT_PRINTER level (printer event)
	output        int_printer_dma  // INT_PRINTER_DMA level (channel complete)
);

//----------------------------------------------------------------------------
// LP control/status register (0x0200F000), four bytes.  Bit layout from
// printer.c: byte 0 DMA out/in, byte 1 printer state, byte 2 transmit
// state / interface enable, byte 3 the appended command byte.
//----------------------------------------------------------------------------
localparam LP_DMA_OUT_EN  = 8'h80, LP_DMA_OUT_REQ = 8'h40, LP_DMA_OUT_UNDR = 8'h20;
localparam LP_ON          = 8'h80, LP_NDI = 8'h40;   // byte 1 controls
localparam LP_EN          = 8'h02, LP_LOOP = 8'h01;  // byte 2 controls

reg  [7:0] lp0, lp1, lp2, lp3;

//----------------------------------------------------------------------------
// Printer DMA channel registers (same shape as the other NeXT channels)
//----------------------------------------------------------------------------
reg  [7:0] d_csr;                     // [0] enable [1] supdate [3] complete [4] busexc
reg [31:0] d_next, d_limit, d_start, d_stop;
reg [31:0] d_snext, d_slimit, d_sstart, d_sstop;   // saved (plain storage)

assign int_printer     = 1'b0;        // no printer feeds an event back
assign int_printer_dma = d_csr[3];    // COMPLETE

//----------------------------------------------------------------------------
// read mux
//----------------------------------------------------------------------------
wire [7:0] lp_byte0 = lp0;
wire [7:0] lp_byte1 = lp1;
wire [7:0] lp_byte2 = lp2;
wire [7:0] lp_byte3 = lp3;

wire [31:0] lp_word = {lp_byte0, lp_byte1, lp_byte2, lp_byte3};
wire [31:0] ptr_q   = (addr[3:2] == 2'd0) ? d_next :
                      (addr[3:2] == 2'd1) ? d_limit :
                      (addr[3:2] == 2'd2) ? d_start : d_stop;

wire lp_csr_selected = sel_lp && (addr[3:2] == 2'd0);

assign rdata = sel_lp  ? (lp_csr_selected ? (addr[1] ? lp_word[15:0] : lp_word[31:16]) : 16'h0000) :
               sel_csr ? (addr[1] ? 16'h0000 : {d_csr, 8'h00}) :
               sel_ptr ? (addr[1] ? ptr_q[15:0] : ptr_q[31:16]) :
               sel_ini ? (addr[1] ? d_next[15:0] : d_next[31:16]) : 16'h0000;

wire [7:0] csr_or = (be[1] ? wdata[15:8] : 8'h00) | (be[0] ? wdata[7:0] : 8'h00);

//----------------------------------------------------------------------------
// engine: while DMA-out is enabled and the channel is armed, read the
// raster a word at a time and consume it, then complete.
//----------------------------------------------------------------------------
localparam E_IDLE = 2'd0, E_RD = 2'd1, E_ACK = 2'd2;
reg  [1:0] est;

wire dma_out = lp0[7];                 // LP_DMA_OUT_EN

task automatic dma_bus_exception;
	begin
		d_csr[0] <= 0;
		d_csr[3] <= 1;
		d_csr[4] <= 1;
		m_req <= 0;
		est <= E_IDLE;
	end
endtask

always @(posedge clk) begin
	if (reset) begin
		lp0 <= 0; lp1 <= 0; lp2 <= 0; lp3 <= 0;
		d_csr <= 0;
		d_next <= 0; d_limit <= 0; d_start <= 0; d_stop <= 0;
		d_snext <= 0; d_slimit <= 0; d_sstart <= 0; d_sstop <= 0;
		est <= E_IDLE;
		m_req <= 0; m_we <= 0; m_addr <= 0; m_be <= 0; m_din <= 0;
	end
	else begin
		//----------------------------------------------------------------
		// LP CSR writes (byte addressed): keep the writable bits, and let
		// a write of the underrun/request bits clear them (write-1-to-clear
		// in printer.c LP_CSR0_Write).
		//----------------------------------------------------------------
		// Decode all four CSR bytes. In particular, RESET command data
		// FFFFFFFF at F004/F006 must not overwrite the CSR: that would
		// set reserved bit 0x0800 and trap Mach's _np_recv at IPL 3.
		if (lp_csr_selected & we) begin
			if (!addr[1]) begin      // bytes 0,1 (0x0200F000/1)
				if (be[1]) begin     // byte 0
					lp0 <= (lp0 & LP_DMA_OUT_REQ) |          // keep req (r/o)
					       (wdata[15:8] & LP_DMA_OUT_EN) |   // enable
					       (lp0 & LP_DMA_OUT_UNDR & ~wdata[15:8]); // w1c underrun
				end
				if (be[0]) lp1 <= wdata[7:0] & (LP_ON | LP_NDI);
			end
			else begin               // bytes 2,3 (0x0200F002/3)
				if (be[1]) lp2 <= wdata[15:8] & (LP_EN | LP_LOOP);
				if (be[0]) lp3 <= wdata[7:0];   // byte 3 (command)
			end
		end

		//----------------------------------------------------------------
		// DMA CSR write (0x02000090): SETENABLE / SETSUPDATE / RESET /
		// INITBUF / CLRCOMPLETE, as DMA_CSR_Write.  A misaligned or short
		// window is a bus exception, matching the other channels.
		//----------------------------------------------------------------
		if (sel_csr & we & !addr[1]) begin
			if (csr_or != 0) begin
				if (csr_or[4]) d_csr <= d_csr & ~8'b00001011;      // RESET
				if (csr_or[5]) begin                                // INITBUF
					d_csr[3] <= 0;
				end
				if (csr_or[1]) d_csr[1] <= 1;                       // SETSUPDATE
				if (csr_or[0]) begin                                // SETENABLE
					if (d_next[1:0] != 0 || d_limit[1:0] != 0)
						dma_bus_exception;
					else d_csr[0] <= 1;
				end
				if (csr_or[3]) d_csr[3] <= 0;                       // CLRCOMPLETE
			end
		end

		//----------------------------------------------------------------
		// pointer register writes
		//----------------------------------------------------------------
		if (sel_ptr & we) begin
			case ({addr[3:2], addr[1]})
				3'b000: if (be[1]) d_next[31:24] <= wdata[15:8];
				3'b001: begin if (be[1]) d_next[15:8] <= wdata[15:8]; if (be[0]) d_next[7:0] <= wdata[7:0]; end
				3'b010: if (be[1]) d_limit[31:24] <= wdata[15:8];
				3'b011: begin if (be[1]) d_limit[15:8] <= wdata[15:8]; if (be[0]) d_limit[7:0] <= wdata[7:0]; end
				default: ;
			endcase
			if (addr[3:2] == 2'd0 && !addr[1] && be[0]) d_next[23:16] <= wdata[7:0];
			if (addr[3:2] == 2'd1 && !addr[1] && be[0]) d_limit[23:16] <= wdata[7:0];
			if (addr[3:2] == 2'd2) begin
				if (!addr[1]) begin if (be[1]) d_start[31:24] <= wdata[15:8]; if (be[0]) d_start[23:16] <= wdata[7:0]; end
				else begin if (be[1]) d_start[15:8] <= wdata[15:8]; if (be[0]) d_start[7:0] <= wdata[7:0]; end
			end
			if (addr[3:2] == 2'd3) begin
				if (!addr[1]) begin if (be[1]) d_stop[31:24] <= wdata[15:8]; if (be[0]) d_stop[23:16] <= wdata[7:0]; end
				else begin if (be[1]) d_stop[15:8] <= wdata[15:8]; if (be[0]) d_stop[7:0] <= wdata[7:0]; end
			end
		end

		// init: writes NEXT (and would set the buffer offset)
		if (sel_ini & we) begin
			if (!addr[1]) begin if (be[1]) d_next[31:24] <= wdata[15:8]; if (be[0]) d_next[23:16] <= wdata[7:0]; end
			else begin if (be[1]) d_next[15:8] <= wdata[15:8]; if (be[0]) d_next[7:0] <= wdata[7:0]; end
		end

		//----------------------------------------------------------------
		// the memory-to-device read engine
		//----------------------------------------------------------------
		case (est)
			E_IDLE: begin
				if (dma_out && d_csr[0] && d_next < d_limit) begin
					lp0[6] <= 1;              // LP_DMA_OUT_REQ while running
					est <= E_RD;
				end
			end

			E_RD: begin
				if (d_next >= d_limit) begin
					// buffer drained: dma_interrupt(CHANNEL_PRINTER)
					d_csr[3] <= 1;            // COMPLETE
					lp0[6] <= 0;
					if (d_csr[1]) begin
						d_next  <= d_start;
						d_limit <= d_stop;
						d_csr[1] <= 0;
					end
					else d_csr[0] <= 0;
					est <= E_IDLE;
				end
				else begin
					m_req  <= 1;
					m_we   <= 0;
					m_be   <= 4'hF;
					m_addr <= d_next[31:2];
					est <= E_ACK;
				end
			end

			E_ACK: if (m_err) begin
				dma_bus_exception;
			end
			else if (m_ack) begin
				m_req <= 0;
				// the raster word m_dout is streamed to the printer (consumed)
				d_next <= (d_next | 32'd3) + 32'd1;   // whole words
				est <= E_RD;
			end

			default: est <= E_IDLE;
		endcase
	end
end

endmodule
