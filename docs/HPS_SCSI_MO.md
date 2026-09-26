# HPS-served SCSI responses, CD audio and MO ECC

The SCSI target's command responses, the CD-ROM's audio playhead and the
magneto-optical controller's Reed-Solomon codec run on the ARM in
Main_MiSTer (`support/next/`, branch `next-fixes`) instead of in the FPGA.
This is the Quadra 800 core's "Main-served SCSI" design duplicated for the
NeXT: every exchange is an ordinary hps_io block read or write of a
"magic" LBA far above any disk, intercepted in Main's sector service before
the generic image path. No new HPS protocol, no framework change.

Motivation: `next_rs` (1,219 ALMs) and the target's response tables
(~500) were the largest device-side logic after the CPU; see
docs/PERF_PROFILE.md "Options" and the Stage 2/3 fit budget in
docs/PERF_PLAN.md. A build without the MO cannot drop the codec anyway:
the v66 ROM's POST runs the OSP ECC test unconditionally on a Cube040.

## Windows

All windows use the slot's normal `sd_lba`; Main's `next_sd_service`
(`support/next/next_scsi.cpp`) takes any LBA >= 0x7C000000 on the CD-ROM
slot (3) or the MO slot (5), and every data read of the CD-ROM slot while a
translated (cue/bin, chd, raw-2352) image is mounted.

| window | slot | LBA | direction | payload |
|---|---|---|---|---|
| response | 3 | `0x7E000000 \| unit<<20 \| flags<<16 \| op<<8 \| a` | read, 1 block | the response bytes; length big-endian at bytes 510..511 |
| command | 3 | `0x7D000000 \| unit<<20 \| op<<8` | write, 1 block | the CDB at bytes 496..505, a MODE SELECT list at 0.. |
| audio frame | 3 | `0x7C000000` | read, 5 blocks | 2352 bytes of 16-bit LE stereo PCM, pad at 2352 = state, 2353 = frame present, 2354..2357 = flush generation |
| ECC | 5 | `0x7E000000 \| op<<8` (1 encode, 2 decode) | write 3 blocks, then read 3 blocks | the 1296-byte bank; on the read back byte 1296 = uncorrectable, 1297 = corrected-byte count |

Response ops and their `flags`/`a`:

| op | for | flags | a | Main builds |
|---|---|---|---|---|
| 0x12 INQUIRY | any unit | bit 3 = LUN != 0 | - | the same 54 bytes the RTL used to ("Previous" / "HDD" or "CD-ROM") |
| 0x25 READ CAPACITY | any | - | - | last LBA from the mounted image size, 512-byte blocks |
| 0x1A MODE SENSE | any | bit 0 = DBD | cdb2 (pc, page) | pages 0/1/3/4/3F as before; page 4 geometry = ceil(blocks/128); CD units also 0x0E (audio ports) and 0x2A; unknown page = length 0 (the RTL answers CHECK CONDITION / invalid CDB) |
| 0x43 READ TOC | CD | bit 0 = MSF, bits 2:1 = format | start track | SCSI-2 formats 0, 1, 2 from the cue/chd track list |
| 0x42 READ SUB-CHANNEL | CD | bit 0 = MSF, bit 1 = SubQ | format | the playhead's position and audio status |

Forwarded commands (CD unit only; the RTL answers GOOD after the block
write lands): PLAY AUDIO 0x45/0x47/0x48/0xA5, PAUSE/RESUME 0x4B, STOP PLAY
0x4E, REZERO 0x01, SEEK 0x0B/0x2B, START/STOP 0x1B, MODE SELECT 0x15
(the DATA OUT list is collected in the sector buffer first, then the block
is written). REQUEST SENSE stays in the RTL: the sense is the engine's
own state. The data paths (READ/WRITE 6/10, the SD sector transfers) are
unchanged.

Timing: a window costs one Main poll each way (~0.1-1 ms). INQUIRY, MODE
SENSE and READ CAPACITY happen at probe time; the ECC exchange costs two
polls per sector, which is on the order of the real drive's sector time.

## Where

