# Running NeXT on the AP68040 `faster` core

`rtl/ap68040/` is the pipelined AP68040 (`apolkosnik/AP68040` branch
`main`, b388dfc of 2026-10-18; `rtl/ap68040/UPSTREAM.md`).  It presents
the real MC68040 external bus and runs on its own clock, twice the
system clock.  This file lists everything that makes that core drive
`next_system.sv`, so the same can be re-done when a newer drop replaces
the directory.  The previous core (the sequential `ap040_*.v` tree) and
its port are history: `CPU_NEXT_PORT_ap040.md`.

## The pieces

| where | what |
|---|---|
| `rtl/ap68040/rtl/*.sv`, `rtl/fpu/`, `rtl/gen/` | the core as dropped, plus the local changes (below) |
| `rtl/ap68040/rtl/ap68040.qip` | the Quartus file list (`files.qip` and `NeXT.qsf` include it) |
| `rtl/next/next_cpu040.sv` | the 68040 bus slave: beats, interrupt acknowledge, TCI, bus error, DMA write snoops, the bus clock enable |
| `rtl/next/next_system.sv` | instantiates the core on `clk_cpu` and the bridge on `clk`; the `b_*` beat FSM is unchanged |
| `rtl/pll/pll_0002.v`, `rtl/pll.v`, `NeXT.sv` | a third PLL output, 55 MHz, for `clk_cpu`; `clk_sys` 27.5 MHz |
| `NeXT.sdc` | the two clocks' 2:1 timing exceptions |
| `tb/tb_next_boot.sv`, `tb/tb_next_recording.sv`, `tb/run_tests.sh` | two clocks, probes on the new core |

## CPU-side changes (four)

**1. The DBcc period floor.**  `rtl/ap68040.sv`, `rtl/ap68040_backend.sv`: the `dbcc_floor[3:0]` input.
A DBcc that follows a taken DBcc leaves EX no earlier than `dbcc_floor`
processor clocks after it (0 or 1: off).  It is a hold on the EX stage,
keyed on the previous DBcc's real outcome, counted in processor clocks;
it commits nothing and trains nothing (register writes and the
predictors move on `adv_ex` only), a flush clears it, and no other
instruction waits.  `tb/asm/t_dbccfloor.s` (in the core's regression,
bench register `$F10C`, clock count `$F2EC`) measures 999 taken `dbf` at
floors 0, 9 and 4 and checks that a `subq/bne` loop and a never-taken
`dbf` run the same with the floor on.  Upstream-friendly: a core without
a timing-calibrated host ties the input to 0.

