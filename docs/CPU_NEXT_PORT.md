# Running NeXT on the Quadra 800 AP68040 tree

`rtl/ap68040/` is the AP68040 as vendored in MacQuadra800_MiSTer (see
`rtl/ap68040/UPSTREAM.md`; imported tree `8778213`), not the
`apolkosnik/AP68040@7431dcb` submodule this core used until `e61f45a`. The
two are different forks of the same base and do not merge. This file lists
every change needed to make that tree drive `next_system.sv`, so the same
changes can be re-applied when a newer CPU drop replaces the directory.

## Re-applying to a new CPU drop

```bash
# from the root of the new CPU tree (the directory that contains rtl/)
git apply -p1 --3way <NeXT_MiSTer>/docs/CPU_NEXT_PORT.patch
```

The patch touches `rtl/ap040_tg68k_compat.v` (interface),
`rtl/ap040_cache.v` and `rtl/ap040_mmu.v` (one bug fix each, below). If it
no longer applies, make the changes by hand; they are small. Then go through
the checklist at the end.

## CPU-side changes

`ap040_core.v` and `ap040_fpu.v` are untouched.

| # | change | why |
|---|---|---|
| 1 | wrapper: `parameter [7:0] AP040_FPU_REVISION = 8'h41`, passed to `ap040_core` | The core already implements the `$40` frames (44-byte UNIMP) old non-Turbo Mach expects; the wrapper just did not expose the parameter. NeXT sets `8'h40`. See `docs/FPU_FRAME_REVISION.md`. |
| 2 | wrapper: `parameter AP040_DEBUG_EXCEPTIONS = 0`, outputs `debug_exception_valid` / `debug_exception[511:0]` tied to 0 | `next_system.sv` sets and connects these. This tree has no exception-diagnostic block (upstream `7431dcb` `ap040_core.v`, generate `g_debug_exceptions` / `g_debug_unhandled`). A non-zero value instantiates a deliberately undefined module so a `NEXT_EXCEPTION_DIAG=1` build fails at elaboration instead of silently reporting nothing. |
| 3 | wrapper: `input tick_in`, unused | Upstream gates the IPL synchroniser on `tick`; NeXT ties it to 1 so interrupts are sampled through bus waits. This core samples `ipl` on every clock regardless of `ce`, which is the same behaviour. **Re-check this on a new drop** (the `ipl_s1 <= ipl` block near the top of `ap040_core.v` must not be under `ce`). |
| 4 | wrapper: `AP040_POST_LO/HI` parameters | The posted-store window was the CPU bench's map (`addr[31:30]==0`); NeXT posts only main RAM `0x04000000-0x07FFFFFF` so a device write can still bus-error. |
| 5 | `ap040_cache.v`: `tag_ridx` holds the crossing read's second row through `xlook`, not only `xlook_read` | **Bug under a gated `ce`** (see "Five bugs" below). |
| 6 | `ap040_mmu.v`: the PFLUSH/PTEST sweep tracks which row `row_q` holds | **Bug under a gated `ce`** (see "Five bugs" below). |
| 7 | `ap040_cache.v`: `xsnooped` (the crossing read's snoop guard) set free-running like `look_snooped`/`fill_snooped` | **Bug under a gated `ce`, hardware only** (see "Five bugs" below). |
| 8 | `ap040_cache.v`: `tag_ridx` switches to the crossing read's second row only on the clock the FSM takes the `xlook_read` step (`ce && xlook_read`) | **Bug under a gated `ce`, hardware only** (bug 5 in "Five bugs" below): the un-qualified combinational `xlook_read` moved the tag row one clock early. |

## NeXT-side changes

| file | change | why |
|---|---|---|
| `rtl/next/next_system.sv` | `POST_STORES` parameter (default 0), `.AP040_POST_LO/HI` = main RAM | With 0 no store is posted (the old CPU's behaviour); 1 posts stores to main RAM only. Both boot NeXTSTEP identically in simulation once the bugs below are fixed; the default stays 0 until the posted path has been run on hardware. |
| `rtl/next/next_system.sv` | `walker_ack`/`walker_berr` held as a LEVEL until `walker_req` drops | **Bug under a gated `ce`** (see "Five bugs" below). The MMU only samples the ack under `ce`. |
| `rtl/next/dpram.v` | `dpram` = MacQuadra800's `altsyncram` wrapper | Read-during-write semantics the CPU RAMs need on M10K (see "dpram" below). |
| `rtl/next/dpram.v`, `ap040_cache.v` | `NEXT_RAM_PESSIMISTIC` (Verilator only) | The simulation models of the tag/ATC RAMs and the cache data arrays behave like the silicon: garbage on a mixed-port collision, NEW data on a same-port write-then-read, every collision counted and the first few printed (`-DNEXT_RAM_PESSIMISTIC` on the verilator line). Used to rule RAM semantics out for bug 5: NeXTSTEP boots under it. |
| `files.qip` | `rtl/AP68040/` -> `rtl/ap68040/` | Directory case; only matters on a case-sensitive filesystem. |
| `files.qip` | `NEXT_FIT_QUADRA=1` fitter recipe block | See "Fitting" below. Opt-in until made the project default. |
| `NeXT.sv`, `tb/tb_next_boot.sv` | `CLK_HZ` 50 MHz -> **25 MHz**, `CPU_PACE` 2/2 -> **1/2** | CPU speed calibration, see below. |
| `NeXT.sv` | `VIDEO_ARX/ARY` "Original" = 35:26 | 1120x832 is not 4:3; at 1x integer scaling the 4:3 declaration squeezed 1120 columns into 1109 and blurred the font. |
| `NeXT.sv`, `next_system.sv`, `NeXT.qsf` | `reset` / `dev_reset` registered and routed on global networks; `next_rom` 96 KB; `next_scsi` `SCSI_UNITS=4` | Fit: -32 M10Ks, the two ~5,000-fanout nets off local routing ("Fitting" below). |
| `tb/run_tests.sh` | `CPU=../rtl/ap68040/rtl` | Directory case. |
| `tb/tb_next_boot.sv` | `+loopdump`, `+exctrace` probes; `POST_STORES` from `-DNEXT_POST_STORES` | Diagnostics used below. |
| `rtl/ap68040/tb/tb_ap040_program.v` | `+pace` (gate `clkena` every other clock), `+paceshift` (the other phase), walker ack level-held, `+mmutrace`, `+pftrace` | The paced CPU suite; `asm/t_xline.s` (cases 12-15: the two lines in different ways, the bug-5 reproduction), `asm/t_xline_mmu.s` added. Run every test `+pace` and `+pace +paceshift`. |

## CPU speed calibration (the "System test failed" after RTC)

The boot ROM's `delay(n)` (at `$010024CC`) spins `(n-3)*6.25` iterations
of a single `dbf d0,*` from the instruction cache, and the POST checks that
loop against the hardware timers (RTC: waits 1100 ms for a seconds tick;
Timer and Event counter: `delay(1000)` must measure 899..1100 us). The
machine's microsecond is `CLK_HZ/1e6` clocks, so the invariant is

    (CLK_HZ / 1e6) * (CPU_PACE_NUM / CPU_PACE_DEN) = 6.25 * clocks per DBF iteration

The old CPU took 8 clocks per iteration (50 clocks/us, `CLK_HZ` 50 MHz,
unpaced). This tree takes **2** (measured in the boot bench with
`+loopdump`: `delay(1000)` = 12,536 clocks, `delay(100)` = 1,286, i.e.
11,250 clocks for 5,625 iterations). With the wrong constant the ROM's
1100 ms RTC wait lasted 275 real ms and POST failed at RTC on hardware and
in simulation. `CLK_HZ/1e6` is an integer divider everywhere, so 12.5
clocks/us is done as `CLK_HZ` 25 MHz with the CPU paced 1 of 2: the ROM
then measures `delay(1000)` = 1015 us and the full POST passes
(`tb/run_tests.sh post`, and on hardware). At the real 28 MHz clock the
machine runs at 112% of real time (it was 56%).

**Re-measure on every CPU drop**: `tb_next_boot +mcycles=1400 +loopdump`,
take the `n=1000` and `n=100` lines, clocks per iteration =
(clocks(1000) - clocks(100)) / 5625.

## dpram (the CPU's ctag_ram and atc_ram)

The CPU's `ap040.qip` does not list `primitives/dpram.v`; the module
resolves to `rtl/next/dpram.v`, which since 2026-09-23 is MacQuadra800's
explicit `altsyncram` wrapper (mixed-port read-during-write DONT_CARE,
same-port NEW data, M10K) with the CPU suite's stub semantics under
Verilator. The inferred write-first template that was there before implied
mixed-port OLD-data semantics an M10K cannot provide; the RAMs were built with
semantics the CPU was never validated against. (The `0xc0835380` bucket
read was bug 4 above, which this change alone did not cure.) Keep the
wrapper in step with the Quadra's `rtl/dpram.v`. The
VRAM's `dpram_dc` is this core's own and is unchanged.

## Five bugs under a gated clock enable (NeXTSTEP 3.3 double fault and panic, 2026-09-23)

Both the Quadra core and the old NeXT integration run the CPU unpaced
(`ce` = 1 except bus waits). NeXT now paces it 1 of 2 (calibration above),
and five sequences that read a RAM (or sample a pulse) on one enabled
clock and consume the result on the next break when an un-enabled clock
sits in between:

1. **Cache, line-crossing cached read** (`xline`/`xlook`, an optimisation the
   old tree does not have -- it bypassed misaligned reads). The tag RAM reads
   every clock; `tag_ridx` selected the next line's row only while
   `xlook_read` was true, so on the un-enabled clock the address reverted to
   the hint row and the FSM's `xlook` arm compared the *request* line's tags:
   same tag, other way, a false hit on an empty way -> 0. NeXTSTEP's
   `vm_page_buckets` is 2-byte aligned, so every fourth bucket read crosses
   a line; the first crossing hit read 0, `vm_page_lookup` dereferenced a0=0
   (`cmp.l $18(a0),d3` at `$04077594`), the access-error frame push faulted
   too, double fault. Fix: hold the row through `xlook`. Directed tests
   `t_xline.s`, `t_xline_mmu.s` (pass paced and unpaced).
2. **Walker acknowledge**: `next_system` pulsed `walker_ack` for one clock;
   the MMU samples it only under `ce`, so a pulse on the un-enabled clock
   was lost and the walk hung until the stall watchdog faulted it (every MMU
   test of the CPU suite failed `+pace`). The DDR path's fixed latency
   happened to line up in the boot simulation, so it did not show there,
   but on hardware the latency varies. Fix: hold the ack until the request
   drops (the `ap040_walker_cdc` contract; the MMU's request-low cycle
   after each transaction makes a held ack safe). The old CPU tree had the
   same sampling, so this was latent before too.
3. **MMU, PFLUSH/PTEST sweep** (`W_SWEEP` in `ap040_mmu.v`): the sweep read
   the ATC tag RAM row by row and examined `row_q` as "the previous step's
   row" (`cnt-1`). That is true only with `ce` high every clock; paced, the
   RAM had already caught up to the current row within the step, so every
   row's data was only ever visible on an un-enabled clock and
   `PFLUSHN (An)` left the entry standing (t_atcprobe `+pace`: the
   repaired page faulted a third time). Fix: track the row the RAM output
   belongs to on every clock (`q_row_a`, as the lookup pipe already does)
   and process/advance only when it is the row asked for. Unpaced this
   costs one extra step per row (64 instead of 32 cycles per sweep).
4. **Cache, crossing read vs. snoop (hardware only)**: DMA snoop
   invalidates write the tag RAM free-running (not `ce`-gated), and on an
   M10K a mixed-port collision reads DONT_CARE. The first lookup's guard
   (`look_snooped`) and the fill's (`fill_snooped`) are set free-running for
   that reason, but the crossing read's (`xsnooped`) was sampled only at the
   read clock, so a snoop on the un-enabled clock between the second
   lookup's read and the `xlook` arm went unseen: garbage tags, a false hit
   on the wrong way, and `vm_page_lookup` read `0xc0835380` (deterministic,
   same in two bitstreams) from RAM that the ROM monitor showed to be
   correct (`el 40e0c18` = `0c16040e`, i.e. the self-pointer). The RTL
   models the collision as old data, so every simulation passed. Fix: set
   `xsnooped` free-running while `xlook` is pending, like the other two.

5. **Cache, crossing read: the tag row switches one clock early (hardware
   only)**. `tag_ridx` selected the second line's row on `xlook_read`, which
   is combinational in `look_hit`. Paced, the clock after the accept is
   un-enabled: the tag RAM had row A out, `look_hit` was already true, so
   `xlook_read` steered the address to row B *before* the FSM took its
   first-lookup step; on the next enabled clock the compare ran against
   row B's tags. Adjacent lines share the 20-bit tag, so with line B
   resident the first lookup was a false hit with **row B's way number**,
   and word 3 was taken from that way of row A (the data arrays are
   `ce`-gated, so they still held row A): the wrong line, or an empty way.
   NeXTSTEP's `vm_page_lookup` read `00006a8a` for bucket `040efe2e`
   (correct `04106a8a`), walked into the ROM at `$6a8a` and found the
   `c0835380` "next" pointer that faulted at `c0835398`. Whether the
   un-enabled clock lands after the accept depends on the pace phase the
   previous bus cycle left behind, so the boot bench (different DDR
   latency) never saw it while the hardware failed byte-identically on
   every build; 52,261 of 52,282 crossing reads went to the bypass on
   hardware for the same reason. Fix: `(ce && xlook_read) || xlook`.
   Directed test `t_xline` cases 12-15 (the two lines in different ways)
   fail on the old cache under `+pace` on both phases and pass with the fix.

The `ap040_cache.v` (bugs 1, 4 and 5) and `ap040_mmu.v` (bug 3) fixes are in `CPU_NEXT_PORT.patch`
and are candidates for upstream (they are correct under any `ce` pattern).
The pattern to look for on a new drop: a RAM read on one clock whose result
is consumed at a *state-machine step* -- either gate the RAM read on `ce`
(as the cache's data arrays are) or track which address the output holds.
The second pattern (bug 5): a RAM *address* driven by a combinational
function of that RAM's own output (`look_hit` -> `xlook_read` -> `tag_ridx`)
advances on un-enabled clocks; qualify the step with `ce`.

### How it was found (kept for the next one)

Hardware and `tb_next_boot +bootsd +img=<NS3.3 image>` agreed: the kernel
loaded, printed its first line and double-faulted. `+exctrace` and
`+panictrace` (bench) gave the halting PC, the instruction, the RAM around
PC and SP and the last 64 CPU memory completions; the bucket-table dump at
the halt showed RAM held correct self-pointers while the CPU had read 0 for
a longword at `..2e` (crossing a 16-byte line). `POST_STORES` 0 and 1
failed identically, so it was not the store path. The CPU-only bench
(`rtl/ap68040/tb`) passed the same access in every residency combination
and with the MMU on, and only failed once `+pace` gated `clkena` the way
`next_system` does -- which then also exposed bugs 2 and 3 (7 of 16 suite
tests fail paced on the pristine tree; all 16 pass with the fixes).

Bug 5 survived all of that (the CPU suite and the boot bench pass paced) and
was found on the hardware: a read-only device window (`0x0201F000`, 16
longwords per entry, ringed in M10K in `next_system.sv`) exposed a capture
register in `ap040_cache.v`, read from the ROM monitor after the panic
(`monitor`, `el 201f000`, Enter per longword). Three captures in sequence:
(1) the crossing read's own internals (`r_addr`, word 3 of line A, word 0 of
line B, the assembled result, tag/valid/hit flags, all four data arrays):
showed a *valid* line with a fresh word 0 and a zero word 3 while RAM was
correct; (2) every event on that data row (array writes with their data,
tag writes, port-B invalidates, the crossing read) frozen at the fatal read:
showed the refill writing the correct word 3 into array 3 way 0 two events
before the fatal read, and an earlier first lookup of the same read comparing
against the *next* row's tags (tag `040c3`, a row-e3 resident, with the
request row `e2`). Lessons for the next one: freeze the log at the event of
interest (the ROM monitor's own VRAM stores invalidate the watched row
thousands of times while you read the window), and keep the capture small
(a 2,048-bit flop ring plus a 64:1 readout mux did not route at 94 %).

## Checklist for a new CPU drop

0. Re-measure the DBF loop speed and update `CLK_HZ`/`CPU_PACE_*` (above).
1. Apply the patch (or the edits above).
2. Wrapper interface: every port and parameter `next_system.sv` names on
   `ap040_tg68k_compat` exists. New wrapper outputs can stay unconnected;
   new inputs need a tie-off.
3. IPL sampling is still not under `ce` (change 3).
4. The post-store window (`AP040_POST_LO/HI`) still exists in the wrapper.
5. **Run the CPU suite paced, on both phases**: `vvp build/tb_prog.vvp
   +prog=... +pace` and `+pace +paceshift` for every test as well as unpaced. Anything that only fails paced is a `ce`
   hazard of the kind above. `t_xline`, `t_xline_mmu`, `t_atcprobe` are the
   directed tests.
6. NeXT-relevant CPU fixes are present, by their directed tests in
   `tb/run_tests.sh`: `t_moves_fc`, `t_movem_restart`, `t_atcprobe`,
   `t_fpu_frames`, `t_fpu_resume`.
7. `rtl/next/dpram.v` still matches the Quadra's `rtl/dpram.v`.
8. `quartus_map NeXT`, then the full flow (`NEXT_FIT_QUADRA=1`): ALM fit,
   M10Ks, timing on every clock.
9. `tb/run_next_fpsp.sh` and `tb/run_fpu_revision_tests.sh` (revision 64),
   `tb/run_tests.sh post`, then `+bootsd +img=` with the NeXTSTEP image.

## Baseline (2026-09-21, tree `8778213`, Quartus 17.0.2 Lite)

`quartus_map NeXT`: 0 errors. Estimated 38,881 ALMs for the whole design
(the 5CSEBA6 has 41,910, so about 93% before the fitter). CPU: 33,551
ALUTs / 7,192 registers / 311,858 block RAM bits / 12 DSP, of which the
core is 30,197 ALUTs (FPU 7,273), cache 1,811, MMU 1,339. The three
"uninferred RAM" notes in `ap040_mmu.v` (`u_row`, `u_tag`, `u_ent`) are
small asynchronous-read arrays and are expected.

### Fitting

The CPU is not larger here than in the Quadra core: 22,639 ALMs fitted
against 22,575 there, from byte-identical source. The rest of this design
is (about 16,900 ALMs against the Quadra's 14,300), so NeXT sits at 94%
where the Quadra sits at 88%, and the few hundred ALMs this tree costs over
`7431dcb` were enough to stop the router.

| settings | result |
|---|---|
| project default (HIGH PERFORMANCE EFFORT, SPEED, seed 1) | placed at 39,538 ALMs, 500/553 RAM blocks; routing abandoned on congestion (peak vertical 98.6%, X11_Y35..X21_Y45) after 21 min |
| HIGH PERFORMANCE EFFORT + AREA + aggressive routability, seed 2 | 37,833 ALMs estimated; fitter still running after 90 min, stopped |
| `NEXT_FIT_QUADRA=1` (BALANCED mode and technique, register duplication off, aggressive routability: MacQuadra800's recipe), seed 1 | **routes and meets timing**, 32 min: 39,213 ALMs (94%), 502/553 RAM blocks; worst setup +0.080 ns (HDMI PLL), CPU clock setup +3.406 ns |
| + registered `reset`/`dev_reset` on global networks, `next_rom` 96 KB, `SCSI_UNITS=4` (2026-09-23) | 39,449 ALMs (94%), **470/553** RAM blocks, route-throughs 4,275 -> 4,105, peak vertical interconnect 95.5% -> 91.7%, the two reset nets gone from the high-fanout list; worst setup +0.34 ns |
| + `dpram` = altsyncram wrapper | 39,358 ALMs, 470 M10K, worst setup +0.22 ns (HDMI); ctag_ram / atc_ram now explicit ALTSYNCRAM instances |

The MiSTer framework (`sys/` and its feature macros) stays stock. Further
room has to come from this core's own RTL: `next_scsi` (2,299 ALMs) and
`next_mo` + `next_rs` (2,205) are the largest entities after the CPU. A
Main-served SCSI response window in the Quadra's style was evaluated and
not pursued: NeXT has no CD-audio engine to move, so the whole target
layer is worth at most ~500 ALMs (standalone synthesis with the response
tables stubbed).

## Open items

- Hardware boot of NeXTSTEP 3.3 with bug 5 fixed (2026-09-23, build
  `NeXT_q800cpu_20260923i_fix`, 39,265 ALMs): POST, `bsd`, the kernel's
  device probe, disk check, multi-user startup and the login window,
  about 2.5 minutes from `bsd` (Control-C at the network prompt).
- `POST_STORES(1)` on hardware (performance) once the boot is solid.
- The exception diagnostics (`NEXT_EXCEPTION_DIAG=1`, `tb_next_exception_cpu`,
  `tb_next_unhandled_cpu`) do not build against this tree until the
  diagnostic block is ported into `ap040_core.v`.
- The ROM disassembly for reference: `rom-disassembly/`.
