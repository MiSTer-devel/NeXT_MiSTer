//============================================================================
//  DSP56001 test: drives the real next_dsp (the vendored Falcon block with
//  the NeXT memory map, host DMA and start modes) the way the kernel's
//  driver and the ROM do, through the 16-bit sub-cycle register bus and a
//  RAM model on its DMA master port.
//
//    1  reset values of the host port (ICR, CVR, ISR, IVR) while the DSP is
//       held in reset by SCR2, and that they survive the release
//    2  start mode 1: the 512-word bootstrap through TXH/TXM/TXL, then data
//       exchange in PIO (TXDE/RXDF) with the echo program (each word comes
//       back + 1), HREQ as INT_DSP_L3, and as INT_DSP_L4 through the BMAP
//       enable when SCR2 selects level 4
//    3  DMA, memory -> DSP, 24-bit words (ICR HM = 01, TREQ): two words from
//       RAM reach the DSP (the first comes back + 1), the channel completes
//       (COMPLETE, INT_DSP_DMA) and IRQB reaches the DSP program's handler
//       at P:$0004 (SCR2 block end)
//    4  DMA, DSP -> memory (RREQ): the two echoed words land in RAM
//    5  the same two transfers in the SCR2 "unpacked" mode: four bytes per
//       word in memory, the fourth (TRX0) ignored on the way in and 0 on the
//       way out
//    6  start mode 2: the program at external P:$E000 runs at the release
//    7  start mode 0: P:$C000-$C1FF is copied into P:$0000 and run
//    8  the external memory enable: with it clear the DSP reads zeros
//
//  DSP programs are hand-assembled (opcodes from Hatari's dsp_cpu.c, the
//  encoder of Falcon_MiSTer tb/dsp/tb_gen.h); the echo program is the one
//  the Falcon's host-port test uses.
//============================================================================

