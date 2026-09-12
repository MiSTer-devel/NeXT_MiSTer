# ESP transfer information

`next_scsi.sv` implements Transfer Information (TI, `0x10` / DMA `0x90`)
for all six initiator information phases. The protocol reference is the
[NCR 53C90A/53C90B data sheet, page 29](https://www.bitsavers.org/components/ncr_symbios/scsi/53C90/53C90A-53C90B_Advanced_SCSI_Controller_1991.pdf#page=29).
Previous's unimplemented TI paths are not a completion model: some return
without transferring bytes, or schedule an interrupt with no cause.

| Phase | Transfer and completion |
| --- | --- |
| Data out | Consume FIFO or memory-DMA bytes into the target's sector buffer; report Bus Service on FIFO/count exhaustion or a target phase change. |
| Command | Accumulate the CDB across selection and TI commands; dispatch only after its full length arrives, then report Bus Service. |
| Message out | Consume IDENTIFY/NOP or a complete extended message, retaining parsing state across TI commands; unsupported messages receive MESSAGE REJECT. TI reports Bus Service. |
| Data in | PIO receives one byte per Bus Service interrupt; DMA retains its existing counted transfer path. |
| Status | Receive the actual status byte, enter message-in, and report Bus Service. |
| Message in | Receive the message byte and report Function Complete; wait for MESSAGE ACCEPTED before advancing. Accepting MESSAGE REJECT resumes command phase; accepting command completion disconnects. |

PIO does not alter the transfer counter, even if the external DMA routing
bit is enabled. DMA decrements the counter only for transferred bytes and
preserves residual FIFO/buffer bytes when the target changes phase.
Select with ATN and Stop (`0x43`) leaves message-out for a subsequent TI.
An incomplete selection CDB remains in command phase for subsequent TI.
Input waits for FIFO space; DMA can wait for the host to rearm its channel.
Those waits must not report successful transfer before receiving a byte.

Status and message input use the same NeXT DMA buffering contract as short
data input: partial words remain buffered until software writes
`ESPCTRL_FLUSH`. Terminal count can become visible before the delayed ESP
interrupt. A flush during that interval must preserve the pending
interrupt, including at the DMA window limit. A flush on the interrupt's
expiry edge must not deliver it a second time after software acknowledges
it.

`tb/tb_next_scsi_ti.svh`, included by `tb_next_scsi.sv`, exercises the real
register interface with the existing RAM and disk models. It checks byte
contents, phase, interrupt cause, residual counts and retained bytes for
PIO and DMA transfers, split CDBs/messages, sector boundaries, full FIFO
backpressure, exhausted DMA windows, and the flush/interrupt race. The
main bench also checks that every asserted ESP interrupt has a nonzero
cause and retains the late chained-DMA restart regression.

## A completed transfer must remain complete

The September 10 hardware capture using `NeXT_20260910_scsi_ti_fix.rbf`
showed mkfs asleep in the raw write path. The ESP driver was idle with no
active request, but the controller was marked busy with its timeout off.
Its last interrupt snapshot was status/sequence/cause `90/04/00`. The
kernel's handler can leave this state after an interrupt arrives while idle.

A register-level reproduction found a further RTL defect: after a DMA TI
completed, clearing `ESPCTRL_MODE_DMA` rerouted the residual-buffer state
into the FIFO transfer engine. That engine saw terminal count and scheduled
the same completion again. Acknowledging the original interrupt cleared
the cause before the duplicate interrupt arrived. Multiple queued FLUSH
writes could also return to the completed transfer after draining its data.
The old write regression did not retain any prefetched bytes, so it missed
this path; an unaligned DMA start exercises it.

`transfer_reported` now records that TI/PAD has delivered its completion,
independently of the DMA buffer's remaining bytes. New TI/PAD commands clear
it. NOP, FIFO flush, DMA route changes, and memory-channel rearming do not.
Completed input may still drain a retained full buffer, or partial words
through FLUSH, but cannot generate another transfer completion. Completed
output preserves unsent bytes for the next transfer.

`tb/tb_next_scsi_irq.svh` checks the 8 KiB read with a closed DMA window,
NOP and FIFO-flush handling, rearming and draining the last word, delayed
padding pumps, and a write with twelve prefetched bytes left over. It checks
byte contents and interrupt causes, quiet intervals after acknowledgement,
ICCS/disconnect, and a subsequent DMA command. These tests reproduce the
controller defect. Subsequent hardware findings are recorded below and
in [DMA completion acknowledgement](SCSI_DMA.md).

Validation of the completion fix:

- The same new regression fails against the RTL used for
  `NeXT_20260910_scsi_ti_fix.rbf`, including zero-cause interrupts with
  status/sequence `90/04` after both reads and writes.
- The corrected RTL passes the complete SCSI bench, including the new
  regression and the existing transfer-information cases.
- `./tb/run_tests.sh` passes all device suites and both ROM boot smoke tests.
- The full Quartus build and `tb/check_timing.sh` pass under the existing
  constraints: worst setup slack `+0.639 ns`, worst hold `+0.249 ns`,
  CPU-clock setup `+5.488 ns`.

The intermediate diagnostic bitstream was
`NeXT_20260911_scsi_idle_irq_fix.rbf`,
4,423,632 bytes, SHA-256
`fb8f51df18dd8cca0bfcb0d544236e37a8bf1d56613ba47f89f626e36519f100`.

The next installation run exposed a separate
[DMA completion-acknowledgement race](SCSI_DMA.md). That failure retains
an active request with a valid ESP cause and must be distinguished from
the idle duplicate-interrupt failure above.

Run `./tb/run_tests.sh` for the device suite and ROM boot smoke tests.
Simulation confirms these controller defects and their repairs. With the
additional DMA acknowledgement fix, a hardware installation subsequently
rebooted from the installed hard disk without the earlier timeout/panic
state in the captured RAM. A later UI wait remains unresolved; see the
[hardware retest and final RBF](SCSI_DMA.md#hardware-installation-retest).
