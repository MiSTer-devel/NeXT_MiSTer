# Integrating the Falcon DSP56001 (`Falcon_MiSTer/rtl/falcon/dsp`) into NeXT

## Status (2026-10-19, evening)

Implemented on `pipelined_040`:

- `rtl/dsp56k/`: the Falcon block vendored as-is plus four small,
  parameterised changes (`rtl/dsp56k/UPSTREAM.md`): the NeXT memory map
  and 8K-word external RAM (`MEMMAP`, `EXT_AW`), the external memory
  enable, an IRQB input, the three start modes, and in the peripheral
  block the host DMA mode bits (`HOST_DMA`, `dma_mode`, `dma_treq`) and the
  mode-gated bootstrap.  Falcon_MiSTer's differential harness passes
  against this copy in its Falcon configuration (12 tests, 600 random
  seeds, 926,545 instructions cycle-exact): `tb/run_dsp_harness.sh`.
- `rtl/next/next_dsp.sv`: the host port at 0x02008000 on the 16-bit
  sub-cycle bus, the DMA channel 0x020000d0 / 0x020040d0 / 0x020042d0
  (packed 24/16/8-bit and unpacked 32-bit words, both directions, chaining,
  IRQB at the block end), the interrupt routing (INT_DSP_L3, INT_DSP_L4
  through the BMAP enable, INT_DSP_DMA).  A seventh master of the RAM
  arbiter (`G_DSP`); SCR2 byte 0 bits 7:3 and byte 3 bits 6:5 and BMAP
  register 3 bits 29:28 are decoded in `next_scr.sv` / `next_bmap.sv`.
  The SSI is idle (the DSP port is not wired).  The block runs on the
  27.5 MHz system clock.
- `tb/tb_next_dsp.sv` (`tb_dsp` in the suite): reset values, the mode-1
  bootstrap and PIO exchange, HREQ at levels 3 and 4, DMA both ways,
  packed and unpacked, IRQB, start modes 2 and 0, the memory enable.

