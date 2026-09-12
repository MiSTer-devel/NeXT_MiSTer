// NeXTSTEP can read ENABLE|COMPLETE, then lose the next segment while it
// is programming START/STOP. CLRCOMPLETE must leave the stopped channel's
// completion visible so dma_intr's post-write CSR check can restart it.
begin : dma_refill_race
 integer n, b;
 reg [31:0] before_csr, after_csr;
 reg [7:0] cause;
 reg exact;

 esp_wr8(6'h03,8'h02); csr_cmd(8'h30); esp_wr8(6'h20,8'h20);
 // Shape from the September 11 capture: 7920 + 256 bytes followed by
 // a 48-byte bounce window, of which the ESP needs only the first 16.
 for(b=0;b<7920;b=b+1) ram_put(32'h2110+32'(b),8'(b)^8'h69);
 for(b=0;b<256;b=b+1) ram_put(32'h6000+32'(b),8'(7920+b)^8'h69);
 for(b=0;b<48;b=b+1) ram_put(32'h8000+32'(b),8'(8176+b)^8'h69);
 k_seg_start[0]=32'h2110; k_seg_end[0]=32'h4000;
 k_seg_start[1]=32'h6000; k_seg_end[1]=32'h6100;
 k_nseg=2;
 select_atn10_target(0,8'h2a,0,0,0,0,8,0,0,16,0);
 wait_irq; read_intr(cause);
 k_dma_start;
 esp_wr8(6'h00,0); esp_wr8(6'h01,8'h20);
 esp_wr8(6'h03,0); esp_wr8(6'h03,8'h90); esp_wr8(6'h20,8'h30);
 n=0;
 while(!int_scsi_dma && n<300000) begin @(posedge clk); n=n+1; end
 csr_rd32(before_csr);
 before_csr=before_csr & 32'h0b000000; // the 0x139 driver's status mask
 check(before_csr == 32'h09000000,
       "DMA CSR race: handler reads a running chained completion");
 // Interrupt latency BEFORE that read is covered elsewhere. This wait
 // models the CPU work AFTER the read, which the old regression omitted.
 n=0;
 while(dut.d_csr[0] && n<300000) begin @(posedge clk); n=n+1; end
 repeat(50) @(posedge clk);
 check(dut.counter == 16 && dut.d_next == 32'h6100 && int_scsi_dma,
       "DMA CSR race: second window runs out while handler prepares the tail");
 ptr_wr32(6'h18,32'h8000); ptr_wr32(6'h1c,32'h8030);
 // _dma_intr at 0407ca52..0407cab6 writes SETSUPDATE|CLRCOMPLETE,
 // then rereads the CSR to detect that the channel stopped meanwhile.
 csr_cmd(8'h0a); csr_rd32(after_csr);
 after_csr=after_csr & 32'h0b000000;
 $display("  DMA refill race CSR: before=%08x after=%08x next=%08x residual=%0d",
          before_csr,after_csr,dut.d_next,dut.counter);
 check(after_csr == 32'h0a000000 && int_scsi_dma,
       "DMA CSR race: stopped completion survives stale chaining acknowledgement");
 if(after_csr == 32'h0a000000 && int_scsi_dma) begin
  // The kernel's post-write check takes its restart path for the tail.
  k_seg_start[0]=32'h8000; k_seg_end[0]=32'h8030; k_nseg=1;
  k_dma_start;
  wait_irq; read_intr(cause);
  check(cause == 8'h10 && dut.counter == 0,
        "DMA CSR race: restarting the tail completes the original ESP command");
  exact=1;
  for(b=0;b<8192;b=b+1)
   if(disk[8*512+b] !== (8'(b)^8'h69)) exact=0;
  check(exact,"DMA CSR race: all 8192 write bytes reach the disk exactly");
  csr_cmd(8'h10); finish_command(sts);
 end
 else begin
  // Leave a failed baseline run able to finish and report its assertions.
  esp_wr8(6'h03,8'h02); csr_cmd(8'h30);
 end
end

// A completion produced on the CSR write edge is a new event, even when
// the channel stays enabled by chaining. Acknowledge only the older event.
begin : dma_completion_edge
 integer chain, n, b;
 reg [31:0] saved_csr;
 reg [7:0] cause;
 for(chain=0;chain<2;chain=chain+1) begin
  esp_wr8(6'h03,8'h02); csr_cmd(8'h30); esp_wr8(6'h20,8'h30);
  for(b=0;b<64;b=b+1) ram_put(BUF+32'(b),8'(b));
  select_atn6(8'h0a,0,0,0,1,0); wait_irq; read_intr(cause);
  ini_wr32(BUF); ptr_wr32(6'h14,BUF+16);
  ptr_wr32(6'h18,BUF+32); ptr_wr32(6'h1c,BUF+48);
  csr_cmd(chain ? 8'h03 : 8'h01);
  esp_wr8(6'h00,0); esp_wr8(6'h01,2); esp_wr8(6'h03,8'h90);
  n=0;
  // Observe the natural boundary, without forcing the engine or counter.
  @(negedge clk);
  while(!(dut.xst == dut.X_DO_CHK && dut.d_next == BUF+16 &&
          dut.dma_buf_size == 0 && dut.gap_us == 0) && n<300000) begin
   @(negedge clk); n=n+1;
  end
  check(n<300000,"DMA CSR edge: reached the programmed memory boundary");
  sel_csr=1; addr=0; we=1; be=2'b11; wdata=16'h0008;
  @(negedge clk); sel_csr=0; we=0;
  csr_rd32(saved_csr);
  check((saved_csr & 32'h0b000000) ==
        (chain ? 32'h09000000 : 32'h08000000) && int_scsi_dma,
        "DMA CSR edge: a new completion wins over simultaneous CLRCOMPLETE");
  // Stop this intentionally incomplete write before a sector is committed.
  esp_wr8(6'h03,8'h02); csr_cmd(8'h30);
 end
 // SETENABLE can report a malformed window on the same CSR write too.
 ini_wr32(BUF); ptr_wr32(6'h14,BUF+17); csr_cmd(8'h09);
 csr_rd32(saved_csr);
 check((saved_csr & 32'h1b000000) == 32'h18000000 && int_scsi_dma,
       "DMA CSR edge: CLRCOMPLETE cannot erase a new enable-time bus exception");
 csr_cmd(8'h30);
end
