// Completion must survive the NeXTSTEP read-handler sequence exactly once.
// The September 10 capture had an idle ESP driver, a busy controller, no
// active request, and saved status/sequence/cause 90/04/00. Reentering a
// finished TI after MODE_DMA changes reproduces a zero-cause interrupt.
begin : retired_transfer
 integer run, pump, byte_index, quiet;
 reg [7:0] snap_status, snap_seq, cause, message;
 reg bytes_ok;

 // An 8 KiB read starting four bytes into the DMA buffer leaves its final
 // four bytes retained when the aligned memory window closes. The kernel
 // pumps FLUSH eight times, then clears MODE_DMA before reading INTSTATUS.
 esp_wr8(6'h03,8'h02); csr_cmd(8'h30); esp_wr8(6'h20,8'h30);
 select_atn10_target(0,8'h28,0,0,0,0,0,0,0,16,0);
 wait_irq; read_intr(cause);
 ti_dma_in(17'd8192,BUF+4,BUF+8192);
 check(dut.counter == 0 && !dut.d_csr[0] && dut.dma_buf_size == 4,
       "idle IRQ: read reaches TC with four bytes at a closed DMA window");
 for(pump=0;pump<8;pump=pump+1) begin
  esp_wr8(6'h20,8'h3c); repeat(5) @(posedge clk);
  esp_wr8(6'h20,8'h38); repeat(5) @(posedge clk);
 end
 esp_wr8(6'h20,8'h20);
 esp_rd8(6'h04,snap_status); esp_rd8(6'h06,snap_seq); read_intr(cause);
 check(snap_status == 8'h93 && snap_seq == 4 && cause == 8'h10,
       "idle IRQ: the original read completion retains its status and BS cause");
 quiet=1;
 repeat(250) begin @(posedge clk); if(int_scsi) quiet=0; end
 check(quiet,"idle IRQ: disabled-channel FLUSH and MODE_DMA off cannot repeat TI");
 // NOP and FIFO flush do not start another TI, even though they update
 // the command register and may clear the DMA buffer-resume selector.
 esp_wr8(6'h03,8'h00); esp_wr8(6'h03,8'h01);
 quiet=1;
 repeat(250) begin @(posedge clk); if(int_scsi) quiet=0; end
 check(quiet,"idle IRQ: NOP and FIFO flush do not revive a completed transfer");
 // Rearm only the memory channel. This must still deliver the retained
 // bytes, with no new ESP command or ESP interrupt required.
 ptr_wr32(6'h14,BUF+8208); csr_cmd(8'h05);
 esp_wr8(6'h20,8'h34); repeat(30) @(posedge clk); esp_wr8(6'h20,8'h30);
 bytes_ok=1;
 for(byte_index=0;byte_index<8192;byte_index=byte_index+1)
  if(ram_byte(BUF+4+32'(byte_index)) !== disk[byte_index]) bytes_ok=0;
 check(bytes_ok && dut.dma_buf_size == 0,
       "idle IRQ: channel rearm and FLUSH preserve all 8192 read bytes");
 quiet=1;
 repeat(250) begin @(posedge clk); if(int_scsi) quiet=0; end
 check(quiet,"idle IRQ: draining retained read bytes does not complete TI again");
 csr_cmd(8'h10);
 esp_wr8(6'h03,8'h11); wait_irq; read_intr(cause);
 esp_rd8(6'h02,sts); esp_rd8(6'h02,message);
 check(cause == 8'h08 && sts == 0 && message == 0,
       "idle IRQ: ICCS still reports GOOD and command complete with FC");
 esp_wr8(6'h03,8'h12); wait_irq; read_intr(cause);
 check(cause == 8'h20,"idle IRQ: message acceptance still reports disconnect");
 esp_wr8(6'h03,8'h44);
 quiet=1;
 repeat(250) begin @(posedge clk); if(int_scsi) quiet=0; end
 check(quiet,"idle IRQ: enable selection leaves the disconnected controller quiet");

 // Multiple FLUSH writes can queue while memory is unavailable. The first
 // pump empties the data; later padding pumps must not resume an old TI.
 for(run=0;run<3;run=run+1) begin
  esp_wr8(6'h03,8'h02); csr_cmd(8'h30); esp_wr8(6'h20,8'h30);
  select_atn6(8'h08,0,0,0,1,0); wait_irq; read_intr(cause);
  ti_dma_in(17'd512,BUF+4,BUF+560);
  hold_m_ack=1;
  for(pump=0;pump<8;pump=pump+1) begin
   esp_wr8(6'h20,8'h3c); repeat(5) @(posedge clk);
   esp_wr8(6'h20,8'h38); repeat(5) @(posedge clk);
  end
  esp_wr8(6'h20,8'h20);
  repeat(run*60) @(posedge clk);
  esp_rd8(6'h04,snap_status); esp_rd8(6'h06,snap_seq); read_intr(cause);
  check(cause == 8'h10,"idle IRQ: queued FLUSHes preserve the original BS cause");
  hold_m_ack=0;
  quiet=1;
  repeat(350) begin @(posedge clk); if(int_scsi) quiet=0; end
  bytes_ok=1;
  for(byte_index=0;byte_index<512;byte_index=byte_index+1)
   if(ram_byte(BUF+4+32'(byte_index)) !== disk[byte_index]) bytes_ok=0;
  check(quiet && bytes_ok && dut.dma_flush_count == 0 && dut.dma_buf_size == 0,
        "idle IRQ: delayed padding pumps drain correctly without another completion");
  csr_cmd(8'h10); finish_command(sts);
 end

 // Memory-to-device DMA has the same route-change hazard, but retains
 // unsent prefetched bytes. Use a four-byte offset so twelve bytes remain.
 esp_wr8(6'h03,8'h02); csr_cmd(8'h30); esp_wr8(6'h20,8'h30);
 for(byte_index=0;byte_index<524;byte_index=byte_index+1)
  ram_put(BUF+4+32'(byte_index),8'(byte_index)^8'ha6);
 select_atn6(8'h0a,0,0,24,1,0); wait_irq; read_intr(cause);
 ini_wr32(BUF+4); ptr_wr32(6'h14,BUF+528); csr_cmd(8'h11);
 esp_wr8(6'h00,0); esp_wr8(6'h01,2); esp_wr8(6'h03,8'h90); wait_irq;
 check(dut.counter == 0 && dut.dma_buf_size == 12,
       "idle IRQ: write completes with twelve unsent prefetched bytes");
 esp_wr8(6'h20,8'h20);
 esp_rd8(6'h04,snap_status); esp_rd8(6'h06,snap_seq); read_intr(cause);
 check(cause == 8'h10,"idle IRQ: changing the write route preserves its BS cause");
 quiet=1;
 repeat(250) begin @(posedge clk); if(int_scsi) quiet=0; end
 check(quiet && dut.dma_buf_size == 12,
       "idle IRQ: MODE_DMA off preserves write residuals without repeating TI");
 esp_wr8(6'h03,8'h00); esp_wr8(6'h03,8'h01);
 esp_wr8(6'h20,8'h30);
 quiet=1;
 repeat(250) begin @(posedge clk); if(int_scsi) quiet=0; end
 bytes_ok=1;
 for(byte_index=0;byte_index<512;byte_index=byte_index+1)
  if(disk[24*512+byte_index] !== (8'(byte_index)^8'ha6)) bytes_ok=0;
 check(quiet && bytes_ok && dut.dma_buf_size == 12,
       "idle IRQ: write data stays exact across NOP, FIFO flush, and route restore");
 csr_cmd(8'h10); finish_command(sts); esp_wr8(6'h03,8'h44);

 // A fresh TI must get its own completion; do not merely mask the line.
 esp_wr8(6'h20,8'h30);
 select_atn6(8'h08,0,0,24,1,0); wait_irq; read_intr(cause);
 ti_dma_in(17'd512,BUF,BUF+512); read_intr(cause);
 bytes_ok=1;
 for(byte_index=0;byte_index<512;byte_index=byte_index+1)
  if(ram_byte(BUF+32'(byte_index)) !== disk[24*512+byte_index]) bytes_ok=0;
 check(cause == 8'h10 && bytes_ok,
       "idle IRQ: the next DMA TI transfers new data and raises its own completion");
 finish_command(sts);
end
