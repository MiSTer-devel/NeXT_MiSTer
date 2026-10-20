# DSP56001 in this repository

This directory is the DSP56001 block of Falcon_MiSTer (`rtl/falcon/dsp`),
taken from the local checkout at **082efe3** (2026-10-19; the directory's
last change dcd9826) on 2026-10-19.  It follows Hatari's `dsp_cpu.c` and
`dsp_core.c` instruction by instruction (see the headers of
`dsp56k_core.sv` and `dsp_periph.sv`), and is verified against Hatari by
Falcon_MiSTer's `tb/dsp` differential testbench.  The NeXT side (host
port decode, the DMA channel, SCR2/BMAP/interrupt glue) is
`rtl/next/next_dsp.sv`, described in `docs/DSP_INTEGRATION.md`.

## What was taken

| upstream | here |
|---|---|
| `dsp56k_core.sv`, `dsp56k_alu.sv`, `dsp56k_dec.sv`, `dsp56k_rom.sv`, `dsp56k_tables.svh`, `dsp_periph.sv`, `dsp_ram.sv` | same |
| `falcon_dsp.sv` (the Falcon top: crossbar SSI link, 68030 bus) | kept, unused by the NeXT build: it is the top the differential harness drives |
| `tb/dsp` (the harness) | not taken; run in place, see below |

## Local changes

All are parameters or inputs that leave the Falcon configuration
(`MEMMAP 0`, `EXT_AW 15`, `HOST_DMA 0`, `boot_mode 1`, `ext_en 1`,
`irqb 0`) behaving as before; the harness passes with them (12 tests,
600 random seeds, 926,545 instructions cycle-exact, 2026-10-19).

1. `dsp56k_core.sv`: parameters `MEMMAP` (1 = the NeXT's single external
   memory: an address with A15 clear modulo the size, with A15 set half
   of it with X in the upper half; Previous `dsp_cpu.c` read_memory) and
   `EXT_AW` (the external RAM's size, 8K words on the NeXT); the program
   fetch goes through the same map.  Input `ext_en`: the external RAM
   reads 0 and drops writes while clear (the SCR2 memory enable).
2. `dsp56k_core.sv`: input `irqb`, a pulse that sets a pending IRQB,
   taken at the level IPR bits 4:3 give, vector P:$0004, ahead of the host
   port at the same level, released when taken (Previous's "IRQB
   simplified for NeXT"), and releasing WAIT.
3. `dsp56k_core.sv`: input `boot_mode`, the start mode at `run_start`
   (SCR2 bits 4:3 inverted): 2 starts at P:$E000, 0 copies external
   P:$C000-$C1FF into internal P RAM first (state `ST_BOOT`), 1 is the
   host-port bootstrap as on the Falcon.
4. `dsp_periph.sv`: parameter `HOST_DMA` (1: an ICR write with HM1:HM0
   set puts ISR.DMA up, Previous `dsp_core_write_host`), outputs
   `dma_mode` (ICR HM1:HM0) and `dma_treq` (ICR TREQ) for the NeXT DMA
   engine, input `boot_mode`: the host-port bootstrap only in mode 1,
   modes 0 and 2 start the core as the reset is released.

## Tests

The Falcon harness against this copy, in its Falcon configuration
(Hatari at `/home/adam/hatari`, the harness in
`/home/adam/Falcon_MiSTer/tb/dsp`):

```bash
bash rtl/dsp56k/../../tb/run_dsp_harness.sh
```

`tb/tb_next_dsp.sv` (`tb/run_tests.sh`, `tb_dsp`) drives `next_dsp` the
way the kernel's driver does: host-port reset values, the mode-1
bootstrap and PIO exchange, HREQ at levels 3 and 4 (BMAP), DMA in both
directions in packed and unpacked words with IRQB at the block end, start
modes 2 and 0, the memory enable.
