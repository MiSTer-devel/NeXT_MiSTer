# DMA completion acknowledgement

The September 11 installation failure on
`NeXT_20260911_scsi_idle_irq_fix.rbf` exposed another DMA race. A new
register-level regression reproduces the saved stopped-channel state and
the missing final 16 bytes of an 8192-byte WRITE(10).

## Failure

NeXTSTEP's interrupt handler reads `ENABLE|COMPLETE` (`09000000`) after
the first DMA descriptor. It rotates its software list, writes the next
START/STOP pair, then acknowledges with `SETSUPDATE|CLRCOMPLETE`.

The second descriptor may finish between that CSR read and the later
acknowledgement. Previously, the RTL unconditionally cleared COMPLETE.
It left the channel disabled with only SUPDATE (`02000000`), even though
SCSI still needed bytes from the final descriptor. No DMA interrupt
remained to restart the channel, and the SCSI timer eventually expired.

The existing late-handler regression delayed the initial CSR read until
the channel stopped. It did not cover a stop *after* the handler read a
running channel but *before* it acknowledged that completion.

## Repair

CLRCOMPLETE now acknowledges a running or explicitly reenabled channel.
A stopped channel retains COMPLETE until RESET or explicit reenable, so
Mach's post-write CSR check can detect the lost chain and restart it.
A completion or bus exception generated on the same clock as an
acknowledgement takes precedence over that acknowledgement. RESET can
still clear a simultaneous engine completion.

The [NeXT register definitions preserved by NetBSD](https://github.com/NetBSD/src/blob/trunk/sys/arch/next68k/dev/nextdmareg.h)
describe CLRCOMPLETE as conditional. The
[NetBSD driver](https://github.com/NetBSD/src/blob/trunk/sys/arch/next68k/dev/nextdma.c)
uses CLRCOMPLETE in the running-channel branch and RESET for a stopped
channel. The specific race requirement is also visible in the captured
Mach 3.3 kernel: `0407ca52..0407ca5c` writes the acknowledgement;
`0407ca98..0407cac6` rereads CSR and handles `0a000000` / `1a000000` by
restarting the remaining descriptor.

The implementation does not add a delay to hide the race. Its correctness
does not depend on the CPU servicing the interrupt within one DMA window.

## Validation

`tb/tb_next_scsi_dma_csr.svh` drives the captured descriptor lengths:
7920 bytes, 256 bytes, then a 48-byte bounce window whose first 16 bytes
finish the command. The previous RTL produces
`before=09000000 after=02000000 residual=16`. The corrected RTL preserves
`after=0a000000`; restarting the tail completes TI and all 8192 bytes
compare exactly on disk.

The same regression checks acknowledgement concurrent with a new chained
completion, a stopped completion, and an enable-time bus exception. All
fail against the previous RTL and pass after the repair. The complete
device suite and both ROM boot smoke tests pass with `./tb/run_tests.sh`.

The full Quartus build and timing gate also pass under the existing
constraints: worst setup `+0.401 ns`, worst hold `+0.236 ns`, CPU-clock
setup `+6.645 ns`. The replacement bitstream is
[`NeXT_20260911_scsi_dma_csr_fix.rbf`](../releases/NeXT_20260911_scsi_dma_csr_fix.rbf),
4,423,552 bytes, SHA-256
`1c7302c1f634222fef88d06b43d6dd881d07b8f78d139fb65e755f82f9461fb7`.

## Panic after the timeout

The second live RAM snapshot records a panic during cleanup of a later
CD-ROM read. The shared DMA structure still carries the failed write's
shift flag and mkfs pmap, while mkfs has exited and that pmap's counts are
zero. The saved `_vcopy` arguments refer to that old user map, and the
reported `_bcopy` destination is zero. This is consistent with stale
write-cleanup state being applied after its process address map was
cleared; it is not evidence by itself of a separate CPU MMU defect.

Full RAM dumps, checksums, decoded descriptors, stack analysis and the
loaded RBF hash are retained locally in `tb/build/live_20260911_timeout/`.

## Hardware installation retest

The replacement RBF was subsequently tested on hardware as NeXT-049.
Its SHA-256 matched the release above. The recovered kernel log records
the installation environment shutting down, unmounting its target, and
rebooting from the installed hard disk (`root on sd0`).

The user reported an apparent freeze after installation. Two further
64 MiB RAM snapshots show no panic, no active SCSI request, and an empty
controller queue. The guest clock advanced 49 seconds and a WindowServer
thread continued executing. BuildDisk was waiting in Mach message receive;
the input-event queue was empty. This run progressed beyond the earlier
write timeout and panic, but the cause of the later UI wait remains
unresolved. It does not establish that every installation path is correct.

Those captures and the repeatable analysis are retained locally in
`tb/build/live_20260911_postinstall_2234/`.
