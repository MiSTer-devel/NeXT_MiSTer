//============================================================================
//  NeXT boot ROM, 128 KB (0x00000000 and mirror 0x01000000, mask 0x1FFFF)
//
//  Only the first 96 KB is stored: every ROM image this core runs (Rev 2.5
//  v66 ends at 0x1708C) is zero above 0x18000, and reads there return zero
//  from the bounds check instead of costing 32 of the device's 553 M10Ks.
//
//  Port A: CPU read.  Address captured at the clock edge, data valid in the
//  following cycle (an M10K in unregistered-output mode).
//  Port B: byte-wide write from the HPS file download (ioctl), assembling
//  big-endian byte pairs: even file offset = bits [15:8].
//
//  The FPGA build instantiates the altsyncram explicitly, as dpram.v does
//  for the CPU's RAMs: with the 32-bit CPU bus (docs/PERF_PLAN.md stage 3)
//  the read address is a mux of the beat address and the half select, and
//  Quartus 17 stopped inferring the RAM from the array ("uninferred due to
//  asynchronous read logic"), turning 96 KB into registers.  The simulation
//  branch keeps the array so the image can be preloaded with $readmemh from
//  INIT_FILE (one 4-digit hex word per line, big-endian).
//============================================================================

module next_rom #(parameter ROM_INIT_EN = 0, parameter ROM_INIT = "rom.hex")
(
	input         clk,

	// CPU read port
	input  [15:0] a_addr,        // word address
	output [15:0] a_q,

	// byte write port (ioctl download)
	input         wr,
	input  [16:0] w_addr,        // byte address
	input   [7:0] w_din
);

localparam WORDS = 49152;          // 96 KB

// the byte-pair assembly of the download
reg [7:0] evenbyte;
always @(posedge clk) if (wr && !w_addr[0]) evenbyte <= w_din;
wire        mem_we   = wr && w_addr[0] && (w_addr[16:1] < WORDS);
wire [15:0] mem_wa   = w_addr[16:1];
wire [15:0] mem_wd   = {evenbyte, w_din};

// reads above the stored part return zero
reg oob;
always @(posedge clk) oob <= !(a_addr < WORDS);
wire [15:0] q;
assign a_q = oob ? 16'h0000 : q;

`ifdef VERILATOR
reg [15:0] mem [0:WORDS-1];
reg [15:0] qa;
always @(posedge clk) begin
	if (mem_we) mem[mem_wa] <= mem_wd;
	qa <= (a_addr < WORDS) ? mem[a_addr] : 16'h0000;
end
assign q = qa;

generate if (ROM_INIT_EN) begin : g_init
	// simulation only: the hex image is the full 128 KB, so read it into
	// a scratch array and keep the stored part
	reg [15:0] img [0:65535];
	integer ii;
	initial begin
		$readmemh(ROM_INIT, img);
		for (ii = 0; ii < WORDS; ii = ii + 1) mem[ii] = img[ii];
	end
end endgenerate
`else
altsyncram ram (
	.clock0    (clk),
	.address_a (mem_wa),
	.data_a    (mem_wd),
	.wren_a    (mem_we),
	.q_a       (),

	.address_b (a_addr),
	.data_b    (16'd0),
	.wren_b    (1'b0),
	.q_b       (q),

	.aclr0(1'b0),
	.aclr1(1'b0),
	.addressstall_a(1'b0),
	.addressstall_b(1'b0),
	.byteena_a(1'b1),
	.byteena_b(1'b1),
	.clock1(1'b1),
	.clocken0(1'b1),
	.clocken1(1'b1),
	.clocken2(1'b1),
	.clocken3(1'b1),
	.eccstatus(),
	.rden_a(1'b1),
	.rden_b(1'b1)
);
defparam
	ram.numwords_a = WORDS,
	ram.widthad_a  = 16,
	ram.width_a    = 16,
	ram.numwords_b = WORDS,
	ram.widthad_b  = 16,
	ram.width_b    = 16,
	ram.address_reg_b = "CLOCK0",
	ram.clock_enable_input_a = "BYPASS",
	ram.clock_enable_input_b = "BYPASS",
	ram.clock_enable_output_a = "BYPASS",
	ram.clock_enable_output_b = "BYPASS",
	ram.intended_device_family = "Cyclone V",
	ram.lpm_type = "altsyncram",
	ram.operation_mode = "DUAL_PORT",
	ram.outdata_aclr_b = "NONE",
	ram.outdata_reg_b = "UNREGISTERED",
	ram.power_up_uninitialized = "FALSE",
	ram.ram_block_type = "M10K",
	ram.read_during_write_mode_mixed_ports = "DONT_CARE",
	ram.width_byteena_a = 1;
`endif

endmodule
