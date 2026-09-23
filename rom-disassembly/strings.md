# Strings

247 NUL-terminated strings.  `refs` = code that names the address (absolute operands only; PC-relative and table references are not counted).

| address | refs | text |
|---|---|---|
| 0100eea6 |  | `softint1` |
| 0100eeaf |  | `intrmask` |
| 0100eeb8 |  | `scr1` |
| 0100eee1 |  | `ccms` |
| 0100eee6 |  | `scr2` |
| 0100ef6a |  | `ekgLED` |
| 0100ef71 |  | `boot command` |
| 0100ef7e |  | `DRAM tests` |
| 0100ef89 |  | `perform power-on system test` |
| 0100efa6 |  | `	sound out tests` |
| 0100efb7 |  | `	SCSI tests` |
| 0100efc3 |  | `	loop until keypress` |
| 0100efd8 |  | `	verbose test mode` |
| 0100efeb |  | `boot extended diagnostics` |
| 0100f005 |  | `serial port A is alternate console` |
| 0100f028 |  | `allow any ROM command even if password protected` |
| 0100f059 |  | `allow boot from any device even if password protected` |
| 0100f08f |  | `allow optical drive #0 eject even if password protected` |
| 0100f0c7 |  | `enable parity checking if parity memory is present` |
| 0100f10d |  | `16MB nibble mode` |
| 0100f11e |  | `4MB nibble mode` |
| 0100f12e |  | `1MB nibble mode` |
| 0100f13e |  | `illegal` |
| 0100f146 |  | `16MB page mode` |
| 0100f155 |  | `4MB page mode` |
| 0100f163 |  | `1MB page mode (illegal)` |
| 0100f17b |  | `16MB parity nibble mode` |
| 0100f193 |  | `4MB parity nibble mode` |
| 0100f1aa |  | `1MB parity nibble mode` |
| 0100f1c1 |  | `16MB parity page mode` |
| 0100f1d7 |  | `4MB parity page mode` |
| 0100f1ec |  | `1MB parity page mode (illegal)` |
| 0100f20b |  | `8MB of page mode` |
| 0100f21c |  | `2MB of page mode` |
| 0100f22d |  | `8MB of parity page mode` |
| 0100f245 |  | `2MB of parity page mode` |
| 0100f260 | 01000b36 | `Testing\nsystem ...` |
| 0100f273 | 01000d9a 01000ef0 | `Main Memory Configuration Test Failed\n\n` |
| 0100f29b | 01000dd8 01000f2a | `Main Memory Test Failed\n\n` |
| 0100f2b5 | 01000e46 | `VRAM` |
| 0100f2ba | 01000e5c | `VRAM Memory Test Failed\n` |
| 0100f2d3 | 01000f6e | `CPU MC68040 ` |
| 0100f2e0 | 01001004 | `%d MHz, memory %d nS\nBackplane slot #%d\nEthernet address: %x:%x:%x:%x:%x:%x\n` |
| 0100f32d | 0100101c | `Warning: non-volatile memory is uninitialized.\n` |
| 0100f35d | 010010f2 | `Memory sockets %d-%d configured for %s SIMMs but have %s SIMMs installed.\n` |
| 0100f3a8 | 0100111c | `Memory sockets %d and %d configured for %s SIMMs but have %s SIMMs installed.\n` |
| 0100f3f7 | 01001182 | `Memory size %dMB` |
| 0100f408 | 01001198 | `, parity enabled` |
| 0100f41b | 01001212 | `can't continue without some working memory\n` |
| 0100f44a | 0100130a | `System test failed.  Error code %x.\n\n` |
| 0100f470 | 01001338 | `\nSystem test passed.\n` |
| 0100f486 | 01001420 010056c4 | `diagnostics` |
| 0100f495 | 010015fe 010052e0 | `No default boot command.\n` |
| 0100f4b1 | 01001708 | `bogus stack frame\n` |
| 0100f4c4 | 0100173a | `Exception #%d (0x%x) at 0x%x\n` |
| 0100f4e8 | 0100186c | `New password: ` |
| 0100f4f7 | 010018b6 | `Retype new password: ` |
| 0100f50d | 010018fc | `Mismatch - password unchanged\n` |
| 0100f531 | 010019ea | `Memory sockets %d-%d have %s SIMMs installed (0x%x-0x%x)\n` |
| 0100f56b | 01001a30 | `Memory sockets %d and %d have %s SIMMs installed (0x%x-0x%x)\n` |
| 0100f5a9 | 01001ac8 | `Old error code: %x\nLast error code: %x\n` |
| 0100f5d1 | 01001b5e | `Function code %d (%s)\n` |
| 0100f5e8 | 01001b98 | `default input radix %d\n` |
| 0100f601 |  | `uh?\n` |
| 0100f606 | 01001d54 | `System\ntest\nfailed` |
| 0100f619 | 01001dc2 | `Password: ` |
| 0100f624 | 01001e10 | `Sorry\n` |
| 0100f62b | 01001e56 | `usage error, type "?" for help\n` |
| 0100f663 | 010020c8 | `must be < %d chars long\n` |
| 0100f686 | 010022b8 | `There must be a disk inserted in drive #0 before you can set this option\n` |
| 0100f6ea | 01003042 01004a58 | `\nDRAM error type %d\n` |
| 0100f6ff | 01003050 | `Check socket (0 is the first socket): ` |
| 0100f72a | 010030b0 01004a8e | `\nMemory error at location: %x\n` |
| 0100f749 | 010030c0 01004a9e | `Value at time of failure: %x\n` |
| 0100f767 | 01003124 01004af2 | `Coupling dependent memory fault!\n` |
| 0100f789 | 01003142 | `One or more SIMM at memory bank %d is bad\n` |
| 0100f7b4 | 0100314a 01004b16 | `Note: bank 0 is the first bank\n` |
| 0100f7d4 | 0100336e | `SCSI DMA intr?\n` |
| 0100f7e4 | 01003e34 | `Sound Out Over Run Interrupt.\n` |
| 0100f803 | 01004128 | `\nSound Out DMA error!\n` |
| 0100f81a | 010044da | `Bank %d has mixed mode SIMM's\n` |
| 0100f839 | 010045c8 01004e18 | `All of the SIMMs must be parity SIMMs if you want parity to work.\n` |
| 0100f87c | 010046de | `Testing the FPU` |
| 0100f88c | 01004708 | `, SCC` |
| 0100f892 | 01004732 | `, SCSI` |
| 0100f899 | 01004750 | `, Enet` |
| 0100f8a0 | 01004788 | `, ECC` |
| 0100f8a6 | 010047b2 | `, RTC` |
| 0100f8ac | 010047dc | `, Timer` |
| 0100f8b4 | 01004806 | `, Event Counter` |
| 0100f8c4 | 01004832 | `, Sound Out` |
| 0100f8d0 | 01004866 | `\n\nStarting Extended Self Test...\n` |
| 0100f8f2 | 01004874 | `Extended SCSI Test` |
| 0100f905 | 0100489c | `\n\nPress and hold any key to exit self test` |
| 0100f932 | 01004a68 | `Check socket (0 is the first socket): %d\n\n` |
| 0100f95d | 01004b0e | `One or both SIMMs in memory bank %d are bad\n` |
| 0100f98a | 01004d40 | `Bank %d has mixed size SIMMs.\n` |
| 0100f9a9 | 010050c8 | `\nVRAM failure at 0x%x:  read 0x%08x, expected 0x%08x, bad bits %08x, IC U%d\n` |
| 0100f9f6 | 010050f0 | `VRAM failure at 0x%x:  read 0x%08x, expected 0x%08x, bad bits %08x, IC U%d\n` |
| 0100fa42 |  | `Loading\nfrom\ndisk ...` |
| 0100fa58 |  | `Please\ninsert\ndisk` |
| 0100fa6b |  | `Please\nflip\ndisk` |
| 0100fa7c |  | `Bad\ndisk` |
| 0100fa85 |  | `SCSI\nerror` |
| 0100fa90 |  | `Loading\nfrom\nnetwork ...` |
| 0100faa9 |  | `Bad\nnetwork` |
| 0100fab5 |  | `Loading\nfrom\nfloppy ...` |
| 0100facd |  | `Ethernet (try thin interface first)` |
| 0100faf4 |  | `Ethernet (try twisted pair interface first)` |
| 0100fb23 |  | `SCSI disk` |
| 0100fb30 |  | `Optical disk` |
| 0100fb40 |  | `Floppy disk` |
| 0100fb4c | 0100530c | `Boot command: %s\n` |
| 0100fb5e | 01005354 | `Default boot device not found.\n` |
| 0100fb89 | 01005536 | `boot %s%s%s\n` |
| 0100fb96 | 0100574e | `Usage: b [device[(ctrl,unit,part)] [filename] [flags]]\n` |
| 0100fbce | 0100575a | `boot devices:\n` |
| 0100fbe7 | 010059ce | `unknown binary format\n` |
| 0100fbfe | 01005ad2 | `Booting %s from %s\n` |
| 0100fc12 | 01005b18 | `octet` |
| 0100fc18 | 01005c2c | `\ntftp: %s\n` |
| 0100fc39 | 01005e18 | `tftp: timeout\n` |
| 0100fc48 | 01005ec6 | `Requesting BOOTP information` |
| 0100fc65 | 01005efc | `from %s` |
| 0100fc6d | 01005f48 | `boot` |
| 0100fc77 | 010060ac | ` [OK]\n` |
| 0100fc7e | 010061c0 | ` [timeout]\n` |
| 0100fc8a | 01006708 | `0123456789abcdef` |
| 0100fca9 | 01007f76 | `en_write: tx not ready\n` |
| 0100fcc1 | 01008432 | `NeXT ROM Monitor %d.%d (v%d)` |
| 0100fcde | 01008b7c | `\nreally power down? ` |
| 0100fcf3 | 010094ba | `Error during boot` |
| 0100fd05 | 0100a762 | `Didn't complete` |
| 0100fd15 | 0100a860 | `scstart: bad state` |
| 0100fd28 | 0100a9a0 | `software error` |
| 0100fd37 | 0100a9b2 | `parity error` |
| 0100fd44 | 0100aa16 | `selection failed` |
| 0100fd55 | 0100aa60 | `bus error` |
| 0100fd5f | 0100aa70 | `target aborted` |
| 0100fd6e | 0100aa8e | `fifo level` |
| 0100fd79 | 0100aaac | `target aborted2` |
| 0100fd89 | 0100aad4 | `msgin fifo level` |
| 0100fd9a | 0100aafa | `scintr program error` |
| 0100fdaf | 0100ab60 | `SCSI command phase` |
| 0100fdc2 | 0100ab70 0100abfe | `SCSI bad i/o direction` |
| 0100fdd9 | 0100aba4 | `SCSI unaligned DMA segment` |
| 0100fdf4 | 0100ac38 | `SCSI unaligned DMA` |
| 0100fe07 | 0100acb6 | `SCSI msgout phase` |
| 0100fe19 | 0100ace4 | `scmsgin: no current sd` |
| 0100fe30 | 0100acf8 | `SCSI unexpected msg:%d\n` |
| 0100fe48 | 0100ad04 | `Unexpected msg` |
| 0100fe57 | 0100ad14 | `scmsgin: no FUNCCMPLT` |
| 0100fe6d | 0100ad46 | `sc: %s\n` |
| 0100fe75 | 0100ae1a | `SCSI Bus Hung\n` |
| 0100fe84 | 0100ae22 | `no SCSI disk\n` |
| 0100fe92 | 0100ae36 | `booting SCSI target %d, lun %d\n` |
| 0100feb2 | 0100ae70 | `dev blk len?\n` |
| 0100fec0 | 0100b012 | `READ CAPACITY` |
| 0100fece | 0100b0c2 | `REQ SENSE` |
| 0100fed8 | 0100b152 | `waiting for drive to come ready` |
| 0100fef8 | 0100b220 | `bad dev blk size %d\n` |
| 0100ff0d | 0100b29e | `READ` |
| 0100ff12 | 0100b36c 0100b420 | `sdcmd bad state: %d\n` |
| 0100ff2c | 0100b3d4 | `Selection timeout on target\n` |
| 0100ff49 | 0100b402 | `Failed, sense key: 0x%x\n` |
| 0100ff62 | 0100b40a | `Target busy\n` |
| 0100ff6f | 0100b428 | `Target disconnected\n` |
| 0100ff84 | 0100b436 | `Driver refused command\n` |
| 0100ff9c | 0100b44c | `sdfail bad state: %d\n` |
| 0100ffb2 | 0100b4ac | `dma_list: bad alignment` |
| 0100ffca | 0100b5b8 | `dma_cleanup: negative resid` |
| 0100ffe6 | 0100b774 | `Bad label\n` |
| 0100fff1 | 0100b790 | `No bootfile in label\n` |
| 01010007 | 0100b7c2 | `dev blk len %d, fs sect %d\n` |
| 01010023 | 0100b7fa | `Can't load blk0 boot\n` |
| 01010039 | 0100b8d8 | `Bad version 0x%x\n` |
| 0101004b | 0100b8fa | `Bad blkno\n` |
| 01010056 | 0100b91a | `Bad cksum\n` |
| 01010061 | 0100ba1c | `short read\n` |
| 0101006d |  | `uncorrectable ECC error` |
| 01010085 |  | `sector timeout` |
| 01010094 |  | `media upside down` |
| 010100a6 |  | `no disk inserted` |
| 010100b7 |  | `PLL failed` |
| 010100c2 |  | `retry` |
| 010100c8 |  | `restore` |
| 010100d0 |  | `re-spin` |
| 010100d8 |  | `failed` |
| 010100df | 0100bb9a | `no optical disk\n` |
| 010100f0 | 0100bcf0 | `no valid disk label found\n` |
| 0101010b | 0100bd62 | `bad ctrl or unit number\n` |
| 01010124 | 0100c81c | `read` |
| 01010129 | 0100c82c | `write` |
| 0101012f | 0100c83c | `erase` |
| 01010135 | 0100c844 | `command` |
| 0101013d | 0100c852 | `od%d%c: %s %s ` |
| 01010151 | 0100c880 | `(error #%d)` |
| 01010167 | 0100cf00 | `fd: RECALIBRATE FAILED\n` |
| 0101017f | 0100cf22 | `fd: CONTROLLER I/O ERROR\n` |
| 01010199 | 0100d016 | `RECALIBRATE FAILED\n` |
| 010101ad | 0100d106 | `No Floppy Disk Drive\n` |
| 010101c3 | 0100d10e | `No Floppy Disk Present\n` |
| 010101db | 0100d116 | `Floppy Disk not Formatted\n` |
| 010101f6 | 0100d11e | `Unknown Floppy Disk error (%d)\n` |
| 01010216 | 0100d13a | `Floppy Disk not Initialized\n` |
| 01010233 | 0100d3b8 | `fd_intr: BOGUS fvp->state` |
| 0101024d | 0100d442 0100d45c | `FATAL` |
| 01010253 | 0100d3ec | `RECALIBRATE` |
| 0101025f | 0100d414 0100d454 | `RETRY` |
| 0101026b |  | `rite` |
| 01010270 | 0100d4a4 | `fd%d: Sector %d(d) cmd = %s; status = %d: %s\n` |
| 0101029e | 0100dac4 | `Bad Controller Phase` |
| 010102b3 | 0100dae0 | `Controller hang` |
| 010102c3 | 0100dbca | `fc: Controller Reset: %s\n` |
| 010102dd | 0100df1c | `fd: Bogus density (%d) in fc_specify()\n` |
| 01010305 | 0100e2b2 | `fc_send_cmd: Error sending command bytes  (%d)\n` |
| 01010335 | 0100e3fe | `fc_send_cmd: Error getting status bytes\n` |
| 0101035e | 0100e622 | `dma_bytes_moved: DMA buf overflow` |
| 01010a38 | 010024b4 | `NeXT ROM monitor commands:\n	p  inspect/modify configuration parameters\n	a [n]  open address register\n	m  print memory configuration\n	d [n]  open data register\n	r [regname]  open processor register\n	s [systemreg]  open system register\n	e [lwb] [alist] [format]  examine memory location addr\n	ec  print recorded system error codes\n	ej [drive #]  eject optical disk (default = 0)\n	eo  (same as above)\n	ef [drive #]  eject floppy disk (default = 0)\n	c  continue execution at last pc location\n	b [device[(ctrl,unit,part)] [filename] [flags]]  boot from device\n	S [fcode]  open function code (address space)\n	R [radix]  set input radix\nNotes:\n	[lwb] select long/word/byte length (default = long).\n	[alist] is starting address or list of addresses to cyclically examine.\n	Examine command, with no arguments, uses last [alist].\nCopyright (c) 1988-1990 NeXT Inc.\n\n` |
| 010113a7 |  | `P+PO` |
| 010113c1 |  | `PNQ:S:Q$` |
| 0101147f |  | `PM8(A` |
| 010114b8 |  | `PIA)8` |
| 010114f1 |  | `EG)8` |
| 01011516 |  | `)PNQ$` |
| 01011639 |  | `PNQ:QF` |
| 010116fc |  | `JP=QLPK` |
| 01011746 |  | `K F 4(IK` |
| 010118a7 |  | `:@PN` |
| 01011933 |  | `QJP8)POPK` |
| 01011944 |  | `7OPN)NM:JF` |
| 01011975 |  | `)PN7A` |
| 010119c5 |  | `;PNF` |
| 010119e1 |  | `:PNF` |
| 01012a8b |  | `rcN\Y$NTuJ!` |
| 01012c09 |  | `+mMuV\z$V` |
| 01013091 |  | `UDDA` |
| 010130d7 |  | `@@DDA` |
| 01013326 |  | `UUUD` |
| 01013d3f |  | `i##[c i 8iUkcD c""3Fc8` |
| 01013f5e |  | `U !;mi'` |
| 01014689 |  | `vea&` |
| 010165f0 | 01006d50 01006d6c | `0123456789abcdef` |
| 01016b68 |  | `PP  ` |
| 01016b8a |  | `PP    ` |
| 01016ce8 |  | `PP  ` |
| 01016f60 | 0100bcce 0100cbbe | `Canon OMD-1` |
