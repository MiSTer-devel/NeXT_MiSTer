// Real AP68040 + next_system regression for the captured recording abort.
// Only the ROM program and RAM are test fixtures. No device state is forced.
`timescale 1ns/1ps
module tb_next_recording;
reg clk=0,reset=1;
always #5 clk=~clk;
wire req,we,halted;
wire [3:0] be;
wire [23:0] addr;
wire [31:0] wd,pc;
reg [31:0] rd=0;
reg ack=0;
next_system #(.CLK_HZ(1000000),.CLK_REAL_HZ(1000000),
 .CPU_PACE_NUM(2),.CPU_PACE_DEN(2),.ROM_INIT_EN(0)) dut(
 .clk(clk),.clk_vid(clk),.reset(reset),.ps2_key(11'd0),.ps2_mouse(25'd0),
 .boot_sel(3'd0),.enet_connected(1'b0),
 .oimg_mounted(2'd0),.oimg_readonly(1'b0),.oimg_size(64'd0),.osd_ack(1'b0),
 .fimg_mounted(2'd0),.fimg_readonly(1'b0),.fimg_size(64'd0),.fsd_ack(1'b0),
 .fsd_buff_addr(9'd0),.fsd_buff_dout(8'd0),.fsd_buff_wr(1'b0),
 .img_mounted(6'd0),.img_readonly(1'b0),.img_size(64'd0),.sd_ack(1'b0),
 .sd_buff_addr(9'd0),.sd_buff_dout(8'd0),.sd_buff_wr(1'b0),
 .rom_wr(1'b0),.rom_waddr(17'd0),.rom_wdata(8'd0),
 .ram_req(req),.ram_we(we),.ram_be(be),.ram_addr(addr),.ram_din(wd),.ram_dout(rd),.ram_ack(ack),
 .btx_addr(11'd0),.btx_rd(1'b0),.btx_done(1'b0),.brx_start(1'b0),
 .brx_len(11'd0),.brx_valid(1'b0),.brx_data(8'd0),
 .audio_in(16'sd0),.dbg_pc(pc),.dbg_halted(halted));
reg [31:0] ram[0:8191];
integer k;
always @(posedge clk) begin
 if(reset || !req)ack<=0;
 else if(!ack) begin
  if(addr>=8192)$fatal(1,"unexpected RAM address %08x",{6'b000001,addr,2'b00});
  rd<=ram[addr];
  if(we)for(k=0;k<4;k=k+1)if(be[k])ram[addr][k*8+:8]<=wd[k*8+:8];
  ack<=1;
 end
end
integer rp;
task word(input [15:0] v);begin dut.rom.mem[rp]=v;rp=rp+1;end endtask
task longword(input [31:0] v);begin word(v[31:16]);word(v[15:0]);end endtask
task store32(input [31:0] a,input [31:0] v);
 begin word(16'h23fc);longword(v);longword(a);end
endtask
task store8(input [31:0] a,input [7:0] v);
 begin word(16'h13fc);word({8'd0,v});longword(a);end
endtask
task codec(input [7:0] cmd);
 begin store8(32'h0200e003,cmd);store32(32'h0200e004,0);end
endtask
task arm(input [31:0] start,input [31:0] limit);
 begin store32(32'h02004280,start);store32(32'h02004084,limit);store32(32'h02000080,32'h00050000);end
endtask
task abort_channel;
 begin
  codec(8'h03);
  word(16'h227c);longword(32'h02000080); // movea.l #CSR,a1
  word(16'h46fc);word(16'h2600);        // move.w #$2600,sr
  word(16'h2011);word(16'h67fc);        // captured move.l (a1),d0 / beq back
  word(16'h22bc);longword(32'h00100000);// move.l #RESET,(a1)
 end
endtask
integer i,n;
bit abort_only;
initial begin
 abort_only=$test$plusargs("abortonly");
 for(i=0;i<8192;i=i+1)ram[i]=32'h12345678;
 for(i=0;i<65536;i=i+1)dut.rom.mem[i]=16'h4e71;
 rp=0;longword(32'h04007ff0);longword(32'h01000100);
 rp=128;
 store8(32'h0200e002,8'h02);store8(32'h0200e000,8'h08);
 arm(32'h04002000,32'h04002080);
 if(!abort_only)begin
  codec(8'h0b);
  // Poll the real system interrupt status for sound-input DMA, bit 22.
  word(16'h2039);longword(32'h02007000);
  word(16'h0800);word(16'd22);word(16'h67f4);
 end
 abort_channel;
 store32(32'h04000100,32'h600dcafe);
 // A stopped codec must still allow abort of a newly armed channel.
 arm(32'h04002100,32'h04002200);abort_channel;
 word(16'h46fc);word(16'h2000);
 store32(32'h04000104,32'h600df00d);word(16'h60fe);
 repeat(20)@(negedge clk);reset=0;
 n=0;
 while(ram[65]!=32'h600df00d && n<300000)begin @(negedge clk);n=n+1;end
 if(halted || ram[65]!=32'h600df00d)
  $fatal(1,"recording abort did not return: PC=%08x marker=%08x",pc,ram[64]);
 if(!abort_only)begin
  for(i=2048;i<2080;i=i+1)if(ram[i]!=32'hffffffff)$fatal(1,"bad recorded sample at %0d",i);
  if(dut.intc.stat[22])$fatal(1,"sound-input interrupt not released after RESET");
 end
 $display("PASS: real CPU recording DMA and both abort paths return (abortonly=%0d)",abort_only);
 $display("ALL PASS");$finish;
end
endmodule
