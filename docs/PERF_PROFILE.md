# Where the cycles go (Quadra-tree CPU, 2026-09-24)

Profile of the NeXT core on the Quadra 800 AP68040 tree, `CLK_HZ` 25 MHz,
`CPU_PACE` 1/2, taken to decide what to do about the real-time speed
(NWBench Dhrystone 2.72 guest-MIPS = 2.4 real MIPS against 15-18.6 for a
real 25 MHz NeXTstation). No RTL was changed for this; the numbers come
from a bench-side monitor and from a program run in the guest on hardware.

## Method

- `tb/next_profile_monitor.sv`, instantiated by `tb_next_boot` under
  `-DNEXT_PROFILE`: samples the host bus FSM, the CPU's clock enable, the
  cache FSM, the core's `mem_req`/`mem_ack`, the `ram_*` port and the DDR
  model on the free-running clock; prints a `PROF bin` line every 50M
  clocks and per-phase totals at the end (phase 0 = ROM POST and loader,
  phase 1 = NeXTSTEP kernel from `saw_kernel`).
- Bench knobs added for this: `+ddrlat=<n>` (DDR3 model read latency,
  default 12), `-DNEXT_TB_CLK_HZ=` / `-DNEXT_TB_PACE_DEN=`.
- Four `+bootsd` boots of the NS3.3 image to 2,400M clocks (about 60 s of
  machine time after kernel entry: device probe, fsck skip, rc, the
  first user processes): latency 12 (A), latency 6 (B), latency 12 with
  `POST_STORES=1` (C), and unpaced with `CLK_HZ` 12 MHz (D: `CPU_PACE` 1/1
  keeps the ROM's delay calibration passing, and the boot still works).
- Hardware calibration on the MiSTer (old-CPU build 0914, same host RAM
  path): `tb/hw/memlat.c` compiled in the guest with `cc`, timed by
  `gettimeofday` (guest us = 50 clocks on that build). Driving the guest:
  `tb/hw/guest_click.py`, `tb/hw/type_text.py`.

## Hardware: what one memory access costs

| access (old-CPU build, 28 MHz) | guest ns | clocks | note |
|---|---|---|---|
| cached longword load loop | 677 | 34 | loop overhead, all cache hits |
| stride-16 byte read (one line fill each) | 3,299 | 165 | fill = 165 - 34 = **~130 clocks** |
| stride-16 longword read | 3,554 | 178 | fill ~145 |
| sequential longword store | 1,268 | 63 | store = 63 - 34 = **~30 clocks** |

So a 16-byte cache line costs 4.7-5.2 us on hardware (a real 68040 burst
fills one in about 0.2 us), and every write-through store costs a
microsecond. The bench reproduces the fill at `+ddrlat=6..7` (123 clocks
at 6, 171 at 12), so run B is the hardware-representative one; the
bench's default 12 is pessimistic. Writes are cheaper in the bench (7 vs
15 clocks per 16-bit half) because the DDR model accepts writes at once
and the HPS bridge does not.

Anatomy of one 16-bit read sub-cycle (bench, latency 6): `ram_req` to
`ram_ack` is 11 clocks (6 DDR + 5 of `next_ddram`/host handshake:
request register, `DDRAM_RD`, acceptance, `DOUT_READY` to `ram_ack`,
`ram_ack` to `mem_ready`), plus ~4.4 clocks in the 16-bit adapter (the
sampled IDLE gap between sub-cycles, which is also pace-gated) and the
host's decode clock: **15.4 clocks per 16-bit transfer, 8 transfers per
line = 123.** The DDR latency is under half of it.

## Simulation: kernel phase (run B, latency 6, 1,705M clocks)

| where the clocks go | share |
|---|---|
| CPU internal step taken (`busstate` idle, `clkena` high) | 31.0% |
| CPU internal step **lost to CPU_PACE** | 26.8% |
| bus cycle, waiting on the DDR3 round trip (`S_RAM`) | 33.1% |
| bus cycle, arbitration/decode clock (`S_IDLE` with a request) | 8.8% |
| bus cycle, DMA owns the RAM port | 0.04% |
| bus cycle, on-chip ROM/device/VRAM | 0.3% |