FPGA:
- `rtl/next/next_scsi.sv`: the response tables are gone; `X_WIN_GO/ACK/DONE`
  fetch a response block into `dbuf` (the length rides in bytes 510..511),
  `X_CMD_FILL/GO/ACK` forward a CDB. `sd_unit` is forced to 3 during a
  window (`win_act`). The CD-ROM slot is shared with the audio engine:
  `sd_hold` (audio owns or wants the channel) blocks new transfers and
  masks `sd_ack`; `sd_busy` tells the engine the target is idle.
- `rtl/next/next_cd_audio.sv`: the FETCH/SAMPLE part of the Quadra's
  `cd_audio.sv`: a two-frame ping-pong filled from the frame window, the
  44.1 kHz cadence with interpolation. A forwarded transport command
  (`cd_fwd_stb`) starts a fetch whose pad reports the real state. Summed
  into the sound output in `next_system` with saturation.
- `rtl/next/next_mo.sv`: `next_rs` is replaced by the `hst` exchange in
  `ECC_RS`: write the transform bank (3 blocks), read it back, the
  fail/count bytes become `rs_fail`/`rs_count`. `sd_blk_cnt` = 2 while it
  runs. `rtl/next/next_rs.sv` is deleted.
- `NeXT.sv`: `sd_blk_cnt` per slot (slot 3: 4 for a frame, slot 5: 2 for
  the ECC); the CD-ROM OSD entry takes ISO, CUE, BIN and CHD.

Main (`Main_MiSTer/support/next/`, no comment lines by the user's rule):
- `next_scsi.cpp/h`: the mount hook (records unit sizes, translates CD
  images), `next_sd_service` (the window dispatch, beside `mac_sd_service`
  in `user_io.cpp`), the disk responses.
- `next_cdrom.cpp/h`: cue/bin, chd and raw image mounting on the CD slot
  (from `mac_cdrom.cpp`), the data window, the frame window, the command
  window.
- `next_cdrom_resp.cpp/h`: READ TOC / READ SUB-CHANNEL builders.
- `next_cdrom_play.cpp/h`: the playhead (from `mac_cdrom_play.cpp`, the
  Apple vendor ops removed), volume law `(v/255)^5`.
- `next_mo.cpp/h`, `next_rs.cpp/h`: the ECC window and the Reed-Solomon
  codec, a port of Previous `src/rs.c`.
- Registration: `support.h`, `user_io.cpp` (mount hook, unmount, sector
  service).

## Testing

- `tb/host/test_next_host.cpp` (native, built and run by `tb/run_tests.sh`):
  the codec against Previous's golden vectors (`tb/rs_vectors.hex`, the
  POST pattern with 36 corrected bytes), the ECC window round trip, every
  SCSI response table against the bytes the RTL used to build, the page-4
  geometry cases of the old `tb_next_scsi_geometry`.
- The Verilator benches co-simulate the real Main sources through DPI-C
  (`tb/host/next_host_dpi.cpp`, shims in `tb/host/shim/`, sources copied by
  `tb/host/sync_main.sh` from `../../Main_MiSTer` or `$MAIN_SRC`): the SD
  slot models of `tb_next_boot`, `tb_next_scsi` and `tb_next_mo` hand
  window transactions to `host_fill`/`host_exec`. The boot bench's POST
  therefore runs the ROM's ECC system test through the same code that
  ships in Main.
- Hardware needs the matching Main (`support/next` present): with a
  stock Main the target answers every INQUIRY with CHECK CONDITION and the
  ROM finds no disk, which is loud, not silent. The MO ECC exchange hangs
  the OSP ECC test the same way.

## Deploying Main

Build with the Quadra repo's `scripts/build_main_wsl.sh` (it rsyncs
`../Main_MiSTer` into the WSL home and cross-compiles; the binary lands in
`MacQuadra800_MiSTer/scratch/MiSTer_<md5>`). On the MiSTer, with the guest
shut down: keep the old binary (`mv /media/fat/MiSTer /media/fat/MiSTer.prev`),
copy the new one to `/media/fat/MiSTer`, `sync`, `reboot`.