**2. The byte-enable RAM's inference.**  `rtl/ap68040_ram.sv`,
`ap68040_sdp_be`: each 32-bit slice is a module of its own
(`ap68040_sdp_be_slice`) with every byte's write spelled out and the read
in the same always block, Intel's byte-enable template to the letter.
As dropped (one always block per byte) Quartus 17.0 made one M10K per
BYTE: 64 blocks for the 4 KB data cache, 16 for the instruction cache's
data and 12 for its tags, 20 percent used each, and the design needed
558 of the device's 553 M10Ks.  Two shapes in between failed in other
ways: the byte writes in a `for` loop infer only while the byte enables
are constant (the instruction cache's) and make 32k flip-flops of the
data cache; the slices of one module assigning part-selects of a shared
read vector likewise.  In the template's shape a slice is one M10K: 16
for the data cache, 4 and 4 for the instruction cache.  Same semantics
(the core regression is unchanged).

**3. The table walk's cache-hit compare.**  `rtl/ap68040_dmu.sv`, one
more wait state (`E_TW_DESCW2`) between addressing the tag RAM's port B
with the descriptor's set and sampling the compare.  The tag RAM
registers its address, so the compare one cycle earlier looked at the
tags of the set addressed BEFORE (the previous descriptor's, or the
pipeline's last data access): a false hit handed the walker another
line's data as the descriptor, a false miss read memory past a dirty
cached descriptor.  Found on the board on 2026-10-19: OPENSTEP 4.2's
kernel, right after "physical memory = 64.00 megabytes", looped at
2,688 access errors per second on a supervisor write to 0x10004494
whose three-level mapping was valid in memory (the RAM dump through the
HPS, `/dev/mem` at 0x30000000, holds the kernel's boot stack with the
format-7 frame, SSW 0x0405, and its page tables); the walker took the
fault handler's own counters, in the same cache set as the pointer
descriptor, for the descriptor.  `tb/asm/t_nx8k.s` reproduces the
kernel's table shape (8 KB pages, supervisor-only copyback transparent
translation, type-10 table descriptors written copyback and never
pushed, fault-fix-flush-retry) and is in the core's regression.  The
upstream suite did not see it: its tables are write-through and its
sets happened not to collide.

**4. A discarded slow-path job under a snoop freeze.**
`rtl/ap68040_dmu.sv`: the engine's kill mark (`e_kill`) is cleared when
the DC2 job is scheduled in `E_IDLE` (where `kill_now` is excluded), no
longer in `E_S_START`'s body.  The engine's case statement is skipped
while the snooper holds the cache (`sn_frz`), the kill block is not: a
kill landing while the engine sat in `E_S_START` frozen by a DMA-write
snoop set the mark, and `E_S_START`'s body, run after the freeze, erased
it.  The dead job (a load on the wrong side of a mispredicted branch,
missing the cache) then filled its line and raised `e_dc2_done`, and the
next memory uop into DC2 was answered at once with the dead job's data.
Found on the board on 2026-10-19 (three OPENSTEP 4.2 panics during disk
DMA, the same shape each time: a kernel pointer read as 0 while memory
held it; the bench reproduced it to the clock, `tb/tb_next_boot.sv
+pwin`), and it is why the first 55 MHz build panicked where the old
core did not: the old core had no speculative memory access to kill.
`tb/asm/t_snkill.s` reproduces it in every bus configuration (a branch
on a pseudo-random bit whose arms load from fresh lines, the bench's
alternate master snooping with a random hold before each transfer; the
bench counts the coincidence in `$F2F0` and the program requires it),
and the DMU checks itself at `E_S_DONE` (a job completing for a
discarded uop without its mark fails the run).

Everything else of the core is as dropped.  `FPU_REVISION` is `8'h40`
(the 44-byte UNIMP frame old non-Turbo Mach expects, `FPU_FRAME_REVISION.md`);
the area options (`FPU_PIPE`, `LOOP_PRED`, `EARLY_RES`, `DC1_ATC`,
`SKID`) are off, `DIV_STEPS` 2.

## Clocks

| clock | rate | PLL output | domain |
|---|---|---|---|
| `clk_cpu` | 55 MHz | `outclk_2` | the core (PCLK) |
| `clk_sys` | 27.5 MHz | `outclk_0` | the bus (BCLK), devices, DDR3 |
| `clk_vid` | 100 MHz | `outclk_1` | pixel clock |

The 68040 bus runs at BCLK = PCLK/2 through the core's `bclk_en` input,
which marks the processor clocks that end on a bus clock edge: every bus
output of the core is a flip-flop that changes only there, and its bus
inputs are sampled only there.  `next_cpu040` makes `bclk_en` so that
those edges are the `clk_sys` edges (`sys_tog` toggles on `clk_sys`;
registered twice on `clk_cpu` the two copies differ exactly in the
processor clock before a `clk_sys` edge), so the bus is synchronous to
`clk_sys`: the slave reads the core's pins at `clk_sys` edges and what it
registers the core samples at the next one.

`NeXT.sdc` tells TimeQuest that every path between the two domains has a
whole bus clock (36.4 ns), not the half the default analysis to the
mid-bus-clock edge assumes: `set_multicycle_path` 2/1 both ways, with the
`sys_tog -> tog_q` capture of the generator itself kept single-cycle.
`clk_vid` stays an asynchronous group.

Simulation: the benches make both clocks in ONE process (`#2.5 clk_cpu =
1; clk = ~clk; #2.5 clk_cpu = 0;`) so a coincident edge is seen by both
domains with the other's pre-edge values, as in hardware; two independent
`always #` clocks are ordered arbitrarily by the simulator and the slow
domain can see the fast domain's updated flops (tb_next_boot's "bus clock
enable marks every bus clock edge" check catches that).

## The bridge, `rtl/next/next_cpu040.sv`

The slave side of MC68040UM section 7, on `clk_sys`:

- **Transfer -> beats.**  TS low for one bus clock starts a transfer; the
  bridge latches the address, size, kind and modifier and requests one
  beat on the `b_*` port of `next_system` (the old adapter's contract:
  `b_req` level-held, `b_ack` a one-clock pulse with `b_rdata`, `berr`
  aborts).  A line transfer (SIZ 11) is four beats: the core holds the
  line's address and the bridge counts A3:A2 up from the long word asked
  for, wrapping in the line.  Byte lanes follow table 7-1 (`be[3]` is the
  byte at A1:A0 = 00, D31-D24); the core only ever puts aligned pieces on
  the bus.  TA is driven for one bus clock after each `b_ack`; the read
  data is registered with it.  A read burst requests the next beat while
  TA for the previous is on the bus (`next_system` does not accept during
  its own acknowledge clock); a write burst leaves one idle clock first,
  because the core puts the next beat's data on the bus only after it has
  seen the current TA.
- **Bus error.**  `next_system` raises `berr_hold` for an address nothing
  decodes; the bridge drops the beat (which ends `berr_hold`, two clocks
  as before) and drives TEA for one bus clock.  The core has no bus
  timeout of its own.
- **TCI** with the first TA of every transfer outside main RAM
  (`0x04-0x07`) and the ROM: devices, BMAP, VRAM and the
  memory-write-function mirrors are never cached, whatever the MMU says
  (the ROM runs with translation off, whose default cache mode is
  cacheable write-through).  TBI is never asserted: every target takes a
  line as four beats (the 16-bit targets as 4 x 2 sub-cycles, as before).
- **Interrupt acknowledge** (TT 11, TM = level): TA with AVEC, nothing
  goes to `next_system`.  Every NeXT interrupt is autovectored.  A
  breakpoint acknowledge (TT 11, TM 0) gets TA; the core then takes the
  illegal instruction exception.
- **MOVES to FC 0/3/4/7** (TT 10) is decoded by address like any access,
  as the old port did (`next_system` never looked at FC).
- **Table walks** are ordinary bus transfers (TM 3/4) through the data
  cache: the old walker port is gone.  `tb_next_boot +walktrace` logs
  them from the bridge's transfer modifier.
- **DMA write snoops.**  The old core had an invalidate input; this one
  snoops the 68040 way, and only while it does not own the bus (with BG
  held it owns the bus for good after its first transfer).  So the
  bridge arbitrates: `next_system` reports each acknowledged DMA write
  (`dma_snoop_stb/addr`), the bridge negates BG, waits for the core to
  finish its transfer and release the bus (A no longer driven), presents
  the write as another master's long-word transfer with SC 10
  (invalidate) on the core's snoop inputs, waits for the snooper to
  release MI, answers it with TA (the shared TA: the core's own BIU is
  idle and off the bus), and re-grants.  `snoop_idle` is low from the
  report to the re-grant and `next_system` grants no DMA transaction
  meanwhile, so one snoop is in flight at a time and no DMA write lands
  before the previous one's invalidation is done.  `snoop_idle` covers
  the report's own clock (`!snoop_stb`): `next_system` decides the next
  grant in the clock the report arrives, and without that term a
  back-to-back DMA write could be granted and its report overwrite the
  pending snoop's address, losing an invalidation (audit 2026-10-19,
  `tb/build/mmu_cpu_audit/tb_dma_snoop_audit.sv`).  Cost: about six bus
  clocks per DMA write, during which the core runs from its caches.