Of the same clocks: cache line fills 5.40M x 123.4 = **39%** of all
clocks (65% instruction lines); uncached/bypassed accesses (`C_PASS`,
device polling and DMA-shared buffers) 13%; stores 14.2M x ~15 = 12%.
The core sits in `S_MRD` 28% and `S_MWR` 23% of the time. Core-level
latency: instruction access avg 5.2 clocks (50% in 1, 43% in 3, 5.5%
misses at 33-128), data read avg 4.2, **write avg 21.4** (76% at 9-16:
two DDR write halves each).

In the busiest bins (rc, first user programs) the mix is: internal
16-24%, gated 11-19%, bus 55-72% with 45-63% pure RAM wait. DMA
contention is nil (586k DMA beats against 69M CPU beats; video scans the
on-chip VRAM), and the table walker is 0.1%.

Run D (unpaced) in the same busy region: 300k fills per 50M-clock bin
against B's 250k, i.e. **about 20% more work per clock**, and the fill
itself drops only 123 -> 118 clocks. Un-pacing pays in full only where
the code is cached: for a Dhrystone-shaped loop it is close to 2x.

Run C (`POST_STORES=1`, latency 12): core write latency 24.1 -> 7.8
clocks, instruction and data access averages down 10%, "posted drain"
busy 10% of clocks; bus share 58% -> 56%. Modest here, worth more on
hardware where a write half costs 15 clocks, not 7.

The ROM phase is dominated by the POST's uncached memory clear/test
(`C_PASS` 51%, 38M writes) and is not representative of anything.

## What the gap is made of

Real-time Dhrystone is 2.4 MIPS. Un-paced at 28 MHz with the working set
cached the same core would do about 2x that; the remaining ~4x against a
real 68040 is the core's own cycles per instruction (a multi-cycle
sequencer: `S_DECODE`/`S_PIPE_*`/`S_EXEC` chains), which is the
Quadra project's pipeline work, not a NeXT-side matter. On miss-heavy
code (Compile, Webster, the GUI) the memory path is the larger term:
the machine spends more than half its time waiting for a 16-bit word
from DDR3.

The "graphics" NWBench numbers (V/V 16.1 -> 28.5, D/V 18.4 -> 31.6) are
consistent with being **times**: converted to real time both builds take
the same ~28 s, which fits a test bound by uncached 16-bit VRAM writes
whose cost did not change.

## Cross-check against Previous and MAME (2026-09-24, second pass)

The 1/2 pacing exists only to satisfy the boot ROM's `delay()`
calibration, so the question is how the emulators satisfy it.

**Previous** (`src/cpu/gencpu.c`, `adjust_cycles`) derives the machine's
microsecond from a CPU cycle counter (`Timing_GetTime` =
`nCyclesMainCounter / nCpuFreq` while the CPU is in supervisor mode; host
real time in user mode when "realtime" is on) and prices instructions
with a block its authors label the "central hacking place for 030/040
instruction timings ... carefully adjusted in order to make all ROM POST
happy, make diagnostic kernels happy, give reasonable results in
NXbench". For the 68040 that block scales the 68000 cycle table by 1/3
("for correct MIPS") and has exactly one special case: `i_DBcc: cycles =
4`, commented "special cases for timing loops, ROM POST depend on these".
So the emulator's answer is: charge DBcc what a real 68040 charges (the
ROM's constant is 6.25 iterations/us at 25 MHz = 4 clocks) and let every
other instruction run at its own rate. It does not slow the whole CPU,
and it does not treat ROM code differently from kernel code.

