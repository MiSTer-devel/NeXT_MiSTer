//--------------------------------------------------------------------------//
// tb_bus32_host16.v - bench side of the 32-bit beat port.                  //
//                                                                          //
// Serves ap040_bus32_adapter's beats as the TG68K-style 16-bit sub-cycles  //
// the program bench's memory model, latency model and magic registers      //
// speak (busstate/addr_out/nuds/nlds/data_write, one mem_ready per         //
// sub-cycle, berr aborts), so the whole suite runs on the 32-bit path      //
// (-DAP040_TB_BUS32=1) with every clock-enable policy.  The split is the   //
// one NeXT_MiSTer's next_system makes for its 16-bit devices: upper half   //
// (b_be[3:2]) first, one idle clock, then the lower half (b_be[1:0]); a    //
// half with no byte enabled is skipped.  Free-running (a host, not a core  //
// stage).                                                                  //
//--------------------------------------------------------------------------//

module tb_bus32_host16
(
	input             clk,
	input             nreset,

	// the beat port
	input             b_req,
	input             b_write,
	input             b_instr,
	input      [31:2] b_addr,
	input       [3:0] b_be,
	input      [31:0] b_wdata,
	input       [2:0] b_fc,
	output reg        b_ack,
	output reg [31:0] b_rdata,

	// the 16-bit host side
	output reg  [1:0] busstate,
	output reg [31:0] addr_out,
	output reg [15:0] data_write,
	output reg        nwr,
	output reg        nuds,
	output reg        nlds,
	output      [2:0] fc,
	output            longword,
	input      [15:0] data_in,
	input             mem_ready,
	input             berr
);

localparam H_IDLE = 2'd0, H_WAIT = 2'd1, H_GAP = 2'd2, H_ACK = 2'd3;
reg [1:0] hst;
reg       half;

assign fc       = b_fc;
assign longword = 1'b0;

wire [1:0] lanes0 = b_be[3:2];
wire [1:0] lanes1 = b_be[1:0];

task present;
	input h;
	begin
		half       <= h;
		addr_out   <= {b_addr, h, 1'b0};
		nuds       <= h ? ~lanes1[1] : ~lanes0[1];
		nlds       <= h ? ~lanes1[0] : ~lanes0[0];
		data_write <= h ? b_wdata[15:0] : b_wdata[31:16];
		busstate   <= b_write ? 2'b11 : (b_instr ? 2'b00 : 2'b10);
		nwr        <= ~b_write;
		hst        <= H_WAIT;
	end
endtask

always @(posedge clk) begin
	b_ack <= 0;
	if (!nreset) begin
		hst      <= H_IDLE;
		half     <= 0;
		busstate <= 2'b01;
		addr_out <= 0;
		data_write <= 0;
		nwr      <= 1;
		nuds     <= 1;
		nlds     <= 1;
		b_rdata  <= 0;
	end
	else begin
		case (hst)
		H_IDLE: begin
			busstate <= 2'b01;
			nuds <= 1; nlds <= 1; nwr <= 1;
			if (b_req && !b_ack && !berr) present(lanes0 == 2'b00);
		end
		H_WAIT: begin
			if (berr) begin
				// the adapter drops the beat: no acknowledge
				busstate <= 2'b01;
				nuds <= 1; nlds <= 1; nwr <= 1;
				hst <= H_IDLE;
			end
			else if (mem_ready) begin
				if (half) b_rdata[15:0]  <= data_in;
				else      b_rdata[31:16] <= data_in;
				busstate <= 2'b01;
				nuds <= 1; nlds <= 1; nwr <= 1;
				hst <= (!half && lanes1 != 2'b00) ? H_GAP : H_ACK;
			end
		end
		H_GAP: present(1'b1);
		H_ACK: begin
			b_ack <= 1;
			hst   <= H_IDLE;
		end
		endcase
	end
end

endmodule
