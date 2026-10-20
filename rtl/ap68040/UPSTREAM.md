# AP68040 in this repository

This directory is the AP68040 `faster` core, vendored from
`apolkosnik/AP68040` branch `main` at **b388dfc** (2026-10-18, "Merge pull
request #8 from apolkosnik/faster") on 2026-10-18.  It is the pipelined
SystemVerilog core (`rtl/ap68040*.sv`, the FPU in `rtl/fpu/`) that
presents the real MC68040 external bus; the NeXT side talks to that bus
through `rtl/next/next_cpu040.sv`, documented in `docs/CPU_NEXT_PORT.md`.

## What was taken

| upstream | here |
|---|---|
| `rtl/`, including the generated `rtl/gen/*.svh` (tools/ucode.py output) | `rtl/` |
| `tb/` (the 33-program regression, cputest replay, benchmarks) | `tb/` |
| `tools/`, `syn/`, `doc/`, `README.md`, `LICENSE` | same |
| `rtl_old/`, `tb_old/` (the previous sequential core, kept upstream as a reference) | not taken: that lineage is this repository's history before this drop (`git log -- rtl/ap68040` up to cb30c12) |

## Local changes to the core

Listed in `docs/CPU_NEXT_PORT.md` ("CPU-side changes") and kept small so
that a newer drop can replace this directory and the list be re-applied:

1. `rtl/ap68040.sv`, `rtl/ap68040_backend.sv`: the `dbcc_floor[3:0]` input
   (a DBcc period floor for hosts calibrated on a real 68040's DBcc
   loops); `tb/tb_ap68040.sv` register `$F10C` and clock count `$F2EC`;
   `tb/asm/t_dbccfloor.s` in `tb/run_tests.sh`.
2. `rtl/ap68040_ram.sv`, `ap68040_sdp_be`: a module per 32-bit slice with
   every byte's write spelled out and the read in the same always block
   (Intel's template to the letter), so Quartus 17.0 infers one M10K per
   slice instead of one per byte (and does not fall back to flip-flops,
   which it does for a `for` loop over the bytes with variable enables).

3. `rtl/ap68040_dmu.sv`: the table walk samples its data-cache tag
   compare one wait state later (`E_TW_DESCW2`), after the tag RAM's
   registered port B address has taken the descriptor's set; before, the
   compare looked at the previously addressed set and a false hit or miss
   corrupted the walk (the NeXT kernel's page-fault loop on hardware,
   2026-10-19).  `tb/asm/t_nx8k.s` reproduces it.
4. `rtl/ap68040_dmu.sv`: the DC2 job's kill mark (`e_kill`) is cleared
   when the job is scheduled in `E_IDLE`, not in `E_S_START`: the engine
   is frozen while the snooper holds the cache but the kill block is
   not, so a kill landing on a frozen `E_S_START` was erased when its
   body ran, the dead job completed, and the next uop into DC2 took its
   data (OPENSTEP panics under disk DMA on the NeXT, 2026-10-19).
   `tb/asm/t_snkill.s`, the bench's `$F2F0` coincidence counter and
   traffic bit 13 (a random hold before each snooped transfer), and a
   self-check at `E_S_DONE`.

All four are candidates for upstream; the third and fourth are bug
fixes, pushed on 2026-10-19 as
https://github.com/apolkosnik/AP68040/pull/9 (branch `walker-tag-compare`,
merged) and https://github.com/apolkosnik/AP68040/pull/10 (branch
`dead-job-kill`).

## History

Until 2026-10-18 this directory held the sequential `ap040_*.v` core as
vendored in MacQuadra800_MiSTer (imported tree `8778213`, Alan
Steremberg's performance stack over Adam Polkosnik's base), with the NeXT
port's 32-bit beat adapter (`ap040_bus32_adapter.v`).  The old
`UPSTREAM.md` and `docs/CPU_NEXT_PORT.patch` describe that tree; both are
in git history.

## Tests

```bash
cd rtl/ap68040/tb && JOBS=12 WORK=/path/outside/tmpfs bash run_tests.sh   # Verilator 5, vasmm68k_mot
```

The default object directory is `rtl/ap68040/obj/` (ignored by git).
