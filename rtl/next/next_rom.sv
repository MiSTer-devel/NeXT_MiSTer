//============================================================================
//  NeXT boot ROM, 128 KB (0x00000000 and mirror 0x01000000, mask 0x1FFFF)
//
//  Only the first 96 KB is stored: every ROM image this core runs (Rev 2.5
//  v66 ends at 0x1708C) is zero above 0x18000, and reads there return zero
//  from the bounds check instead of costing 32 of the device's 553 M10Ks.
//
//  Port A: CPU read.  Registered address, registered output.
//  Port B: byte-wide write from the HPS file download (ioctl), assembling
//  big-endian byte pairs: even file offset = bits [15:8].
//
//  For simulation the image can be preloaded with $readmemh from
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
reg [15:0] mem [0:WORDS-1];

reg [15:0] qa;
assign a_q = qa;

always @(posedge clk) qa <= (a_addr < WORDS) ? mem[a_addr] : 16'h0000;

reg [7:0] evenbyte;
always @(posedge clk) begin
	if (wr) begin
		if (!w_addr[0]) evenbyte <= w_din;
		else if (w_addr[16:1] < WORDS) mem[w_addr[16:1]] <= {evenbyte, w_din};
	end
end

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

endmodule
