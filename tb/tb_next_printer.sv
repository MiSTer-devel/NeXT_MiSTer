//============================================================================
//  Printer test: drives the real next_printer the way the driver does -
//  probe the LP CSR/data ports with Mach's reset sequence, program the DMA
//  channel, enable DMA-out, and check the raster is streamed out of memory
//  a word at a time and the channel completes (INT_PRINTER_DMA).  Also
//  checks that a high/invalid channel address is a bus exception, not a
//  wrapped low-RAM access.
//============================================================================

`timescale 1ns/1ps

module tb_next_printer;

reg clk = 0;
always #5 clk = ~clk;

reg reset = 1;

reg         sel_lp = 0, sel_csr = 0, sel_ptr = 0, sel_ini = 0;
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
integer     m_err_count = 0;

wire        int_printer, int_printer_dma;

next_printer #(.CLK_HZ(1000000)) dut
(
	.clk(clk), .reset(reset),
	.sel_lp(sel_lp), .sel_csr(sel_csr), .sel_ptr(sel_ptr), .sel_ini(sel_ini),
	.addr(addr), .we(we), .be(be), .wdata(wdata), .rdata(rdata),
	.m_req(m_req), .m_we(m_we), .m_addr(m_addr), .m_be(m_be),
	.m_din(m_din), .m_dout(m_dout), .m_ack(m_ack), .m_err(m_err),
	.int_printer(int_printer), .int_printer_dma(int_printer_dma)
);

// RAM model: acknowledge reads with a value, count the raster words read
reg ack_r;
integer reads = 0;
assign m_ack = ack_r;
always @(posedge clk) begin
	if (m_err) m_err_count <= m_err_count + 1;
	if (reset) ack_r <= 0;
	else if (!m_req || !m_addr_valid) ack_r <= 0;
	else if (!ack_r) begin
		m_dout <= 32'hA5A5F00F;   // a raster word; the printer consumes it
		ack_r <= 1;
		reads <= reads + 1;
	end
	else ack_r <= 0;
end

task lp_wr16;
	input       hi;            // 1 = bytes 0/1 (addr[1]=0), 0 = bytes 2/3
	input [7:0] b_hi, b_lo;
	begin
		@(posedge clk);
		sel_lp <= 1; we <= 1; addr <= hi ? 16'h0 : 16'h2;
		be <= 2'b11; wdata <= {b_hi, b_lo};
		@(posedge clk);
		sel_lp <= 0; we <= 0;
	end
endtask

task lp_write;
	input [15:0] a;
	input [1:0] lanes;
	input [15:0] data;
	begin
		@(posedge clk);
		sel_lp <= 1; we <= 1; addr <= a;
		be <= lanes; wdata <= data;
		@(posedge clk);
		sel_lp <= 0; we <= 0;
	end
endtask

task lp_read;
	input [15:0] a;
	output [15:0] data;
	begin
		@(posedge clk);
		sel_lp <= 1; we <= 0; addr <= a;
		@(posedge clk);
		#1 data = rdata;
		sel_lp <= 0;
	end
endtask

task lp_rd16;
	input       hi;
	output [15:0] v;
	begin
		@(posedge clk);
		sel_lp <= 1; we <= 0; addr <= hi ? 16'h0 : 16'h2;
		@(posedge clk);
		#1 v = rdata;
		sel_lp <= 0;
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

task csr_cmd;
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

integer errors = 0;
task check;
	input cond;
	input [639:0] name;
	begin
		if (cond) $display("PASS: %0s", name);
		else begin $display("FAIL: %0s", name); errors = errors + 1; end
	end
endtask

reg [15:0] v;
integer offset;

initial begin
	repeat (10) @(posedge clk);
	reset = 0;
	repeat (10) @(posedge clk);

	// Power and interface enable are software controls, reset to off.
	lp_rd16(1'b1, v);
	check(v == 0, "LP CSR: power and DMA disabled on reset");
	lp_rd16(1'b0, v);
	check(v == 0, "LP CSR: interface disabled on reset");

	// NeXT Mach 2.0 _np_power_on: enable the interface, power on, send
	// command FF with data FFFFFFFF, then enter _np_recv. The data port
	// at F004/F006 must not alias the CSR at F000/F002. On the broken
	// decode the CSR becomes 80FFFFFF and _np_recv spins on mask 0800
	// forever at IPL 3 (PC 04064052 in the Improv1.0Beta kernel).
	lp_write(16'hF002, 2'b10, 16'h0200);
	lp_write(16'hF000, 2'b01, 16'h0080);
	lp_write(16'hF002, 2'b01, 16'h00FF);
	lp_write(16'hF004, 2'b11, 16'hFFFF);
	lp_write(16'hF006, 2'b11, 16'hFFFF);
	lp_rd16(1'b1, v);
	check(v == 16'h0080, "printer reset data preserves power and DMA control");
	lp_rd16(1'b0, v);
	check((v & 16'h0800) == 0, "Mach _np_recv polling bit stays clear after RESET");
	check(v == 16'h02FF, "printer reset data preserves interface and command");

	// Every non-CSR halfword in the decoded window is independent,
	// including byte writes and the unused F008..F00F addresses.
	for (offset = 4; offset < 16; offset = offset + 2) begin
		lp_write(16'hF000 + 16'(offset), 2'b10, 16'hA500);
		lp_write(16'hF000 + 16'(offset), 2'b01, 16'h005A);
		lp_read(16'hF000 + 16'(offset), v);
		check(v == 0, "absent printer data / unused window reads zero");
	end
	lp_rd16(1'b1, v);
	check(v == 16'h0080, "non-CSR byte writes preserve power and DMA");
	lp_rd16(1'b0, v);
	check(v == 16'h02FF, "non-CSR byte writes preserve interface and command");

	// Status/reserved bits cannot be manufactured by software writes.
	lp_write(16'hF000, 2'b01, 16'h00FF);
	lp_write(16'hF002, 2'b10, 16'hFF00);
	lp_rd16(1'b1, v);
	check(v == 16'h00C0, "printer status stays idle with no received data");
	lp_rd16(1'b0, v);
	check(v == 16'h03FF, "transmit status and reserved bits stay clear");
	lp_write(16'hF000, 2'b01, 16'h0000);
	lp_write(16'hF002, 2'b10, 16'h0000);
	lp_rd16(1'b1, v);
	check(v == 0, "driver can switch printer power off after failed probe");
	lp_rd16(1'b0, v);
	check(v == 16'h00FF, "driver can disable the interface after failed probe");
	check(!int_printer, "absent printer leaves event interrupt clear");

	// program a 256-byte (64-word) raster buffer and enable DMA out
	ptr_wr32(4'h0, 32'h04002000);      // next
	ptr_wr32(4'h4, 32'h04002100);      // limit
	csr_cmd(8'h01);                    // SETENABLE
	lp_wr16(1'b1, 8'h80, 8'h00);       // LP_DMA_OUT_EN

	// the channel streams the whole buffer out and completes
	repeat (600) @(posedge clk);
	check(reads == 64, "printer DMA reads all 64 raster words from memory");
	check(int_printer_dma, "channel complete raises INT_PRINTER_DMA");
	check(dut.d_next == 32'h04002100, "next advanced to the limit");
	check(!dut.d_csr[0], "channel disabled at completion");

	// clear complete releases the interrupt
	csr_cmd(8'h08);                    // CLRCOMPLETE
	repeat (2) @(posedge clk);
	check(!int_printer_dma, "CLRCOMPLETE releases the channel interrupt");

	// a chained buffer (SUPDATE) reloads next/limit from start/stop
	ptr_wr32(4'h8, 32'h04003000);      // start
	ptr_wr32(4'hC, 32'h04003040);      // stop  (16-word buffer)
	ptr_wr32(4'h0, 32'h04002200);
	ptr_wr32(4'h4, 32'h04002240);
	csr_cmd(8'h03);                    // SETENABLE | SETSUPDATE
	reads = 0;
	repeat (400) @(posedge clk);
	// On the first buffer's completion SUPDATE reloads next<=start,
	// limit<=stop and clears SUPDATE; the channel stays enabled, so the
	// chained buffer is streamed too.  After both drain, limit sits at
	// stop and 16 (first) + 16 (chained) = 32 words have been read.
	check(int_printer_dma, "chained buffer completes");
	check(reads == 32 && dut.d_limit == 32'h04003040 && !dut.d_csr[1],
	      "SUPDATE reloaded limit from stop and streamed the chained buffer");
	csr_cmd(8'h08);

	// a high/invalid channel address is a bus exception, not a wrap
	m_err_count = 0;
	csr_cmd(8'h10);                    // RESET
	ptr_wr32(4'h0, 32'h08000000);
	ptr_wr32(4'h4, 32'h08000040);
	csr_cmd(8'h01);                    // SETENABLE
	repeat (20) @(posedge clk);
	check(m_err_count != 0 && m_addr == 30'h02000000,
	      "printer DMA preserves the invalid high address to the master port");
	check(!dut.d_csr[0] && dut.d_csr[3] && dut.d_csr[4],
	      "rejected printer DMA completes with BUSEXC and disables the channel");

	if (errors == 0) $display("ALL PASS");
	else             $fatal(1, "%0d FAILURES", errors);
	$finish;
end

endmodule
