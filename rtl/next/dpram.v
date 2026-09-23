//============================================================================
//  dpram: the AP68040's true-dual-port RAM (ctag_ram, atc_ram), taken
//  verbatim from MacQuadra800_MiSTer rtl/dpram.v, the wrapper the cache and
//  MMU were designed and validated on silicon against.
//
//  It replaced the inferred write-first template that used to live here
//  (2026-09-23): that template implied mixed-port OLD-data semantics, which
//  a Cyclone V M10K cannot provide, so what Quartus built did not have the
//  read-during-write behaviour the CPU's snoop/fill/sweep logic assumes
//  (mixed-port DONT_CARE, same-port NEW data).  NeXTSTEP's vm_page bucket
//  walk read a wrong longword on hardware while the same RTL booted in the
//  simulator.  The simulation branch keeps the CPU suite's stub semantics
//  so the boot bench and the CPU suite agree.
//
//  The VRAM's dual-clock variant (dpram_dc, below) is this core's own and
//  is unchanged.
//============================================================================

module dpram #(parameter AW = 8, parameter DW = 8) (
	input clock,
	input [AW-1:0] address_a,
	input [DW-1:0] data_a,
	input wren_a,
	output [DW-1:0] q_a,
	input [AW-1:0] address_b,
	input [DW-1:0] data_b,
	input wren_b,
	output [DW-1:0] q_b
);

`ifdef VERILATOR

	reg [DW-1:0] mem [0:(1<<AW)-1];
	reg [DW-1:0] q_a_r, q_b_r;
`ifdef NEXT_RAM_PESSIMISTIC
	// M10K semantics as the silicon has them: same-port read-during-write
	// returns NEW data, a mixed-port collision (the other port writes the
	// address this port reads) returns garbage, and two writes to one
	// address leave garbage.  Collisions are counted and the first few
	// announced so a boot run shows whether the RTL ever relies on them.
	integer coll_ab = 0, coll_ba = 0, coll_ww = 0;
	reg [DW-1:0] junk;
	always @(posedge clock) begin
		junk = {6{$random}};
		if (wren_a) mem[address_a] <= data_a;
		if (wren_b) mem[address_b] <= data_b;
		if (wren_a && wren_b && address_a == address_b) begin
			mem[address_a] <= junk; coll_ww = coll_ww + 1;
			if (coll_ww <= 8) $display("[%0t] dpram(%0d,%0d) WRITE/WRITE collision at %0h", $time, AW, DW, address_a);
		end
		q_a_r <= (wren_b && !wren_a && address_b == address_a) ? junk : (wren_a ? data_a : mem[address_a]);
		q_b_r <= (wren_a && !wren_b && address_a == address_b) ? junk : (wren_b ? data_b : mem[address_b]);
		if (wren_b && !wren_a && address_b == address_a) begin
			coll_ba = coll_ba + 1;
			if (coll_ba <= 8) $display("[%0t] dpram(%0d,%0d) port A reads row %0h while port B writes it", $time, AW, DW, address_a);
		end
		if (wren_a && !wren_b && address_a == address_b) begin
			coll_ab = coll_ab + 1;
			if (coll_ab <= 8) $display("[%0t] dpram(%0d,%0d) port B reads row %0h while port A writes it", $time, AW, DW, address_b);
		end
	end
`else
	always @(posedge clock) begin
		if (wren_a) mem[address_a] <= data_a;
		if (wren_b) mem[address_b] <= data_b;
		q_a_r <= mem[address_a];
		q_b_r <= mem[address_b];
	end
`endif
	assign q_a = q_a_r;
	assign q_b = q_b_r;

`else

	altsyncram ram
	(
		.clock0    (clock),
		.address_a (address_a),
		.data_a    (data_a),
		.wren_a    (wren_a),
		.q_a       (q_a),

		.address_b (address_b),
		.data_b    (data_b),
		.wren_b    (wren_b),
		.q_b       (q_b),

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
		ram.numwords_a = 1<<AW,
		ram.widthad_a  = AW,
		ram.width_a    = DW,
		ram.numwords_b = 1<<AW,
		ram.widthad_b  = AW,
		ram.width_b    = DW,
		ram.address_reg_b = "CLOCK0",
		ram.clock_enable_input_a = "BYPASS",
		ram.clock_enable_input_b = "BYPASS",
		ram.clock_enable_output_a = "BYPASS",
		ram.clock_enable_output_b = "BYPASS",
		ram.indata_reg_b = "CLOCK0",
		ram.intended_device_family = "Cyclone V",
		ram.lpm_type = "altsyncram",
		ram.operation_mode = "BIDIR_DUAL_PORT",
		ram.outdata_aclr_a = "NONE",
		ram.outdata_aclr_b = "NONE",
		ram.outdata_reg_a = "UNREGISTERED",
		ram.outdata_reg_b = "UNREGISTERED",
		ram.power_up_uninitialized = "FALSE",
		ram.ram_block_type = "M10K",
		ram.read_during_write_mode_mixed_ports = "DONT_CARE",
		ram.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		ram.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
		ram.width_byteena_a = 1,
		ram.width_byteena_b = 1,
		ram.wrcontrol_wraddress_reg_b = "CLOCK0";

`endif

endmodule

//----------------------------------------------------------------------------
// Dual-clock variant: port A and port B each have their own clock.
// Same inference template; used where a memory crosses clock domains
// (the VRAM scan-out port runs in the video clock domain).
//----------------------------------------------------------------------------

module dpram_dc #(parameter AW = 8, parameter DW = 8) (
	input clock_a,
	input [AW-1:0] address_a,
	input [DW-1:0] data_a,
	input wren_a,
	output reg [DW-1:0] q_a,
	input clock_b,
	input [AW-1:0] address_b,
	input [DW-1:0] data_b,
	input wren_b,
	output reg [DW-1:0] q_b
);
	reg [DW-1:0] mem [0:(1<<AW)-1];

	always @(posedge clock_a) begin
		if (wren_a) begin
			mem[address_a] <= data_a;
			q_a <= data_a;
		end
		else q_a <= mem[address_a];
	end

	always @(posedge clock_b) begin
		if (wren_b) begin
			mem[address_b] <= data_b;
			q_b <= data_b;
		end
		else q_b <= mem[address_b];
	end
endmodule