The fit (2026-10-20, seed 13): 41,301 / 41,910 ALMs (99 %), 550 / 553
M10K, 34,790 registers; the CPU clock closes (setup +0.283 ns, hold
+0.171 ns) and only the HDMI PLL's setup misses (-0.418 ns, the path the
user accepts), so the RBF is staged by hand as
`releases/NeXT-ap68040-55mhz-dsp_20261020.rbf` outside the release gate.
The DSP block synthesises to 8,545 ALUTs and 2,304 registers here (the
Falcon's 5,702 ALMs packed).

Not done: the SCI TXD interrupt (`bmap_txd_en` is accepted and unused),
the SSI/DSP port, the Turbo SCR2 variants, a kernel-level test (the
OPENSTEP SoundDSP driver on the boot bench), and any slack for later
features: at 99 % every build is a seed hunt (see "Resources" below).

Investigation of 2026-10-19 (the plan the above follows).  Sources read: the Falcon block
(`falcon_dsp.sv`, `dsp56k_core.sv`, `dsp_periph.sv`, `dsp_ram.sv`, its
`tb/dsp` harness and `tb/dsp/syn` fit), Previous (`src/dsp/dsp.c`,
`dsp_core.c`, `dsp_cpu.c`, `sysReg.c`, `dma.c`, `bmap.c`, `snd.c`,
`ioMemTabNEXT.c`) and this core's fit reports.

## What the Falcon block is

A DSP56001 that follows Hatari's `dsp_cpu.c`/`dsp_core.c` instruction by
instruction and cycle by cycle (one DSP clock per `clk`, 2 clocks per
instruction cycle), with the host port, SSI, port C and the IPR/BCR/SCI
storage, and these memories: 32K x 24 external RAM, 512 x 24 internal P
RAM (bootstrap target), 256 x 24 internal X and Y RAM, the X/Y ROM tables
(mu-law/A-law, sine), 128 x 24 peripheral storage.  Verified against
Hatari by a differential testbench (`tb/dsp/run.sh`: lockstep random
programs, directed tests, host-port tests, crossbar integration).

Resources, measured in the Falcon `040all` build of 2026-10-19
(`Falcon-040all_20261019.rbf`, the block inside a full design that fits
at 40,866 of 41,910 ALMs, 98 %):

| | ALMs | registers | M10K | DSP blocks |
|---|---:|---:|---:|---:|
| **falcon_dsp total** | **5,702** | **2,217** | **104** | **1** |
| core: control, AGU, moves, loops | ~4,590 | ~1,600 | | |
| ALU (MAC, shifter) | 651 | 226 | | 1 |
| instruction decoders (2) | 99 | | | |
| peripherals (host port, SSI, timers) | 316 | 388 | 2 | |
| external RAM, 32K words x 24 bits | 54 | 4 | 96 | |
| internal X, Y and P RAM, ROM tables | | | 6 | |

(The block alone, `tb/dsp/syn`, synthesises to 6,733 ALMs; packed into
the full design it is 5,702.  Fmax about 34.5 MHz at the slow 100C
corner.)  96 of the 104 M10Ks are the Falcon's 32K-word external memory;
the core itself has already been squeezed in the Falcon's own ALM rounds.
For scale, the Falcon's AP68040 is 18,532 ALMs, 132 M10K and 15 DSP
blocks in that build.

Interfaces: a 16-bit 68030-style register bus for the host port (`bus_cs`,
`bus_stb`, `bus_we`, `bus_addr[2:1]`, `bus_uds/lds`, ack on the strobe
clock), `hreq` (level, ISR.HREQ) and `ivr`, a level `dsp_reset`, and the
SSI as a slot link to the Falcon crossbar (`ssi_slot_stb`, frame, 16-bit
rx/tx data, handshake lines).  Bootstrap: after reset the next 512 words
written through TXH/TXM/TXL land in P:$0000-$01FF and the DSP starts at
P:$0000 (Hatari's shortcut for OMR mode 1); the real bootstrap ROM is not
executed.

## What the NeXT needs (Previous as the reference)

**Host port**, `0x02008000-0x02008007`, byte registers in the same order as
the Falcon's `$FFA200-7`: ICR, CVR, ISR, IVR, TRX0, TXH/RXH, TXM/RXM,
TXL/RXL (`ioMemTabNEXT.c`).  Byte 4 (TRX0) reads 0 and is the fourth data
byte of the "unpacked" DMA mode.  Without a DSP Previous returns 0x7F for
ICR and 0xFF for CVR/ISR/IVR; this core returns 0.

**SCR2** (`sysReg.c`), byte 0: bit 7 `DSP_RESET` (1 = reset released and
the DSP started, 0 = held in reset), bits 4:3 `MODE_B/MODE_A` (inverted:
OMR mode `(~scr2_0 >> 3) & 3` at the release: 0 = bootstrap from external
P:$C000, 1 = bootstrap through the host port, 2 = start at P:$E000), bit 6
`DSP_BLK_END` (IRQB to the DSP at the end of a DMA block), bit 5
`DSP_UNPKD` (32-bit DMA words: TRX0 as a fourth byte).  Byte 3: bit 6
`DSP_INT_EN` (HREQ raises `INT_DSP_L4` when set, `INT_DSP_L3` when clear;
the diagnostics expect L3), bit 5 `DSP_MEM_EN` (external DSP RAM enable,
inverted on non-Turbo).  Byte 1 bit 7 `DSP_TXD_EN` is Turbo only.  This
core's `next_scr.sv` stores all four bytes already and decodes none of the
DSP bits.

**Interrupts**: `INT_DSP_L3` (bit 6), `INT_DSP_L4` (bit 14), `INT_DSP_DMA`
(bit 20) of the interrupt status register (`next_intc.sv` has the 32-bit
set/clear ports).  On non-Cube machines BMAP bits 29/28 gate the HREQ and
TXD interrupts (`bmap.c`); `next_bmap.sv` would gain two enables.  TXD is
the DSP's SCI output pin wired as an interrupt source (rare).

**DMA channel** `0x020000d0` (CSR) with its next/limit/start/stop/init
registers in the `0x02004000` block (`dma.c` CHANNEL_DSP).  When ICR
HM1:HM0 != 0 the host port is in DMA mode: HREQ becomes a DMA request
instead of an interrupt (`DSP_HandleHREQ`), and the DMA engine moves
`4 - mode` bytes per DSP word (3, 2 or 1) between memory and TXH..TXL /
RXH..RXL in address order, with the unpacked bit adding TRX0 as a fourth
byte (`DSP_HandleDMA`); direction from ICR TREQ/RREQ; at the limit the
channel interrupts (`INT_DSP_DMA`) and, with `DSP_BLK_END`, pulses IRQB
into the DSP.  Byte granularity to RAM, like the printer channel.  This
core's DMA engines are per device (`next_printer`, `next_scsi`, sound,
Ethernet, MO: the six masters `G_*` of `next_system.sv`'s arbiter, each
with `*_m_req/addr/be/din/ack/err`); a DSP channel is a seventh master of
the same shape, modelled on the printer's memory-to-device stream plus the
reverse direction.

**External DSP memory** (`dsp_cpu.c`, Previous): 8K words standard
(24 KB), 32K with the memory expansion module.  Standard map: external RAM
at $2000-$3FFF (A13 must be high), where P, X and Y are one physical
memory ("image 1"); at $A000-$BFFF X and Y are separate 4K banks and P
overlaps both ("image 2"); $0200-$1FFF and $8000-$9FFF disabled; mirrors
of each image above it.  Previous implements it as: A15 clear -> `ramext[a
& (SIZE-1)]`; A15 set -> Y in the lower half, X in the upper half.  The
Falcon core hard-codes its own map (P external at [14:0], X at
$4000|[13:0], Y at [13:0], 32K words, `ext_addr()` in `dsp56k_core.sv`).

**SSI**: on the NeXT the SSI is the DSP port (DB-15) and the CODEC link;
Previous feeds it 44.1 kHz host audio input (`snd.c` SND_DSP_Handler,
`DSP_SsiReceive_SC0`) and the kernel's SoundDSP driver speaks of a
"codec->dsp link".  No crossbar: the Falcon slot-link protocol has to be
replaced by a NeXT clock/frame generator (or left idle: the SSI then never
frames and the DSP side waits).

**Bootstrap**: NeXTSTEP loads DSP programs through the host port (mode 1,
which the Falcon shortcut covers).  Modes 0 and 2 (external P:$C000 and
P:$E000, used with DSP memory boards) need either the real bootstrap ROM
run on the core (Previous's accurate mode keeps the 32-word P ROM) or an
equivalent shortcut.  Previous also models `mode_wait` (an OMR MA/MB write
takes effect three instructions later).

**Clock**: the NeXT DSP56001 runs at 25 MHz (12.5 MIPS).  The Falcon block
meets 32 MHz; on `clk_sys` (27.5 MHz) it runs 10 % fast with no clock
crossing on the register bus.  A true 25 MHz output is available (the PLL
uses 3 of 9 outputs) at the cost of a CDC on the host port, the DMA
channel and the interrupt lines; the speed difference only matters for
SSI bit clocks derived from the DSP clock.

**What the OS does with it**: the kernel's SoundDSP driver (strings in
the RAM dumps: "codec->dsp link", "dsp_dma: Timed out waiting for TRDY!",
"DSP DMA write truncated by early complete interrupt!") drives the host
port in DMA mode; SoundKit decompresses the NeXT compressed sound formats
on it; the MusicKit synthesises on it.  The boot ROM never touches the
DSP (no reference in the ROM listing), and the kernel boots without it.

## Gaps between the Falcon block and the NeXT

| Area | Falcon block | NeXT | Work |
|---|---|---|---|
| Host port registers | byte order identical | identical | adapter from this core's 32-bit byte lanes to `bus_uds/lds` |
| Host DMA mode | none (`dsp_periph.sv` has no HM1:HM0, TREQ/RREQ requests, TRX0) | required by the kernel's driver | add DMA mode, request lines, TRX0, IRQB input to the core |
| Bootstrap | host port, mode 1 only | modes 0, 1, 2 from SCR2 | add mode 2 start address, mode 0 or the real P ROM, `mode_wait` |
| External memory | 32K, Falcon map | 8K image 1/2 (32K expansion) | parametrise `ext_addr()` and the size; the enable bit |
| Interrupts | `hreq` level + `ivr` | L3/L4 by SCR2, BMAP gating, TXD, `INT_DSP_DMA` | glue in `next_system`, `next_scr`, `next_bmap` |
| SSI | crossbar slot link | DSP port / codec link | NeXT SSI clocking, or idle |
| Reset / modes | level from PSG port A | SCR2 bit 7, modes 4:3 | glue |
| Clock | 32 MHz | 25 MHz | `clk_sys` or a new PLL output |

## Resources: tight, not impossible

Current NeXT fit (seed 11, 2026-10-19): 35,259 / 41,910 ALMs (84 %),
518 / 553 M10K (94 %), 69 / 112 DSP blocks.

ALMs: 35,259 + 5,702 = 40,961, 97.7 % of the device.  The Falcon's own
build fits at 98 % with this block in it, so the number is not out of
reach, but this core's fitter history (the Quadra recipe, seed walks
closing timing at 84-91 %) says every such fit is a seed hunt and any
later feature has nowhere to go.  Two or three thousand ALMs of slack
would make it routine: make the slot-style peripherals build-time
optional (MO drive with its ECC, printer, CD audio, floppy: measure each
with `quartus_map` hierarchy reports; the Falcon core does this with
`FALCON_BRINGUP="NO_IDE NO_FDC NO_DSP"`), or a "DSP build" variant of the
core that drops them.  The CPU's optional features are already off.