- **LOCK.**  The core's `lock_n` (TAS, CAS/CAS2, the walker's locked
  U/M-bit descriptor update) reaches `next_system` as the bridge's
  `bus_locked`, and no DMA transaction is granted while it is asserted,
  so a device cannot write the operand between the locked read and its
  write (the old core was not pipelined and held the bus for the whole
  RMW; audit 2026-10-19, `tb_dma_lock_audit.sv`).
  **DMA reads are not snooped** (the 68040 protocol would have the core
  supply dirty data, SC 01; the old core was write-through, so the
  question did not arise): the kernel is expected to push dirty lines
  before handing a buffer to a device.  See "Open items".
- **Reset.**  `rsti_n = ~reset`; the core's RSTO (the RESET instruction,
  512 bus clocks) drives `dev_reset` as the old `nresetout` did.
- **Interrupts.**  `ipl_n = ~ipl_level` from `next_intc`, sampled by the
  core on bus clocks (two agreeing samples).

## What left next_system

The core's clock enable and everything that gated it (`clkena`, `b_busy`,
`CPU_PACE_*`, the host-side DBcc floor on `debug_status[231:224]`), the
walker port and its service, the retained-line sideband into the cache
(`sb_*`, `cache_line_*`; `ram_line_*` stays on the module's ports,
unused), posted stores (`POST_STORES`), `debug_status`, `tick_in`.  The
exception diagnostics (`DEBUG_EXCEPTIONS`, `NEXT_EXCEPTION_DIAG`) have no
source in this core: the mailbox outputs are quiet and a build that asks
for them fails at elaboration on purpose.

## CPU speed calibration

The boot ROM's `delay(n)` spins `(n-3)*6.25` iterations of a bare
`dbf d0,*` from the instruction cache and the POST checks it against the
hardware timers (RTC: 1100 ms wait for a seconds tick; Timer and Event
counter: `delay(1000)` must read 899..1100 us).  The ROM's constant is a
real 68040's 4 clocks per taken DBcc at 25 MHz: 160 ns.  The pipelined
core runs that loop in 2-3 of its clocks, so `next_system` passes
`DBCC_FLOOR` to the core's `dbcc_floor` input.  With the processor clock
twice the bus clock the invariant is

    (CLK_HZ / 1e6) = 6.25 * DBCC_FLOOR / 2

