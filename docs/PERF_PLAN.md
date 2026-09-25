# Speed plan: implementation details (from docs/PERF_PROFILE.md)

Three stages, one commit each, each measured on hardware before the
next. Stage 3 is outlined only; it is specified when 1 and 2 are in.
Rules that apply throughout: `sys/` and the framework macros stay stock;
no CPU/FPU trimming; `ap040_core.v` is untouched (wrapper edits are
allowed, as in docs/CPU_NEXT_PORT.md changes 1-4); every CPU-side change
runs the CPU suite unpaced, `+pace`, `+pace +paceshift`; every RBF goes
through `release.sh` (fit successful, `tb/check_timing.sh` clean, RBF not
newer than the STA summary) before it is pushed to the MiSTer.

Before stage 1: commit the profiling harness as its own commit
(`tb/next_profile_monitor.sv`, the `-DNEXT_PROFILE` / `+ddrlat=` /
`-DNEXT_TB_CLK_HZ` / `-DNEXT_TB_PACE_DEN` hooks in `tb/tb_next_boot.sv`,
`rtl/ap68040/tb/tb_ap040_program.v` `+dbccstall=N`,
`rtl/ap68040/tb/asm/bench_dbf.s`, `tb/hw/`, `docs/PERF_PROFILE.md`, this
file), so the RTL commits stay clean.

Simulation environment: WSL, `PATH=$HOME/local/bin:/home/dani/oss-cad-suite/bin:$PATH`
(Verilator 5.049; the Debian 5.020 fails on `ap040_mmu.v` BLKLOOPINIT),
build in the WSL home (`~/next_prof/src`, rsync of `rtl/` and `tb/`;
`~/next_prof/build_prof.sh` is the profiling build), NS3.3 image copies
in `~/next_prof/*.hda` (the bench writes sectors back). `vasmm68k_mot`
is in `~/local/bin`. Detach long runs with `setsid nohup` inside one
`wsl -e sh -c`. A `+bootsd` boot runs ~0.4M clocks/s; POST passes near
500M clocks, kernel entry near 700M, the memory-heavy kernel work from
~1,000M.

---------------------------------------------------------------------------

## Stage 1: DBcc period floor replaces CPU_PACE

### What and why

The Quadra-tree core runs the ROM's calibrated `dbf d0,*` loop
(`$010024F0`, `delay()` at `$010024CC`, `(n-3)*6.25` iterations) in 2
clocks per iteration through its DBcc fast path; the ROM assumes a real
68040's 4 (6.25 iterations/us at 25 MHz). `CPU_PACE` 1/2 fixes that by
halving the whole CPU. Previous fixes it by charging DBcc 4 cycles and
nothing else (`src/cpu/gencpu.c` `adjust_cycles`, `i_DBcc: cycles = 4`).
This stage does the same from the host: consecutive executions of DBcc
are kept at least 4 enabled clocks apart, and no other clock is gated.

Measured (`rtl/ap68040/tb/asm/bench_dbf.s`, `+dbccstall=2`): aligned bare
`dbf` 2.0 -> 4.0 clocks/iteration; memcpy-shaped loop 16.2 -> 16.2;
cmp/bne loop 7.0 -> 7.0 (CPU_PACE 1/2 gives 4.0 / 28.4 / 14.0). In the
kernel profile `S_DBCC1` is < 0.5% of clocks.

### Where

`rtl/next/next_system.sv`:

- Today (line ~237):
  ```
  reg [$clog2(CPU_PACE_DEN)-1:0] pace_acc = 0;
  wire pace = pace_acc < CPU_PACE_NUM;
  always @(posedge clk) pace_acc <= (pace_acc == CPU_PACE_DEN-1) ? 1'd0 : pace_acc + 1'd1;
  wire clkena = ((busstate == 2'b01) & pace) | mem_ready | berr_hold;
  ```