M10K: 96 of the block's 104 are the 32K-word external RAM.  A NeXT-sized
8K-word external RAM is 24 blocks (8K x 24 as 512 x 20 slices, as the
Falcon's 32K is 96), so the block becomes 104 - 96 + 24 = 32, and
518 + 32 = 550 of 553: it fits with three blocks to spare.  The 32K
expansion (the full 104) does not, and neither does anything else.
Where the 518 go (synthesis RAM summary): VRAM 256 KB = 208 blocks, boot
ROM 96 KB = 80, the CPU's predecode ROM 32 and microcode 12, CD audio
frame RAM 8, scaler line buffers ~25, the rest small.  Moving the boot ROM
into DDR3 (read-only, boot-time traffic, a small cache in front) frees 80
blocks, enough for the 32K expansion with headroom, and is the natural
companion change; VRAM into DDR3 frees 208 but touches video timing.

## Suggested path

1. Area first: a `NEXT_DSP` build variant with the big optional
   peripherals off, measured, so the fit has slack; the boot ROM into
   DDR3 if the 32K expansion is wanted.  At 97.7 % ALMs and 550 M10K the
   block fits numerically without either, but every build becomes a seed
   hunt.
2. A NeXT wrapper `rtl/next/next_dsp.sv` around the Falcon block (taken
   as-is, like the CPU, with a provenance note): the host-port byte-lane
   adapter, SCR2 bits, interrupt routing (L3/L4, BMAP, TXD), the DSP DMA
   channel as the seventh master of the RAM arbiter, IRQB at block end.
3. Changes inside the block, kept small and upstreamable to the Falcon
   repository: host DMA mode (HM1:HM0, TREQ/RREQ, TRX0), a memory-map
   parameter (Falcon / NeXT 8K / NeXT 32K), start modes 0/2 and
   `mode_wait`, an IRQB input.
4. Verification: the Falcon `tb/dsp` differential harness re-pointed at
   Previous's `dsp_cpu.c`/`dsp_core.c` as the golden model for the NeXT
   variant (they differ from Hatari's by about 300 lines: the memory map,
   `mode_wait`, the bootstrap ROM, the DMA fields), a host-port/DMA bench
   against Previous's `DSP_HandleDMA` semantics, and `tb_next_boot` with
   the kernel's SoundDSP driver (the console strings above are what it
   prints when the DSP misbehaves).
5. Hardware: NeXTSTEP sound playback of a compressed `.snd`, the MusicKit
   examples, `/usr/bin/dspdoc` style tools.

The Falcon core has no IRQA/IRQB pins (`dsp56k_core.sv` has no external
interrupt input; the Falcon never drives them), so the block-end IRQB is
new logic in the core's interrupt controller, not just a wire.

Open questions: what the kernel
does when the DSP is absent today (reads of 0 instead of 0x7F/0xFF) and
whether matching Previous's absent values is a cheap interim fix; the
Turbo (68040 NeXTstation) SCR2 differences (`DSP_TXD_EN`, non-inverted
`DSP_MEM_EN`), since this core is a 68040 machine but models the non-Turbo
SCR2 reset values.