bus clocks per microsecond tick.  The build: `DBCC_FLOOR` 9 (164 ns),
`CLK_HZ` 28 MHz with the real 27.5 MHz clock (`CLK_REAL_HZ`), the machine
uniformly 1.8 percent slower than real time, `delay(1000)` read as 1001
us.  `tb/run_tests.sh post` prints the ROM's own measurement ("event
counter measured delay(1000) = N us"); `tb_next_boot +loopdump` prints
iterations and CPU clocks per `delay()` call.

At 60 MHz / 30 MHz the same invariant gives `DBCC_FLOOR` 10 and `CLK_HZ`
30 MHz: real time exactly, `delay(1000)` read as 1038 us.

## Bench probes (`tb/tb_next_boot.sv`)

The core keeps no opcode past decode and WB holds a uop for one CPU
clock, so everything keyed on a PC lives on `clk_cpu` and on retirement:
`cpu_retire = dut.cpu.be.wb_bound`, `cpu_rpc = dut.cpu.be.wb_u.pc`
(`dbg_pc` is the PC of whatever uop is in WB), `cpu_sr = dut.cpu.sr`, a
shadow register file kept from the back end's two write ports (D0-D7
0-7, A0-A6 8-14, USP 15, ISP 16, MSP 17; `dbg_d0`, `cpu_a7`), exception
entries from `dut.cpu.be.x_go/x_vec/x_pc/x_addr`.  The POST watchpoints,
the PC ring, `+loopdump`, `+wildpc`, `+panictrace` (retired PCs with SR
and A7), `+exctrace` and the kernel-entry detection use these; the bus
monitor is unchanged (`dut.b_*` is now driven by the bridge); the write
watch sees physical addresses only (the 68040 bus carries no virtual
address).  `tb/next_profile_monitor.sv` (`-DNEXT_PROFILE`) still probes
the old core and is not built by the suite.

## Gates

```
cd rtl/ap68040/tb && JOBS=12 WORK=<dir> bash run_tests.sh   # the core: 34 programs x 5 bus configs
MAIN_SRC=/home/adam/MiSTer_Main/Main_MiSTer sh tb/run_tests.sh   # device suites, smoke boot, recording
sh tb/run_tests.sh post      # the full POST (the calibration check)
sh tb/run_tests.sh bootsd    # the ROM's SCSI boot path
NEXT_FIT_QUADRA=1 NEXT_SEED=9 quartus_sh --flow compile NeXT; sh release.sh
```

## Checklist for a new CPU drop

1. Replace `rtl/ap68040/{rtl,tb,tools,syn,doc,README.md,LICENSE}`; update
   `UPSTREAM.md`.  Keep `rtl/gen/` (generated, committed upstream).
2. Re-apply the `dbcc_floor` input (`ap68040.sv`, `ap68040_backend.sv`,
   the bench register in `tb/tb_ap68040.sv`, `t_dbccfloor` in
   `run_tests.sh`) and the `ap68040_sdp_be` write form (`ap68040_ram.sv`)
   and the walker's `E_TW_DESCW2` wait state and the kill mark's
   clearing in `E_IDLE` (`ap68040_dmu.sv`, `t_nx8k` and `t_snkill` in
   `run_tests.sh`) if upstream has not taken them; check the M10K count
   in the fit.
3. Diff the `ap68040` port list against the instance in `next_system.sv`
   and the `ap68040.qip` file list against `syn/fitcore.sh`.
4. Re-check the bus contract the bridge relies on: outputs change and
   inputs sample on `bclk_en` edges only; TS one bus clock; TA/TEA/TBI/TCI
   sampled in S_DATA; the line's A3:A2 counted by the slave; the write
   burst's next data after the current TA; `own`/`ts_alt` in the snooper;
   `mi_n` while idle and not owning.
5. Run the four gates above, then Quartus, then hardware: POST, `bsd`.

## Open items

- **Hardware.**  Not yet run on the board (the core itself has only been
  validated under Verilator, out-of-context fits at 60 MHz upstream).
- **DMA reads of dirty lines** (above).  If NeXTSTEP relies on hardware
  snooping of device reads, the bridge must snoop DMA reads with SC 01
  and route the core's intervention data (its TA and data) to the DMA
  channel in place of RAM's.
- **The retained-line sideband** could answer beats 1-3 of a RAM line
  fill in one clock each instead of three `ram_*` hits.
- **60 MHz**: `DBCC_FLOOR` 10, `CLK_HZ` 30 MHz, the PLL at 60/30.
- `tb/next_profile_monitor.sv` needs re-pointing at the new core.