- The core's state is already in the host: `wire [255:0] debug_status`
  (the wrapper's `debug_status` output; `dbg_pc = debug_status[31:0]`).
  `debug_status[231:224]` is `ap040_core.state`; `S_DBCC1 = 8'd53`
  (`rtl/ap68040/rtl/ap040_core.v` line ~446; **re-check the value on
  every CPU drop**, add it to the CPU_NEXT_PORT.md checklist). The taken
  `dbf` self-loop visits `S_DBCC1` exactly once per iteration (the
  bench's `+dbccstall` counts entries and adds exactly N per iteration).

### Design

```
parameter DBCC_FLOOR = 4;          // enabled clocks between DBcc executions; 0 = off
// keep CPU_PACE_NUM/DEN with defaults 1/1 so the old 1/2 pacing stays selectable

wire       in_dbcc = (debug_status[231:224] == 8'd53);
reg        dbcc_prev;              // in_dbcc last clock
reg  [2:0] dbcc_since;             // enabled clocks since the last S_DBCC1 entry, saturating at DBCC_FLOOR
reg  [2:0] dbcc_left;              // stall clocks still owed
wire       dbcc_entry = in_dbcc & ~dbcc_prev;
wire       dbcc_stall = (dbcc_left != 0);

always @(posedge clk) begin
    dbcc_prev <= in_dbcc;
    if (dbcc_entry) begin
        dbcc_left  <= (dbcc_since < DBCC_FLOOR) ? DBCC_FLOOR - dbcc_since : 3'd0;
        dbcc_since <= 3'd0;
    end
    else begin
        if (dbcc_left != 0) dbcc_left <= dbcc_left - 1'd1;
        if (clkena && dbcc_since != DBCC_FLOOR) dbcc_since <= dbcc_since + 1'd1;
    end
end

wire clkena = ((busstate == 2'b01) & pace & ~dbcc_stall) | mem_ready | berr_hold;
```

Points to get right (the bench decides the off-by-ones):

- `dbcc_since` counts ENABLED clocks (`clkena` high), not raw clocks;
  otherwise the stall itself counts toward the next interval and the
  loop settles at 3 clocks, not 4 (period alternating 4, 2).
- The stall gates only idle clocks (`busstate == 01`), like `pace`
  did: a DBcc followed by a bus cycle hides the stall under the bus
  wait. That is why loop B is unaffected. `mem_ready`/`berr_hold` keep
  completing bus cycles as before.
- `dbcc_entry` is detected one clock after the core entered `S_DBCC1`
  (the state register is what `debug_status` shows), so the stall lands
  on the state after it; the count per iteration is what matters and
  `bench_dbf` must read 4.0 for loop A.
- Reset: `dbcc_left = 0`, `dbcc_since = DBCC_FLOOR` (no stall on the
  first DBcc).
- ~15 ALMs. Nothing else in `next_system` changes; `CLK_HZ` stays 25 MHz
  (guest clock 1.12x real, as today). Do not change `CLK_HZ` to 28 MHz
  in this stage: a floor of 4 reads delay(1000) = 890 us there, below
  the ROM's 899 us limit.

`NeXT.sv`: `.CPU_PACE_NUM(1), .CPU_PACE_DEN(1)` (or drop the two), add
`.DBCC_FLOOR(4)`, replace the calibration comment above the
`next_system` instance: the invariant becomes
`(CLK_HZ / 1e6) = 6.25 * DBCC_FLOOR` -> 25 MHz.

`tb/tb_next_boot.sv`: same parameters (the `-DNEXT_TB_PACE_DEN`
override stays for experiments; add `-DNEXT_TB_DBCC_FLOOR`).

`docs/CPU_NEXT_PORT.md`: rewrite the "CPU speed calibration" section
(the invariant, the measurement recipe: `bench_dbf` and `+loopdump`),
add "S_DBCC1 encoding" to the new-drop checklist, update
`rtl/next/next_system.sv`'s header comment (lines 28-46) which still
describes the old 8-clock/50 MHz model.

### Gates (all must pass before the RBF)

1. CPU suite, `rtl/ap68040/tb/run_tests.sh` style (iverilog) or the
   Verilator build in `~/next_prof/src/rtl/ap68040/tb/build/vl_prog`:
   every program unpaced, `+pace`, `+pace +paceshift`, and `+dbccstall=2`.
   The `+dbccstall` leg is the bench-side twin of this stage; if the
   final host logic differs from "stall N on entry", mirror it in the
   bench so the suite exercises the same gate pattern. Directed tests
   that matter: `t_xline`, `t_xline_mmu`, `t_atcprobe`, `t_moves_fc`,
   `t_movem_restart`, `t_fpu_frames`, `t_fpu_resume`, `t_loops_irq`.
2. `bench_dbf.hex` under the real host: not runnable there (it is a CPU
   bench program); instead use the boot bench's `+loopdump`:
   `tb_next_boot +mcycles=600 +loopdump`, take the `LOOP n=1000` and
   `n=100` lines: `(clocks(1000) - clocks(100)) / 5625` must be 4.0
   (it is 2.0 unpaced, 4.0 under CPU_PACE 1/2 today; the old
   `loopdump.log` in `tb/build` has the 1/2 numbers).
3. `tb/run_tests.sh` (device suites + smoke boot) and
   `tb/run_tests.sh post`: "system test passed path"; the POST's
   measured delay(1000) must be in 899..1100 us (expect ~1,007: 1,003
   plus the call overhead that gave 1,015 under 1/2 pacing).
4. `tb_next_boot +bootsd +img=<copy of NS3.3> +mcycles=2400`: kernel
   entry, no berr storms, no halt; ALL PASS.
5. Profiling build (`-DNEXT_PROFILE`, `+ddrlat=6`): kernel phase
   "internal gated" should fall from 26.8% to ~1% (only the DBcc
   stalls), `S_DBCC1` share unchanged.
6. `tb/run_next_fpsp.sh`, `tb/run_fpu_revision_tests.sh` unchanged.
7. Quartus: `NEXT_FIT_QUADRA=1 quartus_sh --flow compile NeXT`
   (`NEXT_SEED=<n>` if it does not route), `release.sh` gate (it checks
   `output_files/NeXT.fit.summary` "Successful", the STA summary newer
   than the RBF, `tb/check_timing.sh` clean; a failed fit leaves the OLD
   RBF in `output_files`, so compare md5 with the last pushed RBF too).
   Deploy: `scp -i ~/.ssh/mister_only releases/NeXT_<date>.rbf
   root@192.168.99.143:/media/fat/_Unstable/`, shut the guest down first
   (root shell: `halt`, or Log Out -> Power Off; never load a core over a
   running guest with a writable disk), then
   `ssh ... 'echo "load_core /media/fat/_Unstable/NeXT_<date>.rbf" > /dev/MiSTer_cmd'`
   (builds since the SC-slot commit remember the disk mount; older ones
   need the MGL in /tmp/next0914.mgl). At the `NeXT>` prompt type `bsd`,
   Ctrl-C at "No response from network configuration server", log in
   root, blank password. Screenshots: `POST http://192.168.99.143:8182/api/screenshots`,
   newest file under `/media/fat/screenshots/NeXT/`. Keyboard/mouse:
   `tb/hw/type_text.py`, `tb/hw/guest_click.py`.
8. Hardware: POST passes (it is the ROM's own delay check), `bsd` boots
   to the login window, NWBench "Run All" (about 30 min real). Expected:
   Dhrystone guest score ~2x (4,286 -> ~8,000-8,500 at the same 1.12x
   guest clock), Compile/Webster times -20-25%, Disk unchanged or
   slightly better. Record the run in docs/PERF_PROFILE.md.

### Risks

- ce-gating hazards (memory `ap68040-ce-gating-hazards`): the tree is
  validated under 1/2 gating; this is a sparser, data-dependent pattern.
  Bug 5 only showed on hardware, so the hardware boot is part of the
  gate, not a formality. If anything only fails with the floor on,
  compare against `+pace`: the fixed bugs all had the shape "RAM address
  or read-enable derived combinationally from a RAM output, advancing on
  the un-enabled clock".
- A future CPU drop with a different `S_DBCC1` encoding silently
  disables the floor; the POST then fails at the timer test, which is
  loud. The checklist entry covers it.

---------------------------------------------------------------------------

## Stage 2: retain the DDR line in next_ddram

### What and why

Every 16-byte line fill is eight 16-bit sub-cycles, each a full DDR3
round trip (`ram_req -> ram_ack` 11 clocks at the hardware latency of
~6-7, plus ~4.4 clocks of adapter gap/decode): 123 clocks in the bench,
130-145 on hardware, 39% of all kernel clocks. Fetching the whole
aligned 16-byte line in one DDRAM burst and serving the other seven
sub-cycles (and the second half of every longword) from a retained copy
takes the round trips out of them: fill ~123 -> ~60 clocks.

### Where

`rtl/next/next_ddram.sv` (91 lines today) and one fix in
`rtl/next/next_ddram_arb.sv`. Interfaces do not change.

Current mapping, keep it: DDRAM byte base 0x30000000 -> `DDRAM_ADDR =
{5'b00110, 1'b0, ram_addr[23:1]}` (64-bit word address), `half =
ram_addr[0]` selects `DDRAM_DOUT[63:32]` (half 1) or `[31:0]` (half 0),
`bswap` each 32-bit half (68k big-endian words in little-endian DDR),
byte enables `ram_addr[0] ? {be_rev, 4'b0} : {4'b0, be_rev}` with
`be_rev = {ram_be[0], ram_be[1], ram_be[2], ram_be[3]}`.

### Design

State: `line[127:0]` (ram word k = ram_addr[1:0] lives at
`line[127-32k -: 32]`, i.e. word 0 in [127:96], the same order
`ap040_cache` uses for its `m_line_data`, which stage 3 will feed),
`line_tag[21:0] = ram_addr[23:2]`, `line_valid`.

Read, miss (`!line_valid || line_tag != ram_addr[23:2]`):
- `DDRAM_ADDR = {5'b00110, 1'b0, ram_addr[23:2], 1'b0}` (the aligned
  16-byte line), `DDRAM_BURSTCNT = 2`, `DDRAM_RD` one clock while
  `!DDRAM_BUSY`, `DDRAM_BE = 8'hFF`.
- Two `DDRAM_DOUT_READY` beats, consecutive or not (the arbiter and the
  bench model may split them): beat 0 -> words 0 (`[31:0]` swapped) and
  1 (`[63:32]` swapped), beat 1 -> words 2 and 3. Count beats; set
  `line_valid`, `line_tag` when the second lands.
- Acknowledge the requested word as soon as ITS beat has landed (word
  0/1 after beat 0, word 2/3 after beat 1) so a miss on words 0/1 costs
  what it costs today plus nothing, and words 2/3 one extra clock. The
  cache asks for the requested word first and then wraps
  (`r_beat = addr[3:2]`), so the second and later requests of a fill hit
  the retained line whichever word started it.
- `busy` stays high until beat 2 has landed even if the ack went out
  after beat 1: no new request may start until the burst is complete.

Read, hit (`line_valid && line_tag == ram_addr[23:2]`): `ram_dout <=
line word`, `ram_ack <= 1` the next clock. No DDR traffic. (Latency
`ram_req -> ram_ack` 1-2 clocks; the profile's "ram CPU latency hist"
should show the 11-clock peak shrink and a 2-clock peak appear.)

Write: unchanged single-beat DDR write (`ram_ack` on acceptance). In the
same clock, if `line_valid && line_tag == ram_addr[23:2]`, update the
retained word under the byte enables (`ram_be[3]` = byte 0 of the word =
`ram_din[31:24]`). Updating instead of invalidating keeps the line
useful across the write-through stores of a stack frame. Every writer
(CPU, table walker, all six DMA channels) reaches memory through this
one `ram_*` port, so this is the whole coherence story; the ethernet
mailbox on arbiter port B lives at byte 0x1FF00000, outside the RAM
window, and never touches the line.

Reset: `line_valid <= 0`.

`next_ddram_arb.sv`: `a_read_pending` is cleared by the FIRST
`DDRAM_DOUT_READY` (`if (DDRAM_DOUT_READY) a_read_pending <= 0`), so port
B could take the bus between the two beats of a burst and the second
beat would be attributed wrongly. Count the beats: capture `a_burst` on
acceptance and clear `a_read_pending` on the last beat. `a_dout_ready`
gating (`& !b_owns`) stays.

Size: 128 + 22 + 1 flops and a 4:1 word mux plus the beat counter:
~150-250 ALMs. At 94% this is the first change that could fail to route;
`NEXT_FIT_QUADRA=1` with a seed walk is the recipe. If it will not fit,
the next candidate for area is `next_scsi` (2,299 ALMs) / `next_mo` +
`next_rs` (2,205), not the CPU.

### Bench model

`tb/tb_next_boot.sv` DDR3 model already honours `dr_burst` (`d3_left <=
dr_burst`, beats back to back after `d3_lat`, random BUSY) and advances
`d3_addr` by one 64-bit word per beat (`d3_addr <= d3_addr + 1'd1` in
the read-return branch), so a 2-beat burst returns the two halves of the
16-byte line in order without a model change. `ram_mem` is indexed by
32-bit word `{dr_addr[22:0], half}`.

### Gates

1. `tb/tb_next_ddram_arb.sv`: add cases: (a) port A burst of 2 with a
   port B request arriving between the beats: B must wait, both A beats
   must reach A; (b) BUSY asserted between the beats; (c) A write while B
   waits. Run `tb/run_tests.sh` (builds and runs it).
2. A directed `next_ddram` test (new, `tb/tb_next_ddram.sv`, add to
   `run_tests.sh`): miss on word 2 then hits on 3, 0, 1 (the wrap order);
   byte-enable write into the retained line then a read of it (each of
   the 16 masks); a write to another line does not disturb the retained
   one; a DMA-style write (same port) to the retained line is seen by
   the next read; reset clears the line; a read straddling a line
   boundary is two separate requests (the port is per 32-bit word, so
   this cannot happen, assert it anyway).
3. `tb/run_tests.sh` default and `post` (the POST's memory test is a
   heavy user of this path: 38M writes, `C_PASS` 51%).
4. `+bootsd` boot to 2,400M clocks, ALL PASS, and the `-DNEXT_PROFILE`
   `+ddrlat=6` profile: kernel-phase "cache fills avg" from 123 to ~60
   clocks, "ram wait" share from 33% to ~15%, ram CPU latency histogram
   with a 2-clock peak. Also `+ddrlat=12` (fills ~85) to see the
   sensitivity.
5. `run_next_fpsp.sh` / `run_fpu_revision_tests.sh` unchanged (they run
   through RAM).
6. Quartus with `NEXT_FIT_QUADRA=1`, `release.sh`, then hardware:
   POST (its memory tests are 64 MB of uncached traffic through this
   path), `bsd`, NWBench. Re-run `tb/hw/memlat.c` in the guest
   (`type_text.py`, see the memory note `next-guest-remote-control`;
   guest us = 25 clocks on this build): stride-16 read should drop from
   ~165 to ~90-100 clocks per access; W4 unchanged. Expected NWBench:
   Compile/Webster another -15-25%, Dhrystone flat.

### Optional stage 2b (cheap, after 2 is on hardware): the cache line sideband

`ap040_cache` has `m_line_valid / m_line_tag[31:4] / m_line_data[127:0]`:
during a fill (`C_FILL`, `!r_issued`), if `m_line_valid && m_line_tag ==
r_addr[31:4]` it takes the remaining words from `m_line_data` without a
bus transaction (`fill_line_match`, `fill_line_word`). The wrapper
(`ap040_tg68k_compat.v`) ties them to 0. Expose them as wrapper inputs
(`cache_line_valid/tag/data`, exactly as `wombat_cpu.sv` in the Quadra
does, which also gates valid with `!buffered_store_pending`; with
`POST_STORES=0` there is no such thing here) and drive them from
`next_ddram`'s retained line, translated through the host:

- tag: the CPU's PHYSICAL address of the line, i.e. `cpu_addr[31:4]` at
  the time of the fill, not `ram_addr`: the MWF mirrors at 0x10-0x1F map
  to the same RAM and the cache compares against the address it asked
  for. Simplest: `next_system` latches `cpu_addr[31:4]` when it issues a
  CPU RAM read and presents `{that, line_valid && (ram_addr line == the
  latched line)}`.
- data: the retained line, word 0 in [127:96] (already that order).
- valid must drop the clock a write lands in the line (a store from the
  same CPU is write-through and also updates the cache's own copy, but a
  DMA write must not be copied stale; the snoop invalidates the cache's
  set on `dma_snoop_stb`, and the sideband must not re-validate it in
  the same fill: hold `valid` low for the fill after any DMA write to
  the line).

Gain: the fill becomes one 16-bit-bus beat (two sub-cycles, ~31
clocks) plus 3 local copies: ~35 clocks, fills 39% -> ~11% of kernel
clocks. Gate: the paced CPU suite (`fill_line_match` has never run
under a gated ce; the DBcc floor makes gating rare but not absent) with
a bench that supplies `m_line_valid` (the CPU bench has no line
provider today; add one to `tb_ap040_program.v` behind a plusarg), then
the same boot/post/profile/hardware sequence.

---------------------------------------------------------------------------

## Stage 3 (outline): 32-bit host bus, Quadra style

Replace `ap040_bus16_adapter` (130 ALMs) with the Quadra's beat shape
(`MacQuadra800_MiSTer/rtl/wombat_bus32.sv`: aligned longword beats with
byte enables, `b_req` level-held per beat, `b_ack` one-clock pulse,
`b_be[3]` = byte at addr+0 = `b_wdata[31:24]`, `t_berr` aborts), driven
from the cache's `m_*` port the way `wombat_cpu.sv` does, and rewrite
`next_system`'s bus FSM for 32-bit beats:

- RAM: one `ram_*` transaction per beat (the port is already 32-bit with
  byte enables) -> half the transactions of today for every RAM access.
- Devices, ROM, VRAM, BMAP are 16-bit (`io_rdata`, `rom_q`, `vram_q`,
  `bmap_rdata`, the `lanes`/`nuds`/`nlds` decode in every `next_*`
  register file): keep them 16-bit behind a shim in `next_system` that
  turns a beat with `be[3:2]` and/or `be[1:0]` into one or two
  sequential 16-bit internal cycles (`S_INT` twice). Device semantics
  that depend on access width (the ESP FIFO, the SCC, KMS data port)
  need each 16-bit half presented as its own access exactly as today.
- DMA snoop (`dma_snoop_addr`), `walker_*` (already 32-bit), the
  `berr` path (`d_any`), `POST_STORES` window: unchanged in meaning.
- Together with 2b the fill is one beat (~16 clocks) plus 3 copies.

Fit: net +100-200 ALMs. Gates: the whole list of stage 2 plus every
device bench in `tb/run_tests.sh` (they drive the 16-bit register
ports directly, so they will not see the shim; the boot benches do),
`tb/run_audio_audit.sh`, and the hardware SCSI/floppy/ethernet/sound
paths. This stage is specified in full only after stages 1 and 2 are
measured on hardware.

---------------------------------------------------------------------------

## Later

- `POST_STORES(1)` on hardware (0 ALMs; profile says -3-5% in the
  bench, more on hardware where a write half costs 15 clocks).
- Clock 28 -> 30 MHz (Fmax 31.14 MHz in the 2026-09-24 compile) with
  `DBCC_FLOOR` 5 and `CLK_HZ` 30 MHz: delay(1000) = 1,038 us and the
  guest clock becomes real time (`CLK_REAL_HZ`, the audio ADC
  `CLK_REAL_HZ`, `next_enet_bridge` `CLK_HZ` move with it).
- OSD "CPU speed" option (status bits 60-120 are free) if a calibrated
  1/2-paced mode is wanted for comparison.
- The disk test's 10% real-time loss on the Quadra-CPU build: needs a
  hardware trace of the `hps_io` handshake / `next_scsi` timing; the
  bench's SD model answers instantly.