`timescale 1ns/1ps

module tb_next_dsp;

reg clk = 0;
always #5 clk = ~clk;

reg reset = 1;

reg         sel_host = 0, sel_csr = 0, sel_ptr = 0, sel_ini = 0;
reg  [15:0] addr = 0;
reg         we = 0;
reg   [1:0] be = 0;
reg  [15:0] wdata = 0;
wire [15:0] rdata;

wire        m_req, m_we, m_ack;
wire [29:0] m_addr;
wire  [3:0] m_be;
wire [31:0] m_din;
reg  [31:0] m_dout;
wire        m_addr_valid = (m_addr[29:24] == 6'd1);   // 0x04000000..0x07ffffff
wire        m_err = m_req && !m_addr_valid;

reg         dsp_run = 0;
reg   [1:0] dsp_mode = 2'd1;
reg         dsp_blk_end = 0, dsp_unpacked = 0, dsp_int_l4 = 0, dsp_mem_en = 1;
reg         bmap_hreq_en = 0, bmap_txd_en = 0;
wire        int_dsp_l3, int_dsp_l4, int_dsp_dma;

next_dsp #(.CLK_HZ(27500000)) dut
(
	.clk(clk), .reset(reset),
	.sel_host(sel_host), .sel_csr(sel_csr), .sel_ptr(sel_ptr), .sel_ini(sel_ini),
	.addr(addr), .we(we), .be(be), .wdata(wdata), .rdata(rdata),
	.m_req(m_req), .m_we(m_we), .m_addr(m_addr), .m_be(m_be),
	.m_din(m_din), .m_dout(m_dout), .m_ack(m_ack), .m_err(m_err),
	.dsp_run(dsp_run), .dsp_mode(dsp_mode), .dsp_blk_end(dsp_blk_end),
	.dsp_unpacked(dsp_unpacked), .dsp_int_l4(dsp_int_l4), .dsp_mem_en(dsp_mem_en),
	.bmap_hreq_en(bmap_hreq_en), .bmap_txd_en(bmap_txd_en),
	.int_dsp_l3(int_dsp_l3), .int_dsp_l4(int_dsp_l4), .int_dsp_dma(int_dsp_dma)
);

//----------------------------------------------------------------------------
// RAM model: 4 KB at 0x04000000, byte enables, one wait state
//----------------------------------------------------------------------------
reg [7:0] ram [0:4095];
reg       ack_r = 0;
assign m_ack = ack_r;
wire [11:0] m_off = {m_addr[9:0], 2'b00};
always @(posedge clk) begin
	if (reset) ack_r <= 0;
	else if (!m_req || !m_addr_valid) ack_r <= 0;
	else if (!ack_r) begin
		if (m_we && $test$plusargs("trace")) $display("[%0t] RAM WR m_addr=%08x m_off=%03x be=%b din=%08x", $time, m_addr, m_off, m_be, m_din);
		if (m_we) begin
			if (m_be[3]) ram[m_off + 0] <= m_din[31:24];
			if (m_be[2]) ram[m_off + 1] <= m_din[23:16];
			if (m_be[1]) ram[m_off + 2] <= m_din[15:8];
			if (m_be[0]) ram[m_off + 3] <= m_din[7:0];
		end
		m_dout <= {ram[m_off], ram[m_off + 1], ram[m_off + 2], ram[m_off + 3]};
		ack_r <= 1;
	end
	else ack_r <= 0;
end

//----------------------------------------------------------------------------
// bus helpers: one host-port byte per sub-cycle (as the CPU's byte access),
// the read data taken before the edge that applies the access
//----------------------------------------------------------------------------
task host_wr;
	input [2:0] a;
	input [7:0] d;
	begin
		@(posedge clk);
		sel_host <= 1; we <= 1; addr <= {13'd0, a[2:1], 1'b0};
		be <= a[0] ? 2'b01 : 2'b10; wdata <= {d, d};
		@(posedge clk);
		sel_host <= 0; we <= 0;
	end
endtask

task host_rd;
	input [2:0] a;
	output [7:0] d;
	begin
		@(posedge clk);
		sel_host <= 1; we <= 0; addr <= {13'd0, a[2:1], 1'b0};
		be <= a[0] ? 2'b01 : 2'b10;
		@(negedge clk);
		d = a[0] ? rdata[7:0] : rdata[15:8];
		@(posedge clk);
		sel_host <= 0;
	end
endtask

// a 24-bit word out through TXH, TXM, TXL and in through RXH, RXM, RXL
task host_tx;
	input [23:0] w;
	begin
		host_wr(3'd5, w[23:16]); host_wr(3'd6, w[15:8]); host_wr(3'd7, w[7:0]);
	end
endtask
task host_rx;
	output [23:0] w;
	reg [7:0] h, m, l;
	begin
		host_rd(3'd5, h); host_rd(3'd6, m); host_rd(3'd7, l);
		w = {h, m, l};
	end
endtask

task wait_isr;        // wait for an ISR bit, with a timeout
	input [2:0] bnum;
	output ok;
	reg [7:0] v;
	integer n;
	begin
		ok = 0;
		for (n = 0; n < 2000 && !ok; n = n + 1) begin
			host_rd(3'd2, v);
			if (v[bnum]) ok = 1;
		end
	end
endtask

task ptr_wr32;
	input [3:0] a;
	input [31:0] v;
	begin
		@(posedge clk);
		sel_ptr <= 1; addr <= {12'd0, a}; we <= 1; be <= 2'b11; wdata <= v[31:16];
		@(posedge clk);
		addr <= {12'd0, a + 4'd2}; wdata <= v[15:0];
		@(posedge clk);
		sel_ptr <= 0; we <= 0;
	end
endtask

task csr_cmd;         // the command byte (bits 23:16 of the long) and the direction bit 18
	input [7:0] v;
	begin
		@(posedge clk);
		sel_csr <= 1; addr <= 16'h0; we <= 1; be <= 2'b11; wdata <= {8'h00, v};
		@(posedge clk);
		addr <= 16'h2; wdata <= 16'h0000;
		@(posedge clk);
		sel_csr <= 0; we <= 0;
	end
endtask

task csr_rd;
	output [7:0] v;
	begin
		@(posedge clk);
		sel_csr <= 1; addr <= 16'h0; we <= 0;
		@(negedge clk);
		v = rdata[15:8];
		@(posedge clk);
		sel_csr <= 0;
	end
endtask

// +trace: the DMA engine's state transitions
reg [2:0] est_q = 0;
always @(posedge clk) if ($test$plusargs("trace")) begin
	est_q <= dut.est;
	if (dut.est != est_q)
		$display("[%0t] ENG est=%0d k=%0d next=%08x limit=%08x hreq=%b dma_mode=%0d treq=%b isr=%02x icr=%02x csr=%02x cpu_cyc=%b", $time,
		         dut.est, dut.k, dut.d_next, dut.d_limit, dut.hreq, dut.dma_mode, dut.dma_treq, dut.u_periph.isr, dut.u_periph.icr, dut.d_csr, dut.cpu_cyc);
end

integer errors = 0;
task check;
	input cond;
	input [639:0] name;
	begin
		if (cond) $display("PASS: %0s", name);
		else begin $display("FAIL: %0s", name); errors = errors + 1; end
	end
endtask

task dsp_reset;       // SCR2: hold the DSP in reset, set the mode, release
	input [1:0] mode;
	begin
		@(posedge clk); dsp_run <= 0; dsp_mode <= mode;
		repeat (4) @(posedge clk);
		dsp_run <= 1;
		repeat (4) @(posedge clk);
	end
endtask

//----------------------------------------------------------------------------
// the echo program: X0 = 1; L1: jclr #0,x:$ffe9,L1; movep x:$ffeb,a;
// add x0,a; L2: jclr #1,x:$ffe9,L2; movep a,x:$ffeb; jmp L1
// with IPR = $18 first (IRQB at level 3), the handler at P:$0040 counting in
// X:$0010 (move x:$10,b; add x0,b; move b,x:$10; rti), vector P:$0004 jsr $40
//----------------------------------------------------------------------------
reg [23:0] prog [0:511];
integer i;
task load_echo_program;      // into prog[]: mode 1 bootstrap material
	begin
		for (i = 0; i < 512; i = i + 1) prog[i] = 24'h000000;   // nop
		prog[0]  = 24'h08f4bf; prog[1]  = 24'h000018;   // movep #$18,x:$ffff
		prog[2]  = 24'h44f400; prog[3]  = 24'h000001;   // move #1,x0
		prog[4]  = 24'h0aa980; prog[5]  = 24'h000004;   // L1: jclr #0,x:$ffe9,L1
		prog[6]  = 24'h084e2b;                          // movep x:$ffeb,a
		prog[7]  = 24'h200040;                          // add x0,a
		prog[8]  = 24'h0aa981; prog[9]  = 24'h000008;   // L2: jclr #1,x:$ffe9,L2
		prog[10] = 24'h08ce2b;                          // movep a,x:$ffeb
		prog[11] = 24'h0c0004;                          // jmp L1
		// the vector table lives in P:$0000-$003F: IRQB at P:$0004 (two words)
		// -- the main program above sits in it, so move the loop: place the
		// real program at P:$0040 and start with a jump
		for (i = 0; i < 12; i = i + 1) prog[64 + i] = prog[i];
		prog[64 + 5]  = 24'h000044;   // L1 = $44
		prog[64 + 9]  = 24'h000048;   // L2 = $48
		prog[64 + 11] = 24'h0c0044;   // jmp L1
		for (i = 0; i < 12; i = i + 1) prog[i] = 24'h000000;
		prog[0] = 24'h0c0040;         // jmp $40 (reset vector)
		prog[4] = 24'h0d0080;         // IRQB vector: jsr $80 (a long interrupt)
		prog[5] = 24'h000000;
		prog[128] = 24'h579000;       // move x:$10,b
		prog[129] = 24'h200048;       // add x0,b
		prog[130] = 24'h571000;       // move b,x:$10
		prog[131] = 24'h000004;       // rti
	end
endtask

reg [7:0] v;
reg [23:0] w;
reg ok;
integer n;

initial begin
	$display("tb_next_dsp: the NeXT DSP56001 host port, DMA channel and start modes");
	repeat (4) @(posedge clk);
	reset <= 0;
	repeat (4) @(posedge clk);

	//------------------------------------------------------------------
	// 1: reset values while held in reset (SCR2 bit 7 clear)
	//------------------------------------------------------------------
	host_rd(3'd0, v); check(v == 8'h00, "1 ICR reads 0 in reset");
	host_rd(3'd1, v); check(v == 8'h12, "1 CVR reads $12 in reset");
	host_rd(3'd2, v); check(v == 8'h06, "1 ISR reads $06 (TRDY, TXDE) in reset");
	host_rd(3'd3, v); check(v == 8'h0f, "1 IVR reads $0f in reset");
	host_rd(3'd4, v); check(v == 8'h00, "1 TRX0 reads 0");
	check(!int_dsp_l3 && !int_dsp_l4 && !int_dsp_dma, "1 no interrupt in reset");

	//------------------------------------------------------------------
	// 2: mode 1 bootstrap and PIO exchange
	//------------------------------------------------------------------
	dsp_reset(2'd1);
	host_rd(3'd2, v); check(v == 8'h06, "2 ISR $06 after the release");
	check(dut.u_periph.running == 1'b0, "2 not running before the bootstrap");
	load_echo_program;
	for (i = 0; i < 512; i = i + 1) host_tx(prog[i]);
	repeat (8) @(posedge clk);
	check(dut.u_periph.running == 1'b1, "2 running after 512 words");
	check(dut.u_core.u_pint.mem[64] == 24'h08f4bf && dut.u_core.u_pint.mem[131] == 24'h000004, "2 the program is in P RAM");
	check(dut.u_core.rr[0] == 16'h0200 && dut.u_core.omr == 8'h02, "2 R0 = 512, OMR = 2 after the bootstrap");
	// a word out, its echo back
	wait_isr(3'd1, ok); check(ok, "2 TXDE before the first word");
	host_tx(24'h112233);
	wait_isr(3'd0, ok); check(ok, "2 RXDF: the echo arrived");
	host_rx(w); check(w == 24'h112234, "2 echoed word = sent + 1");
	host_rd(3'd2, v); check(v[0] == 1'b0, "2 RXDF clear after reading RXL");
	// HREQ as an interrupt: RREQ set, a word pending
	host_wr(3'd0, 8'h01);                      // ICR RREQ
	host_tx(24'h00abcd);
	wait_isr(3'd0, ok); check(ok, "2 second echo pending");
	host_rd(3'd2, v); check(v[7] == 1'b1, "2 ISR.HREQ with RREQ and RXDF");
	check(int_dsp_l3 == 1'b1 && int_dsp_l4 == 1'b0, "2 HREQ -> INT_DSP_L3 (SCR2 level 3)");
	@(posedge clk); dsp_int_l4 <= 1; bmap_hreq_en <= 0; repeat (2) @(posedge clk);
	check(int_dsp_l3 == 1'b0 && int_dsp_l4 == 1'b0, "2 level 4 selected, BMAP enable clear: no interrupt");
	@(posedge clk); bmap_hreq_en <= 1; repeat (2) @(posedge clk);
	check(int_dsp_l4 == 1'b1, "2 level 4 with the BMAP enable: INT_DSP_L4");
	host_rx(w); check(w == 24'h00abce, "2 second echo = sent + 1");
	repeat (2) @(posedge clk);
	check(int_dsp_l4 == 1'b0, "2 INT_DSP_L4 drops with RXDF");
	@(posedge clk); dsp_int_l4 <= 0; bmap_hreq_en <= 0;
	host_wr(3'd0, 8'h00);

	//------------------------------------------------------------------
	// 3: DMA memory -> DSP, 24-bit words, IRQB at the block end
	//------------------------------------------------------------------
	for (i = 0; i < 4096; i = i + 1) ram[i] = 8'h00;
	ram[0] = 8'h01; ram[1] = 8'h02; ram[2] = 8'h03;     // word 1: $010203
	ram[3] = 8'h40; ram[4] = 8'h50; ram[5] = 8'h60;     // word 2: $405060
	ptr_wr32(4'd0, 32'h04000000);                       // next
	ptr_wr32(4'd4, 32'h04000006);                       // limit
	@(posedge clk); dsp_blk_end <= 1;
	csr_cmd(8'h01);                                     // SETENABLE, memory -> device
	csr_rd(v); check(v[0] == 1'b1, "3 channel enabled");
	host_wr(3'd0, 8'h22);                               // ICR HM = 01 (24-bit), TREQ
	host_rd(3'd2, v); check(v[6] == 1'b1, "3 ISR.DMA set by HM");
	check(int_dsp_l3 == 1'b0, "3 HREQ is not an interrupt in DMA mode");
	ok = 0;
	for (n = 0; n < 4000 && !ok; n = n + 1) begin @(posedge clk); if (int_dsp_dma) ok = 1; end
	check(ok, "3 INT_DSP_DMA: the channel completed");
	csr_rd(v); check(v[3] == 1'b1 && v[0] == 1'b0, "3 CSR COMPLETE, not enabled");
	host_wr(3'd0, 8'h00);                               // leave DMA mode
	wait_isr(3'd0, ok); check(ok, "3 the first word's echo waits in RX");
	host_rx(w); check(w == 24'h010204, "3 first word reached the DSP (+1 back)");
	// the IRQB handler counted the block end
	repeat (200) @(posedge clk);
	check(dut.u_core.u_xint.mem[16] == 24'h000001, "3 IRQB taken: the handler's count in X:$10 is 1");
	wait_isr(3'd0, ok); check(ok, "3 the second word's echo");
	host_rx(w); check(w == 24'h405061, "3 second word reached the DSP (+1 back)");

	//------------------------------------------------------------------
	// 4: DMA DSP -> memory: two more words sent by PIO come back by DMA
	//------------------------------------------------------------------
	csr_cmd(8'h10);                                     // RESET: COMPLETE, SUPDATE, ENABLE clear
	csr_rd(v); check(v == 8'h00, "4 CSR clear after RESET");
	check(int_dsp_dma == 1'b0, "4 INT_DSP_DMA dropped with COMPLETE");
	ptr_wr32(4'd0, 32'h04000100);
	ptr_wr32(4'd4, 32'h04000106);
	csr_cmd(8'h05);                                     // SETENABLE | DEV2M
	host_wr(3'd0, 8'h21);                               // HM = 01, RREQ
	host_tx(24'h0a0b0c);
	wait_isr(3'd1, ok); check(ok, "4 TXDE for the second word");
	host_tx(24'h7f7f7f);
	ok = 0;
	for (n = 0; n < 4000 && !ok; n = n + 1) begin @(posedge clk); if (int_dsp_dma) ok = 1; end
	check(ok, "4 INT_DSP_DMA: the receive channel completed");
	host_wr(3'd0, 8'h00);
	check(ram[256] == 8'h0a && ram[257] == 8'h0b && ram[258] == 8'h0d, "4 first echoed word in RAM (+1)");
	check(ram[259] == 8'h7f && ram[260] == 8'h7f && ram[261] == 8'h80, "4 second echoed word in RAM (+1)");
	check(ram[262] == 8'h00, "4 nothing past the limit");

	//------------------------------------------------------------------
	// 5: unpacked: four bytes per word in memory
	//------------------------------------------------------------------
	@(posedge clk); dsp_unpacked <= 1; dsp_blk_end <= 0;
	ram[512] = 8'h11; ram[513] = 8'h22; ram[514] = 8'h33; ram[515] = 8'hee;   // $112233 + pad
	ram[516] = 8'h44; ram[517] = 8'h55; ram[518] = 8'h66; ram[519] = 8'hee;   // $445566 + pad
	csr_cmd(8'h10);
	ptr_wr32(4'd0, 32'h04000200);
	ptr_wr32(4'd4, 32'h04000208);
	csr_cmd(8'h01);
	host_wr(3'd0, 8'h22);
	ok = 0;
	for (n = 0; n < 4000 && !ok; n = n + 1) begin @(posedge clk); if (int_dsp_dma) ok = 1; end
	check(ok, "5 unpacked send completed");
	host_wr(3'd0, 8'h00);
	// now read the two echoes back by DMA, unpacked
	csr_cmd(8'h10);
	ptr_wr32(4'd0, 32'h04000300);
	ptr_wr32(4'd4, 32'h04000308);
	for (i = 768; i < 776; i = i + 1) ram[i] = 8'hcc;
	csr_cmd(8'h05);
	host_wr(3'd0, 8'h21);
	ok = 0;
	for (n = 0; n < 4000 && !ok; n = n + 1) begin @(posedge clk); if (int_dsp_dma) ok = 1; end
	check(ok, "5 unpacked receive completed");
	host_wr(3'd0, 8'h00);
	check(ram[768] == 8'h11 && ram[769] == 8'h22 && ram[770] == 8'h34 && ram[771] == 8'h00, "5 first word: H M L+1 and a 0 fourth byte");
	check(ram[772] == 8'h44 && ram[773] == 8'h55 && ram[774] == 8'h67 && ram[775] == 8'h00, "5 second word likewise");
	@(posedge clk); dsp_unpacked <= 0;

	//------------------------------------------------------------------
	// 6: start mode 2: external P:$E000 (the NeXT map puts it at ext[0])
	//------------------------------------------------------------------
	@(posedge clk); dsp_run <= 0; repeat (4) @(posedge clk);
	dut.u_core.u_ext.mem[0] = 24'h08f4ab;   // movep #$123456,x:$ffeb
	dut.u_core.u_ext.mem[1] = 24'h123456;
	dut.u_core.u_ext.mem[2] = 24'h000086;   // wait
	dsp_reset(2'd2);
	check(dut.u_periph.running == 1'b1, "6 mode 2 runs at the release");
	wait_isr(3'd0, ok); check(ok, "6 the program at P:$E000 wrote HTX");
	host_rx(w); check(w == 24'h123456, "6 the word from P:$E000's program");

	//------------------------------------------------------------------
	// 7: start mode 0: external P:$C000 copied into P:$0000
	//------------------------------------------------------------------
	@(posedge clk); dsp_run <= 0; repeat (4) @(posedge clk);
	dut.u_core.u_ext.mem[0] = 24'h08f4ab;
	dut.u_core.u_ext.mem[1] = 24'h654321;
	dut.u_core.u_ext.mem[2] = 24'h000086;
	dut.u_core.u_pint.mem[0] = 24'h000000;
	dut.u_core.u_pint.mem[1] = 24'h000000;
	dsp_reset(2'd0);
	repeat (600) @(posedge clk);
	check(dut.u_core.u_pint.mem[0] == 24'h08f4ab && dut.u_core.u_pint.mem[1] == 24'h654321 && dut.u_core.u_pint.mem[2] == 24'h000086,
	      "7 mode 0 copied P:$C000.. into internal P RAM");
	wait_isr(3'd0, ok); check(ok, "7 the copied program ran from P:$0000");
	host_rx(w); check(w == 24'h654321, "7 the word from the copied program");

	//------------------------------------------------------------------
	// 8: external memory disabled: mode 2 reads zeros, nothing comes
	//------------------------------------------------------------------
	@(posedge clk); dsp_run <= 0; dsp_mem_en <= 0; repeat (4) @(posedge clk);
	dsp_reset(2'd2);
	repeat (400) @(posedge clk);
	host_rd(3'd2, v); check(v[0] == 1'b0, "8 memory disabled: no HTX word from P:$E000");
	@(posedge clk); dsp_mem_en <= 1;

	if (errors == 0) $display("ALL PASSED (tb_next_dsp)");
	else $display("%0d FAILURES (tb_next_dsp)", errors);
	$finish;
end

endmodule
