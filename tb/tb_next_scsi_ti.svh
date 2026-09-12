// Included in tb_next_scsi's main stimulus. Exercise TI through the real
// register interface, target and RAM/SD models, without forcing DUT state.

// PIO DATA OUT ignores both the DMA routing bit and the transfer counter.
// Stop after four bytes first: an IRQ alone cannot satisfy this check.
select_atn6(8'h0A, 0, 0, 4, 2, 0);
wait_irq; read_intr(intr);
esp_wr8(6'h00, 8'h55); esp_wr8(6'h01, 8'h12);
esp_wr8(6'h03, 8'h80); // DMA NOP loads a sentinel counter.
for (ti_i = 0; ti_i < 4; ti_i = ti_i + 1)
	esp_wr8(6'h02, 8'hA0 + 8'(ti_i));
esp_wr8(6'h03, 8'h10);
wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.fifoflags == 0 && dut.buf_pos == 4 &&
      dut.dbuf[0] == 8'hA0 && dut.dbuf[3] == 8'hA3 && dut.counter == 17'h1255,
      "PIO data out consumes four bytes before BS and preserves the counter");
ti_ok = 1;
for (ti_i = 4; ti_i < 1024; ti_i = ti_i + 12) begin
	for (ti_j = 0; ti_j < 12; ti_j = ti_j + 1)
		esp_wr8(6'h02, 8'(ti_i + ti_j));
	esp_wr8(6'h03, 8'h10);
	wait_irq; read_intr(intr);
	if (intr != 8'h10) ti_ok = 0;
end
// 4 + 85*12 = 1024, including a FIFO burst crossing the sector boundary.
for (ti_i = 0; ti_i < 1024; ti_i = ti_i + 1)
	if (disk[4*512 + ti_i] !== (ti_i < 4 ? 8'hA0 + 8'(ti_i) : 8'(ti_i))) ti_ok = 0;
check(ti_ok && dut.phase == 3 && dut.counter == 17'h1255,
      "two-sector PIO write is byte exact across a sector-spanning FIFO burst");
finish_command(sts);
check(sts == 0, "PIO write finishes with GOOD status");

// Stop at a target phase change even when the FIFO still has output bytes.
select_atn6(8'h0A, 0, 0, 6, 1, 0);
wait_irq; read_intr(intr);
for (ti_i = 0; ti_i < 508; ti_i = ti_i + 4) begin
	for (ti_j = 0; ti_j < 4; ti_j = ti_j + 1) esp_wr8(6'h02, 8'(ti_i + ti_j));
	esp_wr8(6'h03, 8'h10); wait_irq; read_intr(intr);
end
for (ti_i = 0; ti_i < 16; ti_i = ti_i + 1) esp_wr8(6'h02, 8'(508 + ti_i));
esp_wr8(6'h03, 8'h10); wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.phase == 3 && dut.fifoflags == 12 &&
      disk[6*512 + 511] == 8'hFF,
      "PIO output phase change retains the twelve unsent FIFO bytes");
esp_wr8(6'h03, 8'h01); // discard the unsent bytes before reading status
finish_command(sts);

// Selection supplies IDENTIFY only. Supply the CDB in two PIO TIs.
esp_wr8(6'h02, 8'h80); esp_wr8(6'h04, 0); esp_wr8(6'h03, 8'h42);
wait_irq; read_intr(intr);
check(dut.phase == 2 && dut.cdb_n == 0, "short selection waits for CDB bytes");
for (ti_i = 0; ti_i < 3; ti_i = ti_i + 1) esp_wr8(6'h02, 0);
esp_wr8(6'h03, 8'h10); wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.phase == 2 && dut.cdb_n == 3,
      "partial PIO CDB remains in command phase without premature dispatch");
for (ti_i = 0; ti_i < 3; ti_i = ti_i + 1) esp_wr8(6'h02, 0);
esp_wr8(6'h03, 8'h10); wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.phase == 3 && dut.cdb_n == 6,
      "second PIO CDB fragment dispatches TEST UNIT READY and reports BS");
finish_command(sts);
check(sts == 0, "split PIO CDB executes successfully");

// DMA command bytes sourced from the FIFO: count exhaustion retains bytes
// for the next TI and must not dispatch an incomplete CDB.
esp_wr8(6'h20, 8'h20);
esp_wr8(6'h02, 8'h80); esp_wr8(6'h03, 8'h42); wait_irq; read_intr(intr);
for (ti_i = 0; ti_i < 6; ti_i = ti_i + 1) esp_wr8(6'h02, 0);
esp_wr8(6'h00, 3); esp_wr8(6'h01, 0); esp_wr8(6'h03, 8'h90);
wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.counter == 0 && dut.status[4] &&
      dut.phase == 2 && dut.cdb_n == 3 && dut.fifoflags == 3,
      "FIFO DMA command stops at TC with the remaining CDB bytes retained");
esp_wr8(6'h03, 8'h90); wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.counter == 0 && dut.phase == 3 && dut.fifoflags == 0,
      "second FIFO DMA TI completes the CDB");
finish_command(sts);

// External-DMA CDB: ten READ CAPACITY bytes, but TC permits sixteen.
// The target changes phase at byte ten, leaving six DMA-buffer bytes.
esp_wr8(6'h20, 8'h30);
esp_wr8(6'h02, 8'h80); esp_wr8(6'h03, 8'h42); wait_irq; read_intr(intr);
ram[BUF >> 2] = 32'h25000000;
ram[(BUF >> 2) + 1] = 0;
ram[(BUF >> 2) + 2] = 32'h0000AABB;
ram[(BUF >> 2) + 3] = 32'hCCDDEEFF;
csr_cmd(8'h30); ini_wr32(BUF); ptr_wr32(6'h14, BUF + 16); csr_cmd(8'h01);
esp_wr8(6'h21, 0);
esp_wr8(6'h00, 16); esp_wr8(6'h01, 0); esp_wr8(6'h03, 8'h90);
wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.phase == 1 && dut.counter == 6 && !dut.status[4] &&
      dut.cdb_n == 10 && dut.dma_buf_size == 6 && dut.d_next == BUF + 16,
      "memory DMA CDB dispatches at its length and retains the residual bytes");
check(int_scsi_dma && dut.dma_status[7:6] == 2'b01,
      "memory DMA CDB signals its channel limit and one buffer handoff");
csr_cmd(8'h30);
ti_ok = 1;
for (ti_i = 0; ti_i < 8; ti_i = ti_i + 1) begin
	esp_wr8(6'h03, 8'h10); wait_irq; read_intr(intr); esp_rd8(6'h02, v);
	if (intr != 8'h10 || v != (ti_i == 3 ? 8'(DISK_BLOCKS-1) : ti_i == 6 ? 8'd2 : 8'd0)) ti_ok = 0;
end
check(ti_ok, "memory DMA CDB returned the correct READ CAPACITY data");
finish_command(sts);

// SELECT ATN AND STOP makes message-out available to TI through registers.
esp_wr8(6'h02, 8'h80); esp_wr8(6'h03, 8'h43); wait_irq; read_intr(intr);
check(intr == 8'h18 && dut.phase == 6 && dut.cdb_n == 0,
      "select ATN and stop leaves message out for subsequent TI");
esp_wr8(6'h02, 8'h08); esp_wr8(6'h02, 8'h08);
esp_wr8(6'h03, 8'h10); wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.phase == 2 && dut.fifoflags == 0,
      "PIO message out consumes both NOP bytes before changing to command phase");
for (ti_i = 0; ti_i < 6; ti_i = ti_i + 1) esp_wr8(6'h02, 0);
esp_wr8(6'h03, 8'h10); wait_irq; read_intr(intr);
finish_command(sts);

// Extended negotiation message split across FIFO DMA and memory DMA.
// The asynchronous target rejects it only after receiving all five bytes.
esp_wr8(6'h02, 8'h80); esp_wr8(6'h03, 8'h43); wait_irq; read_intr(intr);
esp_wr8(6'h20, 8'h20);
esp_wr8(6'h02, 8'h01); esp_wr8(6'h02, 8'h03);
esp_wr8(6'h00, 2); esp_wr8(6'h01, 0); esp_wr8(6'h03, 8'h90);
wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.phase == 6 && dut.msg_left == 3 && dut.fifoflags == 0,
      "split extended message retains its outstanding payload length");
ram[BUF >> 2] = 32'h011900EE;
csr_cmd(8'h30); ini_wr32(BUF); ptr_wr32(6'h14, BUF + 16); csr_cmd(8'h01);
esp_wr8(6'h20, 8'h30);
esp_wr8(6'h00, 3); esp_wr8(6'h03, 8'h90); wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.counter == 0 && dut.phase == 7 && dut.msg_left == 0,
      "memory DMA completes the extended message before target MESSAGE REJECT");
csr_cmd(8'h30);
esp_wr8(6'h03, 8'h10); wait_irq; read_intr(intr); esp_rd8(6'h02, v);
check(intr == 8'h08 && v == 8'h07, "message-in TI returns MESSAGE REJECT with FC");
esp_wr8(6'h03, 8'h12); wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.phase == 2 && dut.cmd_busy,
      "accepting MESSAGE REJECT resumes the connected command phase");
for (ti_i = 0; ti_i < 6; ti_i = ti_i + 1) esp_wr8(6'h02, 0);
esp_wr8(6'h03, 8'h10); wait_irq; read_intr(intr); finish_command(sts);

// DMA status and message input must capture bytes and decrement TC.
// Verify the NeXT partial-buffer/FLUSH contract with a nonzero status.
select_atn6(8'hFF, 0, 0, 0, 0, 0); wait_irq; read_intr(intr);
ram[BUF >> 2] = 32'hDEADBEEF; ram[(BUF >> 2) + 1] = 32'hDEADBEEF;
ram[(BUF >> 2) + 2] = 32'hCAFEBABE;
csr_cmd(8'h30); ini_wr32(BUF); ptr_wr32(6'h14, BUF + 16); csr_cmd(8'h05);
esp_wr8(6'h00, 16); esp_wr8(6'h01, 0); esp_wr8(6'h03, 8'h90);
wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.counter == 15 && dut.phase == 7 &&
      dut.dma_buf_size == 1 && dut.dma_buf[dut.dma_buf_head] == 2,
      "DMA status delivers CHECK CONDITION and preserves the residual count");
esp_wr8(6'h20, 8'h34); repeat (100) @(posedge clk);
check(ram[BUF >> 2] == 32'h02000000 && dut.d_next == BUF + 4,
      "DMA status FLUSH writes the actual status byte to memory");
esp_wr8(6'h20, 8'h30);
esp_wr8(6'h00, 1); esp_wr8(6'h03, 8'h90); wait_irq; read_intr(intr);
check(intr == 8'h08 && dut.counter == 0 && dut.status[4] && dut.mi_held,
      "DMA message input reports FC and TC and holds for MESSAGE ACCEPTED");
esp_wr8(6'h20, 8'h34); repeat (100) @(posedge clk);
check(ram[(BUF >> 2) + 1] == 0 && ram[(BUF >> 2) + 2] == 32'hCAFEBABE,
      "DMA message FLUSH writes its byte without an extra memory transfer");
esp_wr8(6'h20, 8'h30);
esp_wr8(6'h03, 8'h12); wait_irq; read_intr(intr);
check(intr == 8'h20, "DMA completion message acceptance disconnects");
csr_cmd(8'h30);

// FIFO-routed DMA status/message: DMA TC still counts each received byte,
// although the external channel is not the route in use.
esp_wr8(6'h20, 8'h20);
select_atn6(0, 0, 0, 0, 0, 0); wait_irq; read_intr(intr);
esp_wr8(6'h00, 1); esp_wr8(6'h01, 0); esp_wr8(6'h03, 8'h90);
wait_irq; read_intr(intr); esp_rd8(6'h02, v);
check(intr == 8'h10 && v == 0 && dut.counter == 0 && dut.status[4],
      "FIFO DMA status returns its byte with BS and terminal count");
esp_wr8(6'h03, 8'h90); wait_irq; read_intr(intr); esp_rd8(6'h02, v);
check(intr == 8'h08 && v == 0 && dut.counter == 0 && dut.mi_held,
      "FIFO DMA message returns its byte with FC and terminal count");
esp_wr8(6'h03, 8'h12); wait_irq; read_intr(intr);
esp_wr8(6'h20, 8'h30);

// A full DMA buffer at the channel limit must drain before a pending
// status byte is received. The limit interrupt belongs to DMA, not to
// the still-pending ESP TI command.
select_atn6(8'h12, 0, 0, 0, 16, 0); wait_irq; read_intr(intr);
csr_cmd(8'h30); ini_wr32(BUF); ptr_wr32(6'h14, BUF); csr_cmd(8'h05);
esp_wr8(6'h00, 16); esp_wr8(6'h01, 0); esp_wr8(6'h03, 8'h90);
wait_irq; read_intr(intr);
check(dut.dma_buf_size == 16 && !dut.d_csr[0] && dut.phase == 3,
      "status boundary setup retains the full data buffer at the channel limit");
csr_cmd(8'h0D); // clear DMA completion and enable the still-empty window
esp_wr8(6'h00, 1); esp_wr8(6'h03, 8'h90);
repeat (1500) @(posedge clk);
check(!int_scsi && int_scsi_dma && dut.counter == 1 && dut.phase == 3 &&
      dut.dma_buf_size == 16,
      "DMA window exhaustion cannot complete a TI before receiving its status byte");
ptr_wr32(6'h14, BUF + 32); csr_cmd(8'h0D);
wait_irq; read_intr(intr);
check(intr == 8'h10 && dut.counter == 0 && dut.phase == 7 &&
      ram[BUF >> 2] == 32'h00000101 && dut.d_next == BUF + 16 && dut.dma_buf_size == 1,
      "rearming DMA drains old data then receives exactly one status byte");
esp_wr8(6'h20, 8'h34); repeat (100) @(posedge clk);
check(ram[(BUF >> 2) + 4] == 0 && dut.d_next == BUF + 20,
      "status after a full-buffer restart flushes to the correct address");
esp_wr8(6'h20, 8'h30);
esp_wr8(6'h03, 8'h10); wait_irq; read_intr(intr); esp_rd8(6'h02, v);
esp_wr8(6'h03, 8'h12); wait_irq; read_intr(intr);
csr_cmd(8'h30);

// TC is visible before the delayed IRQ. A driver may FLUSH after polling
// TC; draining the buffer must preserve that still-pending ESP interrupt.
for (ti_i = 0; ti_i < 3; ti_i = ti_i + 1) begin
	esp_wr8(6'h20, 8'h30);
	select_atn6(0, 0, 0, 0, 0, 0); wait_irq; read_intr(intr);
	csr_cmd(8'h30); ini_wr32(BUF + (ti_i ? 12 : 0));
	ptr_wr32(6'h14, BUF + 16); csr_cmd(8'h05);
	esp_wr8(6'h00, 1); esp_wr8(6'h01, 0); esp_wr8(6'h03, 8'h90);
	v = 0;
	for (ti_j = 0; ti_j < 1000 && !v[4]; ti_j = ti_j + 1) esp_rd8(6'h04, v);
	check(v[4] && !v[7], "DMA status exposes terminal count before its delayed interrupt");
	if (ti_i == 2) begin
		// Align a real bus write with the IRQ expiry edge, then service
		// the IRQ while the memory transaction is deliberately stalled.
		@(negedge clk);
		while (dut.dly_us != 0) @(negedge clk);
		hold_m_ack = 1;
		sel_esp = 1; addr = 6'h20; be = 2'b10; we = 1; wdata = 16'h3400;
		@(negedge clk); sel_esp = 0; we = 0;
		check(int_scsi && dut.intstatus == 8'h10, "FLUSH on the IRQ expiry edge delivers BS");
		read_intr(intr);
		hold_m_ack = 0;
		repeat (300) @(posedge clk);
		check(!int_scsi && !dut.cmd_inprogress && dut.dma_buf_size == 0,
		      "FLUSH completing after IRQ acknowledgement cannot raise a second IRQ");
	end
	else begin
		esp_wr8(6'h20, 8'h34); repeat (300) @(posedge clk);
		check(int_scsi && dut.intstatus == 8'h10 && dut.dma_buf_size == 0,
		      "FLUSH before ESP IRQ preserves its pending bus-service interrupt");
		if (int_scsi) read_intr(intr);
	end
	esp_wr8(6'h03, 8'h02); repeat (40) @(posedge clk);
	csr_cmd(8'h30);
end
esp_wr8(6'h20, 8'h30);

// Input backpressure: a full FIFO must retain all unread PIO bytes.
select_atn6(8'h12, 0, 0, 0, 32, 0); wait_irq; read_intr(intr);
for (ti_i = 0; ti_i < 16; ti_i = ti_i + 1) begin
	esp_wr8(6'h03, 8'h10); wait_irq; read_intr(intr);
end
esp_wr8(6'h03, 8'h10); repeat (200) @(posedge clk);
check(!int_scsi && dut.fifoflags == 16 && dut.buf_pos == 16,
      "PIO input waits on a full FIFO without consuming or overwriting a byte");
esp_rd8(6'h02, v); wait_irq; read_intr(intr);
check(intr == 8'h10 && v == 0 && dut.fifoflags == 16 && dut.buf_pos == 17,
      "FIFO pop permits exactly one pending PIO byte and a valid BS interrupt");
esp_wr8(6'h03, 8'h02); repeat (40) @(posedge clk);
esp_wr8(6'h20, 8'h30);
esp_wr8(6'h03, 8'h10); wait_irq; read_intr(intr);
check(intr == 8'h40, "TI while disconnected reports an illegal command");