**MAME** (`src/mame/next/next.cpp`) clocks the 68040 at 25/33 MHz, takes
the event counter from machine time (`machine().time().as_ticks(1000000)`,
which advances by the CPU's executed cycles), and its 68040 table charges
DBcc and Bcc 6 cycles. All NeXT sets are `MACHINE_NOT_WORKING`; the driver
comment says the POST fails at the SCC test. It offers no working model
to copy, only the same architecture: one cycle counter feeds the timers.

Measured with the CPU bench (`asm/bench_dbf.s`, `+dbccstall=N` added to
`tb_ap040_program.v`), clocks per iteration:

| loop | unpaced | DBcc floor 4 (`+dbccstall=2`) | CPU_PACE 1/2 (today) |
|---|---|---|---|
| A: bare `dbf d0,*`, 32-byte aligned (the ROM's loop) | 2.0 | **4.0** | 4.0 |
| A unaligned (target in the last 3 words of a refill block) | 6.0 | 6.0 with a period floor (8.0 with the bench's fixed +2 stall) | 12.0 |
| B: `move.l (a0)+,(a1)+` / `dbf` (memcpy shape) | 16.2 | **16.2** | 28.4 |
| C: `addq` / `subq` / `bne` (compiler loop) | 7.0 | **7.0** | 14.0 |

The ROM's loop is calibrated identically either way; everything else
runs at full speed under the DBcc rule. In the kernel profile `S_DBCC1`
is below 0.5% of clocks, so the rule costs the OS nothing measurable
(the ROM phase spends 10% there: the delay loops themselves).

The alignment finding also matters on its own: a taken DBcc whose target
lies in the last three words of a 32-byte refill block misses the core's
fast path and costs 6 clocks, three times the aligned case.

## Options, ranked

Gains are in real time on the busy kernel mix (run B) and, separately,
on a cached loop like Dhrystone. Fit numbers refer to the 2026-09-24
build: 39,538 / 41,910 ALMs (94%), `Fmax` of the 28 MHz clock 31.14 MHz.

| # | option | real-time gain | risk | fit | notes |
|---|---|---|---|---|---|
| 1 | **Replace CPU_PACE with a DBcc period floor** (Previous's model): in `next_system`, hold `clkena` low so that consecutive entries into `S_DBCC1` (`debug_status[231:224] == 53`, already exported) are at least 4 enabled clocks apart; no pacing otherwise | cached code up to +90%, busy kernel mix +20-25% (run D), DBcc-only loops unchanged | low: `clkena` gating is the mechanism the tree is already validated under (`+pace`/`+paceshift`); the gate pattern is new, so add a `+dbccstall` leg to the CPU suite and run `run_tests.sh post` (delay(1000) must read ~1,007 us) and the `+bootsd` boot | ~15 ALMs | Address- and mode-independent; identical to what Previous does to the instruction cost. Guest clock stays 1.12x with `CLK_HZ` 25 MHz. At 28 MHz a floor of 4 reads 890 us (the ROM wants 899-1100) and a floor of 5 reads 1,113, so real-time guest time needs the clock change in #7: 30 MHz with floor 5 and `CLK_HZ` 30 MHz reads 1,038 us. |
| 2 | **Retain the DDR line** in `next_ddram`: burst of 2 (16 bytes), keep the line and its tag, serve the other 7 sub-cycles of the fill (and the second half of every longword) from it; invalidate on any `ram_we` to that line (CPU, walker, DMA all pass through this one port) | fill 123 -> ~60 clocks: busy mix -20%, Compile/Webster-class -15-25%, Dhrystone ~0 | low: host-only, one module, `tb_next_ddram_arb`/boot bench cover it | ~150-250 ALMs (128-bit line + tag + control) | Halves the DDR round trips' share but leaves the 4.4-clock adapter overhead and the 5-clock handshake per sub-cycle. Neither emulator models memory latency, so this and the following stand on the measurements alone. |
| 3 | **Feed the cache's line sideband** (`m_line_valid/tag/data`, tied to 0 in the wrapper) from that retained line, as the Quadra's `wombat_cpu` does: the fill issues one beat and copies the other three words locally | fill -> ~35 clocks (with the 16-bit bus): fills 39% -> ~11% of clocks, busy mix -28%; Dhrystone ~0 | medium: a wrapper change (allowed, like changes 1-4 in CPU_NEXT_PORT.md) and a cache path (`fill_line_match`) that has never run under a gated ce; the paced suite is the gate | ~50 ALMs on top of #2 | Builds on #2. |
| 4 | **`POST_STORES(1)`**: already implemented, defaulted off pending hardware | bench -3-5%, hardware likely -5-8% (writes cost 2x the bench there) | low-medium: "once the boot is solid"; the posted drain adds 10% bus occupancy that reads queue behind | 0 | One parameter; hardware boot + NWBench decides. |
| 5 | **Trim the per-sub-cycle handshake**: decode in the request clock, do not drop `ram_req`/`ram_ack` between the two halves of a longword, let the adapter's gap ride the next clock | 2-3 of 15.4 clocks per transfer: fills and stores -13-20% | medium: the adapter gap is the Minimig contract the RAM controllers rely on; the level ack is what `next_ddram` and the DMA masters follow | ~0 | Worth doing inside #2 rather than alone. |
| 6 | **32-bit host bus** (the Quadra's `wombat_bus32` beat shape instead of `ap040_bus16_adapter`, with a 16-bit shim for the devices) | halves transfers: with #2/#3 fill -> ~20 clocks, stores 2x cheaper, `C_PASS` RAM bypasses 2x cheaper: busy mix another -15-25% | medium-high: the bus FSM, every device decode and the DMA snoop are written for 16-bit lanes | net ~+100-200 ALMs (the 130-ALM adapter goes) | Third stage. |
| 7 | **Raise `clk_sys`** 28 -> 30 MHz | +7% on everything (DDR latency is fixed in ns, so a little less) | medium: this compile's Fmax is 31.14 MHz, at 94% ALMs a seed walk of 30-40 min per try; `CLK_REAL_HZ`, the audio ADC and `CLK_HZ` move together | 0 | With #1 (floor 5) and `CLK_HZ` 30 MHz the guest clock becomes real time. Do after the logic changes, since they move the critical paths. |
| 8 | DMA / video contention | none: 0.04% of clocks | - | - | Video scans on-chip VRAM; SCSI DMA is 1% of RAM beats. |
| 9 | OSD "CPU speed" setting | selects #1 vs the old 1/2 pacing at run time | low | ~5 ALMs | Guest time is unaffected either way (`CLK_HZ` is the timer). Status bits 60-120 are free. |

Withdrawn from the first pass: "pace only ROM code". It would have given
the same speed as #1 but by making the ROM see a different CPU from the
one the kernel sees; neither emulator does that, and #1 achieves the
calibration by pricing one instruction the way the real chip does.

Not measured here: the disk test's 10% real-time loss on the new build.
The bench's SD model answers instantly, so the SCSI/MiSTer-side path
needs a hardware trace (the CPU side of it is faster, so it is the
`hps_io` handshake or a `CLK_HZ`-derived delay in `next_scsi`).

## Recommended first step

Option 1 (the DBcc period floor in place of CPU_PACE), because it is a
small counter on `clkena` in `next_system.sv` keyed on the exported core
state, gives the largest gain on the CPU-bound tests and a solid one
everywhere else, and is the model Previous uses for the same ROM. Its
validation path: the CPU suite with a `+dbccstall` leg next to
`+pace`/`+pace +paceshift`, `run_tests.sh post` (delay(1000) must read
about 1,007 us), the `+bootsd` boot, then NWBench on hardware. Option 2
(line retention in `next_ddram`) is the natural second step and is
independent of it.

## Stage 1 result: DBcc period floor (2026-09-24, simulation)

`DBCC_FLOOR` 4 in place of `CPU_PACE` 1/2 (docs/PERF_PLAN.md stage 1),
same `CLK_HZ` 25 MHz. Gates: CPU suite (14 programs) passes unpaced,
`+pace`, `+pace +paceshift`, `+dbccstall=2` and `+dbccfloor=4`;
`bench_dbf` loop A 2.0 -> 4.0 clocks per iteration under the floor (5.0
under a floor of 5), loops B and C unchanged at 16.2 / 7.0; `+loopdump`
(clocks(1000) - clocks(100)) / 5625 = 4.000; the POST measures
delay(1000) = **1009 us** (was 1015 under 1/2 pacing) and passes; the
NS3.3 `+bootsd` boot to 2,400M clocks: ALL PASS. Kernel-phase profile
at `+ddrlat=6`, against run B (1/2 pacing):

| kernel phase | run B (1/2 pacing) | stage 1 (floor 4) |
|---|---|---|
| internal step taken | 31.0% | 60.8% |
| internal step lost to gating | 26.8% | 0.0% (a few bins at 14-16%: delay loops) |
| bus, RAM wait | 33.1% | 30.2% |
| bus, arb/decode | 8.8% | 8.4% |
| cache fills | 5.40M x 123.4 clocks | 5.30M x 118.1 clocks |

The kernel phase got 1,845M clocks against B's 1,705M (the ROM phase is
shorter: 555M vs ~695M) and executed about twice the internal steps in
them. Fit (`NEXT_FIT_QUADRA=1`): seed 1 was still placing after 85 min and
was killed; `NEXT_SEED=2` closed in 20 min at 39,467 ALMs (94%), 470 M10K,
worst setup +0.014 ns (HDMI PLL); `releases/NeXT_20260924.rbf`.

Hardware (2026-09-25, `NeXT_20260924.rbf`, Main next-fixes 7f34486): the
POST passes (the ROM's own delay check), NeXTSTEP 3.3 boots to the login
window, NWBench Run All:

| NWBench | 1/2 pacing (2026-09-24) | DBcc floor |
|---|---|---|
| Dhrystone | 4,286 | **6,591** (4.18 guest MIPS), x1.54 |
| Graphics V/V, D/V | 28.5, 31.6 | 20.5, 24.3 |
| Compile | - | 416.5 s |
| Webster | - | 296.0 s |
| Disk | - | 525.3 KB/s |
| Ethernet | - | 8.47 KB/s |

The Dhrystone gain is 1.54x, not the 2x of a purely cached loop: the
profile's run D said the same for the busy kernel mix (about 20% more work
per clock), and Dhrystone as NWBench builds it evidently spends a third of
its clocks on the bus.

## Area work: the HPS-served SCSI responses, CD audio and MO ECC (2026-09-25)

Target: below 90% ALMs (37,719) for stages 2 and 3, without touching the
CPU, the FPU or the framework. Per-entity ALMs from the fit reports:

| entity | before (stage 1 build) | after (docs/HPS_SCSI_MO.md) |
|---|---:|---:|
| whole design | 39,467 (94%) | 38,348 (92%) seed 2 (setup miss on the HDMI PLL domain); **38,615 (92%) seed 5, timing closed** (`releases/NeXT_20260925.rbf`; seed 3 left a 17 ps hold, seed 4 did not finish in 50 min) |
| next_mo (incl. next_rs) | 2,220 (1,219 in next_rs) | 995 (next_rs gone) |
| next_scsi | 2,268 | 2,247 |
| next_cd_audio (new) | - | under 100 (the frame RAM is M10K) |
| next_kms_snd / sound output | 802 | 789 |
| next_enet_dma + bridge | 1,073 | 1,059 |
| next_scr | 575 | 573 |
| next_floppy | 498 | 502 |
| M10K | 470 / 553 | 470 / 553 |
| peak interconnect (V) | 91.7% | 94.4% (seed 2) |

What the numbers say: the whole gain is the Reed-Solomon codec. The
target's response tables that the port doc had estimated at ~500 ALMs
cost almost nothing in the fitted design (Quartus had already reduced the
constant tables to a few dozen ALMs); the window fetch/forward states put
back what the tables took out. So the "Main-served SCSI" half of the
change buys CD audio and the cue/bin/chd images, not area.

Levers assessed for the remaining ~630 ALMs to 90%:

- A third SCSI hard disk (`SCSI_UNITS` 4 -> 3): 86 ALMs by
  synthesis-only comparison (37,978 -> 37,892 estimated), and since units
  are indexed by target it removes target 3, the CD-ROM. Not applied.
- `next_scr`'s combinational NVRAM checksum (15 x 16-bit adds): ~100 if
  made sequential.
- The audio chain (`next_kms_snd` 517 own + sound output 273 + `next_snd_in`
  341 + ADC 279): a build-time option for the sound input would save ~620,
  the printer ~157; both are features, not offered as defaults.
- `next_scsi` (2,247) and the MO drive model (`next_mo` 995) are the only
  blocks left with real weight; both are cycle-level device models whose
  restructuring is a project of its own (the stage 3 bus rewrite touches
  next_scsi anyway).
