# NeXT hardware registers referenced by the ROM

Absolute device addresses appearing in ROM instructions, named from Previous's `ioMemTabNEXT.c` (non-Turbo table).
Only absolute operands are listed; register accesses through an address register (the common C idiom) are not.

| address | device / register | uses | instructions |
|---|---|---:|---|
| 02000000 | device space | 2 | 01001bfc move.l #$2000000, d2<br>01003edc ori.l #$2000000, d1 |
| 02000010 | DMA Controller (Fujitsu MB610313) (writes MUST be 32-bit): DMA_CSR | 2 | 0100a692 move.l #$2000010, $1c(a4)<br>0100d94c move.l #$2000010, $2e(a2) |
| 02000040 | DMA Controller (Fujitsu MB610313) (writes MUST be 32-bit): DMA_CSR | 2 | 01003e76 move.l #$300000, $2000040.l<br>01003f8c move.l #$2000040, -$14(a6) |
| 02000050 | DMA Controller (Fujitsu MB610313) (writes MUST be 32-bit): DMA_CSR | 2 | 01003836 move.l #$2000050, $4(a5)<br>0100bc30 move.l #$2000050, $1c(a3) |
| 020000c0 | DMA Controller (Fujitsu MB610313) (writes MUST be 32-bit): DMA_CSR | 1 | 010031ec move.l #$300000, $20000c0.l |
| 02000110 | DMA Controller (Fujitsu MB610313) (writes MUST be 32-bit): DMA_CSR | 1 | 01007caa move.l #$2000110, $8(a2) |
| 02000150 | DMA Controller (Fujitsu MB610313) (writes MUST be 32-bit): DMA_CSR | 1 | 01007cb2 move.l #$2000150, $c(a2) |
| 02000180 | DMA Controller (Fujitsu MB610313) (writes MUST be 32-bit): DMA_CSR | 2 | 01005284 move.l #$2000180, d5<br>010057ac movea.l #$2000180, a3 |
| 02004040 | Channel Sound out: DMA_Next | 1 | 01003f94 move.l #$2004040, -$18(a6) |
| 02004044 | Channel Sound out: DMA_Limit | 1 | 01003f9c move.l #$2004044, -$1c(a6) |
| 02004048 | Channel Sound out: DMA_Start | 1 | 01003fa4 movea.l #$2004048, a5 |
| 0200404c | Channel Sound out: DMA_Stop | 1 | 01003faa move.l #$200404c, -$20(a6) |
| 02004050 | Channel MO Drive: DMA_Next | 1 | 0100383e move.l #$2004050, $8(a5) |
| 02004188 | Channel Video: DMA_Start | 1 | 01000186 move.l d0, $2004188(a5, invalid.w) |
| 02007000 | Interrupt Status and Mask Registers: IntRegStatRead/IntRegStatWrite | 1 | 01000be6 move.l #$2007000, $19c(a3) |
| 02007800 | Interrupt Status and Mask Registers: IntRegMaskRead/IntRegMaskWrite | 2 | 0100017c clr.l $2007800(a5, invalid.w)<br>01000bde move.l #$2007800, $1a0(a3) |
| 0200c000 | System Control Register 1 (slot-relative): SCR1/IoMem_WriteWithoutInterceptionButTrace | 11 | 0100009a move.l $200c000(a5, invalid.w), d0<br>010000ba move.l $200c000(a5, invalid.w), d0<br>010000f2 move.l $200c000(a5, invalid.w), d0<br>010001ea move.l $200c000(a5, invalid.w), d0<br>010008c8 move.l $200c000.l, d0<br>01000b4e movea.l #$200c000, a0 ... |
| 0200c002 | System Control Register 1 (slot-relative): SCR1/IoMem_WriteWithoutInterceptionButTrace+2 | 2 | 0100a262 move.b $200c002.l, d0<br>0100a55e move.b $200c002.l, d0 |
| 0200c040 | System Control Register 1 (slot-relative) | 1 | 01000a2e move.l #$200c040, d0 |
| 0200c800 | System Control Register 1 (absolute): SCR1/IoMem_WriteWithoutInterceptionButTrace | 1 | 0100006c move.l $200c800.l, d0 |
| 0200d000 | System Control Register 2: SCR2_Read0/SCR2_Write0 | 24 | 0100007a ori.l #$80, $200d000(a5, invalid.w)<br>0100008e ori.l #$800, $200d000(a5, invalid.w)<br>0100146c andi.l #$7fffffff, $200d000.l<br>01001e7e movea.l #$200d000, a0<br>0100251a ori.l #$1, $200d000(a0, invalid.w)<br>0100252c andi.l #$fffffffe, $200d000(a0, invalid.w) ... |
| 0200e000 | Monitor/Soundbox (Keyboard, Mouse, Sound): KMS_Stat_Snd/KMS_Ctrl_Snd | 8 | 0100259a movea.l #$200e000, a0<br>01003e48 movea.l #$200e000, a0<br>01003fb2 movea.l #$200e000, a4<br>010089da movea.l #$200e000, a0<br>01008b54 movea.l #$200e000, a3<br>01008c2c movea.l #$200e000, a3 ... |
| 0200e001 | Monitor/Soundbox (Keyboard, Mouse, Sound): KMS_Stat_KM/KMS_Ctrl_KM | 1 | 010089c2 ori.b #$10, $200e001.l |
| 0200e002 | Monitor/Soundbox (Keyboard, Mouse, Sound): KMS_Stat_TX/KMS_Ctrl_TX | 1 | 01008e66 ori.b #$2, $200e002.l |
| 02014020 | SCSI DMA Control/Status: ESP_DMA_CTRL | 1 | 0100d970 move.l #$2014020, $212(a2) |
| 02014021 | SCSI DMA Control/Status: ESP_DMA_FIFO_STAT | 1 | 0100d978 move.l #$2014021, $20e(a2) |
| 0201f831 | Event Counter | 1 | 01010732 fbf.l $201f831 |
| 02020000 | Event Counter | 2 | 0100966a move.l #$2020000, -(a7)<br>0100968a movea.l #$2020000, a0 |
| 02020004 | Event Counter | 1 | 0100967e movea.l #$2020004, a0 |
| 0202c55c | Event Counter | 1 | 01016278 fbf.l $202c55c |
| 020c0000 | BMAP chip | 7 | 01000086 move.l d0, $20c0000(a5, invalid.w)<br>0100136c movea.l #$20c0000, a2<br>0100356a movea.l #$20c0000, a3<br>010043ba move.l #$20c0000, -$c(a6)<br>01004cbc movea.l #$20c0000, a5<br>01007c70 movea.l #$20c0000, a5 ... |
| 020c0004 | BMAP chip | 6 | 01000042 move.l #$c7000000, $20c0004.l<br>01000696 move.l $20c0004.l, -(a7)<br>01000736 move.l (a7)+, $20c0004.l<br>01000742 ori.l #$40000000, $20c0004.l<br>01009662 andi.b #$bf, $20c0004.l<br>0100a34e andi.b #$bf, $20c0004.l |
| 020c0008 | BMAP chip | 6 | 0100001e move.l #$0, $20c0008.l<br>01000382 move.l #$0, $20c0008.l<br>01002df0 ori.l #$80000000, $20c0008.l<br>01002e6e move.l $20c0008.l, d0<br>01002e7a move.l #$0, $20c0008.l<br>01002e8e move.l #$0, $20c0008.l |
| 020c000c | BMAP chip | 2 | 01000058 move.l #$80000000, $20c000c.l<br>0100015c move.l #$c0000000, $20c000c.l |
| 020c0010 | BMAP chip | 5 | 01000770 movea.l $20c0010.l, a7<br>010007ac movea.l $20c0010.l, a7<br>01000800 movea.l $20c0010.l, a7<br>01000940 movea.l $20c0010.l, a7<br>01000996 movea.l $20c0010.l, a7 |
| 020c0014 | BMAP chip | 7 | 0100076a movea.l $20c0014.l, a6<br>010007a6 movea.l $20c0014.l, a6<br>010007fa movea.l $20c0014.l, a6<br>01000844 move.l $20c0014.l, d4<br>0100088e move.l $20c0014.l, d4<br>0100093a movea.l $20c0014.l, a6 ... |
| 020c0018 | BMAP chip | 6 | 01000834 move.l d3, $20c0018.l<br>0100087e move.l d3, $20c0018.l<br>0100090a move.l d3, $20c0018.l<br>0100091c move.l #$0, $20c0018.l<br>0100096c move.l d0, $20c0018.l<br>010009c6 move.l d4, $20c0018.l |
| 020c001c | BMAP chip | 8 | 0100074c move.l #$70000000, $20c001c.l<br>010007dc move.l #$50000000, $20c001c.l<br>0100082a move.l #$20000000, $20c001c.l<br>010008a8 move.l #$80000000, $20c001c.l<br>010008b8 move.l #$a0000000, $20c001c.l<br>01000912 move.l #$30000000, $20c001c.l ... |
| 020c0020 | BMAP chip | 6 | 0100075c movea.l #$20c0020, a1<br>010007ec movea.l #$20c0020, a1<br>0100083a move.l #$0, $20c0020.l<br>01000884 move.l #$0, $20c0020.l<br>0100092c movea.l #$20c0020, a1<br>01000982 movea.l #$20c0020, a1 |
| 020c0030 | BMAP chip | 1 | 010000e6 move.l #$40000000, $20c0030.l |
| 020c0034 | BMAP chip | 3 | 010000da move.l #$40000000, $20c0034.l<br>01007f56 move.l $20c0034.l, d0<br>01007f62 move.l d0, $20c0034.l |
| 020c0038 | BMAP chip | 1 | 01000062 move.l #$e1000000, $20c0038.l |
| 02106000 | device space mirror (BMAP access path) of $02006000 | 1 | 01007ca2 move.l #$2106000, $4(a2) |
| 02106004 | device space mirror (BMAP access path) of $02006004 | 4 | 010014a6 move.b #$2, $2106004.l<br>010035f6 move.b #$2, $2106004.l<br>01003604 clr.b $2106004.l<br>010037fe move.b #$2, $2106004.l |
| 02106006 | device space mirror (BMAP access path) of $02006006 | 1 | 0100149e move.b #$80, $2106006.l |
| 0210600d | device space mirror (BMAP access path) of $0200600d | 1 | 01003724 move.b d1, $210600d.l |
| 02106010 | device space mirror (BMAP access path) of $02006010 | 2 | 01000146 lea.l $2106010(a5, invalid.w), a1<br>01004600 movea.l #$2106010, a2 |
| 02110000 | device space mirror (BMAP access path) of $02010000 | 2 | 0100a626 move.b d1, $2110000.l<br>0100a646 move.b d0, $2110000.l |
| 02112000 | device space mirror (BMAP access path) of $02012000 | 3 | 01003830 move.l #$2112000, (a5)<br>0100bd7e move.l #$2112000, -(a7)<br>0100ce08 movea.l #$2112000, a2 |
| 02112004 | device space mirror (BMAP access path) of $02012004 | 1 | 01001450 move.b #$fc, $2112004.l |
| 02112005 | device space mirror (BMAP access path) of $02012005 | 1 | 01001458 clr.b $2112005.l |
| 02112007 | device space mirror (BMAP access path) of $02012007 | 1 | 0100145e clr.b $2112007.l |
| 02114000 | device space mirror (BMAP access path) of $02014000 | 7 | 01003386 movea.l #$2114000, a3<br>01003438 movea.l #$2114000, a3<br>0100a664 movea.l #$2114000, a3<br>0100a7cc movea.l #$2114000, a3<br>0100a8de movea.l #$2114000, a2<br>0100ab30 movea.l #$2114000, a2 ... |
| 02114002 | device space mirror (BMAP access path) of $02014002 | 5 | 010033c4 clr.b $2114002.l<br>010033ca move.b #$1, $2114002.l<br>010033d2 move.b #$2, $2114002.l<br>010033da move.b #$3, $2114002.l<br>010033e2 move.b #$4, $2114002.l |
| 02114003 | device space mirror (BMAP access path) of $02014003 | 7 | 01001464 move.b #$3, $2114003.l<br>010033b6 move.b #$2, $2114003.l<br>010033be clr.b $2114003.l<br>01003460 move.b #$2, $2114003.l<br>01003468 clr.b $2114003.l<br>0100346e move.b #$1, $2114003.l ... |
| 02114007 | device space mirror (BMAP access path) of $02014007 | 2 | 010033ea move.b $2114007.l, d0<br>0100347c move.b $2114007.l, d0 |
| 02114020 | device space mirror (BMAP access path) of $02014020 | 5 | 01003394 move.b #$82, $2114020.l<br>010033a8 move.b #$80, $2114020.l<br>0100343e move.b #$82, $2114020.l<br>01003452 move.b #$80, $2114020.l<br>0100ad5c move.b #$a0, $2114020.l |
| 02114021 | device space mirror (BMAP access path) of $02014021 | 1 | 0100a8f6 move.b $2114021.l, $200(a3) |
| 02114100 | device space mirror (BMAP access path) of $02014100 | 1 | 0100d0b4 move.l #$2114100, -(a7) |
| 02114108 | device space mirror (BMAP access path) of $02014108 | 2 | 0100338c andi.b #$bf, $2114108.l<br>0100a66a andi.b #$bf, $2114108.l |
| 02116000 | device space mirror (BMAP access path) of $02016000 | 1 | 01003bb6 movea.l #$2116000, a5 |
| 02116001 | device space mirror (BMAP access path) of $02016001 | 1 | 01003bbc movea.l #$2116001, a2 |
| 02116004 | device space mirror (BMAP access path) of $02016004 | 2 | 01003b86 movea.l #$2116004, a0<br>01003bb0 movea.l #$2116004, a3 |
| 02118000 | device space mirror (BMAP access path) of $02018000 | 4 | 01003208 movea.l #$2118000, a4<br>0100793e move.l #$2118000, -(a7)<br>01007b48 move.l #$2118000, d1<br>01007bea move.l #$2118000, d1 |
| 02118001 | device space mirror (BMAP access path) of $02018001 | 6 | 01003214 move.b $2118001.l, d0<br>01003222 move.b #$9, $2118001.l<br>0100322c move.b #$ca, $2118001.l<br>0100792c move.l #$2118001, -(a7)<br>01007b58 move.l #$2118001, d1<br>01007bfa move.l #$2118001, d1 |
| 02118004 | device space mirror (BMAP access path) of $02018004 | 2 | 01007910 movea.l #$2118004, a0<br>01007a02 move.b #$a, $2118004.l |
| 02118100 | device space mirror (BMAP access path) of $02018100 | 2 | 0100a310 movea.l #$2118100, a3<br>0100a4ea movea.l #$2118100, a2 |
| 02118101 | device space mirror (BMAP access path) of $02018101 | 2 | 0100a316 movea.l #$2118101, a2<br>0100a4f0 movea.l #$2118101, a1 |
| 02118102 | device space mirror (BMAP access path) of $02018102 | 1 | 0100a31c movea.l #$2118102, a1 |
| 02118103 | device space mirror (BMAP access path) of $02018103 | 2 | 0100a322 movea.l #$2118103, a4<br>0100a4f6 movea.l #$2118103, a0 |
| 02118180 | device space mirror (BMAP access path) of $02018180 | 4 | 01000170 move.b #$0, $2118180(a5, invalid.w)<br>010055a8 movea.l #$2118180, a0<br>01005812 movea.l #$2118180, a2<br>0100a4d6 move.b #$4, $2118180.l |
| 02118190 | device space mirror (BMAP access path) of $02018190 | 2 | 01000166 move.b #$a, $2118190(a5, invalid.w)<br>01004e32 movea.l #$2118190, a0 |
| 0211a000 | device space mirror (BMAP access path) of $0201a000 | 3 | 01000c70 move.l #$211a000, $2f2(a3)<br>01003c86 movea.l #$211a000, a5<br>0100788c movea.l #$211a000, a0 |
| 0211a001 | device space mirror (BMAP access path) of $0201a001 | 2 | 01003c8c movea.l #$211a001, a4<br>01007894 movea.l #$211a001, a0 |
| 0211a002 | device space mirror (BMAP access path) of $0201a002 | 2 | 01003c92 movea.l #$211a002, a3<br>010078a4 movea.l #$211a002, a0 |
| 0211a003 | device space mirror (BMAP access path) of $0201a003 | 2 | 01003c98 movea.l #$211a003, a2<br>010078b4 movea.l #$211a003, a0 |
| 820c0020 | BMAP chip | 1 | 01000798 movea.l #$820c0020, a1 |
