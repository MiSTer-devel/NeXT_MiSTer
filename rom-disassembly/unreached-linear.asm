; Linear-sweep disassembly of the byte ranges NOT reached by the recursive
; descent (and not strings).  Speculative: much of this is data.  Use it to
; look up code the descent missed (computed jumps, tables the scan did not
; recognise); if a routine here is real, add its entry to KNOWN in disasm_rom.py.


; ---- gap 01000008..0100001d (22 bytes) ----
01000008  00000f00          ori.b    #$0, d0
0100000c  f302              fsave    ea(0,2)
0100000e  00000000          ori.b    #$0, d0
01000012  00000000          ori.b    #$0, d0
01000016  4973              dc.w     $4973
01000018  0056f7e9          ori.w    #$f7e9, (a6)
0100001c  1820              move.b   -(a0), d4

; ---- gap 0100056a..01000575 (12 bytes) ----
0100056a  2efc00000002      move.l   #$2, (a7)+
01000570  61ff00001fc8      bsr.l    sub_0100253a

; ---- gap 010009d8..01000a07 (48 bytes) ----
010009d8  ffff              dc.w     $ffff
010009da  ffff              dc.w     $ffff
010009dc  ffff              dc.w     $ffff
010009de  ffff              dc.w     $ffff
010009e0  ffff              dc.w     $ffff
010009e2  ffff              dc.w     $ffff
010009e4  ffff              dc.w     $ffff
010009e6  ffff              dc.w     $ffff
010009e8  ffff              dc.w     $ffff
010009ea  ffff              dc.w     $ffff
010009ec  ffff              dc.w     $ffff
010009ee  ffff              dc.w     $ffff
010009f0  ffff              dc.w     $ffff
010009f2  ffff              dc.w     $ffff
010009f4  ffff              dc.w     $ffff
010009f6  ffff              dc.w     $ffff
010009f8  00000000          ori.b    #$0, d0
010009fc  00000000          ori.b    #$0, d0
01000a00  00000000          ori.b    #$0, d0
01000a04  00000000          ori.b    #$0, d0

; ---- gap 01001c5c..01001c83 (40 bytes) ----
01001c5c  4e560000          link.w   a6, #$0
01001c60  206e0008          movea.l  $8(a6), a0
01001c64  4a88              tst.l    a0
01001c66  671c              beq.b    sub_01001c84
01001c68  217c01001c8401a4  move.l   #sub_01001c84, $1a4(a0)
01001c70  4e71              nop      
01001c72  226e000c          movea.l  $c(a6), a1
01001c76  1011              move.b   (a1), d0
01001c78  49c0              extb.l   d0
01001c7a  4e71              nop      
01001c7c  42a801a4          clr.l    $1a4(a0)
01001c80  7001              moveq    #$1, d0
01001c82  6006              bra.b    $1001c8a

; ---- gap 01002b90..01002b9d (14 bytes) ----
01002b90  4e560000          link.w   a6, #$0
01002b94  48e77ffe          movem.l  d1-d7/a0-a6, -(a7)
01002b98  4ff901002c52      lea.l    sub_01002c52.l, a7

; ---- gap 01002cb6..01002cd1 (28 bytes) ----
01002cb6  4e560000          link.w   a6, #$0
01002cba  48e77ffe          movem.l  d1-d7/a0-a6, -(a7)
01002cbe  226e0008          movea.l  $8(a6), a1
01002cc2  262e000c          move.l   $c(a6), d3
01002cc6  41f901002cd2      lea.l    sub_01002cd2.l, a0
01002ccc  60ffffffff8c      bra.l    loc_01002c5a

; ---- gap 01002e9e..01002ecb (46 bytes) ----
01002e9e  02dc              dc.w     $02dc
01002ea0  0100              btst.l   d0, d0
01002ea2  02dc              dc.w     $02dc
01002ea4  0100              btst.l   d0, d0
01002ea6  2e8e              move.l   a6, (a7)
01002ea8  0100              btst.l   d0, d0
01002eaa  02dc              dc.w     $02dc
01002eac  0100              btst.l   d0, d0
01002eae  02dc              dc.w     $02dc
01002eb0  0100              btst.l   d0, d0
01002eb2  02dc              dc.w     $02dc
01002eb4  0100              btst.l   d0, d0
01002eb6  02dc              dc.w     $02dc
01002eb8  0100              btst.l   d0, d0
01002eba  02dc              dc.w     $02dc
01002ebc  0100              btst.l   d0, d0
01002ebe  02dc              dc.w     $02dc
01002ec0  0100              btst.l   d0, d0
01002ec2  02dc              dc.w     $02dc
01002ec4  0100              btst.l   d0, d0
01002ec6  02dc              dc.w     $02dc
01002ec8  0100              btst.l   d0, d0
01002eca  02dc              dc.w     $02dc

; ---- gap 01002f12..01002f77 (102 bytes) ----
01002f12  4e560000          link.w   a6, #$0
01002f16  48e77ffe          movem.l  d1-d7/a0-a6, -(a7)
01002f1a  4ff901003002      lea.l    sub_01003002.l, a7
01002f20  223501700200d000  move.l   $200d000(a5, invalid.w), d1 ; $0200d000 = System Control Register 2: SCR2_Read0/SCR2_Write0
01002f28  008100000001      ori.l    #$1, d1
01002f2e  2b8101700200d000  move.l   d1, $200d000(a5, invalid.w) ; $0200d000 = System Control Register 2: SCR2_Read0/SCR2_Write0
01002f36  4e7a2002          movec    cacr, d2
01002f3a  f4f8              cpusha   #$3
01002f3c  203c00008000      move.l   #$8000, d0
01002f42  4e7b0002          movec    d0, cacr
01002f46  45f501702c000000  lea.l    $2c000000(a5, invalid.w), a2
01002f4e  47f2017000200000  lea.l    $200000(a2, invalid.w), a3
01002f56  224a              movea.l  a2, a1
01002f58  4280              clr.l    d0
01002f5a  223c0007ffff      move.l   #$7ffff, d1
01002f60  22c0              move.l   d0, (a1)+
01002f62  51c9fffc          dbra     d1, $1002f60
01002f66  223caaa0aaa0      move.l   #$aaa0aaa0, d1
01002f6c  49f901002f78      lea.l    sub_01002f78.l, a4
01002f72  60ffffffff70      bra.l    loc_01002ee4

; ---- gap 0100315c..0100317f (36 bytes) ----
0100315c  4e560000          link.w   a6, #$0
01003160  48e77ffe          movem.l  d1-d7/a0-a6, -(a7)
01003164  4eb90100336a      jsr      sub_0100336a.l
0100316a  4cdf7ffe          movem.l  (a7)+, d1-d7/a0-a6
0100316e  4e73              rte      
01003170  48e77ffe          movem.l  d1-d7/a0-a6, -(a7)
01003174  4eb9010031e8      jsr      sub_010031e8.l
0100317a  4cdf7ffe          movem.l  (a7)+, d1-d7/a0-a6
0100317e  4e73              rte      

; ---- gap 010031a0..010031b3 (20 bytes) ----
010031a0  48e77ffe          movem.l  d1-d7/a0-a6, -(a7)
010031a4  4eb901003e30      jsr      sub_01003e30.l
010031aa  4cdf7ffe          movem.l  (a7)+, d1-d7/a0-a6
010031ae  4e73              rte      
010031b0  4e5e              unlk     a6
010031b2  4e75              rts      

; ---- gap 01004a16..01004a29 (20 bytes) ----
01004a16  4e71              nop      
01004a18  4e560000          link.w   a6, #$0
01004a1c  48780009          pea.l    $9.w
01004a20  61ffffffdaaa      bsr.l    delay_us
01004a26  4e5e              unlk     a6
01004a28  4e75              rts      

; ---- gap 01006eca..01006f41 (120 bytes) ----
01006eca  0c8200000040      cmpi.l   #$40, d2
01006ed0  6fff0000002e      ble.l    $1006f00
01006ed6  2008              move.l   a0, d0
01006ed8  2209              move.l   a1, d1
01006eda  b181              eor.l    d0, d1
01006edc  028100000003      andi.l   #$3, d1
01006ee2  66ff0000001c      bne.l    $1006f00
01006ee8  9280              sub.l    d0, d1
01006eea  028100000003      andi.l   #$3, d1
01006ef0  67ff0000000e      beq.l    $1006f00
01006ef6  9481              sub.l    d1, d2
01006ef8  5381              subq.l   #$1, d1
01006efa  12d8              move.b   (a0)+, (a1)+
01006efc  51c9fffc          dbra     d1, $1006efa
01006f00  2002              move.l   d2, d0
01006f02  e488              lsr.l    #$2, d0
01006f04  67ff0000003e      beq.l    $1006f44
01006f0a  5380              subq.l   #$1, d0
01006f0c  0c800000ffff      cmpi.l   #$ffff, d0
01006f12  6fff0000001c      ble.l    $1006f30
01006f18  203c0000ffff      move.l   #$ffff, d0
01006f1e  22d8              move.l   (a0)+, (a1)+
01006f20  51c8fffc          dbra     d0, $1006f1e
01006f24  048200040000      subi.l   #$40000, d2
01006f2a  60ffffffffd4      bra.l    $1006f00
01006f30  22d8              move.l   (a0)+, (a1)+
01006f32  51c8fffc          dbra     d0, $1006f30
01006f36  028200000003      andi.l   #$3, d2
01006f3c  60ff00000006      bra.l    $1006f44

; ---- gap 01006f58..01006fcd (118 bytes) ----
01006f58  0c8200000040      cmpi.l   #$40, d2
01006f5e  6fff0000002c      ble.l    $1006f8c
01006f64  2008              move.l   a0, d0
01006f66  2209              move.l   a1, d1
01006f68  b181              eor.l    d0, d1
01006f6a  028100000003      andi.l   #$3, d1
01006f70  66ff0000001a      bne.l    $1006f8c
01006f76  028000000003      andi.l   #$3, d0
01006f7c  67ff0000000e      beq.l    $1006f8c
01006f82  9480              sub.l    d0, d2
01006f84  5380              subq.l   #$1, d0
01006f86  1320              move.b   -(a0), -(a1)
01006f88  51c8fffc          dbra     d0, $1006f86
01006f8c  2002              move.l   d2, d0
01006f8e  e488              lsr.l    #$2, d0
01006f90  67ff0000003e      beq.l    $1006fd0
01006f96  5380              subq.l   #$1, d0
01006f98  0c800000ffff      cmpi.l   #$ffff, d0
01006f9e  6fff0000001c      ble.l    $1006fbc
01006fa4  203c0000ffff      move.l   #$ffff, d0
01006faa  2320              move.l   -(a0), -(a1)
01006fac  51c8fffc          dbra     d0, $1006faa
01006fb0  048200040000      subi.l   #$40000, d2
01006fb6  60ff00000004      bra.l    $1006fbc
01006fbc  2320              move.l   -(a0), -(a1)
01006fbe  51c8fffc          dbra     d0, $1006fbc
01006fc2  028200000003      andi.l   #$3, d2
01006fc8  60ff00000006      bra.l    $1006fd0

; ---- gap 0100741e..010075c9 (428 bytes) ----
0100741e  4e560000          link.w   a6, #$0
01007422  48e72020          movem.l  d2/a2, -(a7)
01007426  246e0008          movea.l  $8(a6), a2
0100742a  7246              moveq    #$46, d1
0100742c  93c9              suba.l   a1, a1
0100742e  b2aa0014          cmp.l    $14(a2), d1
01007432  6c1e              bge.b    $1007452
01007434  d2fc016d          adda.w   #$16d, a1
01007438  2001              move.l   d1, d0
0100743a  6c02              bge.b    $100743e
0100743c  5680              addq.l   #$3, d0
0100743e  74fc              moveq    #$fc, d2
01007440  c082              and.l    d2, d0
01007442  9081              sub.l    d1, d0
01007444  4480              neg.l    d0
01007446  6602              bne.b    $100744a
01007448  5249              addq.w   #$1, a1
0100744a  5281              addq.l   #$1, d1
0100744c  b2aa0014          cmp.l    $14(a2), d1
01007450  6de2              blt.b    $1007434
01007452  202a0010          move.l   $10(a2), d0
01007456  41f901016602      lea.l    sub_01016602.l, a0
0100745c  30700a00          movea.w  (a0, d0.l * 2), a0
01007460  d1ea000c          adda.l   $c(a2), a0
01007464  43f098ff          lea.l    -$1(a0, a1.l), a1
01007468  202a0014          move.l   $14(a2), d0
0100746c  6c02              bge.b    $1007470
0100746e  5680              addq.l   #$3, d0
01007470  74fc              moveq    #$fc, d2
01007472  c082              and.l    d2, d0
01007474  90aa0014          sub.l    $14(a2), d0
01007478  4480              neg.l    d0
0100747a  660a              bne.b    $1007486
0100747c  7402              moveq    #$2, d2
0100747e  b4aa0010          cmp.l    $10(a2), d2
01007482  6c02              bge.b    $1007486
01007484  5249              addq.w   #$1, a1
01007486  2009              move.l   a1, d0
01007488  4c3c080000015180  muls.l   #$15180, d0
01007490  222a0008          move.l   $8(a2), d1
01007494  4c3c180000000e10  muls.l   #$e10, d1
0100749c  d081              add.l    d1, d0
0100749e  723c              moveq    #$3c, d1
010074a0  4c2a18000004      muls.l   $4(a2), d1
010074a6  d081              add.l    d1, d0
010074a8  d092              add.l    (a2), d0
010074aa  4cee0404fff8      movem.l  -$8(a6), d2/a2
010074b0  4e5e              unlk     a6
010074b2  4e75              rts      
010074b4  4e56ffc8          link.w   a6, #$ffc8
010074b8  48e73e20          movem.l  d2-d6/a2, -(a7)
010074bc  4285              clr.l    d5
010074be  48780030          pea.l    $30.w
010074c2  61ff000002e6      bsr.l    sub_010077aa
010074c8  584f              addq.w   #$4, a7
010074ca  08000004          btst.b   #$4, d0
010074ce  6706              beq.b    $10074d6
010074d0  4284              clr.l    d4
010074d2  600000e8          bra.w    $10075bc
010074d6  48780030          pea.l    $30.w
010074da  61ff000002ce      bsr.l    sub_010077aa
010074e0  584f              addq.w   #$4, a7
010074e2  4a00              tst.b    d0
010074e4  6c42              bge.b    $1007528
010074e6  48780004          pea.l    $4.w
010074ea  486effd0          pea.l    -$30(a6)
010074ee  48780020          pea.l    $20.w
010074f2  61ff0000027a      bsr.l    $100776e
010074f8  4280              clr.l    d0
010074fa  102effd0          move.b   -$30(a6), d0
010074fe  7c18              moveq    #$18, d6
01007500  eda0              asl.l    d6, d0
01007502  4281              clr.l    d1
01007504  122effd1          move.b   -$2f(a6), d1
01007508  7c10              moveq    #$10, d6
0100750a  eda1              asl.l    d6, d1
0100750c  8081              or.l     d1, d0
0100750e  4281              clr.l    d1
01007510  122effd2          move.b   -$2e(a6), d1
01007514  e181              asl.l    #$8, d1
01007516  8081              or.l     d1, d0
01007518  4281              clr.l    d1
0100751a  122effd3          move.b   -$2d(a6), d1
0100751e  2c00              move.l   d0, d6
01007520  8c81              or.l     d1, d6
01007522  2806              move.l   d6, d4
01007524  60000096          bra.w    $10075bc
01007528  76c8              moveq    #$c8, d3
0100752a  d68e              add.l    a6, d3
0100752c  4282              clr.l    d2
0100752e  48780008          pea.l    $8.w
01007532  2f03              move.l   d3, -(a7)
01007534  48780020          pea.l    $20.w
01007538  61ff00000234      bsr.l    $100776e
0100753e  defc000c          adda.w   #$c, a7
01007542  142effc8          move.b   -$38(a6), d2
01007546  48780020          pea.l    $20.w
0100754a  61ff0000025e      bsr.l    sub_010077aa
01007550  584f              addq.w   #$4, a7
01007552  b082              cmp.l    d2, d0
01007554  66d8              bne.b    $100752e
01007556  4280              clr.l    d0
01007558  102effc8          move.b   -$38(a6), d0
0100755c  2f00              move.l   d0, -(a7)
0100755e  45f9010075ca      lea.l    sub_010075ca.l, a2
01007564  4e92              jsr      (a2)
01007566  2d40ffd4          move.l   d0, -$2c(a6)
0100756a  4280              clr.l    d0
0100756c  102effc9          move.b   -$37(a6), d0
01007570  2f00              move.l   d0, -(a7)
01007572  4e92              jsr      (a2)
01007574  2d40ffd8          move.l   d0, -$28(a6)
01007578  4280              clr.l    d0
0100757a  102effca          move.b   -$36(a6), d0
0100757e  2f00              move.l   d0, -(a7)
01007580  4e92              jsr      (a2)
01007582  2d40ffdc          move.l   d0, -$24(a6)
01007586  4280              clr.l    d0
01007588  102effcc          move.b   -$34(a6), d0
0100758c  2f00              move.l   d0, -(a7)
0100758e  4e92              jsr      (a2)
01007590  2d40ffe0          move.l   d0, -$20(a6)
01007594  4280              clr.l    d0
01007596  102effcd          move.b   -$33(a6), d0
0100759a  2f00              move.l   d0, -(a7)
0100759c  4e92              jsr      (a2)
0100759e  2d40ffe4          move.l   d0, -$1c(a6)
010075a2  4280              clr.l    d0
010075a4  102effce          move.b   -$32(a6), d0
010075a8  2f00              move.l   d0, -(a7)
010075aa  4e92              jsr      (a2)
010075ac  2d40ffe8          move.l   d0, -$18(a6)
010075b0  486effd4          pea.l    -$2c(a6)
010075b4  61fffffffe68      bsr.l    $100741e
010075ba  2800              move.l   d0, d4
010075bc  2004              move.l   d4, d0
010075be  2205              move.l   d5, d1
010075c0  4cee047cffb0      movem.l  -$50(a6), d2-d6/a2
010075c6  4e5e              unlk     a6
010075c8  4e75              rts      

; ---- gap 0100776e..010077a9 (60 bytes) ----
0100776e  4e560000          link.w   a6, #$0
01007772  48e73820          movem.l  d2-d4/a2, -(a7)
01007776  182e000b          move.b   $b(a6), d4
0100777a  246e000c          movea.l  $c(a6), a2
0100777e  262e0010          move.l   $10(a6), d3
01007782  4282              clr.l    d2
01007784  6010              bra.b    $1007796
01007786  1404              move.b   d4, d2
01007788  5204              addq.b   #$1, d4
0100778a  2f02              move.l   d2, -(a7)
0100778c  61ff0000001c      bsr.l    sub_010077aa
01007792  14c0              move.b   d0, (a2)+
01007794  584f              addq.w   #$4, a7
01007796  51cbffee          dbra     d3, $1007786
0100779a  4243              clr.w    d3
0100779c  5383              subq.l   #$1, d3
0100779e  64e6              bcc.b    $1007786
010077a0  4cee041cfff0      movem.l  -$10(a6), d2-d4/a2
010077a6  4e5e              unlk     a6
010077a8  4e75              rts      

; ---- gap 01007f1e..01007f25 (8 bytes) ----
01007f1e  4e560000          link.w   a6, #$0
01007f22  4e5e              unlk     a6
01007f24  4e75              rts      

; ---- gap 0100a5fe..0100a605 (8 bytes) ----
0100a5fe  4e560000          link.w   a6, #$0
0100a602  4e5e              unlk     a6
0100a604  4e75              rts      

; ---- gap 0100a650..0100a657 (8 bytes) ----
0100a650  4e560000          link.w   a6, #$0
0100a654  4e5e              unlk     a6
0100a656  4e75              rts      

; ---- gap 0100b2bc..0100b2c3 (8 bytes) ----
0100b2bc  4e560000          link.w   a6, #$0
0100b2c0  4e5e              unlk     a6
0100b2c2  4e75              rts      

; ---- gap 0100bdac..0100bdb3 (8 bytes) ----
0100bdac  4e560000          link.w   a6, #$0
0100bdb0  4e5e              unlk     a6
0100bdb2  4e75              rts      

; ---- gap 0100bdea..0100bdf1 (8 bytes) ----
0100bdea  4e560000          link.w   a6, #$0
0100bdee  4e5e              unlk     a6
0100bdf0  4e75              rts      

; ---- gap 0100d1c2..0100d1c9 (8 bytes) ----
0100d1c2  4e560000          link.w   a6, #$0
0100d1c6  4e5e              unlk     a6
0100d1c8  4e75              rts      

; ---- gap 0100e6ce..0100e6db (14 bytes) ----
0100e6ce  1708              dc.w     $1708
0100e6d0  0100              btst.l   d0, d0
0100e6d2  1708              dc.w     $1708
0100e6d4  0100              btst.l   d0, d0
0100e6d6  1708              dc.w     $1708
0100e6d8  0100              btst.l   d0, d0
0100e6da  1700              move.b   d0, -(a3)

; ---- gap 0100e76e..0100e793 (38 bytes) ----
0100e76e  1bc6              dc.w     $1bc6
0100e770  0100              btst.l   d0, d0
0100e772  19860100          move.b   d6, (a4, d0.w)
0100e776  1a9a              move.b   (a2)+, (a5)
0100e778  0100              btst.l   d0, d0
0100e77a  1bb401001bb401001baa  move.b   (a4, d0.w), sub_01001baa(d1.l * 2)
0100e784  0100              btst.l   d0, d0
0100e786  1bb401001bb401001bb4  move.b   (a4, d0.w), loc_01001bb4(d1.l * 2)
0100e790  0100              btst.l   d0, d0
0100e792  1bb4              dc.w     $1bb4

; ---- gap 0100e7ba..0100e7cb (18 bytes) ----
0100e7ba  49c8              dc.w     $49c8
0100e7bc  0100              btst.l   d0, d0
0100e7be  49da              dc.w     $49da
0100e7c0  0100              btst.l   d0, d0
0100e7c2  49b80100          chk.w    $100.w, d4
0100e7c6  49c0              extb.l   d0
0100e7c8  0100              btst.l   d0, d0
0100e7ca  49c8              dc.w     $49c8

; ---- gap 0100e7ce..0100e7df (18 bytes) ----
0100e7ce  563e              dc.w     $563e
0100e7d0  0100              btst.l   d0, d0
0100e7d2  566a0100          addq.w   #$3, $100(a2)
0100e7d6  5644              addq.w   #$3, d4
0100e7d8  0100              btst.l   d0, d0
0100e7da  5658              addq.w   #$3, (a0)+
0100e7dc  0100              btst.l   d0, d0
0100e7de  56f2              dc.w     $56f2

; ---- gap 0100e956..0100e96b (22 bytes) ----
0100e956  8fce              dc.w     $8fce
0100e958  0100              btst.l   d0, d0
0100e95a  8fde              divs.w   (a6)+, d7
0100e95c  0100              btst.l   d0, d0
0100e95e  8fc6              divs.w   d6, d7
0100e960  0100              btst.l   d0, d0
0100e962  9044              sub.w    d4, d0
0100e964  0100              btst.l   d0, d0
0100e966  901c              sub.b    (a4)+, d0
0100e968  0100              btst.l   d0, d0
0100e96a  8fa2              or.l     d7, -(a2)

; ---- gap 0100e9da..0100e9eb (18 bytes) ----
0100e9da  927e              dc.w     $927e
0100e9dc  0100              btst.l   d0, d0
0100e9de  927c0100          sub.w    #$100, d1
0100e9e2  927a0100          sub.w    $100eae4(pc), d1
0100e9e6  92780100          sub.w    $100.w, d1
0100e9ea  9276              dc.w     $9276

; ---- gap 0100e9ee..0100ea93 (166 bytes) ----
0100e9ee  a09c              dc.w     $a09c
0100e9f0  0100              btst.l   d0, d0
0100e9f2  9d0a              subx.b   -(a2), -(a6)
0100e9f4  0100              btst.l   d0, d0
0100e9f6  9d740100          sub.w    d6, (a4, d0.w)
0100e9fa  9dbe              dc.w     $9dbe
0100e9fc  0100              btst.l   d0, d0
0100e9fe  9e360100          sub.b    (a6, d0.w), d7
0100ea02  9ea6              sub.l    -(a6), d7
0100ea04  0100              btst.l   d0, d0
0100ea06  a030              dc.w     $a030
0100ea08  0100              btst.l   d0, d0
0100ea0a  9ef40100          suba.w   (a4, d0.w), a7
0100ea0e  9f42              subx.w   d2, d7
0100ea10  0100              btst.l   d0, d0
0100ea12  9f90              sub.l    d7, (a0)
0100ea14  0100              btst.l   d0, d0
0100ea16  9fbe              dc.w     $9fbe
0100ea18  0100              btst.l   d0, d0
0100ea1a  9fe80100          suba.l   $100(a0), a7
0100ea1e  a012              dc.w     $a012
0100ea20  0100              btst.l   d0, d0
0100ea22  a090              dc.w     $a090
0100ea24  0100              btst.l   d0, d0
0100ea26  a062              dc.w     $a062
0100ea28  0100              btst.l   d0, d0
0100ea2a  a06a              dc.w     $a06a
0100ea2c  0100              btst.l   d0, d0
0100ea2e  a072              dc.w     $a072
0100ea30  0100              btst.l   d0, d0
0100ea32  a07a              dc.w     $a07a
0100ea34  0100              btst.l   d0, d0
0100ea36  a082              dc.w     $a082
0100ea38  0100              btst.l   d0, d0
0100ea3a  a08a              dc.w     $a08a
0100ea3c  0100              btst.l   d0, d0
0100ea3e  9c9c              sub.l    (a4)+, d6
0100ea40  0100              btst.l   d0, d0
0100ea42  9c9c              sub.l    (a4)+, d6
0100ea44  0100              btst.l   d0, d0
0100ea46  9c9c              sub.l    (a4)+, d6
0100ea48  0100              btst.l   d0, d0
0100ea4a  9c9c              sub.l    (a4)+, d6
0100ea4c  0100              btst.l   d0, d0
0100ea4e  9c9c              sub.l    (a4)+, d6
0100ea50  0100              btst.l   d0, d0
0100ea52  9c9c              sub.l    (a4)+, d6
0100ea54  0100              btst.l   d0, d0
0100ea56  9c9c              sub.l    (a4)+, d6
0100ea58  0100              btst.l   d0, d0
0100ea5a  9c9c              sub.l    (a4)+, d6
0100ea5c  0100              btst.l   d0, d0
0100ea5e  9c9c              sub.l    (a4)+, d6
0100ea60  0100              btst.l   d0, d0
0100ea62  9c9c              sub.l    (a4)+, d6
0100ea64  0100              btst.l   d0, d0
0100ea66  9c9c              sub.l    (a4)+, d6
0100ea68  0100              btst.l   d0, d0
0100ea6a  9c9c              sub.l    (a4)+, d6
0100ea6c  0100              btst.l   d0, d0
0100ea6e  9cda              suba.w   (a2)+, a6
0100ea70  0100              btst.l   d0, d0
0100ea72  9cea0100          suba.w   $100(a2), a6
0100ea76  9d54              sub.w    d6, (a4)
0100ea78  0100              btst.l   d0, d0
0100ea7a  9c9c              sub.l    (a4)+, d6
0100ea7c  0100              btst.l   d0, d0
0100ea7e  9e14              sub.b    (a4), d7
0100ea80  0100              btst.l   d0, d0
0100ea82  9e62              sub.w    -(a2), d7
0100ea84  0100              btst.l   d0, d0
0100ea86  9e84              sub.l    d4, d7
0100ea88  0100              btst.l   d0, d0
0100ea8a  9ed2              suba.w   (a2), a7
0100ea8c  0100              btst.l   d0, d0
0100ea8e  9f20              sub.b    d7, -(a0)
0100ea90  0100              btst.l   d0, d0
0100ea92  9f6e              dc.w     $9f6e

; ---- gap 0100eaa8..0100eb93 (236 bytes) ----
0100eaa8  4749              dc.w     $4749
0100eaaa  4b4d              dc.w     $4b4d
0100eaac  4e505153          link.w   a0, #$5153
0100eab0  5456              addq.w   #$2, (a6)
0100eab2  5759              subq.w   #$3, (a1)+
0100eab4  5a5c              addq.w   #$5, (a4)+
0100eab6  5d5e              subq.w   #$6, (a6)+
0100eab8  6061              bra.b    $100eb1b
0100eaba  6264              bhi.b    $100eb20
0100eabc  6566              bcs.b    $100eb24
0100eabe  6769              beq.b    $100eb29
0100eac0  6a6b              bpl.b    $100eb2d
0100eac2  6c6d              bge.b    $100eb31
0100eac4  6f70              ble.b    $100eb36
0100eac6  7172              dc.w     $7172
0100eac8  7374              dc.w     $7374
0100eaca  7576              dc.w     $7576
0100eacc  7779              dc.w     $7779
0100eace  7a7b              moveq    #$7b, d5
0100ead0  7c7d              moveq    #$7d, d6
0100ead2  7e7f              moveq    #$7f, d7
0100ead4  8081              or.l     d1, d0
0100ead6  8283              or.l     d3, d1
0100ead8  8485              or.l     d5, d2
0100eada  8687              or.l     d7, d3
0100eadc  8788898a          unpk     -(a0), -(a3), #$898a
0100eae0  8b8c8d8e          unpk     -(a4), -(a5), #$8d8e
0100eae4  8f90              or.l     d7, (a0)
0100eae6  9191              sub.l    d0, (a1)
0100eae8  9293              sub.l    (a3), d1
0100eaea  9495              sub.l    (a5), d2
0100eaec  9697              sub.l    (a7), d3
0100eaee  9798              sub.l    d3, (a0)+
0100eaf0  999a              sub.l    d4, (a2)+
0100eaf2  9b9c              sub.l    d5, (a4)+
0100eaf4  9c9d              sub.l    (a5)+, d6
0100eaf6  9e9f              sub.l    (a7)+, d7
0100eaf8  a0a0              dc.w     $a0a0
0100eafa  a1a2              dc.w     $a1a2
0100eafc  a3a4              dc.w     $a3a4
0100eafe  a4a5              dc.w     $a4a5
0100eb00  a6a7              dc.w     $a6a7
0100eb02  a7a8              dc.w     $a7a8
0100eb04  a9aa              dc.w     $a9aa
0100eb06  aaab              dc.w     $aaab
0100eb08  acad              dc.w     $acad
0100eb0a  adae              dc.w     $adae
0100eb0c  afb0              dc.w     $afb0
0100eb0e  b0b1b2b3          cmp.l    -$4d(a1, a3.w), d0
0100eb12  b3b4b5b5b6b7b7b8  eor.l    d1, ([$b6b7b7b8], a3.w * 4)
0100eb1a  b9ba              dc.w     $b9ba
0100eb1c  babbbcbc          cmp.l    $100eada(pc, a3.l), d5
0100eb20  bdbe              dc.w     $bdbe
0100eb22  bebf              dc.w     $bebf
0100eb24  c0c0              mulu.w   d0, d0
0100eb26  c1c2              muls.w   d2, d0
0100eb28  c2c3              mulu.w   d3, d1
0100eb2a  c4c4              mulu.w   d4, d2
0100eb2c  c5c6              muls.w   d6, d2
0100eb2e  c6c7              mulu.w   d7, d3
0100eb30  c7c8              dc.w     $c7c8
0100eb32  c9c9              dc.w     $c9c9
0100eb34  cacb              dc.w     $cacb
0100eb36  cbcc              dc.w     $cbcc
0100eb38  cccd              dc.w     $cccd
0100eb3a  cece              dc.w     $cece
0100eb3c  cfd0              muls.w   (a0), d7
0100eb3e  d0d1              adda.w   (a1), a0
0100eb40  d1d2              adda.l   (a2), a0
0100eb42  d3d3              adda.l   (a3), a1
0100eb44  d4d4              adda.w   (a4), a2
0100eb46  d5d6              adda.l   (a6), a2
0100eb48  d6d7              adda.w   (a7), a3
0100eb4a  d7d8              adda.l   (a0)+, a3
0100eb4c  d9d9              adda.l   (a1)+, a4
0100eb4e  dada              adda.w   (a2)+, a5
0100eb50  dbdc              adda.l   (a4)+, a5
0100eb52  dcdd              adda.w   (a5)+, a6
0100eb54  ddde              adda.l   (a6)+, a6
0100eb56  dedf              adda.w   (a7)+, a7
0100eb58  e0e0              asr.w    -(a0)
0100eb5a  e1e1              asl.w    -(a1)
0100eb5c  e2e2              lsr.w    -(a2)
0100eb5e  e3e4              lsl.w    -(a4)
0100eb60  e4e5              roxr.w   -(a5)
0100eb62  e5e6              roxl.w   -(a6)
0100eb64  e6e7              ror.w    -(a7)
0100eb66  e7e8e9e9          rol.w    -$1617(a0)
0100eb6a  eaea              dc.w     $eaea
0100eb6c  ebeb              dc.w     $ebeb
0100eb6e  ecec              dc.w     $ecec
0100eb70  eded              dc.w     $eded
0100eb72  eeee              dc.w     $eeee
0100eb74  eff0              dc.w     $eff0
0100eb76  f0f1f1f2f2f3      fbf.l    $f2f3de6b
0100eb7c  f3f4              dc.w     $f3f4
0100eb7e  f4f5              cpushp   #$3, a5
0100eb80  f5f6              dc.w     $f5f6
0100eb82  f6f7f7f8f8f9      fbf.l    $f8f9e47d
0100eb88  f9fa              dc.w     $f9fa
0100eb8a  fafbfbfcfcfd      fbf.l    $fcfde889
0100eb90  fdfe              dc.w     $fdfe
0100eb92  feff              dc.w     $feff

; ---- gap 0100eb96..0100ebb3 (30 bytes) ----
0100eb96  aafa              dc.w     $aafa
0100eb98  0100              btst.l   d0, d0
0100eb9a  a9d6              dc.w     $a9d6
0100eb9c  0100              btst.l   d0, d0
0100eb9e  aafa              dc.w     $aafa
0100eba0  0100              btst.l   d0, d0
0100eba2  aa68              dc.w     $aa68
0100eba4  0100              btst.l   d0, d0
0100eba6  aa20              dc.w     $aa20
0100eba8  0100              btst.l   d0, d0
0100ebaa  aae4              dc.w     $aae4
0100ebac  0100              btst.l   d0, d0
0100ebae  aa0c              dc.w     $aa0c
0100ebb0  0100              btst.l   d0, d0
0100ebb2  aaa4              dc.w     $aaa4

; ---- gap 0100ebb6..0100ebd3 (30 bytes) ----
0100ebb6  ab6a              dc.w     $ab6a
0100ebb8  0100              btst.l   d0, d0
0100ebba  abf8              dc.w     $abf8
0100ebbc  0100              btst.l   d0, d0
0100ebbe  ab60              dc.w     $ab60
0100ebc0  0100              btst.l   d0, d0
0100ebc2  ac96              dc.w     $ac96
0100ebc4  0100              btst.l   d0, d0
0100ebc6  ab60              dc.w     $ab60
0100ebc8  0100              btst.l   d0, d0
0100ebca  ab60              dc.w     $ab60
0100ebcc  0100              btst.l   d0, d0
0100ebce  acb6              dc.w     $acb6
0100ebd0  0100              btst.l   d0, d0
0100ebd2  aca4              dc.w     $aca4

; ---- gap 0100ebf2..0100ec0b (26 bytes) ----
0100ebf2  c182              dc.w     $c182
0100ebf4  0100              btst.l   d0, d0
0100ebf6  c282              and.l    d2, d1
0100ebf8  0100              btst.l   d0, d0
0100ebfa  c282              and.l    d2, d1
0100ebfc  0100              btst.l   d0, d0
0100ebfe  c282              and.l    d2, d1
0100ec00  0100              btst.l   d0, d0
0100ec02  c198              and.l    d0, (a0)+
0100ec04  0100              btst.l   d0, d0
0100ec06  c19e              and.l    d0, (a6)+
0100ec08  0100              btst.l   d0, d0
0100ec0a  c1e6              muls.w   -(a6), d0

; ---- gap 0100edca..0100ede7 (30 bytes) ----
0100edca  7379              dc.w     $7379
0100edcc  7374              dc.w     $7374
0100edce  696d              bvs.b    $100ee3d
0100edd0  6572              bcs.b    $100ee44
0100edd2  1d656e65          move.b   -(a5), $6e65(a6)
0100edd6  7454              moveq    #$54, d2
0100edd8  5844              addq.w   #$4, d4
0100edda  4d41              dc.w     $4d41
0100eddc  1c65              dc.w     $1c65
0100edde  6e65              bgt.b    $100ee45
0100ede0  7452              moveq    #$52, d2
0100ede2  5844              addq.w   #$4, d4
0100ede4  4d41              dc.w     $4d41
0100ede6  1b73              dc.w     $1b73

; ---- gap 0100edec..0100edf1 (6 bytes) ----
0100edec  4d41              dc.w     $4d41
0100edee  1a6f              dc.w     $1a6f
0100edf0  7074              moveq    #$74, d0

; ---- gap 0100edf6..0100ee09 (20 bytes) ----
0100edf6  444d              dc.w     $444d
0100edf8  4119              chk.l    (a1)+, d0
0100edfa  7072              moveq    #$72, d0
0100edfc  696e              bvs.b    $100ee6c
0100edfe  7465              moveq    #$65, d2
0100ee00  7244              moveq    #$44, d1
0100ee02  4d41              dc.w     $4d41
0100ee04  1873              dc.w     $1873
0100ee06  6f75              ble.b    $100ee7d
0100ee08  6e64              bgt.b    $100ee6e

; ---- gap 0100ee0e..0100ee2f (34 bytes) ----
0100ee0e  4d41              dc.w     $4d41
0100ee10  17736f756e64696e444d  move.b   ([$6e64696e, a3]), $444d(a3)
0100ee1a  4116              chk.l    (a6), d0
0100ee1c  7363              dc.w     $7363
0100ee1e  6344              bls.b    $100ee64
0100ee20  4d41              dc.w     $4d41
0100ee22  15647370          move.b   -(a4), $7370(a2)
0100ee26  444d              dc.w     $444d
0100ee28  4114              chk.l    (a4), d0
0100ee2a  6d32              blt.b    $100ee5e
0100ee2c  7244              moveq    #$44, d1
0100ee2e  4d41              dc.w     $4d41

; ---- gap 0100ee38..0100eea5 (110 bytes) ----
0100ee38  7363              dc.w     $7363
0100ee3a  6311              bls.b    $100ee4d
0100ee3c  7270              moveq    #$70, d1
0100ee3e  6910              bvs.b    $100ee50
0100ee40  6275              bhi.b    $100eeb7
0100ee42  730f              dc.w     $730f
0100ee44  7274              moveq    #$74, d1
0100ee46  630e              bls.b    $100ee56
0100ee48  6f70              ble.b    $100eeba
0100ee4a  7469              moveq    #$69, d2
0100ee4c  6361              bls.b    str_0100eeaf
0100ee4e  6c0d              bge.b    $100ee5d
0100ee50  7363              dc.w     $7363
0100ee52  7369              dc.w     $7369
0100ee54  0c7072696e74      cmpi.w   #$7269, $74(a0, d6.l)
0100ee5a  6572              bcs.b    $100eece
0100ee5c  0b65              bchg.b   d5, -(a5)
0100ee5e  6e65              bgt.b    $100eec5
0100ee60  7454              moveq    #$54, d2
0100ee62  580a              dc.w     $580a
0100ee64  656e              bcs.b    $100eed4
0100ee66  6574              bcs.b    $100eedc
0100ee68  5258              addq.w   #$1, (a0)+
0100ee6a  09736f756e647275  bchg.b   d4, ([$6e647275, a3])
0100ee72  6e08              bgt.b    $100ee7c
0100ee74  7068              moveq    #$68, d0
0100ee76  6f6e              ble.b    str_0100eee6
0100ee78  6507              bcs.b    $100ee81
0100ee7a  6473              bcc.b    $100eeef
0100ee7c  7006              moveq    #$6, d0
0100ee7e  7669              moveq    #$69, d3
0100ee80  6465              bcc.b    $100eee7
0100ee82  6f05              ble.b    $100ee89
0100ee84  6d6f              blt.b    $100eef5
0100ee86  6e69              bgt.b    $100eef1
0100ee88  746f              moveq    #$6f, d2
0100ee8a  7204              moveq    #$4, d1
0100ee8c  6b79              bmi.b    $100ef07
0100ee8e  6264              bhi.b    $100eef4
0100ee90  2f6d6f757365      move.l   $6f75(a5), $7365(a7)
0100ee96  03706f7765720273  bchg.b   d1, ([$65720273, a0])
0100ee9e  6f66              ble.b    $100ef06
0100eea0  7469              moveq    #$69, d2
0100eea2  6e74              bgt.b    $100ef18
0100eea4  3201              move.w   d1, d1

; ---- gap 0100eebd..0100eee0 (36 bytes) ----
0100eebd  10dd              move.b   (a5)+, (a0)+
0100eebf  04736964d108      subi.w   #$6964, (a3, a5.w)
0100eec5  444d              dc.w     $444d
0100eec7  4172              dc.w     $4172
0100eec9  6576              bcs.b    $100ef41
0100eecb  c908              abcd.b   -(a0), -(a4)
0100eecd  4350              dc.w     $4350
0100eecf  55726576c702766d  subq.w   #$2, ([$c702766d, a2])
0100eed7  7373              dc.w     $7373
0100eed9  c502              abcd.b   d2, d2
0100eedb  6d6d              blt.b    $100ef4a
0100eedd  7373              dc.w     $7373
0100eedf  c102              abcd.b   d2, d0

; ---- gap 0100eeeb..0100ef69 (127 bytes) ----
0100eeeb  10a0              move.b   -(a0), (a0)
0100eeed  4453              neg.w    (a3)
0100eeef  5072657365741f445350626c  addq.w   #$8, ([$65741f44, a2], $5350626c)
0100eefb  6f63              ble.b    $100ef60
0100eefd  6b1e              bmi.b    $100ef1d
0100eeff  4453              neg.w    (a3)
0100ef01  50756e70          addq.w   #$8, $70(a5, d6.l)
0100ef05  6b1d              bmi.b    $100ef24
0100ef07  4453              neg.w    (a3)
0100ef09  5062              addq.w   #$8, -(a2)
0100ef0b  1c44              dc.w     $1c44
0100ef0d  5350              subq.w   #$1, (a0)
0100ef0f  611b              bsr.b    $100ef2c
0100ef11  7270              moveq    #$70, d1
0100ef13  691a              bvs.b    $100ef2f
0100ef15  736f              dc.w     $736f
0100ef17  6674              bne.b    $100ef8d
0100ef19  696e              bvs.b    str_0100ef89
0100ef1b  7432              moveq    #$32, d2
0100ef1d  19736f6674696e74  move.b   ([$7469, a3]), $6e74(a4)
0100ef25  31d5046d          move.w   (a5), $46d.w
0100ef29  656d              bcs.b    $100ef98
0100ef2b  3235364b          move.w   $4b(a5, d3.w), d1
0100ef2f  2f344dd1          move.l   ([]), -(a7)
0100ef33  046d656d314d      subi.w   #$656d, $314d(a5)
0100ef39  2f344d10          move.l   (a4, d4.l * 4), -(a7)
0100ef3d  7469              moveq    #$69, d2
0100ef3f  6d65              blt.b    str_0100efa6
0100ef41  7269              moveq    #$69, d1
0100ef43  706c              moveq    #$6c, d0
0100ef45  37cd              dc.w     $37cd
0100ef47  0352              bchg.b   d1, (a2)
0100ef49  4f4d              dc.w     $4f4d
0100ef4b  7761              dc.w     $7761
0100ef4d  6974              bvs.b    str_0100efc3
0100ef4f  0b727464          bchg.b   d5, $64(a2, d7.w)
0100ef53  6174              bsr.b    $100efc9
0100ef55  610a              bsr.b    $100ef61
0100ef57  7274              moveq    #$74, d1
0100ef59  636c              bls.b    $100efc7
0100ef5b  6b09              bmi.b    $100ef66
0100ef5d  7274              moveq    #$74, d1
0100ef5f  6365              bls.b    $100efc6
0100ef61  8852              or.w     (a2), d4
0100ef63  4f4d              dc.w     $4f4d
0100ef65  6f76              ble.b    $100efdd
0100ef67  6c79              bge.b    $100efe2
0100ef69  0165              dc.w     $0165

; ---- gap 0100f0fa..0100f10c (19 bytes) ----
0100f0fa  5544              subq.w   #$2, d4
0100f0fc  00555000          ori.w    #$5000, (a5)
0100f100  5344              subq.w   #$1, d4
0100f102  00535000          ori.w    #$5000, (a3)
0100f106  6370              bls.b    $100f178
0100f108  7500              dc.w     $7500
0100f10a  6e6f              bgt.b    str_0100f17b
0100f10c  0031              dc.w     $0031

; ---- gap 0100f4e2..0100f4e7 (6 bytes) ----
0100f4e2  4e65              move     a5, usp
0100f4e4  5854              addq.w   #$4, (a4)
0100f4e6  3e00              move.w   d0, d7

; ---- gap 0100f64b..0100f662 (24 bytes) ----
0100f64b  257325733a2000253038783f  move.l   ([$3a200025, a3], $3038783f), -$5556(a2)
0100f657  2000              move.l   d0, d0
0100f659  25623f20          move.l   -(a2), $3f20(a2)
0100f65d  0025733f          ori.b    #$3f, -(a5)
0100f661  2000              move.l   d0, d0

; ---- gap 0100f67c..0100f685 (10 bytes) ----
0100f67c  7965              dc.w     $7965
0100f67e  7300              dc.w     $7300
0100f680  2025              move.l   -(a5), d0
0100f682  733f              dc.w     $733f
0100f684  2000              move.l   d0, d0

; ---- gap 0100f6d0..0100f6e9 (26 bytes) ----
0100f6d0  25303878          move.l   $78(a0, d3.l), -(a2)
0100f6d4  00253034          ori.b    #$34, -(a5)
0100f6d8  7800              moveq    #$0, d4
0100f6da  25303278          move.l   $78(a0, d3.w), -(a2)
0100f6de  0025783a          ori.b    #$3a, -(a5)
0100f6e2  2000              move.l   d0, d0
0100f6e4  3f20              move.w   -(a0), -(a7)
0100f6e6  00257300          ori.b    #$0, -(a5)

; ---- gap 0100fb7e..0100fb88 (11 bytes) ----
0100fb7e  2825              move.l   -(a5), d4
0100fb80  642c              bcc.b    $100fbae
0100fb82  25642c25          move.l   -(a4), $2c25(a2)
0100fb86  6429              bcc.b    $100fbb1
0100fb88  0062              dc.w     $0062

; ---- gap 0100fbdd..0100fbe6 (10 bytes) ----
0100fbdd  0925              btst.l   d4, -(a5)
0100fbdf  733a              dc.w     $733a
0100fbe1  2025              move.l   -(a5), d0
0100fbe3  732e              dc.w     $732e
0100fbe5  0a00              dc.w     $0a00

; ---- gap 0100fc23..0100fc38 (22 bytes) ----
0100fc23  25732825642c      move.l   $25(a3, d2.l), $642c(a2)
0100fc29  25642c25          move.l   -(a4), $2c25(a2)
0100fc2d  6429              bcc.b    $100fc58
0100fc2f  257300257328      move.l   $25(a3, d0.w), $7328(a2)
0100fc35  2925              move.l   -(a5), -(a4)
0100fc37  7300              dc.w     $7300

; ---- gap 0100fc9b..0100fca8 (14 bytes) ----
0100fc9b  0820              dc.w     $0820
0100fc9d  0800              dc.w     $0800
0100fc9f  30740030          movea.w  $30(a4, d0.w), a0
0100fca3  7800              moveq    #$0, d4
0100fca5  5800              addq.b   #$4, d0
0100fca7  4c00              dc.w     $4c00

; ---- gap 0101015d..01010166 (10 bytes) ----
0101015d  2025              move.l   -(a5), d0
0101015f  643a              bcc.b    $101019b
01010161  303a2564          move.w   $10126c7(pc), d0
01010165  0a00              dc.w     $0a00

; ---- gap 01010265..0101026a (6 bytes) ----
01010265  5265              addq.w   #$1, -(a5)
01010267  6164              bsr.b    $10102cd
01010269  0057              dc.w     $0057

; ---- gap 01010506..010105af (170 bytes) ----
01010506  1fde              dc.w     $1fde
01010508  0100              btst.l   d0, d0
0101050a  ed6e              lsl.w    d6, d6
0101050c  00000000          ori.b    #$0, d0
01010510  0100              btst.l   d0, d0
01010512  ed8e              lsl.l    #$6, d6
01010514  00000040          ori.b    #$40, d0
01010518  00000000          ori.b    #$0, d0
0101051c  00000000          ori.b    #$0, d0
01010520  00000000          ori.b    #$0, d0
01010524  0100              btst.l   d0, d0
01010526  ed92              roxl.l   #$6, d2
01010528  00000044          ori.b    #$44, d0
0101052c  00000000          ori.b    #$0, d0
01010530  00000000          ori.b    #$0, d0
01010534  00000000          ori.b    #$0, d0
01010538  0100              btst.l   d0, d0
0101053a  ed96              roxl.l   #$6, d6
0101053c  00000048          ori.b    #$48, d0
01010540  00000000          ori.b    #$0, d0
01010544  00000000          ori.b    #$0, d0
01010548  00000000          ori.b    #$0, d0
0101054c  0100              btst.l   d0, d0
0101054e  ed9a              rol.l    #$6, d2
01010550  00000054          ori.b    #$54, d0
01010554  00000000          ori.b    #$0, d0
01010558  00000000          ori.b    #$0, d0
0101055c  00000000          ori.b    #$0, d0
01010560  0100              btst.l   d0, d0
01010562  ed9e              rol.l    #$6, d6
01010564  0000004c          ori.b    #$4c, d0
01010568  00000000          ori.b    #$0, d0
0101056c  00000000          ori.b    #$0, d0
01010570  00000000          ori.b    #$0, d0
01010574  0100              btst.l   d0, d0
01010576  eda2              asl.l    d6, d2
01010578  00000050          ori.b    #$50, d0
0101057c  00000000          ori.b    #$0, d0
01010580  00000000          ori.b    #$0, d0
01010584  00000000          ori.b    #$0, d0
01010588  0100              btst.l   d0, d0
0101058a  eda6              asl.l    d6, d6
0101058c  0000005c          ori.b    #$5c, d0
01010590  0100              btst.l   d0, d0
01010592  1fde              dc.w     $1fde
01010594  0100              btst.l   d0, d0
01010596  edab              lsl.l    d6, d3
01010598  00000000          ori.b    #$0, d0
0101059c  00000000          ori.b    #$0, d0
010105a0  00000000          ori.b    #$0, d0
010105a4  00000000          ori.b    #$0, d0
010105a8  00000000          ori.b    #$0, d0
010105ac  00000000          ori.b    #$0, d0

; ---- gap 010105ba..01010613 (90 bytes) ----
010105ba  1fde              dc.w     $1fde
010105bc  0100              btst.l   d0, d0
010105be  edbc              rol.l    d6, d4
010105c0  00000000          ori.b    #$0, d0
010105c4  0100              btst.l   d0, d0
010105c6  eeaf              lsr.l    d7, d7
010105c8  02007800          andi.b   #$0, d0
010105cc  0100              btst.l   d0, d0
010105ce  1fde              dc.w     $1fde
010105d0  0100              btst.l   d0, d0
010105d2  edbc              rol.l    d6, d4
010105d4  00000000          ori.b    #$0, d0
010105d8  0100              btst.l   d0, d0
010105da  eeb8              ror.l    d7, d0
010105dc  0200c000          andi.b   #$0, d0
010105e0  0100              btst.l   d0, d0
010105e2  1fde              dc.w     $1fde
010105e4  0100              btst.l   d0, d0
010105e6  eebd              ror.l    d7, d5
010105e8  00000000          ori.b    #$0, d0
010105ec  0100              btst.l   d0, d0
010105ee  eee6              dc.w     $eee6
010105f0  0200d000          andi.b   #$0, d0
010105f4  0100              btst.l   d0, d0
010105f6  1fde              dc.w     $1fde
010105f8  0100              btst.l   d0, d0
010105fa  eeeb00000000      bfset    $0(a3){0:32}
01010600  00000000          ori.b    #$0, d0
01010604  00000000          ori.b    #$0, d0
01010608  00000000          ori.b    #$0, d0
0101060c  00000000          ori.b    #$0, d0
01010610  00000000          ori.b    #$0, d0

; ---- gap 0101068e..0101072b (158 bytes) ----
0101068e  efd8              dc.w     $efd8
01010690  00000008          ori.b    #$8, d0
01010694  0100              btst.l   d0, d0
01010696  20f20000          move.l   (a2, d0.w), (a0)+
0101069a  00000000          ori.b    #$0, d0
0101069e  00000100          ori.b    #$0, d0
010106a2  efeb00000020      bfins    d0, $20(a3){0:32}
010106a8  0100              btst.l   d0, d0
010106aa  20f20000          move.l   (a2, d0.w), (a0)+
010106ae  00000000          ori.b    #$0, d0
010106b2  00000100          ori.b    #$0, d0
010106b6  f0050800          fmove    fp2, fp0
010106ba  00000100          ori.b    #$0, d0
010106be  2220              move.l   -(a0), d1
010106c0  00000000          ori.b    #$0, d0
010106c4  00000000          ori.b    #$0, d0
010106c8  0100              btst.l   d0, d0
010106ca  f0280000          fmove    fp0, fp0
010106ce  00010100          ori.b    #$0, d1
010106d2  2220              move.l   -(a0), d1
010106d4  00000000          ori.b    #$0, d0
010106d8  00000000          ori.b    #$0, d0
010106dc  0100              btst.l   d0, d0
010106de  f0590000          fsf.b    (a1)+
010106e2  00020100          ori.b    #$0, d2
010106e6  2220              move.l   -(a0), d1
010106e8  00000000          ori.b    #$0, d0
010106ec  00000000          ori.b    #$0, d0
010106f0  0100              btst.l   d0, d0
010106f2  f08f0400          fbf.w    $1010af4
010106f6  00000100          ori.b    #$0, d0
010106fa  2220              move.l   -(a0), d1
010106fc  00000000          ori.b    #$0, d0
01010700  00000000          ori.b    #$0, d0
01010704  0100              btst.l   d0, d0
01010706  f0c700000000      fbf.l    $1010708
0101070c  0100              btst.l   d0, d0
0101070e  21900000          move.l   (a0), (a0, d0.w)
01010712  00000000          ori.b    #$0, d0
01010716  00000000          ori.b    #$0, d0
0101071a  00000000          ori.b    #$0, d0
0101071e  00000000          ori.b    #$0, d0
01010722  00000000          ori.b    #$0, d0
01010726  00000000          ori.b    #$0, d0
0101072a  0000              dc.w     $0000

; ---- gap 01010742..0101074b (10 bytes) ----
01010742  f100              dc.w     $f100
01010744  0100              btst.l   d0, d0
01010746  f103              dc.w     $f103
01010748  0100              btst.l   d0, d0
0101074a  f106              dc.w     $f106

; ---- gap 0101074e..0101078b (62 bytes) ----
0101074e  f10a              dc.w     $f10a
01010750  0100              btst.l   d0, d0
01010752  f10d              dc.w     $f10d
01010754  0100              btst.l   d0, d0
01010756  f11e              dc.w     $f11e
01010758  0100              btst.l   d0, d0
0101075a  f12e0100          fsave    $100(a6)
0101075e  f13e              dc.w     $f13e
01010760  0100              btst.l   d0, d0
01010762  f146              dc.w     $f146
01010764  0100              btst.l   d0, d0
01010766  f155              frestore (a5)
01010768  0100              btst.l   d0, d0
0101076a  f163              dc.w     $f163
0101076c  0100              btst.l   d0, d0
0101076e  f13e              dc.w     $f13e
01010770  0100              btst.l   d0, d0
01010772  f17b0100          frestore (a16, d0.w)
01010776  f193              dc.w     $f193
01010778  0100              btst.l   d0, d0
0101077a  f1aa              dc.w     $f1aa
0101077c  0100              btst.l   d0, d0
0101077e  f13e              dc.w     $f13e
01010780  0100              btst.l   d0, d0
01010782  f1c1              dc.w     $f1c1
01010784  0100              btst.l   d0, d0
01010786  f1d7              dc.w     $f1d7
01010788  0100              btst.l   d0, d0
0101078a  f1ec              dc.w     $f1ec

; ---- gap 0101078e..010107cb (62 bytes) ----
0101078e  f10a              dc.w     $f10a
01010790  0100              btst.l   d0, d0
01010792  f20b0100          fmove    fp0, fp2
01010796  f21c0100          fmove    fp0, fp2
0101079a  f13e              dc.w     $f13e
0101079c  0100              btst.l   d0, d0
0101079e  f13e              dc.w     $f13e
010107a0  0100              btst.l   d0, d0
010107a2  f20b0100          fmove    fp0, fp2
010107a6  f21c0100          fmove    fp0, fp2
010107aa  f13e              dc.w     $f13e
010107ac  0100              btst.l   d0, d0
010107ae  f13e              dc.w     $f13e
010107b0  0100              btst.l   d0, d0
010107b2  f22d0100          fmove    fp0, fp2
010107b6  f2450100          fsf.b    d5
010107ba  f13e              dc.w     $f13e
010107bc  0100              btst.l   d0, d0
010107be  f13e              dc.w     $f13e
010107c0  0100              btst.l   d0, d0
010107c2  f22d0100          fmove    fp0, fp2
010107c6  f2450100          fsf.b    d5
010107ca  f13e              dc.w     $f13e

; ---- gap 01010920..0101092f (16 bytes) ----
01010920  001a7860          ori.b    #$60, (a2)+
01010924  1000              move.b   d0, d0
01010926  00004800          ori.b    #$0, d0
0101092a  00000048          ori.b    #$48, d0
0101092e  0000              dc.w     $0000

; ---- gap 01010970..0101097f (16 bytes) ----
01010970  00076460          ori.b    #$60, d7
01010974  1000              move.b   d0, d0
01010976  00004800          ori.b    #$0, d0
0101097a  00000048          ori.b    #$48, d0
0101097e  0000              dc.w     $0000

; ---- gap 010109c0..010109cf (16 bytes) ----
010109c0  001a7860          ori.b    #$60, (a2)+
010109c4  1000              move.b   d0, d0
010109c6  00004800          ori.b    #$0, d0
010109ca  00000048          ori.b    #$48, d0
010109ce  0000              dc.w     $0000

; ---- gap 01010a10..01010a1f (16 bytes) ----
01010a10  00076460          ori.b    #$60, d7
01010a14  1000              move.b   d0, d0
01010a16  00004800          ori.b    #$0, d0
01010a1a  00000048          ori.b    #$48, d0
01010a1e  0000              dc.w     $0000

; ---- gap 01010daa..01010fb3 (522 bytes) ----
01010daa  145f              dc.w     $145f
01010dac  016a016f          bchg.b   d0, $16f(a2)
01010db0  0195              bclr.b   d0, (a5)
01010db2  01aa01aa          bclr.b   d0, $1aa(a2)
01010db6  04aa08aa09aa0aaa  subi.l   #$8aa09aa, $aaa(a2)
01010dbe  14ab01af          move.b   $1af(a3), (a2)
01010dc2  01b501ba01bf01ea01ef  bclr.b   d0, ([$1bf01ea, d0.w], $1ef)
01010dcc  01f501fa01fe01ff01ff  bset.b   d0, ([$1fe01ff], $1ff)
01010dd6  02ff              dc.w     $02ff
01010dd8  08ff              dc.w     $08ff
01010dda  0aff              dc.w     $0aff
01010ddc  1500              move.b   d0, -(a2)
01010dde  1801              move.b   d1, d4
01010de0  06180210          addi.b   #$10, (a0)+
01010de4  1802              move.b   d2, d4
01010de6  1018              move.b   (a0)+, d0
01010de8  02101802          andi.b   #$2, (a0)
01010dec  1018              move.b   (a0)+, d0
01010dee  020c              dc.w     $020c
01010df0  151e              move.b   (a6)+, -(a2)
01010df2  080c              dc.w     $080c
01010df4  1802              move.b   d2, d4
01010df6  0c140f08          cmpi.b   #$8, (a4)
01010dfa  0c18020c          cmpi.b   #$c, (a0)+
01010dfe  1304              move.b   d4, -(a1)
01010e00  080c              dc.w     $080c
01010e02  1802              move.b   d2, d4
01010e04  0c140f08          cmpi.b   #$8, (a4)
01010e08  0c18020c          cmpi.b   #$c, (a0)+
01010e0c  151e              move.b   (a6)+, -(a2)
01010e0e  080c              dc.w     $080c
01010e10  1802              move.b   d2, d4
01010e12  0c140f08          cmpi.b   #$8, (a4)
01010e16  0c18020c          cmpi.b   #$c, (a0)+
01010e1a  1304              move.b   d4, -(a1)
01010e1c  080c              dc.w     $080c
01010e1e  1802              move.b   d2, d4
01010e20  0c140f08          cmpi.b   #$8, (a4)
01010e24  0c18020c          cmpi.b   #$c, (a0)+
01010e28  151e              move.b   (a6)+, -(a2)
01010e2a  080c              dc.w     $080c
01010e2c  1802              move.b   d2, d4
01010e2e  0c140f08          cmpi.b   #$8, (a4)
01010e32  0c18020c          cmpi.b   #$c, (a0)+
01010e36  1304              move.b   d4, -(a1)
01010e38  080c              dc.w     $080c
01010e3a  1802              move.b   d2, d4
01010e3c  0c140f08          cmpi.b   #$8, (a4)
01010e40  0c18020c          cmpi.b   #$c, (a0)+
01010e44  151e              move.b   (a6)+, -(a2)
01010e46  080c              dc.w     $080c
01010e48  1802              move.b   d2, d4
01010e4a  0c140f08          cmpi.b   #$8, (a4)
01010e4e  0c18020c          cmpi.b   #$c, (a0)+
01010e52  1304              move.b   d4, -(a1)
01010e54  080c              dc.w     $080c
01010e56  1802              move.b   d2, d4
01010e58  0c140f08          cmpi.b   #$8, (a4)
01010e5c  0c18020c          cmpi.b   #$c, (a0)+
01010e60  151e              move.b   (a6)+, -(a2)
01010e62  080c              dc.w     $080c
01010e64  1802              move.b   d2, d4
01010e66  0c140f08          cmpi.b   #$8, (a4)
01010e6a  0c18020c          cmpi.b   #$c, (a0)+
01010e6e  1304              move.b   d4, -(a1)
01010e70  080c              dc.w     $080c
01010e72  1802              move.b   d2, d4
01010e74  0c140f08          cmpi.b   #$8, (a4)
01010e78  0c18020c          cmpi.b   #$c, (a0)+
01010e7c  151e              move.b   (a6)+, -(a2)
01010e7e  080c              dc.w     $080c
01010e80  1802              move.b   d2, d4
01010e82  0c140f08          cmpi.b   #$8, (a4)
01010e86  0c18020c          cmpi.b   #$c, (a0)+
01010e8a  1304              move.b   d4, -(a1)
01010e8c  080c              dc.w     $080c
01010e8e  1802              move.b   d2, d4
01010e90  0c140f08          cmpi.b   #$8, (a4)
01010e94  0c18020c          cmpi.b   #$c, (a0)+
01010e98  151e              move.b   (a6)+, -(a2)
01010e9a  080c              dc.w     $080c
01010e9c  1802              move.b   d2, d4
01010e9e  0c140f08          cmpi.b   #$8, (a4)
01010ea2  0c18020c          cmpi.b   #$c, (a0)+
01010ea6  1304              move.b   d4, -(a1)
01010ea8  080c              dc.w     $080c
01010eaa  1802              move.b   d2, d4
01010eac  0c140f08          cmpi.b   #$8, (a4)
01010eb0  0c18020c          cmpi.b   #$c, (a0)+
01010eb4  151e              move.b   (a6)+, -(a2)
01010eb6  080c              dc.w     $080c
01010eb8  1802              move.b   d2, d4
01010eba  0c140f08          cmpi.b   #$8, (a4)
01010ebe  0c18020c          cmpi.b   #$c, (a0)+
01010ec2  1309              dc.w     $1309
01010ec4  1d0a              dc.w     $1d0a
01010ec6  080c              dc.w     $080c
01010ec8  1802              move.b   d2, d4
01010eca  0c14121d          cmpi.b   #$1d, (a4)
01010ece  0b080c18          movep.w  $c18(a0), d5
01010ed2  020c              dc.w     $020c
01010ed4  1517              move.b   (a7), -(a2)
01010ed6  1d15              move.b   (a5), -(a6)
01010ed8  080c              dc.w     $080c
01010eda  1802              move.b   d2, d4
01010edc  0c140f08          cmpi.b   #$8, (a4)
01010ee0  0c18020c          cmpi.b   #$c, (a0)+
01010ee4  1304              move.b   d4, -(a1)
01010ee6  080c              dc.w     $080c
01010ee8  1802              move.b   d2, d4
01010eea  0c140f08          cmpi.b   #$8, (a4)
01010eee  0c18020c          cmpi.b   #$c, (a0)+
01010ef2  151e              move.b   (a6)+, -(a2)
01010ef4  080c              dc.w     $080c
01010ef6  1802              move.b   d2, d4
01010ef8  0c140f08          cmpi.b   #$8, (a4)
01010efc  0c18020c          cmpi.b   #$c, (a0)+
01010f00  1304              move.b   d4, -(a1)
01010f02  080c              dc.w     $080c
01010f04  1802              move.b   d2, d4
01010f06  0c140f08          cmpi.b   #$8, (a4)
01010f0a  0c18020c          cmpi.b   #$c, (a0)+
01010f0e  151e              move.b   (a6)+, -(a2)
01010f10  080c              dc.w     $080c
01010f12  1802              move.b   d2, d4
01010f14  1018              move.b   (a0)+, d0
01010f16  02101802          andi.b   #$2, (a0)
01010f1a  1018              move.b   (a0)+, d0
01010f1c  02101802          andi.b   #$2, (a0)
01010f20  1018              move.b   (a0)+, d0
01010f22  02101802          andi.b   #$2, (a0)
01010f26  1018              move.b   (a0)+, d0
01010f28  02101802          andi.b   #$2, (a0)
01010f2c  1018              move.b   (a0)+, d0
01010f2e  02101802          andi.b   #$2, (a0)
01010f32  1018              move.b   (a0)+, d0
01010f34  02101802          andi.b   #$2, (a0)
01010f38  1018              move.b   (a0)+, d0
01010f3a  02101802          andi.b   #$2, (a0)
01010f3e  1018              move.b   (a0)+, d0
01010f40  02101802          andi.b   #$2, (a0)
01010f44  1018              move.b   (a0)+, d0
01010f46  02101802          andi.b   #$2, (a0)
01010f4a  1018              move.b   (a0)+, d0
01010f4c  02101802          andi.b   #$2, (a0)
01010f50  1018              move.b   (a0)+, d0
01010f52  02101802          andi.b   #$2, (a0)
01010f56  1018              move.b   (a0)+, d0
01010f58  02101802          andi.b   #$2, (a0)
01010f5c  0e11              dc.w     $0e11
01010f5e  0f18              btst.l   d7, (a0)+
01010f60  020e              dc.w     $020e
01010f62  1216              move.b   (a6), d1
01010f64  0e18              dc.w     $0e18
01010f66  020e              dc.w     $020e
01010f68  1519              move.b   (a1)+, -(a2)
01010f6a  0e18              dc.w     $0e18
01010f6c  020e              dc.w     $020e
01010f6e  1b1a              move.b   (a2)+, -(a5)
01010f70  0e18              dc.w     $0e18
01010f72  020d              dc.w     $020d
01010f74  111c              move.b   (a4)+, -(a0)
01010f76  0e18              dc.w     $0e18
01010f78  020d              dc.w     $020d
01010f7a  121c              move.b   (a4)+, d1
01010f7c  160d              dc.w     $160d
01010f7e  1802              move.b   d2, d4
01010f80  0d11              btst.l   d6, (a1)
01010f82  1c0e              dc.w     $1c0e
01010f84  1802              move.b   d2, d4
01010f86  0e1b              dc.w     $0e1b
01010f88  1a0e              dc.w     $1a0e
01010f8a  1802              move.b   d2, d4
01010f8c  0e15              dc.w     $0e15
01010f8e  190e              dc.w     $190e
01010f90  1802              move.b   d2, d4
01010f92  0e12              dc.w     $0e12
01010f94  160e              dc.w     $160e
01010f96  1802              move.b   d2, d4
01010f98  0e11              dc.w     $0e11
01010f9a  0f18              btst.l   d7, (a0)+
01010f9c  02101802          andi.b   #$2, (a0)
01010fa0  1018              move.b   (a0)+, d0
01010fa2  1f18              move.b   (a0)+, -(a7)
01010fa4  1f18              move.b   (a0)+, -(a7)
01010fa6  031c              btst.l   d1, (a4)+
01010fa8  0507              btst.l   d2, d7
01010faa  1b18              move.b   (a0)+, -(a5)
01010fac  0303              btst.l   d1, d3
01010fae  1c05              move.b   d5, d6
01010fb0  071b              btst.l   d3, (a3)+
01010fb2  1803              move.b   d3, d4

; ---- gap 01010fce..010112cf (770 bytes) ----
01010fce  1656              dc.w     $1656
01010fd0  0157              bchg.b   d0, (a7)
01010fd2  0159              bchg.b   d0, (a1)+
01010fd4  015a              bchg.b   d0, (a2)+
01010fd6  015e              bchg.b   d0, (a6)+
01010fd8  015f              bchg.b   d0, (a7)+
01010fda  0165              bchg.b   d0, -(a5)
01010fdc  0166              bchg.b   d0, -(a6)
01010fde  016a016b          bchg.b   d0, $16b(a2)
01010fe2  017a              dc.w     $017a
01010fe4  017f              dc.w     $017f
01010fe6  0195              bclr.b   d0, (a5)
01010fe8  0196              bclr.b   d0, (a6)
01010fea  019a              bclr.b   d0, (a2)+
01010fec  01a5              bclr.b   d0, -(a5)
01010fee  01a6              bclr.b   d0, -(a6)
01010ff0  01aa01aa          bclr.b   d0, $1aa(a2)
01010ff4  02aa05aa06aa07aa  andi.l   #$5aa06aa, $7aa(a2)
01010ffc  08aa              dc.w     $08aa
01010ffe  0aaa0baa0caa0daa  eori.l   #$baa0caa, $daa(a2)
01011006  0eaa              dc.w     $0eaa
01011008  0faa14ab          bclr.b   d7, $14ab(a2)
0101100c  01ad01ae          bclr.b   d0, $1ae(a5)
01011010  01b501ba01bb06bb08bf  bclr.b   d0, ([$1bb06bb, d0.w], $8bf)
0101101a  01d5              bset.b   d0, (a5)
0101101c  01ea01ee          bset.b   d0, $1ee(a2)
01011020  01ee02ee          bset.b   d0, $2ee(a6)
01011024  07ef01fa          bset.b   d3, $1fa(a7)
01011028  01fb              dc.w     $01fb
0101102a  01fd              dc.w     $01fd
0101102c  01fe              dc.w     $01fe
0101102e  01ff              dc.w     $01ff
01011030  01ff              dc.w     $01ff
01011032  02ff              dc.w     $02ff
01011034  06ff              dc.w     $06ff
01011036  08ff              dc.w     $08ff
01011038  09ff              dc.w     $09ff
0101103a  0aff              dc.w     $0aff
0101103c  0eff              dc.w     $0eff
0101103e  10ff              dc.w     $10ff
01011040  12ff              dc.w     $12ff
01011042  1501              move.b   d1, -(a2)
01011044  123e              dc.w     $123e
01011046  3501              move.w   d1, -(a2)
01011048  013f              dc.w     $013f
0101104a  0101              btst.l   d0, d1
0101104c  3f01              move.w   d1, -(a7)
0101104e  0008              dc.w     $0008
01011050  3f2d0000          move.w   $0(a5), -(a7)
01011054  0837              dc.w     $0837
01011056  3323              move.w   -(a3), -(a1)
01011058  372d0000          move.w   $0(a5), -(a3)
0101105c  0837              dc.w     $0837
0101105e  3323              move.w   -(a3), -(a1)
01011060  372d0000          move.w   $0(a5), -(a3)
01011064  0837              dc.w     $0837
01011066  343d              dc.w     $343d
01011068  36372d00          move.w   (a7, d2.l * 4), d3
0101106c  0008              dc.w     $0008
0101106e  37342227          move.w   $27(a4, d2.w), -(a3)
01011072  372d0000          move.w   $0(a5), -(a3)
01011076  0837              dc.w     $0837
01011078  3422              move.w   -(a2), d2
0101107a  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101107e  0008              dc.w     $0008
01011080  37341603          move.w   $3(a4, d1.w), -(a3)
01011084  141c              move.b   (a4)+, d2
01011086  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101108a  0008              dc.w     $0008
0101108c  37341602          move.w   $2(a4, d1.w), -(a3)
01011090  0d14              btst.l   d6, (a4)
01011092  1d27              move.b   -(a7), -(a6)
01011094  372d0000          move.w   $0(a5), -(a3)
01011098  0837              dc.w     $0837
0101109a  3416              move.w   (a6), d2
0101109c  021e2737          andi.b   #$37, (a6)+
010110a0  2d00              move.l   d0, -(a6)
010110a2  0008              dc.w     $0008
010110a4  3734160a          move.w   $a(a4, d1.w), -(a3)
010110a8  0e0f              dc.w     $0e0f
010110aa  1e27              move.b   -(a7), d7
010110ac  372d0000          move.w   $0(a5), -(a3)
010110b0  0837              dc.w     $0837
010110b2  3416              move.w   (a6), d2
010110b4  00151f27          ori.b    #$27, (a5)
010110b8  372d0000          move.w   $0(a5), -(a3)
010110bc  0837              dc.w     $0837
010110be  3416              move.w   (a6), d2
010110c0  0e20              dc.w     $0e20
010110c2  27372d00          move.l   (a7, d2.l * 4), -(a3)
010110c6  0008              dc.w     $0008
010110c8  37341609          move.w   $9(a4, d1.w), -(a3)
010110cc  2027              move.l   -(a7), d0
010110ce  372d0000          move.w   $0(a5), -(a3)
010110d2  0837              dc.w     $0837
010110d4  3416              move.w   (a6), d2
010110d6  1420              move.b   -(a0), d2
010110d8  27372d00          move.l   (a7, d2.l * 4), -(a3)
010110dc  0008              dc.w     $0008
010110de  3734160f          move.w   $f(a4, d1.w), -(a3)
010110e2  2027              move.l   -(a7), d0
010110e4  372d0000          move.w   $0(a5), -(a3)
010110e8  0837              dc.w     $0837
010110ea  3416              move.w   (a6), d2
010110ec  1520              move.b   -(a0), -(a2)
010110ee  27372d00          move.l   (a7, d2.l * 4), -(a3)
010110f2  0008              dc.w     $0008
010110f4  3734160f          move.w   $f(a4, d1.w), -(a3)
010110f8  2027              move.l   -(a7), d0
010110fa  372d0000          move.w   $0(a5), -(a3)
010110fe  0837              dc.w     $0837
01011100  3416              move.w   (a6), d2
01011102  2127              move.l   -(a7), -(a0)
01011104  372d0000          move.w   $0(a5), -(a3)
01011108  0837              dc.w     $0837
0101110a  3416              move.w   (a6), d2
0101110c  0f20              btst.l   d7, -(a0)
0101110e  27372d00          move.l   (a7, d2.l * 4), -(a3)
01011112  0008              dc.w     $0008
01011114  37341621          move.w   $21(a4, d1.w), -(a3)
01011118  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101111c  0008              dc.w     $0008
0101111e  373417212737      move.w   ([$2737, a4, d1.w * 8]), -(a3)
01011124  2d00              move.l   d0, -(a6)
01011126  0008              dc.w     $0008
01011128  373417212737      move.w   ([$2737, a4, d1.w * 8]), -(a3)
0101112e  2d00              move.l   d0, -(a6)
01011130  0008              dc.w     $0008
01011132  37341621          move.w   $21(a4, d1.w), -(a3)
01011136  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101113a  0008              dc.w     $0008
0101113c  37341621          move.w   $21(a4, d1.w), -(a3)
01011140  27372d00          move.l   (a7, d2.l * 4), -(a3)
01011144  0008              dc.w     $0008
01011146  373417212737      move.w   ([$2737, a4, d1.w * 8]), -(a3)
0101114c  2d00              move.l   d0, -(a6)
0101114e  0008              dc.w     $0008
01011150  37342227          move.w   $27(a4, d2.w), -(a3)
01011154  372d0000          move.w   $0(a5), -(a3)
01011158  0837              dc.w     $0837
0101115a  3417              move.w   (a7), d2
0101115c  2127              move.l   -(a7), -(a0)
0101115e  372d0000          move.w   $0(a5), -(a3)
01011162  0837              dc.w     $0837
01011164  3422              move.w   -(a2), d2
01011166  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101116a  0008              dc.w     $0008
0101116c  37342227          move.w   $27(a4, d2.w), -(a3)
01011170  372d0000          move.w   $0(a5), -(a3)
01011174  0837              dc.w     $0837
01011176  3422              move.w   -(a2), d2
01011178  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101117c  0008              dc.w     $0008
0101117e  37342227          move.w   $27(a4, d2.w), -(a3)
01011182  372d0000          move.w   $0(a5), -(a3)
01011186  0837              dc.w     $0837
01011188  3422              move.w   -(a2), d2
0101118a  27372d00          move.l   (a7, d2.l * 4), -(a3)
0101118e  0008              dc.w     $0008
01011190  37342227          move.w   $27(a4, d2.w), -(a3)
01011194  372d0000          move.w   $0(a5), -(a3)
01011198  0837              dc.w     $0837
0101119a  3422              move.w   -(a2), d2
0101119c  27372d00          move.l   (a7, d2.l * 4), -(a3)
010111a0  0008              dc.w     $0008
010111a2  37342227          move.w   $27(a4, d2.w), -(a3)
010111a6  372d0000          move.w   $0(a5), -(a3)
010111aa  0837              dc.w     $0837
010111ac  3422              move.w   -(a2), d2
010111ae  27372d00          move.l   (a7, d2.l * 4), -(a3)
010111b2  0008              dc.w     $0008
010111b4  37342227          move.w   $27(a4, d2.w), -(a3)
010111b8  372d0000          move.w   $0(a5), -(a3)
010111bc  0837              dc.w     $0837
010111be  3422              move.w   -(a2), d2
010111c0  27372d00          move.l   (a7, d2.l * 4), -(a3)
010111c4  0008              dc.w     $0008
010111c6  37342227          move.w   $27(a4, d2.w), -(a3)
010111ca  372d0000          move.w   $0(a5), -(a3)
010111ce  0837              dc.w     $0837
010111d0  3422              move.w   -(a2), d2
010111d2  27372d00          move.l   (a7, d2.l * 4), -(a3)
010111d6  0008              dc.w     $0008
010111d8  37342227          move.w   $27(a4, d2.w), -(a3)
010111dc  372d0000          move.w   $0(a5), -(a3)
010111e0  0837              dc.w     $0837
010111e2  3422              move.w   -(a2), d2
010111e4  27372d00          move.l   (a7, d2.l * 4), -(a3)
010111e8  0008              dc.w     $0008
010111ea  37342227          move.w   $27(a4, d2.w), -(a3)
010111ee  372d0000          move.w   $0(a5), -(a3)
010111f2  0837              dc.w     $0837
010111f4  343d              dc.w     $343d
010111f6  36372d00          move.w   (a7, d2.l * 4), d3
010111fa  0008              dc.w     $0008
010111fc  373323372d00000837332337  move.w   ([$2d000008, a3], d2.w * 2, $37332337), -(a3)
01011208  2d00              move.l   d0, -(a6)
0101120a  0008              dc.w     $0008
0101120c  3f2d0000          move.w   $0(a5), -(a7)
01011210  083f              dc.w     $083f
01011212  2d00              move.l   d0, -(a6)
01011214  0008              dc.w     $0008
01011216  3f2d0000          move.w   $0(a5), -(a7)
0101121a  083f              dc.w     $083f
0101121c  2d00              move.l   d0, -(a6)
0101121e  0008              dc.w     $0008
01011220  3f2d0005          move.w   $5(a5), -(a7)
01011224  2b13              move.l   (a3), -(a5)
01011226  04053036          subi.b   #$36, d5
0101122a  322f3630          move.w   $3630(a7), d1
0101122e  2d04              move.l   d4, -(a6)
01011230  053a2d04          btst.l   d2, $1013f36(pc)
01011234  053a2d04          btst.l   d2, $1013f3a(pc)
01011238  050c3935          movep.w  $3935(a4), d2
0101123c  0505              btst.l   d2, d5
0101123e  0c39350500081b39  cmpi.b   #$5, $81b39.l
01011246  331a              move.w   (a2)+, -(a1)
01011248  2800              move.l   d0, d4
0101124a  000b              dc.w     $000b
0101124c  1b39331a2600      move.b   $331a2600.l, -(a5)
01011252  000b              dc.w     $000b
01011254  1a25              move.b   -(a5), d5
01011256  2a291a26          move.l   $1a26(a1), d5
0101125a  0000111a          ori.b    #$1a, d0
0101125e  27311a25          move.l   $25(a1, d1.l), -(a3)
01011262  0000111a          ori.b    #$1a, d0
01011266  2b1a              move.l   (a2)+, -(a5)
01011268  2500              move.l   d0, -(a2)
0101126a  002e1a27311b      ori.b    #$27, $311b(a6)
01011270  2d00              move.l   d0, -(a6)
01011272  2e18              move.l   (a0)+, d7
01011274  2538343a          move.l   $343a.w, -(a2)
01011278  36383319          move.w   $3319.w, d3
0101127c  2d08              move.l   a0, -(a6)
0101127e  1925              move.b   -(a5), -(a4)
01011280  38343a36          move.w   $36(a4, d3.l), d4
01011284  383319280819      move.w   $819(a3, d1.l), d4
0101128a  253d              dc.w     $253d
0101128c  3319              move.w   (a1)+, -(a1)
0101128e  280b              move.l   a3, d4
01011290  1925              move.b   -(a5), -(a4)
01011292  3d3319260b192538  move.w   ([$b19, a3], d1.l, $2538), -(a6)
0101129a  343a3638          move.w   $10148d4(pc), d2
0101129e  3319              move.w   (a1)+, -(a1)
010112a0  2611              move.l   (a1), d3
010112a2  2425              move.l   -(a5), d2
010112a4  1124              move.b   -(a4), -(a0)
010112a6  2512              move.l   (a2), -(a2)
010112a8  4012              negx.b   (a2)
010112aa  4012              negx.b   (a2)
010112ac  4012              negx.b   (a2)
010112ae  400f              dc.w     $400f
010112b0  1e14              move.b   (a4), d7
010112b2  1e0f              dc.w     $1e0f
010112b4  1e07              move.b   d7, d7
010112b6  1e12              move.b   (a2), d7
010112b8  3b35103c          move.w   $3c(a5, d1.w), -(a5)
010112bc  0f1e              btst.l   d7, (a6)+
010112be  2c1e              move.l   (a6)+, d6
010112c0  0f1e              btst.l   d7, (a6)+
010112c2  271e              move.l   (a6)+, -(a3)
010112c4  1240              dc.w     $1240
010112c6  1240              dc.w     $1240
010112c8  1240              dc.w     $1240
010112ca  1240              dc.w     $1240
010112cc  06060000          addi.b   #$0, d6

; ---- gap 010112f6..010113a6 (177 bytes) ----
010112f6  0e55              dc.w     $0e55
010112f8  0f55              bchg.b   d7, (a5)
010112fa  13551555          move.b   (a5), $1555(a1)
010112fe  1d552155          move.b   (a5), $2155(a6)
01011302  2655              movea.l  (a5), a3
01011304  2d554056          move.l   (a5), $4056(a6)
01011308  0157              bchg.b   d0, (a7)
0101130a  0157              bchg.b   d0, (a7)
0101130c  025b015d          andi.w   #$15d, (a3)+
01011310  015e              bchg.b   d0, (a6)+
01011312  015f              bchg.b   d0, (a7)+
01011314  015f              bchg.b   d0, (a7)+
01011316  025f056d          andi.w   #$56d, (a7)+
0101131a  016e016f          bchg.b   d0, $16f(a6)
0101131e  016f0275          bchg.b   d0, $275(a7)
01011322  0179017d017d      bchg.b   d0, $17d017d.l
01011328  027d              dc.w     $027d
0101132a  037d              dc.w     $037d
0101132c  057e              dc.w     $057e
0101132e  017f              dc.w     $017f
01011330  017f              dc.w     $017f
01011332  029501960197      andi.l   #$1960197, (a5)
01011338  019b              bclr.b   d0, (a3)+
0101133a  019f              bclr.b   d0, (a7)+
0101133c  01ae01af          bclr.b   d0, $1af(a6)
01011340  01b501b901bd01be  bclr.b   d0, ([$1bd01be, d0.w])
01011348  01be              dc.w     $01be
0101134a  02bf              dc.w     $02bf
0101134c  01d5              bset.b   d0, (a5)
0101134e  01d6              bset.b   d0, (a6)
01011350  01d7              bset.b   d0, (a7)
01011352  01d7              bset.b   d0, (a7)
01011354  02da              dc.w     $02da
01011356  01db              bset.b   d0, (a3)+
01011358  01dd              bset.b   d0, (a5)+
0101135a  01de              bset.b   d0, (a6)+
0101135c  01df              bset.b   d0, (a7)+
0101135e  01e5              bset.b   d0, -(a5)
01011360  01e6              bset.b   d0, -(a6)
01011362  01eb01ed          bset.b   d0, $1ed(a3)
01011366  01ef01f5          bset.b   d0, $1f5(a7)
0101136a  01f502f5          bset.b   d0, -$b(a5, d0.w)
0101136e  03f601f701f901fa  bset.b   d1, ([$1f901fa])
01011376  01fb              dc.w     $01fb
01011378  01fd              dc.w     $01fd
0101137a  01fe              dc.w     $01fe
0101137c  01ff              dc.w     $01ff
0101137e  01ff              dc.w     $01ff
01011380  02ff              dc.w     $02ff
01011382  03ff              dc.w     $03ff
01011384  0414001b          subi.b   #$1b, (a4)
01011388  002950411550      ori.b    #$41, $1550(a1)
0101138e  4150              dc.w     $4150
01011390  4f16              chk.l    (a6), d7
01011392  5338374b          subq.b   #$1, $374b.w
01011396  2400              move.l   d0, d2
01011398  1b460050          move.b   d6, $50(a5)
0101139c  001b4000          ori.b    #$0, (a3)+
010113a0  1b01              move.b   d1, -(a5)
010113a2  1b460024          move.b   d6, $24(a5)
010113a6  1850              dc.w     $1850

; ---- gap 010113ac..010113c0 (21 bytes) ----
010113ac  204f              movea.l  a7, a0
010113ae  1650              dc.w     $1650
010113b0  4b15              chk.l    (a5), d5
010113b2  5041              addq.w   #$8, d1
010113b4  5200              addq.b   #$1, d0
010113b6  163d              dc.w     $163d
010113b8  4b06              chk.l    d6, d5
010113ba  00202b29          ori.b    #$29, -(a0)
010113be  504b              addq.w   #$8, a3
010113c0  1b50              dc.w     $1b50

; ---- gap 010113ca..0101147e (181 bytes) ----
010113ca  1b460050          move.b   d6, $50(a5)
010113ce  00291b001b2b      ori.b    #$0, $1b2b(a1)
010113d4  00204e00          ori.b    #$0, -(a0)
010113d8  24295046          move.l   $5046(a1), d2
010113dc  5138513a          subq.b   #$8, $513a.w
010113e0  511b              subq.b   #$8, (a3)+
010113e2  504e              addq.w   #$8, a6
010113e4  5200              addq.b   #$1, d0
010113e6  1645              dc.w     $1645
010113e8  4f06              chk.l    d6, d7
010113ea  00293824004e      ori.b    #$24, $4e(a1)
010113f0  292b3746          move.l   $3746(a3), -(a4)
010113f4  184a              dc.w     $184a
010113f6  3800              move.w   d0, d4
010113f8  4600              not.b    d0
010113fa  1b41204e          move.b   d1, $204e(a5)
010113fe  001b4600          ori.b    #$0, (a3)+
01011402  5000              addq.b   #$8, d0
01011404  4e1b              dc.w     $4e1b
01011406  001b3800          ori.b    #$0, (a3)+
0101140a  294f0024          move.l   a7, $24(a4)
0101140e  4f15              chk.l    (a5), d7
01011410  4e46              trap     #$6
01011412  164a              dc.w     $164a
01011414  4b18              chk.l    (a0)+, d5
01011416  4a381b50          tst.b    $1b50.w
0101141a  003700461b00      ori.b    #$46, (a7, d1.l * 2)
01011420  164f              dc.w     $164f
01011422  2006              move.l   d6, d0
01011424  003741240024      ori.b    #$24, $24(a7, d0.w)
0101142a  3400              move.w   d0, d2
0101142c  1b46004d          move.b   d6, $4d(a5)
01011430  3800              move.w   d0, d4
01011432  4600              not.b    d0
01011434  2000              move.l   d0, d0
01011436  164e              dc.w     $164e
01011438  001b4600          ori.b    #$0, (a3)+
0101143c  5016              addq.b   #$8, (a6)
0101143e  461b              not.b    (a3)+
01011440  001b4100          ori.b    #$0, (a3)+
01011444  37500028          move.w   (a0), $28(a3)
01011448  4600              not.b    d0
0101144a  2846              movea.l  d6, a4
0101144c  004d              dc.w     $004d
0101144e  3800              move.w   d0, d4
01011450  4d38164f          chk.l    $164f.w, d6
01011454  001b0046          ori.b    #$46, (a3)+
01011458  1b00              move.b   d0, -(a5)
0101145a  164e              dc.w     $164e
0101145c  1b46011b          move.b   d6, $11b(a5)
01011460  02004724          andi.b   #$24, d0
01011464  00244b01          ori.b    #$1, -(a4)
01011468  4600              not.b    d0
0101146a  37380046          move.w   $46.w, -(a3)
0101146e  002800164e00      ori.b    #$16, $4e00(a0)
01011474  1b460050          move.b   d6, $50(a5)
01011478  1b381b00          move.b   $1b00.w, -(a5)
0101147c  1b46              dc.w     $1b46
0101147e  0050              dc.w     $0050

; ---- gap 01011485..010114b7 (51 bytes) ----
01011485  1f460050          move.b   d6, $50(a7)
01011489  2b00              move.l   d0, -(a5)
0101148b  37381650          move.w   $1650.w, -(a3)
0101148f  2b01              move.l   d1, -(a5)
01011491  461b              not.b    (a3)+
01011493  00163828          ori.b    #$28, (a6)
01011497  3701              move.w   d1, -(a3)
01011499  4f02              chk.l    d2, d7
0101149b  00472400          ori.w    #$2400, d7
0101149f  4b46              dc.w     $4b46
010114a1  0146              bchg.b   d0, d6
010114a3  002938004600      ori.b    #$0, $4600(a1)
010114a9  2401              move.l   d1, d2
010114ab  2400              move.l   d0, d2
010114ad  1b460050          move.b   d6, $50(a5)
010114b1  2900              move.l   d0, -(a4)
010114b3  1b00              move.b   d0, -(a5)
010114b5  1b4b              dc.w     $1b4b
010114b7  1550              dc.w     $1550

; ---- gap 010114be..010114f0 (51 bytes) ----
010114be  1b461550          move.b   d6, $1550(a5)
010114c2  0129381b          btst.l   d0, $381b(a1)
010114c6  404e              dc.w     $404e
010114c8  0146              bchg.b   d0, d6
010114ca  1b00              move.b   d0, -(a5)
010114cc  16384e18          move.b   $4e18.w, d3
010114d0  461b              not.b    (a3)+
010114d2  4150              dc.w     $4150
010114d4  4e00              dc.w     $4e00
010114d6  15413329          move.b   d1, $3329(a2)
010114da  5047              addq.w   #$8, d7
010114dc  0146              bchg.b   d0, d6
010114de  0029504e5124      ori.b    #$4e, $5124(a1)
010114e4  01295146          btst.l   d0, $5146(a1)
010114e8  00504e00          ori.w    #$4e00, (a0)
010114ec  1b00              move.b   d0, -(a5)
010114ee  1b34              dc.w     $1b34
010114f0  1645              dc.w     $1645

; ---- gap 010114f6..01011515 (32 bytes) ----
010114f6  1b514501          move.b   (a1), $4501(a5)
010114fa  29510050          move.l   (a1), $50(a4)
010114fe  3800              move.w   d0, d4
01011500  461b              not.b    (a3)+
01011502  00163946          ori.b    #$46, (a6)
01011506  003600504e00      ori.b    #$50, (a6, d4.l * 8)
0101150c  16382429          move.b   $2429.w, d3
01011510  504e              addq.w   #$8, a6
01011512  4601              not.b    d1
01011514  4600              not.b    d0

; ---- gap 0101151c..01011638 (285 bytes) ----
0101151c  5346              subq.w   #$1, d6
0101151e  0051001b          ori.w    #$1b, (a1)
01011522  001b2818          ori.b    #$18, (a3)+
01011526  4046              negx.w   d6
01011528  34293800          move.w   $3800(a1), d2
0101152c  1b512f01          move.b   (a1), $2f01(a5)
01011530  29504e00          move.l   (a0), $4e00(a4)
01011534  184e              dc.w     $184e
01011536  00461b00          ori.w    #$1b00, d6
0101153a  163a3800          move.b   $1014d3c(pc), d3
0101153e  1b460316          move.b   d6, $316(a5)
01011542  504e              addq.w   #$8, a6
01011544  2400              move.l   d0, d2
01011546  29460146          move.l   d6, $146(a4)
0101154a  002938004600      ori.b    #$0, $4600(a1)
01011550  2400              move.l   d0, d2
01011552  504e              addq.w   #$8, a6
01011554  001b4600          ori.b    #$0, (a3)+
01011558  501b              addq.b   #$8, (a3)+
0101155a  381b              move.w   (a3)+, d4
0101155c  001b201b          ori.b    #$1b, (a3)+
01011560  2f462829          move.l   d6, $2829(a7)
01011564  3800              move.w   d0, d4
01011566  1b46001b          move.b   d6, $1b(a5)
0101156a  01293820          btst.l   d0, $3820(a1)
0101156e  01370046          btst.l   d0, $46(a7, d0.w)
01011572  1b00              move.b   d0, -(a5)
01011574  163a3800          move.b   $1014d76(pc), d3
01011578  3600              move.w   d0, d3
0101157a  504e              addq.w   #$8, a6
0101157c  001b5124          ori.b    #$24, (a3)+
01011580  001b4b01          ori.b    #$1, (a3)+
01011584  4600              not.b    d0
01011586  37380046          move.w   $46.w, -(a3)
0101158a  002800164e00      ori.b    #$16, $4e00(a0)
01011590  1b500050          move.b   (a0), $50(a5)
01011594  1646              dc.w     $1646
01011596  1b00              move.b   d0, -(a5)
01011598  1c311b46          move.b   ([a1]), d6
0101159c  1b354100          move.b   (a5, d4.w), -(a5)
010115a0  1f46001b          move.b   d6, $1b(a7)
010115a4  2b24              move.l   -(a4), -(a5)
010115a6  37381b2b          move.w   $1b2b.w, -(a3)
010115aa  00200046          ori.b    #$46, -(a0)
010115ae  1b00              move.b   d0, -(a5)
010115b0  163a3818          move.b   $1014dca(pc), d3
010115b4  461b              not.b    (a3)+
010115b6  4150              dc.w     $4150
010115b8  4e00              dc.w     $4e00
010115ba  1b2b2024          move.b   $2024(a3), -(a5)
010115be  001b3400          ori.b    #$0, (a3)+
010115c2  1b46004d          move.b   d6, $4d(a5)
010115c6  3800              move.w   d0, d4
010115c8  4600              not.b    d0
010115ca  2000              move.l   d0, d0
010115cc  164e              dc.w     $164e
010115ce  001b5000          ori.b    #$0, (a3)+
010115d2  5000              addq.b   #$8, d0
010115d4  4e1b              dc.w     $4e1b
010115d6  001b1830          ori.b    #$30, (a3)+
010115da  1b46184f          move.b   d6, $184f(a5)
010115de  4600              not.b    d0
010115e0  2846              movea.l  d6, a4
010115e2  00183828          ori.b    #$28, (a0)+
010115e6  4d38184e          chk.l    $184e.w, d6
010115ea  00200046          ori.b    #$46, -(a0)
010115ee  1b00              move.b   d0, -(a5)
010115f0  16380037          move.b   $37.w, d3
010115f4  014f0220          movep.l  $220(a7), d0
010115f8  001b3400          ori.b    #$0, (a3)+
010115fc  2a2b3746          move.l   $3746(a3), d5
01011600  184a              dc.w     $184a
01011602  3800              move.w   d0, d4
01011604  4600              not.b    d0
01011606  1b41204e          move.b   d1, $204e(a5)
0101160a  001b503a          ori.b    #$3a, (a3)+
0101160e  5000              addq.b   #$8, d0
01011610  291b              move.l   (a3)+, -(a4)
01011612  001b164e          ori.b    #$4e, (a3)+
01011616  1b46154e          move.b   d6, $154e(a5)
0101161a  4f15              chk.l    (a5), d7
0101161c  4e46              trap     #$6
0101161e  00164b1b          ori.b    #$1b, (a6)
01011622  4a381650          tst.b    $1650.w
01011626  2b370046          move.l   $46(a7, d0.w), -(a5)
0101162a  18381b2b          move.b   $1b2b.w, d4
0101162e  0046011b          ori.w    #$11b, d6
01011632  02280018514e      andi.b   #$18, $514e(a0)
01011638  1b50              dc.w     $1b50

; ---- gap 01011640..010116fb (188 bytes) ----
01011640  1651              dc.w     $1651
01011642  4e00              dc.w     $4e00
01011644  1b4d              dc.w     $1b4d
01011646  5045              addq.w   #$8, d5
01011648  001b4051          ori.b    #$51, (a3)+
0101164c  154b              dc.w     $154b
0101164e  1b46004e          move.b   d6, $4e(a5)
01011652  29504701          move.l   (a0), $4701(a4)
01011656  513a              dc.w     $513a
01011658  3816              move.w   (a6), d4
0101165a  4050              negx.w   (a0)
0101165c  4e00              dc.w     $4e00
0101165e  4616              not.b    (a6)
01011660  5116              subq.b   #$8, (a6)
01011662  3806              move.w   d6, d4
01011664  2400              move.l   d0, d2
01011666  1651              dc.w     $1651
01011668  4115              chk.l    (a5), d0
0101166a  5041              addq.w   #$8, d1
0101166c  504f              addq.w   #$8, a7
0101166e  1651              dc.w     $1651
01011670  4601              not.b    d1
01011672  374a4e00          move.w   a2, $4e00(a3)
01011676  1b49              dc.w     $1b49
01011678  502f0016          addq.b   #$8, $16(a7)
0101167c  5200              addq.b   #$1, d0
0101167e  461b              not.b    (a3)+
01011680  4600              not.b    d0
01011682  2418              move.l   (a0)+, d2
01011684  502b4601          addq.b   #$8, $4601(a3)
01011688  204f              movea.l  a7, a0
0101168a  4a381639          tst.b    $1639.w
0101168e  5041              addq.w   #$8, d1
01011690  00460037          ori.w    #$37, d6
01011694  4b16              chk.l    (a6), d5
01011696  3806              move.w   d6, d4
01011698  0850              dc.w     $0850
0101169a  11460e24          move.b   d6, $e24(a0)
0101169e  00164e00          ori.b    #$0, (a6)
010116a2  4616              not.b    (a6)
010116a4  4e00              dc.w     $4e00
010116a6  1b46001b          move.b   d6, $1b(a5)
010116aa  5146              subq.w   #$8, d6
010116ac  0f46              bchg.b   d7, d6
010116ae  15504b03          move.b   (a0), $4b03(a2)
010116b2  380c              move.w   a4, d4
010116b4  16380128          move.b   $128.w, d3
010116b8  00184e00          ori.b    #$0, (a0)+
010116bc  4616              not.b    (a6)
010116be  4f00              chk.l    d0, d7
010116c0  2046              movea.l  d6, a0
010116c2  001b5146          ori.b    #$46, (a3)+
010116c6  5000              addq.b   #$8, d0
010116c8  34374137410024504e1b4b51  move.w   ([$41002450, a7], d4.w, $4e1b4b51), d2
010116d4  204b              movea.l  a3, a0
010116d6  204b              movea.l  a3, a0
010116d8  1b472051          move.b   d7, $2051(a5)
010116dc  00192220          ori.b    #$20, (a1)+
010116e0  4e18              dc.w     $4e18
010116e2  411b              chk.l    (a3)+, d0
010116e4  00190035          ori.b    #$35, (a1)+
010116e8  03380116          btst.l   d1, $116.w
010116ec  3801              move.w   d1, d4
010116ee  2000              move.l   d0, d0
010116f0  1b34154b16400024  move.b   ([a4], $16400024), -(a5)
010116f8  3300              move.w   d0, -(a1)
010116fa  1f01              move.b   d1, -(a7)

; ---- gap 01011704..01011745 (66 bytes) ----
01011704  4e504e29          link.w   a0, #$4e29
01011708  52374f374f294e46372b2038  addq.b   #$1, ([$4f294e46, a7], d4.l * 8, $372b2038)
01011714  1922              move.b   -(a2), -(a4)
01011716  3750204b          move.w   (a0), $204b(a3)
0101171a  1f00              move.b   d0, -(a7)
0101171c  2915              move.l   (a5), -(a4)
0101171e  502b0119          addq.b   #$8, $119(a3)
01011722  3e01              move.w   d1, d7
01011724  1638011b          move.b   $11b.w, d3
01011728  001b2816          ori.b    #$16, (a3)+
0101172c  4e18              dc.w     $4e18
0101172e  3d384b24          move.w   $4b24.w, -(a6)
01011732  00240016          ori.b    #$16, -(a4)
01011736  3d3a4550          move.w   $1015c88(pc), -(a6)
0101173a  38373834          move.w   $34(a7, d3.l), d4
0101173e  164e              dc.w     $164e
01011740  4600              not.b    d0
01011742  341b              move.w   (a3)+, d2
01011744  001b              dc.w     $001b

; ---- gap 0101174f..010118a6 (344 bytes) ----
0101174f  1641              dc.w     $1641
01011751  1922              move.b   -(a2), -(a4)
01011753  4b40              dc.w     $4b40
01011755  2600              move.l   d0, d3
01011757  4a3b3800          tst.b    $1011759(pc,d3.l)
0101175b  2416              move.l   (a6), d2
0101175d  4601              not.b    d1
0101175f  1838011b          move.b   $11b.w, d4
01011763  2b20              move.l   -(a0), -(a5)
01011765  1f16              move.b   (a6), -(a7)
01011767  4e18              dc.w     $4e18
01011769  2d42461b          move.l   d2, $461b(a6)
0101176d  0046001c          ori.w    #$1c, d6
01011771  2c46              movea.l  d6, a6
01011773  2400              move.l   d0, d2
01011775  29382418          move.l   $2418.w, -(a4)
01011779  3446              movea.w  d6, a2
0101177b  004b              dc.w     $004b
0101177d  0128461b          btst.l   d0, $461b(a0)
01011781  461b              not.b    (a3)+
01011783  4b20              chk.l    -(a0), d5
01011785  4a41              tst.w    d1
01011787  4e46              trap     #$6
01011789  4a51              tst.w    (a1)
0101178b  46382533          not.b    $2533.w
0101178f  16384a3a          move.b   $4a3a.w, d3
01011793  3800              move.w   d0, d4
01011795  2400              move.l   d0, d2
01011797  3801              move.w   d1, d4
01011799  1b2f0118          move.b   $118(a7), -(a5)
0101179d  38281b18          move.w   $1b18(a0), d4
010117a1  301b              move.w   (a3)+, d0
010117a3  004d              dc.w     $004d
010117a5  3818              move.w   (a0)+, d4
010117a7  2c41              movea.l  d1, a6
010117a9  00281b004624      ori.b    #$0, $4624(a0)
010117af  003400332024      ori.b    #$33, $24(a4, d2.w)
010117b5  504b              addq.w   #$8, a3
010117b7  4601              not.b    d1
010117b9  4b46              dc.w     $4b46
010117bb  1b461b46          move.b   d6, $1b46(a5)
010117bf  1b4d              dc.w     $1b4d
010117c1  3a4a              movea.w  a2, a5
010117c3  464a              dc.w     $464a
010117c5  514e              subq.w   #$8, a6
010117c7  3820              move.w   -(a0), d4
010117c9  4b46              dc.w     $4b46
010117cb  0115              btst.l   d0, (a5)
010117cd  502b0024          addq.b   #$8, $24(a3)
010117d1  1646              dc.w     $1646
010117d3  011c              btst.l   d0, (a4)+
010117d5  0116              btst.l   d0, (a6)
010117d7  3824              move.w   -(a4), d4
010117d9  1b18              move.b   (a0)+, -(a5)
010117db  1a1b              move.b   (a3)+, d5
010117dd  003700164338004b1b00  ori.b    #$16, $4b1b00(a7, d4.w * 2)
010117e7  4624              not.b    -(a4)
010117e9  15461b41          move.b   d6, $1b41(a2)
010117ed  25504f4d          move.l   (a0), $4f4d(a2)
010117f1  4b15              chk.l    (a5), d5
010117f3  46364b20461b      not.b    $461b(a6, d4.l * 2)
010117f9  502d3847          addq.b   #$8, $3847(a5)
010117fd  22383741          move.l   $3741.w, d1
01011801  1842              dc.w     $1842
01011803  4101              chk.l    d1, d0
01011805  1650              dc.w     $1650
01011807  0124              btst.l   d0, -(a4)
01011809  193e              dc.w     $193e
0101180b  0120              btst.l   d0, -(a0)
0101180d  02164134          andi.b   #$34, (a6)
01011811  1b2f1b20          move.b   $1b20(a7), -(a5)
01011815  00292b005000      ori.b    #$0, $5000(a1)
0101181b  15411b00          move.b   d1, $1b00(a2)
0101181f  4624              not.b    -(a4)
01011821  18381b47          move.b   $1b47.w, d4
01011825  2441              movea.l  d1, a2
01011827  2050              movea.l  (a0), a0
01011829  4f16              chk.l    (a6), d7
0101182b  41294e37          chk.l    $4e37(a1), d0
0101182f  5046              addq.w   #$8, d6
01011831  1b501b16          move.b   (a0), $1b16(a5)
01011835  3846              movea.w  d6, a4
01011837  2238204f          move.l   $204f.w, d1
0101183b  00163801          ori.b    #$1, (a6)
0101183f  1845              dc.w     $1845
01011841  401b              negx.b   (a3)+
01011843  5046              addq.w   #$8, d6
01011845  3801              move.w   d1, d4
01011847  2802              move.l   d2, d4
01011849  15464b18          move.b   d6, $4b18(a2)
0101184d  401b              negx.b   (a3)+
0101184f  2800              move.l   d0, d4
01011851  4d380024          chk.l    $24.w, d6
01011855  0018381b          ori.b    #$1b, (a0)+
01011859  00462420          ori.w    #$2420, d6
0101185d  0150              bchg.b   d0, (a0)
0101185f  3824              move.w   -(a4), d4
01011861  001b4b20          ori.b    #$20, (a3)+
01011865  18383620          move.b   $3620.w, d4
01011869  4546              dc.w     $4546
0101186b  1b451b16          move.b   d5, $1b16(a5)
0101186f  3a382238          move.w   $2238.w, d5
01011873  15502b18          move.b   (a0), $2b18(a2)
01011877  2e41              movea.l  d1, a7
01011879  001b2d40          ori.b    #$40, (a3)+
0101187d  1b504602          move.b   (a0), $4602(a5)
01011881  2402              move.l   d2, d2
01011883  0047163f          ori.w    #$163f, d7
01011887  1824              move.b   -(a4), d4
01011889  1642              dc.w     $1642
0101188b  4600              not.b    d0
0101188d  2400              move.l   d0, d2
0101188f  1b00              move.b   d0, -(a5)
01011891  1b00              move.b   d0, -(a5)
01011893  4624              not.b    -(a4)
01011895  3401              move.w   d1, d2
01011897  2951001b          move.l   (a1), $1b(a4)
0101189b  461c              not.b    (a4)+
0101189d  2b461b00          move.l   d6, $1b00(a5)
010118a1  1b461b40          move.b   d6, $1b40(a5)
010118a5  1b16              move.b   (a6), -(a5)

; ---- gap 010118ac..01011932 (135 bytes) ----
010118ac  3d381b20          move.w   $1b20.w, -(a6)
010118b0  4b00              chk.l    d0, d5
010118b2  1b00              move.b   d0, -(a5)
010118b4  5000              addq.b   #$8, d0
010118b6  2403              move.l   d3, d2
010118b8  2402              move.l   d2, d2
010118ba  004c              dc.w     $004c
010118bc  4616              not.b    (a6)
010118be  4416              neg.b    (a6)
010118c0  3418              move.w   (a0)+, d2
010118c2  384b              movea.w  a3, a4
010118c4  00240024          ori.b    #$24, -(a4)
010118c8  001b2c46          ori.b    #$46, (a3)+
010118cc  2846              movea.l  d6, a4
010118ce  16382951          move.b   $2951.w, d3
010118d2  461b              not.b    (a3)+
010118d4  461c              not.b    (a4)+
010118d6  00461b00          ori.w    #$1b00, d6
010118da  1b4b              dc.w     $1b4b
010118dc  201d              move.l   (a5)+, d0
010118de  504e              addq.w   #$8, a6
010118e0  463a              dc.w     $463a
010118e2  381f              move.w   (a7)+, d4
010118e4  2500              move.l   d0, -(a2)
010118e6  1b00              move.b   d0, -(a5)
010118e8  4e00              dc.w     $4e00
010118ea  2403              move.l   d3, d2
010118ec  3302              move.w   d2, -(a1)
010118ee  002938154e16      ori.b    #$15, $4e16(a1)
010118f4  4b1b              chk.l    (a3)+, d5
010118f6  00240024          ori.b    #$24, -(a4)
010118fa  00460018          ori.w    #$18, d6
010118fe  3a41              movea.w  d1, a5
01011900  29381641          move.l   $1641.w, -(a4)
01011904  3400              move.w   d0, d2
01011906  244b              movea.l  a3, a2
01011908  204b              movea.l  a3, a0
0101190a  2100              move.l   d0, -(a0)
0101190c  4b20              chk.l    -(a0), d5
0101190e  46283428          not.b    $3428(a0)
01011912  1b2f504e          move.b   $504e(a7), -(a5)
01011916  003a              dc.w     $003a
01011918  004b              dc.w     $004b
0101191a  3d382600          move.w   $2600.w, -(a6)
0101191e  1b2e5000          move.b   $5000(a6), -(a5)
01011922  2403              move.l   d3, d2
01011924  4602              not.b    d2
01011926  002938004b15      ori.b    #$0, $4b15(a1)
0101192c  46280020          not.b    $20(a0)
01011930  0024              dc.w     $0024
01011932  0051              dc.w     $0051

; ---- gap 0101193d..01011943 (7 bytes) ----
0101193d  2437              dc.w     $2437
0101193f  4f37              dc.w     $4f37
01011941  4f28              dc.w     $4f28
01011943  0037              dc.w     $0037

; ---- gap 0101194f..01011974 (38 bytes) ----
0101194f  3a00              move.w   d0, d5
01011951  37502b33          move.w   (a0), $2b33(a3)
01011955  204b              movea.l  a3, a0
01011957  00185040          ori.b    #$40, (a0)+
0101195b  3824              move.w   -(a4), d4
0101195d  16384624          move.b   $4624.w, d3
01011961  461b              not.b    (a3)+
01011963  0100              btst.l   d0, d0
01011965  202b0046          move.l   $46(a3), d0
01011969  00462400          ori.w    #$2400, d6
0101196d  1b00              move.b   d0, -(a5)
0101196f  2400              move.l   d0, d2
01011971  5146              subq.w   #$8, d6
01011973  5000              addq.b   #$8, d0

; ---- gap 0101197b..010119c4 (74 bytes) ----
0101197b  2420              move.l   -(a0), d2
0101197d  4b20              chk.l    -(a0), d5
0101197f  4b24              chk.l    -(a4), d5
01011981  00204b29          ori.b    #$29, -(a0)
01011985  461b              not.b    (a3)+
01011987  464a              dc.w     $464a
01011989  4602              not.b    d2
0101198b  3a00              move.w   d0, d5
0101198d  204f              movea.l  a7, a0
0101198f  00461841          ori.w    #$1841, d6
01011993  00155016          ori.b    #$16, (a5)
01011997  4600              not.b    d0
01011999  16384624          move.b   $4624.w, d3
0101199d  461b              not.b    (a3)+
0101199f  0112              btst.l   d0, (a2)
010119a1  4f05              chk.l    d5, d7
010119a3  3809              move.w   a1, d4
010119a5  3822              move.w   -(a2), d4
010119a7  04133809          subi.b   #$9, (a3)
010119ab  3822              move.w   -(a2), d4
010119ad  04014604          subi.b   #$4, d1
010119b1  4601              not.b    d1
010119b3  2901              move.l   d1, -(a4)
010119b5  2400              move.l   d0, d2
010119b7  164e              dc.w     $164e
010119b9  00241019          ori.b    #$19, -(a4)
010119bd  2200              move.l   d0, d1
010119bf  2938193e          move.l   $193e.w, -(a4)
010119c3  1600              move.b   d0, d3

; ---- gap 010119ca..010119e0 (23 bytes) ----
010119ca  0146              bchg.b   d0, d6
010119cc  04460150          subi.w   #$150, d6
010119d0  0124              btst.l   d0, -(a4)
010119d2  00164e00          ori.b    #$0, (a6)
010119d6  240d              move.l   a5, d2
010119d8  460b              dc.w     $460b
010119da  2500              move.l   d0, -(a2)
010119dc  4719              chk.l    (a1)+, d3
010119de  3e01              move.w   d1, d7
010119e0  163a              dc.w     $163a

; ---- gap 010119e6..01011cc3 (734 bytes) ----
010119e6  0146              bchg.b   d0, d6
010119e8  04460146          subi.w   #$146, d6
010119ec  0124              btst.l   d0, -(a4)
010119ee  0124              btst.l   d0, -(a4)
010119f0  00240d46          ori.b    #$46, -(a4)
010119f4  0b46              bchg.b   d5, d6
010119f6  1b15              move.b   (a5), -(a5)
010119f8  4133193e023a38244b00  chk.l    ([$23a3824, a3], d1.l, $4b00), d0
01011a02  0146              bchg.b   d0, d6
01011a04  04460146          subi.w   #$146, d6
01011a08  0124              btst.l   d0, -(a4)
01011a0a  0124              btst.l   d0, -(a4)
01011a0c  00240d46          ori.b    #$46, -(a4)
01011a10  0a154118          eori.b   #$18, (a5)
01011a14  2d382419          move.l   $2419.w, -(a6)
01011a18  3e02              move.w   d2, d7
01011a1a  3a382434          move.w   $2434.w, d5
01011a1e  001b4e4a          ori.b    #$4a, (a3)+
01011a22  4e16              dc.w     $4e16
01011a24  5016              addq.b   #$8, (a6)
01011a26  4e46              trap     #$6
01011a28  351b              move.w   (a3)+, -(a2)
01011a2a  5018              addq.b   #$8, (a0)+
01011a2c  4a4e              tst.w    a6
01011a2e  3716              move.w   (a6), -(a3)
01011a30  4e1b              dc.w     $4e1b
01011a32  293d              dc.w     $293d
01011a34  394a3d46          move.w   a2, $3d46(a4)
01011a38  2041              movea.l  d1, a0
01011a3a  4a4e              tst.w    a6
01011a3c  164e              dc.w     $164e
01011a3e  501e              addq.b   #$8, (a6)+
01011a40  37405046          move.w   d0, $5046(a3)
01011a44  1b461b46          move.b   d6, $1b46(a5)
01011a48  241b              move.l   (a3)+, d2
01011a4a  461b              not.b    (a3)+
01011a4c  461b              not.b    (a3)+
01011a4e  504f              addq.w   #$8, a7
01011a50  4118              chk.l    (a0)+, d0
01011a52  2d382419          move.l   $2419.w, -(a6)
01011a56  3e00              move.w   d0, d7
01011a58  1b17              move.b   (a7), -(a5)
01011a5a  3825              move.w   -(a5), d4
01011a5c  002831511b50      ori.b    #$51, $1b50(a0)
01011a62  4050              negx.w   (a0)
01011a64  4a50              tst.w    (a0)
01011a66  3c4c              movea.w  a4, a6
01011a68  29504f50          move.l   (a0), $4f50(a4)
01011a6c  3a4e              movea.w  a6, a5
01011a6e  2429454d          move.l   $454d(a1), d2
01011a72  5045              addq.w   #$8, d5
01011a74  4e504e51          link.w   a0, #$4e51
01011a78  1b513550          move.b   (a1), $3550(a5)
01011a7c  481b              nbcd.b   (a3)+
01011a7e  461b              not.b    (a3)+
01011a80  4624              not.b    -(a4)
01011a82  1b4e              dc.w     $1b4e
01011a84  29461b51          move.l   d6, $1b51(a4)
01011a88  3816              move.w   (a6), d4
01011a8a  3a382419          move.w   $2419.w, d5
01011a8e  011b              btst.l   d0, (a3)+
01011a90  00163824          ori.b    #$24, (a6)
01011a94  2800              move.l   d0, d4
01011a96  231b              move.l   (a3)+, -(a1)
01011a98  4e1b              dc.w     $4e1b
01011a9a  3116              move.w   (a6), -(a0)
01011a9c  4516              chk.l    (a6), d2
01011a9e  4d2c4734          chk.l    $4734(a4), d6
01011aa2  1650              dc.w     $1650
01011aa4  163a4e46          move.b   $10168ec(pc), d3
01011aa8  29464e29          move.l   d6, $4e29(a4)
01011aac  46354628          not.b    $28(a5, d4.w)
01011ab0  4e1b              dc.w     $4e1b
01011ab2  3116              move.w   (a6), -(a0)
01011ab4  503a              dc.w     $503a
01011ab6  3848              movea.w  a0, a4
01011ab8  1b331f33241f2434331b0037  move.b   ([$241f2434, a3, d1.l * 8], $331b0037), -(a5)
01011ac4  3816              move.w   (a6), d4
01011ac6  3a382419          move.w   $2419.w, d5
01011aca  0316              btst.l   d1, (a6)
01011acc  3824              move.w   -(a4), d4
01011ace  2000              move.l   d0, d0
01011ad0  003746164e00      ori.b    #$16, (a7, d4.l * 8)
01011ad6  2400              move.l   d0, d2
01011ad8  5000              addq.b   #$8, d0
01011ada  474b              dc.w     $474b
01011adc  164e              dc.w     $164e
01011ade  163a5038          move.b   $1016b18(pc), d3
01011ae2  29384629          move.l   $4629.w, -(a4)
01011ae6  3829381b          move.w   $381b(a1), d4
01011aea  4616              not.b    (a6)
01011aec  4e00              dc.w     $4e00
01011aee  5016              addq.b   #$8, (a6)
01011af0  3800              move.w   d0, d4
01011af2  471b              chk.l    (a3)+, d3
01011af4  271b              move.l   (a3)+, -(a3)
01011af6  4624              not.b    -(a4)
01011af8  1f15              move.b   (a5), -(a7)
01011afa  4a381640          tst.b    $1640.w
01011afe  001b1903          ori.b    #$3, (a3)+
01011b02  1638241b          move.b   $241b.w, d3
01011b06  00185046          ori.b    #$46, (a0)+
01011b0a  164e              dc.w     $164e
01011b0c  00240051          ori.b    #$51, -(a4)
01011b10  4816              nbcd.b   (a6)
01011b12  4e16              dc.w     $4e16
01011b14  3a50              movea.w  (a0), a5
01011b16  41293846          chk.l    $3846(a1), d0
01011b1a  29382938          move.l   $2938.w, -(a4)
01011b1e  1b46164e          move.b   d6, $164e(a5)
01011b22  00501650          ori.w    #$1650, (a0)
01011b26  2b471b26          move.l   d7, $1b26(a5)
01011b2a  3524              move.w   -(a4), -(a2)
01011b2c  1841              dc.w     $1841
01011b2e  2518              move.l   (a0)+, -(a2)
01011b30  3a38164e          move.w   $164e.w, d5
01011b34  00163e03          ori.b    #$3, (a6)
01011b38  1638241b          move.b   $241b.w, d3
01011b3c  00201b46          ori.b    #$46, -(a0)
01011b40  164e              dc.w     $164e
01011b42  00240050          ori.b    #$50, -(a4)
01011b46  0147              bchg.b   d0, d7
01011b48  164e              dc.w     $164e
01011b4a  163a4e46          move.b   $1016992(pc), d3
01011b4e  29384629          move.l   $4629.w, -(a4)
01011b52  3829381b          move.w   $381b(a1), d4
01011b56  4616              not.b    (a6)
01011b58  4e00              dc.w     $4e00
01011b5a  5000              addq.b   #$8, d0
01011b5c  37481b1e          move.w   a0, $1b1e(a3)
01011b60  331e              move.w   (a6)+, -(a1)
01011b62  4323              chk.l    -(a3), d1
01011b64  1841              dc.w     $1841
01011b66  1f24              move.b   -(a4), -(a7)
01011b68  2016              move.l   (a6), d0
01011b6a  3816              move.w   (a6), d4
01011b6c  4000              negx.b   d0
01011b6e  1b19              move.b   (a1)+, -(a5)
01011b70  0316              btst.l   d1, (a6)
01011b72  3824              move.w   -(a4), d4
01011b74  1b2b241b          move.b   $241b(a3), -(a5)
01011b78  4616              not.b    (a6)
01011b7a  4e00              dc.w     $4e00
01011b7c  2400              move.l   d0, d2
01011b7e  5001              addq.b   #$8, d1
01011b80  4716              chk.l    (a6), d3
01011b82  4e16              dc.w     $4e16
01011b84  3a4e              movea.w  a6, a5
01011b86  34293846          move.w   $3846(a1), d2
01011b8a  29382938          move.l   $2938.w, -(a4)
01011b8e  1b46164e          move.b   d6, $164e(a5)
01011b92  00500148          ori.w    #$148, (a0)
01011b96  201a              move.l   (a2)+, d0
01011b98  321a              move.w   (a2)+, d1
01011b9a  43321b46          chk.l    ([a2]), d1
01011b9e  1a332416          move.b   $16(a3, d2.w), d5
01011ba2  3816              move.w   (a6), d4
01011ba4  3a382419          move.w   $2419.w, d5
01011ba8  0316              btst.l   d1, (a6)
01011baa  3824              move.w   -(a4), d4
01011bac  18382420          move.b   $2420.w, d4
01011bb0  4e1b              dc.w     $4e1b
01011bb2  3116              move.w   (a6), -(a0)
01011bb4  4516              chk.l    (a6), d2
01011bb6  4d3947341b4e      chk.l    $47341b4e.l, d6
01011bbc  163a4e28          move.b   $10169e6(pc), d3
01011bc0  29384629          move.l   $4629.w, -(a4)
01011bc4  38284628          move.w   $4628(a0), d4
01011bc8  4e1b              dc.w     $4e1b
01011bca  3116              move.w   (a6), -(a0)
01011bcc  5016              addq.b   #$8, (a6)
01011bce  3848              movea.w  a0, a4
01011bd0  371b              move.w   (a3)+, -(a3)
01011bd2  461b              not.b    (a3)+
01011bd4  3a46              movea.w  d6, a5
01011bd6  24341b46          move.l   ([a4]), d2
01011bda  4b16              chk.l    (a6), d5
01011bdc  3816              move.w   (a6), d4
01011bde  3a382419          move.w   $2419.w, d5
01011be2  0316              btst.l   d1, (a6)
01011be4  3824              move.w   -(a4), d4
01011be6  16382937          move.b   $2937.w, d3
01011bea  511b              subq.b   #$8, (a3)+
01011bec  5040              addq.w   #$8, d0
01011bee  504a              addq.w   #$8, a2
01011bf0  5047              addq.w   #$8, d7
01011bf2  29504e16          move.l   (a0), $4e16(a4)
01011bf6  3a4e              movea.w  a6, a5
01011bf8  1b293846          move.b   $3846(a1), -(a5)
01011bfc  29382450          move.l   $2450.w, -(a4)
01011c00  4e511b51          link.w   a1, #$1b51
01011c04  1650              dc.w     $1650
01011c06  414e              dc.w     $414e
01011c08  5040              addq.w   #$8, d0
01011c0a  1841              dc.w     $1841
01011c0c  183a414e          move.b   $1015d5c(pc), d4
01011c10  2918              move.l   (a0)+, -(a4)
01011c12  4151              dc.w     $4151
01011c14  3816              move.w   (a6), d4
01011c16  3a382419          move.w   $2419.w, d5
01011c1a  011b              btst.l   d0, (a3)+
01011c1c  00163824          ori.b    #$24, (a6)
01011c20  16381b40          move.b   $1b40.w, d3
01011c24  4a4e              tst.w    a6
01011c26  1650              dc.w     $1650
01011c28  164e              dc.w     $164e
01011c2a  46372b46          not.b    ([a7])
01011c2e  1b4d              dc.w     $1b4d
01011c30  4e16              dc.w     $4e16
01011c32  3a4e              movea.w  a6, a5
01011c34  1850              dc.w     $1850
01011c36  3846              movea.w  d6, a4
01011c38  29382429          move.l   $2429.w, -(a4)
01011c3c  464a              dc.w     $464a
01011c3e  4e16              dc.w     $4e16
01011c40  4e500050          link.w   a0, #$50
01011c44  2b24              move.l   -(a4), -(a5)
01011c46  291b              move.l   (a3)+, -(a4)
01011c48  1638163a          move.b   $163a.w, d3
01011c4c  3846              movea.w  d6, a4
01011c4e  1b16              move.b   (a6), -(a5)
01011c50  3850              movea.w  (a0), a4
01011c52  4f41              dc.w     $4f41
01011c54  182d3824          move.b   $3824(a5), d4
01011c58  19514000          move.b   (a1), $4000(a4)
01011c5c  16382416          move.b   $2416.w, d3
01011c60  380b              move.w   a3, d4
01011c62  182b0016          move.b   $16(a3), d4
01011c66  3807              move.w   d7, d4
01011c68  4602              not.b    d2
01011c6a  460b              dc.w     $460b
01011c6c  16380015          move.b   $15.w, d3
01011c70  4118              chk.l    (a0)+, d0
01011c72  2d382419          move.l   $2419.w, -(a6)
01011c76  0316              btst.l   d1, (a6)
01011c78  3824              move.w   -(a4), d4
01011c7a  010a241b          movep.w  $241b(a2), d0
01011c7e  2b00              move.l   d0, -(a5)
01011c80  16380746          move.b   $746.w, d3
01011c84  02460b18          andi.w   #$b18, d6
01011c88  2b01              move.l   d1, -(a5)
01011c8a  461b              not.b    (a3)+
01011c8c  15413319          move.b   d1, $3319(a2)
01011c90  0316              btst.l   d1, (a6)
01011c92  3824              move.w   -(a4), d4
01011c94  010a2950          movep.w  $2950(a2), d0
01011c98  01293807          btst.l   d0, $3807(a1)
01011c9c  4602              not.b    d2
01011c9e  460b              dc.w     $460b
01011ca0  2902              move.l   d2, -(a4)
01011ca2  2500              move.l   d0, -(a2)
01011ca4  4719              chk.l    (a1)+, d3
01011ca6  0316              btst.l   d1, (a6)
01011ca8  504e              addq.w   #$8, a6
01011caa  010a184b          movep.w  $184b(a2), d0
01011cae  01290846          btst.l   d0, $846(a1)
01011cb2  02460b28          andi.w   #$b28, d6
01011cb6  02192200          andi.b   #$0, (a1)+
01011cba  29381903          move.l   $1903.w, -(a4)
01011cbe  1650              dc.w     $1650
01011cc0  4e01              dc.w     $4e01
01011cc2  0000              dc.w     $0000

; ---- gap 01011ce0..0101288b (2988 bytes) ----
01011ce0  4e00              dc.w     $4e00
01011ce2  5900              subq.b   #$4, d0
01011ce4  6d01              blt.b    $1011ce7
01011ce6  0102              btst.l   d0, d2
01011ce8  0103              btst.l   d0, d3
01011cea  0105              btst.l   d0, d5
01011cec  0106              btst.l   d0, d6
01011cee  0107              btst.l   d0, d7
01011cf0  01080109          movep.w  $109(a0), d0
01011cf4  010a010b          movep.w  $10b(a2), d0
01011cf8  010f0116          movep.w  $116(a7), d0
01011cfc  011b              btst.l   d0, (a3)+
01011cfe  011f              btst.l   d0, (a7)+
01011d00  012f013f          btst.l   d0, $13f(a7)
01011d04  0140              bchg.b   d0, d0
01011d06  0143              bchg.b   d0, d3
01011d08  0150              bchg.b   d0, (a0)
01011d0a  0155              bchg.b   d0, (a5)
01011d0c  0155              bchg.b   d0, (a5)
01011d0e  02550355          andi.w   #$355, (a5)
01011d12  04550555          subi.w   #$555, (a5)
01011d16  06550755          addi.w   #$755, (a5)
01011d1a  0855              dc.w     $0855
01011d1c  0955              bchg.b   d4, (a5)
01011d1e  0a550b55          eori.w   #$b55, (a5)
01011d22  0c550d55          cmpi.w   #$d55, (a5)
01011d26  0e55              dc.w     $0e55
01011d28  0f55              bchg.b   d7, (a5)
01011d2a  1055              dc.w     $1055
01011d2c  15551655          move.b   (a5), $1655(a2)
01011d30  17551855          move.b   (a5), $1855(a3)
01011d34  4655              not.w    (a5)
01011d36  4755              dc.w     $4755
01011d38  4855              pea.l    (a5)
01011d3a  4955              dc.w     $4955
01011d3c  4a55              tst.w    (a5)
01011d3e  4b55              dc.w     $4b55
01011d40  4c55              dc.w     $4c55
01011d42  4d55              dc.w     $4d55
01011d44  4e554f55          link.w   a5, #$4f55
01011d48  5055              addq.w   #$8, (a5)
01011d4a  5155              subq.w   #$8, (a5)
01011d4c  5255              addq.w   #$1, (a5)
01011d4e  5355              subq.w   #$1, (a5)
01011d50  5455              addq.w   #$2, (a5)
01011d52  5555              subq.w   #$2, (a5)
01011d54  5655              addq.w   #$3, (a5)
01011d56  5755              subq.w   #$3, (a5)
01011d58  5855              addq.w   #$4, (a5)
01011d5a  5955              subq.w   #$4, (a5)
01011d5c  5e55              addq.w   #$7, (a5)
01011d5e  5f55              subq.w   #$7, (a5)
01011d60  6055              bra.b    $1011db7
01011d62  6c56              bge.b    $1011dba
01011d64  0157              bchg.b   d0, (a7)
01011d66  015b              bchg.b   d0, (a3)+
01011d68  015b              bchg.b   d0, (a3)+
01011d6a  025f0161          andi.w   #$161, (a7)+
01011d6e  016a016f          bchg.b   d0, $16f(a2)
01011d72  017e              dc.w     $017e
01011d74  017f              dc.w     $017f
01011d76  0180              bclr.b   d0, d0
01011d78  0185              bclr.b   d0, d5
01011d7a  0186              bclr.b   d0, d6
01011d7c  0187              bclr.b   d0, d7
01011d7e  018a018b          movep.w  d0, $18b(a2)
01011d82  0190              bclr.b   d0, (a0)
01011d84  0195              bclr.b   d0, (a5)
01011d86  0196              bclr.b   d0, (a6)
01011d88  0197              bclr.b   d0, (a7)
01011d8a  019b              bclr.b   d0, (a3)+
01011d8c  019f              bclr.b   d0, (a7)+
01011d8e  01a1              bclr.b   d0, -(a1)
01011d90  01a4              bclr.b   d0, -(a4)
01011d92  01a5              bclr.b   d0, -(a5)
01011d94  01a901aa          bclr.b   d0, $1aa(a1)
01011d98  05aa11aa          bclr.b   d2, $11aa(a2)
01011d9c  4eaa59aa          jsr      $59aa(a2)
01011da0  6caf              bge.b    $1011d51
01011da2  01be              dc.w     $01be
01011da4  01bf              dc.w     $01bf
01011da6  01c0              bset.b   d0, d0
01011da8  01d0              bset.b   d0, (a0)
01011daa  01d3              bset.b   d0, (a3)
01011dac  01d5              bset.b   d0, (a5)
01011dae  01d6              bset.b   d0, (a6)
01011db0  01e0              bset.b   d0, -(a0)
01011db2  01e4              bset.b   d0, -(a4)
01011db4  01e5              bset.b   d0, -(a5)
01011db6  01e6              bset.b   d0, -(a6)
01011db8  01ef01f0          bset.b   d0, $1f0(a7)
01011dbc  01f401f501f601f8  bset.b   d0, ([$1f601f8])
01011dc4  01f901fb01fc      bset.b   d0, $1fb01fc.l
01011dca  01fd              dc.w     $01fd
01011dcc  01fe              dc.w     $01fe
01011dce  01ff              dc.w     $01ff
01011dd0  01ff              dc.w     $01ff
01011dd2  02ff              dc.w     $02ff
01011dd4  03ff              dc.w     $03ff
01011dd6  04ff              dc.w     $04ff
01011dd8  05ff              dc.w     $05ff
01011dda  06ff              dc.w     $06ff
01011ddc  07ff              dc.w     $07ff
01011dde  08ff              dc.w     $08ff
01011de0  09ff              dc.w     $09ff
01011de2  0aff              dc.w     $0aff
01011de4  0bff              dc.w     $0bff
01011de6  0cff              dc.w     $0cff
01011de8  0dff              dc.w     $0dff
01011dea  6dff6e090c09      blt.l    $6f0a29f5
01011df0  1409              dc.w     $1409
01011df2  180a              dc.w     $180a
01011df4  48680a48          pea.l    $a48(a0)
01011df8  680a              bvc.b    $1011e04
01011dfa  48680a48          pea.l    $a48(a0)
01011dfe  680a              bvc.b    $1011e0a
01011e00  48680a48          pea.l    $a48(a0)
01011e04  680a              bvc.b    $1011e10
01011e06  48680a48          pea.l    $a48(a0)
01011e0a  680a              bvc.b    $1011e16
01011e0c  48680a30          pea.l    $a30(a0)
01011e10  6e3e              bgt.b    $1011e50
01011e12  680a              bvc.b    $1011e1e
01011e14  2f50723e          move.l   (a0), $723e(a7)
01011e18  680a              bvc.b    $1011e24
01011e1a  2e49              movea.l  a1, a7
01011e1c  7f77              dc.w     $7f77
01011e1e  3e680a2e          movea.w  $a2e(a0), a7
01011e22  507f              dc.w     $507f
01011e24  7a3e              moveq    #$3e, d5
01011e26  680a              bvc.b    $1011e32
01011e28  2d49807d          move.l   a1, -$7f83(a6)
01011e2c  3e680a1f          movea.w  $a1f(a0), a7
01011e30  6462              bcc.b    $1011e94
01011e32  5080              addq.l   #$8, d0
01011e34  7e4f              moveq    #$4f, d7
01011e36  6561              bcs.b    $1011e99
01011e38  1f680a1f5306      move.b   $a1f(a0), $5306(a7)
01011e3e  15821a07          move.b   d2, $7(a2, d1.l)
01011e42  0a1f680a          eori.b   #$a, (a7)+
01011e46  1f542c50          move.b   (a4), $2c50(a7)
01011e4a  825a              or.w     (a2)+, d1
01011e4c  394e1f68          move.w   a6, $1f68(a4)
01011e50  0a1f542b          eori.b   #$2b, (a7)+
01011e54  4983              chk.w    d3, d4
01011e56  6e39              bgt.b    $1011e91
01011e58  4e1f              dc.w     $4e1f
01011e5a  680a              bvc.b    $1011e66
01011e5c  1f542b50          move.b   (a4), $2b50(a7)
01011e60  8372394e          or.w     d1, ([a2])
01011e64  1f680a1f542a      move.b   $a1f(a0), $542a(a7)
01011e6a  4984              chk.w    d4, d4
01011e6c  7739              dc.w     $7739
01011e6e  4e1f              dc.w     $4e1f
01011e70  680a              bvc.b    $1011e7c
01011e72  1f542a50          move.b   (a4), $2a50(a7)
01011e76  7f72              dc.w     $7f72
01011e78  000d              dc.w     $000d
01011e7a  6a7f              bpl.b    $1011efb
01011e7c  7a39              moveq    #$39, d5
01011e7e  4e1f              dc.w     $4e1f
01011e80  680a              bvc.b    $1011e8c
01011e82  1f542949          move.b   (a4), $2949(a7)
01011e86  7f7d              dc.w     $7f7d
01011e88  020f              dc.w     $020f
01011e8a  7f7d              dc.w     $7f7d
01011e8c  394e1f68          move.w   a6, $1f68(a4)
01011e90  0a1f5429          eori.b   #$29, (a7)+
01011e94  507f              dc.w     $507f
01011e96  6c03              bge.b    $1011e9b
01011e98  527e              dc.w     $527e
01011e9a  394e1f68          move.w   a6, $1f68(a4)
01011e9e  0a1f5428          eori.b   #$28, (a7)+
01011ea2  497f              dc.w     $497f
01011ea4  7e04              moveq    #$4, d7
01011ea6  147f              dc.w     $147f
01011ea8  394e1f68          move.w   a6, $1f68(a4)
01011eac  0a1f5428          eori.b   #$28, (a7)+
01011eb0  507f              dc.w     $507f
01011eb2  7604              moveq    #$4, d3
01011eb4  0b7f              dc.w     $0b7f
01011eb6  5a384e1f          addq.b   #$5, $4e1f.w
01011eba  680a              bvc.b    $1011ec6
01011ebc  1f542749          move.b   (a4), $2749(a7)
01011ec0  8070011d          or.w     ([a0], d0.w), d0
01011ec4  1a01              move.b   d1, d5
01011ec6  6a6e              bpl.b    $1011f36
01011ec8  384e              movea.w  a6, a4
01011eca  1f680a1f5427      move.b   $a1f(a0), $5427(a7)
01011ed0  5080              addq.l   #$8, d0
01011ed2  1a00              move.b   d0, d5
01011ed4  17801a00          move.b   d0, (a3, d1.l * 2)
01011ed8  1872              dc.w     $1872
01011eda  384e              movea.w  a6, a4
01011edc  1f680a1f5426      move.b   $a1f(a0), $5426(a7)
01011ee2  4980              chk.w    d0, d4
01011ee4  7e00              moveq    #$0, d7
01011ee6  0a8176001377      eori.l   #$76001377, d1
01011eec  384e              movea.w  a6, a4
01011eee  1f680a1f5426      move.b   $a1f(a0), $5426(a7)
01011ef4  5080              addq.l   #$8, d0
01011ef6  7c00              moveq    #$0, d6
01011ef8  0f81              bclr.b   d7, d1
01011efa  7d00              dc.w     $7d00
01011efc  0c7a384e1f68      cmpi.w   #$384e, $1013e66(pc)
01011f02  0a1f5425          eori.b   #$25, (a7)+
01011f06  4981              chk.w    d1, d4
01011f08  7600              moveq    #$0, d3
01011f0a  1782000a          move.b   d2, $a(a3, d0.w)
01011f0e  7d38              dc.w     $7d38
01011f10  4e1f              dc.w     $4e1f
01011f12  680a              bvc.b    $1011f1e
01011f14  1f542550          move.b   (a4), $2550(a7)
01011f18  81750052          or.w     d0, $52(a5, d0.w)
01011f1c  8179017e384e      or.w     d0, $17e384e.l
01011f22  1f680a1f5424      move.b   $a1f(a0), $5424(a7)
01011f28  4982              chk.w    d2, d4
01011f2a  6c008253          bge.w    $100a17f
01011f2e  016a384e          bchg.b   d0, $384e(a2)
01011f32  1f680a1f5424      move.b   $a1f(a0), $5424(a7)
01011f38  5082              addq.l   #$8, d2
01011f3a  6b0b              bmi.b    $1011f47
01011f3c  817c              dc.w     $817c
01011f3e  0113              btst.l   d0, (a3)
01011f40  7f5a              dc.w     $7f5a
01011f42  374e1f68          move.w   a6, $1f68(a3)
01011f46  0a1f5423          eori.b   #$23, (a7)+
01011f4a  4980              chk.w    d0, d4
01011f4c  6d80              blt.b    $1011ece
01011f4e  530c              dc.w     $530c
01011f50  8153              or.w     d0, (a3)
01011f52  0180              bclr.b   d0, d0
01011f54  6e37              bgt.b    $1011f8d
01011f56  4e1f              dc.w     $4e1f
01011f58  680a              bvc.b    $1011f64
01011f5a  1f542350          move.b   (a4), $2350(a7)
01011f5e  7f7d              dc.w     $7f7d
01011f60  0b80              bclr.b   d5, d0
01011f62  1a0f              dc.w     $1a0f
01011f64  807901138072      or.w     $1138072.l, d0
01011f6a  374e1f68          move.w   a6, $1f68(a3)
01011f6e  0a1f5422          eori.b   #$22, (a7)+
01011f72  4980              chk.w    d0, d4
01011f74  7000              moveq    #$0, d0
01011f76  801a              or.b     (a2)+, d0
01011f78  1480              move.b   d0, (a2)
01011f7a  6b01              bmi.b    $1011f7d
01011f7c  6a80              bpl.b    $1011efe
01011f7e  7737              dc.w     $7737
01011f80  4e1f              dc.w     $4e1f
01011f82  680a              bvc.b    $1011f8e
01011f84  1f542250          move.b   (a4), $2250(a7)
01011f88  8079006a7f00      or.w     $6a7f00.l, d0
01011f8e  147f              dc.w     $147f
01011f90  7901              dc.w     $7901
01011f92  1481              move.b   d1, (a2)
01011f94  7a37              moveq    #$37, d5
01011f96  4e1f              dc.w     $4e1f
01011f98  680a              bvc.b    $1011fa4
01011f9a  1f542149          move.b   (a4), $2149(a7)
01011f9e  817c              dc.w     $817c
01011fa0  00197f00          ori.b    #$0, (a1)+
01011fa4  147f              dc.w     $147f
01011fa6  5301              subq.b   #$1, d1
01011fa8  6a7f              bpl.b    $1012029
01011faa  6e4d              bgt.b    $1011ff9
01011fac  7d37              dc.w     $7d37
01011fae  4e1f              dc.w     $4e1f
01011fb0  680a              bvc.b    $1011fbc
01011fb2  1f542150          move.b   (a4), $2150(a7)
01011fb6  817e              dc.w     $817e
01011fb8  00187f00          ori.b    #$0, (a0)+
01011fbc  1479              dc.w     $1479
01011fbe  0113              btst.l   d0, (a3)
01011fc0  806b147e          or.w     $147e(a3), d0
01011fc4  374e1f68          move.w   a6, $1f68(a3)
01011fc8  0a1f5420          eori.b   #$20, (a7)+
01011fcc  4983              chk.w    d3, d4
01011fce  00147f00          ori.b    #$0, (a4)
01011fd2  146b              dc.w     $146b
01011fd4  016a806b          bchg.b   d0, -$7f95(a2)
01011fd8  147f              dc.w     $147f
01011fda  374e1f68          move.w   a6, $1f68(a3)
01011fde  0a1f5420          eori.b   #$20, (a7)+
01011fe2  5083              addq.l   #$8, d3
01011fe4  5313              subq.b   #$1, (a3)
01011fe6  7f00              dc.w     $7f00
01011fe8  1001              move.b   d1, d0
01011fea  13816b14          move.b   d1, (a1, d6.l * 2)
01011fee  7f5a              dc.w     $7f5a
01011ff0  364e              movea.w  a6, a3
01011ff2  1f680a1f541f      move.b   $a1f(a0), $541f(a7)
01011ff8  4984              chk.w    d4, d4
01011ffa  6b0c              bmi.b    $1012008
01011ffc  7f03              dc.w     $7f03
01011ffe  6a81              bpl.b    $1011f81
01012000  5314              subq.b   #$1, (a4)
01012002  7f6e              dc.w     $7f6e
01012004  364e              movea.w  a6, a3
01012006  1f680a1f541f      move.b   $a1f(a0), $541f(a7)
0101200c  5084              addq.l   #$8, d4
0101200e  700b              moveq    #$b, d0
01012010  7f1a              dc.w     $7f1a
01012012  0113              btst.l   d0, (a3)
01012014  821a              or.b     (a2)+, d1
01012016  177f              dc.w     $177f
01012018  7236              moveq    #$36, d1
0101201a  4e1f              dc.w     $4e1f
0101201c  680a              bvc.b    $1012028
0101201e  1f541e49          move.b   (a4), $1e49(a7)
01012022  8575007f          or.w     d2, $7f(a5, d0.w)
01012026  1a01              move.b   d1, d5
01012028  6a82              bpl.b    $1011fac
0101202a  00177f77          ori.b    #$77, (a7)
0101202e  364e              movea.w  a6, a3
01012030  1f680a1f541e      move.b   $a1f(a0), $541e(a7)
01012036  5085              addq.l   #$8, d5
01012038  7900              dc.w     $7900
0101203a  6a53              bpl.b    $101208f
0101203c  0013827e          ori.b    #$7e, (a3)
01012040  00187f7a          ori.b    #$7a, (a0)+
01012044  364e              movea.w  a6, a3
01012046  1f680a1f541d      move.b   $a1f(a0), $541d(a7)
0101204c  4986              chk.w    d6, d4
0101204e  7c00              moveq    #$0, d6
01012050  196b006a827c      move.b   $6a(a3), -$7d84(a4)
01012056  00197f7d          ori.b    #$7d, (a1)+
0101205a  364e              movea.w  a6, a3
0101205c  1f680a1f541d      move.b   $a1f(a0), $541d(a7)
01012062  4d86              chk.w    d6, d6
01012064  7e00              moveq    #$0, d7
01012066  186c              dc.w     $186c
01012068  0b83              bclr.b   d5, d3
0101206a  7600              moveq    #$0, d3
0101206c  527f              dc.w     $527f
0101206e  7e36              moveq    #$36, d7
01012070  4e1f              dc.w     $4e1f
01012072  680a              bvc.b    $101207e
01012074  1f541d4b          move.b   (a4), $1d4b(a7)
01012078  7d6a              dc.w     $7d6a
0101207a  8500              sbcd.b   d0, d2
0101207c  1475              dc.w     $1475
0101207e  008375008136      ori.l    #$75008136, d3
01012084  4e1f              dc.w     $4e1f
01012086  680a              bvc.b    $1012092
01012088  1f541d5c          move.b   (a4), $1d5c(a7)
0101208c  7e0b              moveq    #$b, d7
0101208e  8553              or.w     d2, (a3)
01012090  13760019826b      move.b   $19(a6, d0.w), -$7d95(a1)
01012096  0b81              bclr.b   d5, d1
01012098  5a354e1f          addq.b   #$5, $1f(a5, d4.l)
0101209c  680a              bvc.b    $10120a8
0101209e  1f541d6f          move.b   (a4), $1d6f(a7)
010120a2  7f00              dc.w     $7f00
010120a4  13846b0c          move.b   d4, (a1, d6.l * 2)
010120a8  7c00              moveq    #$0, d6
010120aa  1482              move.b   d2, (a2)
010120ac  000c              dc.w     $000c
010120ae  816e354e          or.w     d0, $354e(a6)
010120b2  1f680a1f541d      move.b   $a1f(a0), $541d(a7)
010120b8  727f              moveq    #$7f, d1
010120ba  5300              subq.b   #$1, d0
010120bc  1683              move.b   d3, (a3)
010120be  700b              moveq    #$b, d0
010120c0  7f00              dc.w     $7f00
010120c2  0b81              bclr.b   d5, d1
010120c4  7600              moveq    #$0, d3
010120c6  1480              move.b   d0, (a2)
010120c8  7472              moveq    #$72, d2
010120ca  354e1f68          move.w   a6, $1f68(a2)
010120ce  0a1f5449          eori.b   #$49, (a7)+
010120d2  776a              dc.w     $776a
010120d4  6b01              bmi.b    $10120d7
010120d6  1682              move.b   d2, (a3)
010120d8  7500              dc.w     $7500
010120da  7f53              dc.w     $7f53
010120dc  00188053          ori.b    #$53, (a0)+
010120e0  00197f7e          ori.b    #$7e, (a1)+
010120e4  1477              dc.w     $1477
010120e6  354e1f68          move.w   a6, $1f68(a2)
010120ea  0a1f544a          eori.b   #$4a, (a7)+
010120ee  7a52              moveq    #$52, d5
010120f0  7002              moveq    #$2, d0
010120f2  1881              move.b   d1, (a4)
010120f4  7900              dc.w     $7900
010120f6  6a70              bpl.b    $1012168
010120f8  000a              dc.w     $000a
010120fa  6a71              bpl.b    $101216d
010120fc  0180              bclr.b   d0, d0
010120fe  7013              moveq    #$13, d0
01012100  7a35              moveq    #$35, d5
01012102  4e1f              dc.w     $4e1f
01012104  680a              bvc.b    $1012110
01012106  1f544b7d          move.b   (a4), $4b7d(a7)
0101210a  50750350          addq.w   #$8, (a5, invalid.w)
0101210e  807c0019          or.w     #$19, d0
01012112  7904              dc.w     $7904
01012114  0c7f              dc.w     $0c7f
01012116  7e00              moveq    #$0, d7
01012118  0c7d              dc.w     $0c7d
0101211a  354e1f68          move.w   a6, $1f68(a2)
0101211e  0a1f544b          eori.b   #$4b, (a7)+
01012122  7e4d              moveq    #$4d, d7
01012124  7904              dc.w     $7904
01012126  6a7f              bpl.b    $10121a7
01012128  7e00              moveq    #$0, d7
0101212a  187e              dc.w     $187e
0101212c  04147f70          subi.b   #$70, (a4)
01012130  000b              dc.w     $000b
01012132  7e35              moveq    #$35, d7
01012134  4e1f              dc.w     $4e1f
01012136  680a              bvc.b    $1012142
01012138  1f544d7f          move.b   (a4), $4d7f(a7)
0101213c  4b7c              dc.w     $4b7c
0101213e  040b              dc.w     $040b
01012140  8000              or.b     d0, d0
01012142  147f              dc.w     $147f
01012144  6c03              bge.b    $1012149
01012146  6a7e              bpl.b    $10121c6
01012148  010b7f35          movep.w  $7f35(a3), d0
0101214c  4e1f              dc.w     $4e1f
0101214e  680a              bvc.b    $101215a
01012150  1f544d7f          move.b   (a4), $4d7f(a7)
01012154  5c7e              dc.w     $5c7e
01012156  0011030e          ori.b    #$e, (a1)
0101215a  7f53              dc.w     $7f53
0101215c  137f              dc.w     $137f
0101215e  7d02              dc.w     $7d02
01012160  0f7f              dc.w     $0f7f
01012162  7001              moveq    #$1, d0
01012164  187f              dc.w     $187f
01012166  5a344e1f          addq.b   #$5, $1f(a4, d4.l)
0101216a  680a              bvc.b    $1012176
0101216c  1f54507f          move.b   (a4), $507f(a7)
01012170  6f7f              ble.b    $10121f1
01012172  00137a03          ori.b    #$3, (a3)
01012176  0e6b              dc.w     $0e6b
01012178  0c8072000e6a      cmpi.l   #$72000e6a, d0
0101217e  7e01              moveq    #$1, d7
01012180  0b80              bclr.b   d5, d0
01012182  6e34              bgt.b    $10121b8
01012184  4e1f              dc.w     $4e1f
01012186  680a              bvc.b    $1012192
01012188  1f54507f          move.b   (a4), $507f(a7)
0101218c  727f              moveq    #$7f, d1
0101218e  530c              dc.w     $530c
01012190  7f7a              dc.w     $7f7a
01012192  040b              dc.w     $040b
01012194  84700118          or.w     (a0, d0.w), d2
01012198  8072344e          or.w     $4e(a2, d3.w), d0
0101219c  1f680a1f5452      move.b   $a1f(a0), $5452(a7)
010121a2  7f77              dc.w     $7f77
010121a4  6a6b              bpl.b    $1012211
010121a6  0b80              bclr.b   d5, d0
010121a8  7604              moveq    #$4, d3
010121aa  837e              dc.w     $837e
010121ac  010b8177          movep.w  -$7e89(a3), d0
010121b0  344e              movea.w  a6, a2
010121b2  1f680a1f5452      move.b   $a1f(a0), $5452(a7)
010121b8  7f7a              dc.w     $7f7a
010121ba  52700081          addq.w   #$1, -$7f(a0, d0.w)
010121be  7103              dc.w     $7103
010121c0  6a82              bpl.b    $1012144
010121c2  7001              moveq    #$1, d0
010121c4  1881              move.b   d1, (a4)
010121c6  7a34              moveq    #$34, d5
010121c8  4e1f              dc.w     $4e1f
010121ca  680a              bvc.b    $10121d6
010121cc  1f546a7f          move.b   (a4), $6a7f(a7)
010121d0  7d50              dc.w     $7d50
010121d2  7500              dc.w     $7500
010121d4  6a81              bpl.b    $1012157
010121d6  6c02              bge.b    $10121da
010121d8  19817e01          move.b   d1, $1(a4, d7.l)
010121dc  0b82              bclr.b   d5, d2
010121de  7d34              dc.w     $7d34
010121e0  4e1f              dc.w     $4e1f
010121e2  680a              bvc.b    $10121ee
010121e4  1f546a7f          move.b   (a4), $6a7f(a7)
010121e8  7e4d              moveq    #$4d, d7
010121ea  7900              dc.w     $7900
010121ec  19825901          move.b   d2, ([a4, d5.l])
010121f0  1881              move.b   d1, (a4)
010121f2  7001              moveq    #$1, d0
010121f4  1482              move.b   d2, (a2)
010121f6  7e34              moveq    #$34, d7
010121f8  4e1f              dc.w     $4e1f
010121fa  680a              bvc.b    $1012206
010121fc  1f54814b          move.b   (a4), -$7eb5(a7)
01012200  7c00              moveq    #$0, d6
01012202  1883              move.b   d3, (a4)
01012204  5900              subq.b   #$4, d0
01012206  1480              move.b   d0, (a2)
01012208  7e02              moveq    #$2, d7
0101220a  1483              move.b   d3, (a2)
0101220c  344e              movea.w  a6, a2
0101220e  1f680a1f5581      move.b   $a1f(a0), $5581(a7)
01012214  5c7e              dc.w     $5c7e
01012216  00148459          ori.b    #$59, (a4)
0101221a  13807002          move.b   d0, $2(a1, d7.w)
0101221e  13835a33          move.b   d3, $33(a1, d5.l)
01012222  4e1f              dc.w     $4e1f
01012224  680a              bvc.b    $1012230
01012226  1f55816f          move.b   (a5), -$7e91(a7)
0101222a  7f00              dc.w     $7f00
0101222c  13851b7f7e010a6b  move.b   d5, ([$7e010a6b, a1])
01012234  0c836e334e1f      cmpi.l   #$6e334e1f, d3
0101223a  680a              bvc.b    $1012246
0101223c  1f568172          move.b   (a6), -$7e8e(a7)
01012240  7f53              dc.w     $7f53
01012242  0c8770011870      cmpi.l   #$70011870, d7
01012248  0b83              bclr.b   d5, d3
0101224a  7233              moveq    #$33, d1
0101224c  4e1f              dc.w     $4e1f
0101224e  680a              bvc.b    $101225a
01012250  1f568177          move.b   (a6), -$7e89(a7)
01012254  6a6b              bpl.b    $10122c1
01012256  0b87              bclr.b   d5, d7
01012258  5300              subq.b   #$1, d0
0101225a  0b7f              dc.w     $0b7f
0101225c  7500              dc.w     $7500
0101225e  8377334e          or.w     d1, ([a7])
01012262  1f680a1f5881      move.b   $a1f(a0), $5881(a7)
01012268  7a52              moveq    #$52, d5
0101226a  7000              moveq    #$0, d0
0101226c  857b              dc.w     $857b
0101226e  7f6b              dc.w     $7f6b
01012270  00187f79          ori.b    #$79, (a0)+
01012274  006a827a334e      ori.w    #$827a, $334e(a2)
0101227a  1f680a1f5881      move.b   $a1f(a0), $5881(a7)
01012280  7d50              dc.w     $7d50
01012282  7500              dc.w     $7500
01012284  6a84              bpl.b    $101220a
01012286  754d              dc.w     $754d
01012288  6c0b              bge.b    $1012295
0101228a  807c0019          or.w     #$19, d0
0101228e  827d              dc.w     $827d
01012290  334e1f68          move.w   a6, $1f68(a1)
01012294  0a1f5e81          eori.b   #$81, (a7)+
01012298  7e4d              moveq    #$4d, d7
0101229a  7900              dc.w     $7900
0101229c  19846c0b          move.b   d4, $b(a4, d6.l)
010122a0  7518              dc.w     $7518
010122a2  807e              dc.w     $807e
010122a4  0018827e          ori.b    #$7e, (a0)+
010122a8  334e1f68          move.w   a6, $1f68(a1)
010122ac  0a1f4d82          eori.b   #$82, (a7)+
010122b0  4b7c              dc.w     $4b7c
010122b2  0018846b          ori.b    #$6b, (a0)+
010122b6  0c7982001483334e  cmpi.w   #$8200, $1483334e.l
010122be  1f680a1f5082      move.b   $a1f(a0), $5082(a7)
010122c4  5c7e              dc.w     $5c7e
010122c6  0014846b          ori.b    #$6b, (a4)
010122ca  0c835313835a      cmpi.l   #$5313835a, d3
010122d0  324e              movea.w  a6, a1
010122d2  1f680a1f5082      move.b   $a1f(a0), $5082(a7)
010122d8  6f7f              ble.b    $1012359
010122da  00138453          ori.b    #$53, (a3)
010122de  0f83              bclr.b   d7, d3
010122e0  6b0c              bmi.b    $10122ee
010122e2  836e324e          or.w     d1, $324e(a6)
010122e6  1f680a1f5282      move.b   $a1f(a0), $5282(a7)
010122ec  727f              moveq    #$7f, d1
010122ee  530c              dc.w     $530c
010122f0  841a              or.b     (a2)+, d2
010122f2  1383700b          move.b   d3, $b(a1, d7.w)
010122f6  8372324e          or.w     d1, $4e(a2, d3.w)
010122fa  1f680a1f6a82      move.b   $a1f(a0), $6a82(a7)
01012300  776a              dc.w     $776a
01012302  6b0b              bmi.b    $101230f
01012304  8400              or.b     d0, d2
01012306  1483              move.b   d3, (a2)
01012308  7500              dc.w     $7500
0101230a  8377324e          or.w     d1, $4e(a7, d3.w)
0101230e  1f680a1f6a82      move.b   $a1f(a0), $6a82(a7)
01012314  7a52              moveq    #$52, d5
01012316  7000              moveq    #$0, d0
01012318  837e              dc.w     $837e
0101231a  00178379          ori.b    #$79, (a7)
0101231e  006a827a324e      ori.w    #$827a, $324e(a2)
01012324  1f680a1f837d      move.b   $a1f(a0), -$7c83(a7)
0101232a  5075006a          addq.w   #$8, $6a(a5, d0.w)
0101232e  827d              dc.w     $827d
01012330  0018837c          ori.b    #$7c, (a0)+
01012334  0019827d          ori.b    #$7d, (a1)+
01012338  324e              movea.w  a6, a1
0101233a  1f680a1e4983      move.b   $a1e(a0), $4983(a7)
01012340  7e4d              moveq    #$4d, d7
01012342  7913              dc.w     $7913
01012344  837c              dc.w     $837c
01012346  0019837e          ori.b    #$7e, (a1)+
0101234a  0018827e          ori.b    #$7e, (a0)+
0101234e  324e              movea.w  a6, a1
01012350  1f680a1e4984      move.b   $a1e(a0), $4984(a7)
01012356  4b7c              dc.w     $4b7c
01012358  6a83              bpl.b    $10122dd
0101235a  7900              dc.w     $7900
0101235c  5284              addq.l   #$1, d4
0101235e  00148332          ori.b    #$32, (a4)
01012362  4e1f              dc.w     $4e1f
01012364  680a              bvc.b    $1012370
01012366  1e4a              dc.w     $1e4a
01012368  845c              or.w     (a4)+, d2
0101236a  8576006a          or.w     d2, $6a(a6, d0.w)
0101236e  8453              or.w     (a3), d2
01012370  13835a31          move.b   d3, $31(a1, d5.l)
01012374  4e1f              dc.w     $4e1f
01012376  680a              bvc.b    $1012382
01012378  1e4a              dc.w     $1e4a
0101237a  846f8575          or.w     -$7a8b(a7), d2
0101237e  00856b0c836e      ori.l    #$6b0c836e, d5
01012384  314e1f68          move.w   a6, $1f68(a0)
01012388  0a1e4b84          eori.b   #$84, (a6)+
0101238c  727f              moveq    #$7f, d1
0101238e  7950              dc.w     $7950
01012390  82700a85          or.w     -$7b(a0, d0.l), d1
01012394  700b              moveq    #$b, d0
01012396  8372314e          or.w     d1, ([a2])
0101239a  1f680a1e4b84      move.b   $a1e(a0), $4b84(a7)
010123a0  776a              dc.w     $776a
010123a2  760a              moveq    #$a, d3
010123a4  6a81              bpl.b    $1012327
010123a6  6c0b              bge.b    $10123b3
010123a8  85750083          or.w     d2, -$7d(a5, d0.w)
010123ac  7231              moveq    #$31, d1
010123ae  4e1f              dc.w     $4e1f
010123b0  680a              bvc.b    $10123bc
010123b2  1e4d              dc.w     $1e4d
010123b4  847a5275          or.w     $101762b(pc), d2
010123b8  000e              dc.w     $000e
010123ba  816b0c85          or.w     d0, $c85(a3)
010123be  7900              dc.w     $7900
010123c0  6a82              bpl.b    $1012344
010123c2  5a314e1f          addq.b   #$5, $1f(a1, d4.l)
010123c6  680a              bvc.b    $10123d2
010123c8  1e4d              dc.w     $1e4d
010123ca  847d              dc.w     $847d
010123cc  507001168053      addq.w   #$8, ([a0], d0.w, $8053)
010123d2  0f85              bclr.b   d7, d5
010123d4  7c00              moveq    #$0, d6
010123d6  19817a32          move.b   d1, $32(a4, d7.l)
010123da  4e1f              dc.w     $4e1f
010123dc  680a              bvc.b    $10123e8
010123de  1e50              dc.w     $1e50
010123e0  847e              dc.w     $847e
010123e2  4d6c              dc.w     $4d6c
010123e4  02507f1a          andi.w   #$7f1a, (a0)
010123e8  13857e00          move.b   d5, (a1, d7.l * 8)
010123ec  1881              move.b   d1, (a4)
010123ee  5a324e1f          addq.b   #$5, $1f(a2, d4.l)
010123f2  680a              bvc.b    $10123fe
010123f4  1e52              dc.w     $1e52
010123f6  854b7102          pack     -(a3), -(a2), #$7102
010123fa  0a6a00148600      eori.w   #$14, -$7a00(a2)
01012400  1480              move.b   d0, (a2)
01012402  7a49              moveq    #$49, d5
01012404  5a314e1f          addq.b   #$5, $1f(a1, d4.l)
01012408  680a              bvc.b    $1012414
0101240a  1e52              dc.w     $1e52
0101240c  855c              or.w     d2, (a4)+
0101240e  7f59              dc.w     $7f59
01012410  020d              dc.w     $020d
01012412  00178653          ori.b    #$53, (a7)
01012416  13805a50          move.b   d0, $50(a1, d5.l)
0101241a  324e              movea.w  a6, a1
0101241c  1f680a1e5085      move.b   $a1e(a0), $5085(a7)
01012422  6f7f              ble.b    $10124a3
01012424  7e1a              moveq    #$1a, d7
01012426  0318              btst.l   d1, (a0)+
01012428  866b0c7f          or.w     $c7f(a3), d3
0101242c  7a49              moveq    #$49, d5
0101242e  7e32              moveq    #$32, d7
01012430  4e1f              dc.w     $4e1f
01012432  680a              bvc.b    $101243e
01012434  1e4d              dc.w     $1e4d
01012436  8572807a          or.w     d2, $7a(a2, a0.w)
0101243a  0316              btst.l   d1, (a6)
0101243c  8670187f          or.w     $7f(a0, d1.l), d3
01012440  5a50              addq.w   #$5, (a0)
01012442  7d32              dc.w     $7d32
01012444  4e1f              dc.w     $4e1f
01012446  680a              bvc.b    $1012452
01012448  1e4b              dc.w     $1e4b
0101244a  85776a80          or.w     d2, -$80(a7, d6.l)
0101244e  7103              dc.w     $7103
01012450  5085              addq.l   #$8, d5
01012452  787f              moveq    #$7f, d4
01012454  7a49              moveq    #$49, d5
01012456  7f7a              dc.w     $7f7a
01012458  324e              movea.w  a6, a1
0101245a  1f680a1e4a85      move.b   $a1e(a0), $4a85(a7)
01012460  7a52              moveq    #$52, d5
01012462  8159              or.w     d0, (a1)+
01012464  020a              dc.w     $020a
01012466  6a86              bpl.b    $10123ee
01012468  5a50              addq.w   #$5, (a0)
0101246a  7f77              dc.w     $7f77
0101246c  324e              movea.w  a6, a1
0101246e  1f680a1e4985      move.b   $a1e(a0), $4985(a7)
01012474  7d50              dc.w     $7d50
01012476  817e              dc.w     $817e
01012478  1a02              move.b   d2, d5
0101247a  0e85              dc.w     $0e85
0101247c  7a49              moveq    #$49, d5
0101247e  8072324e          or.w     $4e(a2, d3.w), d0
01012482  1f680a1f857e      move.b   $a1f(a0), -$7a82(a7)
01012488  4d82              chk.w    d2, d6
0101248a  6b03              bmi.b    $101248f
0101248c  1684              move.b   d4, (a3)
0101248e  5a50              addq.w   #$5, (a0)
01012490  806e324e          or.w     $324e(a6), d0
01012494  1f680a1f6a85      move.b   $a1f(a0), $6a85(a7)
0101249a  4b82              chk.w    d2, d5
0101249c  6b04              bmi.b    $10124a2
0101249e  5082              addq.l   #$8, d2
010124a0  7a49              moveq    #$49, d5
010124a2  815a              or.w     d0, (a2)+
010124a4  324e              movea.w  a6, a1
010124a6  1f680a1f5285      move.b   $a1f(a0), $5285(a7)
010124ac  5c82              addq.l   #$6, d2
010124ae  530f              dc.w     $530f
010124b0  6002              bra.b    $10124b4
010124b2  0a6a815a5081      eori.w   #$815a, $5081(a2)
010124b8  334e1f68          move.w   a6, $1f68(a1)
010124bc  0a1f5085          eori.b   #$85, (a7)+
010124c0  6f82              ble.b    $1012444
010124c2  1a13              move.b   (a3), d5
010124c4  7f59              dc.w     $7f59
010124c6  0218807a          andi.b   #$7a, (a0)+
010124ca  4981              chk.w    d1, d4
010124cc  7e33              moveq    #$33, d7
010124ce  4e1f              dc.w     $4e1f
010124d0  680a              bvc.b    $10124dc
010124d2  1f4d              dc.w     $1f4d
010124d4  85728200          or.w     d2, (a2, a0.w * 2)
010124d8  147f              dc.w     $147f
010124da  7e1a              moveq    #$1a, d7
010124dc  0119              btst.l   d0, (a1)+
010124de  805a              or.w     (a2)+, d0
010124e0  5081              addq.l   #$8, d1
010124e2  7e33              moveq    #$33, d7
010124e4  4e1f              dc.w     $4e1f
010124e6  680a              bvc.b    $10124f2
010124e8  1f5d8577          move.b   (a5)+, -$7a89(a7)
010124ec  6a80              bpl.b    $101246e
010124ee  7e00              moveq    #$0, d7
010124f0  17807a01          move.b   d0, $1(a3, d7.l)
010124f4  527f              dc.w     $527f
010124f6  7a49              moveq    #$49, d5
010124f8  827d              dc.w     $827d
010124fa  334e1f68          move.w   a6, $1f68(a1)
010124fe  0a1f5685          eori.b   #$85, (a7)+
01012502  7a52              moveq    #$52, d5
01012504  807d              dc.w     $807d
01012506  00188171          ori.b    #$71, (a0)+
0101250a  006a7f5a5082      ori.w    #$7f5a, $5082(a2)
01012510  7a33              moveq    #$33, d5
01012512  4e1f              dc.w     $4e1f
01012514  680a              bvc.b    $1012520
01012516  1f55857d          move.b   (a5), -$7a83(a7)
0101251a  5080              addq.l   #$8, d0
0101251c  7c00              moveq    #$0, d6
0101251e  1982597f7a498377  move.b   d2, ([$7a498377, a4])
01012526  334e1f68          move.w   a6, $1f68(a1)
0101252a  0a1f5485          eori.b   #$85, (a7)+
0101252e  7e4d              moveq    #$4d, d7
01012530  80790052827e      or.w     $52827e.l, d0
01012536  7f5a              dc.w     $7f5a
01012538  5083              addq.l   #$8, d3
0101253a  7233              moveq    #$33, d1
0101253c  4e1f              dc.w     $4e1f
0101253e  680a              bvc.b    $101254a
01012540  1f546a85          move.b   (a4), $6a85(a7)
01012544  4b80              chk.w    d0, d5
01012546  7600              moveq    #$0, d3
01012548  6a83              bpl.b    $10124cd
0101254a  7a49              moveq    #$49, d5
0101254c  846e334e          or.w     $334e(a6), d2
01012550  1f680a1f5452      move.b   $a1f(a0), $5452(a7)
01012556  855c              or.w     d2, (a4)+
01012558  80750084          or.w     -$7c(a5, d0.w), d0
0101255c  5a50              addq.w   #$5, (a0)
0101255e  845a              or.w     (a2)+, d2
01012560  334e1f68          move.w   a6, $1f68(a1)
01012564  0a1f5450          eori.b   #$50, (a7)+
01012568  856f8070          or.w     d2, -$7f90(a7)
0101256c  0a837a498534      eori.l   #$7a498534, d3
01012572  4e1f              dc.w     $4e1f
01012574  680a              bvc.b    $1012580
01012576  1f544d85          move.b   (a4), $4d85(a7)
0101257a  7280              moveq    #$80, d1
0101257c  6c0b              bge.b    $1012589
0101257e  835a              or.w     d1, (a2)+
01012580  5084              addq.l   #$8, d4
01012582  7e34              moveq    #$34, d7
01012584  4e1f              dc.w     $4e1f
01012586  680a              bvc.b    $1012592
01012588  1f544b85          move.b   (a4), $4b85(a7)
0101258c  776a              dc.w     $776a
0101258e  7f6b              dc.w     $7f6b
01012590  0c827a49857d      cmpi.l   #$7a49857d, d2
01012596  344e              movea.w  a6, a2
01012598  1f680a1f544a      move.b   $a1f(a0), $544a(a7)
0101259e  857a              dc.w     $857a
010125a0  527f              dc.w     $527f
010125a2  530f              dc.w     $530f
010125a4  825a              or.w     (a2)+, d1
010125a6  5085              addq.l   #$8, d5
010125a8  7a34              moveq    #$34, d5
010125aa  4e1f              dc.w     $4e1f
010125ac  680a              bvc.b    $10125b8
010125ae  1f544985          move.b   (a4), $4985(a7)
010125b2  7d50              dc.w     $7d50
010125b4  7f1a              dc.w     $7f1a
010125b6  13817a49          move.b   d1, $49(a1, d7.l)
010125ba  8677344e          or.w     $4e(a7, d3.w), d3
010125be  1f680a1f541d      move.b   $a1f(a0), $541d(a7)
010125c4  857e              dc.w     $857e
010125c6  4d7f              dc.w     $4d7f
010125c8  0014815a          ori.b    #$5a, (a4)
010125cc  5086              addq.l   #$8, d6
010125ce  7234              moveq    #$34, d1
010125d0  4e1f              dc.w     $4e1f
010125d2  680a              bvc.b    $10125de
010125d4  1f541d6a          move.b   (a4), $1d6a(a7)
010125d8  854b7e00          pack     -(a3), -(a2), #$7e00
010125dc  17807a49          move.b   d0, $49(a3, d7.l)
010125e0  8772344e          or.w     d3, $4e(a2, d3.w)
010125e4  1f680a1f541d      move.b   $a1f(a0), $541d(a7)
010125ea  5285              addq.l   #$1, d5
010125ec  5c7d              dc.w     $5c7d
010125ee  0018805a          ori.b    #$5a, (a0)+
010125f2  5087              addq.l   #$8, d7
010125f4  6e34              bgt.b    $101262a
010125f6  4e1f              dc.w     $4e1f
010125f8  680a              bvc.b    $1012604
010125fa  1f541d50          move.b   (a4), $1d50(a7)
010125fe  856f7c00          or.w     d2, $7c00(a7)
01012602  197f              dc.w     $197f
01012604  7a49              moveq    #$49, d5
01012606  885a              or.w     (a2)+, d4
01012608  344e              movea.w  a6, a2
0101260a  1f680a1f541d      move.b   $a1f(a0), $541d(a7)
01012610  4d85              chk.w    d5, d6
01012612  7279              moveq    #$79, d1
01012614  00527f5a          ori.w    #$7f5a, (a2)
01012618  5088              addq.l   #$8, a0
0101261a  354e1f68          move.w   a6, $1f68(a2)
0101261e  0a1f541d          eori.b   #$1d, (a7)+
01012622  4b85              chk.w    d5, d5
01012624  7769              dc.w     $7769
01012626  1a6a              dc.w     $1a6a
01012628  7a49              moveq    #$49, d5
0101262a  887e              dc.w     $887e
0101262c  354e1f68          move.w   a6, $1f68(a2)
01012630  0a1f541d          eori.b   #$1d, (a7)+
01012634  4a85              tst.l    d5
01012636  7a52              moveq    #$52, d5
01012638  7a7f              moveq    #$7f, d5
0101263a  5a50              addq.w   #$5, (a0)
0101263c  887d              dc.w     $887d
0101263e  354e1f68          move.w   a6, $1f68(a2)
01012642  0a1f541d          eori.b   #$1d, (a7)+
01012646  4985              chk.w    d5, d4
01012648  7d50              dc.w     $7d50
0101264a  7f7a              dc.w     $7f7a
0101264c  4989              dc.w     $4989
0101264e  7a35              moveq    #$35, d5
01012650  4e1f              dc.w     $4e1f
01012652  680a              bvc.b    $101265e
01012654  1f541e85          move.b   (a4), $1e85(a7)
01012658  7e4d              moveq    #$4d, d7
0101265a  7f5a              dc.w     $7f5a
0101265c  5089              addq.l   #$8, a1
0101265e  7735              dc.w     $7735
01012660  4e1f              dc.w     $4e1f
01012662  680a              bvc.b    $101266e
01012664  1f541e6a          move.b   (a4), $1e6a(a7)
01012668  854b7a49          pack     -(a3), -(a2), #$7a49
0101266c  8a72354e          or.w     ([a2]), d5
01012670  1f680a1f541e      move.b   $a1f(a0), $541e(a7)
01012676  5285              addq.l   #$1, d5
01012678  5b5a              subq.w   #$5, (a2)+
0101267a  508a              addq.l   #$8, a2
0101267c  6e35              bgt.b    $10126b3
0101267e  4e1f              dc.w     $4e1f
01012680  680a              bvc.b    $101268c
01012682  1f541e50          move.b   (a4), $1e50(a7)
01012686  856e498b          or.w     d2, $498b(a6)
0101268a  5a354e1f          addq.b   #$5, $1f(a5, d4.l)
0101268e  680a              bvc.b    $101269a
01012690  1f541e4d          move.b   (a4), $1e4d(a7)
01012694  8572508b          or.w     d2, -$75(a2, d5.w)
01012698  364e              movea.w  a6, a3
0101269a  1f680a1f541e      move.b   $a1f(a0), $541e(a7)
010126a0  4b85              chk.w    d5, d5
010126a2  6f8b              ble.b    $101262f
010126a4  7e36              moveq    #$36, d7
010126a6  4e1f              dc.w     $4e1f
010126a8  680a              bvc.b    $10126b4
010126aa  1f541e4a          move.b   (a4), $1e4a(a7)
010126ae  855c              or.w     d2, (a4)+
010126b0  8b7d              dc.w     $8b7d
010126b2  364e              movea.w  a6, a3
010126b4  1f680a1f541e      move.b   $a1f(a0), $541e(a7)
010126ba  4985              chk.w    d5, d4
010126bc  4b8b              dc.w     $4b8b
010126be  7236              moveq    #$36, d1
010126c0  4e1f              dc.w     $4e1f
010126c2  680a              bvc.b    $10126ce
010126c4  1f541f84          move.b   (a4), $1f84(a7)
010126c8  7e4d              moveq    #$4d, d7
010126ca  8a7e              dc.w     $8a7e
010126cc  374e1f68          move.w   a6, $1f68(a3)
010126d0  0a1f541f          eori.b   #$1f, (a7)+
010126d4  6a83              bpl.b    $1012659
010126d6  7e50              moveq    #$50, d7
010126d8  8a72374e          or.w     ([a2]), d5
010126dc  1f680a1f541f      move.b   $a1f(a0), $541f(a7)
010126e2  5283              addq.l   #$1, d3
010126e4  7d50              dc.w     $7d50
010126e6  897e              dc.w     $897e
010126e8  384e              movea.w  a6, a4
010126ea  1f680a1f541f      move.b   $a1f(a0), $541f(a7)
010126f0  5083              addq.l   #$8, d3
010126f2  7a52              moveq    #$52, d5
010126f4  8972384e          or.w     d4, $4e(a2, d3.l)
010126f8  1f680a1f541f      move.b   $a1f(a0), $541f(a7)
010126fe  4d83              chk.w    d3, d6
01012700  7a6a              moveq    #$6a, d5
01012702  887e              dc.w     $887e
01012704  394e1f68          move.w   a6, $1f68(a4)
01012708  0a1f541f          eori.b   #$1f, (a7)+
0101270c  4b83              chk.w    d3, d5
0101270e  726a              moveq    #$6a, d1
01012710  8872394e          or.w     ([a2]), d4
01012714  1f680a1f541f      move.b   $a1f(a0), $541f(a7)
0101271a  4a83              tst.l    d3
0101271c  7388              dc.w     $7388
0101271e  7e3a              moveq    #$3a, d7
01012720  4e1f              dc.w     $4e1f
01012722  680a              bvc.b    $101272e
01012724  1f541f49          move.b   (a4), $1f49(a7)
01012728  836f8872          or.w     d1, -$778e(a7)
0101272c  3a4e              movea.w  a6, a5
0101272e  1f680a1f5420      move.b   $a1f(a0), $5420(a7)
01012734  835c              or.w     d1, (a4)+
01012736  877e              dc.w     $877e
01012738  3b4e1f68          move.w   a6, $1f68(a5)
0101273c  0a1f5420          eori.b   #$20, (a7)+
01012740  6a82              bpl.b    $10126c4
01012742  4b87              chk.w    d7, d5
01012744  723b              moveq    #$3b, d1
01012746  4e1f              dc.w     $4e1f
01012748  680a              bvc.b    $1012754
0101274a  1f542052          move.b   (a4), $2052(a7)
0101274e  817e              dc.w     $817e
01012750  4d86              chk.w    d6, d6
01012752  7e3c              moveq    #$3c, d7
01012754  4e1f              dc.w     $4e1f
01012756  680a              bvc.b    $1012762
01012758  1f542050          move.b   (a4), $2050(a7)
0101275c  817e              dc.w     $817e
0101275e  5086              addq.l   #$8, d6
01012760  723c              moveq    #$3c, d1
01012762  4e1f              dc.w     $4e1f
01012764  680a              bvc.b    $1012770
01012766  1f54204d          move.b   (a4), $204d(a7)
0101276a  817d              dc.w     $817d
0101276c  5085              addq.l   #$8, d5
0101276e  7e3d              moveq    #$3d, d7
01012770  4e1f              dc.w     $4e1f
01012772  680a              bvc.b    $101277e
01012774  1f54204b          move.b   (a4), $204b(a7)
01012778  817a              dc.w     $817a
0101277a  5285              addq.l   #$1, d5
0101277c  723d              moveq    #$3d, d1
0101277e  4e1f              dc.w     $4e1f
01012780  680a              bvc.b    $101278c
01012782  1f54204a          move.b   (a4), $204a(a7)
01012786  81776a84          or.w     d0, -$7c(a7, d6.l)
0101278a  7e3e              moveq    #$3e, d7
0101278c  4e1f              dc.w     $4e1f
0101278e  680a              bvc.b    $101279a
01012790  1f542049          move.b   (a4), $2049(a7)
01012794  81726a84          or.w     d0, -$7c(a2, d6.l)
01012798  723e              moveq    #$3e, d1
0101279a  4e1f              dc.w     $4e1f
0101279c  680a              bvc.b    $10127a8
0101279e  1f542181          move.b   (a4), $2181(a7)
010127a2  6f84              ble.b    $1012728
010127a4  7e3f              moveq    #$3f, d7
010127a6  4e1f              dc.w     $4e1f
010127a8  680a              bvc.b    $10127b4
010127aa  1f54216a          move.b   (a4), $216a(a7)
010127ae  805b              or.w     (a3)+, d0
010127b0  84723f4e          or.w     ([a2]), d2
010127b4  1f680a1f5421      move.b   $a1f(a0), $5421(a7)
010127ba  5280              addq.l   #$1, d0
010127bc  5d83              subq.l   #$6, d3
010127be  7e40              moveq    #$40, d7
010127c0  4e1f              dc.w     $4e1f
010127c2  680a              bvc.b    $10127ce
010127c4  1f542150          move.b   (a4), $2150(a7)
010127c8  804b              dc.w     $804b
010127ca  8372404e          or.w     d1, $4e(a2, d4.w)
010127ce  1f680a1f5421      move.b   $a1f(a0), $5421(a7)
010127d4  4d7f              dc.w     $4d7f
010127d6  7e4d              moveq    #$4d, d7
010127d8  827e              dc.w     $827e
010127da  414e              dc.w     $414e
010127dc  1f680a1f5421      move.b   $a1f(a0), $5421(a7)
010127e2  4b7f              dc.w     $4b7f
010127e4  7d50              dc.w     $7d50
010127e6  8272414e          or.w     ([a2]), d1
010127ea  1f680a1f5421      move.b   $a1f(a0), $5421(a7)
010127f0  4a7f              dc.w     $4a7f
010127f2  7a52              moveq    #$52, d5
010127f4  817e              dc.w     $817e
010127f6  424e              dc.w     $424e
010127f8  1f680a1f5421      move.b   $a1f(a0), $5421(a7)
010127fe  497f              dc.w     $497f
01012800  776a              dc.w     $776a
01012802  8172424e          or.w     d0, $4e(a2, d4.w)
01012806  1f680a1f5422      move.b   $a1f(a0), $5422(a7)
0101280c  7f72              dc.w     $7f72
0101280e  6a80              bpl.b    $1012790
01012810  7e43              moveq    #$43, d7
01012812  4e1f              dc.w     $4e1f
01012814  680a              bvc.b    $1012820
01012816  1f54226a          move.b   (a4), $226a(a7)
0101281a  7381              dc.w     $7381
0101281c  7243              moveq    #$43, d1
0101281e  4e1f              dc.w     $4e1f
01012820  680a              bvc.b    $101282c
01012822  1f542252          move.b   (a4), $2252(a7)
01012826  6f80              ble.b    $10127a8
01012828  7e44              moveq    #$44, d7
0101282a  4e1f              dc.w     $4e1f
0101282c  680a              bvc.b    $1012838
0101282e  1f576362          move.b   (a7), $6362(a7)
01012832  505c              addq.w   #$8, (a4)+
01012834  8072665f          or.w     $5f(a2, d6.w), d0
01012838  1f680a1f1a05      move.b   $a1f(a0), $1a05(a7)
0101283e  175d7f7e          move.b   (a5)+, $7f7e(a3)
01012842  1c08              dc.w     $1c08
01012844  0a1f680a          eori.b   #$a, (a7)+
01012848  264c              movea.l  a4, a3
0101284a  7f72              dc.w     $7f72
0101284c  4568              dc.w     $4568
0101284e  0a26494d          eori.b   #$4d, -(a6)
01012852  7e46              moveq    #$46, d7
01012854  680a              bvc.b    $1012860
01012856  2649              movea.l  a1, a3
01012858  50724668          addq.w   #$8, $68(a2, d4.w)
0101285c  0a275147          eori.b   #$47, -(a7)
01012860  680a              bvc.b    $101286c
01012862  275a4768          move.l   (a2)+, $4768(a3)
01012866  0a48              dc.w     $0a48
01012868  680a              bvc.b    $1012874
0101286a  48680a48          pea.l    $a48(a0)
0101286e  680a              bvc.b    $101287a
01012870  48680a48          pea.l    $a48(a0)
01012874  680a              bvc.b    $1012880
01012876  48680a48          pea.l    $a48(a0)
0101287a  680a              bvc.b    $1012886
0101287c  48680a48          pea.l    $a48(a0)
01012880  680b              bvc.b    $101288d
01012882  6768              beq.b    $10128ec
01012884  1267              dc.w     $1267
01012886  6819              bvc.b    $10128a1
01012888  8c8d              dc.w     $8c8d
0101288a  0000              dc.w     $0000

; ---- gap 010128a6..0101297b (214 bytes) ----
010128a6  0e01              dc.w     $0e01
010128a8  0102              btst.l   d0, d2
010128aa  0104              btst.l   d0, d4
010128ac  0104              btst.l   d0, d4
010128ae  02050106          andi.b   #$6, d5
010128b2  010a0110          movep.w  $110(a2), d0
010128b6  0111              btst.l   d0, (a1)
010128b8  0111              btst.l   d0, (a1)
010128ba  02110311          andi.b   #$11, (a1)
010128be  04140115          subi.b   #$15, (a4)
010128c2  011b              btst.l   d0, (a3)+
010128c4  012a012e          btst.l   d0, $12e(a2)
010128c8  013a0140          btst.l   d0, $1012a0a(pc)
010128cc  0140              bchg.b   d0, d0
010128ce  02410144          andi.w   #$144, d1
010128d2  0144              bchg.b   d0, d4
010128d4  02440345          andi.w   #$345, d4
010128d8  0150              bchg.b   d0, (a0)
010128da  0151              bchg.b   d0, (a1)
010128dc  0151              bchg.b   d0, (a1)
010128de  02520153          andi.w   #$153, (a2)
010128e2  0154              bchg.b   d0, (a4)
010128e4  0155              bchg.b   d0, (a5)
010128e6  0155              bchg.b   d0, (a5)
010128e8  02550355          andi.w   #$355, (a5)
010128ec  04550555          subi.w   #$555, (a5)
010128f0  06550755          addi.w   #$755, (a5)
010128f4  0855              dc.w     $0855
010128f6  0a550c55          eori.w   #$c55, (a5)
010128fa  0e56              dc.w     $0e56
010128fc  0157              bchg.b   d0, (a7)
010128fe  0159              bchg.b   d0, (a1)+
01012900  015a              bchg.b   d0, (a2)+
01012902  015b              bchg.b   d0, (a3)+
01012904  015e              bchg.b   d0, (a6)+
01012906  015f              bchg.b   d0, (a7)+
01012908  0164              bchg.b   d0, -(a4)
0101290a  0165              bchg.b   d0, -(a5)
0101290c  0166              bchg.b   d0, -(a6)
0101290e  0166              bchg.b   d0, -(a6)
01012910  0266036a          andi.w   #$36a, -(a6)
01012914  016b016e          bchg.b   d0, $16e(a3)
01012918  0195              bclr.b   d0, (a5)
0101291a  0196              bclr.b   d0, (a6)
0101291c  0198              bclr.b   d0, (a0)+
0101291e  0199              bclr.b   d0, (a1)+
01012920  0199              bclr.b   d0, (a1)+
01012922  039a              bclr.b   d1, (a2)+
01012924  01a0              bclr.b   d0, -(a0)
01012926  01a1              bclr.b   d0, -(a1)
01012928  01a5              bclr.b   d0, -(a5)
0101292a  01a6              bclr.b   d0, -(a6)
0101292c  01a801a9          bclr.b   d0, $1a9(a0)
01012930  01aa01aa          bclr.b   d0, $1aa(a2)
01012934  02aa03aa04aa06aa  andi.l   #$3aa04aa, $6aa(a2)
0101293c  07aa11aa          bclr.b   d3, $11aa(a2)
01012940  12ab01ac          move.b   $1ac(a3), (a1)
01012944  01ae01af          bclr.b   d0, $1af(a6)
01012948  01af02b5          bclr.b   d0, $2b5(a7)
0101294c  01b801b9          bclr.b   d0, $1b9.w
01012950  01ba              dc.w     $01ba
01012952  01ba              dc.w     $01ba
01012954  02bb              dc.w     $02bb
01012956  01bb              dc.w     $01bb
01012958  02bb              dc.w     $02bb
0101295a  03bc              dc.w     $03bc
0101295c  01bd              dc.w     $01bd
0101295e  01be              dc.w     $01be
01012960  01bf              dc.w     $01bf
01012962  01c0              bset.b   d0, d0
01012964  01c1              bset.b   d0, d1
01012966  01c2              bset.b   d0, d2
01012968  01c4              bset.b   d0, d4
0101296a  01d0              bset.b   d0, (a0)
0101296c  01d1              bset.b   d0, (a1)
0101296e  01d4              bset.b   d0, (a4)
01012970  01d5              bset.b   d0, (a5)
01012972  01d9              bset.b   d0, (a1)+
01012974  01e5              bset.b   d0, -(a5)
01012976  01e6              bset.b   d0, -(a6)
01012978  01e801e9          bset.b   d0, $1e9(a0)

; ---- gap 01012994..01012a8a (247 bytes) ----
01012994  01fb              dc.w     $01fb
01012996  01fc              dc.w     $01fc
01012998  01fe              dc.w     $01fe
0101299a  01ff              dc.w     $01ff
0101299c  01ff              dc.w     $01ff
0101299e  02ff              dc.w     $02ff
010129a0  03ff              dc.w     $03ff
010129a2  04ff              dc.w     $04ff
010129a4  05ff              dc.w     $05ff
010129a6  08ff              dc.w     $08ff
010129a8  11ff              dc.w     $11ff
010129aa  1229052c          move.b   $52c(a1), d1
010129ae  2619              move.l   (a1)+, d3
010129b0  0114              btst.l   d0, (a4)
010129b2  2d650307          move.l   -(a5), $307(a6)
010129b6  2626              move.l   -(a6), d3
010129b8  164d              dc.w     $164d
010129ba  142d724f          move.b   $724f(a5), d2
010129be  5e26              addq.b   #$7, -(a6)
010129c0  2617              move.l   (a7), d3
010129c2  4d14              chk.l    (a4), d6
010129c4  2d724f5e2626      move.l   ([a2]), $2626(a6)
010129ca  174d              dc.w     $174d
010129cc  6c2d              bge.b    $10129fb
010129ce  724f              moveq    #$4f, d1
010129d0  5e26              addq.b   #$7, -(a6)
010129d2  2617              move.l   (a7), d3
010129d4  574c              subq.w   #$3, a4
010129d6  6481              bcc.b    $1012959
010129d8  7a2b              moveq    #$2b, d5
010129da  724e              moveq    #$4e, d1
010129dc  7b5e              dc.w     $7b5e
010129de  2625              move.l   -(a5), d3
010129e0  5664              addq.w   #$3, -(a4)
010129e2  164d              dc.w     $164d
010129e4  622a              bhi.b    $1012a10
010129e6  1f724d54795c      move.b   (a2, invalid.w), $795c(a7)
010129ec  6c25              bge.b    $1012a13
010129ee  5661              addq.w   #$3, -(a1)
010129f0  164d              dc.w     $164d
010129f2  47291f26          chk.l    $1f26(a1), d3
010129f6  724d              moveq    #$4d, d1
010129f8  5467              addq.w   #$2, -(a7)
010129fa  5c6c2556          addq.w   #$6, $2556(a4)
010129fe  464e              dc.w     $464e
01012a00  472a1472          chk.l    $1472(a2), d3
01012a04  4d4b              dc.w     $4d4b
01012a06  0d5c              bchg.b   d6, (a4)+
01012a08  6c25              bge.b    $1012a2f
01012a0a  564f              addq.w   #$3, a7
01012a0c  4728211f          chk.l    $211f(a0), d3
01012a10  21724f5c6c25      move.l   (a2, invalid.w), $6c25(a0)
01012a16  564f              addq.w   #$3, a7
01012a18  4a27              tst.b    -(a7)
01012a1a  2126              move.l   -(a6), -(a0)
01012a1c  251f              move.l   (a7)+, -(a2)
01012a1e  724f              moveq    #$4f, d1
01012a20  5c6c2556          addq.w   #$6, $2556(a4)
01012a24  4f4a              dc.w     $4f4a
01012a26  281f              move.l   (a7)+, d4
01012a28  1072              dc.w     $1072
01012a2a  4f5c              dc.w     $4f5c
01012a2c  6c25              bge.b    $1012a53
01012a2e  564f              addq.w   #$3, a7
01012a30  4a26              tst.b    -(a6)
01012a32  2225              move.l   -(a5), d1
01012a34  1c07              move.b   d7, d6
01012a36  724f              moveq    #$4f, d1
01012a38  5c6c2356          addq.w   #$6, $2356(a4)
01012a3c  4f4a              dc.w     $4f4a
01012a3e  1f26              move.b   -(a6), -(a7)
01012a40  1410              move.b   (a0), d2
01012a42  0b724f5c          bchg.b   d5, (a2, invalid.w)
01012a46  5923              subq.b   #$4, -(a3)
01012a48  564f              addq.w   #$3, a7
01012a4a  4a26              tst.b    -(a6)
01012a4c  0f25              btst.l   d7, -(a5)
01012a4e  1c00              move.b   d0, d6
01012a50  07724f5c          bchg.b   d3, (a2, invalid.w)
01012a54  5923              subq.b   #$4, -(a3)
01012a56  564f              addq.w   #$3, a7
01012a58  4a25              tst.b    -(a5)
01012a5a  260f              move.l   a7, d3
01012a5c  0009              dc.w     $0009
01012a5e  1b724f5c5923      move.b   (a2, invalid.w), $5923(a5)
01012a64  564f              addq.w   #$3, a7
01012a66  6126              bsr.b    $1012a8e
01012a68  1d1b              move.b   (a3)+, -(a6)
01012a6a  0007804f          ori.b    #$4f, d7
01012a6e  5c59              addq.w   #$6, (a1)+
01012a70  23564e54          move.l   (a6), $4e54(a1)
01012a74  701c              moveq    #$1c, d0
01012a76  0f0e0009          movep.w  $9(a6), d7
01012a7a  0773724e          bchg.b   d3, $4e(a3, d7.w)
01012a7e  5c59              addq.w   #$6, (a1)+
01012a80  2480              move.l   d0, (a2)
01012a82  4e63              move     a3, usp
01012a84  4a26              tst.b    -(a6)
01012a86  1c1b              move.b   (a3)+, d6
01012a88  0e00              dc.w     $0e00
01012a8a  0772              dc.w     $0772

; ---- gap 01012a97..01012c08 (370 bytes) ----
01012a97  0e01              dc.w     $0e01
01012a99  07715472          bchg.b   d3, $72(a1, d5.w)
01012a9d  4d64              dc.w     $4d64
01012a9f  7a24              moveq    #$24, d5
01012aa1  4e56724a          link.w   a6, #$724a
01012aa5  1d1b              move.b   (a3)+, -(a6)
01012aa7  0107              btst.l   d0, d7
01012aa9  7243              moveq    #$43, d1
01012aab  5c4e              addq.w   #$6, a6
01012aad  7a24              moveq    #$24, d5
01012aaf  4e5e              unlk     a6
01012ab1  5c7021030f72393f  addq.w   #$6, ([a0, d2.w], $f72393f)
01012ab9  4e7a244e          movec    invalid, d2
01012abd  764a              moveq    #$4a, d3
01012abf  191b              move.b   (a3)+, -(a4)
01012ac1  010e0771          movep.w  $771(a6), d0
01012ac5  41354e7a          chk.l    $7a(a5, d4.l), d0
01012ac9  244d              movea.l  a5, a2
01012acb  545f              addq.w   #$2, (a7)+
01012acd  4a21              tst.b    -(a1)
01012acf  031b              btst.l   d1, (a3)+
01012ad1  7239              moveq    #$39, d1
01012ad3  31724d7a244d5680755a1902  move.w   ([$244d5680, a2], $755a), $1902(a0)
01012adf  190b              dc.w     $190b
01012ae1  7140              dc.w     $7140
01012ae3  265c              movea.l  (a4)+, a3
01012ae5  4d7a              dc.w     $4d7a
01012ae7  244d              movea.l  a5, a2
01012ae9  5e81              addq.l   #$7, d1
01012aeb  7e4a              moveq    #$4a, d7
01012aed  2019              move.l   (a1)+, d0
01012aef  0019070f          ori.b    #$f, (a1)+
01012af3  6f33              ble.b    $1012b28
01012af5  1c3f              dc.w     $1c3f
01012af7  4d7a              dc.w     $4d7a
01012af9  244d              movea.l  a5, a2
01012afb  7880              moveq    #$80, d4
01012afd  7574              dc.w     $7574
01012aff  1901              move.b   d1, -(a4)
01012b01  07091f71          movep.w  $1f71(a1), d3
01012b05  400f              dc.w     $400f
01012b07  154d              dc.w     $154d
01012b09  7a24              moveq    #$24, d5
01012b0b  4c54              dc.w     $4c54
01012b0d  6481              bcc.b    $1012a90
01012b0f  7e5a              moveq    #$5a, d7
01012b11  1900              move.b   d0, -(a4)
01012b13  1a0f              dc.w     $1a0f
01012b15  266f261c          movea.l  $261c(a7), a3
01012b19  0872              dc.w     $0872
01012b1b  4c7a              dc.w     $4c7a
01012b1d  244c              movea.l  a4, a2
01012b1f  5464              addq.w   #$2, -(a4)
01012b21  82741900          or.w     (a4, d1.l), d1
01012b25  0a1c216d          eori.b   #$6d, (a4)+
01012b29  260e              move.l   a6, d3
01012b2b  19724c7a244c      move.b   $7a(a2, d4.l), $244c(a4)
01012b31  5678817e          addq.w   #$3, $817e.w
01012b35  5a19              addq.b   #$5, (a1)+
01012b37  0919              btst.l   d4, (a1)+
01012b39  0f14              btst.l   d7, (a4)
01012b3b  266e251c          movea.l  $251c(a6), a3
01012b3f  005c4c7a          ori.w    #$4c7a, (a4)+
01012b43  244c              movea.l  a4, a2
01012b45  575e              subq.w   #$3, (a6)+
01012b47  6481              bcc.b    $1012aca
01012b49  741b              moveq    #$1b, d2
01012b4b  0009              dc.w     $0009
01012b4d  1f26              move.b   -(a6), -(a7)
01012b4f  146c              dc.w     $146c
01012b51  0f01              btst.l   d7, d1
01012b53  184c              dc.w     $184c
01012b55  7a24              moveq    #$24, d5
01012b57  4c5c              dc.w     $4c5c
01012b59  7578              dc.w     $7578
01012b5b  817c              dc.w     $817c
01012b5d  1911              move.b   (a1), -(a4)
01012b5f  1f26              move.b   -(a6), -(a7)
01012b61  6b1c              bmi.b    $1012b7f
01012b63  0e00              dc.w     $0e00
01012b65  3f4c7a24          move.w   a4, $7a24(a7)
01012b69  4c5e              dc.w     $4c5e
01012b6b  545e              addq.w   #$2, (a6)+
01012b6d  647f              bcc.b    $1012bee
01012b6f  2109              move.l   a1, -(a0)
01012b71  1c286a0e          move.b   $6a0e(a0), d6
01012b75  000f              dc.w     $000f
01012b77  174c              dc.w     $174c
01012b79  7a24              moveq    #$24, d5
01012b7b  4c72              dc.w     $4c72
01012b7d  5c56              addq.w   #$6, (a6)
01012b7f  787f              moveq    #$7f, d4
01012b81  1910              move.b   (a0), -(a4)
01012b83  1c27              move.b   -(a7), d6
01012b85  6819              bvc.b    $1012ba0
01012b87  001c354c          ori.b    #$4c, (a4)+
01012b8b  7a24              moveq    #$24, d5
01012b8d  4c72              dc.w     $4c72
01012b8f  4d5e              dc.w     $4d5e
01012b91  611c              bsr.b    $1012baf
01012b93  1f25              move.b   -(a5), -(a7)
01012b95  28690007          movea.l  $7(a1), a4
01012b99  14354c7a          move.b   $7a(a5, d4.l), d2
01012b9d  2454              movea.l  (a4), a2
01012b9f  434d              dc.w     $434d
01012ba1  56742110          addq.w   #$3, (a4, d2.w)
01012ba5  1f27              move.b   -(a7), -(a7)
01012ba7  68001c21          bvc.w    $10147ca
01012bab  31727a245449      move.w   $24(a2, d7.l), $5449(a0)
01012bb1  3b4c5a1c          move.w   a4, $5a1c(a5)
01012bb5  1f29690f          move.b   $690f(a1), -(a7)
01012bb9  1426              move.b   -(a6), d2
01012bbb  4172              dc.w     $4172
01012bbd  7a24              moveq    #$24, d5
01012bbf  5444              addq.w   #$2, d4
01012bc1  454a              dc.w     $454a
01012bc3  2621              move.l   -(a1), d3
01012bc5  1f28651f          move.b   $651f(a0), -(a7)
01012bc9  263b727a          move.l   $1012c45(pc, d7.w), d3
01012bcd  2454              movea.l  (a4), a2
01012bcf  4026              negx.b   -(a6)
01012bd1  3b381c1f          move.w   $1c1f.w, -(a5)
01012bd5  29661433          move.l   -(a6), $1433(a4)
01012bd9  434c              dc.w     $434c
01012bdb  727a              moveq    #$7a, d1
01012bdd  2454              movea.l  (a4), a2
01012bdf  4027              negx.b   -(a7)
01012be1  33422b68          move.w   d2, $2b68(a1)
01012be5  313a3d4c          move.w   $1016933(pc), -(a0)
01012be9  727a              moveq    #$7a, d1
01012beb  2456              movea.l  (a6), a2
01012bed  0f28251f          btst.l   d7, $251f(a0)
01012bf1  14296c33          move.b   $6c33(a1), d2
01012bf5  454d              dc.w     $454d
01012bf7  5c7a              dc.w     $5c7a
01012bf9  2456              movea.l  (a6), a2
01012bfb  1e26              move.b   -(a6), d7
01012bfd  252b6f3a          move.l   $6f3a(a3), -(a2)
01012c01  4d72              dc.w     $4d72
01012c03  5c7a              dc.w     $5c7a
01012c05  2456              movea.l  (a6), a2
01012c07  1213              move.b   (a3), d1

; ---- gap 01012c13..01012d97 (389 bytes) ----
01012c13  0900              btst.l   d4, d0
01012c15  1900              move.b   d0, -(a4)
01012c17  2b724c5e545d      move.l   $5e(a2, d4.l), $545d(a5)
01012c1d  7a24              moveq    #$24, d5
01012c1f  5604              addq.b   #$3, d4
01012c21  2b7277785c7a24560207  move.l   $5c7a2456(a2, invalid.w), $207(a5)
01012c2b  0e2b              dc.w     $0e2b
01012c2d  7e60              moveq    #$60, d7
01012c2f  645c              bcc.b    $1012c8d
01012c31  7a24              moveq    #$24, d5
01012c33  5600              addq.b   #$3, d0
01012c35  091e              btst.l   d4, (a6)+
01012c37  2b75837e5c7a24560710  move.l   ([$5c7a2456, a5]), $710(a5)
01012c41  1425              move.b   -(a5), d2
01012c43  2b855c7a          move.l   d5, $7a(a5, d5.l)
01012c47  2456              movea.l  (a6), a2
01012c49  1c1f              move.b   (a7)+, d6
01012c4b  2725              move.l   -(a5), -(a3)
01012c4d  2b80845c          move.l   d0, $5c(a5, a0.w)
01012c51  7a24              moveq    #$24, d5
01012c53  560f              dc.w     $560f
01012c55  2733422b          move.l   $2b(a3, d4.w), -(a3)
01012c59  735e              dc.w     $735e
01012c5b  647e              bcc.b    $1012cdb
01012c5d  815c              or.w     d0, (a4)+
01012c5f  7a24              moveq    #$24, d5
01012c61  56283a38          addq.b   #$3, $3a38(a0)
01012c65  2b7256775c7a      move.l   $77(a2, d5.w), $5c7a(a5)
01012c6b  2456              movea.l  (a6), a2
01012c6d  2644              movea.l  d4, a3
01012c6f  422b724c          clr.b    $724c(a3)
01012c73  545f              addq.w   #$2, (a7)+
01012c75  7d7a              dc.w     $7d7a
01012c77  2454              movea.l  (a4), a2
01012c79  3c3d              dc.w     $3c3d
01012c7b  4a2b6f3d          tst.b    $6f3d(a3)
01012c7f  4d75              dc.w     $4d75
01012c81  727a              moveq    #$7a, d1
01012c83  2454              movea.l  (a4), a2
01012c85  33434549          move.w   d3, $4549(a1)
01012c89  422b6d43          clr.b    $6d43(a3)
01012c8d  4e727a24          stop     #$7a24
01012c91  543b              dc.w     $543b
01012c93  4b4c              dc.w     $4b4c
01012c95  4a2b6c3c          tst.b    $6c3c(a3)
01012c99  4c72              dc.w     $4c72
01012c9b  7a24              moveq    #$24, d5
01012c9d  5426              addq.b   #$2, -(a6)
01012c9f  4e4a              trap     #$a
01012ca1  506c2633          addq.w   #$8, $2633(a4)
01012ca5  434c              dc.w     $434c
01012ca7  727a              moveq    #$7a, d1
01012ca9  2454              movea.l  (a4), a2
01012cab  4a06              tst.b    d6
01012cad  0c727a244c6e      cmpi.w   #$7a24, $6e(a2, d4.l)
01012cb3  30354c7a          move.w   $7a(a5, d4.l), d0
01012cb7  244c              movea.l  a4, a2
01012cb9  6e30              bgt.b    $1012ceb
01012cbb  354c7a24          move.w   a4, $7a24(a2)
01012cbf  4c5b              dc.w     $4c5b
01012cc1  303f              dc.w     $303f
01012cc3  4c7a              dc.w     $4c7a
01012cc5  244c              movea.l  a4, a2
01012cc7  5b288628          subq.b   #$5, -$79d8(a0)
01012ccb  3f4c7a24          move.w   a4, $7a24(a7)
01012ccf  4c56              dc.w     $4c56
01012cd1  305c              movea.w  (a4)+, a0
01012cd3  4c7a              dc.w     $4c7a
01012cd5  244c              movea.l  a4, a2
01012cd7  56305c4c          addq.b   #$3, $4c(a0, d5.l)
01012cdb  7a24              moveq    #$24, d5
01012cdd  4c54              dc.w     $4c54
01012cdf  4027              negx.b   -(a7)
01012ce1  8627              or.b     -(a7), d3
01012ce3  31724c7a244c      move.w   $7a(a2, d4.l), $244c(a0)
01012ce9  5440              addq.w   #$2, d0
01012ceb  2f31724c          move.l   $4c(a1, d7.w), -(a7)
01012cef  7a24              moveq    #$24, d5
01012cf1  4d6e              dc.w     $4d6e
01012cf3  2f354d7a24574c5b2786  move.l   ([$24574c5b, a5], $2786), -(a7)
01012cfd  273f              dc.w     $273f
01012cff  4c7d              dc.w     $4c7d
01012d01  7a24              moveq    #$24, d5
01012d03  6416              bcc.b    $1012d1b
01012d05  5c2f5654          addq.b   #$6, $5654(a7)
01012d09  7d7a              dc.w     $7d7a
01012d0b  2461              movea.l  -(a1), a2
01012d0d  1656              dc.w     $1656
01012d0f  402e315c          negx.b   $315c(a6)
01012d13  5467              addq.w   #$2, -(a7)
01012d15  7a24              moveq    #$24, d5
01012d17  464c              dc.w     $464c
01012d19  5448              addq.w   #$2, a0
01012d1b  2686              move.l   d6, (a3)
01012d1d  2634724c          move.l   $4c(a4, d7.w), d3
01012d21  0d7a              dc.w     $0d7a
01012d23  244e              movea.l  a6, a2
01012d25  712e              dc.w     $712e
01012d27  3e4e              movea.w  a6, a7
01012d29  7a24              moveq    #$24, d5
01012d2b  4e5c              unlk     a4
01012d2d  2e56              movea.l  (a6), a7
01012d2f  4e7a244e          movec    invalid, d2
01012d33  5640              addq.w   #$3, d0
01012d35  2d317d4e          move.l   ([a1]), -(a6)
01012d39  7a24              moveq    #$24, d5
01012d3b  4e54712d          link.w   a4, #$712d
01012d3f  3e4f              movea.w  a7, a7
01012d41  7a24              moveq    #$24, d5
01012d43  804e              dc.w     $804e
01012d45  6340              bls.b    $1012d87
01012d47  2b31634e          move.l   ([a1]), -(a5)
01012d4b  577a              dc.w     $577a
01012d4d  2636634d          move.l   ([a6]), d3
01012d51  54712b3e724d58262623  addq.w   #$2, ([$724d5826, a1], d2.l * 2, $2623)
01012d5b  734e              dc.w     $734e
01012d5d  6340              bls.b    $1012d9f
01012d5f  2931634e          move.l   ([a1]), -(a4)
01012d63  5c782626          addq.w   #$6, $2626.w
01012d67  23734e547229      move.l   $54(a3, d4.l), $7229(a1)
01012d6d  54724e5c          addq.w   #$2, $5c(a2, d4.l)
01012d71  7826              moveq    #$26, d4
01012d73  2508              move.l   a0, -(a2)
01012d75  634f              bls.b    $1012dc6
01012d77  647d              bcc.b    $1012df6
01012d79  4d57              dc.w     $4d57
01012d7b  804f              dc.w     $804f
01012d7d  5755              subq.w   #$3, (a5)
01012d7f  0b325157          btst.l   d5, ([a2])
01012d83  827d              dc.w     $827d
01012d85  517a              dc.w     $517a
01012d87  3253              movea.w  (a3), a1
01012d89  7a32              moveq    #$32, d5
01012d8b  7252              moveq    #$52, d1
01012d8d  7a26              moveq    #$26, d5
01012d8f  887a2637          or.w     $10153c8(pc), d4
01012d93  876c0000          or.w     d3, $0(a4)
01012d97  0053              dc.w     $0053

; ---- gap 01012d9e..0101306b (718 bytes) ----
01012d9e  0048              dc.w     $0048
01012da0  00000029          ori.b    #$29, d0
01012da4  5f00              subq.b   #$7, d0
01012da6  0100              btst.l   d0, d0
01012da8  02000300          andi.b   #$0, d0
01012dac  04010104          subi.b   #$4, d1
01012db0  0104              btst.l   d0, d4
01012db2  02050110          andi.b   #$10, d5
01012db6  0111              btst.l   d0, (a1)
01012db8  0111              btst.l   d0, (a1)
01012dba  02110314          andi.b   #$14, (a1)
01012dbe  0115              btst.l   d0, (a5)
01012dc0  0140              bchg.b   d0, d0
01012dc2  0140              bchg.b   d0, d0
01012dc4  02410144          andi.w   #$144, d1
01012dc8  0144              bchg.b   d0, d4
01012dca  02440445          andi.w   #$445, d4
01012dce  0150              bchg.b   d0, (a0)
01012dd0  0151              bchg.b   d0, (a1)
01012dd2  0152              bchg.b   d0, (a2)
01012dd4  0153              bchg.b   d0, (a3)
01012dd6  0154              bchg.b   d0, (a4)
01012dd8  0155              bchg.b   d0, (a5)
01012dda  0155              bchg.b   d0, (a5)
01012ddc  02550355          andi.w   #$355, (a5)
01012de0  04550656          subi.w   #$656, (a5)
01012de4  0158              bchg.b   d0, (a0)+
01012de6  0159              bchg.b   d0, (a1)+
01012de8  0164              bchg.b   d0, -(a4)
01012dea  0165              bchg.b   d0, -(a5)
01012dec  0166              bchg.b   d0, -(a6)
01012dee  0166              bchg.b   d0, -(a6)
01012df0  03680180          bchg.b   d1, $180(a0)
01012df4  0194              bclr.b   d0, (a4)
01012df6  0195              bclr.b   d0, (a5)
01012df8  0196              bclr.b   d0, (a6)
01012dfa  0198              bclr.b   d0, (a0)+
01012dfc  0199              bclr.b   d0, (a1)+
01012dfe  0199              bclr.b   d0, (a1)+
01012e00  0299039a01a6      andi.l   #$39a01a6, (a1)+
01012e06  01a801a9          bclr.b   d0, $1a9(a0)
01012e0a  01aa01aa          bclr.b   d0, $1aa(a2)
01012e0e  02aa03aa04aa06ab  andi.l   #$3aa04aa, $6ab(a2)
01012e16  01ac01ae          bclr.b   d0, $1ae(a4)
01012e1a  01ae02af          bclr.b   d0, $2af(a6)
01012e1e  01b801b9          bclr.b   d0, $1b9.w
01012e22  01ba              dc.w     $01ba
01012e24  01ba              dc.w     $01ba
01012e26  02bb              dc.w     $02bb
01012e28  01bb              dc.w     $01bb
01012e2a  02bb              dc.w     $02bb
01012e2c  03bc              dc.w     $03bc
01012e2e  01be              dc.w     $01be
01012e30  01bf              dc.w     $01bf
01012e32  01c0              bset.b   d0, d0
01012e34  01c801d4          movep.l  d0, $1d4(a0)
01012e38  01d5              bset.b   d0, (a5)
01012e3a  01d9              bset.b   d0, (a1)+
01012e3c  01e1              bset.b   d0, -(a1)
01012e3e  01e4              bset.b   d0, -(a4)
01012e40  01e5              bset.b   d0, -(a5)
01012e42  01e6              bset.b   d0, -(a6)
01012e44  01e801ea          bset.b   d0, $1ea(a0)
01012e48  01eb01ec          bset.b   d0, $1ec(a3)
01012e4c  01ee01ee          bset.b   d0, $1ee(a6)
01012e50  02ee              dc.w     $02ee
01012e52  03ef01fa          bset.b   d1, $1fa(a7)
01012e56  01fb              dc.w     $01fb
01012e58  01fc              dc.w     $01fc
01012e5a  01fe              dc.w     $01fe
01012e5c  01ff              dc.w     $01ff
01012e5e  01ff              dc.w     $01ff
01012e60  02ff              dc.w     $02ff
01012e62  04173a36          subi.b   #$36, (a7)
01012e66  3119              move.w   (a1)+, -(a0)
01012e68  1a09              dc.w     $1a09
01012e6a  00051051          ori.b    #$51, d5
01012e6e  3617              move.w   (a7), d3
01012e70  3a36441a          move.w   $1a(a6, d4.w), d5
01012e74  1210              move.b   (a0), d1
01012e76  00045b36          ori.b    #$36, d4
01012e7a  173a3538          move.b   $10163b4(pc), -(a3)
01012e7e  5011              addq.b   #$8, (a1)
01012e80  09080005          movep.w  $5(a0), d4
01012e84  04525135          subi.w   #$5135, (a2)
01012e88  185b              dc.w     $185b
01012e8a  3545311a          move.w   d5, $311a(a2)
01012e8e  1110              move.b   (a0), -(a0)
01012e90  0800              dc.w     $0800
01012e92  04514535          subi.w   #$4535, (a1)
01012e96  18353851          move.b   $51(a5, d3.l), d4
01012e9a  3116              move.w   (a6), -(a0)
01012e9c  0008              dc.w     $0008
01012e9e  0104              btst.l   d0, d4
01012ea0  51385134          subq.b   #$8, $5134.w
01012ea4  18353a24          move.b   $24(a5, d3.l), d4
01012ea8  3112              move.w   (a2), -(a0)
01012eaa  1001              move.b   d1, d0
01012eac  0451383f          subi.w   #$383f, (a1)
01012eb0  3418              move.w   (a0)+, d2
01012eb2  353e              dc.w     $353e
01012eb4  21311603          move.l   $3(a1, d1.w), -(a0)
01012eb8  0951              bchg.b   d4, (a1)
01012eba  3a54              movea.w  (a4), a5
01012ebc  3418              move.w   (a0)+, d2
01012ebe  354e1f26          move.w   a6, $1f26(a2)
01012ec2  0e10              dc.w     $0e10
01012ec4  01080451          movep.w  $451(a0), d0
01012ec8  42341834          clr.b    $34(a4, d1.l)
01012ecc  38292131          move.w   $2131(a1), d4
01012ed0  1603              move.b   d3, d3
01012ed2  1051              dc.w     $1051
01012ed4  3a54              movea.w  (a4), a5
01012ed6  51331834          subq.b   #$8, $34(a3, d1.l)
01012eda  3a1a              move.w   (a2)+, d5
01012edc  1f26              move.b   -(a6), -(a7)
01012ede  0e02              dc.w     $0e02
01012ee0  0e07              dc.w     $0e07
01012ee2  5441              addq.w   #$2, d1
01012ee4  463f              dc.w     $463f
01012ee6  3318              move.w   (a0)+, -(a1)
01012ee8  343e              dc.w     $343e
01012eea  091a              btst.l   d4, (a2)+
01012eec  2b15              move.l   (a5), -(a5)
01012eee  0e00              dc.w     $0e00
01012ef0  0e04              dc.w     $0e04
01012ef2  0951              bchg.b   d4, (a1)
01012ef4  575c              subq.w   #$3, (a4)+
01012ef6  54331834          addq.b   #$2, $34(a3, d1.l)
01012efa  4d11              chk.l    (a1), d6
01012efc  1f26              move.b   -(a6), -(a7)
01012efe  0e01              dc.w     $0e01
01012f00  04051452          subi.b   #$52, d5
01012f04  415c              dc.w     $415c
01012f06  59331833          subq.b   #$4, $33(a3, d1.l)
01012f0a  3827              move.w   -(a7), d4
01012f0c  091a              btst.l   d4, (a2)+
01012f0e  2b0e              move.l   a6, -(a5)
01012f10  000f              dc.w     $000f
01012f12  091a              btst.l   d4, (a2)+
01012f14  5457              addq.w   #$2, (a7)
01012f16  5c5b              addq.w   #$6, (a3)+
01012f18  5118              subq.b   #$8, (a0)+
01012f1a  33380005          move.w   $5.w, -(a1)
01012f1e  1a22              move.b   -(a2), d5
01012f20  0e00              dc.w     $0e00
01012f22  06111659          addi.b   #$59, (a1)
01012f26  465c              not.w    (a4)+
01012f28  5b51              subq.w   #$5, (a1)
01012f2a  18333a00          move.b   (a3, d3.l * 2), d4
01012f2e  040d              dc.w     $040d
01012f30  200e              move.l   a6, d0
01012f32  050e090d          movep.w  $90d(a6), d2
01012f36  1a54              dc.w     $1a54
01012f38  5d59              subq.w   #$6, (a1)+
01012f3a  3f18              move.w   (a0)+, -(a7)
01012f3c  333901111910      move.w   $1111910.l, -(a1)
01012f42  0005141a          ori.b    #$1a, d5
01012f46  0d59              bchg.b   d6, (a1)+
01012f48  5c5b              addq.w   #$6, (a3)+
01012f4a  5458              addq.w   #$2, (a0)+
01012f4c  18333e01          move.b   $1(a3, d3.l), d4
01012f50  090c0e0b          movep.w  $e0b(a4), d4
01012f54  141a              move.b   (a2)+, d2
01012f56  575c              subq.w   #$3, (a4)+
01012f58  5941              subq.w   #$4, d1
01012f5a  3a18              move.w   (a0)+, d5
01012f5c  333d              dc.w     $333d
01012f5e  1100              move.b   d0, -(a0)
01012f60  0511              btst.l   d2, (a1)
01012f62  1605              move.b   d5, d3
01012f64  111c              move.b   (a4)+, -(a0)
01012f66  5c5b              addq.w   #$6, (a3)+
01012f68  5451              addq.w   #$2, (a1)
01012f6a  5418              addq.b   #$2, (a0)+
01012f6c  334e0900          move.w   a6, $900(a1)
01012f70  0408              dc.w     $0408
01012f72  0e0a              dc.w     $0e0a
01012f74  111b              move.b   (a3)+, -(a0)
01012f76  5c59              addq.w   #$6, (a1)+
01012f78  3f3a3818          move.w   $1016792(pc), -(a7)
01012f7c  334e190e          move.w   a6, $190e(a1)
01012f80  00051114          ori.b    #$14, d5
01012f84  191c              move.b   (a4)+, -(a4)
01012f86  5b54              subq.w   #$5, (a4)
01012f88  34381838          move.w   $1838.w, d2
01012f8c  291a              move.l   (a2)+, -(a4)
01012f8e  0900              btst.l   d4, d0
01012f90  0816              dc.w     $0816
01012f92  0a141b59          eori.b   #$59, (a4)
01012f96  3f342418          move.w   $18(a4, d2.w), -(a7)
01012f9a  382a1a19          move.w   $1a19(a2), d4
01012f9e  1105              move.b   d5, -(a0)
01012fa0  1114              move.b   (a4), -(a0)
01012fa2  1d54332d          move.b   (a4), $332d(a6)
01012fa6  2f18              move.l   (a0)+, -(a7)
01012fa8  382d1a16          move.w   $1a16(a5), d4
01012fac  001a1614          ori.b    #$14, (a2)+
01012fb0  1c51              dc.w     $1c51
01012fb2  3025              move.w   -(a5), d0
01012fb4  18383324          move.b   $3324.w, d4
01012fb8  2319              move.l   (a1)+, -(a1)
01012fba  0e11              dc.w     $0e11
01012fbc  141d              move.b   (a5)+, d2
01012fbe  4b2d1a1f          chk.l    $1a1f(a5), d5
01012fc2  18383332          move.b   $3332.w, d4
01012fc6  2c29081e          move.l   $81e(a1), d6
01012fca  4f23              chk.l    -(a3), d7
01012fcc  1b1f              move.b   (a7)+, -(a5)
01012fce  183a3430          move.b   $1016400(pc), d4
01012fd2  2319              move.l   (a1)+, -(a1)
01012fd4  140d              dc.w     $140d
01012fd6  1d4a              dc.w     $1d4a
01012fd8  1c11              move.b   (a1), d6
01012fda  183a352c          move.b   $1016508(pc), d4
01012fde  2b1e              move.l   (a6)+, -(a5)
01012fe0  4a1a              tst.b    (a2)+
01012fe2  0b18              btst.l   d5, (a0)+
01012fe4  3a40              movea.w  d0, a5
01012fe6  3422              move.w   -(a2), d2
01012fe8  1e49              dc.w     $1e49
01012fea  1318              move.b   (a0)+, -(a1)
01012fec  3b515433          move.w   (a1), $5433(a5)
01012ff0  311e              move.w   (a6)+, -(a0)
01012ff2  4704              chk.l    d4, d3
01012ff4  0008              dc.w     $0008
01012ff6  00183a59          ori.b    #$59, (a0)+
01012ffa  43311e47          chk.l    $47(a1, d1.l), d1
01012ffe  0318              btst.l   d1, (a0)+
01013000  3a5b              movea.w  (a3)+, a5
01013002  5653              addq.w   #$3, (a3)
01013004  1e48              dc.w     $1e48
01013006  0318              btst.l   d1, (a0)+
01013008  3a5e              movea.w  (a6)+, a5
0101300a  5a1e              addq.b   #$5, (a6)+
0101300c  4c0a              dc.w     $4c0a
0101300e  0800              dc.w     $0800
01013010  183a5e5a          move.b   $1018e6c(pc), d4
01013014  1e4a              dc.w     $1e4a
01013016  2812              move.l   (a2), d4
01013018  0e18              dc.w     $0e18
0101301a  3a5e              movea.w  (a6)+, a5
0101301c  5a1e              addq.b   #$5, (a6)+
0101301e  4a1b              tst.b    (a3)+
01013020  1609              dc.w     $1609
01013022  183a5c57          move.b   $1018c7b(pc), d4
01013026  5b54              subq.w   #$5, (a4)
01013028  501e              addq.b   #$8, (a6)+
0101302a  4f23              chk.l    -(a3), d7
0101302c  1b11              move.b   (a1), -(a5)
0101302e  183a5c42          move.b   $1018c72(pc), d4
01013032  3f311e4b          move.w   $4b(a1, d1.l), -(a7)
01013036  2c1c              move.l   (a4)+, d6
01013038  183c5551          move.b   #$51, d4
0101303c  33311e4f          move.w   $4f(a1, d1.l), -(a1)
01013040  251a              move.l   (a2)+, -(a2)
01013042  18384134          move.b   $4134.w, d4
01013046  322b1e51          move.w   $1e51(a3), d1
0101304a  322e1838          move.w   $1838(a6), d1
0101304e  3524              move.w   -(a4), -(a2)
01013050  221e              move.l   (a6)+, d1
01013052  51333024          subq.b   #$8, $24(a3, d3.w)
01013056  2318              move.l   (a0)+, -(a1)
01013058  38332e19          move.w   $19(a3, d2.l), d4
0101305c  1e51              dc.w     $1e51
0101305e  342d1838          move.w   $1838(a5), d2
01013062  1f24              move.b   -(a4), -(a7)
01013064  231a              move.l   (a2)+, -(a1)
01013066  1937              dc.w     $1937
01013068  51351a00          subq.b   #$8, (a5, d1.l * 2)

; ---- gap 01013072..01013090 (31 bytes) ----
01013072  0048              dc.w     $0048
01013074  00000029          ori.b    #$29, d0
01013078  52aeaaaa          addq.l   #$1, -$5556(a6)
0101307c  aaaa              dc.w     $aaaa
0101307e  a854              dc.w     $a854
01013080  5511              subq.b   #$2, (a1)
01013082  000441ea          ori.b    #$ea, d4
01013086  aaaa              dc.w     $aaaa
01013088  aaaa              dc.w     $aaaa
0101308a  52aeaaaa          addq.l   #$1, -$5556(a6)
0101308e  aaaa              dc.w     $aaaa
01013090  bc55              dc.w     $bc55

; ---- gap 01013096..010130d6 (65 bytes) ----
01013096  01fe              dc.w     $01fe
01013098  aaaa              dc.w     $aaaa
0101309a  aaaa              dc.w     $aaaa
0101309c  52aeaaaa          addq.l   #$1, -$5556(a6)
010130a0  aaab              dc.w     $aaab
010130a2  e844              asr.w    #$4, d4
010130a4  1110              move.b   (a0), -(a0)
010130a6  000401eb          ori.b    #$eb, d4
010130aa  eaaa              lsr.l    d5, d2
010130ac  aaaa              dc.w     $aaaa
010130ae  53fe              dc.w     $53fe
010130b0  aaaa              dc.w     $aaaa
010130b2  aabd              dc.w     $aabd
010130b4  4055              negx.w   (a5)
010130b6  4441              neg.w    d1
010130b8  1000              move.b   d0, d0
010130ba  01c1              bset.b   d0, d1
010130bc  7eaa              moveq    #$aa, d7
010130be  aaaa              dc.w     $aaaa
010130c0  53aaaaaa          subq.l   #$1, -$5556(a2)
010130c4  abe8              dc.w     $abe8
010130c6  00510010          ori.w    #$10, (a1)
010130ca  000001c0          ori.b    #$c0, d0
010130ce  2bea              dc.w     $2bea
010130d0  aaaa              dc.w     $aaaa
010130d2  53aaaaaa          subq.l   #$1, -$5556(a2)
010130d6  ae40              dc.w     $ae40

; ---- gap 010130dd..01013325 (585 bytes) ----
010130dd  0001c101          ori.b    #$1, d1
010130e1  baaaaa53          cmp.l    -$55ad(a2), d5
010130e5  aaaa              dc.w     $aaaa
010130e7  aab9              dc.w     $aab9
010130e9  1100              move.b   d0, -(a0)
010130eb  5100              subq.b   #$8, d0
010130ed  00000011          ori.b    #$11, d0
010130f1  c044              and.w    d4, d0
010130f3  6eaa              bgt.b    $101309f
010130f5  aa53              dc.w     $aa53
010130f7  aaaa              dc.w     $aaaa
010130f9  aae4              dc.w     $aae4
010130fb  4440              neg.w    d0
010130fd  4041              negx.w   d1
010130ff  00001001          ori.b    #$1, d0
01013103  c111              and.b    d0, (a1)
01013105  1baaaa53aaaa      move.b   -$55ad(a2), -$56(a5, a2.l)
0101310b  ab99              dc.w     $ab99
0101310d  5110              subq.b   #$8, (a0)
0101310f  5100              subq.b   #$8, d0
01013111  00000041          ori.b    #$41, d0
01013115  c445              and.w    d5, d2
01013117  66ea              bne.b    $1013103
01013119  aa53              dc.w     $aa53
0101311b  aaaa              dc.w     $aaaa
0101311d  ae65              dc.w     $ae65
0101311f  1444              dc.w     $1444
01013121  4000              negx.b   d0
01013123  00004005          ori.b    #$5, d0
01013127  d114              add.b    d0, (a4)
01013129  59ba              dc.w     $59ba
0101312b  aa53              dc.w     $aa53
0101312d  aaaa              dc.w     $aaaa
0101312f  ba59              cmp.w    (a1)+, d5
01013131  5510              subq.b   #$2, (a0)
01013133  5040              addq.w   #$8, d0
01013135  00400111          ori.w    #$111, d0
01013139  c455              and.w    (a5), d2
0101313b  65ae              bcs.b    $10130eb
0101313d  aa53              dc.w     $aa53
0101313f  aaaa              dc.w     $aaaa
01013141  eaa6              asr.l    d5, d6
01013143  6550              bcs.b    $1013195
01013145  4000              negx.b   d0
01013147  00010445          ori.b    #$45, d1
0101314b  c559              and.w    d2, (a1)+
0101314d  9aabaa53          sub.l    -$55ad(a3), d5
01013151  aaab              dc.w     $aaab
01013153  aaa9              dc.w     $aaa9
01013155  9954              sub.w    d4, (a4)
01013157  4000              negx.b   d0
01013159  4040              negx.w   d0
0101315b  1155d566          move.b   (a5), -$2a9a(a0)
0101315f  6aaa              bpl.b    $101310b
01013161  ea53              roxr.w   #$5, d3
01013163  aaab              dc.w     $aaab
01013165  baaa6654          cmp.l    $6654(a2), d5
01013169  4000              negx.b   d0
0101316b  04044451          subi.b   #$51, d4
0101316f  d599              add.l    d2, (a1)+
01013171  aaae              dc.w     $aaae
01013173  ea53              roxr.w   #$5, d3
01013175  aaae              dc.w     $aaae
01013177  eeaa              lsr.l    d7, d2
01013179  a998              dc.w     $a998
0101317b  4004              negx.b   d4
0101317d  4011              negx.b   (a1)
0101317f  1555e66a          move.b   (a5), -$1996(a2)
01013183  aabb              dc.w     $aabb
01013185  ba53              cmp.w    (a3), d5
01013187  aaae              dc.w     $aaae
01013189  bbaaaa64          eor.l    d5, -$559c(a2)
0101318d  4100              chk.l    d0, d0
0101318f  04455515          subi.w   #$5515, d5
01013193  d9aaaaee          add.l    d4, -$5512(a2)
01013197  ba53              cmp.w    (a3), d5
01013199  aabb              dc.w     $aabb
0101319b  eeee              dc.w     $eeee
0101319d  ba98              cmp.l    (a0)+, d5
0101319f  4011              negx.b   (a1)
010131a1  1111              move.b   (a1), -(a0)
010131a3  4555              dc.w     $4555
010131a5  e6ae              lsr.l    d3, d6
010131a7  bbbb              dc.w     $bbbb
010131a9  ee53              roxr.w   #$7, d3
010131ab  aabb              dc.w     $aabb
010131ad  fbbb              dc.w     $fbbb
010131af  aaa4              dc.w     $aaa4
010131b1  5104              subq.b   #$8, d4
010131b3  4455              neg.w    (a5)
010131b5  5555              subq.w   #$2, (a5)
010131b7  daaaeeef          add.l    -$1111(a2), d5
010131bb  ee53              roxr.w   #$7, d3
010131bd  aaef              dc.w     $aaef
010131bf  beeeeba8          cmpa.w   -$1458(a6), a7
010131c3  4011              negx.b   (a1)
010131c5  11445555          move.b   d4, $5555(a0)
010131c9  eaeb              dc.w     $eaeb
010131cb  bbbe              dc.w     $bbbe
010131cd  fb53              frestore (a3)
010131cf  aaef              dc.w     $aaef
010131d1  fffb              dc.w     $fffb
010131d3  bab84445          cmp.l    $4445.w, d5
010131d7  5455              addq.w   #$2, (a5)
010131d9  5555              subq.w   #$2, (a5)
010131db  eeae              lsr.l    d7, d6
010131dd  efff              dc.w     $efff
010131df  fb53              frestore (a3)
010131e1  abbf              dc.w     $abbf
010131e3  ffbe              dc.w     $ffbe
010131e5  eee8              dc.w     $eee8
010131e7  5111              subq.b   #$8, (a1)
010131e9  11455555          move.b   d5, $5555(a0)
010131ed  ebbb              rol.l    d5, d3
010131ef  beff              dc.w     $beff
010131f1  fe53abbf          ftrapueq.b (a3)
010131f5  bffbbbac4445      cmpa.l   $4445(a3.l * 2), a7
010131fb  5555              subq.w   #$2, (a5)
010131fd  5555              subq.w   #$2, (a5)
010131ff  faeeeffefe53      fbf.l    $f1003054
01013205  abbb              dc.w     $abbb
01013207  efff              dc.w     $efff
01013209  eee8              dc.w     $eee8
0101320b  5551              subq.w   #$2, (a1)
0101320d  4555              dc.w     $4555
0101320f  5555              subq.w   #$2, (a5)
01013211  ebbb              rol.l    d5, d3
01013213  fffb              dc.w     $fffb
01013215  ee53              roxr.w   #$7, d3
01013217  abbf              dc.w     $abbf
01013219  beff              dc.w     $beff
0101321b  fbb8              dc.w     $fbb8
0101321d  4445              neg.w    d5
0101321f  5555              subq.w   #$2, (a5)
01013221  5555              subq.w   #$2, (a5)
01013223  eeef              dc.w     $eeef
01013225  ffbe              dc.w     $ffbe
01013227  fe53abbb          ftrapole.b (a3)
0101322b  ffef              dc.w     $ffef
0101322d  feec55555555      fbf.l    $56568784
01013233  5555              subq.w   #$2, (a5)
01013235  fbbf              dc.w     $fbbf
01013237  fbff              dc.w     $fbff
01013239  ee53              roxr.w   #$7, d3
0101323b  aeee              dc.w     $aeee
0101323d  eeff              dc.w     $eeff
0101323f  eff845155555      bfins    d4, $5555.w{20:21}
01013245  5555              subq.w   #$2, (a5)
01013247  effb              dc.w     $effb
01013249  ffbb              dc.w     $ffbb
0101324b  bb53              eor.w    d5, (a3)
0101324d  aebb              dc.w     $aebb
0101324f  bbbb              dc.w     $bbbb
01013251  ffbc              dc.w     $ffbc
01013253  5555              subq.w   #$2, (a5)
01013255  5555              subq.w   #$2, (a5)
01013257  5555              subq.w   #$2, (a5)
01013259  feffeeeeee53      fbf.l    $eff020ae
0101325f  aeee              dc.w     $aeee
01013261  eeee              dc.w     $eeee
01013263  effc              dc.w     $effc
01013265  5555              subq.w   #$2, (a5)
01013267  5555              subq.w   #$2, (a5)
01013269  5555              subq.w   #$2, (a5)
0101326b  fffb              dc.w     $fffb
0101326d  bbbb              dc.w     $bbbb
0101326f  bb53              eor.w    d5, (a3)
01013271  aebb              dc.w     $aebb
01013273  bbbb              dc.w     $bbbb
01013275  bbb85555          eor.l    d5, $5555.w
01013279  5555              subq.w   #$2, (a5)
0101327b  5555              subq.w   #$2, (a5)
0101327d  eeee              dc.w     $eeee
0101327f  eeee              dc.w     $eeee
01013281  ee53              roxr.w   #$7, d3
01013283  aeee              dc.w     $aeee
01013285  eaea              dc.w     $eaea
01013287  aaec              dc.w     $aaec
01013289  5555              subq.w   #$2, (a5)
0101328b  5555              subq.w   #$2, (a5)
0101328d  5555              subq.w   #$2, (a5)
0101328f  fbaa              dc.w     $fbaa
01013291  abab              dc.w     $abab
01013293  bb53              eor.w    d5, (a3)
01013295  aee6              dc.w     $aee6
01013297  9aaaaaa4          sub.l    -$555c(a2), d5
0101329b  5555              subq.w   #$2, (a5)
0101329d  5555              subq.w   #$2, (a5)
0101329f  5555              subq.w   #$2, (a5)
010132a1  daaaaaa6          add.l    -$555a(a2), d5
010132a5  9b53              sub.w    d5, (a3)
010132a7  aeaa              dc.w     $aeaa
010132a9  a9a9              dc.w     $a9a9
010132ab  9998              sub.l    d4, (a0)+
010132ad  5555              subq.w   #$2, (a5)
010132af  5555              subq.w   #$2, (a5)
010132b1  5555              subq.w   #$2, (a5)
010132b3  e666              asr.w    d3, d6
010132b5  6a6a              bpl.b    $1013321
010132b7  aa53              dc.w     $aa53
010132b9  aeaa              dc.w     $aeaa
010132bb  6a66              bpl.b    $1013323
010132bd  6654              bne.b    $1013313
010132bf  5555              subq.w   #$2, (a5)
010132c1  5555              subq.w   #$2, (a5)
010132c3  5555              subq.w   #$2, (a5)
010132c5  d599              add.l    d2, (a1)+
010132c7  99a9aa53          sub.l    d4, -$55ad(a1)
010132cb  aea6              dc.w     $aea6
010132cd  a999              dc.w     $a999
010132cf  9550              sub.w    d2, (a0)
010132d1  5555              subq.w   #$2, (a5)
010132d3  5555              subq.w   #$2, (a5)
010132d5  5555              subq.w   #$2, (a5)
010132d7  c556              and.w    d2, (a6)
010132d9  666a              bne.b    $1013345
010132db  9a53              sub.w    (a3), d5
010132dd  aeaa              dc.w     $aeaa
010132df  6666              bne.b    $1013347
010132e1  5544              subq.w   #$2, d4
010132e3  5555              subq.w   #$2, (a5)
010132e5  5555              subq.w   #$2, (a5)
010132e7  5555              subq.w   #$2, (a5)
010132e9  d155              add.w    d0, (a5)
010132eb  9999              sub.l    d4, (a1)+
010132ed  aa53              dc.w     $aa53
010132ef  ae99              dc.w     $ae99
010132f1  9995              sub.l    d4, (a5)
010132f3  5510              subq.b   #$2, (a0)
010132f5  5555              subq.w   #$2, (a5)
010132f7  5555              subq.w   #$2, (a5)
010132f9  5555              subq.w   #$2, (a5)
010132fb  c455              and.w    (a5), d2
010132fd  5666              addq.w   #$3, -(a6)
010132ff  6653              bne.b    $1013354
01013301  aea6              dc.w     $aea6
01013303  6555              bcs.b    sub_0101335a
01013305  5440              addq.w   #$2, d0
01013307  5555              subq.w   #$2, (a5)
01013309  5555              subq.w   #$2, (a5)
0101330b  5555              subq.w   #$2, (a5)
0101330d  c115              and.b    d0, (a5)
0101330f  5559              subq.w   #$2, (a1)+
01013311  9a53              sub.w    (a3), d5
01013313  ab59              dc.w     $ab59
01013315  9555              sub.w    d2, (a5)
01013317  1104              move.b   d4, -(a0)
01013319  5555              subq.w   #$2, (a5)
0101331b  5555              subq.w   #$2, (a5)
0101331d  5555              subq.w   #$2, (a5)
0101331f  d044              add.w    d4, d0
01013321  5556              subq.w   #$2, (a6)
01013323  6553              bcs.b    $1013378
01013325  ab55              dc.w     $ab55

; ---- gap 0101332b..01013359 (47 bytes) ----
0101332b  5555              subq.w   #$2, (a5)
0101332d  5555              subq.w   #$2, (a5)
0101332f  5555              subq.w   #$2, (a5)
01013331  c011              and.b    (a1), d0
01013333  5555              subq.w   #$2, (a5)
01013335  5553              subq.w   #$2, (a3)
01013337  ab55              dc.w     $ab55
01013339  5551              subq.w   #$2, (a1)
0101333b  1000              move.b   d0, d0
0101333d  5555              subq.w   #$2, (a5)
0101333f  5555              subq.w   #$2, (a5)
01013341  5555              subq.w   #$2, (a5)
01013343  c004              and.b    d4, d0
01013345  4555              dc.w     $4555
01013347  5553              subq.w   #$2, (a3)
01013349  ab55              dc.w     $ab55
0101334b  5444              addq.w   #$2, d4
0101334d  4444              neg.w    d4
0101334f  aaaa              dc.w     $aaaa
01013351  aaaa              dc.w     $aaaa
01013353  aaaa              dc.w     $aaaa
01013355  d111              add.b    d0, (a1)
01013357  1115              move.b   (a5), -(a0)
01013359  5555              dc.w     $5555

; ---- gap 0101336a..010133a9 (64 bytes) ----
0101336a  044f              dc.w     $044f
0101336c  f555              frestore (a5)
0101336e  113f              dc.w     $113f
01013370  fc5545ff          ftrapueq.b (a5)
01013374  ff55              frestore (a5)
01013376  13ff              dc.w     $13ff
01013378  ffd5              dc.w     $ffd5
0101337a  4fff              dc.w     $4fff
0101337c  fff5              dc.w     $fff5
0101337e  7fff              dc.w     $7fff
01013380  fffd              dc.w     $fffd
01013382  ffff              dc.w     $ffff
01013384  ffff              dc.w     $ffff
01013386  ffff              dc.w     $ffff
01013388  ffff              dc.w     $ffff
0101338a  15ff              dc.w     $15ff
0101338c  ff55              frestore (a5)
0101338e  55ff              dc.w     $55ff
01013390  ff55              frestore (a5)
01013392  55ff              dc.w     $55ff
01013394  ff55              frestore (a5)
01013396  55ff              dc.w     $55ff
01013398  ff55              frestore (a5)
0101339a  55ff              dc.w     $55ff
0101339c  ff55              frestore (a5)
0101339e  55ff              dc.w     $55ff
010133a0  ff55              frestore (a5)
010133a2  55ff              dc.w     $55ff
010133a4  ff55              frestore (a5)
010133a6  55ff              dc.w     $55ff
010133a8  ff55              frestore (a5)

; ---- gap 010133ba..010133f9 (64 bytes) ----
010133ba  000f              dc.w     $000f
010133bc  f040403f          ftrapueq.b d0
010133c0  fc0100ff          add      fp0, fp1
010133c4  ff04              dc.w     $ff04
010133c6  03ff              dc.w     $03ff
010133c8  ffd1              dc.w     $ffd1
010133ca  0fff              dc.w     $0fff
010133cc  fff4              dc.w     $fff4
010133ce  3fff              dc.w     $3fff
010133d0  fffd              dc.w     $fffd
010133d2  ffff              dc.w     $ffff
010133d4  ffff              dc.w     $ffff
010133d6  ffff              dc.w     $ffff
010133d8  ffff              dc.w     $ffff
010133da  04ff              dc.w     $04ff
010133dc  ff55              frestore (a5)
010133de  11ff              dc.w     $11ff
010133e0  ff55              frestore (a5)
010133e2  45ff              dc.w     $45ff
010133e4  ff55              frestore (a5)
010133e6  11ff              dc.w     $11ff
010133e8  ff55              frestore (a5)
010133ea  45ff              dc.w     $45ff
010133ec  ff55              frestore (a5)
010133ee  51ff              dc.w     $51ff
010133f0  ff55              frestore (a5)
010133f2  45ff              dc.w     $45ff
010133f4  ff55              frestore (a5)
010133f6  55ff              dc.w     $55ff
010133f8  ff55              frestore (a5)

; ---- gap 0101340a..01013449 (64 bytes) ----
0101340a  444f              dc.w     $444f
0101340c  f100              dc.w     $f100
0101340e  113f              dc.w     $113f
01013410  fc0444ff          add.s    d4, fp1
01013414  ff00              dc.w     $ff00
01013416  03ff              dc.w     $03ff
01013418  ffc0              dc.w     $ffc0
0101341a  4fff              dc.w     $4fff
0101341c  fff0              dc.w     $fff0
0101341e  3fff              dc.w     $3fff
01013420  fffc              dc.w     $fffc
01013422  ffff              dc.w     $ffff
01013424  ffff              dc.w     $ffff
01013426  ffff              dc.w     $ffff
01013428  ffff              dc.w     $ffff
0101342a  00ff              dc.w     $00ff
0101342c  ff40              dc.w     $ff40
0101342e  40ff              dc.w     $40ff
01013430  ff01              dc.w     $ff01
01013432  00ff              dc.w     $00ff
01013434  ff04              dc.w     $ff04
01013436  00ff              dc.w     $00ff
01013438  ff11              fsave    (a1)
0101343a  00ff              dc.w     $00ff
0101343c  ff44              dc.w     $ff44
0101343e  04ff              dc.w     $04ff
01013440  ff15              fsave    (a5)
01013442  00ff              dc.w     $00ff
01013444  ff55              frestore (a5)
01013446  11ff              dc.w     $11ff
01013448  ff45              dc.w     $ff45

; ---- gap 01013458..010134f5 (158 bytes) ----
01013458  3fff              dc.w     $3fff
0101345a  fffc              dc.w     $fffc
0101345c  01e9a843          bset.b   d0, -$57bd(a1)
01013460  fa95440c          fbf.w    $101786e
01013464  41eab80e          lea.l    -$47f2(a2), a0
01013468  ea75              roxr.w   d5, d5
0101346a  500e              dc.w     $500e
0101346c  a5e9              dc.w     $a5e9
0101346e  a80e              dc.w     $a80e
01013470  eabd              ror.l    d5, d5
01013472  440e              dc.w     $440e
01013474  a1e6              dc.w     $a1e6
01013476  ec3a              ror.b    d6, d2
01013478  ea73              roxr.w   d5, d3
0101347a  500e              dc.w     $500e
0101347c  a5e9              dc.w     $a5e9
0101347e  b83abeb1          cmp.b    $100f331(pc), d4
01013482  c40e              dc.w     $c40e
01013484  a5e6              dc.w     $a5e6
01013486  ec3a              ror.b    d6, d2
01013488  67f0              beq.b    $101347a
0101348a  700e              moveq    #$e, d0
0101348c  a1d9              dc.w     $a1d9
0101348e  b83a9501          cmp.b    $100c991(pc), d4
01013492  1ffe              dc.w     $1ffe
01013494  a5e5              dc.w     $a5e5
01013496  ec3a              ror.b    d6, d2
01013498  6440              bcc.b    $10134da
0101349a  57aaa5d5          subq.l   #$3, -$5a2b(a2)
0101349e  f83a950115ea      fmove.l  $1014a8a(pc), fpcr
010134a4  a5d4              dc.w     $a5d4
010134a6  fc5e6440          fsf.b    (a6)+
010134aa  557955d1fc5e      subq.w   #$2, $55d1fc5e.l
010134b0  9501              subx.b   d1, d2
010134b2  15ea              dc.w     $15ea
010134b4  55c4              scs.b    d4
010134b6  bc47              cmp.w    d7, d6
010134b8  e440              asr.w    #$2, d0
010134ba  57a955d0          subq.l   #$3, $55d0(a1)
010134be  ec51              roxr.w   #$6, d1
010134c0  7d01              dc.w     $7d01
010134c2  1ea5              move.b   -(a5), (a7)
010134c4  55c4              scs.b    d4
010134c6  b845              cmp.w    d5, d4
010134c8  17f0              dc.w     $17f0
010134ca  7a95              moveq    #$95, d5
010134cc  55d0              scs.b    (a0)
010134ce  a855              dc.w     $a855
010134d0  5171ea55          subq.w   #$8, $55(a1, a6.l)
010134d4  55c0              scs.b    d0
010134d6  6444              bcc.b    $101351c
010134d8  4573              dc.w     $4573
010134da  a955              dc.w     $a955
010134dc  55c1              scs.b    d1
010134de  9855              sub.w    (a5), d4
010134e0  557e              dc.w     $557e
010134e2  a555              dc.w     $a555
010134e4  55c4              scs.b    d4
010134e6  5445              addq.w   #$2, d5
010134e8  1576955555d5      move.b   ([a6]), $55d5(a2)
010134ee  5455              addq.w   #$2, (a5)
010134f0  5556              subq.w   #$2, (a6)
010134f2  5555              subq.w   #$2, (a5)
010134f4  55e6              scs.b    -(a6)

; ---- gap 01013562..0101372d (460 bytes) ----
01013562  01ff              dc.w     $01ff
01013564  02ff              dc.w     $02ff
01013566  03ff              dc.w     $03ff
01013568  04ff              dc.w     $04ff
0101356a  0515              btst.l   d2, (a5)
0101356c  2421              move.l   -(a1), d2
0101356e  1d17              move.b   (a7), -(a6)
01013570  1809              dc.w     $1809
01013572  00050f2a          ori.b    #$2a, d5
01013576  2127              move.l   -(a7), -(a0)
01013578  2615              move.l   (a5), d3
0101357a  2421              move.l   -(a1), d2
0101357c  2818              move.l   (a0)+, d4
0101357e  110f              dc.w     $110f
01013580  00042e21          ori.b    #$21, d4
01013584  2726              move.l   -(a6), -(a3)
01013586  1524              move.b   -(a4), -(a2)
01013588  2023              move.l   -(a3), d0
0101358a  2d10              move.l   (a0), -(a6)
0101358c  09080005          movep.w  $5(a0), d4
01013590  042f2a202726      subi.b   #$20, $2726(a7)
01013596  162e2029          move.b   $2029(a6), d3
0101359a  2d18              move.l   (a0)+, -(a6)
0101359c  100f              dc.w     $100f
0101359e  0800              dc.w     $0800
010135a0  042f2e202726      subi.b   #$20, $2726(a7)
010135a6  1620              move.b   -(a0), d3
010135a8  232f2d14          move.l   $2d14(a7), -(a1)
010135ac  0008              dc.w     $0008
010135ae  0104              btst.l   d0, d4
010135b0  302a1f29          move.w   $1f29(a2), d0
010135b4  2b16              move.l   (a6), -(a5)
010135b6  2025              move.l   -(a5), d0
010135b8  2f2d110f          move.l   $110f(a5), -(a7)
010135bc  0104              btst.l   d0, d4
010135be  302c202b          move.w   $202b(a4), d0
010135c2  1620              move.b   -(a0), d3
010135c4  292f2d14          move.l   $2d14(a7), -(a4)
010135c8  0309302e          movep.w  $302e(a1), d1
010135cc  202b1620          move.l   $1620(a3), d0
010135d0  302d0d0f          move.w   $d0f(a5), d0
010135d4  01080431          movep.w  $431(a0), d0
010135d8  202b161f          move.l   $161f(a3), d0
010135dc  23302d14          move.l   (a0, d2.l * 4), -(a1)
010135e0  030f312a          movep.w  $312a(a7), d1
010135e4  1f2b161f          move.b   $161f(a3), -(a7)
010135e8  25302d0d          move.l   ([a0], d2.l * 4), -(a2)
010135ec  020d              dc.w     $020d
010135ee  07312c1f          btst.l   d3, $1f(a1, d2.l)
010135f2  2b16              move.l   (a6), -(a5)
010135f4  1f29302d          move.b   $302d(a1), -(a7)
010135f8  130d              dc.w     $130d
010135fa  000d              dc.w     $000d
010135fc  0409              dc.w     $0409
010135fe  312e1f2b          move.w   $1f2b(a6), -(a0)
01013602  161f              move.b   (a7)+, d3
01013604  312d0d01          move.w   $d01(a5), -(a0)
01013608  04051232          subi.b   #$32, d5
0101360c  1f2b161e          move.b   $161e(a3), -(a7)
01013610  23312d0d          move.l   ([a1], d2.l * 4), -(a1)
01013614  000e              dc.w     $000e
01013616  0918              btst.l   d4, (a0)+
01013618  322a1e2b          move.w   $1e2b(a2), d1
0101361c  161e              move.b   (a6)+, d3
0101361e  23312d0d          move.l   ([a1], d2.l * 4), -(a1)
01013622  00061014          ori.b    #$14, d6
01013626  322a1e2b          move.w   $1e2b(a2), d1
0101362a  161e              move.b   (a6)+, d3
0101362c  25312d0d          move.l   ([a1], d2.l * 4), -(a2)
01013630  050d090c          movep.w  $90c(a5), d2
01013634  18322c1e          move.b   $1e(a2, d2.l), d4
01013638  2b16              move.l   (a6), -(a5)
0101363a  1e25              move.b   -(a5), d7
0101363c  312d0f00          move.w   $f00(a5), -(a0)
01013640  0512              btst.l   d2, (a2)
01013642  180c              dc.w     $180c
01013644  322c1e2b          move.w   $1e2b(a4), d1
01013648  161e              move.b   (a6)+, d3
0101364a  29312d0d          move.l   ([a1], d2.l * 4), -(a4)
0101364e  0b12              btst.l   d5, (a2)
01013650  18322e1e          move.b   $1e(a2, d2.l), d4
01013654  2b16              move.l   (a6), -(a5)
01013656  1e29312d          move.b   $312d(a1), d7
0101365a  1405              move.b   d5, d2
0101365c  101a              move.b   (a2)+, d0
0101365e  322e1e2b          move.w   $1e2b(a6), d1
01013662  161e              move.b   (a6)+, d3
01013664  322d0d0a          move.w   $d0a(a5), d1
01013668  1019              move.b   (a1)+, d0
0101366a  331e              move.w   (a6)+, -(a1)
0101366c  2b16              move.l   (a6), -(a5)
0101366e  1e322d10          move.b   (a2, d2.l * 4), d7
01013672  1217              move.b   (a7), d1
01013674  1a331e2b          move.b   $2b(a3, d1.l), d5
01013678  1623              move.b   -(a3), d3
0101367a  322d140a          move.w   $140a(a5), d1
0101367e  1219              move.b   (a1)+, d1
01013680  332a2b16          move.w   $2b16(a2), -(a1)
01013684  23322d10          move.l   (a2, d2.l * 4), -(a1)
01013688  121b              move.b   (a3)+, d1
0101368a  332a2b16          move.w   $2b16(a2), -(a1)
0101368e  23322d18          move.l   (a2, d2.l * 4), -(a1)
01013692  1412              move.b   (a2), d2
01013694  1a332a2b          move.b   $2b(a3, d2.l), d5
01013698  1623              move.b   -(a3), d3
0101369a  322d1012          move.w   $1012(a5), d1
0101369e  1b332a2b          move.b   $2b(a3, d2.l), -(a5)
010136a2  1623              move.b   -(a3), d3
010136a4  322d1c33          move.w   $1c33(a5), d1
010136a8  2a2b1625          move.l   $1625(a3), d5
010136ac  322d120c          move.w   $120c(a5), d1
010136b0  1b332c2b          move.b   $2b(a3, d2.l), -(a5)
010136b4  1625              move.b   -(a5), d3
010136b6  322d1c33          move.w   $1c33(a5), d1
010136ba  2c2b1625          move.l   $1625(a3), d6
010136be  322d1c33          move.w   $1c33(a5), d1
010136c2  2c2b1625          move.l   $1625(a3), d6
010136c6  322d1c33          move.w   $1c33(a5), d1
010136ca  2c2b1625          move.l   $1625(a3), d6
010136ce  322d1c33          move.w   $1c33(a5), d1
010136d2  2c2b1625          move.l   $1625(a3), d6
010136d6  322d1c33          move.w   $1c33(a5), d1
010136da  2c2b1625          move.l   $1625(a3), d6
010136de  322d1c33          move.w   $1c33(a5), d1
010136e2  2c2b1625          move.l   $1625(a3), d6
010136e6  322d1c33          move.w   $1c33(a5), d1
010136ea  2c2b1625          move.l   $1625(a3), d6
010136ee  322d1c33          move.w   $1c33(a5), d1
010136f2  2c2b1625          move.l   $1625(a3), d6
010136f6  322d1c33          move.w   $1c33(a5), d1
010136fa  2c2b1625          move.l   $1625(a3), d6
010136fe  322d1c33          move.w   $1c33(a5), d1
01013702  2c2b1625          move.l   $1625(a3), d6
01013706  322d1c33          move.w   $1c33(a5), d1
0101370a  2c2b1623          move.l   $1623(a3), d6
0101370e  322d1c33          move.w   $1c33(a5), d1
01013712  2a2b1623          move.l   $1623(a3), d5
01013716  322d1c33          move.w   $1c33(a5), d1
0101371a  2a2b1623          move.l   $1623(a3), d5
0101371e  322d1c33          move.w   $1c33(a5), d1
01013722  2a2b1623          move.l   $1623(a3), d5
01013726  322d2233          move.w   $2233(a5), d1
0101372a  2a2b0000          move.l   $0(a3), d5

; ---- gap 0101378c..01013bcd (1090 bytes) ----
0101378c  0855              dc.w     $0855
0101378e  0955              bchg.b   d4, (a5)
01013790  0a550b55          eori.w   #$b55, (a5)
01013794  0c550d55          cmpi.w   #$d55, (a5)
01013798  0e55              dc.w     $0e55
0101379a  0f55              bchg.b   d7, (a5)
0101379c  1055              dc.w     $1055
0101379e  1255              dc.w     $1255
010137a0  13551455          move.b   (a5), $1455(a1)
010137a4  15560157          move.b   (a6), $157(a2)
010137a8  0158              bchg.b   d0, (a0)+
010137aa  0159              bchg.b   d0, (a1)+
010137ac  0159              bchg.b   d0, (a1)+
010137ae  025a015b          andi.w   #$15b, (a2)+
010137b2  015d              bchg.b   d0, (a5)+
010137b4  015e              bchg.b   d0, (a6)+
010137b6  015f              bchg.b   d0, (a7)+
010137b8  0164              bchg.b   d0, -(a4)
010137ba  0165              bchg.b   d0, -(a5)
010137bc  0166              bchg.b   d0, -(a6)
010137be  0166              bchg.b   d0, -(a6)
010137c0  04670168          subi.w   #$168, -(a7)
010137c4  0169016a          bchg.b   d0, $16a(a1)
010137c8  016b016d          bchg.b   d0, $16d(a3)
010137cc  016e016f          bchg.b   d0, $16f(a6)
010137d0  017401760179017a  bchg.b   d0, ([$179017a, a4])
010137d8  017e              dc.w     $017e
010137da  017f              dc.w     $017f
010137dc  0180              bclr.b   d0, d0
010137de  0181              bclr.b   d0, d1
010137e0  0191              bclr.b   d0, (a1)
010137e2  0192              bclr.b   d0, (a2)
010137e4  0194              bclr.b   d0, (a4)
010137e6  0195              bclr.b   d0, (a5)
010137e8  0195              bclr.b   d0, (a5)
010137ea  029601980199      andi.l   #$1980199, (a6)
010137f0  0199              bclr.b   d0, (a1)+
010137f2  0299039a019d      andi.l   #$39a019d, (a1)+
010137f8  019e              bclr.b   d0, (a6)+
010137fa  019f              bclr.b   d0, (a7)+
010137fc  01a0              bclr.b   d0, -(a0)
010137fe  01a1              bclr.b   d0, -(a1)
01013800  01a2              bclr.b   d0, -(a2)
01013802  01a3              bclr.b   d0, -(a3)
01013804  01a4              bclr.b   d0, -(a4)
01013806  01a5              bclr.b   d0, -(a5)
01013808  01a5              bclr.b   d0, -(a5)
0101380a  02a601a701a8      andi.l   #$1a701a8, -(a6)
01013810  01a901aa          bclr.b   d0, $1aa(a1)
01013814  01aa02aa          bclr.b   d0, $2aa(a2)
01013818  03aa04ab          bclr.b   d1, $4ab(a2)
0101381c  01ad01ae          bclr.b   d0, $1ae(a5)
01013820  01af01b5          bclr.b   d0, $1b5(a7)
01013824  01b601b901ba01bb  bclr.b   d0, ([$1ba01bb, d0.w])
0101382c  01bb              dc.w     $01bb
0101382e  02bb              dc.w     $02bb
01013830  03bd              dc.w     $03bd
01013832  01be              dc.w     $01be
01013834  01bf              dc.w     $01bf
01013836  01bf              dc.w     $01bf
01013838  02c0              dc.w     $02c0
0101383a  01c1              bset.b   d0, d1
0101383c  01c4              bset.b   d0, d4
0101383e  01d4              bset.b   d0, (a4)
01013840  01d5              bset.b   d0, (a5)
01013842  01d9              bset.b   d0, (a1)+
01013844  01df              bset.b   d0, (a7)+
01013846  01e5              bset.b   d0, -(a5)
01013848  01e6              bset.b   d0, -(a6)
0101384a  01e901ea          bset.b   d0, $1ea(a1)
0101384e  01eb01ee          bset.b   d0, $1ee(a3)
01013852  01ee02ee          bset.b   d0, $2ee(a6)
01013856  03ef01f0          bset.b   d1, $1f0(a7)
0101385a  01f101f201f501f901fa  bset.b   d0, ([$1f501f9], $1fa)
01013864  01fb              dc.w     $01fb
01013866  01fd              dc.w     $01fd
01013868  01fe              dc.w     $01fe
0101386a  01ff              dc.w     $01ff
0101386c  01ff              dc.w     $01ff
0101386e  02ff              dc.w     $02ff
01013870  03ff              dc.w     $03ff
01013872  0427356c          subi.b   #$6c, -(a7)
01013876  6337              bls.b    $10138af
01013878  685a              bvc.b    $10138d4
0101387a  2927              move.l   -(a7), -(a4)
0101387c  6a10              bpl.b    $101388e
0101387e  3589742a          move.w   a1, $2a(a2, d7.w)
01013882  2646              movea.l  d6, a3
01013884  2147742c          move.l   d7, $742c(a0)
01013888  2535566c          move.l   $6c(a5, d5.w), -(a2)
0101388c  4d2d2544          chk.l    $2544(a5), d6
01013890  1493              move.b   (a3), (a2)
01013892  2e25              move.l   -(a5), d7
01013894  5549              subq.w   #$2, a1
01013896  2446              movea.l  d6, a2
01013898  6d28              blt.b    $10138c2
0101389a  24383b66          move.l   $3b66.w, d2
0101389e  2246              movea.l  d6, a1
010138a0  6c56              bge.b    $10138f8
010138a2  2007              move.l   d7, d0
010138a4  6d6b              blt.b    $1013911
010138a6  2524              move.l   -(a4), -(a2)
010138a8  4071226c          negx.w   $6c(a1, d2.w)
010138ac  5621              addq.b   #$3, -(a1)
010138ae  4140              dc.w     $4140
010138b0  1322              move.b   -(a2), -(a1)
010138b2  356c24245d92      move.w   $2424(a4), $5d92(a2)
010138b8  216c1d136d6b      move.l   $1d13(a4), $6d6b(a0)
010138be  3a6d6b03          movea.w  $6b03(a5), a5
010138c2  6623              bne.b    $10138e7
010138c4  23351466          move.l   $66(a5, d1.w), -(a1)
010138c8  3a21              move.w   -(a1), d5
010138ca  453a7078          chk.l    $101a944(pc), d2
010138ce  774a              dc.w     $774a
010138d0  8a6d353a          or.w     $353a(a5), d5
010138d4  2323              move.l   -(a3), -(a1)
010138d6  37383556          move.w   $3556.w, -(a3)
010138da  3a6b5f99          movea.w  $5f99(a3), a5
010138de  97729988          sub.w    d3, (a1.l)
010138e2  5d67              subq.w   #$6, -(a7)
010138e4  2223              move.l   -(a3), d1
010138e6  4167              dc.w     $4167
010138e8  3a6c8b73          movea.w  -$748d(a4), a5
010138ec  8824              or.b     -(a4), d4
010138ee  7297              moveq    #$97, d1
010138f0  726c              moveq    #$6c, d1
010138f2  3a22              move.w   -(a2), d5
010138f4  23417521          move.l   d1, $7521(a1)
010138f8  6c8e              bge.b    $1013888
010138fa  97284794          sub.b    d3, $4794(a0)
010138fe  5721              subq.b   #$3, -(a1)
01013900  233a8f16          move.l   $100c818(pc), -(a1)
01013904  7097              moveq    #$97, d0
01013906  2a4a              movea.l  a2, a5
01013908  6b40              bmi.b    $101394a
0101390a  2123              move.l   -(a3), -(a0)
0101390c  5d80              subq.l   #$6, d0
0101390e  167d              dc.w     $167d
01013910  562a3588          addq.b   #$3, $3588(a2)
01013914  0721              btst.l   d3, -(a1)
01013916  233a373b          move.l   $1017053(pc), -(a1)
0101391a  932c4b04          sub.b    d1, $4b04(a4)
0101391e  2123              move.l   -(a3), -(a0)
01013920  5845              addq.w   #$4, d5
01013922  5056              addq.w   #$8, (a6)
01013924  2c3a3583          move.l   $1016ea9(pc), d6
01013928  22354570962d3566  move.l   $962d3566(a5, invalid.w), d1
01013930  5622              addq.b   #$3, -(a2)
01013932  385d              movea.w  (a5)+, a4
01013934  7d86              dc.w     $7d86
01013936  2e5a              movea.l  (a2)+, a7
01013938  7422              moveq    #$22, d2
0101393a  4146              dc.w     $4146
0101393c  98306622          sub.b    $22(a0, d6.w), d4
01013940  5670882f          addq.w   #$3, $2f(a0, a0.l)
01013944  6671              bne.b    $10139b7
01013946  21353873          move.l   $73(a5, d3.l), -(a0)
0101394a  932f554d          sub.b    d1, $554d(a7)
0101394e  2138417d          move.l   $417d.w, -(a0)
01013952  8856              or.w     (a6), d4
01013954  2e62              movea.l  -(a2), a7
01013956  5e21              addq.b   #$7, -(a1)
01013958  405d              negx.w   (a5)+
0101395a  7d66              dc.w     $7d66
0101395c  562e5648          addq.b   #$3, $5648(a6)
01013960  21514685          move.l   (a1), $4685(a0)
01013964  6b15              bmi.b    $101397b
01013966  2e58              movea.l  (a0)+, a7
01013968  7135              dc.w     $7135
0101396a  033b3e66          btst.l   d1, $10139d2(pc, d3.l)
0101396e  0b2d353b          btst.l   d5, $353b(a5)
01013972  7135              dc.w     $7135
01013974  083c              dc.w     $083c
01013976  3682              move.w   d2, (a3)
01013978  1066              dc.w     $1066
0101397a  2c384674          move.l   $4674.w, d6
0101397e  39402186          move.w   d0, $2186(a4)
01013982  213a2b3a          move.l   $10164be(pc), -(a0)
01013986  546c9238          addq.w   #$2, -$6dc8(a4)
0101398a  4174              dc.w     $4174
0101398c  21455621          move.l   d5, $5621(a0)
01013990  6629              bne.b    $10139bb
01013992  35660870          move.w   -(a6), $870(a2)
01013996  83413a83          pack     d1, d1, #$3a83
0101399a  213a5a56          move.l   $10193f2(pc), -(a0)
0101399e  3a56              movea.w  (a6), a5
010139a0  27356b2273214046  move.l   ([$7321, a5, d6.l * 2], $4046), -(a3)
010139a8  8321              or.b     d1, -(a1)
010139aa  3689              move.w   a1, (a3)
010139ac  2246              movea.l  d6, a1
010139ae  6c24              bge.b    $10139d4
010139b0  356c5a213a56      move.w   $5a21(a4), $3a56(a2)
010139b6  7b21              dc.w     $7b21
010139b8  4147              dc.w     $4147
010139ba  23946821          move.l   (a4), $21(a1, d6.l)
010139be  19386f6b          move.b   $6f6b.w, -(a4)
010139c2  5603              addq.b   #$3, d3
010139c4  216c58832156      move.l   $5883(a4), $2156(a0)
010139ca  7023              moveq    #$23, d0
010139cc  506c6b19          addq.w   #$8, $6b19(a4)
010139d0  2220              move.l   -(a0), d1
010139d2  1b23              move.b   -(a3), -(a5)
010139d4  0f46              bchg.b   d7, d6
010139d6  6c84              bge.b    $101395c
010139d8  2258              movea.l  (a0)+, a1
010139da  7023              moveq    #$23, d0
010139dc  3b8b6c35          move.w   a3, $35(a5, d6.l)
010139e0  5621              addq.b   #$3, -(a1)
010139e2  2003              move.l   d3, d0
010139e4  2241              movea.l  d1, a1
010139e6  356c8e922256      move.w   -$716e(a4), $2256(a2)
010139ec  7224              moveq    #$24, d1
010139ee  7d77              dc.w     $7d77
010139f0  356b5a59215b      move.w   $5a59(a3), $215b(a2)
010139f6  5d35787d          subq.b   #$6, $7d(a5, d7.l)
010139fa  5622              addq.b   #$3, -(a2)
010139fc  5349              subq.w   #$1, a1
010139fe  243b9843          move.l   $1013a43(pc, a1.l), d2
01013a02  6d6b              blt.b    $1013a6f
01013a04  356f8e932352      move.w   -$716d(a7), $2352(a2)
01013a0a  1325              move.b   -(a5), -(a1)
01013a0c  4a6c8b6c          tst.w    -$7494(a4)
01013a10  6b35              bmi.b    $1013a47
01013a12  6c70              bge.b    $1013a84
01013a14  7870              moveq    #$70, d4
01013a16  9424              sub.b    -(a4), d2
01013a18  063a              dc.w     $063a
01013a1a  2647              movea.l  d7, a3
01013a1c  9879437e9788      sub.w    $437e9788.l, d4
01013a22  2507              move.l   d7, -(a2)
01013a24  5a27              addq.b   #$5, -(a7)
01013a26  4698              not.l    (a0)+
01013a28  94709897          sub.w    -$69(a0, a1.l), d2
01013a2c  6626              bne.b    $1013a54
01013a2e  0a3a              dc.w     $0a3a
01013a30  33663533          move.w   -(a6), $3533(a1)
01013a34  6b35              bmi.b    $1013a6b
01013a36  33663533          move.w   -(a6), $3533(a1)
01013a3a  6b21              bmi.b    $1013a5d
01013a3c  5632893476573277  addq.b   #$3, $76573277(a2, a0.l)
01013a44  4045              negx.w   d5
01013a46  324f              movea.w  a7, a1
01013a48  5a08              dc.w     $5a08
01013a4a  3249              movea.w  a1, a1
01013a4c  6603              bne.b    $1013a51
01013a4e  6631              bne.b    $1013a81
01013a50  3e65              movea.w  -(a5), a7
01013a52  1a5a              dc.w     $1a5a
01013a54  213b9892          move.l   $10139e8(pc, a1.l), -(a0)
01013a58  217b2c368610      move.l   $1013a90(pc, d2.l), -$79f0(a0)
01013a5e  4156              dc.w     $4156
01013a60  3a6c7398          movea.w  $7398(a4), a5
01013a64  7b3b              dc.w     $7b3b
01013a66  9a83              sub.l    d3, d5
01013a68  3b9a2335921c385d  move.w   (a2)+, ([$921c385d, a5], d2.w * 2)
01013a70  665a              bne.b    $1013acc
01013a72  5f6c7d95          subq.w   #$7, $7d95(a4)
01013a76  9b95              sub.l    d5, (a5)
01013a78  9b83              subx.l   d3, d5
01013a7a  2121              move.l   -(a1), -(a0)
01013a7c  93352141          sub.b    d1, ([a5])
01013a80  1f41485a          move.b   d1, $485a(a7)
01013a84  4768              dc.w     $4768
01013a86  6e89              bgt.b    $1013a11
01013a88  686d              bvc.b    $1013af7
01013a8a  706c              moveq    #$6c, d0
01013a8c  8321              or.b     d1, -(a1)
01013a8e  214c385a          move.l   a4, $385a(a0)
01013a92  21622138          move.l   -(a2), $2138(a0)
01013a96  2111              move.l   (a1), -(a0)
01013a98  1e23              move.b   -(a3), d7
01013a9a  831e              or.b     d1, (a6)+
01013a9c  2235218321213a6c  move.l   ([, d2.w], $21213a6c), d1
01013aa4  6821              bvc.b    $1013ac7
01013aa6  1e0e              dc.w     $1e0e
01013aa8  120e              dc.w     $120e
01013aaa  041d0283          subi.b   #$83, (a5)+
01013aae  1d01              move.b   d1, -(a6)
01013ab0  04218321          subi.b   #$21, -(a1)
01013ab4  2135706b          move.l   $6b(a5, d7.w), -(a0)
01013ab8  5a1d              addq.b   #$5, (a5)+
01013aba  0009              dc.w     $0009
01013abc  1b04              move.b   d4, -(a5)
01013abe  1d02              move.b   d2, -(a6)
01013ac0  510d              dc.w     $510d
01013ac2  0104              btst.l   d0, d4
01013ac4  00562122          ori.w    #$2122, (a6)
01013ac8  728b              moveq    #$8b, d1
01013aca  411d              chk.l    (a5)+, d0
01013acc  00060304          ori.b    #$4, d6
01013ad0  1d02              move.b   d2, -(a6)
01013ad2  7f0d              dc.w     $7f0d
01013ad4  0103              btst.l   d0, d3
01013ad6  00562122          ori.w    #$2122, (a6)
01013ada  3e95              move.w   (a5), (a7)
01013adc  6c61              bge.b    $1013b3f
01013ade  00060304          ori.b    #$4, d6
01013ae2  1e23              move.b   -(a3), d7
01013ae4  811e              or.b     d0, (a6)+
01013ae6  230e              move.l   a6, -(a1)
01013ae8  5621              addq.b   #$3, -(a1)
01013aea  2235978b8f00060c  move.l   ([, a1.w * 8], $8f00060c), d1
01013af2  0521              btst.l   d2, -(a1)
01013af4  5c83              addq.l   #$6, d3
01013af6  215c2183          move.l   (a4)+, $2183(a0)
01013afa  2123              move.l   -(a3), -(a0)
01013afc  4a95              tst.l    (a5)
01013afe  6221              bhi.b    $1013b21
01013b00  384e              movea.w  a6, a4
01013b02  11428742          move.b   d2, -$78be(a0)
01013b06  5a83              addq.l   #$5, d3
01013b08  2124              move.l   -(a4), -(a0)
01013b0a  7d90              dc.w     $7d90
01013b0c  213d              dc.w     $213d
01013b0e  8811              or.b     (a1), d4
01013b10  586e8468          addq.w   #$4, -$7b98(a6)
01013b14  6d70              blt.b    $1013b86
01013b16  4183              chk.w    d3, d0
01013b18  2124              move.l   -(a4), -(a0)
01013b1a  35914149          move.w   (a1), ([a2])
01013b1e  8711              or.b     d3, (a1)
01013b20  697a              bvs.b    $1013b9c
01013b22  89697a6c          or.w     d4, $7a6c(a1)
01013b26  8321              or.b     d1, -(a1)
01013b28  265a              movea.l  (a2)+, a3
01013b2a  605d              bra.b    $1013b89
01013b2c  4777              dc.w     $4777
01013b2e  8d95              or.l     d6, (a5)
01013b30  778c              dc.w     $778c
01013b32  8e8b              dc.w     $8e8b
01013b34  8321              or.b     d1, -(a1)
01013b36  25356c73          move.l   $73(a5, d6.l), -(a2)
01013b3a  5d47              subq.w   #$6, d7
01013b3c  959b              sub.l    d2, (a3)+
01013b3e  959b              sub.l    d2, (a3)+
01013b40  8321              or.b     d1, -(a1)
01013b42  2536787e          move.l   $7e(a6, d7.l), -(a2)
01013b46  463b              dc.w     $463b
01013b48  9a83              sub.l    d3, d5
01013b4a  3b9a23253b98      move.w   (a2)+, ([$3b98, a5], d2.w * 2)
01013b50  9321              sub.b    d1, -(a1)
01013b52  7c35              moveq    #$35, d6
01013b54  9997              sub.l    d4, (a7)
01013b56  282a4001          move.l   $4001(a2), d4
01013b5a  0e56              dc.w     $0e56
01013b5c  272a4e19          move.l   $4e19(a2), -(a3)
01013b60  06418327          addi.w   #$8327, d1
01013b64  2a4e              movea.l  a6, a5
01013b66  1903              move.b   d3, -(a4)
01013b68  3a83              move.w   d3, (a5)
01013b6a  272a4e19          move.l   $4e19(a2), -(a3)
01013b6e  06418327          addi.w   #$8327, d1
01013b72  2a4e              movea.l  a6, a5
01013b74  1903              move.b   d3, -(a4)
01013b76  3a83              move.w   d3, (a5)
01013b78  272a4e19          move.l   $4e19(a2), -(a3)
01013b7c  06418327          addi.w   #$8327, d1
01013b80  2a4e              movea.l  a6, a5
01013b82  1903              move.b   d3, -(a4)
01013b84  3a83              move.w   d3, (a5)
01013b86  272a4e19          move.l   $4e19(a2), -(a3)
01013b8a  06418327          addi.w   #$8327, d1
01013b8e  2a4a              movea.l  a2, a5
01013b90  9a282a3d          sub.b    $2a3d(a0), d5
01013b94  3f08              move.w   a0, -(a7)
01013b96  7328              dc.w     $7328
01013b98  2a3d              dc.w     $2a3d
01013b9a  5508              dc.w     $5508
01013b9c  89282a3d          or.b     d4, $2a3d(a0)
01013ba0  3f0c              move.w   a4, -(a7)
01013ba2  6428              bcc.b    $1013bcc
01013ba4  2a3d              dc.w     $2a3d
01013ba6  5518              subq.b   #$2, (a0)+
01013ba8  17282a3d          move.b   $2a3d(a0), -(a3)
01013bac  4044              negx.w   d4
01013bae  3b282a40          move.w   $2a40(a0), -(a5)
01013bb2  0110              btst.l   d0, (a0)
01013bb4  5627              addq.b   #$3, -(a7)
01013bb6  2a4e              movea.l  a6, a5
01013bb8  1906              move.b   d6, -(a4)
01013bba  4183              chk.w    d3, d0
01013bbc  272a4e19          move.l   $4e19(a2), -(a3)
01013bc0  033a8327          btst.l   d1, $100bee9(pc)
01013bc4  2a50              movea.l  (a0), a5
01013bc6  5635738327000000  addq.b   #$3, ([, d7.w * 2], $27000000)

; ---- gap 01013bd8..01013d3e (359 bytes) ----
01013bd8  003f              dc.w     $003f
01013bda  9200              sub.b    d0, d1
01013bdc  0100              btst.l   d0, d0
01013bde  02000301          andi.b   #$1, d0
01013be2  0102              btst.l   d0, d2
01013be4  0103              btst.l   d0, d3
01013be6  0104              btst.l   d0, d4
01013be8  0105              btst.l   d0, d5
01013bea  0106              btst.l   d0, d6
01013bec  01080109          movep.w  $109(a0), d0
01013bf0  010a010b          movep.w  $10b(a2), d0
01013bf4  010e0110          movep.w  $110(a6), d0
01013bf8  0111              btst.l   d0, (a1)
01013bfa  0115              btst.l   d0, (a5)
01013bfc  0116              btst.l   d0, (a6)
01013bfe  0117              btst.l   d0, (a7)
01013c00  0119              btst.l   d0, (a1)+
01013c02  012a0140          btst.l   d0, $140(a2)
01013c06  0144              bchg.b   d0, d4
01013c08  0145              bchg.b   d0, d5
01013c0a  0146              bchg.b   d0, d6
01013c0c  0147              bchg.b   d0, d7
01013c0e  0149014a          movep.l  $14a(a1), d0
01013c12  0150              bchg.b   d0, (a0)
01013c14  0151              bchg.b   d0, (a1)
01013c16  0152              bchg.b   d0, (a2)
01013c18  0154              bchg.b   d0, (a4)
01013c1a  0155              bchg.b   d0, (a5)
01013c1c  0155              bchg.b   d0, (a5)
01013c1e  02550355          andi.w   #$355, (a5)
01013c22  04550555          subi.w   #$555, (a5)
01013c26  06550755          addi.w   #$755, (a5)
01013c2a  0855              dc.w     $0855
01013c2c  0955              bchg.b   d4, (a5)
01013c2e  0a550b55          eori.w   #$b55, (a5)
01013c32  0c550d55          cmpi.w   #$d55, (a5)
01013c36  0e55              dc.w     $0e55
01013c38  0f55              bchg.b   d7, (a5)
01013c3a  1255              dc.w     $1255
01013c3c  13551455          move.b   (a5), $1455(a1)
01013c40  15560156          move.b   (a6), $156(a2)
01013c44  02570158          andi.w   #$158, (a7)
01013c48  0159              bchg.b   d0, (a1)+
01013c4a  015a              bchg.b   d0, (a2)+
01013c4c  015b              bchg.b   d0, (a3)+
01013c4e  015d              bchg.b   d0, (a5)+
01013c50  015e              bchg.b   d0, (a6)+
01013c52  015f              bchg.b   d0, (a7)+
01013c54  0161              bchg.b   d0, -(a1)
01013c56  0164              bchg.b   d0, -(a4)
01013c58  0165              bchg.b   d0, -(a5)
01013c5a  0166              bchg.b   d0, -(a6)
01013c5c  0166              bchg.b   d0, -(a6)
01013c5e  02660467          andi.w   #$467, -(a6)
01013c62  0169016a          bchg.b   d0, $16a(a1)
01013c66  016b016d          bchg.b   d0, $16d(a3)
01013c6a  016e016f          bchg.b   d0, $16f(a6)
01013c6e  017501760179017a  bchg.b   d0, ([$179017a, a5])
01013c76  017d              dc.w     $017d
01013c78  017f              dc.w     $017f
01013c7a  0180              bclr.b   d0, d0
01013c7c  0184              bclr.b   d0, d4
01013c7e  0190              bclr.b   d0, (a0)
01013c80  0191              bclr.b   d0, (a1)
01013c82  0194              bclr.b   d0, (a4)
01013c84  0195              bclr.b   d0, (a5)
01013c86  0195              bclr.b   d0, (a5)
01013c88  029601990199      andi.l   #$1990199, (a6)
01013c8e  0299039a019b      andi.l   #$39a019b, (a1)+
01013c94  019d              bclr.b   d0, (a5)+
01013c96  019e              bclr.b   d0, (a6)+
01013c98  019f              bclr.b   d0, (a7)+
01013c9a  01a0              bclr.b   d0, -(a0)
01013c9c  01a1              bclr.b   d0, -(a1)
01013c9e  01a4              bclr.b   d0, -(a4)
01013ca0  01a5              bclr.b   d0, -(a5)
01013ca2  01a5              bclr.b   d0, -(a5)
01013ca4  02a601a701a8      andi.l   #$1a701a8, -(a6)
01013caa  01a901aa          bclr.b   d0, $1aa(a1)
01013cae  01aa02aa          bclr.b   d0, $2aa(a2)
01013cb2  03aa04ab          bclr.b   d1, $4ab(a2)
01013cb6  01ad01ae          bclr.b   d0, $1ae(a5)
01013cba  01af01b5          bclr.b   d0, $1b5(a7)
01013cbe  01ba              dc.w     $01ba
01013cc0  01bb              dc.w     $01bb
01013cc2  01bb              dc.w     $01bb
01013cc4  03bd              dc.w     $03bd
01013cc6  01be              dc.w     $01be
01013cc8  01bf              dc.w     $01bf
01013cca  01c0              bset.b   d0, d0
01013ccc  01c4              bset.b   d0, d4
01013cce  01d5              bset.b   d0, (a5)
01013cd0  01d9              bset.b   d0, (a1)+
01013cd2  01df              bset.b   d0, (a7)+
01013cd4  01e5              bset.b   d0, -(a5)
01013cd6  01e6              bset.b   d0, -(a6)
01013cd8  01e901ea          bset.b   d0, $1ea(a1)
01013cdc  01eb01ee          bset.b   d0, $1ee(a3)
01013ce0  01ee02ee          bset.b   d0, $2ee(a6)
01013ce4  03ef01f0          bset.b   d1, $1f0(a7)
01013ce8  01f101f201f501f901fa  bset.b   d0, ([$1f501f9], $1fa)
01013cf2  01fb              dc.w     $01fb
01013cf4  01fd              dc.w     $01fd
01013cf6  01fe              dc.w     $01fe
01013cf8  01ff              dc.w     $01ff
01013cfa  01ff              dc.w     $01ff
01013cfc  03ff              dc.w     $03ff
01013cfe  04263369          subi.b   #$69, -(a6)
01013d02  651a              bcs.b    $1013d1e
01013d04  6558              bcs.b    $1013d5e
01013d06  2826              move.l   -(a6), d4
01013d08  6820              bvc.b    $1013d2a
01013d0a  116d71292545      move.b   $7129(a5), $2545(a0)
01013d10  0746              bchg.b   d3, d6
01013d12  4a2b2433          tst.b    $2433(a3)
01013d16  55394c2c2444      subq.b   #$2, $4c2c2444.l
01013d1c  46682d24          not.w    $2d24(a0)
01013d20  55762345          subq.w   #$2, ([a6])
01013d24  6a27              bpl.b    $1013d4d
01013d26  23360c7d          move.l   $7d(a6, d0.l), -(a1)
01013d2a  21456952          move.l   d5, $6952(a0)
01013d2e  216a6824233e      move.l   $6824(a2), $233e(a0)
01013d34  3a21              move.w   -(a1), d5
01013d36  6955              bvs.b    $1013d8d
01013d38  201d              move.l   (a5)+, d0
01013d3a  4569              dc.w     $4569
01013d3c  201c              move.l   (a4)+, d0
01013d3e  1169              dc.w     $1169

; ---- gap 01013d56..01013f5d (520 bytes) ----
01013d56  4569              dc.w     $4569
01013d58  6d73              blt.b    $1013dcd
01013d5a  7285              moveq    #$85, d1
01013d5c  8163              or.w     d0, -(a3)
01013d5e  4569              dc.w     $4569
01013d60  3822              move.w   -(a2), d4
01013d62  22376e33          move.l   $33(a7, d6.l), d1
01013d66  5517              subq.b   #$2, (a7)
01013d68  6982              bvs.b    $1013cec
01013d6a  8f80908b          unpk     d0, d7, #$908b
01013d6e  6a64              bpl.b    $1013dd4
01013d70  2122              move.l   -(a2), -(a0)
01013d72  4071633863858f8a  negx.w   $63858f8a(a1, d6.w * 2)
01013d7a  2369768e6918      move.l   $768e(a1), $6918(a1)
01013d80  2122              move.l   -(a2), -(a0)
01013d82  3d4b2069          move.w   a3, $2069(a6)
01013d86  808e              dc.w     $808e
01013d88  27468b15          move.l   d6, -$74eb(a3)
01013d8c  5520              subq.b   #$2, -(a0)
01013d8e  22387145          move.l   $7145.w, d1
01013d92  6d8b              blt.b    $1013d1f
01013d94  29491d3f          move.l   a1, $1d3f(a4)
01013d98  2022              move.l   -(a2), d0
01013d9a  5b7a              dc.w     $5b7a
01013d9c  4577              dc.w     $4577
01013d9e  5529337b          subq.b   #$2, $337b(a1)
01013da2  5820              addq.b   #$4, -(a0)
01013da4  22383639          move.l   $3639.w, d1
01013da8  8a2b4033          or.b     $4033(a3), d5
01013dac  2022              move.l   -(a2), d0
01013dae  5744              subq.w   #$3, d4
01013db0  4955              dc.w     $4955
01013db2  2b38337a          move.l   $337a.w, -(a5)
01013db6  2210              move.l   (a0), d1
01013db8  6d6e              blt.b    $1013e28
01013dba  2c336355          move.l   ([a3]), d6
01013dbe  213617777d2d5871  move.l   ([$7d2d5871, a6]), -(a0)
01013dc6  2140208f          move.l   d0, $208f(a0)
01013dca  2e1f              move.l   (a7)+, d7
01013dcc  2021              move.l   -(a1), d0
01013dce  5566              subq.w   #$2, -(a6)
01013dd0  7f2e              dc.w     $7f2e
01013dd2  52372033          addq.b   #$1, $33(a7, d2.w)
01013dd6  37708a2e534c      move.w   $2e(a0, a0.l), $534c(a3)
01013ddc  20374077          move.l   $77(a7, d4.w), d0
01013de0  7f55              dc.w     $7f55
01013de2  2d635d20          move.l   -(a3), $5d20(a6)
01013de6  3f5b7763          move.w   (a3)+, $7763(a7)
01013dea  552d5547          subq.b   #$2, $5547(a5)
01013dee  2055              movea.l  (a5), a0
01013df0  457c              dc.w     $457c
01013df2  683f              bvc.b    $1013e33
01013df4  2d576e34          move.l   (a7), $6e34(a6)
01013df8  6d3c              blt.b    $1013e36
01013dfa  6538              bcs.b    $1013e34
01013dfc  2c33396e3447      move.l   ([$3447, a3]), d6
01013e02  357a20632b36      move.w   $1015e67(pc), $2b36(a2)
01013e08  1471              dc.w     $1471
01013e0a  360a              move.w   a2, d3
01013e0c  4e20              dc.w     $4e20
01013e0e  891c              or.b     d4, (a4)+
01013e10  0b2a3854          btst.l   d5, $3854(a2)
01013e14  4589              dc.w     $4589
01013e16  360f              move.w   a7, d3
01013e18  7120              dc.w     $7120
01013e1a  4e500363          link.w   a0, #$363
01013e1e  28336320397a      move.l   $397a(a3, d6.w * 2), d4
01013e24  3d07              move.w   d7, -(a6)
01013e26  7a20              moveq    #$20, d5
01013e28  3c51              movea.w  (a1), a6
01013e2a  20385526          move.l   $5526.w, d0
01013e2e  3368205b3c20      move.w   $205b(a0), $3c20(a1)
01013e34  3f20              move.w   -(a0), -(a7)
01013e36  5520              subq.b   #$2, -(a0)
01013e38  357a21456923      move.w   $1015f7f(pc), $6923(a2)
01013e3e  336958033845      move.w   $5803(a1), $3845(a1)
01013e44  4720              chk.l    -(a0), d3
01013e46  4122              chk.l    -(a2), d0
01013e48  6365              bls.b    $1013eaf
01013e4a  21366c68          move.l   $68(a6, d6.l), -(a0)
01013e4e  5520              subq.b   #$2, -(a0)
01013e50  03696d55          bchg.b   d1, $6d55(a1)
01013e54  2055              movea.l  (a5), a0
01013e56  6d22              blt.b    $1013e7a
01013e58  4569              dc.w     $4569
01013e5a  6820              bvc.b    $1013e7c
01013e5c  1c10              move.b   (a0), d6
01013e5e  2103              move.l   d3, -(a0)
01013e60  21383369          move.l   $3369.w, -(a0)
01013e64  8521              or.b     d2, -(a1)
01013e66  5746              subq.w   #$3, d6
01013e68  2239826a5210      move.l   $826a5210.l, d1
01013e6e  2115              move.l   (a5), -(a0)
01013e70  2041              movea.l  d1, a0
01013e72  33858921556f      move.w   d5, ([$556f, a1, a0.l])
01013e78  237772695437      move.l   $69(a7, d7.w), $5437(a1)
01013e7e  5951              subq.w   #$4, (a1)
01013e80  585b              addq.w   #$4, (a3)+
01013e82  6943              bvs.b    $1013ec7
01013e84  7755              dc.w     $7755
01013e86  21556f23          move.l   (a5), $6f23(a0)
01013e8a  3c8f              move.w   a7, (a6)
01013e8c  7355              dc.w     $7355
01013e8e  6b55              bmi.b    $1013ee5
01013e90  6b5c              bmi.b    $1013eee
01013e92  8a22              or.b     -(a2), d5
01013e94  5748              subq.w   #$3, a0
01013e96  2449              movea.l  a1, a2
01013e98  8e7b6b55          or.w     ([$1013e9apc]), d7
01013e9c  6d73              blt.b    $1013f11
01013e9e  7769              dc.w     $7769
01013ea0  23556f25          move.l   (a5), $6f25(a1)
01013ea4  4680              not.l    d0
01013ea6  7469              moveq    #$69, d2
01013ea8  778e              dc.w     $778e
01013eaa  8a24              or.b     -(a4), d5
01013eac  556e2645          subq.w   #$2, $2645(a6)
01013eb0  9080              sub.l    d0, d0
01013eb2  8f63              or.w     d7, -(a3)
01013eb4  25584631          move.l   (a0)+, $4631(a2)
01013eb8  6319              bls.b    $1013ed3
01013eba  31671031          move.w   -(a7), $1031(a0)
01013ebe  6008              bra.b    $1013ec8
01013ec0  31621055          move.w   -(a2), $1055(a0)
01013ec4  307a3267          movea.w  $101712d(pc), a0
01013ec8  5630653f4430455833304563  addq.b   #$3, ([$44304558, a0], d6.w * 4, $33304563)
01013ed4  2063              movea.l  -(a3), a0
01013ed6  2f3963205520      move.l   $63205520.l, -(a7)
01013edc  398f8920752b      move.w   a7, $752b(a4, a0.l)
01013ee2  357f              dc.w     $357f
01013ee4  3f1d              move.w   (a5)+, -(a7)
01013ee6  55386970          subq.b   #$2, $6970.w
01013eea  8f753990          or.w     d7, (d3.l)
01013eee  7a39              moveq    #$39, d5
01013ef0  9022              sub.b    -(a2), d0
01013ef2  338b37061b63      move.w   a3, ([a1], d3.w * 8, $1b63)
01013ef8  585e              addq.w   #$4, (a6)+
01013efa  6977              bvs.b    $1013f73
01013efc  8c91              or.l     (a1), d6
01013efe  8c91              or.l     (a1), d6
01013f00  7a20              moveq    #$20, d5
01013f02  208e              move.l   a6, (a0)
01013f04  5500              subq.b   #$2, d0
01013f06  401e              negx.b   (a6)+
01013f08  4047              negx.w   d7
01013f0a  5846              addq.w   #$4, d6
01013f0c  656b              bcs.b    $1013f79
01013f0e  8065              or.w     -(a5), d0
01013f10  6a6d              bpl.b    $1013f7f
01013f12  697a              bvs.b    $1013f8e
01013f14  2020              move.l   -(a0), d0
01013f16  4f67              dc.w     $4f67
01013f18  1620              move.b   -(a0), d3
01013f1a  6120              bsr.b    $1013f3c
01013f1c  3720              move.w   -(a0), -(a3)
01013f1e  121d              move.b   (a5)+, d1
01013f20  227a1d21          movea.l  $1015c43(pc), a1
01013f24  3320              move.w   -(a0), -(a1)
01013f26  7a20              moveq    #$20, d5
01013f28  203c7f1e201d      move.l   #$7f1e201d, d0
01013f2e  0f13              btst.l   d7, (a3)
01013f30  0f04              btst.l   d7, d4
01013f32  1c02              move.b   d2, d6
01013f34  7a1c              moveq    #$1c, d5
01013f36  0104              btst.l   d0, d4
01013f38  207a2020          movea.l  $1015f5a(pc), a0
01013f3c  358b2058          move.w   a3, $58(a2, d2.w)
01013f40  1c00              move.b   d0, d6
01013f42  0917              btst.l   d4, (a7)
01013f44  041c0250          subi.b   #$50, (a4)+
01013f48  0e01              dc.w     $0e01
01013f4a  04005520          subi.b   #$20, d0
01013f4e  218d5b40          move.l   a5, (a0, invalid.w)
01013f52  1c00              move.b   d0, d6
01013f54  0603041c          addi.b   #$1c, d3
01013f58  02780e010300      andi.w   #$e01, $300.w

; ---- gap 01013f66..01013fbd (88 bytes) ----
01013f66  0603041d          addi.b   #$1d, d3
01013f6a  22791d220f55      movea.l  $1d220f55.l, a1
01013f70  2021              move.l   -(a1), d0
01013f72  336982860006      move.w   -$7d7a(a1), $6(a1)
01013f78  0d05              btst.l   d6, d5
01013f7a  205a              movea.l  (a2)+, a0
01013f7c  7a20              moveq    #$20, d5
01013f7e  5a20              addq.b   #$5, -(a0)
01013f80  7a20              moveq    #$20, d5
01013f82  2249              movea.l  a1, a1
01013f84  8c61              or.w     -(a1), d6
01013f86  20374d12427e      move.l   ([a7, d4.l * 4], $427e), d0
01013f8c  4258              clr.w    (a0)+
01013f8e  7a20              moveq    #$20, d5
01013f90  237787203b7f1257  move.l   $3b7f(a7, a0.w * 8), $1257(a1)
01013f98  6b7b              bmi.b    $1014015
01013f9a  656a              bcs.b    $1014006
01013f9c  6d40              blt.b    $1013fde
01013f9e  7a20              moveq    #$20, d5
01013fa0  23338840          move.l   $40(a3, a0.l), -(a1)
01013fa4  487e              dc.w     $487e
01013fa6  1266              dc.w     $1266
01013fa8  7480              moveq    #$80, d2
01013faa  6674              bne.b    $1014020
01013fac  697a              bvs.b    $1014028
01013fae  2025              move.l   -(a5), d0
01013fb0  585f              addq.w   #$4, (a7)+
01013fb2  5b46              subq.w   #$5, d6
01013fb4  7284              moveq    #$84, d1
01013fb6  8c728385          or.w     ([], a0.w * 2), d6
01013fba  827a2000          or.w     $1015fbc(pc), d1

; ---- gap 01013fc8..010143b5 (1006 bytes) ----
01013fc8  003f              dc.w     $003f
01013fca  9300              subx.b   d0, d1
01013fcc  0100              btst.l   d0, d0
01013fce  02000301          andi.b   #$1, d0
01013fd2  0102              btst.l   d0, d2
01013fd4  0103              btst.l   d0, d3
01013fd6  0104              btst.l   d0, d4
01013fd8  0105              btst.l   d0, d5
01013fda  0107              btst.l   d0, d7
01013fdc  0108010e          movep.w  $10e(a0), d0
01013fe0  0110              btst.l   d0, (a0)
01013fe2  0111              btst.l   d0, (a1)
01013fe4  0111              btst.l   d0, (a1)
01013fe6  02120115          andi.b   #$15, (a2)
01013fea  0116              btst.l   d0, (a6)
01013fec  0117              btst.l   d0, (a7)
01013fee  0119              btst.l   d0, (a1)+
01013ff0  011a              btst.l   d0, (a2)+
01013ff2  0129012a          btst.l   d0, $12a(a1)
01013ff6  0140              bchg.b   d0, d0
01013ff8  0141              bchg.b   d0, d1
01013ffa  0144              bchg.b   d0, d4
01013ffc  0145              bchg.b   d0, d5
01013ffe  014a0150          movep.l  $150(a2), d0
01014002  0151              bchg.b   d0, (a1)
01014004  0154              bchg.b   d0, (a4)
01014006  0155              bchg.b   d0, (a5)
01014008  0155              bchg.b   d0, (a5)
0101400a  02550355          andi.w   #$355, (a5)
0101400e  04550555          subi.w   #$555, (a5)
01014012  06550755          addi.w   #$755, (a5)
01014016  0855              dc.w     $0855
01014018  0955              bchg.b   d4, (a5)
0101401a  0a550b55          eori.w   #$b55, (a5)
0101401e  0c550d55          cmpi.w   #$d55, (a5)
01014022  0e55              dc.w     $0e55
01014024  0f55              bchg.b   d7, (a5)
01014026  1255              dc.w     $1255
01014028  13551456          move.b   (a5), $1456(a1)
0101402c  0156              bchg.b   d0, (a6)
0101402e  02570158          andi.w   #$158, (a7)
01014032  0159              bchg.b   d0, (a1)+
01014034  0159              bchg.b   d0, (a1)+
01014036  025a015a          andi.w   #$15a, (a2)+
0101403a  025b015e          andi.w   #$15e, (a3)+
0101403e  015f              bchg.b   d0, (a7)+
01014040  0160              bchg.b   d0, -(a0)
01014042  0161              bchg.b   d0, -(a1)
01014044  0164              bchg.b   d0, -(a4)
01014046  0165              bchg.b   d0, -(a5)
01014048  0166              bchg.b   d0, -(a6)
0101404a  0166              bchg.b   d0, -(a6)
0101404c  02660469          andi.w   #$469, -(a6)
01014050  016a016b          bchg.b   d0, $16b(a2)
01014054  016d016e          bchg.b   d0, $16e(a5)
01014058  016f0175          bchg.b   d0, $175(a7)
0101405c  0179017a017e      bchg.b   d0, $17a017e.l
01014062  017f              dc.w     $017f
01014064  0180              bclr.b   d0, d0
01014066  0184              bclr.b   d0, d4
01014068  0185              bclr.b   d0, d5
0101406a  0186              bclr.b   d0, d6
0101406c  0190              bclr.b   d0, (a0)
0101406e  0194              bclr.b   d0, (a4)
01014070  0195              bclr.b   d0, (a5)
01014072  0195              bclr.b   d0, (a5)
01014074  029601970199      andi.l   #$1970199, (a6)
0101407a  0199              bclr.b   d0, (a1)+
0101407c  0299039a019b      andi.l   #$39a019b, (a1)+
01014082  019d              bclr.b   d0, (a5)+
01014084  019e              bclr.b   d0, (a6)+
01014086  019f              bclr.b   d0, (a7)+
01014088  01a0              bclr.b   d0, -(a0)
0101408a  01a5              bclr.b   d0, -(a5)
0101408c  01a6              bclr.b   d0, -(a6)
0101408e  01a7              bclr.b   d0, -(a7)
01014090  01a901aa          bclr.b   d0, $1aa(a1)
01014094  01aa02aa          bclr.b   d0, $2aa(a2)
01014098  03aa04ab          bclr.b   d1, $4ab(a2)
0101409c  01ad01ae          bclr.b   d0, $1ae(a5)
010140a0  01af01b0          bclr.b   d0, $1b0(a7)
010140a4  01b101b501b901ba  bclr.b   d0, ([$1b901ba], d0.w)
010140ac  01bb              dc.w     $01bb
010140ae  01bb              dc.w     $01bb
010140b0  03bd              dc.w     $03bd
010140b2  01be              dc.w     $01be
010140b4  01bf              dc.w     $01bf
010140b6  01c0              bset.b   d0, d0
010140b8  01c4              bset.b   d0, d4
010140ba  01d5              bset.b   d0, (a5)
010140bc  01d6              bset.b   d0, (a6)
010140be  01d9              bset.b   d0, (a1)+
010140c0  01df              bset.b   d0, (a7)+
010140c2  01e4              bset.b   d0, -(a4)
010140c4  01e5              bset.b   d0, -(a5)
010140c6  01e6              bset.b   d0, -(a6)
010140c8  01e901ea          bset.b   d0, $1ea(a1)
010140cc  01eb01ed          bset.b   d0, $1ed(a3)
010140d0  01ee01ee          bset.b   d0, $1ee(a6)
010140d4  02ee              dc.w     $02ee
010140d6  03ef01f2          bset.b   d1, $1f2(a7)
010140da  01f501f901fa01fb  bset.b   d0, ([$1fa01fb])
010140e2  01fd              dc.w     $01fd
010140e4  01fe              dc.w     $01fe
010140e6  01fe              dc.w     $01fe
010140e8  02ff              dc.w     $02ff
010140ea  01ff              dc.w     $01ff
010140ec  02ff              dc.w     $02ff
010140ee  03ff              dc.w     $03ff
010140f0  04243064          subi.b   #$64, -(a4)
010140f4  6012              bra.b    $1014108
010140f6  3f572624          move.w   (a7), $2624(a7)
010140fa  6317              bls.b    $1014113
010140fc  36684827          movea.w  $4827(a0), a3
01014100  23433056          move.l   d3, $3056(a1)
01014104  6f29              ble.b    $101412f
01014106  223019686f2a      move.l   $6f2a(a0, invalid.w), d1
0101410c  2242              movea.l  d2, a1
0101410e  1189              dc.w     $1189
01014110  2b22              move.l   -(a2), -(a5)
01014112  536a2143          subq.w   #$1, $2143(a2)
01014116  6525              bcs.b    $101413d
01014118  2134387d          move.l   $7d(a4, d3.l), -(a0)
0101411c  1f436453          move.b   d3, $6453(a7)
01014120  1f656322          move.b   -(a5), $6322(a7)
01014124  213e              dc.w     $213e
01014126  6a1f              bpl.b    $1014147
01014128  6451              bcc.b    $101417b
0101412a  0f40              bchg.b   d7, d0
0101412c  4303              chk.l    d3, d1
0101412e  1e306421          move.b   $21(a0, d6.w), d7
01014132  2150881e          move.l   (a0), -$77e2(a0)
01014136  641e              bcc.b    $1014156
01014138  3e366636          move.w   $36(a6, d6.w), d7
0101413c  6463              bcc.b    $10141a1
0101413e  1e60              dc.w     $1e60
01014140  2020              move.l   -(a0), d0
01014142  3160361e          move.w   -(a0), $361e(a0)
01014146  4360              dc.w     $4360
01014148  38717082          movea.w  -$7e(a1, d7.w), a4
0101414c  5b65              subq.w   #$5, -(a5)
0101414e  3f13              move.w   (a3), -(a7)
01014150  2020              move.l   -(a0), d0
01014152  3463              movea.w  -(a3), a2
01014154  3053              movea.w  (a3), a0
01014156  3664              movea.w  -(a4), a3
01014158  826b908d          or.w     -$6f73(a3), d1
0101415c  6b8f              bmi.b    $10140ed
0101415e  8064              or.w     -(a4), d0
01014160  1c60              dc.w     $1c60
01014162  1f20              move.b   -(a0), -(a7)
01014164  3f6e5f366486      move.w   $5f36(a6), $6486(a7)
0101416a  8a6f216a          or.w     $216a(a7), d5
0101416e  8e30361f          or.b     $1f(a0, d3.w), d7
01014172  203f              dc.w     $203f
01014174  7016              moveq    #$16, d0
01014176  4386              chk.w    d6, d1
01014178  8d60              or.w     d6, -(a0)
0101417a  2444              movea.l  d4, a2
0101417c  6454              bcc.b    $10141d2
0101417e  1e20              move.b   -(a0), d7
01014180  3688              move.w   a0, (a3)
01014182  3e44              movea.w  d4, a7
01014184  8d60              or.w     d6, -(a0)
01014186  263a603e          move.l   $101a1c6(pc), d3
0101418a  1e20              move.b   -(a0), d7
0101418c  5a7942476327      addq.w   #$5, $42476327.l
01014192  307f              dc.w     $307f
01014194  1f20              move.b   -(a0), -(a7)
01014196  37647029          move.w   -(a4), $7029(a3)
0101419a  49301e20          chk.l    $20(a0, d1.l), d4
0101419e  5543              subq.w   #$2, d3
010141a0  7053              moveq    #$53, d0
010141a2  29363078          move.l   $78(a6, d3.w), -(a4)
010141a6  1f304268          move.b   $68(a0, d4.w), -(a7)
010141aa  8c2a305f          or.b     $305f(a2), d6
010141ae  1e1f              move.b   (a7)+, d7
010141b0  345a              movea.w  (a2)+, a2
010141b2  757d              dc.w     $757d
010141b4  2b4e481f          move.l   a6, $481f(a5)
010141b8  3f438f2c          move.w   d3, -$70d4(a7)
010141bc  1660              dc.w     $1660
010141be  1f536880          move.b   (a3), $6880(a7)
010141c2  2c60              movea.l  -(a0), a6
010141c4  691e              bvs.b    $10141e4
010141c6  3007              move.w   d7, d0
010141c8  6b8a              bmi.b    $1014154
010141ca  2c53              movea.l  (a3), a6
010141cc  491e              chk.l    (a6)+, d4
010141ce  330c              move.w   a4, -(a1)
010141d0  757c              dc.w     $757c
010141d2  532b605c          subq.b   #$1, $605c(a3)
010141d6  1e3d              dc.w     $1e3d
010141d8  197551532b53451e533e  move.b   ([a5], $2b53451e), $533e(a4)
010141e2  7b1e              dc.w     $7b1e
010141e4  3e2b5569          move.w   $5569(a3), d7
010141e8  31623a30          move.w   -(a2), $3a30(a0)
010141ec  362a3008          move.w   $3008(a2), d3
010141f0  6931              bvs.b    $1014223
010141f2  4532631e6029      chk.l    ([a2], d6.w * 2, $6029), d2
010141f8  420f              dc.w     $420f
010141fa  4835731e8a1e      nbcd.b   ([a5], d7.w * 2, $8a1e)
01014200  36283653          move.w   $3653(a0), d3
01014204  6088              bra.b    $101418e
01014206  343f              dc.w     $343f
01014208  6e1e              bgt.b    $1014228
0101420a  4b53              dc.w     $4b53
0101420c  1e60              dc.w     $1e60
0101420e  26306030          move.l   $30(a0, d6.w), d3
01014212  6878              bvc.b    $101428c
01014214  3f36781e          move.w   $1e(a6, d7.l), -(a7)
01014218  3a57              movea.w  (a7), a5
0101421a  533653243063      subq.b   #$1, $3063(a6, d5.w * 2)
01014220  175a6b1e          move.b   (a2)+, $6b1e(a3)
01014224  3e43              movea.w  d3, a7
01014226  781e              moveq    #$1e, d4
01014228  3280              move.w   d0, (a1)
0101422a  1e1d              move.b   (a5)+, d7
0101422c  15642130          move.b   -(a4), $2130(a2)
01014230  6457              bcc.b    $1014289
01014232  1e19              move.b   (a1)+, d7
01014234  4373              dc.w     $4373
01014236  1e3f              dc.w     $1e3f
01014238  4420              neg.b    -(a0)
0101423a  8a61              or.w     -(a1), d5
0101423c  1b0f              dc.w     $1b0f
0101423e  3467              movea.w  -(a7), a2
01014240  634f              bls.b    $1014291
01014242  1f606878          move.b   -(a0), $6878(a7)
01014246  1e53              dc.w     $1e53
01014248  6820              bvc.b    $101426a
0101424a  4c64              dc.w     $4c64
0101424c  5220              addq.b   #$1, -(a0)
0101424e  031f              btst.l   d1, (a7)+
01014250  1b07              move.b   d7, -(a5)
01014252  3643              movea.w  d3, a3
01014254  606b              bra.b    $10142c1
01014256  1f17              move.b   (a7), -(a7)
01014258  1120              move.b   -(a0), -(a0)
0101425a  3883              move.w   d3, (a4)
0101425c  5364              subq.w   #$1, -(a4)
0101425e  531e              subq.b   #$1, (a6)+
01014260  031f              btst.l   d1, (a7)+
01014262  1b10              move.b   (a0), -(a5)
01014264  3f64816e          move.w   -(a4), -$7e92(a7)
01014268  1f16              move.b   (a6), -(a7)
0101426a  3621              move.w   -(a1), d3
0101426c  7560              dc.w     $7560
0101426e  6463              bcc.b    $10142d3
01014270  571e              subq.b   #$3, (a6)+
01014272  5852              addq.w   #$4, (a2)
01014274  1a64              dc.w     $1a64
01014276  7170              dc.w     $7170
01014278  204f              movea.l  a7, a0
0101427a  5a21              addq.b   #$5, -(a1)
0101427c  3a80              move.w   d0, (a5)
0101427e  7165              dc.w     $7165
01014280  3065              movea.w  -(a5), a0
01014282  6336              bls.b    $10142ba
01014284  6486              bcc.b    $101420c
01014286  8920              or.b     d4, -(a0)
01014288  5546              subq.w   #$2, d6
0101428a  2244              movea.l  d4, a1
0101428c  8d836436          unpk     d3, d6, #$6436
01014290  6662              bne.b    $10142f4
01014292  758a              dc.w     $758a
01014294  21536a23          move.l   (a3), $6a23(a0)
01014298  448f              dc.w     $448f
0101429a  7144              dc.w     $7144
0101429c  7175              dc.w     $7175
0101429e  7464              moveq    #$64, d2
010142a0  8922              or.b     d4, -(a2)
010142a2  53692468          subq.w   #$1, $2468(a1)
010142a6  8f6b9160          or.w     d7, -$6ea0(a3)
010142aa  2357442f          move.l   (a7), $442f(a1)
010142ae  6038              bra.b    $10142e8
010142b0  2f63432f          move.l   -(a3), $432f(a7)
010142b4  6038              bra.b    $10142ee
010142b6  2f633653          move.l   -(a3), $3653(a7)
010142ba  2e80              move.l   d0, (a7)
010142bc  3053              movea.w  (a3), a0
010142be  2e6f5160          movea.l  $5160(a7), a7
010142c2  2e701b14          movea.l  (a0, d1.l * 2), a7
010142c6  2e4b              movea.l  a3, a7
010142c8  4e36              dc.w     $4e36
010142ca  2e46              movea.l  d6, a7
010142cc  1c30602d          move.b   $2d(a0, d6.w), d6
010142d0  39301e57          move.w   $57(a0, d1.l), -(a4)
010142d4  1e388f88          move.b   $8f88.w, d7
010142d8  1e73              dc.w     $1e73
010142da  29305a3e          move.l   $3e(a0, d5.l), -(a4)
010142de  3f533664          move.w   (a3), $3664(a7)
010142e2  6b8f              bmi.b    $1014273
010142e4  7338              dc.w     $7338
010142e6  91783891          sub.w    d0, $3891.w
010142ea  20307057          move.l   $57(a0, d7.w), d0
010142ee  345a              movea.w  (a2)+, a2
010142f0  6057              bra.b    $1014349
010142f2  5d64              subq.w   #$6, -(a4)
010142f4  758b              dc.w     $758b
010142f6  928b              sub.l    a3, d1
010142f8  92781e1e          sub.w    $1e1e.w, d1
010142fc  7461              moveq    #$61, d2
010142fe  1e3c0e3f          move.b   #$3f, d7
01014302  4557              dc.w     $4557
01014304  4461              neg.w    -(a1)
01014306  6680              bne.b    $1014288
01014308  6165              bsr.b    $101436f
0101430a  6864              bvc.b    $1014370
0101430c  781e              moveq    #$1e, d4
0101430e  1e4c              dc.w     $1e4c
01014310  6357              bls.b    $1014369
01014312  163c1e34          move.b   #$34, d3
01014316  1e11              move.b   (a1), d7
01014318  1c20              move.b   -(a0), d6
0101431a  781c              moveq    #$1c, d4
0101431c  1f301e78          move.b   $78(a0, d1.l), -(a7)
01014320  1e1e              move.b   (a6)+, d7
01014322  3a80              move.w   d0, (a5)
01014324  61000d12          bsr.w    $1015038
01014328  0c041b02          cmpi.b   #$2, d4
0101432c  781b              moveq    #$1b, d4
0101432e  0104              btst.l   d0, d4
01014330  1e78              dc.w     $1e78
01014332  1e1e              move.b   (a6)+, d7
01014334  328b              move.w   a3, (a1)
01014336  6318              bls.b    $1014350
01014338  0b00              btst.l   d5, d0
0101433a  0919              btst.l   d4, (a1)+
0101433c  041b024d          subi.b   #$4d, (a3)+
01014340  0b01              btst.l   d5, d1
01014342  0400531e          subi.b   #$1e, d0
01014346  1f8d              dc.w     $1f8d
01014348  830c1b00          sbcd     -(a4), -(a1), #$1b00
0101434c  0603041b          addi.b   #$1b, d3
01014350  02760b010300      andi.w   #$b01, (a6, d0.w * 2)
01014356  531e              subq.b   #$1, (a6)+
01014358  1f3a8b1e          move.b   $100ce78(pc), -(a7)
0101435c  3b00              move.w   d0, -(a5)
0101435e  0603041c          addi.b   #$1c, d3
01014362  20771c20          movea.l  $20(a7, d1.l), a0
01014366  0c531e1f          cmpi.w   #$1e1f, (a3)
0101436a  308d              move.w   a5, (a0)
0101436c  576c0006          subq.w   #$3, $6(a4)
01014370  0a051e59          eori.b   #$59, d5
01014374  781e              moveq    #$1e, d4
01014376  591e              subq.b   #$4, (a6)+
01014378  781e              moveq    #$1e, d4
0101437a  2046              movea.l  d6, a0
0101437c  613c              bsr.b    $10143ba
0101437e  1e344a11          move.b   $11(a4, d4.l), d7
01014382  417e              dc.w     $417e
01014384  4157              dc.w     $4157
01014386  781e              moveq    #$1e, d4
01014388  21646d1e          move.l   -(a4), $6d1e(a0)
0101438c  397f              dc.w     $397f
0101438e  1155667a          move.b   (a5), $667a(a0)
01014392  6165              bsr.b    $10143f9
01014394  683f              bvc.b    $10143d5
01014396  781e              moveq    #$1e, d4
01014398  2130873f467e116272806272  move.l   ([$467e1162, a0], a0.w * 8, $72806272), -(a0)
010143a4  6478              bcc.b    $101441e
010143a6  1e23              move.b   -(a3), d7
010143a8  575e              subq.w   #$3, (a6)+
010143aa  5a44              addq.w   #$5, d4
010143ac  7085              moveq    #$85, d0
010143ae  8b708486          or.w     d5, -$7a(a0, a0.w)
010143b2  83781e00          or.w     d1, $1e00.w

; ---- gap 010143c6..01014688 (707 bytes) ----
010143c6  0e00              dc.w     $0e00
010143c8  0f00              btst.l   d7, d0
010143ca  1101              move.b   d1, -(a0)
010143cc  0102              btst.l   d0, d2
010143ce  0102              btst.l   d0, d2
010143d0  02030105          andi.b   #$5, d3
010143d4  0106              btst.l   d0, d6
010143d6  0107              btst.l   d0, d7
010143d8  0108010a          movep.w  $10a(a0), d0
010143dc  010b010d          movep.w  $10d(a3), d0
010143e0  010e010f          movep.w  $10f(a6), d0
010143e4  0110              btst.l   d0, (a0)
010143e6  0111              btst.l   d0, (a1)
010143e8  0114              btst.l   d0, (a4)
010143ea  0115              btst.l   d0, (a5)
010143ec  0116              btst.l   d0, (a6)
010143ee  0119              btst.l   d0, (a1)+
010143f0  011f              btst.l   d0, (a7)+
010143f2  0120              btst.l   d0, -(a0)
010143f4  0126              btst.l   d0, -(a6)
010143f6  012a012b          btst.l   d0, $12b(a2)
010143fa  012f0133          btst.l   d0, $133(a7)
010143fe  0135013d013f0140  btst.l   d0, ([$13f0140, a5], d0.w)
01014406  0148014a          movep.l  $14a(a0), d0
0101440a  014e014f          movep.l  $14f(a6), d0
0101440e  0150              bchg.b   d0, (a0)
01014410  0151              bchg.b   d0, (a1)
01014412  0152              bchg.b   d0, (a2)
01014414  0154              bchg.b   d0, (a4)
01014416  0155              bchg.b   d0, (a5)
01014418  0155              bchg.b   d0, (a5)
0101441a  02550355          andi.w   #$355, (a5)
0101441e  04550556          subi.w   #$556, (a5)
01014422  0157              bchg.b   d0, (a7)
01014424  0158              bchg.b   d0, (a0)+
01014426  0159              bchg.b   d0, (a1)+
01014428  0159              bchg.b   d0, (a1)+
0101442a  025a015b          andi.w   #$15b, (a2)+
0101442e  015e              bchg.b   d0, (a6)+
01014430  015f              bchg.b   d0, (a7)+
01014432  0160              bchg.b   d0, -(a0)
01014434  0162              bchg.b   d0, -(a2)
01014436  0164              bchg.b   d0, -(a4)
01014438  0165              bchg.b   d0, -(a5)
0101443a  0166              bchg.b   d0, -(a6)
0101443c  0166              bchg.b   d0, -(a6)
0101443e  02660366          andi.w   #$366, -(a6)
01014442  04660667          subi.w   #$667, -(a6)
01014446  016a016b          bchg.b   d0, $16b(a2)
0101444a  016c016e          bchg.b   d0, $16e(a4)
0101444e  016f0170          bchg.b   d0, $170(a7)
01014452  0179017a017e      bchg.b   d0, $17a017e.l
01014458  017f              dc.w     $017f
0101445a  0180              bclr.b   d0, d0
0101445c  0181              bclr.b   d0, d1
0101445e  0182              bclr.b   d0, d2
01014460  0187              bclr.b   d0, d7
01014462  018a018f          movep.w  d0, $18f(a2)
01014466  0190              bclr.b   d0, (a0)
01014468  0192              bclr.b   d0, (a2)
0101446a  0195              bclr.b   d0, (a5)
0101446c  0196              bclr.b   d0, (a6)
0101446e  0198              bclr.b   d0, (a0)+
01014470  0199              bclr.b   d0, (a1)+
01014472  0199              bclr.b   d0, (a1)+
01014474  0299049a019b      andi.l   #$49a019b, (a1)+
0101447a  019d              bclr.b   d0, (a5)+
0101447c  019e              bclr.b   d0, (a6)+
0101447e  01a0              bclr.b   d0, -(a0)
01014480  01a2              bclr.b   d0, -(a2)
01014482  01a5              bclr.b   d0, -(a5)
01014484  01a6              bclr.b   d0, -(a6)
01014486  01a801a9          bclr.b   d0, $1a9(a0)
0101448a  01a902aa          bclr.b   d0, $2aa(a1)
0101448e  01aa02aa          bclr.b   d0, $2aa(a2)
01014492  03aa07aa          bclr.b   d1, $7aa(a2)
01014496  0faa10aa          bclr.b   d7, $10aa(a2)
0101449a  11ab01ad01ae01af01b2  move.b   $1ad(a3), ([$1af], d0.w, $1b2)
010144a4  01b601b701b901ba01bb01bb  bclr.b   d0, ([$1b901ba], d0.w, $1bb01bb)
010144b0  02bb              dc.w     $02bb
010144b2  03bd              dc.w     $03bd
010144b4  01be              dc.w     $01be
010144b6  01be              dc.w     $01be
010144b8  02bf              dc.w     $02bf
010144ba  01bf              dc.w     $01bf
010144bc  02c0              dc.w     $02c0
010144be  01c1              bset.b   d0, d1
010144c0  01c2              bset.b   d0, d2
010144c2  01c3              bset.b   d0, d3
010144c4  01c5              bset.b   d0, d5
010144c6  01c6              bset.b   d0, d6
010144c8  01c901cd          movep.l  d0, $1cd(a1)
010144cc  01d2              bset.b   d0, (a2)
010144ce  01d9              bset.b   d0, (a1)+
010144d0  01e1              bset.b   d0, -(a1)
010144d2  01e2              bset.b   d0, -(a2)
010144d4  01e5              bset.b   d0, -(a5)
010144d6  01e6              bset.b   d0, -(a6)
010144d8  01e801e9          bset.b   d0, $1e9(a0)
010144dc  01ea01eb          bset.b   d0, $1eb(a2)
010144e0  01ee01ee          bset.b   d0, $1ee(a6)
010144e4  02ee              dc.w     $02ee
010144e6  03ee0fef          bset.b   d1, $fef(a6)
010144ea  01ef02f0          bset.b   d0, $2f0(a7)
010144ee  01f101f201fa01fb01fb  bset.b   d0, ([$1fa01fb], $1fb)
010144f8  02fc              dc.w     $02fc
010144fa  01fd              dc.w     $01fd
010144fc  01fe              dc.w     $01fe
010144fe  01fe              dc.w     $01fe
01014500  02fe              dc.w     $02fe
01014502  04ff              dc.w     $04ff
01014504  01ff              dc.w     $01ff
01014506  02ff              dc.w     $02ff
01014508  03ff              dc.w     $03ff
0101450a  04ff              dc.w     $04ff
0101450c  05ff              dc.w     $05ff
0101450e  06ff              dc.w     $06ff
01014510  07ff              dc.w     $07ff
01014512  0fff              dc.w     $0fff
01014514  1226              move.b   -(a6), d1
01014516  031e              btst.l   d1, (a6)+
01014518  2a286b78          move.l   $6b78(a0), d5
0101451c  2a37a82a          move.l   $2a(a7, a2.l), d5
01014520  2f939501          move.l   (a3), ([a7, a1.w * 4])
01014524  07a0              bclr.b   d3, -(a0)
01014526  2a2f7b0c          move.l   $7b0c(a7), d5
0101452a  6999              bvs.b    $10144c5
0101452c  2a2f5e65          move.l   $5e65(a7), d5
01014530  8d6ca299          or.w     d6, -$5d67(a4)
01014534  757b              dc.w     $757b
01014536  9f8f              subx.l   -(a7), -(a7)
01014538  9d8d              subx.l   -(a5), -(a6)
0101453a  7b2a              dc.w     $7b2a
0101453c  2a50              movea.l  (a0), a5
0101453e  6fa2              ble.b    $10144e2
01014540  8d6ea499          or.w     d6, -$5b67(a6)
01014544  775f              dc.w     $775f
01014546  752a              dc.w     $752a
01014548  2f1a              move.l   (a2)+, -(a7)
0101454a  9d8f              subx.l   -(a7), -(a6)
0101454c  6e9d              bgt.b    $10144eb
0101454e  6575              bcs.b    $10145c5
01014550  7ca2              moveq    #$a2, d6
01014552  9d90              sub.l    d6, (a0)
01014554  8d5f              or.w     d6, (a7)+
01014556  7b2a              dc.w     $7b2a
01014558  2f1b              move.l   (a3)+, -(a7)
0101455a  7574              dc.w     $7574
0101455c  6c8d              bge.b    $10144eb
0101455e  656e              bcs.b    $10145ce
01014560  99a4              sub.l    d4, -(a4)
01014562  9966              sub.w    d4, -(a6)
01014564  53752a29          subq.w   #$1, $29(a5, d2.l)
01014568  6e8f              bgt.b    $10144f9
0101456a  6579              bcs.b    $10145e5
0101456c  3265              movea.w  -(a5), a1
0101456e  757b              dc.w     $757b
01014570  a49d              dc.w     $a49d
01014572  6639              bne.b    $10145ad
01014574  7b2a              dc.w     $7b2a
01014576  296f73578915      move.l   $7357(a7), -$76eb(a4)
0101457c  4265              clr.w    -(a5)
0101457e  8f99              or.l     d7, (a1)+
01014580  a399              dc.w     $a399
01014582  6563              bcs.b    $10145e7
01014584  53752a29          subq.w   #$1, $29(a5, d2.l)
01014588  748a              moveq    #$8a, d2
0101458a  4154              dc.w     $4154
0101458c  325a              movea.w  (a2)+, a1
0101458e  6c7b              bge.b    $101460b
01014590  a49d              dc.w     $a49d
01014592  8d65              or.w     d6, -(a5)
01014594  397b2a287b57      move.w   $10145be(pc, d2.l), $7b57(a4)
0101459a  5d2a2f42          subq.b   #$6, $2f42(a2)
0101459e  6593              bcs.b    $1014533
010145a0  7ba4              dc.w     $7ba4
010145a2  9863              sub.w    -(a3), d4
010145a4  53752a28          subq.w   #$1, $28(a5, d2.l)
010145a8  743c              moveq    #$3c, d2
010145aa  482b5765          nbcd.b   $5765(a3)
010145ae  75a5              dc.w     $75a5
010145b0  7965              dc.w     $7965
010145b2  397b2a287b57      move.w   $10145dc(pc, d2.l), $7b57(a4)
010145b8  893b              dc.w     $893b
010145ba  2a3c6c6ea599      move.l   #$6c6ea599, d5
010145c0  6353              bls.b    $1014615
010145c2  752a              dc.w     $752a
010145c4  28744155          movea.l  ([a4]), a4
010145c8  2b32657599a379a0  move.l   ([$99a379a0, a2]), -(a5)
010145d0  8d397b2a2878      or.b     d6, $7b2a2878.l
010145d6  5d54              subq.w   #$6, (a4)
010145d8  572a2f42          subq.b   #$3, $2f42(a2)
010145dc  6ea6              bgt.b    $1014584
010145de  7353              dc.w     $7353
010145e0  752a              dc.w     $752a
010145e2  287449613b2a      movea.l  ([$3b2a, a4]), a4
010145e8  3265              movea.w  -(a5), a1
010145ea  7593              dc.w     $7593
010145ec  a293              dc.w     $a293
010145ee  758f              dc.w     $758f
010145f0  9d397b2a2878      sub.b    d6, $7b2a2878.l
010145f6  7463              moveq    #$63, d2
010145f8  5754              subq.w   #$3, (a4)
010145fa  2f426ea5          move.l   d2, $6ea5(a7)
010145fe  7578              dc.w     $7578
01014600  53752a28          subq.w   #$1, $28(a5, d2.l)
01014604  7498              moveq    #$98, d2
01014606  653c              bcs.b    $1014644
01014608  3b2a576c          move.w   $576c(a2), -(a5)
0101460c  75a2              dc.w     $75a2
0101460e  9990              sub.l    d4, (a0)
01014610  8e397b2a2878      or.b     $7b2a2878.l, d7
01014616  8d65              or.w     d6, -(a5)
01014618  582a3c6e          addq.b   #$4, $3c6e(a2)
0101461c  a279              dc.w     $a279
0101461e  937753752a287567  sub.w    d1, ([$2a287567, a7])
01014626  3c2a326c          move.w   $326c(a2), d6
0101462a  7ba2              dc.w     $7ba2
0101462c  9d90              sub.l    d6, (a0)
0101462e  8d887b2a          unpk     -(a0), -(a6), #$7b2a
01014632  287b6e66          movea.l  $101469a(pc, d6.l), a4
01014636  582f4299          addq.b   #$4, $4299(a7)
0101463a  a199              dc.w     $a199
0101463c  7674              moveq    #$74, d3
0101463e  6585              bcs.b    $10145c5
01014640  752a              dc.w     $752a
01014642  28797566613c      movea.l  $7566613c.l, a4
01014648  325b              movea.w  (a3)+, a1
0101464a  7ba0              dc.w     $7ba0
0101464c  99798f8d6c65      sub.w    d4, $8f8d6c65.l
01014652  887b2a28          or.w     $101467c(pc, d2.l), d4
01014656  7b90              dc.w     $7b90
01014658  6657              bne.b    $10146b1
0101465a  5542              subq.w   #$2, d2
0101465c  93a1              sub.l    d1, -(a1)
0101465e  99756e66          sub.w    d4, $66(a5, d6.l)
01014662  7075              moveq    #$75, d0
01014664  2a287b76          move.l   $7b76(a0), d5
01014668  7466              moveq    #$66, d2
0101466a  3b65799d          move.w   -(a5), $799d(a5)
0101466e  998f              subx.l   -(a7), -(a4)
01014670  8d67              or.w     d6, -(a7)
01014672  5f7b              dc.w     $5f7b
01014674  2a287ba0          move.l   $7ba0(a0), d5
01014678  908d              sub.l    a5, d0
0101467a  6557              bcs.b    $10146d3
0101467c  347ba1756e675f75  movea.w  ([$6f68a5f3, pc]), a2
01014684  2a287b79          move.l   $7b79(a0), d5
01014688  a076              dc.w     $a076

; ---- gap 0101468e..01014a05 (888 bytes) ----
0101468e  469d              not.l    (a5)+
01014690  8d67              or.w     d6, -(a7)
01014692  5a5f              addq.w   #$5, (a7)+
01014694  7b2a              dc.w     $7b2a
01014696  287ba290          movea.l  $1014628(pc, a2.w), a4
0101469a  5a4d              addq.w   #$5, a5
0101469c  2a0f              move.l   a7, d5
0101469e  996e6661          sub.w    d4, $6661(a6)
010146a2  6353              bls.b    $10146f7
010146a4  752a              dc.w     $752a
010146a6  287b9479          movea.l  $1014721(pc, a1.w), a4
010146aa  a075              dc.w     $a075
010146ac  6214              bhi.b    $10146c2
010146ae  2a27              move.l   -(a7), d5
010146b0  8d66              or.w     d6, -(a6)
010146b2  5a65              addq.w   #$5, -(a5)
010146b4  3c397b2a287b      move.w   $7b2a287b.l, d6
010146ba  a299              dc.w     $a299
010146bc  a087              dc.w     $a087
010146be  2a0e              move.l   a6, d5
010146c0  2a5a              movea.l  (a2)+, a5
010146c2  6542              bcs.b    $1014706
010146c4  6358              bls.b    $101471e
010146c6  53752a28          subq.w   #$1, $28(a5, d2.l)
010146ca  7ba3              dc.w     $7ba3
010146cc  9396              sub.l    d1, (a6)
010146ce  2a1f              move.l   (a7)+, d5
010146d0  2a8d              move.l   a5, (a5)
010146d2  6561              bcs.b    $1014735
010146d4  3e397b2a287b      move.w   $7b2a287b.l, d7
010146da  a39d              dc.w     $a39d
010146dc  812c4963          or.b     d0, $4963(a4)
010146e0  5953              subq.w   #$4, (a3)
010146e2  752a              dc.w     $752a
010146e4  287ba481          movea.l  $1014667(pc, a2.w), a4
010146e8  2b3c493d3b2f      move.l   #$493d3b2f, -(a5)
010146ee  2a397b2a287b      move.l   $7b2a287b.l, d5
010146f4  a414              dc.w     $a414
010146f6  2a09              move.l   a1, d5
010146f8  2a5c              movea.l  (a4)+, a5
010146fa  542b543b          addq.b   #$2, $543b(a3)
010146fe  53752a28          subq.w   #$1, $28(a5, d2.l)
01014702  7ba4              dc.w     $7ba4
01014704  1529173c          move.b   $173c(a1), -(a2)
01014708  452f2d39          chk.l    $2d39(a7), d2
0101470c  7b2a              dc.w     $7b2a
0101470e  287ba414          movea.l  $1014724(pc, a2.w), a4
01014712  3110              move.w   (a0), -(a0)
01014714  575c              subq.w   #$3, (a4)+
01014716  2e28752a          move.l   $752a(a0), d7
0101471a  287ba419          movea.l  $1014735(pc, a2.w), a4
0101471e  3c20              move.w   -(a0), d6
01014720  3c45              movea.w  d5, a6
01014722  3b2a332a          move.w   $332a(a2), -(a5)
01014726  397b2a287ba4      move.w   $1014750(pc, d2.l), $7ba4(a4)
0101472c  3257              movea.w  (a7), a1
0101472e  7857              moveq    #$57, d4
01014730  6d58              blt.b    $101478a
01014732  2b3253752a287ba4  move.l   ([$2a287ba4, a2]), -(a5)
0101473a  823d              dc.w     $823d
0101473c  42713f2a397b2a28  clr.w    ([$397b, a1, d3.l * 8], $2a28)
01014744  7ba3              dc.w     $7ba3
01014746  9983              subx.l   d3, d4
01014748  6661              bne.b    $10147ab
0101474a  7165              dc.w     $7165
0101474c  5953              subq.w   #$4, (a3)
0101474e  752a              dc.w     $752a
01014750  287ba29e          movea.l  $10146f0(pc, a2.w), a4
01014754  885a              or.w     (a2)+, d4
01014756  3665              movea.w  -(a5), a3
01014758  8f66              or.w     d7, -(a6)
0101475a  613d              bsr.b    $1014799
0101475c  397b2a287ba1      move.w   $1014786(pc, d2.l), $7ba1(a4)
01014762  937b              dc.w     $937b
01014764  8f8b654a          unpk     -(a3), -(a7), #$654a
01014768  659d              bcs.b    $1014707
0101476a  9867              sub.w    -(a7), d4
0101476c  6353              bls.b    $10147c1
0101476e  752a              dc.w     $752a
01014770  287b9ea0          movea.l  $1014712(pc, a1.l), a4
01014774  9975658d          sub.w    d4, ([], d6.w * 4)
01014778  656f              bcs.b    $10147e9
0101477a  998e              subx.l   -(a6), -(a4)
0101477c  7567              dc.w     $7567
0101477e  5f7b              dc.w     $5f7b
01014780  2a287ba1          move.l   $7ba1(a0), d5
01014784  9161              sub.w    d0, -(a1)
01014786  4a65              tst.w    -(a5)
01014788  a07b              dc.w     $a07b
0101478a  7990              dc.w     $7990
0101478c  8d65              or.w     d6, -(a5)
0101478e  39752a287b93      move.w   $28(a5, d2.l), $7b93(a4)
01014794  7765              dc.w     $7765
01014796  5735a199          subq.b   #$3, ([, a2.w])
0101479a  8ea0              or.l     -(a0), d7
0101479c  775f              dc.w     $775f
0101479e  7b2a              dc.w     $7b2a
010147a0  2875a09d          movea.l  -$63(a5, a2.w), a4
010147a4  9065              sub.w    -(a5), d0
010147a6  2a356ca2          move.l   -$5e(a5, d6.l), d5
010147aa  939d              sub.l    d1, (a5)+
010147ac  9085              sub.l    d5, d0
010147ae  752a              dc.w     $752a
010147b0  287b7765643c      movea.l  ([$101abee, pc]), a4
010147b6  7ca0              moveq    #$a0, d6
010147b8  79a0              dc.w     $79a0
010147ba  7ba0              dc.w     $7ba0
010147bc  995f              sub.w    d4, (a7)+
010147be  7b2a              dc.w     $7b2a
010147c0  287b9165614e      movea.l  ([$101a910, pc]), a4
010147c6  4293              clr.l    (a3)
010147c8  a299              dc.w     $a299
010147ca  9d99              sub.l    d6, (a1)+
010147cc  a088              dc.w     $a088
010147ce  752a              dc.w     $752a
010147d0  287976665747      movea.l  $76665747.l, a4
010147d6  5579a393a079      subq.w   #$2, $a393a079.l
010147dc  887b2a28          or.w     $1014806(pc, d2.l), d4
010147e0  7b90              dc.w     $7b90
010147e2  6561              bcs.b    $1014845
010147e4  3b441a93          move.w   d4, $1a93(a5)
010147e8  a29d              dc.w     $a29d
010147ea  a099              dc.w     $a099
010147ec  a097              dc.w     $a097
010147ee  752a              dc.w     $752a
010147f0  287599665754      movea.l  ([$5754, a5]), a4
010147f6  350d              move.w   a5, -(a2)
010147f8  7993              dc.w     $7993
010147fa  a29d              dc.w     $a29d
010147fc  a099              dc.w     $a099
010147fe  887b2a28          or.w     $1014828(pc, d2.l), d4
01014802  798f              dc.w     $798f
01014804  7465              moveq    #$65, d2
01014806  3c2a367e          move.w   $367e(a2), d6
0101480a  93a5              sub.l    d1, -(a5)
0101480c  7b70              dc.w     $7b70
0101480e  752a              dc.w     $752a
01014810  28759865          movea.l  $65(a5, a1.l), a4
01014814  6357              bls.b    $101486d
01014816  5441              addq.w   #$2, d1
01014818  954b              subx.w   -(a3), -(a2)
0101481a  7ba5              dc.w     $7ba5
0101481c  887b2a28          or.w     $1014846(pc, d2.l), d4
01014820  7998              dc.w     $7998
01014822  6561              bcs.b    $1014885
01014824  3b2a429b          move.w   $429b(a2), -(a5)
01014828  17a499a07075      move.b   -(a4), $7075(a1.l)
0101482e  2a287574          move.l   $7574(a0), d5
01014832  6358              bls.b    $101488c
01014834  2a65              movea.l  -(a5), a5
01014836  7b1d              dc.w     $7b1d
01014838  a59d              dc.w     $a59d
0101483a  887b2a28          or.w     $1014864(pc, d2.l), d4
0101483e  788f              moveq    #$8f, d4
01014840  613c              bsr.b    $101487e
01014842  3b2f326e          move.w   $326e(a7), -(a5)
01014846  7d7b              dc.w     $7d7b
01014848  a475              dc.w     $a475
0101484a  7075              moveq    #$75, d0
0101484c  2a287443          move.l   $7443(a0), d5
01014850  6057              bra.b    $10148a9
01014852  5432656f951c      addq.b   #$2, ([$951c, a2])
01014858  a48d              dc.w     $a48d
0101485a  5f7b              dc.w     $5f7b
0101485c  2a287865          move.l   $7865(a0), d5
01014860  8c3c2a2f          or.b     #$2f, d6
01014864  42759b0aa29d      clr.w    ([a5, a1.l * 2], $a29d)
0101486a  9365              sub.w    d1, -(a5)
0101486c  7075              moveq    #$75, d0
0101486e  2a287443          move.l   $7443(a0), d5
01014872  7357              dc.w     $7357
01014874  5434656e9304      addq.b   #$2, ([$9304, a4])
0101487a  a37b              dc.w     $a37b
0101487c  a088              dc.w     $a088
0101487e  7b2a              dc.w     $7b2a
01014880  28786e9d          movea.l  $6e9d.w, a4
01014884  3c2a4265          move.w   $4265(a2), d6
01014888  75a0              dc.w     $75a0
0101488a  7d1c              dc.w     $7d1c
0101488c  a488              dc.w     $a488
0101488e  752a              dc.w     $752a
01014890  28746c7b          movea.l  $7b(a4, d6.l), a4
01014894  572a5a65          subq.b   #$3, $5a65(a2)
01014898  937b              dc.w     $937b
0101489a  950a              subx.b   -(a2), -(a2)
0101489c  a19d              dc.w     $a19d
0101489e  a188              dc.w     $a188
010148a0  7b2a              dc.w     $7b2a
010148a2  28796ea08a2a      movea.l  $6ea08a2a.l, a4
010148a8  4265              clr.w    -(a5)
010148aa  7599              dc.w     $7599
010148ac  9b00              subx.b   d0, d5
010148ae  a19a              dc.w     $a19a
010148b0  7588              dc.w     $7588
010148b2  752a              dc.w     $752a
010148b4  28746fa09d3b      movea.l  $9d3b(d6.l * 8), a4
010148ba  5a65              addq.w   #$5, -(a5)
010148bc  937b              dc.w     $937b
010148be  a000              dc.w     $a000
010148c0  93a1              sub.l    d1, -(a1)
010148c2  524a              addq.w   #$1, a2
010148c4  887b2a28          or.w     $10148ee(pc, d2.l), d4
010148c8  7978              dc.w     $7978
010148ca  5aa0              addq.l   #$5, -(a0)
010148cc  8d65              or.w     d6, -(a5)
010148ce  6e75              bgt.b    $1014945
010148d0  9da0              sub.l    d6, -(a0)
010148d2  804f              dc.w     $804f
010148d4  a08d              dc.w     $a08d
010148d6  210f              move.l   a7, -(a0)
010148d8  88752a28          or.w     $28(a5, d2.l), d4
010148dc  748a              moveq    #$8a, d2
010148de  3c46              movea.w  d6, a6
010148e0  9d66              sub.w    d6, -(a6)
010148e2  93a1              sub.l    d1, -(a1)
010148e4  9d12              sub.b    d6, (a2)
010148e6  7a09              moveq    #$9, d5
010148e8  2488              move.l   a0, (a2)
010148ea  7b2a              dc.w     $7b2a
010148ec  2875585b          movea.l  $5b(a5, d5.l), a4
010148f0  a08d              dc.w     $a08d
010148f2  6c79              bge.b    $101496d
010148f4  93a0              sub.l    d1, -(a0)
010148f6  9b22              sub.b    d5, -(a2)
010148f8  17841651          move.b   d4, $51(a3, d1.w)
010148fc  5f752a28          subq.w   #$7, $28(a5, d2.l)
01014900  723d              moveq    #$3d, d1
01014902  41a1              chk.w    -(a1), d0
01014904  6593              bcs.b    $1014899
01014906  a20f              dc.w     $a20f
01014908  0609              dc.w     $0609
0101490a  25887b2a28785705  move.l   a0, ([$2878, a2, d7.l * 2], $5705)
01014912  5aa1              addq.l   #$5, -(a1)
01014914  9d7b              dc.w     $9d7b
01014916  a27d              dc.w     $a27d
01014918  0b11              btst.l   d5, (a1)
0101491a  4c20              dc.w     $4c20
0101491c  5f752a28          subq.w   #$7, $28(a5, d2.l)
01014920  793a              dc.w     $793a
01014922  148a              dc.w     $148a
01014924  a29d              dc.w     $a29d
01014926  8f94              or.l     d7, (a4)
01014928  9518              sub.b    d2, (a0)+
0101492a  2920              move.l   -(a0), -(a4)
0101492c  9d88              subx.l   -(a0), -(a6)
0101492e  7b2a              dc.w     $7b2a
01014930  2878562a          movea.l  $562a.w, a4
01014934  86a5              or.l     -(a5), d3
01014936  759b              dc.w     $759b
01014938  4d2a1099          chk.l    $1099(a2), d6
0101493c  5f752a28          subq.w   #$7, $28(a5, d2.l)
01014940  793a              dc.w     $793a
01014942  2f8aa39d          move.l   a2, ([], a2.w * 2)
01014946  6e8f              bgt.b    $10148d7
01014948  a008              dc.w     $a008
0101494a  2a10              move.l   (a0), d5
0101494c  8f5f              or.w     d7, (a7)+
0101494e  7b2a              dc.w     $7b2a
01014950  28785a5b          movea.l  $5a5b.w, a4
01014954  5aa3              addq.l   #$5, -(a3)
01014956  9d6c757b          sub.w    d6, $757b(a4)
0101495a  7e29              moveq    #$29, d7
0101495c  207453752a287b3c  movea.l  ([$2a287b3c, a4]), a0
01014964  7941              dc.w     $7941
01014966  a69b              dc.w     $a69b
01014968  3826              move.w   -(a6), d4
0101496a  9d8d              subx.l   -(a5), -(a6)
0101496c  397b2a287b58      move.w   $1014996(pc, d2.l), $7b58(a4)
01014972  5ba6              subq.l   #$5, -(a6)
01014974  96310799          sub.b    ([, d0.w * 8]), d3
01014978  6353              bls.b    $10149cd
0101497a  752a              dc.w     $752a
0101497c  287b8a3c          movea.l  $10149ba(pc, a0.l), a4
01014980  458d              dc.w     $458d
01014982  613d              bsr.b    $10149c1
01014984  4ba1              chk.w    -(a1), d5
01014986  9b2f108f          sub.b    d5, $108f(a7)
0101498a  6139              bsr.b    $10149c5
0101498c  7b2a              dc.w     $7b2a
0101498e  287b9c57          movea.l  $10149e7(pc, a1.l), a4
01014992  996e6358          sub.w    d4, $6358(a6)
01014996  7ba2              dc.w     $7ba2
01014998  137b74575375      move.b   $10149f1(pc, d7.w), $5375(a1)
0101499e  2a287ba1          move.l   $7ba1(a0), d5
010149a2  8f8d6140          unpk     -(a5), -(a7), #$6140
010149a6  7f9d              dc.w     $7f9d
010149a8  8d3c              dc.w     $8d3c
010149aa  397b2a287ba2      move.w   $10149d4(pc, d2.l), $7ba2(a4)
010149b0  7468              moveq    #$68, d2
010149b2  6c99              bge.b    $101494d
010149b4  6357              bls.b    $1014a0d
010149b6  53752a28          subq.w   #$1, $28(a5, d2.l)
010149ba  5e02              addq.b   #$7, d2
010149bc  057b              dc.w     $057b
010149be  2a286b75          move.l   $6b75(a0), d5
010149c2  2a286b7b          move.l   $6b7b(a0), d5
010149c6  2a286b75          move.l   $6b75(a0), d5
010149ca  2a286b7b          move.l   $6b7b(a0), d5
010149ce  2a296b75          move.l   $6b75(a1), d5
010149d2  2a2a1a6a          move.l   $1a6a(a2), d5
010149d6  7b2a              dc.w     $7b2a
010149d8  2a23              move.l   -(a3), d5
010149da  6a75              bpl.b    $1014a51
010149dc  2a2a286a          move.l   $286a(a2), d5
010149e0  7b2a              dc.w     $7b2a
010149e2  2a296a75          move.l   $6a75(a1), d5
010149e6  2a2b1a69          move.l   $1a69(a3), d5
010149ea  7b2a              dc.w     $7b2a
010149ec  2b23              move.l   -(a3), -(a5)
010149ee  6975              bvs.b    $1014a65
010149f0  2a2b2869          move.l   $2869(a3), d5
010149f4  7b2a              dc.w     $7b2a
010149f6  2b30a799          move.l   ([, a2.w * 8]), -(a5)
010149fa  2a2c9293          move.l   -$6d6d(a4), d5
010149fe  2a2c4ba7          move.l   $4ba7(a4), d5
01014a02  2a00              move.l   d0, d5
01014a04  0000              dc.w     $0000

; ---- gap 01014a0c..01014ea3 (1176 bytes) ----
01014a0c  0048              dc.w     $0048
01014a0e  00000041          ori.b    #$41, d0
01014a12  56a0              addq.l   #$3, -(a0)
01014a14  aaea              dc.w     $aaea
01014a16  abff              dc.w     $abff
01014a18  ffff              dc.w     $ffff
01014a1a  fbbb              dc.w     $fbbb
01014a1c  bffe              dc.w     $bffe
01014a1e  fefefeeefeea      fbf.l    $fff0490a
01014a24  558a              subq.l   #$2, a2
01014a26  afff              dc.w     $afff
01014a28  ffff              dc.w     $ffff
01014a2a  ffff              dc.w     $ffff
01014a2c  ffee              dc.w     $ffee
01014a2e  baa99ffb          cmp.l    -$6005(a1), d5
01014a32  bbbb              dc.w     $bbbb
01014a34  bba2              eor.l    d5, -(a2)
01014a36  562afeee          addq.b   #$3, -$112(a2)
01014a3a  aeff              dc.w     $aeff
01014a3c  aeea              dc.w     $aeea
01014a3e  aa66              dc.w     $aa66
01014a40  5599              subq.l   #$2, (a1)+
01014a42  9abe              dc.w     $9abe
01014a44  eeee              dc.w     $eeee
01014a46  eaa2              asr.l    d5, d2
01014a48  562bbbba          addq.b   #$3, -$4446(a3)
01014a4c  abfb              dc.w     $abfb
01014a4e  fbaa              dc.w     $fbaa
01014a50  a999              dc.w     $a999
01014a52  5566              subq.w   #$2, -(a6)
01014a54  aaab              dc.w     $aaab
01014a56  fbaa              dc.w     $fbaa
01014a58  aa92              dc.w     $aa92
01014a5a  54aeeeaa          addq.l   #$2, -$1156(a6)
01014a5e  bfff              dc.w     $bfff
01014a60  eeee              dc.w     $eeee
01014a62  a665              dc.w     $a665
01014a64  9599              sub.l    d2, (a1)+
01014a66  aaaa              dc.w     $aaaa
01014a68  eeaa              lsr.l    d7, d2
01014a6a  aa62              dc.w     $aa62
01014a6c  54afb999          addq.l   #$2, -$4667(a7)
01014a70  ffef              dc.w     $ffef
01014a72  bbaaa999          eor.l    d5, -$5667(a2)
01014a76  5566              subq.w   #$2, -(a6)
01014a78  aaab              dc.w     $aaab
01014a7a  bbaaa992          eor.l    d5, -$566e(a2)
01014a7e  54ba              dc.w     $54ba
01014a80  e667              asr.w    d3, d7
01014a82  eeff              dc.w     $eeff
01014a84  eeea              dc.w     $eeea
01014a86  a665              dc.w     $a665
01014a88  559a              subq.l   #$2, (a2)+
01014a8a  6aae              bpl.b    $1014a3a
01014a8c  eeea              dc.w     $eeea
01014a8e  aa62              dc.w     $aa62
01014a90  52bf              dc.w     $52bf
01014a92  999f              sub.l    d4, (a7)+
01014a94  fffe              dc.w     $fffe
01014a96  fbae              dc.w     $fbae
01014a98  a999              dc.w     $a999
01014a9a  9566              sub.w    d2, -(a6)
01014a9c  aaeb              dc.w     $aaeb
01014a9e  bbba              dc.w     $bbba
01014aa0  a992              dc.w     $a992
01014aa2  52ba              dc.w     $52ba
01014aa4  667b              bne.b    $1014b21
01014aa6  efbf              rol.l    d7, d7
01014aa8  beeaaa65          cmpa.w   -$559b(a2), a7
01014aac  559a              subq.l   #$2, (a2)+
01014aae  aaae              dc.w     $aaae
01014ab0  eefe              dc.w     $eefe
01014ab2  aa62              dc.w     $aa62
01014ab4  52bf              dc.w     $52bf
01014ab6  99effffb          suba.l   -$5(a7), a4
01014aba  fbba              dc.w     $fbba
01014abc  a999              dc.w     $a999
01014abe  566aaabb          addq.w   #$3, -$5545(a2)
01014ac2  bbefa992          cmpa.l   -$566e(a7), a5
01014ac6  52ba              dc.w     $52ba
01014ac8  67ffffffbeea      beq.l    $10109b4
01014ace  aa65              dc.w     $aa65
01014ad0  559a              subq.l   #$2, (a2)+
01014ad2  aaee              dc.w     $aaee
01014ad4  eeff              dc.w     $eeff
01014ad6  ea62              asr.w    d5, d2
01014ad8  52bd              dc.w     $52bd
01014ada  9eff              dc.w     $9eff
01014adc  ffbf              dc.w     $ffbf
01014ade  ffba              dc.w     $ffba
01014ae0  a999              dc.w     $a999
01014ae2  566aaabb          addq.w   #$3, -$5545(a2)
01014ae6  bfbe              dc.w     $bfbe
01014ae8  f992              dc.w     $f992
01014aea  52ba              dc.w     $52ba
01014aec  7fff              dc.w     $7fff
01014aee  fffe              dc.w     $fffe
01014af0  fbee              dc.w     $fbee
01014af2  aa65              dc.w     $aa65
01014af4  59a6              subq.l   #$4, -(a6)
01014af6  aeee              dc.w     $aeee
01014af8  fbff              dc.w     $fbff
01014afa  fe6252bd          ftrapor.b -(a2)
01014afe  bfff              dc.w     $bfff
01014b00  ffff              dc.w     $ffff
01014b02  ffba              dc.w     $ffba
01014b04  a999              dc.w     $a999
01014b06  566abbbb          addq.w   #$3, -$4445(a2)
01014b0a  ffff              dc.w     $ffff
01014b0c  fd92              dc.w     $fd92
01014b0e  52ba              dc.w     $52ba
01014b10  ffff              dc.w     $ffff
01014b12  ffff              dc.w     $ffff
01014b14  fbee              dc.w     $fbee
01014b16  aa65              dc.w     $aa65
01014b18  59aaaeff          subq.l   #$4, -$5101(a2)
01014b1c  bfbf              dc.w     $bfbf
01014b1e  fe6252bd          ftrapor.b -(a2)
01014b22  ffff              dc.w     $ffff
01014b24  ffff              dc.w     $ffff
01014b26  fffb              dc.w     $fffb
01014b28  aa99              dc.w     $aa99
01014b2a  566abbbb          addq.w   #$3, -$4445(a2)
01014b2e  ffff              dc.w     $ffff
01014b30  ff92              dc.w     $ff92
01014b32  52bb              dc.w     $52bb
01014b34  ffff              dc.w     $ffff
01014b36  ffff              dc.w     $ffff
01014b38  efbe              rol.l    d7, d6
01014b3a  aa65              dc.w     $aa65
01014b3c  59aaeeff          subq.l   #$4, -$1101(a2)
01014b40  fbff              dc.w     $fbff
01014b42  ffa2              dc.w     $ffa2
01014b44  52bf              dc.w     $52bf
01014b46  ffff              dc.w     $ffff
01014b48  ffff              dc.w     $ffff
01014b4a  fffb              dc.w     $fffb
01014b4c  aa95              dc.w     $aa95
01014b4e  66ab              bne.b    $1014afb
01014b50  bfeeffff          cmpa.l   -$1(a6), a7
01014b54  ff92              dc.w     $ff92
01014b56  52bf              dc.w     $52bf
01014b58  ffff              dc.w     $ffff
01014b5a  ffff              dc.w     $ffff
01014b5c  ffbe              dc.w     $ffbe
01014b5e  eb65              asl.w    d5, d5
01014b60  59aeefff          subq.l   #$4, -$1001(a6)
01014b64  ffff              dc.w     $ffff
01014b66  ffe2              dc.w     $ffe2
01014b68  52bf              dc.w     $52bf
01014b6a  ffff              dc.w     $ffff
01014b6c  ffff              dc.w     $ffff
01014b6e  fffb              dc.w     $fffb
01014b70  ba95              cmp.l    (a5), d5
01014b72  66bb              bne.b    $1014b2f
01014b74  bfbf              dc.w     $bfbf
01014b76  ffff              dc.w     $ffff
01014b78  ffe2              dc.w     $ffe2
01014b7a  52bf              dc.w     $52bf
01014b7c  ffff              dc.w     $ffff
01014b7e  ffff              dc.w     $ffff
01014b80  ffff              dc.w     $ffff
01014b82  ea65              asr.w    d5, d5
01014b84  5aeefffe          spl.b    -$2(a6)
01014b88  ffff              dc.w     $ffff
01014b8a  ffe2              dc.w     $ffe2
01014b8c  52bf              dc.w     $52bf
01014b8e  bfefffff          cmpa.l   -$1(a7), a7
01014b92  fffb              dc.w     $fffb
01014b94  ba95              cmp.l    (a5), d5
01014b96  6bbb              bmi.b    $1014b53
01014b98  fbff              dc.w     $fbff
01014b9a  ffff              dc.w     $ffff
01014b9c  ffe2              dc.w     $ffe2
01014b9e  52bf              dc.w     $52bf
01014ba0  ffff              dc.w     $ffff
01014ba2  ffff              dc.w     $ffff
01014ba4  ffff              dc.w     $ffff
01014ba6  e000              asr.b    #$8, d0
01014ba8  5eff              dc.w     $5eff
01014baa  ffff              dc.w     $ffff
01014bac  ffff              dc.w     $ffff
01014bae  ffe2              dc.w     $ffe2
01014bb0  52be              dc.w     $52be
01014bb2  fbff              dc.w     $fbff
01014bb4  ffff              dc.w     $ffff
01014bb6  ffff              dc.w     $ffff
01014bb8  c155              and.w    d0, (a5)
01014bba  0fefbfff          bset.b   d7, -$4001(a7)
01014bbe  ffff              dc.w     $ffff
01014bc0  fff2              dc.w     $fff2
01014bc2  52bf              dc.w     $52bf
01014bc4  ffef              dc.w     $ffef
01014bc6  beff              dc.w     $beff
01014bc8  bff81555          cmpa.l   $1555.w, a7
01014bcc  52ff              dc.w     $52ff
01014bce  ffff              dc.w     $ffff
01014bd0  fffe              dc.w     $fffe
01014bd2  fff2              dc.w     $fff2
01014bd4  52bf              dc.w     $52bf
01014bd6  efff              dc.w     $efff
01014bd8  fffb              dc.w     $fffb
01014bda  ffe1              dc.w     $ffe1
01014bdc  550d              dc.w     $550d
01014bde  55ff              dc.w     $55ff
01014be0  ffff              dc.w     $ffff
01014be2  ffff              dc.w     $ffff
01014be4  fff2              dc.w     $fff2
01014be6  52be              dc.w     $52be
01014be8  ffbe              dc.w     $ffbe
01014bea  fbff              dc.w     $fbff
01014bec  eff1553d55ffffffffff  bfins    d5, ([$ffffffff]){20:5}
01014bf6  fbf2              dc.w     $fbf2
01014bf8  52bf              dc.w     $52bf
01014bfa  bbff              dc.w     $bbff
01014bfc  ffef              dc.w     $ffef
01014bfe  ffc5              dc.w     $ffc5
01014c00  5555              subq.w   #$2, (a5)
01014c02  557f              dc.w     $557f
01014c04  ffff              dc.w     $ffff
01014c06  fefefff252be      fbf.l    $f39ec6
01014c0c  eeee              dc.w     $eeee
01014c0e  effe              dc.w     $effe
01014c10  fbc5              dc.w     $fbc5
01014c12  5555              subq.w   #$2, (a5)
01014c14  667f              bne.b    $1014c95
01014c16  bfbf              dc.w     $bfbf
01014c18  ffff              dc.w     $ffff
01014c1a  efe2              dc.w     $efe2
01014c1c  52bf              dc.w     $52bf
01014c1e  bbbb              dc.w     $bbbb
01014c20  bbbf              dc.w     $bbbf
01014c22  ff15              fsave    (a5)
01014c24  5506              subq.b   #$2, d6
01014c26  559f              subq.l   #$2, (a7)+
01014c28  fffe              dc.w     $fffe
01014c2a  fffb              dc.w     $fffb
01014c2c  fef252baeeee      fbf.l    $53bc3b1c
01014c32  eeee              dc.w     $eeee
01014c34  ee16              roxr.b   #$7, d6
01014c36  541f              addq.b   #$2, (a7)+
01014c38  666e              bne.b    $1014ca8
01014c3a  fbef              dc.w     $fbef
01014c3c  efbf              rol.l    d7, d7
01014c3e  fff2              dc.w     $fff2
01014c40  52be              dc.w     $52be
01014c42  aaaa              dc.w     $aaaa
01014c44  aabb              dc.w     $aabb
01014c46  bb15              eor.b    d5, (a5)
01014c48  580f              dc.w     $580f
01014c4a  999f              sub.l    d4, (a7)+
01014c4c  ffff              dc.w     $ffff
01014c4e  fefeeee252be      fbf.l    $efe39f0e
01014c54  aaaa              dc.w     $aaaa
01014c56  aaaa              dc.w     $aaaa
01014c58  aa26              dc.w     $aa26
01014c5a  663f              bne.b    $1014c9b
01014c5c  666e              bne.b    $1014ccc
01014c5e  bbbb              dc.w     $bbbb
01014c60  bbbb              dc.w     $bbbb
01014c62  bbb252be          eor.l    d5, -$42(a2, d5.w)
01014c66  aaaa              dc.w     $aaaa
01014c68  aaaa              dc.w     $aaaa
01014c6a  aa55              dc.w     $aa55
01014c6c  99bd              dc.w     $99bd
01014c6e  99adaaee          sub.l    d4, -$5512(a5)
01014c72  eeee              dc.w     $eeee
01014c74  eee2              dc.w     $eee2
01014c76  52be              dc.w     $52be
01014c78  aaaa              dc.w     $aaaa
01014c7a  aaaa              dc.w     $aaaa
01014c7c  6656              bne.b    $1014cd4
01014c7e  6666              bne.b    $1014ce6
01014c80  6ab6              bpl.b    $1014c38
01014c82  6aaa              bpl.b    $1014c2e
01014c84  abbb              dc.w     $abbb
01014c86  bba2              eor.l    d5, -(a2)
01014c88  52be              dc.w     $52be
01014c8a  a699              dc.w     $a699
01014c8c  9999              sub.l    d4, (a1)+
01014c8e  9959              sub.w    d4, (a1)+
01014c90  aaaa              dc.w     $aaaa
01014c92  a6b5              dc.w     $a6b5
01014c94  aaaa              dc.w     $aaaa
01014c96  eaaa              lsr.l    d5, d2
01014c98  aab2              dc.w     $aab2
01014c9a  52bd              dc.w     $52bd
01014c9c  aa66              dc.w     $aa66
01014c9e  6665              bne.b    $1014d05
01014ca0  5562              subq.w   #$2, -(a2)
01014ca2  9a5e              sub.w    (a6)+, d5
01014ca4  aad5              dc.w     $aad5
01014ca6  66aa              bne.b    $1014c52
01014ca8  aaaa              dc.w     $aaaa
01014caa  aea2              dc.w     $aea2
01014cac  52be              dc.w     $52be
01014cae  9999              sub.l    d4, (a1)+
01014cb0  9956              sub.w    d4, (a6)
01014cb2  559b              subq.l   #$2, (a3)+
01014cb4  aa7e              dc.w     $aa7e
01014cb6  ab65              dc.w     $ab65
01014cb8  999a              sub.l    d4, (a2)+
01014cba  6aaa              bpl.b    $1014c66
01014cbc  aa92              dc.w     $aa92
01014cbe  52be              dc.w     $52be
01014cc0  6666              bne.b    $1014d28
01014cc2  5595              subq.l   #$2, (a5)
01014cc4  566beaaa          addq.w   #$3, -$1556(a3)
01014cc8  ae99              dc.w     $ae99
01014cca  5666              addq.w   #$3, -(a6)
01014ccc  aaaa              dc.w     $aaaa
01014cce  aaa2              dc.w     $aaa2
01014cd0  52bd              dc.w     $52bd
01014cd2  9995              sub.l    d4, (a5)
01014cd4  5555              subq.w   #$2, (a5)
01014cd6  59aefeaa          subq.l   #$4, -$156(a6)
01014cda  fa665599          fsueq.b  -(a6)
01014cde  999a              sub.l    d4, (a2)+
01014ce0  a6a2              dc.w     $a6a2
01014ce2  52be              dc.w     $52be
01014ce4  6559              bcs.b    $1014d3f
01014ce6  5555              subq.w   #$2, (a5)
01014ce8  66bb              bne.b    $1014ca5
01014cea  efff              dc.w     $efff
01014cec  fe999566          fbf.w    $100e254
01014cf0  6666              bne.b    $1014d58
01014cf2  6aa2              bpl.b    $1014c96
01014cf4  52bd              dc.w     $52bd
01014cf6  5555              subq.w   #$2, (a5)
01014cf8  5565              subq.w   #$2, -(a5)
01014cfa  9aaefffe          sub.l    -$2(a6), d5
01014cfe  fba6              dc.w     $fba6
01014d00  6555              bcs.b    $1014d57
01014d02  9999              sub.l    d4, (a1)+
01014d04  99a2              sub.l    d4, -(a2)
01014d06  52bd              dc.w     $52bd
01014d08  5955              subq.w   #$4, (a5)
01014d0a  5556              subq.w   #$2, (a6)
01014d0c  6affefffbe99      bpl.l    $f1010ba7
01014d12  9955              sub.w    d4, (a5)
01014d14  5566              subq.w   #$2, -(a6)
01014d16  6562              bcs.b    $1014d7a
01014d18  52be              dc.w     $52be
01014d1a  9555              sub.w    d2, (a5)
01014d1c  5599              subq.l   #$2, (a1)+
01014d1e  aac2              dc.w     $aac2
01014d20  ffff              dc.w     $ffff
01014d22  fbaa              dc.w     $fbaa
01014d24  6655              bne.b    $1014d7b
01014d26  5595              subq.l   #$2, (a5)
01014d28  99e2              suba.l   -(a2), a4
01014d2a  52be              dc.w     $52be
01014d2c  5555              subq.w   #$2, (a5)
01014d2e  5666              addq.w   #$3, -(a6)
01014d30  aaf0              dc.w     $aaf0
01014d32  bffbfeea          cmpa.l   $1014d1e(pc, a7.l), a7
01014d36  9999              sub.l    d4, (a1)+
01014d38  5559              subq.w   #$2, (a1)+
01014d3a  55e2              scs.b    -(a2)
01014d3c  52bf              dc.w     $52bf
01014d3e  5555              subq.w   #$2, (a5)
01014d40  999a              sub.l    d4, (a2)+
01014d42  6abc              bpl.b    $1014d00
01014d44  2eff              dc.w     $2eff
01014d46  bfba              dc.w     $bfba
01014d48  a666              dc.w     $a666
01014d4a  5555              subq.w   #$2, (a5)
01014d4c  59f252bb          svs.b    -$45(a2, d5.w)
01014d50  d565              add.w    d2, -(a5)
01014d52  6666              bne.b    $1014dba
01014d54  aaef              dc.w     $aaef
01014d56  0bff              dc.w     $0bff
01014d58  fbee              dc.w     $fbee
01014d5a  aa99              dc.w     $aa99
01014d5c  9555              sub.w    d2, (a5)
01014d5e  56e2              sne.b    -(a2)
01014d60  52be              dc.w     $52be
01014d62  e995              roxl.l   #$4, d5
01014d64  999a              sub.l    d4, (a2)+
01014d66  abbb              dc.w     $abbb
01014d68  c1ff              dc.w     $c1ff
01014d6a  bfabba66          eor.l    d7, -$459a(a3)
01014d6e  6655              bne.b    $1014dc5
01014d70  57b252bb          subq.l   #$3, -$45(a2, d5.w)
01014d74  e656              roxr.w   #$3, d6
01014d76  666a              bne.b    $1014de2
01014d78  aaef              dc.w     $aaef
01014d7a  f07f              dc.w     $f07f
01014d7c  fbee              dc.w     $fbee
01014d7e  aaa9              dc.w     $aaa9
01014d80  9995              sub.l    d4, (a5)
01014d82  5fe2              sle.b    -(a2)
01014d84  52be              dc.w     $52be
01014d86  f959              frestore (a1)+
01014d88  99aaabbf          sub.l    d4, -$5441(a2)
01014d8c  fc1ffffb          fmovem   invalid, (a7)+
01014d90  aa9a              dc.w     $aa9a
01014d92  6665              bne.b    $1014df9
01014d94  5fb252bb          subq.l   #$7, -$45(a2, d5.w)
01014d98  be66              cmp.w    -(a6), d7
01014d9a  66aa              bne.b    $1014d46
01014d9c  aefe              dc.w     $aefe
01014d9e  fb33fbbeeaaa99996ee2  fsave    ([$eaaa9999], a7.l * 2, $6ee2)
01014da8  52bd              dc.w     $52bd
01014daa  ee55              roxr.w   #$7, d5
01014dac  99abbbef          sub.l    d4, -$4411(a3)
01014db0  ffc0              dc.w     $ffc0
01014db2  bffbbaa9          cmpa.l   $1014d5d(pc, a3.l), a7
01014db6  a666              dc.w     $a666
01014db8  bbb252ba          eor.l    d5, -$46(a2, d5.w)
01014dbc  6ba6              bmi.b    $1014d64
01014dbe  6aaa              bpl.b    $1014d6a
01014dc0  aefe              dc.w     $aefe
01014dc2  fff0              dc.w     $fff0
01014dc4  2fbe              dc.w     $2fbe
01014dc6  eeaa              lsr.l    d7, d2
01014dc8  aa99              dc.w     $aa99
01014dca  eaa2              asr.l    d5, d2
01014dcc  52bd              dc.w     $52bd
01014dce  aafa              dc.w     $aafa
01014dd0  a6aa              dc.w     $a6aa
01014dd2  bbff              dc.w     $bbff
01014dd4  fffc              dc.w     $fffc
01014dd6  07ff              dc.w     $07ff
01014dd8  baea9a6f          cmpa.w   -$6591(a2), a5
01014ddc  aab2              dc.w     $aab2
01014dde  52ba              dc.w     $52ba
01014de0  6bbe              bmi.b    $1014da0
01014de2  aaaa              dc.w     $aaaa
01014de4  efbf              rol.l    d7, d7
01014de6  efff              dc.w     $efff
01014de8  02fb              dc.w     $02fb
01014dea  eeaa              lsr.l    d7, d2
01014dec  aabf              dc.w     $aabf
01014dee  ffe2              dc.w     $ffe2
01014df0  52bd              dc.w     $52bd
01014df2  aeff              dc.w     $aeff
01014df4  aabb              dc.w     $aabb
01014df6  bbfbffffc02fbbab  cmpa.l   ([$c13109a3]), a5
01014dfe  aaff              dc.w     $aaff
01014e00  ffe2              dc.w     $ffe2
01014e02  52ba              dc.w     $52ba
01014e04  abbf              dc.w     $abbf
01014e06  aaaa              dc.w     $aaaa
01014e08  efff              dc.w     $efff
01014e0a  fffe              dc.w     $fffe
01014e0c  f007eeea          fmovem   d6, d7
01014e10  aeff              dc.w     $aeff
01014e12  ffe2              dc.w     $ffe2
01014e14  52be              dc.w     $52be
01014e16  aeff              dc.w     $aeff
01014e18  eebb              ror.l    d7, d3
01014e1a  beff              dc.w     $beff
01014e1c  ffff              dc.w     $ffff
01014e1e  fc00fbba          fmovem   invalid, d0
01014e22  fbfb              dc.w     $fbfb
01014e24  bbe2              cmpa.l   -(a2), a5
01014e26  52ba              dc.w     $52ba
01014e28  afff              dc.w     $afff
01014e2a  feaeefef          fbf.w    $1013e1b
01014e2e  ffff              dc.w     $ffff
01014e30  ff00              dc.w     $ff00
01014e32  eeef              dc.w     $eeef
01014e34  ff90              dc.w     $ff90
01014e36  7ee2              moveq    #$e2, d7
01014e38  52be              dc.w     $52be
01014e3a  bd9a              eor.l    d6, (a2)+
01014e3c  ffff              dc.w     $ffff
01014e3e  bfff              dc.w     $bfff
01014e40  fffe              dc.w     $fffe
01014e42  efc3              dc.w     $efc3
01014e44  87ff              dc.w     $87ff
01014e46  ea40              asr.w    #$5, d0
01014e48  0ee2              dc.w     $0ee2
01014e4a  52ba              dc.w     $52ba
01014e4c  e666              asr.w    d3, d6
01014e4e  6ffe              ble.b    $1014e4e
01014e50  bbbf              dc.w     $bbbf
01014e52  fefffefe11be      fbf.l    $ffff6012
01014e58  be06              cmp.b    d6, d7
01014e5a  4ee2              dc.w     $4ee2
01014e5c  52bb              dc.w     $52bb
01014e5e  9999              sub.l    d4, (a1)+
01014e60  9bff              dc.w     $9bff
01014e62  ebff              dc.w     $ebff
01014e64  ffff              dc.w     $ffff
01014e66  effc              dc.w     $effc
01014e68  481f              nbcd.b   (a7)+
01014e6a  cd19              and.b    d6, (a1)+
01014e6c  8fa2              or.l     d7, -(a2)
01014e6e  52b76666          addq.l   #$1, $66(a7, d6.w)
01014e72  67fffffffffb      beq.l    $1014e6f
01014e78  ffef              dc.w     $ffef
01014e7a  0e02              dc.w     $0e02
01014e7c  02064fe2          andi.b   #$e2, d6
01014e80  52bd              dc.w     $52bd
01014e82  9902              subx.b   d2, d4
01014e84  9aff              dc.w     $9aff
01014e86  ffee              dc.w     $ffee
01014e88  ffff              dc.w     $ffff
01014e8a  befe              dc.w     $befe
01014e8c  c008              dc.w     $c008
01014e8e  1080              move.b   d0, (a0)
01014e90  3fa252be          move.w   -(a2), -$42(a7, d5.w)
01014e94  6415              bcc.b    $1014eab
01014e96  e6ff              dc.w     $e6ff
01014e98  ffff              dc.w     $ffff
01014e9a  fbbf              dc.w     $fbbf
01014e9c  ffff              dc.w     $ffff
01014e9e  f020543f          dc.w     $9
01014ea2  fee2              dc.w     $fee2

; ---- gap 01014eaa..01015343 (1178 bytes) ----
01014eaa  0048              dc.w     $0048
01014eac  00000041          ori.b    #$41, d0
01014eb0  56a0              addq.l   #$3, -(a0)
01014eb2  aaea              dc.w     $aaea
01014eb4  abff              dc.w     $abff
01014eb6  ffff              dc.w     $ffff
01014eb8  fbbb              dc.w     $fbbb
01014eba  bffe              dc.w     $bffe
01014ebc  fefefeeefeea      fbf.l    $fff04da8
01014ec2  558a              subq.l   #$2, a2
01014ec4  afff              dc.w     $afff
01014ec6  ffff              dc.w     $ffff
01014ec8  ffff              dc.w     $ffff
01014eca  ffff              dc.w     $ffff
01014ecc  fbfe              dc.w     $fbfe
01014ece  effb              dc.w     $effb
01014ed0  bbbb              dc.w     $bbbb
01014ed2  bba2              eor.l    d5, -(a2)
01014ed4  562afeee          addq.b   #$3, -$112(a2)
01014ed8  aeff              dc.w     $aeff
01014eda  ffff              dc.w     $ffff
01014edc  ffff              dc.w     $ffff
01014ede  bfbb              dc.w     $bfbb
01014ee0  aafe              dc.w     $aafe
01014ee2  eeee              dc.w     $eeee
01014ee4  eaa2              asr.l    d5, d2
01014ee6  562bbbba          addq.b   #$3, -$4446(a3)
01014eea  abff              dc.w     $abff
01014eec  ffff              dc.w     $ffff
01014eee  ffef              dc.w     $ffef
01014ef0  ffee              dc.w     $ffee
01014ef2  eaaf              lsr.l    d5, d7
01014ef4  fbaa              dc.w     $fbaa
01014ef6  aa92              dc.w     $aa92
01014ef8  54aeeeaa          addq.l   #$2, -$1156(a6)
01014efc  beff              dc.w     $beff
01014efe  ffff              dc.w     $ffff
01014f00  fffe              dc.w     $fffe
01014f02  fbfb              dc.w     $fbfb
01014f04  aea6              dc.w     $aea6
01014f06  feaaaa62          fbf.w    $100f96a
01014f0a  54afb999          addq.l   #$2, -$4667(a7)
01014f0e  fffb              dc.w     $fffb
01014f10  ffff              dc.w     $ffff
01014f12  ffff              dc.w     $ffff
01014f14  ffee              dc.w     $ffee
01014f16  eaaa              lsr.l    d5, d2
01014f18  7faa              dc.w     $7faa
01014f1a  a992              dc.w     $a992
01014f1c  54ba              dc.w     $54ba
01014f1e  e667              asr.w    d3, d7
01014f20  bfff              dc.w     $bfff
01014f22  ffff              dc.w     $ffff
01014f24  ffff              dc.w     $ffff
01014f26  ffbb              dc.w     $ffbb
01014f28  aaa9              dc.w     $aaa9
01014f2a  99eaaa62          suba.l   -$559e(a2), a4
01014f2e  52bf              dc.w     $52bf
01014f30  999f              sub.l    d4, (a7)+
01014f32  eeff              dc.w     $eeff
01014f34  ffff              dc.w     $ffff
01014f36  fffe              dc.w     $fffe
01014f38  fbee              dc.w     $fbee
01014f3a  eaa6              asr.l    d5, d6
01014f3c  667a              bne.b    $1014fb8
01014f3e  a992              dc.w     $a992
01014f40  52ba              dc.w     $52ba
01014f42  667a              bne.b    $1014fbe
01014f44  fffe              dc.w     $fffe
01014f46  ffff              dc.w     $ffff
01014f48  ffff              dc.w     $ffff
01014f4a  ffba              dc.w     $ffba
01014f4c  aa99              dc.w     $aa99
01014f4e  996eaa62          sub.w    d4, -$559e(a6)
01014f52  52bf              dc.w     $52bf
01014f54  99fbbbefffff      suba.l   ([$1024f55]), a4
01014f5a  fffb              dc.w     $fffb
01014f5c  feeeea66665f      fbf.l    $eb67b5bd
01014f62  a992              dc.w     $a992
01014f64  52ba              dc.w     $52ba
01014f66  67ae              beq.b    $1014f16
01014f68  eeff              dc.w     $eeff
01014f6a  ffff              dc.w     $ffff
01014f6c  ffff              dc.w     $ffff
01014f6e  efba              rol.l    d7, d2
01014f70  aa99              dc.w     $aa99
01014f72  9566              sub.w    d2, -(a6)
01014f74  ea62              asr.w    d5, d2
01014f76  52bd              dc.w     $52bd
01014f78  9fbb              dc.w     $9fbb
01014f7a  bbefbfff          cmpa.l   -$4001(a7), a5
01014f7e  ffff              dc.w     $ffff
01014f80  feeeaa666555      fbf.l    $ab67b4d7
01014f86  b992              eor.l    d4, (a2)
01014f88  52ba              dc.w     $52ba
01014f8a  7aae              moveq    #$ae, d5
01014f8c  eeff              dc.w     $eeff
01014f8e  ffff              dc.w     $ffff
01014f90  fffe              dc.w     $fffe
01014f92  efba              rol.l    d7, d2
01014f94  a999              dc.w     $a999
01014f96  9556              sub.w    d2, (a6)
01014f98  ae62              dc.w     $ae62
01014f9a  52bd              dc.w     $52bd
01014f9c  baebbbbe          cmpa.w   -$4442(a3), a5
01014fa0  ffff              dc.w     $ffff
01014fa2  ffff              dc.w     $ffff
01014fa4  feeea6665595      fbf.l    $a767a53b
01014faa  7d92              dc.w     $7d92
01014fac  52ba              dc.w     $52ba
01014fae  faaaaeef          fbf.w    $100fe9f
01014fb2  fbff              dc.w     $fbff
01014fb4  ffff              dc.w     $ffff
01014fb6  bbaa9995          eor.l    d5, -$666b(a2)
01014fba  5559              subq.w   #$2, (a1)+
01014fbc  9f62              sub.w    d7, -(a2)
01014fbe  52bd              dc.w     $52bd
01014fc0  eaaa              lsr.l    d5, d2
01014fc2  ebbb              rol.l    d5, d3
01014fc4  bfefffff          cmpa.l   -$1(a7), a7
01014fc8  feea66595666      fbf.l    $675aa630
01014fce  6b92              bmi.b    $1014f62
01014fd0  52bb              dc.w     $52bb
01014fd2  aaaa              dc.w     $aaaa
01014fd4  aaee              dc.w     $aaee
01014fd6  ffff              dc.w     $ffff
01014fd8  fffe              dc.w     $fffe
01014fda  fbba              dc.w     $fbba
01014fdc  9955              sub.w    d4, (a5)
01014fde  5999              subq.l   #$4, (a1)+
01014fe0  aae2              dc.w     $aae2
01014fe2  52bf              dc.w     $52bf
01014fe4  a66a              dc.w     $a66a
01014fe6  aabb              dc.w     $aabb
01014fe8  bbff              dc.w     $bbff
01014fea  ffff              dc.w     $ffff
01014fec  eeaa              lsr.l    d7, d2
01014fee  6555              bcs.b    $1015045
01014ff0  6666              bne.b    $1015058
01014ff2  aad2              dc.w     $aad2
01014ff4  52bf              dc.w     $52bf
01014ff6  999a              sub.l    d4, (a2)+
01014ff8  aaae              dc.w     $aaae
01014ffa  efef              dc.w     $efef
01014ffc  bfff              dc.w     $bfff
01014ffe  fba9              dc.w     $fba9
01015000  9555              sub.w    d2, (a5)
01015002  999a              sub.l    d4, (a2)+
01015004  aae2              dc.w     $aae2
01015006  52be              dc.w     $52be
01015008  6666              bne.b    $1015070
0101500a  aaab              dc.w     $aaab
0101500c  bbff              dc.w     $bbff
0101500e  fffe              dc.w     $fffe
01015010  eea6              asr.l    d7, d6
01015012  5566              subq.w   #$2, -(a6)
01015014  66aa              bne.b    $1014fc0
01015016  aab2              dc.w     $aab2
01015018  52bd              dc.w     $52bd
0101501a  9999              sub.l    d4, (a1)+
0101501c  9aaaaeff          sub.l    -$5101(a2), d5
01015020  ffff              dc.w     $ffff
01015022  fa995599          fbf.w    $101a5bd
01015026  aaaa              dc.w     $aaaa
01015028  aaa2              dc.w     $aaa2
0101502a  52bd              dc.w     $52bd
0101502c  5566              subq.w   #$2, -(a6)
0101502e  66aa              bne.b    $1014fda
01015030  abee              dc.w     $abee
01015032  ffff              dc.w     $ffff
01015034  ea65              asr.w    d5, d5
01015036  6666              bne.b    $101509e
01015038  aaaa              dc.w     $aaaa
0101503a  abb2              dc.w     $abb2
0101503c  52bd              dc.w     $52bd
0101503e  5555              subq.w   #$2, (a5)
01015040  999a              sub.l    d4, (a2)+
01015042  aaff              dc.w     $aaff
01015044  e000              asr.b    #$8, d0
01015046  6995              bvs.b    $1014fdd
01015048  99aaaaae          sub.l    d4, -$5552(a2)
0101504c  eee2              dc.w     $eee2
0101504e  52bd              dc.w     $52bd
01015050  5555              subq.w   #$2, (a5)
01015052  5666              addq.w   #$3, -(a6)
01015054  aabf              dc.w     $aabf
01015056  c155              and.w    d0, (a5)
01015058  0956              bchg.b   d4, (a6)
0101505a  66aa              bne.b    $1015006
0101505c  aabb              dc.w     $aabb
0101505e  bbb252bd          eor.l    d5, -$43(a2, d5.w)
01015062  5555              subq.w   #$2, (a5)
01015064  5559              subq.w   #$2, (a1)+
01015066  9aac1555          sub.l    $1555(a4), d5
0101506a  5059              addq.w   #$8, (a1)+
0101506c  aaaa              dc.w     $aaaa
0101506e  aeee              dc.w     $aeee
01015070  eee2              dc.w     $eee2
01015072  52bd              dc.w     $52bd
01015074  9955              sub.w    d4, (a5)
01015076  5556              subq.w   #$2, (a6)
01015078  6661              bne.b    $10150db
0101507a  550d              dc.w     $550d
0101507c  552aaabb          subq.b   #$2, -$5545(a2)
01015080  bbbb              dc.w     $bbbb
01015082  bbf252be          cmpa.l   -$42(a2, d5.w), a5
01015086  6655              bne.b    $10150dd
01015088  5555              subq.w   #$2, (a5)
0101508a  99b1553d55eaaeee  sub.l    d4, ([$55eaaeee, a1], d5.w * 4)
01015092  eeff              dc.w     $eeff
01015094  ffb2              dc.w     $ffb2
01015096  52bd              dc.w     $52bd
01015098  9999              sub.l    d4, (a1)+
0101509a  5555              subq.w   #$2, (a5)
0101509c  5605              addq.b   #$3, d5
0101509e  5555              subq.w   #$2, (a5)
010150a0  557b              dc.w     $557b
010150a2  bbbf              dc.w     $bbbf
010150a4  ffee              dc.w     $ffee
010150a6  fbf2              dc.w     $fbf2
010150a8  52be              dc.w     $52be
010150aa  6666              bne.b    $1015112
010150ac  6555              bcs.b    $1015103
010150ae  5505              subq.b   #$2, d5
010150b0  5555              subq.w   #$2, (a5)
010150b2  667a              bne.b    $101512e
010150b4  efff              dc.w     $efff
010150b6  efff              dc.w     $efff
010150b8  fff2              dc.w     $fff2
010150ba  52bd              dc.w     $52bd
010150bc  9999              sub.l    d4, (a1)+
010150be  9999              sub.l    d4, (a1)+
010150c0  5515              subq.b   #$2, (a5)
010150c2  5506              subq.b   #$2, d6
010150c4  559f              subq.l   #$2, (a7)+
010150c6  ffbe              dc.w     $ffbe
010150c8  feefbff252be      fbf.l    $c0f3a388
010150ce  aaaa              dc.w     $aaaa
010150d0  a666              dc.w     $a666
010150d2  6616              bne.b    $10150ea
010150d4  541f              addq.b   #$2, (a7)+
010150d6  666e              bne.b    $1015146
010150d8  efff              dc.w     $efff
010150da  ffff              dc.w     $ffff
010150dc  ffb2              dc.w     $ffb2
010150de  52be              dc.w     $52be
010150e0  aaaa              dc.w     $aaaa
010150e2  aaa9              dc.w     $aaa9
010150e4  9a15              sub.b    (a5), d5
010150e6  580f              dc.w     $580f
010150e8  999f              sub.l    d4, (a7)+
010150ea  feefeffffff2      fbf.l    $f10150de
010150f0  52be              dc.w     $52be
010150f2  aaaa              dc.w     $aaaa
010150f4  aaaa              dc.w     $aaaa
010150f6  aa26              dc.w     $aa26
010150f8  663f              bne.b    $1015139
010150fa  666f              bne.b    $101516b
010150fc  ffff              dc.w     $ffff
010150fe  ffff              dc.w     $ffff
01015100  fff2              dc.w     $fff2
01015102  52be              dc.w     $52be
01015104  eaea              dc.w     $eaea
01015106  aaaa              dc.w     $aaaa
01015108  aa19              dc.w     $aa19
0101510a  99bd              dc.w     $99bd
0101510c  99afffff          sub.l    d4, -$1(a7)
01015110  ffff              dc.w     $ffff
01015112  fff2              dc.w     $fff2
01015114  52be              dc.w     $52be
01015116  aaab              dc.w     $aaab
01015118  abbb              dc.w     $abbb
0101511a  bb86              eor.l    d5, d6
0101511c  6666              bne.b    $1015184
0101511e  6abf              bpl.b    $10150df
01015120  ffff              dc.w     $ffff
01015122  ffff              dc.w     $ffff
01015124  fff2              dc.w     $fff2
01015126  52be              dc.w     $52be
01015128  aeae              dc.w     $aeae
0101512a  eeee              dc.w     $eeee
0101512c  efc9              dc.w     $efc9
0101512e  aaaa              dc.w     $aaaa
01015130  a6bf              dc.w     $a6bf
01015132  ffff              dc.w     $ffff
01015134  ffff              dc.w     $ffff
01015136  fff2              dc.w     $fff2
01015138  52bf              dc.w     $52bf
0101513a  bbbb              dc.w     $bbbb
0101513c  bbbb              dc.w     $bbbb
0101513e  fef29a5eaaff      fbf.l    $9b5ffc3f
01015144  ffff              dc.w     $ffff
01015146  ffff              dc.w     $ffff
01015148  fff2              dc.w     $fff2
0101514a  52be              dc.w     $52be
0101514c  eeee              dc.w     $eeee
0101514e  eeff              dc.w     $eeff
01015150  bffcaa7eaafb      cmpa.l   #$aa7eaafb, a7
01015156  ffff              dc.w     $ffff
01015158  ffff              dc.w     $ffff
0101515a  fff2              dc.w     $fff2
0101515c  52bf              dc.w     $52bf
0101515e  abbf              dc.w     $abbf
01015160  bfeffbff          cmpa.l   -$401(a7), a7
01015164  eaaa              lsr.l    d5, d2
01015166  afbf              dc.w     $afbf
01015168  bbff              dc.w     $bbff
0101516a  ffff              dc.w     $ffff
0101516c  fff2              dc.w     $fff2
0101516e  52bf              dc.w     $52bf
01015170  fefbfbfeffff      fbf.l    $fd005171
01015176  beaafabb          cmp.l    -$545(a2), d7
0101517a  ffbf              dc.w     $ffbf
0101517c  ffff              dc.w     $ffff
0101517e  fff2              dc.w     $fff2
01015180  52bf              dc.w     $52bf
01015182  bfbf              dc.w     $bfbf
01015184  bfbf              dc.w     $bfbf
01015186  ffff              dc.w     $ffff
01015188  ffff              dc.w     $ffff
0101518a  5aeefbff          spl.b    -$401(a6)
0101518e  ffff              dc.w     $ffff
01015190  fff2              dc.w     $fff2
01015192  52bf              dc.w     $52bf
01015194  efff              dc.w     $efff
01015196  fbff              dc.w     $fbff
01015198  ffff              dc.w     $ffff
0101519a  ffa6              dc.w     $ffa6
0101519c  56bb              dc.w     $56bb
0101519e  bfbb              dc.w     $bfbb
010151a0  ffff              dc.w     $ffff
010151a2  fff2              dc.w     $fff2
010151a4  52bf              dc.w     $52bf
010151a6  fefbffffffab      fbf.l    $1015153
010151ac  fea659ae          fbf.w    $101ab5c
010151b0  efff              dc.w     $efff
010151b2  ffff              dc.w     $ffff
010151b4  fff2              dc.w     $fff2
010151b6  52bf              dc.w     $52bf
010151b8  bfff              dc.w     $bfff
010151ba  ffff              dc.w     $ffff
010151bc  ff82              dc.w     $ff82
010151be  baa9566b          cmp.l    $566b(a1), d5
010151c2  bbbe              dc.w     $bbbe
010151c4  efbf              rol.l    d7, d7
010151c6  fff2              dc.w     $fff2
010151c8  52bf              dc.w     $52bf
010151ca  ffef              dc.w     $ffef
010151cc  beff              dc.w     $beff
010151ce  ffb0              dc.w     $ffb0
010151d0  baa6              cmp.l    -(a6), d5
010151d2  55aaeeef          subq.l   #$2, -$1111(a2)
010151d6  ffff              dc.w     $ffff
010151d8  ffe2              dc.w     $ffe2
010151da  52bf              dc.w     $52bf
010151dc  fbff              dc.w     $fbff
010151de  ffff              dc.w     $ffff
010151e0  ffec              dc.w     $ffec
010151e2  2a99              move.l   (a1)+, (a5)
010151e4  566abbbb          addq.w   #$3, -$4445(a2)
010151e8  effe              dc.w     $effe
010151ea  ffb2              dc.w     $ffb2
010151ec  52bb              dc.w     $52bb
010151ee  ffff              dc.w     $ffff
010151f0  ffff              dc.w     $ffff
010151f2  fffb              dc.w     $fffb
010151f4  0bb6559aaaee      bclr.b   d5, ([, d5.w * 4], $aaee)
010151fa  fbbf              dc.w     $fbbf
010151fc  efe2              dc.w     $efe2
010151fe  52be              dc.w     $52be
01015200  ffbe              dc.w     $ffbe
01015202  ffff              dc.w     $ffff
01015204  fffe              dc.w     $fffe
01015206  c1ea566a          muls.w   $566a(a2), d0
0101520a  aabb              dc.w     $aabb
0101520c  bfff              dc.w     $bfff
0101520e  ffb2              dc.w     $ffb2
01015210  52bb              dc.w     $52bb
01015212  ffff              dc.w     $ffff
01015214  ffff              dc.w     $ffff
01015216  ffbf              dc.w     $ffbf
01015218  b075559aaaee      cmp.w    ([, d5.w * 4], $aaee), d0
0101521e  eefb              dc.w     $eefb
01015220  ffe2              dc.w     $ffe2
01015222  52be              dc.w     $52be
01015224  ffff              dc.w     $ffff
01015226  ffff              dc.w     $ffff
01015228  fbfb              dc.w     $fbfb
0101522a  ec1e              ror.b    #$6, d6
0101522c  5566              subq.w   #$2, -(a6)
0101522e  aabb              dc.w     $aabb
01015230  bbbf              dc.w     $bbbf
01015232  bfb252bb          eor.l    d7, -$45(a2, d5.w)
01015236  bbff              dc.w     $bbff
01015238  ffff              dc.w     $ffff
0101523a  ffbf              dc.w     $ffbf
0101523c  ff33d559          fsave    ([a3])
01015240  aaae              dc.w     $aaae
01015242  eeef              dc.w     $eeef
01015244  fee252bdefff      fbf.l    $53bf4245
0101524a  ffff              dc.w     $ffff
0101524c  fffe              dc.w     $fffe
0101524e  fec0b5666aab      fbf.l    $b667bcfb
01015254  bbbb              dc.w     $bbbb
01015256  fbb2              dc.w     $fbb2
01015258  52ba              dc.w     $52ba
0101525a  6bbf              bmi.b    $101521b
0101525c  ffff              dc.w     $ffff
0101525e  eeef              dc.w     $eeef
01015260  bff02d59          cmpa.l   ([a0]), a7
01015264  9aaaeeef          sub.l    -$1111(a2), d5
01015268  eaa2              asr.l    d5, d2
0101526a  52bd              dc.w     $52bd
0101526c  aaef              dc.w     $aaef
0101526e  ffff              dc.w     $ffff
01015270  fffe              dc.w     $fffe
01015272  effc              dc.w     $effc
01015274  0756              bchg.b   d3, (a6)
01015276  66ae              bne.b    $1015226
01015278  bbefaab2          cmpa.l   -$554e(a7), a5
0101527c  52ba              dc.w     $52ba
0101527e  6bbb              bmi.b    $101523b
01015280  fffe              dc.w     $fffe
01015282  fffb              dc.w     $fffb
01015284  baef01e5          cmpa.w   $1e5(a7), a5
01015288  9aaaaeff          sub.l    -$5101(a2), d5
0101528c  ffe2              dc.w     $ffe2
0101528e  52bd              dc.w     $52bd
01015290  aefe              dc.w     $aefe
01015292  ffff              dc.w     $ffff
01015294  fbbe              dc.w     $fbbe
01015296  eabf              ror.l    d5, d7
01015298  c02f66aa          and.b    $66aa(a7), d0
0101529c  ebff              dc.w     $ebff
0101529e  ffe2              dc.w     $ffe2
010152a0  52ba              dc.w     $52ba
010152a2  abbf              dc.w     $abbf
010152a4  afef              dc.w     $afef
010152a6  fffb              dc.w     $fffb
010152a8  ba9b              cmp.l    (a3)+, d5
010152aa  f007d9aa          fmovem   d7, invalid
010152ae  beff              dc.w     $beff
010152b0  ffe2              dc.w     $ffe2
010152b2  52be              dc.w     $52be
010152b4  aeff              dc.w     $aeff
010152b6  ebff              dc.w     $ebff
010152b8  beeeeaa6          cmpa.w   -$155a(a6), a7
010152bc  fc00f66b          fmovem   fp1-fp2/fp4/fp6-fp7, d0
010152c0  fffb              dc.w     $fffb
010152c2  bbe2              cmpa.l   -(a2), a5
010152c4  52ba              dc.w     $52ba
010152c6  afff              dc.w     $afff
010152c8  febffffb          fbf.w    $10152c5
010152cc  ae99              dc.w     $ae99
010152ce  af00              dc.w     $af00
010152d0  efbf              rol.l    d7, d7
010152d2  ff90              dc.w     $ff90
010152d4  7ee2              moveq    #$e2, d7
010152d6  52be              dc.w     $52be
010152d8  bd9a              eor.l    d6, (a2)+
010152da  ffeb              dc.w     $ffeb
010152dc  fbee              dc.w     $fbee
010152de  eaa6              asr.l    d5, d6
010152e0  afc3              dc.w     $afc3
010152e2  87ff              dc.w     $87ff
010152e4  ea40              asr.w    #$5, d0
010152e6  0ee2              dc.w     $0ee2
010152e8  52ba              dc.w     $52ba
010152ea  e666              asr.w    d3, d6
010152ec  6ffe              ble.b    $10152ec
010152ee  afbb              dc.w     $afbb
010152f0  ba99              cmp.l    (a1)+, d5
010152f2  6bfe              bmi.b    $10152f2
010152f4  11be              dc.w     $11be
010152f6  be06              cmp.b    d6, d7
010152f8  4ee2              dc.w     $4ee2
010152fa  52bb              dc.w     $52bb
010152fc  9999              sub.l    d4, (a1)+
010152fe  9bff              dc.w     $9bff
01015300  ebee              dc.w     $ebee
01015302  eaa6              asr.l    d5, d6
01015304  5afc              trappl   
01015306  481f              nbcd.b   (a7)+
01015308  cd19              and.b    d6, (a1)+
0101530a  8fa2              or.l     d7, -(a2)
0101530c  52b76666          addq.l   #$1, $66(a7, d6.w)
01015310  67ffffbeaaa9      beq.l    $bffdbb
01015316  56bf              dc.w     $56bf
01015318  0e02              dc.w     $0e02
0101531a  02064fe2          andi.b   #$e2, d6
0101531e  52bd              dc.w     $52bd
01015320  9902              subx.b   d2, d4
01015322  9aff              dc.w     $9aff
01015324  fffe              dc.w     $fffe
01015326  faa6557f          fbf.w    $101a8a7
0101532a  c008              dc.w     $c008
0101532c  1080              move.b   d0, (a0)
0101532e  3fa252be          move.w   -(a2), -$42(a7, d5.w)
01015332  6415              bcc.b    $1015349
01015334  e6ff              dc.w     $e6ff
01015336  ffff              dc.w     $ffff
01015338  feeeefeff020      fbf.l    $f0f1435a
0101533e  543f              dc.w     $543f
01015340  fee2              dc.w     $fee2
01015342  0000              dc.w     $0000

; ---- gap 01015348..01015363 (28 bytes) ----
01015348  0e10              dc.w     $0e10
0101534a  0c0a              dc.w     $0c0a
0101534c  0d00              btst.l   d6, d0
0101534e  0e11              dc.w     $0e11
01015350  0a0003c1          eori.b   #$c1, d0
01015354  05ea0f00          bset.b   d2, $f00(a2)
01015358  ffff              dc.w     $ffff
0101535a  ffff              dc.w     $ffff
0101535c  ffff              dc.w     $ffff
0101535e  ffff              dc.w     $ffff
01015360  ffff              dc.w     $ffff
01015362  ffff              dc.w     $ffff

; ---- gap 0101536e..010160b3 (3398 bytes) ----
0101536e  0e7e              dc.w     $0e7e
01015370  0f98              bclr.b   d7, (a0)+
01015372  0fe2              bset.b   d7, -(a2)
01015374  0f5a              bchg.b   d7, (a2)+
01015376  0e08              dc.w     $0e08
01015378  0bfd              dc.w     $0bfd
0101537a  0956              bchg.b   d4, (a6)
0101537c  063602c8ff39fbb7f871  addi.b   #$c8, ([$fbb7f871, a6, a7.l * 8])
01015386  f593              dc.w     $f593
01015388  f341              frestore ea(0,1)
0101538a  f19a              dc.w     $f19a
0101538c  f0b4f098          fbf.w    $1014426
01015390  f149              dc.w     $f149
01015392  f2bbf4db          fbf.w    $101486f
01015396  f78d              dc.w     $f78d
01015398  faabfe0d          fbf.w    $10151a7
0101539c  0184              bclr.b   d0, d4
0101539e  04e4              dc.w     $04e4
010153a0  0801              dc.w     $0801
010153a2  0ab00ccf0e430ef9  eori.l   #$ccf0e43, -$7(a0, d0.l)
010153aa  0ee8              dc.w     $0ee8
010153ac  0e12              dc.w     $0e12
010153ae  0c820a4f0796      cmpi.l   #$a4f0796, d2
010153b4  047c              dc.w     $047c
010153b6  0129fdcb          btst.l   d0, -$235(a1)
010153ba  fa8df79b          fbf.w    $1014b57
010153be  f51a              pflusha  
010153c0  f32cf1ea          fsave    -$e16(a4)
010153c4  f163              dc.w     $f163
010153c6  f19e              dc.w     $f19e
010153c8  f297f440          fbf.w    $101480a
010153cc  f683f941          fbf.w    $1014d0f
010153d0  fc55ff97          fsor.b   (a5)
010153d4  02da              dc.w     $02da
010153d6  05f508be          bset.b   d2, -$42(a5, d0.l)
010153da  0b10              btst.l   d5, (a0)
010153dc  0cce              dc.w     $0cce
010153de  0de1              bset.b   d6, -(a1)
010153e0  0e3b              dc.w     $0e3b
010153e2  0dd9              bset.b   d6, (a1)+
010153e4  0cc0              dc.w     $0cc0
010153e6  0aff              dc.w     $0aff
010153e8  08af              dc.w     $08af
010153ea  05ee02e2          bset.b   d2, $2e2(a6)
010153ee  ffb4              dc.w     $ffb4
010153f0  fc8cf995          fbf.w    $1014d87
010153f4  f6f5f4d1f342      fbf.l    $f5d34738
010153fa  f25df22d          ftrapor.b (a5)+
010153fe  f2b5f3eb          fbf.w    $10147eb
01015402  f5c1              dc.w     $f5c1
01015404  f81bfadc          fmovem   invalid, (a3)+
01015408  fdde              dc.w     $fdde
0101540a  00f8              dc.w     $00f8
0101540c  040306d6          subi.b   #$d6, d3
01015410  094c0b44          movep.l  $b44(a4), d4
01015414  0ca50d5d0d65      cmpi.l   #$d5d0d65, -(a5)
0101541a  0cbb0b690982071f0460016b  cmpi.l   #$b690982, ([$101541cpc], d0.w * 8, $460016b)
01015426  fe66fb79          ftrapoge.b -(a6)
0101542a  f8cbf67ff4b2      fbf.l    $f78148de
01015430  f37e              frestore ea(7,6)
01015432  f2eff30ef3d9      fbf.l    $f410480d
01015438  f543              dc.w     $f543
0101543a  f739f9a2fc5c      fsave    $f9a2fc5c.l
01015440  ff44              dc.w     $ff44
01015442  023105000789      andi.b   #$0, ([, d0.w * 8])
01015448  09ad0b4e          bclr.b   d4, $b4e(a5)
0101544c  0c580cbe          cmpi.w   #$cbe, (a0)+
01015450  0c7a0b930a13      cmpi.w   #$b93, $1015e65(pc)
01015456  080f              dc.w     $080f
01015458  05a3              bclr.b   d2, -(a3)
0101545a  02ef              dc.w     $02ef
0101545c  0017fd41          ori.b    #$41, (a7)
01015460  fa92f82d          fbf.w    $1014c8f
01015464  f632f4bbf3dbf39cf401  fmovem   fp0/fp2-fp4/fp6-fp7, ([], $f39cf401)
0101546e  f504              pflushn  (a4)
01015470  f697f8a5          fbf.w    $1014d17
01015474  fb13              fsave    (a3)
01015476  fdbf              dc.w     $fdbf
01015478  0085034305d2      ori.l    #$34305d2, d5
0101547e  0812              dc.w     $0812
01015480  09e5              bset.b   d4, -(a5)
01015482  0b330bec0c06      btst.l   d5, $c06(invalid.w)
01015488  0b82              bclr.b   d5, d2
0101548a  0a6508c1          eori.w   #$8c1, -(a5)
0101548e  06aa043d019bfee7  addi.l   #$43d019b, -$119(a2)
01015496  fc44f9d4          fsolt.b  d4
0101549a  f7b9              dc.w     $f7b9
0101549c  f60df4e7f454      move16   $f4e7f454.l, (a5)+
010154a2  f45d              cinva    #$1
010154a4  f4ff              cpusha   #$3
010154a6  f632f7e6fa02      fmovem   fp0-fp2/fp5-fp6, $2(a2, a7.l)
010154ac  fc6cff0301a4      fsoge.b  $1a4(a4)
010154b2  042c067b0872      subi.b   #$7b, $872(a4)
010154b8  09f80af8          bset.b   d4, $af8.w
010154bc  0b66              bchg.b   d5, -(a6)
010154be  0b3c0a7f0937      btst.l   d5, #$a7f0937
010154c4  07770556          bchg.b   d3, ([a7])
010154c8  02f0              dc.w     $02f0
010154ca  0066fddb          ori.w    #$fddb, -(a6)
010154ce  fb6df93e          frestore -$6c2(a5)
010154d2  f76bf60c          frestore -$9f4(a3)
010154d6  f531f4e6          fsave    -$1a(a1, a7.w)
010154da  f52ef605          fsave    -$9fb(a6)
010154de  f75f              frestore (a7)+
010154e0  f92afb4d          fsave    -$4b3(a2)
010154e4  fdad              dc.w     $fdad
010154e6  0027029e          ori.b    #$9e, -(a7)
010154ea  04f0              dc.w     $04f0
010154ec  06fe              dc.w     $06fe
010154ee  08ae              dc.w     $08ae
010154f0  09e90aa0          bset.b   d4, $aa0(a1)
010154f4  0ac9              dc.w     $0ac9
010154f6  0a640976          eori.w   #$976, -(a4)
010154fa  080c              dc.w     $080c
010154fc  0638041501bd      addi.b   #$15, $1bd.w
01015502  ff52              frestore (a2)
01015504  fcf1fabcf8ce      fbf.l    $fbbe4dd4
0101550a  f741              dc.w     $f741
0101550c  f62af595f58b      fmovem   fp0/fp3/fp5/fp7, -$a75(a2)
01015512  f60cf70ff888      move16   $f70ff888.l, (a4)+
01015518  fa62fc84          fsolt.b  -(a2)
0101551c  fed2012d0376      fbf.l    $22e5894
01015522  0590              bclr.b   d2, (a0)
01015524  075d              bchg.b   d3, (a5)+
01015526  08c8              dc.w     $08c8
01015528  09bd              dc.w     $09bd
0101552a  0a300a1c0982086b  eori.b   #$1c, ([, d0.l], $86b)
01015532  06e6              dc.w     $06e6
01015534  050802e9          movep.w  $2e9(a0), d2
01015538  00a5fe5cfc2b      ori.l    #$fe5cfc2b, -(a5)
0101553e  fa2ef880f737      fmovem   invalid, -$8c9(a6)
01015544  f664f610          fsf.b    -(a4)
01015548  f640f6f1          fssub.b  d0
0101554c  f819f9a9          fmovem   invalid, (a1)+
01015550  fb8a              dc.w     $fb8a
01015552  fda5              dc.w     $fda5
01015554  ffdd              dc.w     $ffdd
01015556  0213042c          andi.b   #$2c, (a3)
0101555a  060d              dc.w     $060d
0101555c  079b              bclr.b   d3, (a3)+
0101555e  08c3              dc.w     $08c3
01015560  097609ab0960089a0762  bchg.b   d4, ([$960, d0.l], $89a0762)
0101556a  05cb03e8          movep.l  d2, $3e8(a3)
0101556e  01d3              bset.b   d0, (a3)
01015570  ffaa              dc.w     $ffaa
01015572  fd86              dc.w     $fd86
01015574  fb85              dc.w     $fb85
01015576  f9c1              dc.w     $f9c1
01015578  f852f74a          fsugt.b  (a2)
0101557c  f6b6f69d          fbf.w    $1014c1b
01015580  f701              dc.w     $f701
01015582  f7db              dc.w     $f7db
01015584  f920              fsave    -(a0)
01015586  fabffca2          fbf.w    $101522a
0101558a  feaf00ca          fbf.w    $1015656
0101558e  02da              dc.w     $02da
01015590  04c2              dc.w     $04c2
01015592  066907ba08a3      addi.w   #$7ba, $8a3(a1)
01015598  0919              btst.l   d4, (a1)+
0101559a  0916              btst.l   d4, (a6)
0101559c  089b              dc.w     $089b
0101559e  07af065e          bclr.b   d3, $65e(a7)
010155a2  04ba              dc.w     $04ba
010155a4  02da              dc.w     $02da
010155a6  00d6              dc.w     $00d6
010155a8  fec9fccefaff      fbf.l    $fdd050a9
010155ae  f974f841          frestore $41(a4, a7.l)
010155b2  f776f71d          frestore ([a6], a7.w * 8)
010155b6  f739f7caf8c6      fsave    $f7caf8c6.l
010155bc  fa21fbc8          fmovem   invalid, -(a1)
010155c0  fda6              dc.w     $fda6
010155c2  ffa0              dc.w     $ffa0
010155c4  019d              bclr.b   d0, (a5)+
010155c6  0383              bclr.b   d1, d3
010155c8  053806a7          btst.l   d2, $6a7.w
010155cc  07bd              dc.w     $07bd
010155ce  086b              dc.w     $086b
010155d0  08a9              dc.w     $08a9
010155d2  0874              dc.w     $0874
010155d4  07d0              bset.b   d3, (a0)
010155d6  06c5              dc.w     $6c5
010155d8  0561              bchg.b   d2, -(a1)
010155da  03b801e0          bclr.b   d1, $1e0.w
010155de  fff1              dc.w     $fff1
010155e0  fe04fc34          fmovem   invalid, d4
010155e4  fa97f944          fbf.w    $1014f2a
010155e8  f84bf7b9f795      fdbf     d3, $1014d81
010155ee  f7e1              dc.w     $f7e1
010155f0  f897f9af          fbf.w    $1014fa1
010155f4  fb19              dc.w     $fb19
010155f6  fcc3fe960078      fbf.l    $ff975670
010155fc  0254040f          andi.w   #$40f, (a4)
01015600  0592              bclr.b   d2, (a2)
01015602  06ca              dc.w     $6ca
01015604  07a7              bclr.b   d3, -(a7)
01015606  081e              dc.w     $081e
01015608  0829              dc.w     $0829
0101560a  07c80701          movep.l  d3, $701(a0)
0101560e  05de              bset.b   d2, (a6)+
01015610  046e02c600fa      subi.w   #$2c6, $fa(a6)
01015616  ff24              fsave    -(a4)
01015618  fd5b              frestore (a3)+
0101561a  fbb6              dc.w     $fbb6
0101561c  fa4cf92ef86c      fdbf     d4, $1014e8c
01015622  f80ff81b          fmovem   invalid, a7
01015626  f890f966          fbf.w    $1014f8e
0101562a  fa93fc07          fbf.w    $1015233
0101562e  fdad              dc.w     $fdad
01015630  ff71013902f0047f  frestore ([$2f0047f, a1, d0.w])
01015638  05d0              bset.b   d2, (a0)
0101563a  06d4              dc.w     $06d4
0101563c  077c              dc.w     $077c
0101563e  07c0              bset.b   d3, d0
01015640  079d              bclr.b   d3, (a5)+
01015642  0716              btst.l   d3, (a6)
01015644  063204fd038701e4002a  addi.b   #$fd, ([], d0.w * 2, $1e4002a)
0101564e  fe70fccbfb53fa1af930  fsuge.b  ([a0], $fa1af930)
01015658  f8a2f875          fbf.w    $1014ecf
0101565c  f8acf944          fbf.w    $1014fa2
01015660  fa34fb71fce8      fmovem   invalid, -$18(a4, a7.l)
01015666  fe860036          fbf.w    $101569e
0101566a  01e2              bset.b   d0, -(a2)
0101566c  037304d5          bchg.b   d1, -$2b(a3, d0.w)
01015670  05f606c6          bset.b   d2, -$3a(a6, d0.w)
01015674  073d              dc.w     $073d
01015676  0753              bchg.b   d3, (a3)
01015678  07080661          movep.w  $661(a0), d3
0101567c  0566              bchg.b   d2, -(a6)
0101567e  042402ad          subi.b   #$ad, -(a4)
01015682  0114              btst.l   d0, (a4)
01015684  ff70fdd3fc55fb09  frestore ([], $fc55fb09)
0101568c  fa00f948          fmovem   invalid, d0
01015690  f8e9f8e8f945      fbf.l    $f9ea4fd7
01015696  f9fb              dc.w     $f9fb
01015698  fafffc45fdba      fbf.l    $fd475454
0101569e  ff4d              dc.w     $ff4d
010156a0  00e6              dc.w     $00e6
010156a2  027203dd0513060406a5  andi.w   #$3dd, ([a2, d0.w * 4], $60406a5)
010156ac  06ee              dc.w     $06ee
010156ae  06db              dc.w     $06db
010156b0  066d05aa049e      addi.w   #$5aa, $49e(a5)
010156b6  0355              bchg.b   d1, (a5)
010156b8  01e2              bset.b   d0, -(a2)
010156ba  0057feca          ori.w    #$feca, (a7)
010156be  fd4e              dc.w     $fd4e
010156c0  fbf7              dc.w     $fbf7
010156c2  fad7f9fcf972      fbf.l    $fafe5036
010156c8  f93f              dc.w     $f93f
010156ca  f965              dc.w     $f965
010156cc  f9e3              dc.w     $f9e3
010156ce  fab1fbc4          fbf.w    $1015294
010156d2  fd0e              dc.w     $fd0e
010156d4  fe7e              dc.w     $fe7e
010156d6  00000180          ori.b    #$80, d0
010156da  02ec              dc.w     $02ec
010156dc  042f053a05fe      subi.b   #$3a, $5fe(a7)
010156e2  067306910659      addi.w   #$691, $59(a3, d0.w)
010156e8  05cd04f5          movep.l  d2, $4f5(a5)
010156ec  03dc              bset.b   d1, (a4)+
010156ee  02920126ffae      andi.l   #$126ffae, (a2)
010156f4  fe3bfce0fbb0fabbfa0c  fmovem   invalid, $fabbfa0c(a7.l * 2)
010156fe  f9ad              dc.w     $f9ad
01015700  f9a1              dc.w     $f9a1
01015702  f9ea              dc.w     $f9ea
01015704  fa83fb64          fbf.w    $101526a
01015708  fc81fdcc          fbf.w    $10154d6
0101570c  ff3200a0          fsave    -$60(a2, d0.w)
01015710  0206034f          andi.b   #$4f, d6
01015714  046b054c05e6      subi.w   #$54c, $5e6(a3)
0101571a  0631062a05d1      addi.b   #$2a, ([])
01015720  052c0443          btst.l   d2, $443(a4)
01015724  0323              btst.l   d1, -(a3)
01015726  01db              bset.b   d0, (a3)+
01015728  007b              dc.w     $007b
0101572a  ff17              fsave    (a7)
0101572c  fdc0              dc.w     $fdc0
0101572e  fc87fb7e          fbf.w    $10152ae
01015732  fab2fa2d          fbf.w    $1015161
01015736  f9f5              dc.w     $f9f5
01015738  fa0dfa74          fmovem   invalid, a5
0101573c  fb24              fsave    -(a4)
0101573e  fc13fd36          fmovem   invalid, (a3)
01015742  fe7cffd5          ftrapole 
01015746  012e0276          btst.l   d0, $276(a6)
0101574a  039d              bclr.b   d1, (a5)+
0101574c  0493054c05bd      subi.l   #$54c05bd, (a3)
01015752  05e2              bset.b   d2, -(a2)
01015754  05ba              dc.w     $05ba
01015756  0546              bchg.b   d2, d6
01015758  048c              dc.w     $048c
0101575a  0397              bclr.b   d1, (a7)
0101575c  02740131ffe1fe93  andi.w   #$131, ([$fe93])
01015764  fd59              frestore (a1)+
01015766  fc43fb60          fsub.b   d3
0101576a  fabbfa5c          fbf.w    $10151c8
0101576e  fa49fa81fb01      fdbf     d1, $1015273
01015774  fbc3              dc.w     $fbc3
01015776  fcbdfde0          fbf.w    $1015558
0101577a  ff1e              dc.w     $ff1e
0101577c  006601a8          ori.w    #$1a8, -(a6)
01015780  02d3              dc.w     $02d3
01015782  03d8              bset.b   d1, (a0)+
01015784  04a8053a0587058a  subi.l   #$53a0587, $58a(a0)
0101578c  0543              bchg.b   d2, d3
0101578e  04b803ee02f201cf  subi.l   #$3ee02f2, $1cf.w
01015796  0096ff57fe21      ori.l    #$ff57fe21, (a6)
0101579c  fd05              dc.w     $fd05
0101579e  fc12fb54          fmovem   invalid, (a2)
010157a2  fad4fa99faa6      fbf.l    $fb9b524a
010157a8  faf9fb8ffc5f      fbf.l    $fc915409
010157ae  fd5e              frestore (a6)+
010157b0  fe7f              dc.w     $fe7f
010157b2  ffb2              dc.w     $ffb2
010157b4  00e8              dc.w     $00e8
010157b6  0211031e          andi.b   #$1e, (a1)
010157ba  040004ac          subi.b   #$ac, d0
010157be  051b              btst.l   d2, (a3)+
010157c0  0545              bchg.b   d2, d5
010157c2  052904c9          btst.l   d2, $4c9(a1)
010157c6  042a03550255      subi.b   #$55, $255(a2)
010157cc  01360009          btst.l   d0, $9(a6, d0.w)
010157d0  fedefdc1fcc4      fbf.l    $fec35496
010157d6  fbf2              dc.w     $fbf2
010157d8  fb57              frestore (a7)
010157da  fafafae0fb0a      fbf.l    $fbe252e6
010157e0  fb75fc1c          frestore $1c(a5, a7.l)
010157e4  fcf6fdf7ff12      fbf.l    $fef956f8
010157ea  003701590268      ori.b    #$59, $68(a7, d0.w)
010157f0  0356              bchg.b   d1, (a6)
010157f2  041704a1          subi.b   #$a1, (a7)
010157f6  04ee              dc.w     $04ee
010157f8  04f9              dc.w     $04f9
010157fa  04c2              dc.w     $04c2
010157fc  044c              dc.w     $044c
010157fe  039e              bclr.b   d1, (a6)+
01015800  02c1              dc.w     $02c1
01015802  01c1              bset.b   d0, d1
01015804  00aaff8cfe75fd73  ori.l    #$ff8cfe75, -$28d(a2)
0101580c  fc94fbe3          fbf.w    $10153f1
01015810  fb69fb2d          frestore -$4d3(a1)
01015814  fb30fb73fbf2fca6fd86fe86  fsave    ([$fbf2fca6, a0], $fd86fe86)
01015820  ff98              dc.w     $ff98
01015822  00ad01b902ae037e  ori.l    #$1b902ae, $37e(a5)
0101582a  041f0489          subi.b   #$89, (a7)+
0101582e  04b604a5045703cf  subi.l   #$4a50457, ([])
01015836  0316              btst.l   d1, (a6)
01015838  02350137002a      andi.b   #$37, $2a(a5, d0.w)
0101583e  ff1d              dc.w     $ff1d
01015840  fe1cfd35          fmovem   invalid, (a4)+
01015844  fc74fbe2fb88      fdsub.b  (a7.l * 2)
0101584a  fb69fb87          frestore -$479(a1)
0101584e  fbe0              dc.w     $fbe0
01015850  fc6ffd2cfe0f      ftrapogl.b -$1f1(a7)
01015856  ff0a              dc.w     $ff0a
01015858  00100115          ori.b    #$15, (a0)
0101585c  020a              dc.w     $020a
0101585e  02e4              dc.w     $02e4
01015860  0397              bclr.b   d1, (a7)
01015862  04190465          subi.b   #$65, (a1)+
01015866  0476044c03e90354  subi.w   #$44c, ([$354])
0101586e  029201b000b8      andi.l   #$1b000b8, (a2)
01015874  ffb8              dc.w     $ffb8
01015876  febdfdd3          fbf.w    $101564b
0101587a  fd06              dc.w     $fd06
0101587c  fc62fbef          ftrapueq.b -(a2)
01015880  fbb1              dc.w     $fbb1
01015882  fbad              dc.w     $fbad
01015884  fbe2              dc.w     $fbe2
01015886  fc4efce9fdad      fdbf     d6, $1015637
0101588c  fe8fff83          fbf.w    $1015811
01015890  007c016e          ori.w    #$16e, sr
01015894  024c              dc.w     $024c
01015896  030b03a1          movep.w  $3a1(a3), d1
0101589a  04070436          subi.b   #$36, d7
0101589e  042e03ee037b      subi.b   #$ee, $37b(a6)
010158a4  02da              dc.w     $02da
010158a6  02140134          andi.b   #$34, (a4)
010158aa  0044ff53          ori.w    #$ff53, d4
010158ae  fe6afd98fce6      fsun.b   -$31a(a2)
010158b4  fc5efc07          fsor.b   (a6)+
010158b8  fbe4              dc.w     $fbe4
010158ba  fbf8              dc.w     $fbf8
010158bc  fc41fcbc          ftrapogl.b d1
010158c0  fd61              dc.w     $fd61
010158c2  fe28ff07fff2      fmovem   invalid, -$e(a0)
010158c8  00db              dc.w     $00db
010158ca  01b902800325      bclr.b   d0, $2800325.l
010158d0  039f              bclr.b   d1, (a7)+
010158d2  03e903ff          bset.b   d1, $3ff(a1)
010158d6  03e1              bset.b   d1, -(a1)
010158d8  038e030e          movep.w  d1, $30e(a6)
010158dc  0265019d          andi.w   #$19d, -(a5)
010158e0  00c1              dc.w     $00c1
010158e2  ffdd              dc.w     $ffdd
010158e4  fefafe26fd6b      fbf.l    $ff285651
010158ea  fcd3fc66fc29      fbf.l    $fd685515
010158f0  fc1ffc48          fmovem   invalid, (a7)+
010158f4  fca2fd28          fbf.w    $101561e
010158f8  fdd4              dc.w     $fdd4
010158fa  fe9cff75          fbf.w    $1015871
010158fe  0053012e          ori.w    #$12e, (a3)
01015902  01f702a6          bset.b   d0, -$5a(a7, d0.w)
01015906  0332039203c3      btst.l   d1, ([, d0.w * 2], $3c3)
0101590c  03c2              bset.b   d1, d2
0101590e  038f032d          movep.w  d1, $32d(a7)
01015912  02a201f4012e      andi.l   #$1f4012e, -(a2)
01015918  0058ff80          ori.w    #$ff80, (a0)+
0101591c  feaefdef          fbf.w    $101570d
01015920  fd4b              dc.w     $fd4b
01015922  fcccfc78fc53      fbf.l    $fd7a5577
01015928  fc5ffc9b          fsuge.b  (a7)+
0101592c  fd03              dc.w     $fd03
0101592e  fd93              dc.w     $fd93
01015930  fe42ff07          fsor.b   d2
01015934  ffd9              dc.w     $ffd9
01015936  00aa0173022802c0  ori.l    #$1730228, $2c0(a2)
0101593e  0333037b0395037f033b02cc  btst.l   d1, ([$395037f, a3], $33b02cc)
0101594a  0239018a00c6fffa  andi.b   #$8a, $c6fffa.l
01015952  ff2efe6e          fsave    -$192(a6)
01015956  fdc4              dc.w     $fdc4
01015958  fd37fcd0          fsave    -$30(a7, a7.l)
0101595c  fc94fc85          fbf.w    $10155e3
01015960  fca4fcf0          fbf.w    $1015652
01015964  fd64              dc.w     $fd64
01015966  fdf9              dc.w     $fdf9
01015968  fea9ff6a          fbf.w    $10158d4
0101596c  003100f601ad024d  ori.b    #$f6, ([$24d], d0.w)
01015974  02cf              dc.w     $02cf
01015976  032a035b          btst.l   d1, $35b(a2)
0101597a  0360              bchg.b   d1, -(a0)
0101597c  033802e5          btst.l   d1, $2e5.w
01015980  026d01d50125      andi.w   #$1d5, $125(a5)
01015986  0067ffa5          ori.w    #$ffa5, -(a7)
0101598a  fee8fe3afda4      fbf.l    $ff3c5730
01015990  fd2efcde          fsave    -$322(a6)
01015994  fcb7fcbd          fbf.w    $1015653
01015998  fcedfd45fdc2      fbf.l    $fe47575c
0101599e  fe5cff0a          fsugt.b  (a4)+
010159a2  ffc5              dc.w     $ffc5
010159a4  0081013701dc      ori.l    #$13701dc, d1
010159aa  026702d2          andi.w   #$2d2, -(a7)
010159ae  0318              btst.l   d1, (a0)+
010159b0  0334032602ee0290  btst.l   d1, ([$2ee, a4], d0.w * 2, $290)
010159b8  02100175          andi.b   #$75, (a0)
010159bc  00c8              dc.w     $00c8
010159be  0011ff5b          ori.b    #$5b, (a1)
010159c2  feadfe11          fbf.w    $10157d5
010159c6  fd90              dc.w     $fd90
010159c8  fd2ffcf4          fsave    -$30c(a7)
010159cc  fce2fcf8fd37      fbf.l    $fdfa5705
010159d2  fd9b              dc.w     $fd9b
010159d4  fe1dfeb9          fmovem   invalid, (a5)+
010159d8  ff64              dc.w     $ff64
010159da  001600c7          ori.b    #$c7, (a6)
010159de  016d01ff          bchg.b   d0, $1ff(a5)
010159e2  027702cd02fe      andi.w   #$2cd, -$2(a7, d0.w)
010159e8  0307              btst.l   d1, d7
010159ea  02e8              dc.w     $02e8
010159ec  02a3023b01b6      andi.l   #$23b01b6, -(a3)
010159f2  011b              btst.l   d0, (a3)+
010159f4  0072ffc5ff1afe7c  ori.w    #$ffc5, ([a2, a7.l * 8], $fe7c)
010159fc  fdf3              dc.w     $fdf3
010159fe  fd85              dc.w     $fd85
01015a00  fd39fd12fd11      fsave    $fd12fd11.l
01015a06  fd38fd83          fsave    $fd83.w
01015a0a  fdee              dc.w     $fdee
01015a0c  fe75ff10ffb6005f01030199  fsf.b    ([$5f0103], a7.l * 8, $199)
01015a18  0219027d          andi.b   #$7d, (a1)+
01015a1c  02bf              dc.w     $02bf
01015a1e  02dd              dc.w     $02dd
01015a20  02d5              dc.w     $02d5
01015a22  02a8025801e80161  andi.l   #$25801e8, $161(a0)
01015a2a  00c7              dc.w     $00c7
01015a2c  0024ff80          ori.b    #$80, -(a4)
01015a30  fee3fe55fdde      fbf.l    $ff575810
01015a36  fd84              dc.w     $fd84
01015a38  fd4a              dc.w     $fd4a
01015a3a  fd35fd45          fsave    ([a5])
01015a3e  fd79fdcefe40      frestore $fdcefe40.l
01015a44  fec8ff610000      fbf.l    $625a46
01015a4a  009f013501bb      ori.l    #$13501bb, (a7)+
01015a50  0229027a02aa      andi.b   #$7a, $2aa(a1)
01015a56  02b702a00266020d  andi.l   #$2a00266, $d(a7, d0.w)
01015a5e  0198              bclr.b   d0, (a0)+
01015a60  0110              btst.l   d0, (a0)
01015a62  0079ffdeff45feb6  ori.w    #$ffde, $ff45feb6.l
01015a6a  fe38fdd2fd8a      fmovem   invalid, $fd8a.w
01015a70  fd63              dc.w     $fd63
01015a72  fd5e              frestore (a6)+
01015a74  fd7cfdbb          frestore #$bb
01015a78  fe18fe8e          fmovem   invalid, (a0)+
01015a7c  ff17              fsave    (a7)
01015a7e  ffab              dc.w     $ffab
01015a80  004200d6          ori.w    #$d6, d2
01015a84  015e              bchg.b   d0, (a6)+
01015a86  01d4              bset.b   d0, (a4)
01015a88  02300270028f      andi.b   #$70, -$71(a0, d0.w)
01015a8e  028c              dc.w     $028c
01015a90  0268022301c3      andi.w   #$223, $1c3(a0)
01015a96  014c00c4          movep.l  $c4(a4), d0
01015a9a  0032ffa0ff12fe91  ori.b    #$a0, ([a2, a7.l * 8], $fe91)
01015aa2  fe23fdcf          fmovem   invalid, -(a3)
01015aa6  fd98              dc.w     $fd98
01015aa8  fd80              dc.w     $fd80
01015aaa  fd8b              dc.w     $fd8b
01015aac  fdb5              dc.w     $fdb5
01015aae  fdfe              dc.w     $fdfe
01015ab0  fe61fed9          fsueq.b  -(a1)
01015ab4  ff60              dc.w     $ff60
01015ab6  ffee              dc.w     $ffee
01015ab8  007c0104          ori.w    #$104, sr
01015abc  017e              dc.w     $017e
01015abe  01e4              bset.b   d0, -(a4)
01015ac0  0230025f026f      andi.b   #$5f, $6f(a0, d0.w)
01015ac6  025e022e          andi.w   #$22e, (a6)+
01015aca  01e1              bset.b   d0, -(a1)
01015acc  017c              dc.w     $017c
01015ace  0103              btst.l   d0, d3
01015ad0  007e              dc.w     $007e
01015ad2  fff3              dc.w     $fff3
01015ad4  ff69fee7          frestore -$119(a1)
01015ad8  fe75fe17fdd2fdab  fsor.b   ([], $fdab)
01015ae0  fda3              dc.w     $fda3
01015ae2  fdba              dc.w     $fdba
01015ae4  fdef              dc.w     $fdef
01015ae6  fe40fea7          ftrapeq.b d0
01015aea  ff1f              dc.w     $ff1f
01015aec  ffa3              dc.w     $ffa3
01015aee  002a00af012b      ori.b    #$af, $12b(a2)
01015af4  0197              bclr.b   d0, (a7)
01015af6  01ed0229          bset.b   d0, $229(a5)
01015afa  0249              dc.w     $0249
01015afc  024a              dc.w     $024a
01015afe  022d01f301a0      andi.b   #$f3, $1a0(a5)
01015b04  013700bf          btst.l   d0, -$41(a7, d0.w)
01015b08  003e              dc.w     $003e
01015b0a  ffba              dc.w     $ffba
01015b0c  ff3a              dc.w     $ff3a
01015b0e  fec5fe60fe11      fbf.l    $ff625921
01015b14  fddd              dc.w     $fddd
01015b16  fdc4              dc.w     $fdc4
01015b18  fdca              dc.w     $fdca
01015b1a  fdec              dc.w     $fdec
01015b1c  fe2afe80fee9      fmovem   invalid, -$117(a2)
01015b22  ff61              dc.w     $ff61
01015b24  ffe0              dc.w     $ffe0
01015b26  006000da          ori.w    #$da, -(a0)
01015b2a  014a01a7          movep.l  $1a7(a2), d0
01015b2e  01ef021c          bset.b   d0, $21c(a7)
01015b32  022d022201fa      andi.b   #$22, $1fa(a5)
01015b38  01b9016100f6      bclr.b   d0, $16100f6.l
01015b3e  00800004ff88      ori.l    #$4ff88, d0
01015b44  ff13              fsave    (a3)
01015b46  feaafe53          fbf.w    $101599b
01015b4a  fe13fded          fmovem   invalid, (a3)
01015b4e  fde2              dc.w     $fde2
01015b50  fdf3              dc.w     $fdf3
01015b52  fe1ffe64          fmovem   invalid, (a7)+
01015b56  febeff29          fbf.w    $1015a81
01015b5a  ff9e              dc.w     $ff9e
01015b5c  0016008e          ori.b    #$8e, (a6)
01015b60  00fe              dc.w     $00fe
01015b62  0161              bchg.b   d0, -(a1)
01015b64  01b101ea020a020e  bclr.b   d0, ([$20a], $20e)
01015b6c  01f701c7          bset.b   d0, ([])
01015b70  017f              dc.w     $017f
01015b72  0123              btst.l   d0, -(a3)
01015b74  00b90046ffd0ff5dfef2  ori.l    #$46ffd0, $ff5dfef2.l
01015b7e  fe96fe4d          fbf.w    $10159cd
01015b82  fe1afe01          fmovem   invalid, (a2)+
01015b86  fe03fe1f          fmovem   invalid, d3
01015b8a  fe53fe9e          fsne.b   (a3)
01015b8e  fefaff64ffd5      fbf.l    $665b65
01015b94  004700b6          ori.w    #$b6, d7
01015b98  011b              btst.l   d0, (a3)+
01015b9a  017101b401e001f3  bchg.b   d0, $1e001f3(d0.w)
01015ba2  01ec01cb          bset.b   d0, $1cb(a4)
01015ba6  0193              bclr.b   d0, (a3)
01015ba8  0146              bchg.b   d0, d6
01015baa  00e9              dc.w     $00e9
01015bac  00800011ffa3      ori.l    #$11ffa3, d0
01015bb2  ff38fed9          fsave    $fed9.w
01015bb6  fe89fe4d          fbf.w    $1015a05
01015bba  fe27fe1a          fmovem   invalid, -(a7)
01015bbe  fe27fe4b          fmovem   invalid, -(a7)
01015bc2  fe87fed5          fbf.w    $1015a99
01015bc6  ff33ff9b00060072  fsave    ([, a7.l * 8], $60072)
01015bce  00d8              dc.w     $00d8
01015bd0  0132017c01b201d1  btst.l   d0, $1b201d1(a2, invalid.w)
01015bd8  01d8              bset.b   d0, (a0)+
01015bda  01c7              bset.b   d0, d7
01015bdc  019e              bclr.b   d0, (a6)+
01015bde  0160              bchg.b   d0, -(a0)
01015be0  0110              btst.l   d0, (a0)
01015be2  00b2004cffe3ff7bff1afec5  ori.l    #$4cffe3, ([$ff1afec5, a2], $aaaaaaaa)
01015bee  fe81fe52          fbf.w    $1015a42
01015bf2  fe38fe37fe4d      fmovem   invalid, $fe4d.w
01015bf8  fe79feb9ff0aff68  ftrapoge.b $ff0aff68.l
01015c00  ffcd              dc.w     $ffcd
01015c02  0033009700f3      ori.b    #$97, -$d(a3, d0.w)
01015c08  0142              bchg.b   d0, d2
01015c0a  0180              bclr.b   d0, d0
01015c0c  01aa01be          bclr.b   d0, $1be(a2)
01015c10  01ba              dc.w     $01ba
01015c12  01a0              bclr.b   d0, -(a0)
01015c14  0170012e00dc007f  bchg.b   d0, ([$dc, a0], d0.w, $7f)
01015c1c  001cffb9          ori.b    #$b9, (a4)+
01015c20  ff59              frestore (a1)+
01015c22  ff02              dc.w     $ff02
01015c24  feb8fe80          fbf.w    $1015aa6
01015c28  fe5cfe4d          fsule.b  (a4)+
01015c2c  fe56fe74          ftanh.b  (a6)
01015c30  fea6feeb          fbf.w    $1015b1d
01015c34  ff3d              dc.w     $ff3d
01015c36  ff99              dc.w     $ff99
01015c38  fffa              dc.w     $fffa
01015c3a  005a00b6          ori.w    #$b6, (a2)+
01015c3e  0108014d          movep.w  $14d(a0), d0
01015c42  017f              dc.w     $017f
01015c44  019e              bclr.b   d0, (a6)+
01015c46  01a7              bclr.b   d0, -(a7)
01015c48  019a              bclr.b   d0, (a2)+
01015c4a  01780143          bchg.b   d0, $143.w
01015c4e  00fd              dc.w     $00fd
01015c50  00ab0050fff2ff94  ori.l    #$50fff2, -$6c(a3)
01015c58  ff3c              dc.w     $ff3c
01015c5a  feeffeb0fe83      fbf.l    $ffb25adf
01015c60  fe6afe65fe76      ftentox.b -$18a(a2)
01015c66  fe9cfed3          fbf.w    $1015b3b
01015c6a  ff1a              dc.w     $ff1a
01015c6c  ff6dffc7          frestore -$39(a5)
01015c70  0022007c          ori.b    #$7c, -(a2)
01015c74  00d0              dc.w     $00d0
01015c76  0118              btst.l   d0, (a0)+
01015c78  0152              bchg.b   d0, (a2)
01015c7a  017a              dc.w     $017a
01015c7c  018e018d          movep.w  d0, $18d(a6)
01015c80  01780150          bchg.b   d0, $150.w
01015c84  0116              btst.l   d0, (a6)
01015c86  00cf              dc.w     $00cf
01015c88  007d              dc.w     $007d
01015c8a  0024ffcb          ori.b    #$cb, -(a4)
01015c8e  ff75ff25fee2      frestore ([$fee2, a5], a7.l * 8)
01015c94  feadfe8b          fbf.w    $1015b21
01015c98  fe7bfe80fe99fec4  ftrapf.w #$fe99fec4
01015ca0  feffff48ff99      fbf.l    $4a5c3b
01015ca6  fff0              dc.w     $fff0
01015ca8  00460099          ori.w    #$99, d6
01015cac  00e4              dc.w     $00e4
01015cae  0123              btst.l   d0, -(a3)
01015cb0  0152              bchg.b   d0, (a2)
01015cb2  0170017b01720156012800eb  bchg.b   d0, ([$1720156, a0], $12800eb)
01015cbe  00a30052fffe      ori.l    #$52fffe, -(a3)
01015cc4  ffaa              dc.w     $ffaa
01015cc6  ff5a              frestore (a2)+
01015cc8  ff14              fsave    (a4)
01015cca  fedafeaffe96      fbf.l    $ffb15b62
01015cd0  fe90fe9d          fbf.w    $1015b6f
01015cd4  febcfeec          fbf.w    $1015bc2
01015cd8  ff2aff73          fsave    -$8d(a2)
01015cdc  ffc2              dc.w     $ffc2
01015cde  00140065          ori.b    #$65, (a4)
01015ce2  00b100f30129014f  ori.l    #$f30129, ([a1])
01015cea  0163              bchg.b   d0, -(a3)
01015cec  0165              bchg.b   d0, -(a5)
01015cee  0154              bchg.b   d0, (a4)
01015cf0  01320101          btst.l   d0, ([a2, d0.w])
01015cf4  00c2              dc.w     $00c2
01015cf6  0079002affdbff8d  ori.w    #$2a, $ffdbff8d.l
01015cfe  ff45              dc.w     $ff45
01015d00  ff07              dc.w     $ff07
01015d02  fed6feb5fea5      fbf.l    $ffb75ba9
01015d08  fea7febb          fbf.w    $1015bc5
01015d0c  fedfff13ff52      fbf.l    $155c60
01015d12  ff9b              dc.w     $ff9b
01015d14  ffe8              dc.w     $ffe8
01015d16  0035008000c4      ori.b    #$80, -$3c(a5, d0.w)
01015d1c  00fe              dc.w     $00fe
01015d1e  012a0147          btst.l   d0, $147(a2)
01015d22  0153              bchg.b   d0, (a3)
01015d24  014d0136          movep.l  $136(a5), d0
01015d28  010f00da          movep.w  $da(a7), d0
01015d2c  009a00520007      ori.l    #$520007, (a2)+
01015d32  ffbc              dc.w     $ffbc
01015d34  ff74ff34fefefed6  frestore $fefefed6(a4, a7.l * 8)
01015d3c  febefeb6          fbf.w    $1015bf4
01015d40  fec0fedaff03      fbf.l    $ffdc5c45
01015d46  ff39ff79ffc0      fsave    $ff79ffc0.l
01015d4c  0009              dc.w     $0009
01015d4e  00520097          ori.w    #$97, (a2)
01015d52  00d3              dc.w     $00d3
01015d54  0105              btst.l   d0, d5
01015d56  0128013d          btst.l   d0, $13d(a0)
01015d5a  0140              bchg.b   d0, d0
01015d5c  0134011700ec00b5  btst.l   d0, ([a4], d0.w, $ec00b5)
01015d64  0075002fffe8ffa1  ori.w    #$2f, $ffa1(invalid.w)
01015d6c  ff60              dc.w     $ff60
01015d6e  ff27              fsave    -(a7)
01015d70  fefafedafeca      fbf.l    $ffdc5c3c
01015d76  fecafedafef9      fbf.l    $ffdc5c71
01015d7c  ff25              fsave    -(a5)
01015d7e  ff5d              frestore (a5)+
01015d80  ff9d              dc.w     $ff9d
01015d82  ffe2              dc.w     $ffe2
01015d84  0027006b          ori.b    #$6b, -(a7)
01015d88  00a900de01070123  ori.l    #$de0107, $123(a1)
01015d90  012f012c          btst.l   d0, $12c(a7)
01015d94  0119              btst.l   d0, (a1)+
01015d96  00f8              dc.w     $00f8
01015d98  00ca              dc.w     $00ca
01015d9a  00920052000f      ori.l    #$52000f, (a2)
01015da0  ffcc              dc.w     $ffcc
01015da2  ff8a              dc.w     $ff8a
01015da4  ff50              frestore (a0)
01015da6  ff1f              dc.w     $ff1f
01015da8  fef9fee1fed9      fbf.l    $ffe35c83
01015dae  fedffef5ff18      fbf.l    $fff75cc8
01015db4  ff47              dc.w     $ff47
01015db6  ff7f              dc.w     $ff7f
01015db8  ffbe              dc.w     $ffbe
01015dba  00000041          ori.b    #$41, d0
01015dbe  007f              dc.w     $007f
01015dc0  00b700e40106011a011f  ori.l    #$e40106, ([a7, d0.w], $11f)
01015dca  0116              btst.l   d0, (a6)
01015dcc  00fe              dc.w     $00fe
01015dce  00d9              dc.w     $00d9
01015dd0  00a900700032fff2  ori.l    #$700032, -$e(a1)
01015dd8  ffb3              dc.w     $ffb3
01015dda  ff78ff44          frestore $ff44.w
01015dde  ff1a              dc.w     $ff1a
01015de0  fefcfeebfee9      fbf.l    $ffed5ccb
01015de6  fef6ff10ff37      fbf.l    $125d1f
01015dec  ff67              dc.w     $ff67
01015dee  ffa0              dc.w     $ffa0
01015df0  ffdd              dc.w     $ffdd
01015df2  001b0058          ori.b    #$58, (a3)+
01015df6  009000c100e7      ori.l    #$c100e7, (a0)
01015dfc  0102              btst.l   d0, d2
01015dfe  010f010d          movep.w  $10d(a7), d0
01015e02  00fe              dc.w     $00fe
01015e04  00e2              dc.w     $00e2
01015e06  00ba              dc.w     $00ba
01015e08  0089              dc.w     $0089
01015e0a  00510015          ori.w    #$15, (a1)
01015e0e  ffd9              dc.w     $ffd9
01015e10  ff9e              dc.w     $ff9e
01015e12  ff68ff3b          frestore -$c5(a0)
01015e16  ff18              dc.w     $ff18
01015e18  ff01              dc.w     $ff01
01015e1a  fef8fefcff0e      fbf.l    $fffe5d2a
01015e20  ff2cff55          fsave    -$ab(a4)
01015e24  ff86              dc.w     $ff86
01015e26  ffbe              dc.w     $ffbe
01015e28  fff9              dc.w     $fff9
01015e2a  0033006b009e      ori.b    #$6b, -$62(a3, d0.w)
01015e30  00c8              dc.w     $00c8
01015e32  00e7              dc.w     $00e7
01015e34  00fb              dc.w     $00fb
01015e36  0101              btst.l   d0, d1
01015e38  00fa              dc.w     $00fa
01015e3a  00e6              dc.w     $00e6
01015e3c  00c7              dc.w     $00c7
01015e3e  009d006b0034      ori.l    #$6b0034, (a5)+
01015e44  fffb              dc.w     $fffb
01015e46  ffc2              dc.w     $ffc2
01015e48  ff8c              dc.w     $ff8c
01015e4a  ff5d              frestore (a5)+
01015e4c  ff36ff1aff09      fsave    ([a6, a7.l * 8], $ff09)
01015e52  ff06              dc.w     $ff06
01015e54  ff10              fsave    (a0)
01015e56  ff26              fsave    -(a6)
01015e58  ff47              dc.w     $ff47
01015e5a  ff71ffa3ffda00110048  frestore ([$ffda, a7.l * 8], $110048)
01015e64  007b              dc.w     $007b
01015e66  00a800cc00e500f2  ori.l    #$cc00e5, $f2(a0)
01015e6e  00f2              dc.w     $00f2
01015e70  00e6              dc.w     $00e6
01015e72  00ce              dc.w     $00ce
01015e74  00ac0081004f0019  ori.l    #$81004f, $19(a4)
01015e7c  ffe4              dc.w     $ffe4
01015e7e  ffaf              dc.w     $ffaf
01015e80  ff7e              dc.w     $ff7e
01015e82  ff54              frestore (a4)
01015e84  ff34ff1eff14      fsave    ([a4], a7.l * 8, $ff14)
01015e8a  ff16              fsave    (a6)
01015e8c  ff24              fsave    -(a4)
01015e8e  ff3e              dc.w     $ff3e
01015e90  ff61              dc.w     $ff61
01015e92  ff8d              dc.w     $ff8d
01015e94  ffbe              dc.w     $ffbe
01015e96  fff3              dc.w     $fff3
01015e98  0027005a          ori.b    #$5a, -(a7)
01015e9c  0088              dc.w     $0088
01015e9e  00af00cc00df00e6  ori.l    #$cc00df, $e6(a7)
01015ea6  00e2              dc.w     $00e2
01015ea8  00d1              dc.w     $00d1
01015eaa  00b6009200660035  ori.l    #$920066, $35(a6, d0.w)
01015eb2  0001ffcf          ori.b    #$cf, d1
01015eb6  ff9e              dc.w     $ff9e
01015eb8  ff73ff4f          frestore ([a3])
01015ebc  ff34ff24ff20      fsave    $ff20(a4, a7.l * 8)
01015ec2  ff27              fsave    -(a7)
01015ec4  ff39ff56ff7b      fsave    $ff56ff7b.l
01015eca  ffa7              dc.w     $ffa7
01015ecc  ffd8              dc.w     $ffd8
01015ece  0009              dc.w     $0009
01015ed0  003b              dc.w     $003b
01015ed2  0069009200b3      ori.w    #$92, $b3(a1)
01015ed8  00ca              dc.w     $00ca
01015eda  00d7              dc.w     $00d7
01015edc  00d9              dc.w     $00d9
01015ede  00d0              dc.w     $00d0
01015ee0  00bc              dc.w     $00bc
01015ee2  009e0078004c      ori.l    #$78004c, (a6)+
01015ee8  001dffed          ori.b    #$ed, (a5)+
01015eec  ffbd              dc.w     $ffbd
01015eee  ff91              dc.w     $ff91
01015ef0  ff6bff4c          frestore -$b4(a3)
01015ef4  ff37ff2dff2e      fsave    ([$ff2e, a7], a7.l * 8)
01015efa  ff39ff4fff6e      fsave    $ff4fff6e.l
01015f00  ff94              dc.w     $ff94
01015f02  ffc0              dc.w     $ffc0
01015f04  ffef              dc.w     $ffef
01015f06  001d004b          ori.b    #$4b, (a5)+
01015f0a  0075009800b4      ori.w    #$98, -$4c(a5, d0.w)
01015f10  00c6              dc.w     $00c6
01015f12  00ce              dc.w     $00ce
01015f14  00cb              dc.w     $00cb
01015f16  00be              dc.w     $00be
01015f18  00a600870060      ori.l    #$870060, -(a6)
01015f1e  00350007ffdaffae  ori.b    #$7, ([], $ffae)
01015f26  ff86              dc.w     $ff86
01015f28  ff65              dc.w     $ff65
01015f2a  ff4c              dc.w     $ff4c
01015f2c  ff3d              dc.w     $ff3d
01015f2e  ff37ff3dff4cff64  fsave    ([$ff4cff64, a7], a7.l * 8)
01015f36  ff85              dc.w     $ff85
01015f38  ffab              dc.w     $ffab
01015f3a  ffd6              dc.w     $ffd6
01015f3c  0002002f          ori.b    #$2f, d2
01015f40  0059007e          ori.w    #$7e, (a1)+
01015f44  009d00b300c0      ori.l    #$b300c0, (a5)+
01015f4a  00c3              dc.w     $00c3
01015f4c  00bc              dc.w     $00bc
01015f4e  00ab009100700049  ori.l    #$910070, $49(a3)
01015f56  001ffff4          ori.b    #$f4, (a7)+
01015f5a  ffc9              dc.w     $ffc9
01015f5c  ffa1              dc.w     $ffa1
01015f5e  ff7e              dc.w     $ff7e
01015f60  ff62              dc.w     $ff62
01015f62  ff4e              dc.w     $ff4e
01015f64  ff44              dc.w     $ff44
01015f66  ff43              dc.w     $ff43
01015f68  ff4c              dc.w     $ff4c
01015f6a  ff5f              frestore (a7)+
01015f6c  ff79ff9bffc1      frestore $ff9bffc1.l
01015f72  ffeb              dc.w     $ffeb
01015f74  0015003e          ori.b    #$3e, (a5)
01015f78  00640085          ori.w    #$85, -(a4)
01015f7c  009f00b000b8      ori.l    #$b000b8, (a7)+
01015f82  00b700ac0098007d  ori.l    #$ac0098, $7d(a7, d0.w)
01015f8a  005b0034          ori.w    #$34, (a3)+
01015f8e  000b              dc.w     $000b
01015f90  ffe3              dc.w     $ffe3
01015f92  ffbb              dc.w     $ffbb
01015f94  ff97              dc.w     $ff97
01015f96  ff79ff61ff52      frestore $ff61ff52.l
01015f9c  ff4d              dc.w     $ff4d
01015f9e  ff50              frestore (a0)
01015fa0  ff5c              frestore (a4)+
01015fa2  ff71ff8effb0      frestore ([], a7.l * 8, $ffb0)
01015fa8  ffd6              dc.w     $ffd6
01015faa  fffe              dc.w     $fffe
01015fac  0025004b          ori.b    #$4b, -(a5)
01015fb0  006d0089009e      ori.w    #$89, $9e(a5)
01015fb6  00ab00af00a9009b  ori.l    #$af00a9, $9b(a3)
01015fbe  008500680046      ori.l    #$680046, d5
01015fc4  0021fffa          ori.b    #$fa, -(a1)
01015fc8  ffd4              dc.w     $ffd4
01015fca  ffaf              dc.w     $ffaf
01015fcc  ff8f              dc.w     $ff8f
01015fce  ff75ff63ff58ff56ff5e  frestore ([$ff58, a5], $ff56ff5e)
01015fd8  ff6dff84          frestore -$7c(a5)
01015fdc  ffa1              dc.w     $ffa1
01015fde  ffc3              dc.w     $ffc3
01015fe0  ffe9              dc.w     $ffe9
01015fe2  000e              dc.w     $000e
01015fe4  003300560074      ori.b    #$56, $74(a3, d0.w)
01015fea  008b              dc.w     $008b
01015fec  009c00a400a4      ori.l    #$a400a4, (a4)+
01015ff2  009b008b0073      ori.l    #$8b0073, (a3)+
01015ff8  00550033          ori.w    #$33, (a5)
01015ffc  000f              dc.w     $000f
01015ffe  ffeb              dc.w     $ffeb
01016000  ffc7              dc.w     $ffc7
01016002  ffa6              dc.w     $ffa6
01016004  ff8a              dc.w     $ff8a
01016006  ff74ff66ff60      frestore ([$ff60, a4])
0101600c  ff62              dc.w     $ff62
0101600e  ff6cff7e          frestore -$82(a4)
01016012  ff96              dc.w     $ff96
01016014  ffb4              dc.w     $ffb4
01016016  ffd6              dc.w     $ffd6
01016018  fffa              dc.w     $fffa
0101601a  001d003f          ori.b    #$3f, (a5)+
0101601e  005e0078          ori.w    #$78, (a6)+
01016022  008c              dc.w     $008c
01016024  0098009c0099      ori.l    #$9c0099, (a0)+
0101602a  008d              dc.w     $008d
0101602c  007a              dc.w     $007a
0101602e  00610043          ori.w    #$43, -(a1)
01016032  0022ffff          ori.b    #$ff, -(a2)
01016036  ffdd              dc.w     $ffdd
01016038  ffbc              dc.w     $ffbc
0101603a  ff9f              dc.w     $ff9f
0101603c  ff87              dc.w     $ff87
0101603e  ff75ff6bff68ff6dff7a  frestore ([$ff68, a5], $ff6dff7a)
01016048  ff8e              dc.w     $ff8e
0101604a  ffa8              dc.w     $ffa8
0101604c  ffc6              dc.w     $ffc6
0101604e  ffe7              dc.w     $ffe7
01016050  0008              dc.w     $0008
01016052  002a00490064      ori.b    #$49, $64(a2)
01016058  007a              dc.w     $007a
0101605a  008a              dc.w     $008a
0101605c  00930093008d      ori.l    #$93008d, (a3)
01016062  007e              dc.w     $007e
01016064  006a00500032      ori.w    #$50, $32(a2)
0101606a  0011fff1          ori.b    #$f1, (a1)
0101606e  ffd1              dc.w     $ffd1
01016070  ffb3              dc.w     $ffb3
01016072  ff99              dc.w     $ff99
01016074  ff85              dc.w     $ff85
01016076  ff77ff71ff72ff7a  frestore ([$ff72ff7a, a7])
0101607e  ff89              dc.w     $ff89
01016080  ff9e              dc.w     $ff9e
01016082  ffb8              dc.w     $ffb8
01016084  ffd6              dc.w     $ffd6
01016086  fff6              dc.w     $fff6
01016088  00160035          ori.b    #$35, (a6)
0101608c  00510069          ori.w    #$69, (a1)
01016090  007b              dc.w     $007b
01016092  0087008c0089      ori.l    #$8c0089, d7
01016098  00800070005a      ori.l    #$70005a, d0
0101609e  003f              dc.w     $003f
010160a0  00220003          ori.b    #$3, -(a2)
010160a4  4448              dc.w     $4448
010160a6  4c00              dc.w     $4c00
010160a8  4347              dc.w     $4347
010160aa  4b00              chk.l    d0, d5
010160ac  4246              clr.w    d6
010160ae  4a00              tst.b    d0
010160b0  4145              dc.w     $4145
010160b2  4900              chk.l    d0, d4

; ---- gap 01016102..0101622f (302 bytes) ----
01016102  0801              dc.w     $0801
01016104  02a001c80101      andi.l   #$1c80101, -(a0)
0101610a  33aa09220280      move.w   $922(a2), -$80(a1, d0.w)
01016110  01df              bset.b   d0, (a7)+
01016112  0101              btst.l   d0, d1
01016114  288c              move.l   a4, (a4)
01016116  0a0102a0          eori.b   #$a0, d1
0101611a  01d0              bset.b   d0, (a0)
0101611c  0101              btst.l   d0, d1
0101611e  33fa05220226017c  move.w   $1016642(pc), $226017c.l
01016126  0100              btst.l   d0, d0
01016128  fa6b0c000280      fsf.b    $280(a3)
0101612e  01df              bset.b   d0, (a7)+
01016130  0101              btst.l   d0, d1
01016132  288c              move.l   a4, (a4)
01016134  0d22              btst.l   d6, -(a2)
01016136  029801c90101      andi.l   #$1c90101, (a0)+
0101613c  344a              movea.w  a2, a2
0101613e  0c220226          cmpi.b   #$26, -(a2)
01016142  0186              bclr.b   d0, d6
01016144  0100              btst.l   d0, d0
01016146  fa7c0f00          ftrapf   
0101614a  028001df0101      andi.l   #$1df0101, d0
01016150  288c              move.l   a4, (a4)
01016152  1022              move.b   -(a2), d0
01016154  028001d00101      andi.l   #$1d00101, d0
0101615a  34f60f220226017c  move.w   ([$226, a6, d0.l * 8], $17c), (a2)+
01016162  0100              btst.l   d0, d0
01016164  fa421200          fsf.b    d2
01016168  028001e50101      andi.l   #$1e50101, d0
0101616e  43b61305          chk.w    ([a6], d1.w * 2), d1
01016172  028001e00101      andi.l   #$1e00101, d0
01016178  4a06              tst.b    d6
0101617a  1405              move.b   d5, d2
0101617c  028001e00101      andi.l   #$1e00101, d0
01016182  4ea4              dc.w     $4ea4
01016184  1205              move.b   d5, d1
01016186  02260186          andi.b   #$86, -(a6)
0101618a  0100              btst.l   d0, d0
0101618c  fa851600          fbf.w    $101778e
01016190  028001e50101      andi.l   #$1e50101, d0
01016196  43b61644          chk.w    $44(a6, d1.w), d1
0101619a  0226017c          andi.b   #$7c, -(a6)
0101619e  0100              btst.l   d0, d0
010161a0  fa901800          fbf.w    $10179a2
010161a4  028001df0101      andi.l   #$1df0101, d0
010161aa  372e1905          move.w   $1905(a6), -(a3)
010161ae  028001df0101      andi.l   #$1df0101, d0
010161b4  3bce              dc.w     $3bce
010161b6  1a05              move.b   d5, d5
010161b8  028001df0101      andi.l   #$1df0101, d0
010161be  3fbe              dc.w     $3fbe
010161c0  1805              move.b   d5, d4
010161c2  02260186          andi.b   #$86, -(a6)
010161c6  0100              btst.l   d0, d0
010161c8  faa91c00          fbf.w    $1017dca
010161cc  028001df0101      andi.l   #$1df0101, d0
010161d2  372e1c44          move.w   $1c44(a6), -(a3)
010161d6  0226017c          andi.b   #$7c, -(a6)
010161da  0100              btst.l   d0, d0
010161dc  fab51e44          fbf.w    $1018022
010161e0  028001df0101      andi.l   #$1df0101, d0
010161e6  288c              move.l   a4, (a4)
010161e8  1f05              move.b   d5, -(a7)
010161ea  028001d00101      andi.l   #$1d00101, d0
010161f0  2d982005          move.l   (a0)+, $5(a6, d2.w)
010161f4  028001d00101      andi.l   #$1d00101, d0
010161fa  306c1e05          movea.w  $1e05(a4), a0
010161fe  02260186          andi.b   #$86, -(a6)
01016202  0100              btst.l   d0, d0
01016204  fa7c2200          ftrapf   
01016208  028001df0101      andi.l   #$1df0101, d0
0101620e  288c              move.l   a4, (a4)
01016210  2322              move.l   -(a2), -(a1)
01016212  028001d00101      andi.l   #$1d00101, d0
01016218  34f62222          move.w   $22(a6, d2.w), (a2)+
0101621c  0226017c          andi.b   #$7c, -(a6)
01016220  0100              btst.l   d0, d0
01016222  fa582500          fsf.b    (a0)+
01016226  028001df0101      andi.l   #$1df0101, d0
0101622c  288c              move.l   a4, (a4)
0101622e  2601              move.l   d1, d3

; ---- gap 0101629c..010162a9 (14 bytes) ----
0101629c  ffff              dc.w     $ffff
0101629e  0100              btst.l   d0, d0
010162a0  fb2d0101          fsave    $101(a5)
010162a4  6dec              blt.b    $1016292
010162a6  0101              btst.l   d0, d1
010162a8  6f96              ble.b    $1016240

; ---- gap 010162b0..010162bd (14 bytes) ----
010162b0  040b              dc.w     $040b
010162b2  0100              btst.l   d0, d0
010162b4  fb3d              dc.w     $fb3d
010162b6  0101              btst.l   d0, d1
010162b8  6dec              blt.b    $10162a6
010162ba  0101              btst.l   d0, d1
010162bc  6fdc              ble.b    $101629a

; ---- gap 010162c0..010162e1 (34 bytes) ----
010162c0  fb40              dc.w     $fb40
010162c2  1d21              move.b   -(a1), -(a6)
010162c4  24ff              dc.w     $24ff
010162c6  00000000          ori.b    #$0, d0
010162ca  00000000          ori.b    #$0, d0
010162ce  00000000          ori.b    #$0, d0
010162d2  00000000          ori.b    #$0, d0
010162d6  00000000          ori.b    #$0, d0
010162da  0000ffff          ori.b    #$ff, d0
010162de  ffff              dc.w     $ffff
010162e0  ffff              dc.w     $ffff

; ---- gap 010162f8..010165ef (760 bytes) ----
010162f8  020e              dc.w     $020e
010162fa  0000dc0d          ori.b    #$d, d0
010162fe  0305              btst.l   d1, d5
01016300  f700              dc.w     $f700
01016302  a614              dc.w     $a614
01016304  0a0d              dc.w     $0a0d
01016306  0000b012          ori.b    #$12, d0
0101630a  0910              btst.l   d4, (a0)
0101630c  0200b914          andi.b   #$14, d0
01016310  0e0d              dc.w     $0e0d
01016312  0000ce14          ori.b    #$14, d0
01016316  0c0d              dc.w     $0c0d
01016318  0000eb0d          ori.b    #$d, d0
0101631c  0205f700          andi.b   #$0, d5
01016320  c300              abcd.b   d0, d1
01016322  04120400          subi.b   #$0, (a2)
01016326  c900              abcd.b   d0, d4
01016328  04120400          subi.b   #$0, (a2)
0101632c  e21a              ror.b    #$1, d2
0101632e  0507              btst.l   d2, d7
01016330  fa00da15          fmovem   d0, invalid
01016334  080a              dc.w     $080a
01016336  ff00              dc.w     $ff00
01016338  e811              roxr.b   #$4, d1
0101633a  02050300          andi.b   #$0, d5
0101633e  00000000          ori.b    #$0, d0
01016342  0000ed14          ori.b    #$14, d0
01016346  02020000          andi.b   #$0, d2
0101634a  f014050e          fsin     fp1, fp2
0101634e  00003e14          ori.b    #$14, d0
01016352  080d              dc.w     $080d
01016354  00004614          ori.b    #$14, d0
01016358  050d0000          movep.w  $0(a5), d2
0101635c  4b14              chk.l    (a4), d5
0101635e  080d              dc.w     $080d
01016360  00005314          ori.b    #$14, d0
01016364  080d              dc.w     $080d
01016366  00005b14          ori.b    #$14, d0
0101636a  090d0000          movep.w  $0(a5), d4
0101636e  6414              bcc.b    $1016384
01016370  080d              dc.w     $080d
01016372  00006c14          ori.b    #$14, d0
01016376  080d              dc.w     $080d
01016378  00007414          ori.b    #$14, d0
0101637c  080d              dc.w     $080d
0101637e  00007c14          ori.b    #$14, d0
01016382  080d              dc.w     $080d
01016384  00008414          ori.b    #$14, d0
01016388  080d              dc.w     $080d
0101638a  0000e604          ori.b    #$4, d0
0101638e  020a              dc.w     $020a
01016390  0000e601          ori.b    #$1, d0
01016394  020d              dc.w     $020d
01016396  0300              btst.l   d1, d0
01016398  e425              asr.b    d2, d5
0101639a  0809              dc.w     $0809
0101639c  fe000000          fmove    fp0, fp0
010163a0  00000000          ori.b    #$0, d0
010163a4  ec25              asr.b    d6, d5
010163a6  0809              dc.w     $0809
010163a8  fe00dd23          fmovem   d0, invalid
010163ac  070e0000          movep.w  $0(a6), d3
010163b0  9612              sub.b    (a2), d3
010163b2  1010              move.b   (a0), d0
010163b4  0100              btst.l   d0, d0
010163b6  0123              btst.l   d0, -(a3)
010163b8  0c0e              dc.w     $0c0e
010163ba  00000d23          ori.b    #$23, d0
010163be  0b0e0000          movep.w  $0(a6), d5
010163c2  1823              move.b   -(a3), d4
010163c4  0c0e              dc.w     $0c0e
010163c6  00002423          ori.b    #$23, d0
010163ca  0b0e0000          movep.w  $0(a6), d5
010163ce  2f23              move.l   -(a3), -(a7)
010163d0  090e0000          movep.w  $0(a6), d4
010163d4  3823              move.w   -(a3), d4
010163d6  090e0000          movep.w  $0(a6), d4
010163da  4123              chk.l    -(a3), d0
010163dc  0c0e              dc.w     $0c0e
010163de  00004d23          ori.b    #$23, d0
010163e2  0b0e0000          movep.w  $0(a6), d5
010163e6  5823              addq.b   #$4, -(a3)
010163e8  020e              dc.w     $020e
010163ea  00005a23          ori.b    #$23, d0
010163ee  080e              dc.w     $080e
010163f0  00006223          ori.b    #$23, d0
010163f4  0c0e              dc.w     $0c0e
010163f6  00006e23          ori.b    #$23, d0
010163fa  080e              dc.w     $080e
010163fc  00007623          ori.b    #$23, d0
01016400  0e0e              dc.w     $0e0e
01016402  00008423          ori.b    #$23, d0
01016406  0b0e0000          movep.w  $0(a6), d5
0101640a  8f23              or.b     d7, -(a3)
0101640c  0d0e0000          movep.w  $0(a6), d6
01016410  9c23              sub.b    -(a3), d6
01016412  0a0e              dc.w     $0a0e
01016414  0000a622          ori.b    #$22, d0
01016418  0d0f0100          movep.w  $100(a7), d6
0101641c  b323              eor.b    d1, -(a3)
0101641e  0a0e              dc.w     $0a0e
01016420  0000bd23          ori.b    #$23, d0
01016424  0b0e0000          movep.w  $0(a6), d5
01016428  c823              and.b    -(a3), d4
0101642a  0a0e              dc.w     $0a0e
0101642c  0000d223          ori.b    #$23, d0
01016430  0b0e0000          movep.w  $0(a6), d5
01016434  0114              btst.l   d0, (a4)
01016436  0c0e              dc.w     $0c0e
01016438  00000d14          ori.b    #$14, d0
0101643c  100e              dc.w     $100e
0101643e  00001d14          ori.b    #$14, d0
01016442  0b0e0000          movep.w  $0(a6), d5
01016446  2814              move.l   (a4), d4
01016448  0c0e              dc.w     $0c0e
0101644a  00003414          ori.b    #$14, d0
0101644e  0a0e              dc.w     $0a0e
01016450  0000ef00          ori.b    #$0, d0
01016454  04120400          subi.b   #$0, (a2)
01016458  f804050e          fsin     fp1, fp2
0101645c  0000f300          ori.b    #$0, d0
01016460  04120400          subi.b   #$0, (a2)
01016464  c71d              and.b    d3, (a5)+
01016466  0704              btst.l   d3, d4
01016468  f700              dc.w     $f700
0101646a  dc04              add.b    d4, d6
0101646c  0901              btst.l   d4, d1
0101646e  00000000          ori.b    #$0, d0
01016472  00000000          ori.b    #$0, d0
01016476  0104              btst.l   d0, d4
01016478  070a0000          movep.w  $0(a2), d3
0101647c  0804              dc.w     $0804
0101647e  090e0000          movep.w  $0(a6), d4
01016482  1104              move.b   d4, -(a0)
01016484  080a              dc.w     $080a
01016486  00001904          ori.b    #$4, d0
0101648a  090e0000          movep.w  $0(a6), d4
0101648e  2204              move.l   d4, d1
01016490  080a              dc.w     $080a
01016492  00002a04          ori.b    #$4, d0
01016496  060e              dc.w     $060e
01016498  00003000          ori.b    #$0, d0
0101649c  090e0400          movep.w  $400(a6), d4
010164a0  3904              move.w   d4, -(a4)
010164a2  080e              dc.w     $080e
010164a4  00004304          ori.b    #$4, d0
010164a8  020e              dc.w     $020e
010164aa  00004100          ori.b    #$0, d0
010164ae  04120400          subi.b   #$0, (a2)
010164b2  4504              chk.l    d4, d2
010164b4  080e              dc.w     $080e
010164b6  00004d04          ori.b    #$4, d0
010164ba  020e              dc.w     $020e
010164bc  00004f04          ori.b    #$4, d0
010164c0  0c0a              dc.w     $0c0a
010164c2  00005b04          ori.b    #$4, d0
010164c6  080a              dc.w     $080a
010164c8  00006304          ori.b    #$4, d0
010164cc  090a0000          movep.w  $0(a2), d4
010164d0  6c00090e          bge.w    $1016de0
010164d4  04007500          subi.b   #$0, d0
010164d8  090e0400          movep.w  $400(a6), d4
010164dc  7e04              moveq    #$4, d7
010164de  050a0000          movep.w  $0(a2), d2
010164e2  8304              sbcd.b   d4, d1
010164e4  070a0000          movep.w  $0(a2), d3
010164e8  8a04              or.b     d4, d5
010164ea  060d              dc.w     $060d
010164ec  00009004          ori.b    #$4, d0
010164f0  080a              dc.w     $080a
010164f2  00009804          ori.b    #$4, d0
010164f6  080a              dc.w     $080a
010164f8  0000a004          ori.b    #$4, d0
010164fc  0c0a              dc.w     $0c0a
010164fe  0000ac04          ori.b    #$4, d0
01016502  080a              dc.w     $080a
01016504  0000b400          ori.b    #$0, d0
01016508  080e              dc.w     $080e
0101650a  0400bc04          subi.b   #$4, d0
0101650e  070a0000          movep.w  $0(a2), d3
01016512  cd00              abcd.b   d0, d6
01016514  06120400          addi.b   #$0, (a2)
01016518  da00              add.b    d0, d5
0101651a  0112              btst.l   d0, (a2)
0101651c  0400d300          subi.b   #$0, d0
01016520  06120400          addi.b   #$0, (a2)
01016524  00000000          ori.b    #$0, d0
01016528  00000000          ori.b    #$0, d0
0101652c  00000000          ori.b    #$0, d0
01016530  00000000          ori.b    #$0, d0
01016534  00000000          ori.b    #$0, d0
01016538  00000000          ori.b    #$0, d0
0101653c  00000000          ori.b    #$0, d0
01016540  00000000          ori.b    #$0, d0
01016544  00000000          ori.b    #$0, d0
01016548  00000000          ori.b    #$0, d0
0101654c  00000000          ori.b    #$0, d0
01016550  00000000          ori.b    #$0, d0
01016554  00000000          ori.b    #$0, d0
01016558  00000000          ori.b    #$0, d0
0101655c  00000000          ori.b    #$0, d0
01016560  00000000          ori.b    #$0, d0
01016564  00000000          ori.b    #$0, d0
01016568  00000000          ori.b    #$0, d0
0101656c  00000000          ori.b    #$0, d0
01016570  00000000          ori.b    #$0, d0
01016574  00000000          ori.b    #$0, d0
01016578  00000000          ori.b    #$0, d0
0101657c  00000000          ori.b    #$0, d0
01016580  00000000          ori.b    #$0, d0
01016584  00000000          ori.b    #$0, d0
01016588  00000000          ori.b    #$0, d0
0101658c  00000000          ori.b    #$0, d0
01016590  00000000          ori.b    #$0, d0
01016594  00000000          ori.b    #$0, d0
01016598  00000000          ori.b    #$0, d0
0101659c  00000000          ori.b    #$0, d0
010165a0  00000000          ori.b    #$0, d0
010165a4  00000000          ori.b    #$0, d0
010165a8  00000000          ori.b    #$0, d0
010165ac  00000000          ori.b    #$0, d0
010165b0  00000000          ori.b    #$0, d0
010165b4  00000000          ori.b    #$0, d0
010165b8  00000000          ori.b    #$0, d0
010165bc  00000000          ori.b    #$0, d0
010165c0  00000000          ori.b    #$0, d0
010165c4  00000000          ori.b    #$0, d0
010165c8  00000000          ori.b    #$0, d0
010165cc  00000000          ori.b    #$0, d0
010165d0  00000000          ori.b    #$0, d0
010165d4  00000000          ori.b    #$0, d0
010165d8  00000000          ori.b    #$0, d0
010165dc  00000000          ori.b    #$0, d0
010165e0  00000000          ori.b    #$0, d0
010165e4  00000000          ori.b    #$0, d0
010165e8  00000000          ori.b    #$0, d0
010165ec  00000000          ori.b    #$0, d0

; ---- gap 01016614..0101661b (8 bytes) ----
01016614  00f3              dc.w     $00f3
01016616  0111              btst.l   d0, (a1)
01016618  0130014e          btst.l   d0, ([a0])

; ---- gap 0101662e..0101663b (14 bytes) ----
0101662e  7b34              dc.w     $7b34
01016630  0100              btst.l   d0, d0
01016632  7bd2              dc.w     $7bd2
01016634  00000000          ori.b    #$0, d0
01016638  00000000          ori.b    #$0, d0

; ---- gap 0101664a..01016653 (10 bytes) ----
0101664a  7f26              dc.w     $7f26
0101664c  0100              btst.l   d0, d0
0101664e  7c4c              moveq    #$4c, d6
01016650  00000001          ori.b    #$1, d0

; ---- gap 01016672..010168db (618 bytes) ----
01016672  004f              dc.w     $004f
01016674  00700050010301030100  ori.w    #$50, ([a0, d0.w], $1030100)
0101667e  0100              btst.l   d0, d0
01016680  00300030002e      ori.b    #$30, $2e(a0, d0.w)
01016686  002e000d000d      ori.b    #$d, $d(a6)
0101668c  0100              btst.l   d0, d0
0101668e  0100              btst.l   d0, d0
01016690  0104              btst.l   d0, d4
01016692  0104              btst.l   d0, d4
01016694  0105              btst.l   d0, d5
01016696  0105              btst.l   d0, d5
01016698  003100310034      ori.b    #$31, $34(a1, d0.w)
0101669e  003400360036      ori.b    #$36, $36(a4, d0.w)
010166a4  00330033002b      ori.b    #$33, $2b(a3, d0.w)
010166aa  002b01060106      ori.b    #$6, $106(a3)
010166b0  003200320035      ori.b    #$32, $35(a2, d0.w)
010166b6  00350107010701080108  ori.b    #$7, ([a5], d0.w, $1080108)
010166c0  007f              dc.w     $007f
010166c2  0008              dc.w     $0008
010166c4  003d              dc.w     $003d
010166c6  002b002d005f      ori.b    #$2d, $5f(a3)
010166cc  0038002a0039      ori.b    #$2a, $39.w
010166d2  002800300029      ori.b    #$30, $29(a0)
010166d8  003700370038      ori.b    #$37, $38(a7, d0.w)
010166de  003800390039      ori.b    #$39, $39.w
010166e4  002d002d002a      ori.b    #$2d, $2a(a5)
010166ea  002a0060007e      ori.b    #$60, $7e(a2)
010166f0  003d              dc.w     $003d
010166f2  007c002f          ori.w    #$2f, sr
010166f6  005c0100          ori.w    #$100, (a4)+
010166fa  0100              btst.l   d0, d0
010166fc  000d              dc.w     $000d
010166fe  000d              dc.w     $000d
01016700  00270022          ori.b    #$22, -(a7)
01016704  003b              dc.w     $003b
01016706  003a              dc.w     $003a
01016708  006c004c002c      ori.w    #$4c, $2c(a4)
0101670e  003c002e          ori.b    #$2e, ccr
01016712  003e              dc.w     $003e
01016714  002f003f007a      ori.b    #$3f, $7a(a7)
0101671a  005a0078          ori.w    #$78, (a2)+
0101671e  00580063          ori.w    #$63, (a0)+
01016722  00430076          ori.w    #$76, d3
01016726  00560062          ori.w    #$62, (a6)
0101672a  0042006d          ori.w    #$6d, d2
0101672e  004d              dc.w     $004d
01016730  006e004e0020      ori.w    #$4e, $20(a6)
01016736  00200061          ori.b    #$61, -(a0)
0101673a  00410073          ori.w    #$73, d1
0101673e  00530064          ori.w    #$64, (a3)
01016742  00440066          ori.w    #$66, d4
01016746  00460067          ori.w    #$67, d6
0101674a  0047006b          ori.w    #$6b, d7
0101674e  004b              dc.w     $004b
01016750  006a004a0068      ori.w    #$4a, $68(a2)
01016756  0048              dc.w     $0048
01016758  0009              dc.w     $0009
0101675a  0009              dc.w     $0009
0101675c  007100510077      ori.w    #$51, $77(a1, d0.w)
01016762  00570065          ori.w    #$65, (a7)
01016766  00450072          ori.w    #$72, d5
0101676a  00520075          ori.w    #$75, (a2)
0101676e  00550079          ori.w    #$79, (a5)
01016772  00590074          ori.w    #$74, (a1)+
01016776  0054001b          ori.w    #$1b, (a4)
0101677a  007e              dc.w     $007e
0101677c  003100210032      ori.b    #$21, $32(a1, d0.w)
01016782  00400033          ori.w    #$33, d0
01016786  00230034          ori.b    #$34, -(a3)
0101678a  00240037          ori.b    #$37, -(a4)
0101678e  00260036          ori.b    #$36, -(a6)
01016792  005e0035          ori.w    #$35, (a6)+
01016796  00250100          ori.b    #$0, -(a5)
0101679a  0100              btst.l   d0, d0
0101679c  0101              btst.l   d0, d1
0101679e  0101              btst.l   d0, d1
010167a0  0102              btst.l   d0, d2
010167a2  0102              btst.l   d0, d2
010167a4  001c001c          ori.b    #$1c, (a4)+
010167a8  001d001d          ori.b    #$1d, (a5)+
010167ac  001b001b          ori.b    #$1b, (a3)+
010167b0  0009              dc.w     $0009
010167b2  0009              dc.w     $0009
010167b4  000f              dc.w     $000f
010167b6  000f              dc.w     $000f
010167b8  00100010          ori.b    #$10, (a0)
010167bc  0103              btst.l   d0, d3
010167be  0103              btst.l   d0, d3
010167c0  0100              btst.l   d0, d0
010167c2  0100              btst.l   d0, d0
010167c4  00300030002e      ori.b    #$30, $2e(a0, d0.w)
010167ca  002e000d000d      ori.b    #$d, $d(a6)
010167d0  0100              btst.l   d0, d0
010167d2  0100              btst.l   d0, d0
010167d4  0104              btst.l   d0, d4
010167d6  0104              btst.l   d0, d4
010167d8  0105              btst.l   d0, d5
010167da  0105              btst.l   d0, d5
010167dc  003100310034      ori.b    #$31, $34(a1, d0.w)
010167e2  003400360036      ori.b    #$36, $36(a4, d0.w)
010167e8  00330033002b      ori.b    #$33, $2b(a3, d0.w)
010167ee  002b01060106      ori.b    #$6, $106(a3)
010167f4  003200320035      ori.b    #$32, $35(a2, d0.w)
010167fa  00350107010701080108  ori.b    #$7, ([a5], d0.w, $1080108)
01016804  0100              btst.l   d0, d0
01016806  0100              btst.l   d0, d0
01016808  003d              dc.w     $003d
0101680a  002b001f001f      ori.b    #$1f, $1f(a3)
01016810  0038002a0039      ori.b    #$2a, $39.w
01016816  002800300029      ori.b    #$30, $29(a0)
0101681c  003700370038      ori.b    #$37, $38(a7, d0.w)
01016822  003800390039      ori.b    #$39, $39.w
01016828  002d002d002a      ori.b    #$2d, $2a(a5)
0101682e  002a0060007e      ori.b    #$60, $7e(a2)
01016834  003d              dc.w     $003d
01016836  001c002f          ori.b    #$2f, (a4)+
0101683a  001c0100          ori.b    #$0, (a4)+
0101683e  0100              btst.l   d0, d0
01016840  000d              dc.w     $000d
01016842  000d              dc.w     $000d
01016844  00270022          ori.b    #$22, -(a7)
01016848  003b              dc.w     $003b
0101684a  003a              dc.w     $003a
0101684c  000c              dc.w     $000c
0101684e  000c              dc.w     $000c
01016850  002c003c002e      ori.b    #$3c, $2e(a4)
01016856  003e              dc.w     $003e
01016858  002f003f001a      ori.b    #$3f, $1a(a7)
0101685e  001a0018          ori.b    #$18, (a2)+
01016862  00180003          ori.b    #$3, (a0)+
01016866  00030016          ori.b    #$16, d3
0101686a  00160002          ori.b    #$2, (a6)
0101686e  0002000d          ori.b    #$d, d2
01016872  000d              dc.w     $000d
01016874  000e              dc.w     $000e
01016876  000e              dc.w     $000e
01016878  00000000          ori.b    #$0, d0
0101687c  00010001          ori.b    #$1, d1
01016880  00130013          ori.b    #$13, (a3)
01016884  00040004          ori.b    #$4, d4
01016888  00060006          ori.b    #$6, d6
0101688c  00070007          ori.b    #$7, d7
01016890  000b              dc.w     $000b
01016892  000b              dc.w     $000b
01016894  000a              dc.w     $000a
01016896  000a              dc.w     $000a
01016898  0008              dc.w     $0008
0101689a  0008              dc.w     $0008
0101689c  0009              dc.w     $0009
0101689e  0009              dc.w     $0009
010168a0  00110011          ori.b    #$11, (a1)
010168a4  00170017          ori.b    #$17, (a7)
010168a8  00050005          ori.b    #$5, d5
010168ac  00120012          ori.b    #$12, (a2)
010168b0  00150015          ori.b    #$15, (a5)
010168b4  00190019          ori.b    #$19, (a1)+
010168b8  00140014          ori.b    #$14, (a4)
010168bc  001b007e          ori.b    #$7e, (a3)+
010168c0  003100210000      ori.b    #$21, (a1, d0.w)
010168c6  00000033          ori.b    #$33, d0
010168ca  00230034          ori.b    #$34, -(a3)
010168ce  00240037          ori.b    #$37, -(a4)
010168d2  0026001e          ori.b    #$1e, -(a6)
010168d6  001e0035          ori.b    #$35, (a6)+
010168da  0025              dc.w     $0025

; ---- gap 01016912..01016b67 (598 bytes) ----
01016912  a870              dc.w     $a870
01016914  2000              move.l   d0, d0
01016916  000044a4          ori.b    #$a4, d0
0101691a  a850              dc.w     $a850
0101691c  2854              movea.l  (a4), a4
0101691e  9488              sub.l    a0, d2
01016920  00000000          ori.b    #$0, d0
01016924  6090              bra.b    $10168b6
01016926  8040              or.w     d0, d0
01016928  a094              dc.w     $a094
0101692a  88740000          or.w     (a4, d0.w), d4
0101692e  00002020          ori.b    #$20, d0
01016932  4000              negx.b   d0
01016934  00000000          ori.b    #$0, d0
01016938  00000000          ori.b    #$0, d0
0101693c  1020              move.b   -(a0), d0
0101693e  2040              movea.l  d0, a0
01016940  4040              negx.w   d0
01016942  4020              negx.b   -(a0)
01016944  2010              move.l   (a0), d0
01016946  00004020          ori.b    #$20, d0
0101694a  2010              move.l   (a0), d0
0101694c  1010              move.b   (a0), d0
0101694e  1020              move.b   -(a0), d0
01016950  2040              movea.l  d0, a0
01016952  000020a8          ori.b    #$a8, d0
01016956  7070              moveq    #$70, d0
01016958  a820              dc.w     $a820
0101695a  00000000          ori.b    #$0, d0
0101695e  00000000          ori.b    #$0, d0
01016962  2020              move.l   -(a0), d0
01016964  f8202000          fmove    fp0, fp0
01016968  00000000          ori.b    #$0, d0
0101696c  00000000          ori.b    #$0, d0
01016970  00000010          ori.b    #$10, d0
01016974  2000              move.l   d0, d0
01016976  00000000          ori.b    #$0, d0
0101697a  0000f800          ori.b    #$0, d0
0101697e  00000000          ori.b    #$0, d0
01016982  00000000          ori.b    #$0, d0
01016986  00000000          ori.b    #$0, d0
0101698a  00200000          ori.b    #$0, -(a0)
0101698e  00000808          ori.b    #$8, d0
01016992  1010              move.b   (a0), d0
01016994  2020              move.l   -(a0), d0
01016996  4040              negx.w   d0
01016998  00000000          ori.b    #$0, d0
0101699c  7088              moveq    #$88, d0
0101699e  98a8c888          sub.l    -$3778(a0), d4
010169a2  88700000          or.w     (a0, d0.w), d4
010169a6  00002060          ori.b    #$60, d0
010169aa  a020              dc.w     $a020
010169ac  2020              move.l   -(a0), d0
010169ae  20f80000          move.l   $0.w, (a0)+
010169b2  00007088          ori.b    #$88, d0
010169b6  0810              dc.w     $0810
010169b8  2040              movea.l  d0, a0
010169ba  80f80000          divu.w   $0.w, d0
010169be  00007088          ori.b    #$88, d0
010169c2  0830              dc.w     $0830
010169c4  0808              dc.w     $0808
010169c6  88700000          or.w     (a0, d0.w), d4
010169ca  00001030          ori.b    #$30, d0
010169ce  5090              addq.l   #$8, (a0)
010169d0  f8101010          fetox    fp4, fp0
010169d4  00000000          ori.b    #$0, d0
010169d8  f88080f0          fbf.w    $100eaca
010169dc  8808              dc.w     $8808
010169de  08f000000000      bset.b   #$0, (a0, d0.w)
010169e4  3040              movea.w  d0, a0
010169e6  80f08888          divu.w   -$78(a0, a0.l), d0
010169ea  88700000          or.w     (a0, d0.w), d4
010169ee  0000f888          ori.b    #$88, d0
010169f2  0810              dc.w     $0810
010169f4  1020              move.b   -(a0), d0
010169f6  2020              move.l   -(a0), d0
010169f8  00000000          ori.b    #$0, d0
010169fc  7088              moveq    #$88, d0
010169fe  88708888          or.w     -$78(a0, a0.l), d4
01016a02  88700000          or.w     (a0, d0.w), d4
01016a06  00007088          ori.b    #$88, d0
01016a0a  8888              dc.w     $8888
01016a0c  7808              moveq    #$8, d4
01016a0e  1060              dc.w     $1060
01016a10  00000000          ori.b    #$0, d0
01016a14  00002000          ori.b    #$0, d0
01016a18  00000020          ori.b    #$20, d0
01016a1c  00000000          ori.b    #$0, d0
01016a20  00002000          ori.b    #$0, d0
01016a24  00000020          ori.b    #$20, d0
01016a28  4000              negx.b   d0
01016a2a  00000000          ori.b    #$0, d0
01016a2e  0830              dc.w     $0830
01016a30  c0300800          and.b    (a0, d0.l), d0
01016a34  00000000          ori.b    #$0, d0
01016a38  000000f8          ori.b    #$f8, d0
01016a3c  00f800000000      cmp2.b   $0.w, d0
01016a42  00000000          ori.b    #$0, d0
01016a46  8060              or.w     -(a0), d0
01016a48  1860              dc.w     $1860
01016a4a  8000              or.b     d0, d0
01016a4c  00000000          ori.b    #$0, d0
01016a50  7088              moveq    #$88, d0
01016a52  8808              dc.w     $8808
01016a54  1020              move.b   -(a0), d0
01016a56  00200000          ori.b    #$0, -(a0)
01016a5a  00003048          ori.b    #$48, d0
01016a5e  98a8a8a8          sub.l    -$5758(a0), d4
01016a62  9840              sub.w    d0, d4
01016a64  3800              move.w   d0, d4
01016a66  00002020          ori.b    #$20, d0
01016a6a  2050              movea.l  (a0), a0
01016a6c  50f88888          st.b     $8888.w
01016a70  00000000          ori.b    #$0, d0
01016a74  f08888f0          fbf.w    $100f366
01016a78  8888              dc.w     $8888
01016a7a  88f00000          divu.w   (a0, d0.w), d4
01016a7e  00007088          ori.b    #$88, d0
01016a82  8080              or.l     d0, d0
01016a84  8080              or.l     d0, d0
01016a86  88700000          or.w     (a0, d0.w), d4
01016a8a  0000e090          ori.b    #$90, d0
01016a8e  8888              dc.w     $8888
01016a90  8888              dc.w     $8888
01016a92  90e0              suba.w   -(a0), a0
01016a94  00000000          ori.b    #$0, d0
01016a98  f88080f0          fbf.w    $100eb8a
01016a9c  8080              or.l     d0, d0
01016a9e  80f80000          divu.w   $0.w, d0
01016aa2  0000f880          ori.b    #$80, d0
01016aa6  80f08080          divu.w   -$80(a0, a0.w), d0
01016aaa  8080              or.l     d0, d0
01016aac  00000000          ori.b    #$0, d0
01016ab0  7088              moveq    #$88, d0
01016ab2  8080              or.l     d0, d0
01016ab4  9888              sub.l    a0, d4
01016ab6  88700000          or.w     (a0, d0.w), d4
01016aba  00008888          ori.b    #$88, d0
01016abe  88f88888          divu.w   $8888.w, d4
01016ac2  8888              dc.w     $8888
01016ac4  00000000          ori.b    #$0, d0
01016ac8  7020              moveq    #$20, d0
01016aca  2020              move.l   -(a0), d0
01016acc  2020              move.l   -(a0), d0
01016ace  20700000          movea.l  (a0, d0.w), a0
01016ad2  00000808          ori.b    #$8, d0
01016ad6  0808              dc.w     $0808
01016ad8  0888              dc.w     $0888
01016ada  88700000          or.w     (a0, d0.w), d4
01016ade  00008890          ori.b    #$90, d0
01016ae2  a0c0              dc.w     $a0c0
01016ae4  c0a0              and.l    -(a0), d0
01016ae6  9088              sub.l    a0, d0
01016ae8  00000000          ori.b    #$0, d0
01016aec  8080              or.l     d0, d0
01016aee  8080              or.l     d0, d0
01016af0  8080              or.l     d0, d0
01016af2  80f80000          divu.w   $0.w, d0
01016af6  000088d8          ori.b    #$d8, d0
01016afa  d8a88888          add.l    -$7778(a0), d4
01016afe  8888              dc.w     $8888
01016b00  00000000          ori.b    #$0, d0
01016b04  88c8              dc.w     $88c8
01016b06  c8a8a898          and.l    -$5768(a0), d4
01016b0a  9888              sub.l    a0, d4
01016b0c  00000000          ori.b    #$0, d0
01016b10  7088              moveq    #$88, d0
01016b12  8888              dc.w     $8888
01016b14  8888              dc.w     $8888
01016b16  88700000          or.w     (a0, d0.w), d4
01016b1a  0000f088          ori.b    #$88, d0
01016b1e  8888              dc.w     $8888
01016b20  f0808080          fbf.w    $100eba2
01016b24  00000000          ori.b    #$0, d0
01016b28  7088              moveq    #$88, d0
01016b2a  8888              dc.w     $8888
01016b2c  8888              dc.w     $8888
01016b2e  8870100c          or.w     $c(a0, d1.w), d4
01016b32  0000f088          ori.b    #$88, d0
01016b36  8888              dc.w     $8888
01016b38  f0a09088          fbf.w    $100fbc2
01016b3c  00000000          ori.b    #$0, d0
01016b40  7088              moveq    #$88, d0
01016b42  80700808          or.w     $8(a0, d0.l), d0
01016b46  88700000          or.w     (a0, d0.w), d4
01016b4a  0000f820          ori.b    #$20, d0
01016b4e  2020              move.l   -(a0), d0
01016b50  2020              move.l   -(a0), d0
01016b52  2020              move.l   -(a0), d0
01016b54  00000000          ori.b    #$0, d0
01016b58  8888              dc.w     $8888
01016b5a  8888              dc.w     $8888
01016b5c  8888              dc.w     $8888
01016b5e  88700000          or.w     (a0, d0.w), d4
01016b62  00008888          ori.b    #$88, d0
01016b66  8888              dc.w     $8888

; ---- gap 01016b6d..01016b89 (29 bytes) ----
01016b6d  00000088          ori.b    #$88, d0
01016b71  88a8a8a8          or.l     -$5758(a0), d4
01016b75  5050              addq.w   #$8, (a0)
01016b77  5000              addq.b   #$8, d0
01016b79  00000088          ori.b    #$88, d0
01016b7d  8850              or.w     (a0), d4
01016b7f  2020              move.l   -(a0), d0
01016b81  5088              addq.l   #$8, a0
01016b83  8800              or.b     d0, d4
01016b85  00000088          ori.b    #$88, d0
01016b89  8850              dc.w     $8850

; ---- gap 01016b91..01016ce7 (343 bytes) ----
01016b91  000000f8          ori.b    #$f8, d0
01016b95  0810              dc.w     $0810
01016b97  2020              move.l   -(a0), d0
01016b99  4080              negx.l   d0
01016b9b  f8000000          fmove    fp0, fp0
01016b9f  007040404040      ori.w    #$4040, $40(a0, d4.w)
01016ba5  4040              negx.w   d0
01016ba7  4040              negx.w   d0
01016ba9  7000              moveq    #$0, d0
01016bab  00404020          ori.w    #$4020, d0
01016baf  2010              move.l   (a0), d0
01016bb1  1008              dc.w     $1008
01016bb3  08000000          btst.b   #$0, d0
01016bb7  003010101010      ori.b    #$10, $10(a0, d1.w)
01016bbd  1010              move.b   (a0), d0
01016bbf  1010              move.b   (a0), d0
01016bc1  3000              move.w   d0, d0
01016bc3  00205088          ori.b    #$88, -(a0)
01016bc7  00000000          ori.b    #$0, d0
01016bcb  00000000          ori.b    #$0, d0
01016bcf  00000000          ori.b    #$0, d0
01016bd3  00000000          ori.b    #$0, d0
01016bd7  0000fc00          ori.b    #$0, d0
01016bdb  00201000          ori.b    #$0, -(a0)
01016bdf  00000000          ori.b    #$0, d0
01016be3  00000000          ori.b    #$0, d0
01016be7  00000070          ori.b    #$70, d0
01016beb  88788888          or.w     $8888.w, d4
01016bef  7800              moveq    #$0, d4
01016bf1  00000080          ori.b    #$80, d0
01016bf5  80f08888          divu.w   -$78(a0, a0.l), d0
01016bf9  8888              dc.w     $8888
01016bfb  f0000000          fmove    fp0, fp0
01016bff  00000070          ori.b    #$70, d0
01016c03  8880              or.l     d0, d4
01016c05  8088              dc.w     $8088
01016c07  7000              moveq    #$0, d0
01016c09  00000008          ori.b    #$8, d0
01016c0d  0878              dc.w     $0878
01016c0f  8888              dc.w     $8888
01016c11  8888              dc.w     $8888
01016c13  7800              moveq    #$0, d4
01016c15  00000000          ori.b    #$0, d0
01016c19  007088f88088      ori.w    #$88f8, -$78(a0, a0.w)
01016c1f  7000              moveq    #$0, d0
01016c21  00000018          ori.b    #$18, d0
01016c25  20782020          movea.l  $2020.w, a0
01016c29  2020              move.l   -(a0), d0
01016c2b  2000              move.l   d0, d0
01016c2d  00000000          ori.b    #$0, d0
01016c31  007888888888      ori.w    #$8888, $8888.w
01016c37  7808              moveq    #$8, d4
01016c39  7000              moveq    #$0, d0
01016c3b  008080f08888      ori.l    #$80f08888, d0
01016c41  8888              dc.w     $8888
01016c43  8800              or.b     d0, d4
01016c45  00000020          ori.b    #$20, d0
01016c49  00e0              dc.w     $00e0
01016c4b  2020              move.l   -(a0), d0
01016c4d  2020              move.l   -(a0), d0
01016c4f  f8000000          fmove    fp0, fp0
01016c53  0008              dc.w     $0008
01016c55  003808080808      ori.b    #$8, $808.w
01016c5b  0808              dc.w     $0808
01016c5d  7000              moveq    #$0, d0
01016c5f  00808090a0c0      ori.l    #$8090a0c0, d0
01016c65  a090              dc.w     $a090
01016c67  8800              or.b     d0, d4
01016c69  00000060          ori.b    #$60, d0
01016c6d  2020              move.l   -(a0), d0
01016c6f  2020              move.l   -(a0), d0
01016c71  2020              move.l   -(a0), d0
01016c73  f8000000          fmove    fp0, fp0
01016c77  000000d0          ori.b    #$d0, d0
01016c7b  a8a8              dc.w     $a8a8
01016c7d  a8a8              dc.w     $a8a8
01016c7f  a800              dc.w     $a800
01016c81  00000000          ori.b    #$0, d0
01016c85  00b0c88888888800  ori.l    #$c8888888, (a0, a0.l)
01016c8d  00000000          ori.b    #$0, d0
01016c91  007088888888      ori.w    #$8888, -$78(a0, a0.l)
01016c97  7000              moveq    #$0, d0
01016c99  00000000          ori.b    #$0, d0
01016c9d  00f0              dc.w     $00f0
01016c9f  8888              dc.w     $8888
01016ca1  8888              dc.w     $8888
01016ca3  f0808000          fbf.w    $100eca5
01016ca7  00000078          ori.b    #$78, d0
01016cab  8888              dc.w     $8888
01016cad  8888              dc.w     $8888
01016caf  7808              moveq    #$8, d4
01016cb1  08000000          btst.b   #$0, d0
01016cb5  00d8              dc.w     $00d8
01016cb7  6040              bra.b    $1016cf9
01016cb9  4040              negx.w   d0
01016cbb  e000              asr.b    #$8, d0
01016cbd  00000000          ori.b    #$0, d0
01016cc1  007088700888      ori.w    #$8870, -$78(a0, d0.l)
01016cc7  7000              moveq    #$0, d0
01016cc9  00000040          ori.b    #$40, d0
01016ccd  40f04040          move.w   sr, $40(a0, d4.w)
01016cd1  4048              dc.w     $4048
01016cd3  3000              move.w   d0, d0
01016cd5  00000000          ori.b    #$0, d0
01016cd9  0088              dc.w     $0088
01016cdb  8888              dc.w     $8888
01016cdd  8898              or.l     (a0)+, d4
01016cdf  68000000          bvc.w    $1016ce1
01016ce3  00000088          ori.b    #$88, d0
01016ce7  8850              dc.w     $8850

; ---- gap 01016ced..01016d5b (111 bytes) ----
01016ced  00000000          ori.b    #$0, d0
01016cf1  0088              dc.w     $0088
01016cf3  88a8a850          or.l     -$57b0(a0), d4
01016cf7  5000              addq.b   #$8, d0
01016cf9  00000000          ori.b    #$0, d0
01016cfd  0088              dc.w     $0088
01016cff  5020              addq.b   #$8, -(a0)
01016d01  2050              movea.l  (a0), a0
01016d03  8800              or.b     d0, d4
01016d05  00000000          ori.b    #$0, d0
01016d09  0088              dc.w     $0088
01016d0b  8850              or.w     (a0), d4
01016d0d  5020              addq.b   #$8, -(a0)
01016d0f  2040              movea.l  d0, a0
01016d11  8000              or.b     d0, d0
01016d13  000000f8          ori.b    #$f8, d0
01016d17  1020              move.b   -(a0), d0
01016d19  4080              negx.l   d0
01016d1b  f8000000          fmove    fp0, fp0
01016d1f  00102020          ori.b    #$20, (a0)
01016d23  2040              movea.l  d0, a0
01016d25  2020              move.l   -(a0), d0
01016d27  2020              move.l   -(a0), d0
01016d29  1000              move.b   d0, d0
01016d2b  00202020          ori.b    #$20, -(a0)
01016d2f  2020              move.l   -(a0), d0
01016d31  2020              move.l   -(a0), d0
01016d33  2020              move.l   -(a0), d0
01016d35  2000              move.l   d0, d0
01016d37  00402020          ori.w    #$2020, d0
01016d3b  2010              move.l   (a0), d0
01016d3d  2020              move.l   -(a0), d0
01016d3f  2020              move.l   -(a0), d0
01016d41  4000              negx.b   d0
01016d43  00000000          ori.b    #$0, d0
01016d47  6890              bvc.b    $1016cd9
01016d49  00000000          ori.b    #$0, d0
01016d4d  00000000          ori.b    #$0, d0
01016d51  00000000          ori.b    #$0, d0
01016d55  00000000          ori.b    #$0, d0
01016d59  0000              dc.w     $0000
01016d5b  0001              dc.w     $0001

; ---- gap 01016d5e..01016d93 (54 bytes) ----
01016d5e  a25e              dc.w     $a25e
01016d60  0100              btst.l   d0, d0
01016d62  a27a              dc.w     $a27a
01016d64  0100              btst.l   d0, d0
01016d66  a308              dc.w     $a308
01016d68  0100              btst.l   d0, d0
01016d6a  a4be              dc.w     $a4be
01016d6c  0100              btst.l   d0, d0
01016d6e  a650              dc.w     $a650
01016d70  0100              btst.l   d0, d0
01016d72  2ecc              move.l   a4, (a7)+
01016d74  0100              btst.l   d0, d0
01016d76  a4e2              dc.w     $a4e2
01016d78  0100              btst.l   d0, d0
01016d7a  a55a              dc.w     $a55a
01016d7c  0100              btst.l   d0, d0
01016d7e  a576              dc.w     $a576
01016d80  0100              btst.l   d0, d0
01016d82  a5fe              dc.w     $a5fe
01016d84  0100              btst.l   d0, d0
01016d86  a606              dc.w     $a606
01016d88  0100              btst.l   d0, d0
01016d8a  a650              dc.w     $a650
01016d8c  0100              btst.l   d0, d0
01016d8e  a650              dc.w     $a650
01016d90  0100              btst.l   d0, d0
01016d92  a630              dc.w     $a630

; ---- gap 01016d9a..01016dd3 (58 bytes) ----
01016d9a  3e3d              dc.w     $3e3d
01016d9c  3b372f1e3c39      move.w   ([a7], d2.l * 8, $3c39), -(a5)
01016da2  3327              move.w   -(a7), -(a1)
01016da4  0e1d              dc.w     $0e1d
01016da6  3a352b162c18      move.w   ([a5], d2.l * 2, $2c18), d5
01016dac  3021              move.w   -(a1), d0
01016dae  02050b17          andi.b   #$17, d5
01016db2  2e1c              move.l   (a4)+, d7
01016db4  383123060d1b      move.w   ([a1], d2.w * 2, $d1b), d4
01016dba  362d1a34          move.w   $1a34(a5), d3
01016dbe  2912              move.l   (a2), -(a4)
01016dc0  2408              move.l   a0, d2
01016dc2  1122              move.b   -(a2), -(a0)
01016dc4  0409              dc.w     $0409
01016dc6  1326              move.b   -(a6), -(a1)
01016dc8  0c193225          cmpi.b   #$25, (a1)+
01016dcc  0a152a14          eori.b   #$14, (a5)
01016dd0  2810              move.l   (a0), d4
01016dd2  0000              dc.w     $0000

; ---- gap 01016dd6..01016deb (22 bytes) ----
01016dd6  ad9c              dc.w     $ad9c
01016dd8  0100              btst.l   d0, d0
01016dda  aea0              dc.w     $aea0
01016ddc  0100              btst.l   d0, d0
01016dde  b1dc              cmpa.l   (a4)+, a0
01016de0  0100              btst.l   d0, d0
01016de2  b2bc0100b2c4      cmp.l    #sub_0100b2c4, d1
01016de8  00000001          ori.b    #$1, d0

; ---- gap 01016e5c..01016e75 (26 bytes) ----
01016e5c  00940d000000      ori.l    #$d000000, (a4)
01016e62  00002d00          ori.b    #$0, d0
01016e66  00000000          ori.b    #$0, d0
01016e6a  2d00              move.l   d0, -(a6)
01016e6c  00000000          ori.b    #$0, d0
01016e70  2000              move.l   d0, d0
01016e72  0101              btst.l   d0, d1
01016e74  00a6              dc.w     $00a6

; ---- gap 01016f0a..01016f5f (86 bytes) ----
01016f0a  00006000          ori.b    #$0, d0
01016f0e  00000000          ori.b    #$0, d0
01016f12  60000000          bra.w    $1016f14
01016f16  00006000          ori.b    #$0, d0
01016f1a  00000000          ori.b    #$0, d0
01016f1e  8000              or.b     d0, d0
01016f20  00000000          ori.b    #$0, d0
01016f24  8000              or.b     d0, d0
01016f26  00000000          ori.b    #$0, d0
01016f2a  8000              or.b     d0, d0
01016f2c  00000000          ori.b    #$0, d0
01016f30  8000              or.b     d0, d0
01016f32  00000000          ori.b    #$0, d0
01016f36  8000              or.b     d0, d0
01016f38  00000000          ori.b    #$0, d0
01016f3c  2000              move.l   d0, d0
01016f3e  00000000          ori.b    #$0, d0
01016f42  2000              move.l   d0, d0
01016f44  00000000          ori.b    #$0, d0
01016f48  2d00              move.l   d0, -(a6)
01016f4a  00000000          ori.b    #$0, d0
01016f4e  2d00              move.l   d0, -(a6)
01016f50  00000000          ori.b    #$0, d0
01016f54  2000              move.l   d0, d0
01016f56  00000000          ori.b    #$0, d0
01016f5a  2000              move.l   d0, d0
01016f5c  00000000          ori.b    #$0, d0

; ---- gap 01016f6c..01016f77 (12 bytes) all zero ----

; ---- gap 01016f80..01016f8f (16 bytes) ----
01016f80  ffff              dc.w     $ffff
01016f82  ffff              dc.w     $ffff
01016f84  ffff              dc.w     $ffff
01016f86  ffff              dc.w     $ffff
01016f88  00000400          ori.b    #$0, d0
01016f8c  00040000          ori.b    #$0, d4

; ---- gap 01016fb4..01016fc1 (14 bytes) ----
01016fb4  00c2              dc.w     $00c2
01016fb6  0101              btst.l   d0, d1
01016fb8  00c8              dc.w     $00c8
01016fba  0101              btst.l   d0, d1
01016fbc  00d0              dc.w     $00d0
01016fbe  0101              btst.l   d0, d1
01016fc0  00d8              dc.w     $00d8

; ---- gap 0101706c..0101ffff (36756 bytes) ----
0101706c  000b              dc.w     $000b
0101706e  4000              negx.b   d0
01017070  08000000          btst.b   #$0, d0
01017074  00010000          ori.b    #$0, d1
01017078  00020016          ori.b    #$16, d2
0101707c  8000              or.b     d0, d0
0101707e  1000              move.b   d0, d0
01017080  00000001          ori.b    #$1, d0
01017084  00000003          ori.b    #$3, d0
01017088  002d00002000      ori.b    #$0, $2000(a5)
0101708e  00000001          ori.b    #$1, d0
01017092  00000000          ori.b    #$0, d0
01017096  000b              dc.w     $000b
01017098  4000              negx.b   d0
0101709a  3000              move.w   d0, d0
0101709c  00000001          ori.b    #$1, d0
010170a0  00000000          ori.b    #$0, d0
010170a4  00000000          ori.b    #$0, d0
010170a8  00000000          ori.b    #$0, d0
010170ac  00000000          ori.b    #$0, d0
010170b0  00000000          ori.b    #$0, d0
010170b4  00000000          ori.b    #$0, d0
010170b8  00000000          ori.b    #$0, d0
010170bc  00000000          ori.b    #$0, d0
010170c0  00000000          ori.b    #$0, d0
010170c4  00000000          ori.b    #$0, d0
010170c8  00000000          ori.b    #$0, d0
010170cc  00000000          ori.b    #$0, d0
010170d0  00000000          ori.b    #$0, d0
010170d4  00000000          ori.b    #$0, d0
010170d8  00000000          ori.b    #$0, d0
010170dc  00000000          ori.b    #$0, d0
010170e0  00000000          ori.b    #$0, d0
010170e4  00000000          ori.b    #$0, d0
010170e8  00000000          ori.b    #$0, d0
010170ec  00000000          ori.b    #$0, d0
010170f0  00000000          ori.b    #$0, d0
010170f4  00000000          ori.b    #$0, d0
010170f8  00000000          ori.b    #$0, d0
010170fc  00000000          ori.b    #$0, d0
01017100  00000000          ori.b    #$0, d0
01017104  00000000          ori.b    #$0, d0
01017108  00000000          ori.b    #$0, d0
0101710c  00000000          ori.b    #$0, d0
01017110  00000000          ori.b    #$0, d0
01017114  00000000          ori.b    #$0, d0
01017118  00000000          ori.b    #$0, d0
0101711c  00000000          ori.b    #$0, d0
01017120  00000000          ori.b    #$0, d0
01017124  00000000          ori.b    #$0, d0
01017128  00000000          ori.b    #$0, d0
0101712c  00000000          ori.b    #$0, d0
01017130  00000000          ori.b    #$0, d0
01017134  00000000          ori.b    #$0, d0
01017138  00000000          ori.b    #$0, d0
0101713c  00000000          ori.b    #$0, d0
01017140  00000000          ori.b    #$0, d0
01017144  00000000          ori.b    #$0, d0
01017148  00000000          ori.b    #$0, d0
0101714c  00000000          ori.b    #$0, d0
01017150  00000000          ori.b    #$0, d0
01017154  00000000          ori.b    #$0, d0
01017158  00000000          ori.b    #$0, d0
0101715c  00000000          ori.b    #$0, d0
01017160  00000000          ori.b    #$0, d0
01017164  00000000          ori.b    #$0, d0
01017168  00000000          ori.b    #$0, d0
0101716c  00000000          ori.b    #$0, d0
01017170  00000000          ori.b    #$0, d0
01017174  00000000          ori.b    #$0, d0
01017178  00000000          ori.b    #$0, d0
0101717c  00000000          ori.b    #$0, d0
01017180  00000000          ori.b    #$0, d0
01017184  00000000          ori.b    #$0, d0
01017188  00000000          ori.b    #$0, d0
0101718c  00000000          ori.b    #$0, d0
01017190  00000000          ori.b    #$0, d0
01017194  00000000          ori.b    #$0, d0
01017198  00000000          ori.b    #$0, d0
0101719c  00000000          ori.b    #$0, d0
010171a0  00000000          ori.b    #$0, d0
010171a4  00000000          ori.b    #$0, d0
010171a8  00000000          ori.b    #$0, d0
010171ac  00000000          ori.b    #$0, d0
010171b0  00000000          ori.b    #$0, d0
010171b4  00000000          ori.b    #$0, d0
010171b8  00000000          ori.b    #$0, d0
010171bc  00000000          ori.b    #$0, d0
010171c0  00000000          ori.b    #$0, d0
010171c4  00000000          ori.b    #$0, d0
010171c8  00000000          ori.b    #$0, d0
010171cc  00000000          ori.b    #$0, d0
010171d0  00000000          ori.b    #$0, d0
010171d4  00000000          ori.b    #$0, d0
010171d8  00000000          ori.b    #$0, d0
010171dc  00000000          ori.b    #$0, d0
010171e0  00000000          ori.b    #$0, d0
010171e4  00000000          ori.b    #$0, d0
010171e8  00000000          ori.b    #$0, d0
010171ec  00000000          ori.b    #$0, d0
010171f0  00000000          ori.b    #$0, d0
010171f4  00000000          ori.b    #$0, d0
010171f8  00000000          ori.b    #$0, d0
010171fc  00000000          ori.b    #$0, d0
01017200  00000000          ori.b    #$0, d0
01017204  00000000          ori.b    #$0, d0
01017208  00000000          ori.b    #$0, d0
0101720c  00000000          ori.b    #$0, d0
01017210  00000000          ori.b    #$0, d0
01017214  00000000          ori.b    #$0, d0
01017218  00000000          ori.b    #$0, d0
0101721c  00000000          ori.b    #$0, d0
01017220  00000000          ori.b    #$0, d0
01017224  00000000          ori.b    #$0, d0
01017228  00000000          ori.b    #$0, d0
0101722c  00000000          ori.b    #$0, d0
01017230  00000000          ori.b    #$0, d0
01017234  00000000          ori.b    #$0, d0
01017238  00000000          ori.b    #$0, d0
0101723c  00000000          ori.b    #$0, d0
01017240  00000000          ori.b    #$0, d0
01017244  00000000          ori.b    #$0, d0
01017248  00000000          ori.b    #$0, d0
0101724c  00000000          ori.b    #$0, d0
01017250  00000000          ori.b    #$0, d0
01017254  00000000          ori.b    #$0, d0
01017258  00000000          ori.b    #$0, d0
0101725c  00000000          ori.b    #$0, d0
01017260  00000000          ori.b    #$0, d0
01017264  00000000          ori.b    #$0, d0
01017268  00000000          ori.b    #$0, d0
0101726c  00000000          ori.b    #$0, d0
01017270  00000000          ori.b    #$0, d0
01017274  00000000          ori.b    #$0, d0
01017278  00000000          ori.b    #$0, d0
0101727c  00000000          ori.b    #$0, d0
01017280  00000000          ori.b    #$0, d0
01017284  00000000          ori.b    #$0, d0
01017288  00000000          ori.b    #$0, d0
0101728c  00000000          ori.b    #$0, d0
01017290  00000000          ori.b    #$0, d0
01017294  00000000          ori.b    #$0, d0
01017298  00000000          ori.b    #$0, d0
0101729c  00000000          ori.b    #$0, d0
010172a0  00000000          ori.b    #$0, d0
010172a4  00000000          ori.b    #$0, d0
010172a8  00000000          ori.b    #$0, d0
010172ac  00000000          ori.b    #$0, d0
010172b0  00000000          ori.b    #$0, d0
010172b4  00000000          ori.b    #$0, d0
010172b8  00000000          ori.b    #$0, d0
010172bc  00000000          ori.b    #$0, d0
010172c0  00000000          ori.b    #$0, d0
010172c4  00000000          ori.b    #$0, d0
010172c8  00000000          ori.b    #$0, d0
010172cc  00000000          ori.b    #$0, d0
010172d0  00000000          ori.b    #$0, d0
010172d4  00000000          ori.b    #$0, d0
010172d8  00000000          ori.b    #$0, d0
010172dc  00000000          ori.b    #$0, d0
010172e0  00000000          ori.b    #$0, d0
010172e4  00000000          ori.b    #$0, d0
010172e8  00000000          ori.b    #$0, d0
010172ec  00000000          ori.b    #$0, d0
010172f0  00000000          ori.b    #$0, d0
010172f4  00000000          ori.b    #$0, d0
010172f8  00000000          ori.b    #$0, d0
010172fc  00000000          ori.b    #$0, d0
01017300  00000000          ori.b    #$0, d0
01017304  00000000          ori.b    #$0, d0
01017308  00000000          ori.b    #$0, d0
0101730c  00000000          ori.b    #$0, d0
01017310  00000000          ori.b    #$0, d0
01017314  00000000          ori.b    #$0, d0
01017318  00000000          ori.b    #$0, d0
0101731c  00000000          ori.b    #$0, d0
01017320  00000000          ori.b    #$0, d0
01017324  00000000          ori.b    #$0, d0
01017328  00000000          ori.b    #$0, d0
0101732c  00000000          ori.b    #$0, d0
01017330  00000000          ori.b    #$0, d0
01017334  00000000          ori.b    #$0, d0
01017338  00000000          ori.b    #$0, d0
0101733c  00000000          ori.b    #$0, d0
01017340  00000000          ori.b    #$0, d0
01017344  00000000          ori.b    #$0, d0
01017348  00000000          ori.b    #$0, d0
0101734c  00000000          ori.b    #$0, d0
01017350  00000000          ori.b    #$0, d0
01017354  00000000          ori.b    #$0, d0
01017358  00000000          ori.b    #$0, d0
0101735c  00000000          ori.b    #$0, d0
01017360  00000000          ori.b    #$0, d0
01017364  00000000          ori.b    #$0, d0
01017368  00000000          ori.b    #$0, d0
0101736c  00000000          ori.b    #$0, d0
01017370  00000000          ori.b    #$0, d0
01017374  00000000          ori.b    #$0, d0
01017378  00000000          ori.b    #$0, d0
0101737c  00000000          ori.b    #$0, d0
01017380  00000000          ori.b    #$0, d0
01017384  00000000          ori.b    #$0, d0
01017388  00000000          ori.b    #$0, d0
0101738c  00000000          ori.b    #$0, d0
01017390  00000000          ori.b    #$0, d0
01017394  00000000          ori.b    #$0, d0
01017398  00000000          ori.b    #$0, d0
0101739c  00000000          ori.b    #$0, d0
010173a0  00000000          ori.b    #$0, d0
010173a4  00000000          ori.b    #$0, d0
010173a8  00000000          ori.b    #$0, d0
010173ac  00000000          ori.b    #$0, d0
010173b0  00000000          ori.b    #$0, d0
010173b4  00000000          ori.b    #$0, d0
010173b8  00000000          ori.b    #$0, d0
010173bc  00000000          ori.b    #$0, d0
010173c0  00000000          ori.b    #$0, d0
010173c4  00000000          ori.b    #$0, d0
010173c8  00000000          ori.b    #$0, d0
010173cc  00000000          ori.b    #$0, d0
010173d0  00000000          ori.b    #$0, d0
010173d4  00000000          ori.b    #$0, d0
010173d8  00000000          ori.b    #$0, d0
010173dc  00000000          ori.b    #$0, d0
010173e0  00000000          ori.b    #$0, d0
010173e4  00000000          ori.b    #$0, d0
010173e8  00000000          ori.b    #$0, d0
010173ec  00000000          ori.b    #$0, d0
010173f0  00000000          ori.b    #$0, d0
010173f4  00000000          ori.b    #$0, d0
010173f8  00000000          ori.b    #$0, d0
010173fc  00000000          ori.b    #$0, d0
01017400  00000000          ori.b    #$0, d0
01017404  00000000          ori.b    #$0, d0
01017408  00000000          ori.b    #$0, d0
0101740c  00000000          ori.b    #$0, d0
01017410  00000000          ori.b    #$0, d0
01017414  00000000          ori.b    #$0, d0
01017418  00000000          ori.b    #$0, d0
0101741c  00000000          ori.b    #$0, d0
01017420  00000000          ori.b    #$0, d0
01017424  00000000          ori.b    #$0, d0
01017428  00000000          ori.b    #$0, d0
0101742c  00000000          ori.b    #$0, d0
01017430  00000000          ori.b    #$0, d0
01017434  00000000          ori.b    #$0, d0
01017438  00000000          ori.b    #$0, d0
0101743c  00000000          ori.b    #$0, d0
01017440  00000000          ori.b    #$0, d0
01017444  00000000          ori.b    #$0, d0
01017448  00000000          ori.b    #$0, d0
0101744c  00000000          ori.b    #$0, d0
01017450  00000000          ori.b    #$0, d0
01017454  00000000          ori.b    #$0, d0
01017458  00000000          ori.b    #$0, d0
0101745c  00000000          ori.b    #$0, d0
01017460  00000000          ori.b    #$0, d0
01017464  00000000          ori.b    #$0, d0
01017468  00000000          ori.b    #$0, d0
0101746c  00000000          ori.b    #$0, d0
01017470  00000000          ori.b    #$0, d0
01017474  00000000          ori.b    #$0, d0
01017478  00000000          ori.b    #$0, d0
0101747c  00000000          ori.b    #$0, d0
01017480  00000000          ori.b    #$0, d0
01017484  00000000          ori.b    #$0, d0
01017488  00000000          ori.b    #$0, d0
0101748c  00000000          ori.b    #$0, d0
01017490  00000000          ori.b    #$0, d0
01017494  00000000          ori.b    #$0, d0
01017498  00000000          ori.b    #$0, d0
0101749c  00000000          ori.b    #$0, d0
010174a0  00000000          ori.b    #$0, d0
010174a4  00000000          ori.b    #$0, d0
010174a8  00000000          ori.b    #$0, d0
010174ac  00000000          ori.b    #$0, d0
010174b0  00000000          ori.b    #$0, d0
010174b4  00000000          ori.b    #$0, d0
010174b8  00000000          ori.b    #$0, d0
010174bc  00000000          ori.b    #$0, d0
010174c0  00000000          ori.b    #$0, d0
010174c4  00000000          ori.b    #$0, d0
010174c8  00000000          ori.b    #$0, d0
010174cc  00000000          ori.b    #$0, d0
010174d0  00000000          ori.b    #$0, d0
010174d4  00000000          ori.b    #$0, d0
010174d8  00000000          ori.b    #$0, d0
010174dc  00000000          ori.b    #$0, d0
010174e0  00000000          ori.b    #$0, d0
010174e4  00000000          ori.b    #$0, d0
010174e8  00000000          ori.b    #$0, d0
010174ec  00000000          ori.b    #$0, d0
010174f0  00000000          ori.b    #$0, d0
010174f4  00000000          ori.b    #$0, d0
010174f8  00000000          ori.b    #$0, d0
010174fc  00000000          ori.b    #$0, d0
01017500  00000000          ori.b    #$0, d0
01017504  00000000          ori.b    #$0, d0
01017508  00000000          ori.b    #$0, d0
0101750c  00000000          ori.b    #$0, d0
01017510  00000000          ori.b    #$0, d0
01017514  00000000          ori.b    #$0, d0
01017518  00000000          ori.b    #$0, d0
0101751c  00000000          ori.b    #$0, d0
01017520  00000000          ori.b    #$0, d0
01017524  00000000          ori.b    #$0, d0
01017528  00000000          ori.b    #$0, d0
0101752c  00000000          ori.b    #$0, d0
01017530  00000000          ori.b    #$0, d0
01017534  00000000          ori.b    #$0, d0
01017538  00000000          ori.b    #$0, d0
0101753c  00000000          ori.b    #$0, d0
01017540  00000000          ori.b    #$0, d0
01017544  00000000          ori.b    #$0, d0
01017548  00000000          ori.b    #$0, d0
0101754c  00000000          ori.b    #$0, d0
01017550  00000000          ori.b    #$0, d0
01017554  00000000          ori.b    #$0, d0
01017558  00000000          ori.b    #$0, d0
0101755c  00000000          ori.b    #$0, d0
01017560  00000000          ori.b    #$0, d0
01017564  00000000          ori.b    #$0, d0
01017568  00000000          ori.b    #$0, d0
0101756c  00000000          ori.b    #$0, d0
01017570  00000000          ori.b    #$0, d0
01017574  00000000          ori.b    #$0, d0
01017578  00000000          ori.b    #$0, d0
0101757c  00000000          ori.b    #$0, d0
01017580  00000000          ori.b    #$0, d0
01017584  00000000          ori.b    #$0, d0
01017588  00000000          ori.b    #$0, d0
0101758c  00000000          ori.b    #$0, d0
01017590  00000000          ori.b    #$0, d0
01017594  00000000          ori.b    #$0, d0
01017598  00000000          ori.b    #$0, d0
0101759c  00000000          ori.b    #$0, d0
010175a0  00000000          ori.b    #$0, d0
010175a4  00000000          ori.b    #$0, d0
010175a8  00000000          ori.b    #$0, d0
010175ac  00000000          ori.b    #$0, d0
010175b0  00000000          ori.b    #$0, d0
010175b4  00000000          ori.b    #$0, d0
010175b8  00000000          ori.b    #$0, d0
010175bc  00000000          ori.b    #$0, d0
010175c0  00000000          ori.b    #$0, d0
010175c4  00000000          ori.b    #$0, d0
010175c8  00000000          ori.b    #$0, d0
010175cc  00000000          ori.b    #$0, d0
010175d0  00000000          ori.b    #$0, d0
010175d4  00000000          ori.b    #$0, d0
010175d8  00000000          ori.b    #$0, d0
010175dc  00000000          ori.b    #$0, d0
010175e0  00000000          ori.b    #$0, d0
010175e4  00000000          ori.b    #$0, d0
010175e8  00000000          ori.b    #$0, d0
010175ec  00000000          ori.b    #$0, d0
010175f0  00000000          ori.b    #$0, d0
010175f4  00000000          ori.b    #$0, d0
010175f8  00000000          ori.b    #$0, d0
010175fc  00000000          ori.b    #$0, d0
01017600  00000000          ori.b    #$0, d0
01017604  00000000          ori.b    #$0, d0
01017608  00000000          ori.b    #$0, d0
0101760c  00000000          ori.b    #$0, d0
01017610  00000000          ori.b    #$0, d0
01017614  00000000          ori.b    #$0, d0
01017618  00000000          ori.b    #$0, d0
0101761c  00000000          ori.b    #$0, d0
01017620  00000000          ori.b    #$0, d0
01017624  00000000          ori.b    #$0, d0
01017628  00000000          ori.b    #$0, d0
0101762c  00000000          ori.b    #$0, d0
01017630  00000000          ori.b    #$0, d0
01017634  00000000          ori.b    #$0, d0
01017638  00000000          ori.b    #$0, d0
0101763c  00000000          ori.b    #$0, d0
01017640  00000000          ori.b    #$0, d0
01017644  00000000          ori.b    #$0, d0
01017648  00000000          ori.b    #$0, d0
0101764c  00000000          ori.b    #$0, d0
01017650  00000000          ori.b    #$0, d0
01017654  00000000          ori.b    #$0, d0
01017658  00000000          ori.b    #$0, d0
0101765c  00000000          ori.b    #$0, d0
01017660  00000000          ori.b    #$0, d0
01017664  00000000          ori.b    #$0, d0
01017668  00000000          ori.b    #$0, d0
0101766c  00000000          ori.b    #$0, d0
01017670  00000000          ori.b    #$0, d0
01017674  00000000          ori.b    #$0, d0
01017678  00000000          ori.b    #$0, d0
0101767c  00000000          ori.b    #$0, d0
01017680  00000000          ori.b    #$0, d0
01017684  00000000          ori.b    #$0, d0
01017688  00000000          ori.b    #$0, d0
0101768c  00000000          ori.b    #$0, d0
01017690  00000000          ori.b    #$0, d0
01017694  00000000          ori.b    #$0, d0
01017698  00000000          ori.b    #$0, d0
0101769c  00000000          ori.b    #$0, d0
010176a0  00000000          ori.b    #$0, d0
010176a4  00000000          ori.b    #$0, d0
010176a8  00000000          ori.b    #$0, d0
010176ac  00000000          ori.b    #$0, d0
010176b0  00000000          ori.b    #$0, d0
010176b4  00000000          ori.b    #$0, d0
010176b8  00000000          ori.b    #$0, d0
010176bc  00000000          ori.b    #$0, d0
010176c0  00000000          ori.b    #$0, d0
010176c4  00000000          ori.b    #$0, d0
010176c8  00000000          ori.b    #$0, d0
010176cc  00000000          ori.b    #$0, d0
010176d0  00000000          ori.b    #$0, d0
010176d4  00000000          ori.b    #$0, d0
010176d8  00000000          ori.b    #$0, d0
010176dc  00000000          ori.b    #$0, d0
010176e0  00000000          ori.b    #$0, d0
010176e4  00000000          ori.b    #$0, d0
010176e8  00000000          ori.b    #$0, d0
010176ec  00000000          ori.b    #$0, d0
010176f0  00000000          ori.b    #$0, d0
010176f4  00000000          ori.b    #$0, d0
010176f8  00000000          ori.b    #$0, d0
010176fc  00000000          ori.b    #$0, d0
01017700  00000000          ori.b    #$0, d0
01017704  00000000          ori.b    #$0, d0
01017708  00000000          ori.b    #$0, d0
0101770c  00000000          ori.b    #$0, d0
01017710  00000000          ori.b    #$0, d0
01017714  00000000          ori.b    #$0, d0
01017718  00000000          ori.b    #$0, d0
0101771c  00000000          ori.b    #$0, d0
01017720  00000000          ori.b    #$0, d0
01017724  00000000          ori.b    #$0, d0
01017728  00000000          ori.b    #$0, d0
0101772c  00000000          ori.b    #$0, d0
01017730  00000000          ori.b    #$0, d0
01017734  00000000          ori.b    #$0, d0
01017738  00000000          ori.b    #$0, d0
0101773c  00000000          ori.b    #$0, d0
01017740  00000000          ori.b    #$0, d0
01017744  00000000          ori.b    #$0, d0
01017748  00000000          ori.b    #$0, d0
0101774c  00000000          ori.b    #$0, d0
01017750  00000000          ori.b    #$0, d0
01017754  00000000          ori.b    #$0, d0
01017758  00000000          ori.b    #$0, d0
0101775c  00000000          ori.b    #$0, d0
01017760  00000000          ori.b    #$0, d0
01017764  00000000          ori.b    #$0, d0
01017768  00000000          ori.b    #$0, d0
0101776c  00000000          ori.b    #$0, d0
01017770  00000000          ori.b    #$0, d0
01017774  00000000          ori.b    #$0, d0
01017778  00000000          ori.b    #$0, d0
0101777c  00000000          ori.b    #$0, d0
01017780  00000000          ori.b    #$0, d0
01017784  00000000          ori.b    #$0, d0
01017788  00000000          ori.b    #$0, d0
0101778c  00000000          ori.b    #$0, d0
01017790  00000000          ori.b    #$0, d0
01017794  00000000          ori.b    #$0, d0
01017798  00000000          ori.b    #$0, d0
0101779c  00000000          ori.b    #$0, d0
010177a0  00000000          ori.b    #$0, d0
010177a4  00000000          ori.b    #$0, d0
010177a8  00000000          ori.b    #$0, d0
010177ac  00000000          ori.b    #$0, d0
010177b0  00000000          ori.b    #$0, d0
010177b4  00000000          ori.b    #$0, d0
010177b8  00000000          ori.b    #$0, d0
010177bc  00000000          ori.b    #$0, d0
010177c0  00000000          ori.b    #$0, d0
010177c4  00000000          ori.b    #$0, d0
010177c8  00000000          ori.b    #$0, d0
010177cc  00000000          ori.b    #$0, d0
010177d0  00000000          ori.b    #$0, d0
010177d4  00000000          ori.b    #$0, d0
010177d8  00000000          ori.b    #$0, d0
010177dc  00000000          ori.b    #$0, d0
010177e0  00000000          ori.b    #$0, d0
010177e4  00000000          ori.b    #$0, d0
010177e8  00000000          ori.b    #$0, d0
010177ec  00000000          ori.b    #$0, d0
010177f0  00000000          ori.b    #$0, d0
010177f4  00000000          ori.b    #$0, d0
010177f8  00000000          ori.b    #$0, d0
010177fc  00000000          ori.b    #$0, d0
01017800  00000000          ori.b    #$0, d0
01017804  00000000          ori.b    #$0, d0
01017808  00000000          ori.b    #$0, d0
0101780c  00000000          ori.b    #$0, d0
01017810  00000000          ori.b    #$0, d0
01017814  00000000          ori.b    #$0, d0
01017818  00000000          ori.b    #$0, d0
0101781c  00000000          ori.b    #$0, d0
01017820  00000000          ori.b    #$0, d0
01017824  00000000          ori.b    #$0, d0
01017828  00000000          ori.b    #$0, d0
0101782c  00000000          ori.b    #$0, d0
01017830  00000000          ori.b    #$0, d0
01017834  00000000          ori.b    #$0, d0
01017838  00000000          ori.b    #$0, d0
0101783c  00000000          ori.b    #$0, d0
01017840  00000000          ori.b    #$0, d0
01017844  00000000          ori.b    #$0, d0
01017848  00000000          ori.b    #$0, d0
0101784c  00000000          ori.b    #$0, d0
01017850  00000000          ori.b    #$0, d0
01017854  00000000          ori.b    #$0, d0
01017858  00000000          ori.b    #$0, d0
0101785c  00000000          ori.b    #$0, d0
01017860  00000000          ori.b    #$0, d0
01017864  00000000          ori.b    #$0, d0
01017868  00000000          ori.b    #$0, d0
0101786c  00000000          ori.b    #$0, d0
01017870  00000000          ori.b    #$0, d0
01017874  00000000          ori.b    #$0, d0
01017878  00000000          ori.b    #$0, d0
0101787c  00000000          ori.b    #$0, d0
01017880  00000000          ori.b    #$0, d0
01017884  00000000          ori.b    #$0, d0
01017888  00000000          ori.b    #$0, d0
0101788c  00000000          ori.b    #$0, d0
01017890  00000000          ori.b    #$0, d0
01017894  00000000          ori.b    #$0, d0
01017898  00000000          ori.b    #$0, d0
0101789c  00000000          ori.b    #$0, d0
010178a0  00000000          ori.b    #$0, d0
010178a4  00000000          ori.b    #$0, d0
010178a8  00000000          ori.b    #$0, d0
010178ac  00000000          ori.b    #$0, d0
010178b0  00000000          ori.b    #$0, d0
010178b4  00000000          ori.b    #$0, d0
010178b8  00000000          ori.b    #$0, d0
010178bc  00000000          ori.b    #$0, d0
010178c0  00000000          ori.b    #$0, d0
010178c4  00000000          ori.b    #$0, d0
010178c8  00000000          ori.b    #$0, d0
010178cc  00000000          ori.b    #$0, d0
010178d0  00000000          ori.b    #$0, d0
010178d4  00000000          ori.b    #$0, d0
010178d8  00000000          ori.b    #$0, d0
010178dc  00000000          ori.b    #$0, d0
010178e0  00000000          ori.b    #$0, d0
010178e4  00000000          ori.b    #$0, d0
010178e8  00000000          ori.b    #$0, d0
010178ec  00000000          ori.b    #$0, d0
010178f0  00000000          ori.b    #$0, d0
010178f4  00000000          ori.b    #$0, d0
010178f8  00000000          ori.b    #$0, d0
010178fc  00000000          ori.b    #$0, d0
01017900  00000000          ori.b    #$0, d0
01017904  00000000          ori.b    #$0, d0
01017908  00000000          ori.b    #$0, d0
0101790c  00000000          ori.b    #$0, d0
01017910  00000000          ori.b    #$0, d0
01017914  00000000          ori.b    #$0, d0
01017918  00000000          ori.b    #$0, d0
0101791c  00000000          ori.b    #$0, d0
01017920  00000000          ori.b    #$0, d0
01017924  00000000          ori.b    #$0, d0
01017928  00000000          ori.b    #$0, d0
0101792c  00000000          ori.b    #$0, d0
01017930  00000000          ori.b    #$0, d0
01017934  00000000          ori.b    #$0, d0
01017938  00000000          ori.b    #$0, d0
0101793c  00000000          ori.b    #$0, d0
01017940  00000000          ori.b    #$0, d0
01017944  00000000          ori.b    #$0, d0
01017948  00000000          ori.b    #$0, d0
0101794c  00000000          ori.b    #$0, d0
01017950  00000000          ori.b    #$0, d0
01017954  00000000          ori.b    #$0, d0
01017958  00000000          ori.b    #$0, d0
0101795c  00000000          ori.b    #$0, d0
01017960  00000000          ori.b    #$0, d0
01017964  00000000          ori.b    #$0, d0
01017968  00000000          ori.b    #$0, d0
0101796c  00000000          ori.b    #$0, d0
01017970  00000000          ori.b    #$0, d0
01017974  00000000          ori.b    #$0, d0
01017978  00000000          ori.b    #$0, d0
0101797c  00000000          ori.b    #$0, d0
01017980  00000000          ori.b    #$0, d0
01017984  00000000          ori.b    #$0, d0
01017988  00000000          ori.b    #$0, d0
0101798c  00000000          ori.b    #$0, d0
01017990  00000000          ori.b    #$0, d0
01017994  00000000          ori.b    #$0, d0
01017998  00000000          ori.b    #$0, d0
0101799c  00000000          ori.b    #$0, d0
010179a0  00000000          ori.b    #$0, d0
010179a4  00000000          ori.b    #$0, d0
010179a8  00000000          ori.b    #$0, d0
010179ac  00000000          ori.b    #$0, d0
010179b0  00000000          ori.b    #$0, d0
010179b4  00000000          ori.b    #$0, d0
010179b8  00000000          ori.b    #$0, d0
010179bc  00000000          ori.b    #$0, d0
010179c0  00000000          ori.b    #$0, d0
010179c4  00000000          ori.b    #$0, d0
010179c8  00000000          ori.b    #$0, d0
010179cc  00000000          ori.b    #$0, d0
010179d0  00000000          ori.b    #$0, d0
010179d4  00000000          ori.b    #$0, d0
010179d8  00000000          ori.b    #$0, d0
010179dc  00000000          ori.b    #$0, d0
010179e0  00000000          ori.b    #$0, d0
010179e4  00000000          ori.b    #$0, d0
010179e8  00000000          ori.b    #$0, d0
010179ec  00000000          ori.b    #$0, d0
010179f0  00000000          ori.b    #$0, d0
010179f4  00000000          ori.b    #$0, d0
010179f8  00000000          ori.b    #$0, d0
010179fc  00000000          ori.b    #$0, d0
01017a00  00000000          ori.b    #$0, d0
01017a04  00000000          ori.b    #$0, d0
01017a08  00000000          ori.b    #$0, d0
01017a0c  00000000          ori.b    #$0, d0
01017a10  00000000          ori.b    #$0, d0
01017a14  00000000          ori.b    #$0, d0
01017a18  00000000          ori.b    #$0, d0
01017a1c  00000000          ori.b    #$0, d0
01017a20  00000000          ori.b    #$0, d0
01017a24  00000000          ori.b    #$0, d0
01017a28  00000000          ori.b    #$0, d0
01017a2c  00000000          ori.b    #$0, d0
01017a30  00000000          ori.b    #$0, d0
01017a34  00000000          ori.b    #$0, d0
01017a38  00000000          ori.b    #$0, d0
01017a3c  00000000          ori.b    #$0, d0
01017a40  00000000          ori.b    #$0, d0
01017a44  00000000          ori.b    #$0, d0
01017a48  00000000          ori.b    #$0, d0
01017a4c  00000000          ori.b    #$0, d0
01017a50  00000000          ori.b    #$0, d0
01017a54  00000000          ori.b    #$0, d0
01017a58  00000000          ori.b    #$0, d0
01017a5c  00000000          ori.b    #$0, d0
01017a60  00000000          ori.b    #$0, d0
01017a64  00000000          ori.b    #$0, d0
01017a68  00000000          ori.b    #$0, d0
01017a6c  00000000          ori.b    #$0, d0
01017a70  00000000          ori.b    #$0, d0
01017a74  00000000          ori.b    #$0, d0
01017a78  00000000          ori.b    #$0, d0
01017a7c  00000000          ori.b    #$0, d0
01017a80  00000000          ori.b    #$0, d0
01017a84  00000000          ori.b    #$0, d0
01017a88  00000000          ori.b    #$0, d0
01017a8c  00000000          ori.b    #$0, d0
01017a90  00000000          ori.b    #$0, d0
01017a94  00000000          ori.b    #$0, d0
01017a98  00000000          ori.b    #$0, d0
01017a9c  00000000          ori.b    #$0, d0
01017aa0  00000000          ori.b    #$0, d0
01017aa4  00000000          ori.b    #$0, d0
01017aa8  00000000          ori.b    #$0, d0
01017aac  00000000          ori.b    #$0, d0
01017ab0  00000000          ori.b    #$0, d0
01017ab4  00000000          ori.b    #$0, d0
01017ab8  00000000          ori.b    #$0, d0
01017abc  00000000          ori.b    #$0, d0
01017ac0  00000000          ori.b    #$0, d0
01017ac4  00000000          ori.b    #$0, d0
01017ac8  00000000          ori.b    #$0, d0
01017acc  00000000          ori.b    #$0, d0
01017ad0  00000000          ori.b    #$0, d0
01017ad4  00000000          ori.b    #$0, d0
01017ad8  00000000          ori.b    #$0, d0
01017adc  00000000          ori.b    #$0, d0
01017ae0  00000000          ori.b    #$0, d0
01017ae4  00000000          ori.b    #$0, d0
01017ae8  00000000          ori.b    #$0, d0
01017aec  00000000          ori.b    #$0, d0
01017af0  00000000          ori.b    #$0, d0
01017af4  00000000          ori.b    #$0, d0
01017af8  00000000          ori.b    #$0, d0
01017afc  00000000          ori.b    #$0, d0
01017b00  00000000          ori.b    #$0, d0
01017b04  00000000          ori.b    #$0, d0
01017b08  00000000          ori.b    #$0, d0
01017b0c  00000000          ori.b    #$0, d0
01017b10  00000000          ori.b    #$0, d0
01017b14  00000000          ori.b    #$0, d0
01017b18  00000000          ori.b    #$0, d0
01017b1c  00000000          ori.b    #$0, d0
01017b20  00000000          ori.b    #$0, d0
01017b24  00000000          ori.b    #$0, d0
01017b28  00000000          ori.b    #$0, d0
01017b2c  00000000          ori.b    #$0, d0
01017b30  00000000          ori.b    #$0, d0
01017b34  00000000          ori.b    #$0, d0
01017b38  00000000          ori.b    #$0, d0
01017b3c  00000000          ori.b    #$0, d0
01017b40  00000000          ori.b    #$0, d0
01017b44  00000000          ori.b    #$0, d0
01017b48  00000000          ori.b    #$0, d0
01017b4c  00000000          ori.b    #$0, d0
01017b50  00000000          ori.b    #$0, d0
01017b54  00000000          ori.b    #$0, d0
01017b58  00000000          ori.b    #$0, d0
01017b5c  00000000          ori.b    #$0, d0
01017b60  00000000          ori.b    #$0, d0
01017b64  00000000          ori.b    #$0, d0
01017b68  00000000          ori.b    #$0, d0
01017b6c  00000000          ori.b    #$0, d0
01017b70  00000000          ori.b    #$0, d0
01017b74  00000000          ori.b    #$0, d0
01017b78  00000000          ori.b    #$0, d0
01017b7c  00000000          ori.b    #$0, d0
01017b80  00000000          ori.b    #$0, d0
01017b84  00000000          ori.b    #$0, d0
01017b88  00000000          ori.b    #$0, d0
01017b8c  00000000          ori.b    #$0, d0
01017b90  00000000          ori.b    #$0, d0
01017b94  00000000          ori.b    #$0, d0
01017b98  00000000          ori.b    #$0, d0
01017b9c  00000000          ori.b    #$0, d0
01017ba0  00000000          ori.b    #$0, d0
01017ba4  00000000          ori.b    #$0, d0
01017ba8  00000000          ori.b    #$0, d0
01017bac  00000000          ori.b    #$0, d0
01017bb0  00000000          ori.b    #$0, d0
01017bb4  00000000          ori.b    #$0, d0
01017bb8  00000000          ori.b    #$0, d0
01017bbc  00000000          ori.b    #$0, d0
01017bc0  00000000          ori.b    #$0, d0
01017bc4  00000000          ori.b    #$0, d0
01017bc8  00000000          ori.b    #$0, d0
01017bcc  00000000          ori.b    #$0, d0
01017bd0  00000000          ori.b    #$0, d0
01017bd4  00000000          ori.b    #$0, d0
01017bd8  00000000          ori.b    #$0, d0
01017bdc  00000000          ori.b    #$0, d0
01017be0  00000000          ori.b    #$0, d0
01017be4  00000000          ori.b    #$0, d0
01017be8  00000000          ori.b    #$0, d0
01017bec  00000000          ori.b    #$0, d0
01017bf0  00000000          ori.b    #$0, d0
01017bf4  00000000          ori.b    #$0, d0
01017bf8  00000000          ori.b    #$0, d0
01017bfc  00000000          ori.b    #$0, d0
01017c00  00000000          ori.b    #$0, d0
01017c04  00000000          ori.b    #$0, d0
01017c08  00000000          ori.b    #$0, d0
01017c0c  00000000          ori.b    #$0, d0
01017c10  00000000          ori.b    #$0, d0
01017c14  00000000          ori.b    #$0, d0
01017c18  00000000          ori.b    #$0, d0
01017c1c  00000000          ori.b    #$0, d0
01017c20  00000000          ori.b    #$0, d0
01017c24  00000000          ori.b    #$0, d0
01017c28  00000000          ori.b    #$0, d0
01017c2c  00000000          ori.b    #$0, d0
01017c30  00000000          ori.b    #$0, d0
01017c34  00000000          ori.b    #$0, d0
01017c38  00000000          ori.b    #$0, d0
01017c3c  00000000          ori.b    #$0, d0
01017c40  00000000          ori.b    #$0, d0
01017c44  00000000          ori.b    #$0, d0
01017c48  00000000          ori.b    #$0, d0
01017c4c  00000000          ori.b    #$0, d0
01017c50  00000000          ori.b    #$0, d0
01017c54  00000000          ori.b    #$0, d0
01017c58  00000000          ori.b    #$0, d0
01017c5c  00000000          ori.b    #$0, d0
01017c60  00000000          ori.b    #$0, d0
01017c64  00000000          ori.b    #$0, d0
01017c68  00000000          ori.b    #$0, d0
01017c6c  00000000          ori.b    #$0, d0
01017c70  00000000          ori.b    #$0, d0
01017c74  00000000          ori.b    #$0, d0
01017c78  00000000          ori.b    #$0, d0
01017c7c  00000000          ori.b    #$0, d0
01017c80  00000000          ori.b    #$0, d0
01017c84  00000000          ori.b    #$0, d0
01017c88  00000000          ori.b    #$0, d0
01017c8c  00000000          ori.b    #$0, d0
01017c90  00000000          ori.b    #$0, d0
01017c94  00000000          ori.b    #$0, d0
01017c98  00000000          ori.b    #$0, d0
01017c9c  00000000          ori.b    #$0, d0
01017ca0  00000000          ori.b    #$0, d0
01017ca4  00000000          ori.b    #$0, d0
01017ca8  00000000          ori.b    #$0, d0
01017cac  00000000          ori.b    #$0, d0
01017cb0  00000000          ori.b    #$0, d0
01017cb4  00000000          ori.b    #$0, d0
01017cb8  00000000          ori.b    #$0, d0
01017cbc  00000000          ori.b    #$0, d0
01017cc0  00000000          ori.b    #$0, d0
01017cc4  00000000          ori.b    #$0, d0
01017cc8  00000000          ori.b    #$0, d0
01017ccc  00000000          ori.b    #$0, d0
01017cd0  00000000          ori.b    #$0, d0
01017cd4  00000000          ori.b    #$0, d0
01017cd8  00000000          ori.b    #$0, d0
01017cdc  00000000          ori.b    #$0, d0
01017ce0  00000000          ori.b    #$0, d0
01017ce4  00000000          ori.b    #$0, d0
01017ce8  00000000          ori.b    #$0, d0
01017cec  00000000          ori.b    #$0, d0
01017cf0  00000000          ori.b    #$0, d0
01017cf4  00000000          ori.b    #$0, d0
01017cf8  00000000          ori.b    #$0, d0
01017cfc  00000000          ori.b    #$0, d0
01017d00  00000000          ori.b    #$0, d0
01017d04  00000000          ori.b    #$0, d0
01017d08  00000000          ori.b    #$0, d0
01017d0c  00000000          ori.b    #$0, d0
01017d10  00000000          ori.b    #$0, d0
01017d14  00000000          ori.b    #$0, d0
01017d18  00000000          ori.b    #$0, d0
01017d1c  00000000          ori.b    #$0, d0
01017d20  00000000          ori.b    #$0, d0
01017d24  00000000          ori.b    #$0, d0
01017d28  00000000          ori.b    #$0, d0
01017d2c  00000000          ori.b    #$0, d0
01017d30  00000000          ori.b    #$0, d0
01017d34  00000000          ori.b    #$0, d0
01017d38  00000000          ori.b    #$0, d0
01017d3c  00000000          ori.b    #$0, d0
01017d40  00000000          ori.b    #$0, d0
01017d44  00000000          ori.b    #$0, d0
01017d48  00000000          ori.b    #$0, d0
01017d4c  00000000          ori.b    #$0, d0
01017d50  00000000          ori.b    #$0, d0
01017d54  00000000          ori.b    #$0, d0
01017d58  00000000          ori.b    #$0, d0
01017d5c  00000000          ori.b    #$0, d0
01017d60  00000000          ori.b    #$0, d0
01017d64  00000000          ori.b    #$0, d0
01017d68  00000000          ori.b    #$0, d0
01017d6c  00000000          ori.b    #$0, d0
01017d70  00000000          ori.b    #$0, d0
01017d74  00000000          ori.b    #$0, d0
01017d78  00000000          ori.b    #$0, d0
01017d7c  00000000          ori.b    #$0, d0
01017d80  00000000          ori.b    #$0, d0
01017d84  00000000          ori.b    #$0, d0
01017d88  00000000          ori.b    #$0, d0
01017d8c  00000000          ori.b    #$0, d0
01017d90  00000000          ori.b    #$0, d0
01017d94  00000000          ori.b    #$0, d0
01017d98  00000000          ori.b    #$0, d0
01017d9c  00000000          ori.b    #$0, d0
01017da0  00000000          ori.b    #$0, d0
01017da4  00000000          ori.b    #$0, d0
01017da8  00000000          ori.b    #$0, d0
01017dac  00000000          ori.b    #$0, d0
01017db0  00000000          ori.b    #$0, d0
01017db4  00000000          ori.b    #$0, d0
01017db8  00000000          ori.b    #$0, d0
01017dbc  00000000          ori.b    #$0, d0
01017dc0  00000000          ori.b    #$0, d0
01017dc4  00000000          ori.b    #$0, d0
01017dc8  00000000          ori.b    #$0, d0
01017dcc  00000000          ori.b    #$0, d0
01017dd0  00000000          ori.b    #$0, d0
01017dd4  00000000          ori.b    #$0, d0
01017dd8  00000000          ori.b    #$0, d0
01017ddc  00000000          ori.b    #$0, d0
01017de0  00000000          ori.b    #$0, d0
01017de4  00000000          ori.b    #$0, d0
01017de8  00000000          ori.b    #$0, d0
01017dec  00000000          ori.b    #$0, d0
01017df0  00000000          ori.b    #$0, d0
01017df4  00000000          ori.b    #$0, d0
01017df8  00000000          ori.b    #$0, d0
01017dfc  00000000          ori.b    #$0, d0
01017e00  00000000          ori.b    #$0, d0
01017e04  00000000          ori.b    #$0, d0
01017e08  00000000          ori.b    #$0, d0
01017e0c  00000000          ori.b    #$0, d0
01017e10  00000000          ori.b    #$0, d0
01017e14  00000000          ori.b    #$0, d0
01017e18  00000000          ori.b    #$0, d0
01017e1c  00000000          ori.b    #$0, d0
01017e20  00000000          ori.b    #$0, d0
01017e24  00000000          ori.b    #$0, d0
01017e28  00000000          ori.b    #$0, d0
01017e2c  00000000          ori.b    #$0, d0
01017e30  00000000          ori.b    #$0, d0
01017e34  00000000          ori.b    #$0, d0
01017e38  00000000          ori.b    #$0, d0
01017e3c  00000000          ori.b    #$0, d0
01017e40  00000000          ori.b    #$0, d0
01017e44  00000000          ori.b    #$0, d0
01017e48  00000000          ori.b    #$0, d0
01017e4c  00000000          ori.b    #$0, d0
01017e50  00000000          ori.b    #$0, d0
01017e54  00000000          ori.b    #$0, d0
01017e58  00000000          ori.b    #$0, d0
01017e5c  00000000          ori.b    #$0, d0
01017e60  00000000          ori.b    #$0, d0
01017e64  00000000          ori.b    #$0, d0
01017e68  00000000          ori.b    #$0, d0
01017e6c  00000000          ori.b    #$0, d0
01017e70  00000000          ori.b    #$0, d0
01017e74  00000000          ori.b    #$0, d0
01017e78  00000000          ori.b    #$0, d0
01017e7c  00000000          ori.b    #$0, d0
01017e80  00000000          ori.b    #$0, d0
01017e84  00000000          ori.b    #$0, d0
01017e88  00000000          ori.b    #$0, d0
01017e8c  00000000          ori.b    #$0, d0
01017e90  00000000          ori.b    #$0, d0
01017e94  00000000          ori.b    #$0, d0
01017e98  00000000          ori.b    #$0, d0
01017e9c  00000000          ori.b    #$0, d0
01017ea0  00000000          ori.b    #$0, d0
01017ea4  00000000          ori.b    #$0, d0
01017ea8  00000000          ori.b    #$0, d0
01017eac  00000000          ori.b    #$0, d0
01017eb0  00000000          ori.b    #$0, d0
01017eb4  00000000          ori.b    #$0, d0
01017eb8  00000000          ori.b    #$0, d0
01017ebc  00000000          ori.b    #$0, d0
01017ec0  00000000          ori.b    #$0, d0
01017ec4  00000000          ori.b    #$0, d0
01017ec8  00000000          ori.b    #$0, d0
01017ecc  00000000          ori.b    #$0, d0
01017ed0  00000000          ori.b    #$0, d0
01017ed4  00000000          ori.b    #$0, d0
01017ed8  00000000          ori.b    #$0, d0
01017edc  00000000          ori.b    #$0, d0
01017ee0  00000000          ori.b    #$0, d0
01017ee4  00000000          ori.b    #$0, d0
01017ee8  00000000          ori.b    #$0, d0
01017eec  00000000          ori.b    #$0, d0
01017ef0  00000000          ori.b    #$0, d0
01017ef4  00000000          ori.b    #$0, d0
01017ef8  00000000          ori.b    #$0, d0
01017efc  00000000          ori.b    #$0, d0
01017f00  00000000          ori.b    #$0, d0
01017f04  00000000          ori.b    #$0, d0
01017f08  00000000          ori.b    #$0, d0
01017f0c  00000000          ori.b    #$0, d0
01017f10  00000000          ori.b    #$0, d0
01017f14  00000000          ori.b    #$0, d0
01017f18  00000000          ori.b    #$0, d0
01017f1c  00000000          ori.b    #$0, d0
01017f20  00000000          ori.b    #$0, d0
01017f24  00000000          ori.b    #$0, d0
01017f28  00000000          ori.b    #$0, d0
01017f2c  00000000          ori.b    #$0, d0
01017f30  00000000          ori.b    #$0, d0
01017f34  00000000          ori.b    #$0, d0
01017f38  00000000          ori.b    #$0, d0
01017f3c  00000000          ori.b    #$0, d0
01017f40  00000000          ori.b    #$0, d0
01017f44  00000000          ori.b    #$0, d0
01017f48  00000000          ori.b    #$0, d0
01017f4c  00000000          ori.b    #$0, d0
01017f50  00000000          ori.b    #$0, d0
01017f54  00000000          ori.b    #$0, d0
01017f58  00000000          ori.b    #$0, d0
01017f5c  00000000          ori.b    #$0, d0
01017f60  00000000          ori.b    #$0, d0
01017f64  00000000          ori.b    #$0, d0
01017f68  00000000          ori.b    #$0, d0
01017f6c  00000000          ori.b    #$0, d0
01017f70  00000000          ori.b    #$0, d0
01017f74  00000000          ori.b    #$0, d0
01017f78  00000000          ori.b    #$0, d0
01017f7c  00000000          ori.b    #$0, d0
01017f80  00000000          ori.b    #$0, d0
01017f84  00000000          ori.b    #$0, d0
01017f88  00000000          ori.b    #$0, d0
01017f8c  00000000          ori.b    #$0, d0
01017f90  00000000          ori.b    #$0, d0
01017f94  00000000          ori.b    #$0, d0
01017f98  00000000          ori.b    #$0, d0
01017f9c  00000000          ori.b    #$0, d0
01017fa0  00000000          ori.b    #$0, d0
01017fa4  00000000          ori.b    #$0, d0
01017fa8  00000000          ori.b    #$0, d0
01017fac  00000000          ori.b    #$0, d0
01017fb0  00000000          ori.b    #$0, d0
01017fb4  00000000          ori.b    #$0, d0
01017fb8  00000000          ori.b    #$0, d0
01017fbc  00000000          ori.b    #$0, d0
01017fc0  00000000          ori.b    #$0, d0
01017fc4  00000000          ori.b    #$0, d0
01017fc8  00000000          ori.b    #$0, d0
01017fcc  00000000          ori.b    #$0, d0
01017fd0  00000000          ori.b    #$0, d0
01017fd4  00000000          ori.b    #$0, d0
01017fd8  00000000          ori.b    #$0, d0
01017fdc  00000000          ori.b    #$0, d0
01017fe0  00000000          ori.b    #$0, d0
01017fe4  00000000          ori.b    #$0, d0
01017fe8  00000000          ori.b    #$0, d0
01017fec  00000000          ori.b    #$0, d0
01017ff0  00000000          ori.b    #$0, d0
01017ff4  00000000          ori.b    #$0, d0
01017ff8  00000000          ori.b    #$0, d0
01017ffc  00000000          ori.b    #$0, d0
01018000  00000000          ori.b    #$0, d0
01018004  00000000          ori.b    #$0, d0
01018008  00000000          ori.b    #$0, d0
0101800c  00000000          ori.b    #$0, d0
01018010  00000000          ori.b    #$0, d0
01018014  00000000          ori.b    #$0, d0
01018018  00000000          ori.b    #$0, d0
0101801c  00000000          ori.b    #$0, d0
01018020  00000000          ori.b    #$0, d0
01018024  00000000          ori.b    #$0, d0
01018028  00000000          ori.b    #$0, d0
0101802c  00000000          ori.b    #$0, d0
01018030  00000000          ori.b    #$0, d0
01018034  00000000          ori.b    #$0, d0
01018038  00000000          ori.b    #$0, d0
0101803c  00000000          ori.b    #$0, d0
01018040  00000000          ori.b    #$0, d0
01018044  00000000          ori.b    #$0, d0
01018048  00000000          ori.b    #$0, d0
0101804c  00000000          ori.b    #$0, d0
01018050  00000000          ori.b    #$0, d0
01018054  00000000          ori.b    #$0, d0
01018058  00000000          ori.b    #$0, d0
0101805c  00000000          ori.b    #$0, d0
01018060  00000000          ori.b    #$0, d0
01018064  00000000          ori.b    #$0, d0
01018068  00000000          ori.b    #$0, d0
0101806c  00000000          ori.b    #$0, d0
01018070  00000000          ori.b    #$0, d0
01018074  00000000          ori.b    #$0, d0
01018078  00000000          ori.b    #$0, d0
0101807c  00000000          ori.b    #$0, d0
01018080  00000000          ori.b    #$0, d0
01018084  00000000          ori.b    #$0, d0
01018088  00000000          ori.b    #$0, d0
0101808c  00000000          ori.b    #$0, d0
01018090  00000000          ori.b    #$0, d0
01018094  00000000          ori.b    #$0, d0
01018098  00000000          ori.b    #$0, d0
0101809c  00000000          ori.b    #$0, d0
010180a0  00000000          ori.b    #$0, d0
010180a4  00000000          ori.b    #$0, d0
010180a8  00000000          ori.b    #$0, d0
010180ac  00000000          ori.b    #$0, d0
010180b0  00000000          ori.b    #$0, d0
010180b4  00000000          ori.b    #$0, d0
010180b8  00000000          ori.b    #$0, d0
010180bc  00000000          ori.b    #$0, d0
010180c0  00000000          ori.b    #$0, d0
010180c4  00000000          ori.b    #$0, d0
010180c8  00000000          ori.b    #$0, d0
010180cc  00000000          ori.b    #$0, d0
010180d0  00000000          ori.b    #$0, d0
010180d4  00000000          ori.b    #$0, d0
010180d8  00000000          ori.b    #$0, d0
010180dc  00000000          ori.b    #$0, d0
010180e0  00000000          ori.b    #$0, d0
010180e4  00000000          ori.b    #$0, d0
010180e8  00000000          ori.b    #$0, d0
010180ec  00000000          ori.b    #$0, d0
010180f0  00000000          ori.b    #$0, d0
010180f4  00000000          ori.b    #$0, d0
010180f8  00000000          ori.b    #$0, d0
010180fc  00000000          ori.b    #$0, d0
01018100  00000000          ori.b    #$0, d0
01018104  00000000          ori.b    #$0, d0
01018108  00000000          ori.b    #$0, d0
0101810c  00000000          ori.b    #$0, d0
01018110  00000000          ori.b    #$0, d0
01018114  00000000          ori.b    #$0, d0
01018118  00000000          ori.b    #$0, d0
0101811c  00000000          ori.b    #$0, d0
01018120  00000000          ori.b    #$0, d0
01018124  00000000          ori.b    #$0, d0
01018128  00000000          ori.b    #$0, d0
0101812c  00000000          ori.b    #$0, d0
01018130  00000000          ori.b    #$0, d0
01018134  00000000          ori.b    #$0, d0
01018138  00000000          ori.b    #$0, d0
0101813c  00000000          ori.b    #$0, d0
01018140  00000000          ori.b    #$0, d0
01018144  00000000          ori.b    #$0, d0
01018148  00000000          ori.b    #$0, d0
0101814c  00000000          ori.b    #$0, d0
01018150  00000000          ori.b    #$0, d0
01018154  00000000          ori.b    #$0, d0
01018158  00000000          ori.b    #$0, d0
0101815c  00000000          ori.b    #$0, d0
01018160  00000000          ori.b    #$0, d0
01018164  00000000          ori.b    #$0, d0
01018168  00000000          ori.b    #$0, d0
0101816c  00000000          ori.b    #$0, d0
01018170  00000000          ori.b    #$0, d0
01018174  00000000          ori.b    #$0, d0
01018178  00000000          ori.b    #$0, d0
0101817c  00000000          ori.b    #$0, d0
01018180  00000000          ori.b    #$0, d0
01018184  00000000          ori.b    #$0, d0
01018188  00000000          ori.b    #$0, d0
0101818c  00000000          ori.b    #$0, d0
01018190  00000000          ori.b    #$0, d0
01018194  00000000          ori.b    #$0, d0
01018198  00000000          ori.b    #$0, d0
0101819c  00000000          ori.b    #$0, d0
010181a0  00000000          ori.b    #$0, d0
010181a4  00000000          ori.b    #$0, d0
010181a8  00000000          ori.b    #$0, d0
010181ac  00000000          ori.b    #$0, d0
010181b0  00000000          ori.b    #$0, d0
010181b4  00000000          ori.b    #$0, d0
010181b8  00000000          ori.b    #$0, d0
010181bc  00000000          ori.b    #$0, d0
010181c0  00000000          ori.b    #$0, d0
010181c4  00000000          ori.b    #$0, d0
010181c8  00000000          ori.b    #$0, d0
010181cc  00000000          ori.b    #$0, d0
010181d0  00000000          ori.b    #$0, d0
010181d4  00000000          ori.b    #$0, d0
010181d8  00000000          ori.b    #$0, d0
010181dc  00000000          ori.b    #$0, d0
010181e0  00000000          ori.b    #$0, d0
010181e4  00000000          ori.b    #$0, d0
010181e8  00000000          ori.b    #$0, d0
010181ec  00000000          ori.b    #$0, d0
010181f0  00000000          ori.b    #$0, d0
010181f4  00000000          ori.b    #$0, d0
010181f8  00000000          ori.b    #$0, d0
010181fc  00000000          ori.b    #$0, d0
01018200  00000000          ori.b    #$0, d0
01018204  00000000          ori.b    #$0, d0
01018208  00000000          ori.b    #$0, d0
0101820c  00000000          ori.b    #$0, d0
01018210  00000000          ori.b    #$0, d0
01018214  00000000          ori.b    #$0, d0
01018218  00000000          ori.b    #$0, d0
0101821c  00000000          ori.b    #$0, d0
01018220  00000000          ori.b    #$0, d0
01018224  00000000          ori.b    #$0, d0
01018228  00000000          ori.b    #$0, d0
0101822c  00000000          ori.b    #$0, d0
01018230  00000000          ori.b    #$0, d0
01018234  00000000          ori.b    #$0, d0
01018238  00000000          ori.b    #$0, d0
0101823c  00000000          ori.b    #$0, d0
01018240  00000000          ori.b    #$0, d0
01018244  00000000          ori.b    #$0, d0
01018248  00000000          ori.b    #$0, d0
0101824c  00000000          ori.b    #$0, d0
01018250  00000000          ori.b    #$0, d0
01018254  00000000          ori.b    #$0, d0
01018258  00000000          ori.b    #$0, d0
0101825c  00000000          ori.b    #$0, d0
01018260  00000000          ori.b    #$0, d0
01018264  00000000          ori.b    #$0, d0
01018268  00000000          ori.b    #$0, d0
0101826c  00000000          ori.b    #$0, d0
01018270  00000000          ori.b    #$0, d0
01018274  00000000          ori.b    #$0, d0
01018278  00000000          ori.b    #$0, d0
0101827c  00000000          ori.b    #$0, d0
01018280  00000000          ori.b    #$0, d0
01018284  00000000          ori.b    #$0, d0
01018288  00000000          ori.b    #$0, d0
0101828c  00000000          ori.b    #$0, d0
01018290  00000000          ori.b    #$0, d0
01018294  00000000          ori.b    #$0, d0
01018298  00000000          ori.b    #$0, d0
0101829c  00000000          ori.b    #$0, d0
010182a0  00000000          ori.b    #$0, d0
010182a4  00000000          ori.b    #$0, d0
010182a8  00000000          ori.b    #$0, d0
010182ac  00000000          ori.b    #$0, d0
010182b0  00000000          ori.b    #$0, d0
010182b4  00000000          ori.b    #$0, d0
010182b8  00000000          ori.b    #$0, d0
010182bc  00000000          ori.b    #$0, d0
010182c0  00000000          ori.b    #$0, d0
010182c4  00000000          ori.b    #$0, d0
010182c8  00000000          ori.b    #$0, d0
010182cc  00000000          ori.b    #$0, d0
010182d0  00000000          ori.b    #$0, d0
010182d4  00000000          ori.b    #$0, d0
010182d8  00000000          ori.b    #$0, d0
010182dc  00000000          ori.b    #$0, d0
010182e0  00000000          ori.b    #$0, d0
010182e4  00000000          ori.b    #$0, d0
010182e8  00000000          ori.b    #$0, d0
010182ec  00000000          ori.b    #$0, d0
010182f0  00000000          ori.b    #$0, d0
010182f4  00000000          ori.b    #$0, d0
010182f8  00000000          ori.b    #$0, d0
010182fc  00000000          ori.b    #$0, d0
01018300  00000000          ori.b    #$0, d0
01018304  00000000          ori.b    #$0, d0
01018308  00000000          ori.b    #$0, d0
0101830c  00000000          ori.b    #$0, d0
01018310  00000000          ori.b    #$0, d0
01018314  00000000          ori.b    #$0, d0
01018318  00000000          ori.b    #$0, d0
0101831c  00000000          ori.b    #$0, d0
01018320  00000000          ori.b    #$0, d0
01018324  00000000          ori.b    #$0, d0
01018328  00000000          ori.b    #$0, d0
0101832c  00000000          ori.b    #$0, d0
01018330  00000000          ori.b    #$0, d0
01018334  00000000          ori.b    #$0, d0
01018338  00000000          ori.b    #$0, d0
0101833c  00000000          ori.b    #$0, d0
01018340  00000000          ori.b    #$0, d0
01018344  00000000          ori.b    #$0, d0
01018348  00000000          ori.b    #$0, d0
0101834c  00000000          ori.b    #$0, d0
01018350  00000000          ori.b    #$0, d0
01018354  00000000          ori.b    #$0, d0
01018358  00000000          ori.b    #$0, d0
0101835c  00000000          ori.b    #$0, d0
01018360  00000000          ori.b    #$0, d0
01018364  00000000          ori.b    #$0, d0
01018368  00000000          ori.b    #$0, d0
0101836c  00000000          ori.b    #$0, d0
01018370  00000000          ori.b    #$0, d0
01018374  00000000          ori.b    #$0, d0
01018378  00000000          ori.b    #$0, d0
0101837c  00000000          ori.b    #$0, d0
01018380  00000000          ori.b    #$0, d0
01018384  00000000          ori.b    #$0, d0
01018388  00000000          ori.b    #$0, d0
0101838c  00000000          ori.b    #$0, d0
01018390  00000000          ori.b    #$0, d0
01018394  00000000          ori.b    #$0, d0
01018398  00000000          ori.b    #$0, d0
0101839c  00000000          ori.b    #$0, d0
010183a0  00000000          ori.b    #$0, d0
010183a4  00000000          ori.b    #$0, d0
010183a8  00000000          ori.b    #$0, d0
010183ac  00000000          ori.b    #$0, d0
010183b0  00000000          ori.b    #$0, d0
010183b4  00000000          ori.b    #$0, d0
010183b8  00000000          ori.b    #$0, d0
010183bc  00000000          ori.b    #$0, d0
010183c0  00000000          ori.b    #$0, d0
010183c4  00000000          ori.b    #$0, d0
010183c8  00000000          ori.b    #$0, d0
010183cc  00000000          ori.b    #$0, d0
010183d0  00000000          ori.b    #$0, d0
010183d4  00000000          ori.b    #$0, d0
010183d8  00000000          ori.b    #$0, d0
010183dc  00000000          ori.b    #$0, d0
010183e0  00000000          ori.b    #$0, d0
010183e4  00000000          ori.b    #$0, d0
010183e8  00000000          ori.b    #$0, d0
010183ec  00000000          ori.b    #$0, d0
010183f0  00000000          ori.b    #$0, d0
010183f4  00000000          ori.b    #$0, d0
010183f8  00000000          ori.b    #$0, d0
010183fc  00000000          ori.b    #$0, d0
01018400  00000000          ori.b    #$0, d0
01018404  00000000          ori.b    #$0, d0
01018408  00000000          ori.b    #$0, d0
0101840c  00000000          ori.b    #$0, d0
01018410  00000000          ori.b    #$0, d0
01018414  00000000          ori.b    #$0, d0
01018418  00000000          ori.b    #$0, d0
0101841c  00000000          ori.b    #$0, d0
01018420  00000000          ori.b    #$0, d0
01018424  00000000          ori.b    #$0, d0
01018428  00000000          ori.b    #$0, d0
0101842c  00000000          ori.b    #$0, d0
01018430  00000000          ori.b    #$0, d0
01018434  00000000          ori.b    #$0, d0
01018438  00000000          ori.b    #$0, d0
0101843c  00000000          ori.b    #$0, d0
01018440  00000000          ori.b    #$0, d0
01018444  00000000          ori.b    #$0, d0
01018448  00000000          ori.b    #$0, d0
0101844c  00000000          ori.b    #$0, d0
01018450  00000000          ori.b    #$0, d0
01018454  00000000          ori.b    #$0, d0
01018458  00000000          ori.b    #$0, d0
0101845c  00000000          ori.b    #$0, d0
01018460  00000000          ori.b    #$0, d0
01018464  00000000          ori.b    #$0, d0
01018468  00000000          ori.b    #$0, d0
0101846c  00000000          ori.b    #$0, d0
01018470  00000000          ori.b    #$0, d0
01018474  00000000          ori.b    #$0, d0
01018478  00000000          ori.b    #$0, d0
0101847c  00000000          ori.b    #$0, d0
01018480  00000000          ori.b    #$0, d0
01018484  00000000          ori.b    #$0, d0
01018488  00000000          ori.b    #$0, d0
0101848c  00000000          ori.b    #$0, d0
01018490  00000000          ori.b    #$0, d0
01018494  00000000          ori.b    #$0, d0
01018498  00000000          ori.b    #$0, d0
0101849c  00000000          ori.b    #$0, d0
010184a0  00000000          ori.b    #$0, d0
010184a4  00000000          ori.b    #$0, d0
010184a8  00000000          ori.b    #$0, d0
010184ac  00000000          ori.b    #$0, d0
010184b0  00000000          ori.b    #$0, d0
010184b4  00000000          ori.b    #$0, d0
010184b8  00000000          ori.b    #$0, d0
010184bc  00000000          ori.b    #$0, d0
010184c0  00000000          ori.b    #$0, d0
010184c4  00000000          ori.b    #$0, d0
010184c8  00000000          ori.b    #$0, d0
010184cc  00000000          ori.b    #$0, d0
010184d0  00000000          ori.b    #$0, d0
010184d4  00000000          ori.b    #$0, d0
010184d8  00000000          ori.b    #$0, d0
010184dc  00000000          ori.b    #$0, d0
010184e0  00000000          ori.b    #$0, d0
010184e4  00000000          ori.b    #$0, d0
010184e8  00000000          ori.b    #$0, d0
010184ec  00000000          ori.b    #$0, d0
010184f0  00000000          ori.b    #$0, d0
010184f4  00000000          ori.b    #$0, d0
010184f8  00000000          ori.b    #$0, d0
010184fc  00000000          ori.b    #$0, d0
01018500  00000000          ori.b    #$0, d0
01018504  00000000          ori.b    #$0, d0
01018508  00000000          ori.b    #$0, d0
0101850c  00000000          ori.b    #$0, d0
01018510  00000000          ori.b    #$0, d0
01018514  00000000          ori.b    #$0, d0
01018518  00000000          ori.b    #$0, d0
0101851c  00000000          ori.b    #$0, d0
01018520  00000000          ori.b    #$0, d0
01018524  00000000          ori.b    #$0, d0
01018528  00000000          ori.b    #$0, d0
0101852c  00000000          ori.b    #$0, d0
01018530  00000000          ori.b    #$0, d0
01018534  00000000          ori.b    #$0, d0
01018538  00000000          ori.b    #$0, d0
0101853c  00000000          ori.b    #$0, d0
01018540  00000000          ori.b    #$0, d0
01018544  00000000          ori.b    #$0, d0
01018548  00000000          ori.b    #$0, d0
0101854c  00000000          ori.b    #$0, d0
01018550  00000000          ori.b    #$0, d0
01018554  00000000          ori.b    #$0, d0
01018558  00000000          ori.b    #$0, d0
0101855c  00000000          ori.b    #$0, d0
01018560  00000000          ori.b    #$0, d0
01018564  00000000          ori.b    #$0, d0
01018568  00000000          ori.b    #$0, d0
0101856c  00000000          ori.b    #$0, d0
01018570  00000000          ori.b    #$0, d0
01018574  00000000          ori.b    #$0, d0
01018578  00000000          ori.b    #$0, d0
0101857c  00000000          ori.b    #$0, d0
01018580  00000000          ori.b    #$0, d0
01018584  00000000          ori.b    #$0, d0
01018588  00000000          ori.b    #$0, d0
0101858c  00000000          ori.b    #$0, d0
01018590  00000000          ori.b    #$0, d0
01018594  00000000          ori.b    #$0, d0
01018598  00000000          ori.b    #$0, d0
0101859c  00000000          ori.b    #$0, d0
010185a0  00000000          ori.b    #$0, d0
010185a4  00000000          ori.b    #$0, d0
010185a8  00000000          ori.b    #$0, d0
010185ac  00000000          ori.b    #$0, d0
010185b0  00000000          ori.b    #$0, d0
010185b4  00000000          ori.b    #$0, d0
010185b8  00000000          ori.b    #$0, d0
010185bc  00000000          ori.b    #$0, d0
010185c0  00000000          ori.b    #$0, d0
010185c4  00000000          ori.b    #$0, d0
010185c8  00000000          ori.b    #$0, d0
010185cc  00000000          ori.b    #$0, d0
010185d0  00000000          ori.b    #$0, d0
010185d4  00000000          ori.b    #$0, d0
010185d8  00000000          ori.b    #$0, d0
010185dc  00000000          ori.b    #$0, d0
010185e0  00000000          ori.b    #$0, d0
010185e4  00000000          ori.b    #$0, d0
010185e8  00000000          ori.b    #$0, d0
010185ec  00000000          ori.b    #$0, d0
010185f0  00000000          ori.b    #$0, d0
010185f4  00000000          ori.b    #$0, d0
010185f8  00000000          ori.b    #$0, d0
010185fc  00000000          ori.b    #$0, d0
01018600  00000000          ori.b    #$0, d0
01018604  00000000          ori.b    #$0, d0
01018608  00000000          ori.b    #$0, d0
0101860c  00000000          ori.b    #$0, d0
01018610  00000000          ori.b    #$0, d0
01018614  00000000          ori.b    #$0, d0
01018618  00000000          ori.b    #$0, d0
0101861c  00000000          ori.b    #$0, d0
01018620  00000000          ori.b    #$0, d0
01018624  00000000          ori.b    #$0, d0
01018628  00000000          ori.b    #$0, d0
0101862c  00000000          ori.b    #$0, d0
01018630  00000000          ori.b    #$0, d0
01018634  00000000          ori.b    #$0, d0
01018638  00000000          ori.b    #$0, d0
0101863c  00000000          ori.b    #$0, d0
01018640  00000000          ori.b    #$0, d0
01018644  00000000          ori.b    #$0, d0
01018648  00000000          ori.b    #$0, d0
0101864c  00000000          ori.b    #$0, d0
01018650  00000000          ori.b    #$0, d0
01018654  00000000          ori.b    #$0, d0
01018658  00000000          ori.b    #$0, d0
0101865c  00000000          ori.b    #$0, d0
01018660  00000000          ori.b    #$0, d0
01018664  00000000          ori.b    #$0, d0
01018668  00000000          ori.b    #$0, d0
0101866c  00000000          ori.b    #$0, d0
01018670  00000000          ori.b    #$0, d0
01018674  00000000          ori.b    #$0, d0
01018678  00000000          ori.b    #$0, d0
0101867c  00000000          ori.b    #$0, d0
01018680  00000000          ori.b    #$0, d0
01018684  00000000          ori.b    #$0, d0
01018688  00000000          ori.b    #$0, d0
0101868c  00000000          ori.b    #$0, d0
01018690  00000000          ori.b    #$0, d0
01018694  00000000          ori.b    #$0, d0
01018698  00000000          ori.b    #$0, d0
0101869c  00000000          ori.b    #$0, d0
010186a0  00000000          ori.b    #$0, d0
010186a4  00000000          ori.b    #$0, d0
010186a8  00000000          ori.b    #$0, d0
010186ac  00000000          ori.b    #$0, d0
010186b0  00000000          ori.b    #$0, d0
010186b4  00000000          ori.b    #$0, d0
010186b8  00000000          ori.b    #$0, d0
010186bc  00000000          ori.b    #$0, d0
010186c0  00000000          ori.b    #$0, d0
010186c4  00000000          ori.b    #$0, d0
010186c8  00000000          ori.b    #$0, d0
010186cc  00000000          ori.b    #$0, d0
010186d0  00000000          ori.b    #$0, d0
010186d4  00000000          ori.b    #$0, d0
010186d8  00000000          ori.b    #$0, d0
010186dc  00000000          ori.b    #$0, d0
010186e0  00000000          ori.b    #$0, d0
010186e4  00000000          ori.b    #$0, d0
010186e8  00000000          ori.b    #$0, d0
010186ec  00000000          ori.b    #$0, d0
010186f0  00000000          ori.b    #$0, d0
010186f4  00000000          ori.b    #$0, d0
010186f8  00000000          ori.b    #$0, d0
010186fc  00000000          ori.b    #$0, d0
01018700  00000000          ori.b    #$0, d0
01018704  00000000          ori.b    #$0, d0
01018708  00000000          ori.b    #$0, d0
0101870c  00000000          ori.b    #$0, d0
01018710  00000000          ori.b    #$0, d0
01018714  00000000          ori.b    #$0, d0
01018718  00000000          ori.b    #$0, d0
0101871c  00000000          ori.b    #$0, d0
01018720  00000000          ori.b    #$0, d0
01018724  00000000          ori.b    #$0, d0
01018728  00000000          ori.b    #$0, d0
0101872c  00000000          ori.b    #$0, d0
01018730  00000000          ori.b    #$0, d0
01018734  00000000          ori.b    #$0, d0
01018738  00000000          ori.b    #$0, d0
0101873c  00000000          ori.b    #$0, d0
01018740  00000000          ori.b    #$0, d0
01018744  00000000          ori.b    #$0, d0
01018748  00000000          ori.b    #$0, d0
0101874c  00000000          ori.b    #$0, d0
01018750  00000000          ori.b    #$0, d0
01018754  00000000          ori.b    #$0, d0
01018758  00000000          ori.b    #$0, d0
0101875c  00000000          ori.b    #$0, d0
01018760  00000000          ori.b    #$0, d0
01018764  00000000          ori.b    #$0, d0
01018768  00000000          ori.b    #$0, d0
0101876c  00000000          ori.b    #$0, d0
01018770  00000000          ori.b    #$0, d0
01018774  00000000          ori.b    #$0, d0
01018778  00000000          ori.b    #$0, d0
0101877c  00000000          ori.b    #$0, d0
01018780  00000000          ori.b    #$0, d0
01018784  00000000          ori.b    #$0, d0
01018788  00000000          ori.b    #$0, d0
0101878c  00000000          ori.b    #$0, d0
01018790  00000000          ori.b    #$0, d0
01018794  00000000          ori.b    #$0, d0
01018798  00000000          ori.b    #$0, d0
0101879c  00000000          ori.b    #$0, d0
010187a0  00000000          ori.b    #$0, d0
010187a4  00000000          ori.b    #$0, d0
010187a8  00000000          ori.b    #$0, d0
010187ac  00000000          ori.b    #$0, d0
010187b0  00000000          ori.b    #$0, d0
010187b4  00000000          ori.b    #$0, d0
010187b8  00000000          ori.b    #$0, d0
010187bc  00000000          ori.b    #$0, d0
010187c0  00000000          ori.b    #$0, d0
010187c4  00000000          ori.b    #$0, d0
010187c8  00000000          ori.b    #$0, d0
010187cc  00000000          ori.b    #$0, d0
010187d0  00000000          ori.b    #$0, d0
010187d4  00000000          ori.b    #$0, d0
010187d8  00000000          ori.b    #$0, d0
010187dc  00000000          ori.b    #$0, d0
010187e0  00000000          ori.b    #$0, d0
010187e4  00000000          ori.b    #$0, d0
010187e8  00000000          ori.b    #$0, d0
010187ec  00000000          ori.b    #$0, d0
010187f0  00000000          ori.b    #$0, d0
010187f4  00000000          ori.b    #$0, d0
010187f8  00000000          ori.b    #$0, d0
010187fc  00000000          ori.b    #$0, d0
01018800  00000000          ori.b    #$0, d0
01018804  00000000          ori.b    #$0, d0
01018808  00000000          ori.b    #$0, d0
0101880c  00000000          ori.b    #$0, d0
01018810  00000000          ori.b    #$0, d0
01018814  00000000          ori.b    #$0, d0
01018818  00000000          ori.b    #$0, d0
0101881c  00000000          ori.b    #$0, d0
01018820  00000000          ori.b    #$0, d0
01018824  00000000          ori.b    #$0, d0
01018828  00000000          ori.b    #$0, d0
0101882c  00000000          ori.b    #$0, d0
01018830  00000000          ori.b    #$0, d0
01018834  00000000          ori.b    #$0, d0
01018838  00000000          ori.b    #$0, d0
0101883c  00000000          ori.b    #$0, d0
01018840  00000000          ori.b    #$0, d0
01018844  00000000          ori.b    #$0, d0
01018848  00000000          ori.b    #$0, d0
0101884c  00000000          ori.b    #$0, d0
01018850  00000000          ori.b    #$0, d0
01018854  00000000          ori.b    #$0, d0
01018858  00000000          ori.b    #$0, d0
0101885c  00000000          ori.b    #$0, d0
01018860  00000000          ori.b    #$0, d0
01018864  00000000          ori.b    #$0, d0
01018868  00000000          ori.b    #$0, d0
0101886c  00000000          ori.b    #$0, d0
01018870  00000000          ori.b    #$0, d0
01018874  00000000          ori.b    #$0, d0
01018878  00000000          ori.b    #$0, d0
0101887c  00000000          ori.b    #$0, d0
01018880  00000000          ori.b    #$0, d0
01018884  00000000          ori.b    #$0, d0
01018888  00000000          ori.b    #$0, d0
0101888c  00000000          ori.b    #$0, d0
01018890  00000000          ori.b    #$0, d0
01018894  00000000          ori.b    #$0, d0
01018898  00000000          ori.b    #$0, d0
0101889c  00000000          ori.b    #$0, d0
010188a0  00000000          ori.b    #$0, d0
010188a4  00000000          ori.b    #$0, d0
010188a8  00000000          ori.b    #$0, d0
010188ac  00000000          ori.b    #$0, d0
010188b0  00000000          ori.b    #$0, d0
010188b4  00000000          ori.b    #$0, d0
010188b8  00000000          ori.b    #$0, d0
010188bc  00000000          ori.b    #$0, d0
010188c0  00000000          ori.b    #$0, d0
010188c4  00000000          ori.b    #$0, d0
010188c8  00000000          ori.b    #$0, d0
010188cc  00000000          ori.b    #$0, d0
010188d0  00000000          ori.b    #$0, d0
010188d4  00000000          ori.b    #$0, d0
010188d8  00000000          ori.b    #$0, d0
010188dc  00000000          ori.b    #$0, d0
010188e0  00000000          ori.b    #$0, d0
010188e4  00000000          ori.b    #$0, d0
010188e8  00000000          ori.b    #$0, d0
010188ec  00000000          ori.b    #$0, d0
010188f0  00000000          ori.b    #$0, d0
010188f4  00000000          ori.b    #$0, d0
010188f8  00000000          ori.b    #$0, d0
010188fc  00000000          ori.b    #$0, d0
01018900  00000000          ori.b    #$0, d0
01018904  00000000          ori.b    #$0, d0
01018908  00000000          ori.b    #$0, d0
0101890c  00000000          ori.b    #$0, d0
01018910  00000000          ori.b    #$0, d0
01018914  00000000          ori.b    #$0, d0
01018918  00000000          ori.b    #$0, d0
0101891c  00000000          ori.b    #$0, d0
01018920  00000000          ori.b    #$0, d0
01018924  00000000          ori.b    #$0, d0
01018928  00000000          ori.b    #$0, d0
0101892c  00000000          ori.b    #$0, d0
01018930  00000000          ori.b    #$0, d0
01018934  00000000          ori.b    #$0, d0
01018938  00000000          ori.b    #$0, d0
0101893c  00000000          ori.b    #$0, d0
01018940  00000000          ori.b    #$0, d0
01018944  00000000          ori.b    #$0, d0
01018948  00000000          ori.b    #$0, d0
0101894c  00000000          ori.b    #$0, d0
01018950  00000000          ori.b    #$0, d0
01018954  00000000          ori.b    #$0, d0
01018958  00000000          ori.b    #$0, d0
0101895c  00000000          ori.b    #$0, d0
01018960  00000000          ori.b    #$0, d0
01018964  00000000          ori.b    #$0, d0
01018968  00000000          ori.b    #$0, d0
0101896c  00000000          ori.b    #$0, d0
01018970  00000000          ori.b    #$0, d0
01018974  00000000          ori.b    #$0, d0
01018978  00000000          ori.b    #$0, d0
0101897c  00000000          ori.b    #$0, d0
01018980  00000000          ori.b    #$0, d0
01018984  00000000          ori.b    #$0, d0
01018988  00000000          ori.b    #$0, d0
0101898c  00000000          ori.b    #$0, d0
01018990  00000000          ori.b    #$0, d0
01018994  00000000          ori.b    #$0, d0
01018998  00000000          ori.b    #$0, d0
0101899c  00000000          ori.b    #$0, d0
010189a0  00000000          ori.b    #$0, d0
010189a4  00000000          ori.b    #$0, d0
010189a8  00000000          ori.b    #$0, d0
010189ac  00000000          ori.b    #$0, d0
010189b0  00000000          ori.b    #$0, d0
010189b4  00000000          ori.b    #$0, d0
010189b8  00000000          ori.b    #$0, d0
010189bc  00000000          ori.b    #$0, d0
010189c0  00000000          ori.b    #$0, d0
010189c4  00000000          ori.b    #$0, d0
010189c8  00000000          ori.b    #$0, d0
010189cc  00000000          ori.b    #$0, d0
010189d0  00000000          ori.b    #$0, d0
010189d4  00000000          ori.b    #$0, d0
010189d8  00000000          ori.b    #$0, d0
010189dc  00000000          ori.b    #$0, d0
010189e0  00000000          ori.b    #$0, d0
010189e4  00000000          ori.b    #$0, d0
010189e8  00000000          ori.b    #$0, d0
010189ec  00000000          ori.b    #$0, d0
010189f0  00000000          ori.b    #$0, d0
010189f4  00000000          ori.b    #$0, d0
010189f8  00000000          ori.b    #$0, d0
010189fc  00000000          ori.b    #$0, d0
01018a00  00000000          ori.b    #$0, d0
01018a04  00000000          ori.b    #$0, d0
01018a08  00000000          ori.b    #$0, d0
01018a0c  00000000          ori.b    #$0, d0
01018a10  00000000          ori.b    #$0, d0
01018a14  00000000          ori.b    #$0, d0
01018a18  00000000          ori.b    #$0, d0
01018a1c  00000000          ori.b    #$0, d0
01018a20  00000000          ori.b    #$0, d0
01018a24  00000000          ori.b    #$0, d0
01018a28  00000000          ori.b    #$0, d0
01018a2c  00000000          ori.b    #$0, d0
01018a30  00000000          ori.b    #$0, d0
01018a34  00000000          ori.b    #$0, d0
01018a38  00000000          ori.b    #$0, d0
01018a3c  00000000          ori.b    #$0, d0
01018a40  00000000          ori.b    #$0, d0
01018a44  00000000          ori.b    #$0, d0
01018a48  00000000          ori.b    #$0, d0
01018a4c  00000000          ori.b    #$0, d0
01018a50  00000000          ori.b    #$0, d0
01018a54  00000000          ori.b    #$0, d0
01018a58  00000000          ori.b    #$0, d0
01018a5c  00000000          ori.b    #$0, d0
01018a60  00000000          ori.b    #$0, d0
01018a64  00000000          ori.b    #$0, d0
01018a68  00000000          ori.b    #$0, d0
01018a6c  00000000          ori.b    #$0, d0
01018a70  00000000          ori.b    #$0, d0
01018a74  00000000          ori.b    #$0, d0
01018a78  00000000          ori.b    #$0, d0
01018a7c  00000000          ori.b    #$0, d0
01018a80  00000000          ori.b    #$0, d0
01018a84  00000000          ori.b    #$0, d0
01018a88  00000000          ori.b    #$0, d0
01018a8c  00000000          ori.b    #$0, d0
01018a90  00000000          ori.b    #$0, d0
01018a94  00000000          ori.b    #$0, d0
01018a98  00000000          ori.b    #$0, d0
01018a9c  00000000          ori.b    #$0, d0
01018aa0  00000000          ori.b    #$0, d0
01018aa4  00000000          ori.b    #$0, d0
01018aa8  00000000          ori.b    #$0, d0
01018aac  00000000          ori.b    #$0, d0
01018ab0  00000000          ori.b    #$0, d0
01018ab4  00000000          ori.b    #$0, d0
01018ab8  00000000          ori.b    #$0, d0
01018abc  00000000          ori.b    #$0, d0
01018ac0  00000000          ori.b    #$0, d0
01018ac4  00000000          ori.b    #$0, d0
01018ac8  00000000          ori.b    #$0, d0
01018acc  00000000          ori.b    #$0, d0
01018ad0  00000000          ori.b    #$0, d0
01018ad4  00000000          ori.b    #$0, d0
01018ad8  00000000          ori.b    #$0, d0
01018adc  00000000          ori.b    #$0, d0
01018ae0  00000000          ori.b    #$0, d0
01018ae4  00000000          ori.b    #$0, d0
01018ae8  00000000          ori.b    #$0, d0
01018aec  00000000          ori.b    #$0, d0
01018af0  00000000          ori.b    #$0, d0
01018af4  00000000          ori.b    #$0, d0
01018af8  00000000          ori.b    #$0, d0
01018afc  00000000          ori.b    #$0, d0
01018b00  00000000          ori.b    #$0, d0
01018b04  00000000          ori.b    #$0, d0
01018b08  00000000          ori.b    #$0, d0
01018b0c  00000000          ori.b    #$0, d0
01018b10  00000000          ori.b    #$0, d0
01018b14  00000000          ori.b    #$0, d0
01018b18  00000000          ori.b    #$0, d0
01018b1c  00000000          ori.b    #$0, d0
01018b20  00000000          ori.b    #$0, d0
01018b24  00000000          ori.b    #$0, d0
01018b28  00000000          ori.b    #$0, d0
01018b2c  00000000          ori.b    #$0, d0
01018b30  00000000          ori.b    #$0, d0
01018b34  00000000          ori.b    #$0, d0
01018b38  00000000          ori.b    #$0, d0
01018b3c  00000000          ori.b    #$0, d0
01018b40  00000000          ori.b    #$0, d0
01018b44  00000000          ori.b    #$0, d0
01018b48  00000000          ori.b    #$0, d0
01018b4c  00000000          ori.b    #$0, d0
01018b50  00000000          ori.b    #$0, d0
01018b54  00000000          ori.b    #$0, d0
01018b58  00000000          ori.b    #$0, d0
01018b5c  00000000          ori.b    #$0, d0
01018b60  00000000          ori.b    #$0, d0
01018b64  00000000          ori.b    #$0, d0
01018b68  00000000          ori.b    #$0, d0
01018b6c  00000000          ori.b    #$0, d0
01018b70  00000000          ori.b    #$0, d0
01018b74  00000000          ori.b    #$0, d0
01018b78  00000000          ori.b    #$0, d0
01018b7c  00000000          ori.b    #$0, d0
01018b80  00000000          ori.b    #$0, d0
01018b84  00000000          ori.b    #$0, d0
01018b88  00000000          ori.b    #$0, d0
01018b8c  00000000          ori.b    #$0, d0
01018b90  00000000          ori.b    #$0, d0
01018b94  00000000          ori.b    #$0, d0
01018b98  00000000          ori.b    #$0, d0
01018b9c  00000000          ori.b    #$0, d0
01018ba0  00000000          ori.b    #$0, d0
01018ba4  00000000          ori.b    #$0, d0
01018ba8  00000000          ori.b    #$0, d0
01018bac  00000000          ori.b    #$0, d0
01018bb0  00000000          ori.b    #$0, d0
01018bb4  00000000          ori.b    #$0, d0
01018bb8  00000000          ori.b    #$0, d0
01018bbc  00000000          ori.b    #$0, d0
01018bc0  00000000          ori.b    #$0, d0
01018bc4  00000000          ori.b    #$0, d0
01018bc8  00000000          ori.b    #$0, d0
01018bcc  00000000          ori.b    #$0, d0
01018bd0  00000000          ori.b    #$0, d0
01018bd4  00000000          ori.b    #$0, d0
01018bd8  00000000          ori.b    #$0, d0
01018bdc  00000000          ori.b    #$0, d0
01018be0  00000000          ori.b    #$0, d0
01018be4  00000000          ori.b    #$0, d0
01018be8  00000000          ori.b    #$0, d0
01018bec  00000000          ori.b    #$0, d0
01018bf0  00000000          ori.b    #$0, d0
01018bf4  00000000          ori.b    #$0, d0
01018bf8  00000000          ori.b    #$0, d0
01018bfc  00000000          ori.b    #$0, d0
01018c00  00000000          ori.b    #$0, d0
01018c04  00000000          ori.b    #$0, d0
01018c08  00000000          ori.b    #$0, d0
01018c0c  00000000          ori.b    #$0, d0
01018c10  00000000          ori.b    #$0, d0
01018c14  00000000          ori.b    #$0, d0
01018c18  00000000          ori.b    #$0, d0
01018c1c  00000000          ori.b    #$0, d0
01018c20  00000000          ori.b    #$0, d0
01018c24  00000000          ori.b    #$0, d0
01018c28  00000000          ori.b    #$0, d0
01018c2c  00000000          ori.b    #$0, d0
01018c30  00000000          ori.b    #$0, d0
01018c34  00000000          ori.b    #$0, d0
01018c38  00000000          ori.b    #$0, d0
01018c3c  00000000          ori.b    #$0, d0
01018c40  00000000          ori.b    #$0, d0
01018c44  00000000          ori.b    #$0, d0
01018c48  00000000          ori.b    #$0, d0
01018c4c  00000000          ori.b    #$0, d0
01018c50  00000000          ori.b    #$0, d0
01018c54  00000000          ori.b    #$0, d0
01018c58  00000000          ori.b    #$0, d0
01018c5c  00000000          ori.b    #$0, d0
01018c60  00000000          ori.b    #$0, d0
01018c64  00000000          ori.b    #$0, d0
01018c68  00000000          ori.b    #$0, d0
01018c6c  00000000          ori.b    #$0, d0
01018c70  00000000          ori.b    #$0, d0
01018c74  00000000          ori.b    #$0, d0
01018c78  00000000          ori.b    #$0, d0
01018c7c  00000000          ori.b    #$0, d0
01018c80  00000000          ori.b    #$0, d0
01018c84  00000000          ori.b    #$0, d0
01018c88  00000000          ori.b    #$0, d0
01018c8c  00000000          ori.b    #$0, d0
01018c90  00000000          ori.b    #$0, d0
01018c94  00000000          ori.b    #$0, d0
01018c98  00000000          ori.b    #$0, d0
01018c9c  00000000          ori.b    #$0, d0
01018ca0  00000000          ori.b    #$0, d0
01018ca4  00000000          ori.b    #$0, d0
01018ca8  00000000          ori.b    #$0, d0
01018cac  00000000          ori.b    #$0, d0
01018cb0  00000000          ori.b    #$0, d0
01018cb4  00000000          ori.b    #$0, d0
01018cb8  00000000          ori.b    #$0, d0
01018cbc  00000000          ori.b    #$0, d0
01018cc0  00000000          ori.b    #$0, d0
01018cc4  00000000          ori.b    #$0, d0
01018cc8  00000000          ori.b    #$0, d0
01018ccc  00000000          ori.b    #$0, d0
01018cd0  00000000          ori.b    #$0, d0
01018cd4  00000000          ori.b    #$0, d0
01018cd8  00000000          ori.b    #$0, d0
01018cdc  00000000          ori.b    #$0, d0
01018ce0  00000000          ori.b    #$0, d0
01018ce4  00000000          ori.b    #$0, d0
01018ce8  00000000          ori.b    #$0, d0
01018cec  00000000          ori.b    #$0, d0
01018cf0  00000000          ori.b    #$0, d0
01018cf4  00000000          ori.b    #$0, d0
01018cf8  00000000          ori.b    #$0, d0
01018cfc  00000000          ori.b    #$0, d0
01018d00  00000000          ori.b    #$0, d0
01018d04  00000000          ori.b    #$0, d0
01018d08  00000000          ori.b    #$0, d0
01018d0c  00000000          ori.b    #$0, d0
01018d10  00000000          ori.b    #$0, d0
01018d14  00000000          ori.b    #$0, d0
01018d18  00000000          ori.b    #$0, d0
01018d1c  00000000          ori.b    #$0, d0
01018d20  00000000          ori.b    #$0, d0
01018d24  00000000          ori.b    #$0, d0
01018d28  00000000          ori.b    #$0, d0
01018d2c  00000000          ori.b    #$0, d0
01018d30  00000000          ori.b    #$0, d0
01018d34  00000000          ori.b    #$0, d0
01018d38  00000000          ori.b    #$0, d0
01018d3c  00000000          ori.b    #$0, d0
01018d40  00000000          ori.b    #$0, d0
01018d44  00000000          ori.b    #$0, d0
01018d48  00000000          ori.b    #$0, d0
01018d4c  00000000          ori.b    #$0, d0
01018d50  00000000          ori.b    #$0, d0
01018d54  00000000          ori.b    #$0, d0
01018d58  00000000          ori.b    #$0, d0
01018d5c  00000000          ori.b    #$0, d0
01018d60  00000000          ori.b    #$0, d0
01018d64  00000000          ori.b    #$0, d0
01018d68  00000000          ori.b    #$0, d0
01018d6c  00000000          ori.b    #$0, d0
01018d70  00000000          ori.b    #$0, d0
01018d74  00000000          ori.b    #$0, d0
01018d78  00000000          ori.b    #$0, d0
01018d7c  00000000          ori.b    #$0, d0
01018d80  00000000          ori.b    #$0, d0
01018d84  00000000          ori.b    #$0, d0
01018d88  00000000          ori.b    #$0, d0
01018d8c  00000000          ori.b    #$0, d0
01018d90  00000000          ori.b    #$0, d0
01018d94  00000000          ori.b    #$0, d0
01018d98  00000000          ori.b    #$0, d0
01018d9c  00000000          ori.b    #$0, d0
01018da0  00000000          ori.b    #$0, d0
01018da4  00000000          ori.b    #$0, d0
01018da8  00000000          ori.b    #$0, d0
01018dac  00000000          ori.b    #$0, d0
01018db0  00000000          ori.b    #$0, d0
01018db4  00000000          ori.b    #$0, d0
01018db8  00000000          ori.b    #$0, d0
01018dbc  00000000          ori.b    #$0, d0
01018dc0  00000000          ori.b    #$0, d0
01018dc4  00000000          ori.b    #$0, d0
01018dc8  00000000          ori.b    #$0, d0
01018dcc  00000000          ori.b    #$0, d0
01018dd0  00000000          ori.b    #$0, d0
01018dd4  00000000          ori.b    #$0, d0
01018dd8  00000000          ori.b    #$0, d0
01018ddc  00000000          ori.b    #$0, d0
01018de0  00000000          ori.b    #$0, d0
01018de4  00000000          ori.b    #$0, d0
01018de8  00000000          ori.b    #$0, d0
01018dec  00000000          ori.b    #$0, d0
01018df0  00000000          ori.b    #$0, d0
01018df4  00000000          ori.b    #$0, d0
01018df8  00000000          ori.b    #$0, d0
01018dfc  00000000          ori.b    #$0, d0
01018e00  00000000          ori.b    #$0, d0
01018e04  00000000          ori.b    #$0, d0
01018e08  00000000          ori.b    #$0, d0
01018e0c  00000000          ori.b    #$0, d0
01018e10  00000000          ori.b    #$0, d0
01018e14  00000000          ori.b    #$0, d0
01018e18  00000000          ori.b    #$0, d0
01018e1c  00000000          ori.b    #$0, d0
01018e20  00000000          ori.b    #$0, d0
01018e24  00000000          ori.b    #$0, d0
01018e28  00000000          ori.b    #$0, d0
01018e2c  00000000          ori.b    #$0, d0
01018e30  00000000          ori.b    #$0, d0
01018e34  00000000          ori.b    #$0, d0
01018e38  00000000          ori.b    #$0, d0
01018e3c  00000000          ori.b    #$0, d0
01018e40  00000000          ori.b    #$0, d0
01018e44  00000000          ori.b    #$0, d0
01018e48  00000000          ori.b    #$0, d0
01018e4c  00000000          ori.b    #$0, d0
01018e50  00000000          ori.b    #$0, d0
01018e54  00000000          ori.b    #$0, d0
01018e58  00000000          ori.b    #$0, d0
01018e5c  00000000          ori.b    #$0, d0
01018e60  00000000          ori.b    #$0, d0
01018e64  00000000          ori.b    #$0, d0
01018e68  00000000          ori.b    #$0, d0
01018e6c  00000000          ori.b    #$0, d0
01018e70  00000000          ori.b    #$0, d0
01018e74  00000000          ori.b    #$0, d0
01018e78  00000000          ori.b    #$0, d0
01018e7c  00000000          ori.b    #$0, d0
01018e80  00000000          ori.b    #$0, d0
01018e84  00000000          ori.b    #$0, d0
01018e88  00000000          ori.b    #$0, d0
01018e8c  00000000          ori.b    #$0, d0
01018e90  00000000          ori.b    #$0, d0
01018e94  00000000          ori.b    #$0, d0
01018e98  00000000          ori.b    #$0, d0
01018e9c  00000000          ori.b    #$0, d0
01018ea0  00000000          ori.b    #$0, d0
01018ea4  00000000          ori.b    #$0, d0
01018ea8  00000000          ori.b    #$0, d0
01018eac  00000000          ori.b    #$0, d0
01018eb0  00000000          ori.b    #$0, d0
01018eb4  00000000          ori.b    #$0, d0
01018eb8  00000000          ori.b    #$0, d0
01018ebc  00000000          ori.b    #$0, d0
01018ec0  00000000          ori.b    #$0, d0
01018ec4  00000000          ori.b    #$0, d0
01018ec8  00000000          ori.b    #$0, d0
01018ecc  00000000          ori.b    #$0, d0
01018ed0  00000000          ori.b    #$0, d0
01018ed4  00000000          ori.b    #$0, d0
01018ed8  00000000          ori.b    #$0, d0
01018edc  00000000          ori.b    #$0, d0
01018ee0  00000000          ori.b    #$0, d0
01018ee4  00000000          ori.b    #$0, d0
01018ee8  00000000          ori.b    #$0, d0
01018eec  00000000          ori.b    #$0, d0
01018ef0  00000000          ori.b    #$0, d0
01018ef4  00000000          ori.b    #$0, d0
01018ef8  00000000          ori.b    #$0, d0
01018efc  00000000          ori.b    #$0, d0
01018f00  00000000          ori.b    #$0, d0
01018f04  00000000          ori.b    #$0, d0
01018f08  00000000          ori.b    #$0, d0
01018f0c  00000000          ori.b    #$0, d0
01018f10  00000000          ori.b    #$0, d0
01018f14  00000000          ori.b    #$0, d0
01018f18  00000000          ori.b    #$0, d0
01018f1c  00000000          ori.b    #$0, d0
01018f20  00000000          ori.b    #$0, d0
01018f24  00000000          ori.b    #$0, d0
01018f28  00000000          ori.b    #$0, d0
01018f2c  00000000          ori.b    #$0, d0
01018f30  00000000          ori.b    #$0, d0
01018f34  00000000          ori.b    #$0, d0
01018f38  00000000          ori.b    #$0, d0
01018f3c  00000000          ori.b    #$0, d0
01018f40  00000000          ori.b    #$0, d0
01018f44  00000000          ori.b    #$0, d0
01018f48  00000000          ori.b    #$0, d0
01018f4c  00000000          ori.b    #$0, d0
01018f50  00000000          ori.b    #$0, d0
01018f54  00000000          ori.b    #$0, d0
01018f58  00000000          ori.b    #$0, d0
01018f5c  00000000          ori.b    #$0, d0
01018f60  00000000          ori.b    #$0, d0
01018f64  00000000          ori.b    #$0, d0
01018f68  00000000          ori.b    #$0, d0
01018f6c  00000000          ori.b    #$0, d0
01018f70  00000000          ori.b    #$0, d0
01018f74  00000000          ori.b    #$0, d0
01018f78  00000000          ori.b    #$0, d0
01018f7c  00000000          ori.b    #$0, d0
01018f80  00000000          ori.b    #$0, d0
01018f84  00000000          ori.b    #$0, d0
01018f88  00000000          ori.b    #$0, d0
01018f8c  00000000          ori.b    #$0, d0
01018f90  00000000          ori.b    #$0, d0
01018f94  00000000          ori.b    #$0, d0
01018f98  00000000          ori.b    #$0, d0
01018f9c  00000000          ori.b    #$0, d0
01018fa0  00000000          ori.b    #$0, d0
01018fa4  00000000          ori.b    #$0, d0
01018fa8  00000000          ori.b    #$0, d0
01018fac  00000000          ori.b    #$0, d0
01018fb0  00000000          ori.b    #$0, d0
01018fb4  00000000          ori.b    #$0, d0
01018fb8  00000000          ori.b    #$0, d0
01018fbc  00000000          ori.b    #$0, d0
01018fc0  00000000          ori.b    #$0, d0
01018fc4  00000000          ori.b    #$0, d0
01018fc8  00000000          ori.b    #$0, d0
01018fcc  00000000          ori.b    #$0, d0
01018fd0  00000000          ori.b    #$0, d0
01018fd4  00000000          ori.b    #$0, d0
01018fd8  00000000          ori.b    #$0, d0
01018fdc  00000000          ori.b    #$0, d0
01018fe0  00000000          ori.b    #$0, d0
01018fe4  00000000          ori.b    #$0, d0
01018fe8  00000000          ori.b    #$0, d0
01018fec  00000000          ori.b    #$0, d0
01018ff0  00000000          ori.b    #$0, d0
01018ff4  00000000          ori.b    #$0, d0
01018ff8  00000000          ori.b    #$0, d0
01018ffc  00000000          ori.b    #$0, d0
01019000  00000000          ori.b    #$0, d0
01019004  00000000          ori.b    #$0, d0
01019008  00000000          ori.b    #$0, d0
0101900c  00000000          ori.b    #$0, d0
01019010  00000000          ori.b    #$0, d0
01019014  00000000          ori.b    #$0, d0
01019018  00000000          ori.b    #$0, d0
0101901c  00000000          ori.b    #$0, d0
01019020  00000000          ori.b    #$0, d0
01019024  00000000          ori.b    #$0, d0
01019028  00000000          ori.b    #$0, d0
0101902c  00000000          ori.b    #$0, d0
01019030  00000000          ori.b    #$0, d0
01019034  00000000          ori.b    #$0, d0
01019038  00000000          ori.b    #$0, d0
0101903c  00000000          ori.b    #$0, d0
01019040  00000000          ori.b    #$0, d0
01019044  00000000          ori.b    #$0, d0
01019048  00000000          ori.b    #$0, d0
0101904c  00000000          ori.b    #$0, d0
01019050  00000000          ori.b    #$0, d0
01019054  00000000          ori.b    #$0, d0
01019058  00000000          ori.b    #$0, d0
0101905c  00000000          ori.b    #$0, d0
01019060  00000000          ori.b    #$0, d0
01019064  00000000          ori.b    #$0, d0
01019068  00000000          ori.b    #$0, d0
0101906c  00000000          ori.b    #$0, d0
01019070  00000000          ori.b    #$0, d0
01019074  00000000          ori.b    #$0, d0
01019078  00000000          ori.b    #$0, d0
0101907c  00000000          ori.b    #$0, d0
01019080  00000000          ori.b    #$0, d0
01019084  00000000          ori.b    #$0, d0
01019088  00000000          ori.b    #$0, d0
0101908c  00000000          ori.b    #$0, d0
01019090  00000000          ori.b    #$0, d0
01019094  00000000          ori.b    #$0, d0
01019098  00000000          ori.b    #$0, d0
0101909c  00000000          ori.b    #$0, d0
010190a0  00000000          ori.b    #$0, d0
010190a4  00000000          ori.b    #$0, d0
010190a8  00000000          ori.b    #$0, d0
010190ac  00000000          ori.b    #$0, d0
010190b0  00000000          ori.b    #$0, d0
010190b4  00000000          ori.b    #$0, d0
010190b8  00000000          ori.b    #$0, d0
010190bc  00000000          ori.b    #$0, d0
010190c0  00000000          ori.b    #$0, d0
010190c4  00000000          ori.b    #$0, d0
010190c8  00000000          ori.b    #$0, d0
010190cc  00000000          ori.b    #$0, d0
010190d0  00000000          ori.b    #$0, d0
010190d4  00000000          ori.b    #$0, d0
010190d8  00000000          ori.b    #$0, d0
010190dc  00000000          ori.b    #$0, d0
010190e0  00000000          ori.b    #$0, d0
010190e4  00000000          ori.b    #$0, d0
010190e8  00000000          ori.b    #$0, d0
010190ec  00000000          ori.b    #$0, d0
010190f0  00000000          ori.b    #$0, d0
010190f4  00000000          ori.b    #$0, d0
010190f8  00000000          ori.b    #$0, d0
010190fc  00000000          ori.b    #$0, d0
01019100  00000000          ori.b    #$0, d0
01019104  00000000          ori.b    #$0, d0
01019108  00000000          ori.b    #$0, d0
0101910c  00000000          ori.b    #$0, d0
01019110  00000000          ori.b    #$0, d0
01019114  00000000          ori.b    #$0, d0
01019118  00000000          ori.b    #$0, d0
0101911c  00000000          ori.b    #$0, d0
01019120  00000000          ori.b    #$0, d0
01019124  00000000          ori.b    #$0, d0
01019128  00000000          ori.b    #$0, d0
0101912c  00000000          ori.b    #$0, d0
01019130  00000000          ori.b    #$0, d0
01019134  00000000          ori.b    #$0, d0
01019138  00000000          ori.b    #$0, d0
0101913c  00000000          ori.b    #$0, d0
01019140  00000000          ori.b    #$0, d0
01019144  00000000          ori.b    #$0, d0
01019148  00000000          ori.b    #$0, d0
0101914c  00000000          ori.b    #$0, d0
01019150  00000000          ori.b    #$0, d0
01019154  00000000          ori.b    #$0, d0
01019158  00000000          ori.b    #$0, d0
0101915c  00000000          ori.b    #$0, d0
01019160  00000000          ori.b    #$0, d0
01019164  00000000          ori.b    #$0, d0
01019168  00000000          ori.b    #$0, d0
0101916c  00000000          ori.b    #$0, d0
01019170  00000000          ori.b    #$0, d0
01019174  00000000          ori.b    #$0, d0
01019178  00000000          ori.b    #$0, d0
0101917c  00000000          ori.b    #$0, d0
01019180  00000000          ori.b    #$0, d0
01019184  00000000          ori.b    #$0, d0
01019188  00000000          ori.b    #$0, d0
0101918c  00000000          ori.b    #$0, d0
01019190  00000000          ori.b    #$0, d0
01019194  00000000          ori.b    #$0, d0
01019198  00000000          ori.b    #$0, d0
0101919c  00000000          ori.b    #$0, d0
010191a0  00000000          ori.b    #$0, d0
010191a4  00000000          ori.b    #$0, d0
010191a8  00000000          ori.b    #$0, d0
010191ac  00000000          ori.b    #$0, d0
010191b0  00000000          ori.b    #$0, d0
010191b4  00000000          ori.b    #$0, d0
010191b8  00000000          ori.b    #$0, d0
010191bc  00000000          ori.b    #$0, d0
010191c0  00000000          ori.b    #$0, d0
010191c4  00000000          ori.b    #$0, d0
010191c8  00000000          ori.b    #$0, d0
010191cc  00000000          ori.b    #$0, d0
010191d0  00000000          ori.b    #$0, d0
010191d4  00000000          ori.b    #$0, d0
010191d8  00000000          ori.b    #$0, d0
010191dc  00000000          ori.b    #$0, d0
010191e0  00000000          ori.b    #$0, d0
010191e4  00000000          ori.b    #$0, d0
010191e8  00000000          ori.b    #$0, d0
010191ec  00000000          ori.b    #$0, d0
010191f0  00000000          ori.b    #$0, d0
010191f4  00000000          ori.b    #$0, d0
010191f8  00000000          ori.b    #$0, d0
010191fc  00000000          ori.b    #$0, d0
01019200  00000000          ori.b    #$0, d0
01019204  00000000          ori.b    #$0, d0
01019208  00000000          ori.b    #$0, d0
0101920c  00000000          ori.b    #$0, d0
01019210  00000000          ori.b    #$0, d0
01019214  00000000          ori.b    #$0, d0
01019218  00000000          ori.b    #$0, d0
0101921c  00000000          ori.b    #$0, d0
01019220  00000000          ori.b    #$0, d0
01019224  00000000          ori.b    #$0, d0
01019228  00000000          ori.b    #$0, d0
0101922c  00000000          ori.b    #$0, d0
01019230  00000000          ori.b    #$0, d0
01019234  00000000          ori.b    #$0, d0
01019238  00000000          ori.b    #$0, d0
0101923c  00000000          ori.b    #$0, d0
01019240  00000000          ori.b    #$0, d0
01019244  00000000          ori.b    #$0, d0
01019248  00000000          ori.b    #$0, d0
0101924c  00000000          ori.b    #$0, d0
01019250  00000000          ori.b    #$0, d0
01019254  00000000          ori.b    #$0, d0
01019258  00000000          ori.b    #$0, d0
0101925c  00000000          ori.b    #$0, d0
01019260  00000000          ori.b    #$0, d0
01019264  00000000          ori.b    #$0, d0
01019268  00000000          ori.b    #$0, d0
0101926c  00000000          ori.b    #$0, d0
01019270  00000000          ori.b    #$0, d0
01019274  00000000          ori.b    #$0, d0
01019278  00000000          ori.b    #$0, d0
0101927c  00000000          ori.b    #$0, d0
01019280  00000000          ori.b    #$0, d0
01019284  00000000          ori.b    #$0, d0
01019288  00000000          ori.b    #$0, d0
0101928c  00000000          ori.b    #$0, d0
01019290  00000000          ori.b    #$0, d0
01019294  00000000          ori.b    #$0, d0
01019298  00000000          ori.b    #$0, d0
0101929c  00000000          ori.b    #$0, d0
010192a0  00000000          ori.b    #$0, d0
010192a4  00000000          ori.b    #$0, d0
010192a8  00000000          ori.b    #$0, d0
010192ac  00000000          ori.b    #$0, d0
010192b0  00000000          ori.b    #$0, d0
010192b4  00000000          ori.b    #$0, d0
010192b8  00000000          ori.b    #$0, d0
010192bc  00000000          ori.b    #$0, d0
010192c0  00000000          ori.b    #$0, d0
010192c4  00000000          ori.b    #$0, d0
010192c8  00000000          ori.b    #$0, d0
010192cc  00000000          ori.b    #$0, d0
010192d0  00000000          ori.b    #$0, d0
010192d4  00000000          ori.b    #$0, d0
010192d8  00000000          ori.b    #$0, d0
010192dc  00000000          ori.b    #$0, d0
010192e0  00000000          ori.b    #$0, d0
010192e4  00000000          ori.b    #$0, d0
010192e8  00000000          ori.b    #$0, d0
010192ec  00000000          ori.b    #$0, d0
010192f0  00000000          ori.b    #$0, d0
010192f4  00000000          ori.b    #$0, d0
010192f8  00000000          ori.b    #$0, d0
010192fc  00000000          ori.b    #$0, d0
01019300  00000000          ori.b    #$0, d0
01019304  00000000          ori.b    #$0, d0
01019308  00000000          ori.b    #$0, d0
0101930c  00000000          ori.b    #$0, d0
01019310  00000000          ori.b    #$0, d0
01019314  00000000          ori.b    #$0, d0
01019318  00000000          ori.b    #$0, d0
0101931c  00000000          ori.b    #$0, d0
01019320  00000000          ori.b    #$0, d0
01019324  00000000          ori.b    #$0, d0
01019328  00000000          ori.b    #$0, d0
0101932c  00000000          ori.b    #$0, d0
01019330  00000000          ori.b    #$0, d0
01019334  00000000          ori.b    #$0, d0
01019338  00000000          ori.b    #$0, d0
0101933c  00000000          ori.b    #$0, d0
01019340  00000000          ori.b    #$0, d0
01019344  00000000          ori.b    #$0, d0
01019348  00000000          ori.b    #$0, d0
0101934c  00000000          ori.b    #$0, d0
01019350  00000000          ori.b    #$0, d0
01019354  00000000          ori.b    #$0, d0
01019358  00000000          ori.b    #$0, d0
0101935c  00000000          ori.b    #$0, d0
01019360  00000000          ori.b    #$0, d0
01019364  00000000          ori.b    #$0, d0
01019368  00000000          ori.b    #$0, d0
0101936c  00000000          ori.b    #$0, d0
01019370  00000000          ori.b    #$0, d0
01019374  00000000          ori.b    #$0, d0
01019378  00000000          ori.b    #$0, d0
0101937c  00000000          ori.b    #$0, d0
01019380  00000000          ori.b    #$0, d0
01019384  00000000          ori.b    #$0, d0
01019388  00000000          ori.b    #$0, d0
0101938c  00000000          ori.b    #$0, d0
01019390  00000000          ori.b    #$0, d0
01019394  00000000          ori.b    #$0, d0
01019398  00000000          ori.b    #$0, d0
0101939c  00000000          ori.b    #$0, d0
010193a0  00000000          ori.b    #$0, d0
010193a4  00000000          ori.b    #$0, d0
010193a8  00000000          ori.b    #$0, d0
010193ac  00000000          ori.b    #$0, d0
010193b0  00000000          ori.b    #$0, d0
010193b4  00000000          ori.b    #$0, d0
010193b8  00000000          ori.b    #$0, d0
010193bc  00000000          ori.b    #$0, d0
010193c0  00000000          ori.b    #$0, d0
010193c4  00000000          ori.b    #$0, d0
010193c8  00000000          ori.b    #$0, d0
010193cc  00000000          ori.b    #$0, d0
010193d0  00000000          ori.b    #$0, d0
010193d4  00000000          ori.b    #$0, d0
010193d8  00000000          ori.b    #$0, d0
010193dc  00000000          ori.b    #$0, d0
010193e0  00000000          ori.b    #$0, d0
010193e4  00000000          ori.b    #$0, d0
010193e8  00000000          ori.b    #$0, d0
010193ec  00000000          ori.b    #$0, d0
010193f0  00000000          ori.b    #$0, d0
010193f4  00000000          ori.b    #$0, d0
010193f8  00000000          ori.b    #$0, d0
010193fc  00000000          ori.b    #$0, d0
01019400  00000000          ori.b    #$0, d0
01019404  00000000          ori.b    #$0, d0
01019408  00000000          ori.b    #$0, d0
0101940c  00000000          ori.b    #$0, d0
01019410  00000000          ori.b    #$0, d0
01019414  00000000          ori.b    #$0, d0
01019418  00000000          ori.b    #$0, d0
0101941c  00000000          ori.b    #$0, d0
01019420  00000000          ori.b    #$0, d0
01019424  00000000          ori.b    #$0, d0
01019428  00000000          ori.b    #$0, d0
0101942c  00000000          ori.b    #$0, d0
01019430  00000000          ori.b    #$0, d0
01019434  00000000          ori.b    #$0, d0
01019438  00000000          ori.b    #$0, d0
0101943c  00000000          ori.b    #$0, d0
01019440  00000000          ori.b    #$0, d0
01019444  00000000          ori.b    #$0, d0
01019448  00000000          ori.b    #$0, d0
0101944c  00000000          ori.b    #$0, d0
01019450  00000000          ori.b    #$0, d0
01019454  00000000          ori.b    #$0, d0
01019458  00000000          ori.b    #$0, d0
0101945c  00000000          ori.b    #$0, d0
01019460  00000000          ori.b    #$0, d0
01019464  00000000          ori.b    #$0, d0
01019468  00000000          ori.b    #$0, d0
0101946c  00000000          ori.b    #$0, d0
01019470  00000000          ori.b    #$0, d0
01019474  00000000          ori.b    #$0, d0
01019478  00000000          ori.b    #$0, d0
0101947c  00000000          ori.b    #$0, d0
01019480  00000000          ori.b    #$0, d0
01019484  00000000          ori.b    #$0, d0
01019488  00000000          ori.b    #$0, d0
0101948c  00000000          ori.b    #$0, d0
01019490  00000000          ori.b    #$0, d0
01019494  00000000          ori.b    #$0, d0
01019498  00000000          ori.b    #$0, d0
0101949c  00000000          ori.b    #$0, d0
010194a0  00000000          ori.b    #$0, d0
010194a4  00000000          ori.b    #$0, d0
010194a8  00000000          ori.b    #$0, d0
010194ac  00000000          ori.b    #$0, d0
010194b0  00000000          ori.b    #$0, d0
010194b4  00000000          ori.b    #$0, d0
010194b8  00000000          ori.b    #$0, d0
010194bc  00000000          ori.b    #$0, d0
010194c0  00000000          ori.b    #$0, d0
010194c4  00000000          ori.b    #$0, d0
010194c8  00000000          ori.b    #$0, d0
010194cc  00000000          ori.b    #$0, d0
010194d0  00000000          ori.b    #$0, d0
010194d4  00000000          ori.b    #$0, d0
010194d8  00000000          ori.b    #$0, d0
010194dc  00000000          ori.b    #$0, d0
010194e0  00000000          ori.b    #$0, d0
010194e4  00000000          ori.b    #$0, d0
010194e8  00000000          ori.b    #$0, d0
010194ec  00000000          ori.b    #$0, d0
010194f0  00000000          ori.b    #$0, d0
010194f4  00000000          ori.b    #$0, d0
010194f8  00000000          ori.b    #$0, d0
010194fc  00000000          ori.b    #$0, d0
01019500  00000000          ori.b    #$0, d0
01019504  00000000          ori.b    #$0, d0
01019508  00000000          ori.b    #$0, d0
0101950c  00000000          ori.b    #$0, d0
01019510  00000000          ori.b    #$0, d0
01019514  00000000          ori.b    #$0, d0
01019518  00000000          ori.b    #$0, d0
0101951c  00000000          ori.b    #$0, d0
01019520  00000000          ori.b    #$0, d0
01019524  00000000          ori.b    #$0, d0
01019528  00000000          ori.b    #$0, d0
0101952c  00000000          ori.b    #$0, d0
01019530  00000000          ori.b    #$0, d0
01019534  00000000          ori.b    #$0, d0
01019538  00000000          ori.b    #$0, d0
0101953c  00000000          ori.b    #$0, d0
01019540  00000000          ori.b    #$0, d0
01019544  00000000          ori.b    #$0, d0
01019548  00000000          ori.b    #$0, d0
0101954c  00000000          ori.b    #$0, d0
01019550  00000000          ori.b    #$0, d0
01019554  00000000          ori.b    #$0, d0
01019558  00000000          ori.b    #$0, d0
0101955c  00000000          ori.b    #$0, d0
01019560  00000000          ori.b    #$0, d0
01019564  00000000          ori.b    #$0, d0
01019568  00000000          ori.b    #$0, d0
0101956c  00000000          ori.b    #$0, d0
01019570  00000000          ori.b    #$0, d0
01019574  00000000          ori.b    #$0, d0
01019578  00000000          ori.b    #$0, d0
0101957c  00000000          ori.b    #$0, d0
01019580  00000000          ori.b    #$0, d0
01019584  00000000          ori.b    #$0, d0
01019588  00000000          ori.b    #$0, d0
0101958c  00000000          ori.b    #$0, d0
01019590  00000000          ori.b    #$0, d0
01019594  00000000          ori.b    #$0, d0
01019598  00000000          ori.b    #$0, d0
0101959c  00000000          ori.b    #$0, d0
010195a0  00000000          ori.b    #$0, d0
010195a4  00000000          ori.b    #$0, d0
010195a8  00000000          ori.b    #$0, d0
010195ac  00000000          ori.b    #$0, d0
010195b0  00000000          ori.b    #$0, d0
010195b4  00000000          ori.b    #$0, d0
010195b8  00000000          ori.b    #$0, d0
010195bc  00000000          ori.b    #$0, d0
010195c0  00000000          ori.b    #$0, d0
010195c4  00000000          ori.b    #$0, d0
010195c8  00000000          ori.b    #$0, d0
010195cc  00000000          ori.b    #$0, d0
010195d0  00000000          ori.b    #$0, d0
010195d4  00000000          ori.b    #$0, d0
010195d8  00000000          ori.b    #$0, d0
010195dc  00000000          ori.b    #$0, d0
010195e0  00000000          ori.b    #$0, d0
010195e4  00000000          ori.b    #$0, d0
010195e8  00000000          ori.b    #$0, d0
010195ec  00000000          ori.b    #$0, d0
010195f0  00000000          ori.b    #$0, d0
010195f4  00000000          ori.b    #$0, d0
010195f8  00000000          ori.b    #$0, d0
010195fc  00000000          ori.b    #$0, d0
01019600  00000000          ori.b    #$0, d0
01019604  00000000          ori.b    #$0, d0
01019608  00000000          ori.b    #$0, d0
0101960c  00000000          ori.b    #$0, d0
01019610  00000000          ori.b    #$0, d0
01019614  00000000          ori.b    #$0, d0
01019618  00000000          ori.b    #$0, d0
0101961c  00000000          ori.b    #$0, d0
01019620  00000000          ori.b    #$0, d0
01019624  00000000          ori.b    #$0, d0
01019628  00000000          ori.b    #$0, d0
0101962c  00000000          ori.b    #$0, d0
01019630  00000000          ori.b    #$0, d0
01019634  00000000          ori.b    #$0, d0
01019638  00000000          ori.b    #$0, d0
0101963c  00000000          ori.b    #$0, d0
01019640  00000000          ori.b    #$0, d0
01019644  00000000          ori.b    #$0, d0
01019648  00000000          ori.b    #$0, d0
0101964c  00000000          ori.b    #$0, d0
01019650  00000000          ori.b    #$0, d0
01019654  00000000          ori.b    #$0, d0
01019658  00000000          ori.b    #$0, d0
0101965c  00000000          ori.b    #$0, d0
01019660  00000000          ori.b    #$0, d0
01019664  00000000          ori.b    #$0, d0
01019668  00000000          ori.b    #$0, d0
0101966c  00000000          ori.b    #$0, d0
01019670  00000000          ori.b    #$0, d0
01019674  00000000          ori.b    #$0, d0
01019678  00000000          ori.b    #$0, d0
0101967c  00000000          ori.b    #$0, d0
01019680  00000000          ori.b    #$0, d0
01019684  00000000          ori.b    #$0, d0
01019688  00000000          ori.b    #$0, d0
0101968c  00000000          ori.b    #$0, d0
01019690  00000000          ori.b    #$0, d0
01019694  00000000          ori.b    #$0, d0
01019698  00000000          ori.b    #$0, d0
0101969c  00000000          ori.b    #$0, d0
010196a0  00000000          ori.b    #$0, d0
010196a4  00000000          ori.b    #$0, d0
010196a8  00000000          ori.b    #$0, d0
010196ac  00000000          ori.b    #$0, d0
010196b0  00000000          ori.b    #$0, d0
010196b4  00000000          ori.b    #$0, d0
010196b8  00000000          ori.b    #$0, d0
010196bc  00000000          ori.b    #$0, d0
010196c0  00000000          ori.b    #$0, d0
010196c4  00000000          ori.b    #$0, d0
010196c8  00000000          ori.b    #$0, d0
010196cc  00000000          ori.b    #$0, d0
010196d0  00000000          ori.b    #$0, d0
010196d4  00000000          ori.b    #$0, d0
010196d8  00000000          ori.b    #$0, d0
010196dc  00000000          ori.b    #$0, d0
010196e0  00000000          ori.b    #$0, d0
010196e4  00000000          ori.b    #$0, d0
010196e8  00000000          ori.b    #$0, d0
010196ec  00000000          ori.b    #$0, d0
010196f0  00000000          ori.b    #$0, d0
010196f4  00000000          ori.b    #$0, d0
010196f8  00000000          ori.b    #$0, d0
010196fc  00000000          ori.b    #$0, d0
01019700  00000000          ori.b    #$0, d0
01019704  00000000          ori.b    #$0, d0
01019708  00000000          ori.b    #$0, d0
0101970c  00000000          ori.b    #$0, d0
01019710  00000000          ori.b    #$0, d0
01019714  00000000          ori.b    #$0, d0
01019718  00000000          ori.b    #$0, d0
0101971c  00000000          ori.b    #$0, d0
01019720  00000000          ori.b    #$0, d0
01019724  00000000          ori.b    #$0, d0
01019728  00000000          ori.b    #$0, d0
0101972c  00000000          ori.b    #$0, d0
01019730  00000000          ori.b    #$0, d0
01019734  00000000          ori.b    #$0, d0
01019738  00000000          ori.b    #$0, d0
0101973c  00000000          ori.b    #$0, d0
01019740  00000000          ori.b    #$0, d0
01019744  00000000          ori.b    #$0, d0
01019748  00000000          ori.b    #$0, d0
0101974c  00000000          ori.b    #$0, d0
01019750  00000000          ori.b    #$0, d0
01019754  00000000          ori.b    #$0, d0
01019758  00000000          ori.b    #$0, d0
0101975c  00000000          ori.b    #$0, d0
01019760  00000000          ori.b    #$0, d0
01019764  00000000          ori.b    #$0, d0
01019768  00000000          ori.b    #$0, d0
0101976c  00000000          ori.b    #$0, d0
01019770  00000000          ori.b    #$0, d0
01019774  00000000          ori.b    #$0, d0
01019778  00000000          ori.b    #$0, d0
0101977c  00000000          ori.b    #$0, d0
01019780  00000000          ori.b    #$0, d0
01019784  00000000          ori.b    #$0, d0
01019788  00000000          ori.b    #$0, d0
0101978c  00000000          ori.b    #$0, d0
01019790  00000000          ori.b    #$0, d0
01019794  00000000          ori.b    #$0, d0
01019798  00000000          ori.b    #$0, d0
0101979c  00000000          ori.b    #$0, d0
010197a0  00000000          ori.b    #$0, d0
010197a4  00000000          ori.b    #$0, d0
010197a8  00000000          ori.b    #$0, d0
010197ac  00000000          ori.b    #$0, d0
010197b0  00000000          ori.b    #$0, d0
010197b4  00000000          ori.b    #$0, d0
010197b8  00000000          ori.b    #$0, d0
010197bc  00000000          ori.b    #$0, d0
010197c0  00000000          ori.b    #$0, d0
010197c4  00000000          ori.b    #$0, d0
010197c8  00000000          ori.b    #$0, d0
010197cc  00000000          ori.b    #$0, d0
010197d0  00000000          ori.b    #$0, d0
010197d4  00000000          ori.b    #$0, d0
010197d8  00000000          ori.b    #$0, d0
010197dc  00000000          ori.b    #$0, d0
010197e0  00000000          ori.b    #$0, d0
010197e4  00000000          ori.b    #$0, d0
010197e8  00000000          ori.b    #$0, d0
010197ec  00000000          ori.b    #$0, d0
010197f0  00000000          ori.b    #$0, d0
010197f4  00000000          ori.b    #$0, d0
010197f8  00000000          ori.b    #$0, d0
010197fc  00000000          ori.b    #$0, d0
01019800  00000000          ori.b    #$0, d0
01019804  00000000          ori.b    #$0, d0
01019808  00000000          ori.b    #$0, d0
0101980c  00000000          ori.b    #$0, d0
01019810  00000000          ori.b    #$0, d0
01019814  00000000          ori.b    #$0, d0
01019818  00000000          ori.b    #$0, d0
0101981c  00000000          ori.b    #$0, d0
01019820  00000000          ori.b    #$0, d0
01019824  00000000          ori.b    #$0, d0
01019828  00000000          ori.b    #$0, d0
0101982c  00000000          ori.b    #$0, d0
01019830  00000000          ori.b    #$0, d0
01019834  00000000          ori.b    #$0, d0
01019838  00000000          ori.b    #$0, d0
0101983c  00000000          ori.b    #$0, d0
01019840  00000000          ori.b    #$0, d0
01019844  00000000          ori.b    #$0, d0
01019848  00000000          ori.b    #$0, d0
0101984c  00000000          ori.b    #$0, d0
01019850  00000000          ori.b    #$0, d0
01019854  00000000          ori.b    #$0, d0
01019858  00000000          ori.b    #$0, d0
0101985c  00000000          ori.b    #$0, d0
01019860  00000000          ori.b    #$0, d0
01019864  00000000          ori.b    #$0, d0
01019868  00000000          ori.b    #$0, d0
0101986c  00000000          ori.b    #$0, d0
01019870  00000000          ori.b    #$0, d0
01019874  00000000          ori.b    #$0, d0
01019878  00000000          ori.b    #$0, d0
0101987c  00000000          ori.b    #$0, d0
01019880  00000000          ori.b    #$0, d0
01019884  00000000          ori.b    #$0, d0
01019888  00000000          ori.b    #$0, d0
0101988c  00000000          ori.b    #$0, d0
01019890  00000000          ori.b    #$0, d0
01019894  00000000          ori.b    #$0, d0
01019898  00000000          ori.b    #$0, d0
0101989c  00000000          ori.b    #$0, d0
010198a0  00000000          ori.b    #$0, d0
010198a4  00000000          ori.b    #$0, d0
010198a8  00000000          ori.b    #$0, d0
010198ac  00000000          ori.b    #$0, d0
010198b0  00000000          ori.b    #$0, d0
010198b4  00000000          ori.b    #$0, d0
010198b8  00000000          ori.b    #$0, d0
010198bc  00000000          ori.b    #$0, d0
010198c0  00000000          ori.b    #$0, d0
010198c4  00000000          ori.b    #$0, d0
010198c8  00000000          ori.b    #$0, d0
010198cc  00000000          ori.b    #$0, d0
010198d0  00000000          ori.b    #$0, d0
010198d4  00000000          ori.b    #$0, d0
010198d8  00000000          ori.b    #$0, d0
010198dc  00000000          ori.b    #$0, d0
010198e0  00000000          ori.b    #$0, d0
010198e4  00000000          ori.b    #$0, d0
010198e8  00000000          ori.b    #$0, d0
010198ec  00000000          ori.b    #$0, d0
010198f0  00000000          ori.b    #$0, d0
010198f4  00000000          ori.b    #$0, d0
010198f8  00000000          ori.b    #$0, d0
010198fc  00000000          ori.b    #$0, d0
01019900  00000000          ori.b    #$0, d0
01019904  00000000          ori.b    #$0, d0
01019908  00000000          ori.b    #$0, d0
0101990c  00000000          ori.b    #$0, d0
01019910  00000000          ori.b    #$0, d0
01019914  00000000          ori.b    #$0, d0
01019918  00000000          ori.b    #$0, d0
0101991c  00000000          ori.b    #$0, d0
01019920  00000000          ori.b    #$0, d0
01019924  00000000          ori.b    #$0, d0
01019928  00000000          ori.b    #$0, d0
0101992c  00000000          ori.b    #$0, d0
01019930  00000000          ori.b    #$0, d0
01019934  00000000          ori.b    #$0, d0
01019938  00000000          ori.b    #$0, d0
0101993c  00000000          ori.b    #$0, d0
01019940  00000000          ori.b    #$0, d0
01019944  00000000          ori.b    #$0, d0
01019948  00000000          ori.b    #$0, d0
0101994c  00000000          ori.b    #$0, d0
01019950  00000000          ori.b    #$0, d0
01019954  00000000          ori.b    #$0, d0
01019958  00000000          ori.b    #$0, d0
0101995c  00000000          ori.b    #$0, d0
01019960  00000000          ori.b    #$0, d0
01019964  00000000          ori.b    #$0, d0
01019968  00000000          ori.b    #$0, d0
0101996c  00000000          ori.b    #$0, d0
01019970  00000000          ori.b    #$0, d0
01019974  00000000          ori.b    #$0, d0
01019978  00000000          ori.b    #$0, d0
0101997c  00000000          ori.b    #$0, d0
01019980  00000000          ori.b    #$0, d0
01019984  00000000          ori.b    #$0, d0
01019988  00000000          ori.b    #$0, d0
0101998c  00000000          ori.b    #$0, d0
01019990  00000000          ori.b    #$0, d0
01019994  00000000          ori.b    #$0, d0
01019998  00000000          ori.b    #$0, d0
0101999c  00000000          ori.b    #$0, d0
010199a0  00000000          ori.b    #$0, d0
010199a4  00000000          ori.b    #$0, d0
010199a8  00000000          ori.b    #$0, d0
010199ac  00000000          ori.b    #$0, d0
010199b0  00000000          ori.b    #$0, d0
010199b4  00000000          ori.b    #$0, d0
010199b8  00000000          ori.b    #$0, d0
010199bc  00000000          ori.b    #$0, d0
010199c0  00000000          ori.b    #$0, d0
010199c4  00000000          ori.b    #$0, d0
010199c8  00000000          ori.b    #$0, d0
010199cc  00000000          ori.b    #$0, d0
010199d0  00000000          ori.b    #$0, d0
010199d4  00000000          ori.b    #$0, d0
010199d8  00000000          ori.b    #$0, d0
010199dc  00000000          ori.b    #$0, d0
010199e0  00000000          ori.b    #$0, d0
010199e4  00000000          ori.b    #$0, d0
010199e8  00000000          ori.b    #$0, d0
010199ec  00000000          ori.b    #$0, d0
010199f0  00000000          ori.b    #$0, d0
010199f4  00000000          ori.b    #$0, d0
010199f8  00000000          ori.b    #$0, d0
010199fc  00000000          ori.b    #$0, d0
01019a00  00000000          ori.b    #$0, d0
01019a04  00000000          ori.b    #$0, d0
01019a08  00000000          ori.b    #$0, d0
01019a0c  00000000          ori.b    #$0, d0
01019a10  00000000          ori.b    #$0, d0
01019a14  00000000          ori.b    #$0, d0
01019a18  00000000          ori.b    #$0, d0
01019a1c  00000000          ori.b    #$0, d0
01019a20  00000000          ori.b    #$0, d0
01019a24  00000000          ori.b    #$0, d0
01019a28  00000000          ori.b    #$0, d0
01019a2c  00000000          ori.b    #$0, d0
01019a30  00000000          ori.b    #$0, d0
01019a34  00000000          ori.b    #$0, d0
01019a38  00000000          ori.b    #$0, d0
01019a3c  00000000          ori.b    #$0, d0
01019a40  00000000          ori.b    #$0, d0
01019a44  00000000          ori.b    #$0, d0
01019a48  00000000          ori.b    #$0, d0
01019a4c  00000000          ori.b    #$0, d0
01019a50  00000000          ori.b    #$0, d0
01019a54  00000000          ori.b    #$0, d0
01019a58  00000000          ori.b    #$0, d0
01019a5c  00000000          ori.b    #$0, d0
01019a60  00000000          ori.b    #$0, d0
01019a64  00000000          ori.b    #$0, d0
01019a68  00000000          ori.b    #$0, d0
01019a6c  00000000          ori.b    #$0, d0
01019a70  00000000          ori.b    #$0, d0
01019a74  00000000          ori.b    #$0, d0
01019a78  00000000          ori.b    #$0, d0
01019a7c  00000000          ori.b    #$0, d0
01019a80  00000000          ori.b    #$0, d0
01019a84  00000000          ori.b    #$0, d0
01019a88  00000000          ori.b    #$0, d0
01019a8c  00000000          ori.b    #$0, d0
01019a90  00000000          ori.b    #$0, d0
01019a94  00000000          ori.b    #$0, d0
01019a98  00000000          ori.b    #$0, d0
01019a9c  00000000          ori.b    #$0, d0
01019aa0  00000000          ori.b    #$0, d0
01019aa4  00000000          ori.b    #$0, d0
01019aa8  00000000          ori.b    #$0, d0
01019aac  00000000          ori.b    #$0, d0
01019ab0  00000000          ori.b    #$0, d0
01019ab4  00000000          ori.b    #$0, d0
01019ab8  00000000          ori.b    #$0, d0
01019abc  00000000          ori.b    #$0, d0
01019ac0  00000000          ori.b    #$0, d0
01019ac4  00000000          ori.b    #$0, d0
01019ac8  00000000          ori.b    #$0, d0
01019acc  00000000          ori.b    #$0, d0
01019ad0  00000000          ori.b    #$0, d0
01019ad4  00000000          ori.b    #$0, d0
01019ad8  00000000          ori.b    #$0, d0
01019adc  00000000          ori.b    #$0, d0
01019ae0  00000000          ori.b    #$0, d0
01019ae4  00000000          ori.b    #$0, d0
01019ae8  00000000          ori.b    #$0, d0
01019aec  00000000          ori.b    #$0, d0
01019af0  00000000          ori.b    #$0, d0
01019af4  00000000          ori.b    #$0, d0
01019af8  00000000          ori.b    #$0, d0
01019afc  00000000          ori.b    #$0, d0
01019b00  00000000          ori.b    #$0, d0
01019b04  00000000          ori.b    #$0, d0
01019b08  00000000          ori.b    #$0, d0
01019b0c  00000000          ori.b    #$0, d0
01019b10  00000000          ori.b    #$0, d0
01019b14  00000000          ori.b    #$0, d0
01019b18  00000000          ori.b    #$0, d0
01019b1c  00000000          ori.b    #$0, d0
01019b20  00000000          ori.b    #$0, d0
01019b24  00000000          ori.b    #$0, d0
01019b28  00000000          ori.b    #$0, d0
01019b2c  00000000          ori.b    #$0, d0
01019b30  00000000          ori.b    #$0, d0
01019b34  00000000          ori.b    #$0, d0
01019b38  00000000          ori.b    #$0, d0
01019b3c  00000000          ori.b    #$0, d0
01019b40  00000000          ori.b    #$0, d0
01019b44  00000000          ori.b    #$0, d0
01019b48  00000000          ori.b    #$0, d0
01019b4c  00000000          ori.b    #$0, d0
01019b50  00000000          ori.b    #$0, d0
01019b54  00000000          ori.b    #$0, d0
01019b58  00000000          ori.b    #$0, d0
01019b5c  00000000          ori.b    #$0, d0
01019b60  00000000          ori.b    #$0, d0
01019b64  00000000          ori.b    #$0, d0
01019b68  00000000          ori.b    #$0, d0
01019b6c  00000000          ori.b    #$0, d0
01019b70  00000000          ori.b    #$0, d0
01019b74  00000000          ori.b    #$0, d0
01019b78  00000000          ori.b    #$0, d0
01019b7c  00000000          ori.b    #$0, d0
01019b80  00000000          ori.b    #$0, d0
01019b84  00000000          ori.b    #$0, d0
01019b88  00000000          ori.b    #$0, d0
01019b8c  00000000          ori.b    #$0, d0
01019b90  00000000          ori.b    #$0, d0
01019b94  00000000          ori.b    #$0, d0
01019b98  00000000          ori.b    #$0, d0
01019b9c  00000000          ori.b    #$0, d0
01019ba0  00000000          ori.b    #$0, d0
01019ba4  00000000          ori.b    #$0, d0
01019ba8  00000000          ori.b    #$0, d0
01019bac  00000000          ori.b    #$0, d0
01019bb0  00000000          ori.b    #$0, d0
01019bb4  00000000          ori.b    #$0, d0
01019bb8  00000000          ori.b    #$0, d0
01019bbc  00000000          ori.b    #$0, d0
01019bc0  00000000          ori.b    #$0, d0
01019bc4  00000000          ori.b    #$0, d0
01019bc8  00000000          ori.b    #$0, d0
01019bcc  00000000          ori.b    #$0, d0
01019bd0  00000000          ori.b    #$0, d0
01019bd4  00000000          ori.b    #$0, d0
01019bd8  00000000          ori.b    #$0, d0
01019bdc  00000000          ori.b    #$0, d0
01019be0  00000000          ori.b    #$0, d0
01019be4  00000000          ori.b    #$0, d0
01019be8  00000000          ori.b    #$0, d0
01019bec  00000000          ori.b    #$0, d0
01019bf0  00000000          ori.b    #$0, d0
01019bf4  00000000          ori.b    #$0, d0
01019bf8  00000000          ori.b    #$0, d0
01019bfc  00000000          ori.b    #$0, d0
01019c00  00000000          ori.b    #$0, d0
01019c04  00000000          ori.b    #$0, d0
01019c08  00000000          ori.b    #$0, d0
01019c0c  00000000          ori.b    #$0, d0
01019c10  00000000          ori.b    #$0, d0
01019c14  00000000          ori.b    #$0, d0
01019c18  00000000          ori.b    #$0, d0
01019c1c  00000000          ori.b    #$0, d0
01019c20  00000000          ori.b    #$0, d0
01019c24  00000000          ori.b    #$0, d0
01019c28  00000000          ori.b    #$0, d0
01019c2c  00000000          ori.b    #$0, d0
01019c30  00000000          ori.b    #$0, d0
01019c34  00000000          ori.b    #$0, d0
01019c38  00000000          ori.b    #$0, d0
01019c3c  00000000          ori.b    #$0, d0
01019c40  00000000          ori.b    #$0, d0
01019c44  00000000          ori.b    #$0, d0
01019c48  00000000          ori.b    #$0, d0
01019c4c  00000000          ori.b    #$0, d0
01019c50  00000000          ori.b    #$0, d0
01019c54  00000000          ori.b    #$0, d0
01019c58  00000000          ori.b    #$0, d0
01019c5c  00000000          ori.b    #$0, d0
01019c60  00000000          ori.b    #$0, d0
01019c64  00000000          ori.b    #$0, d0
01019c68  00000000          ori.b    #$0, d0
01019c6c  00000000          ori.b    #$0, d0
01019c70  00000000          ori.b    #$0, d0
01019c74  00000000          ori.b    #$0, d0
01019c78  00000000          ori.b    #$0, d0
01019c7c  00000000          ori.b    #$0, d0
01019c80  00000000          ori.b    #$0, d0
01019c84  00000000          ori.b    #$0, d0
01019c88  00000000          ori.b    #$0, d0
01019c8c  00000000          ori.b    #$0, d0
01019c90  00000000          ori.b    #$0, d0
01019c94  00000000          ori.b    #$0, d0
01019c98  00000000          ori.b    #$0, d0
01019c9c  00000000          ori.b    #$0, d0
01019ca0  00000000          ori.b    #$0, d0
01019ca4  00000000          ori.b    #$0, d0
01019ca8  00000000          ori.b    #$0, d0
01019cac  00000000          ori.b    #$0, d0
01019cb0  00000000          ori.b    #$0, d0
01019cb4  00000000          ori.b    #$0, d0
01019cb8  00000000          ori.b    #$0, d0
01019cbc  00000000          ori.b    #$0, d0
01019cc0  00000000          ori.b    #$0, d0
01019cc4  00000000          ori.b    #$0, d0
01019cc8  00000000          ori.b    #$0, d0
01019ccc  00000000          ori.b    #$0, d0
01019cd0  00000000          ori.b    #$0, d0
01019cd4  00000000          ori.b    #$0, d0
01019cd8  00000000          ori.b    #$0, d0
01019cdc  00000000          ori.b    #$0, d0
01019ce0  00000000          ori.b    #$0, d0
01019ce4  00000000          ori.b    #$0, d0
01019ce8  00000000          ori.b    #$0, d0
01019cec  00000000          ori.b    #$0, d0
01019cf0  00000000          ori.b    #$0, d0
01019cf4  00000000          ori.b    #$0, d0
01019cf8  00000000          ori.b    #$0, d0
01019cfc  00000000          ori.b    #$0, d0
01019d00  00000000          ori.b    #$0, d0
01019d04  00000000          ori.b    #$0, d0
01019d08  00000000          ori.b    #$0, d0
01019d0c  00000000          ori.b    #$0, d0
01019d10  00000000          ori.b    #$0, d0
01019d14  00000000          ori.b    #$0, d0
01019d18  00000000          ori.b    #$0, d0
01019d1c  00000000          ori.b    #$0, d0
01019d20  00000000          ori.b    #$0, d0
01019d24  00000000          ori.b    #$0, d0
01019d28  00000000          ori.b    #$0, d0
01019d2c  00000000          ori.b    #$0, d0
01019d30  00000000          ori.b    #$0, d0
01019d34  00000000          ori.b    #$0, d0
01019d38  00000000          ori.b    #$0, d0
01019d3c  00000000          ori.b    #$0, d0
01019d40  00000000          ori.b    #$0, d0
01019d44  00000000          ori.b    #$0, d0
01019d48  00000000          ori.b    #$0, d0
01019d4c  00000000          ori.b    #$0, d0
01019d50  00000000          ori.b    #$0, d0
01019d54  00000000          ori.b    #$0, d0
01019d58  00000000          ori.b    #$0, d0
01019d5c  00000000          ori.b    #$0, d0
01019d60  00000000          ori.b    #$0, d0
01019d64  00000000          ori.b    #$0, d0
01019d68  00000000          ori.b    #$0, d0
01019d6c  00000000          ori.b    #$0, d0
01019d70  00000000          ori.b    #$0, d0
01019d74  00000000          ori.b    #$0, d0
01019d78  00000000          ori.b    #$0, d0
01019d7c  00000000          ori.b    #$0, d0
01019d80  00000000          ori.b    #$0, d0
01019d84  00000000          ori.b    #$0, d0
01019d88  00000000          ori.b    #$0, d0
01019d8c  00000000          ori.b    #$0, d0
01019d90  00000000          ori.b    #$0, d0
01019d94  00000000          ori.b    #$0, d0
01019d98  00000000          ori.b    #$0, d0
01019d9c  00000000          ori.b    #$0, d0
01019da0  00000000          ori.b    #$0, d0
01019da4  00000000          ori.b    #$0, d0
01019da8  00000000          ori.b    #$0, d0
01019dac  00000000          ori.b    #$0, d0
01019db0  00000000          ori.b    #$0, d0
01019db4  00000000          ori.b    #$0, d0
01019db8  00000000          ori.b    #$0, d0
01019dbc  00000000          ori.b    #$0, d0
01019dc0  00000000          ori.b    #$0, d0
01019dc4  00000000          ori.b    #$0, d0
01019dc8  00000000          ori.b    #$0, d0
01019dcc  00000000          ori.b    #$0, d0
01019dd0  00000000          ori.b    #$0, d0
01019dd4  00000000          ori.b    #$0, d0
01019dd8  00000000          ori.b    #$0, d0
01019ddc  00000000          ori.b    #$0, d0
01019de0  00000000          ori.b    #$0, d0
01019de4  00000000          ori.b    #$0, d0
01019de8  00000000          ori.b    #$0, d0
01019dec  00000000          ori.b    #$0, d0
01019df0  00000000          ori.b    #$0, d0
01019df4  00000000          ori.b    #$0, d0
01019df8  00000000          ori.b    #$0, d0
01019dfc  00000000          ori.b    #$0, d0
01019e00  00000000          ori.b    #$0, d0
01019e04  00000000          ori.b    #$0, d0
01019e08  00000000          ori.b    #$0, d0
01019e0c  00000000          ori.b    #$0, d0
01019e10  00000000          ori.b    #$0, d0
01019e14  00000000          ori.b    #$0, d0
01019e18  00000000          ori.b    #$0, d0
01019e1c  00000000          ori.b    #$0, d0
01019e20  00000000          ori.b    #$0, d0
01019e24  00000000          ori.b    #$0, d0
01019e28  00000000          ori.b    #$0, d0
01019e2c  00000000          ori.b    #$0, d0
01019e30  00000000          ori.b    #$0, d0
01019e34  00000000          ori.b    #$0, d0
01019e38  00000000          ori.b    #$0, d0
01019e3c  00000000          ori.b    #$0, d0
01019e40  00000000          ori.b    #$0, d0
01019e44  00000000          ori.b    #$0, d0
01019e48  00000000          ori.b    #$0, d0
01019e4c  00000000          ori.b    #$0, d0
01019e50  00000000          ori.b    #$0, d0
01019e54  00000000          ori.b    #$0, d0
01019e58  00000000          ori.b    #$0, d0
01019e5c  00000000          ori.b    #$0, d0
01019e60  00000000          ori.b    #$0, d0
01019e64  00000000          ori.b    #$0, d0
01019e68  00000000          ori.b    #$0, d0
01019e6c  00000000          ori.b    #$0, d0
01019e70  00000000          ori.b    #$0, d0
01019e74  00000000          ori.b    #$0, d0
01019e78  00000000          ori.b    #$0, d0
01019e7c  00000000          ori.b    #$0, d0
01019e80  00000000          ori.b    #$0, d0
01019e84  00000000          ori.b    #$0, d0
01019e88  00000000          ori.b    #$0, d0
01019e8c  00000000          ori.b    #$0, d0
01019e90  00000000          ori.b    #$0, d0
01019e94  00000000          ori.b    #$0, d0
01019e98  00000000          ori.b    #$0, d0
01019e9c  00000000          ori.b    #$0, d0
01019ea0  00000000          ori.b    #$0, d0
01019ea4  00000000          ori.b    #$0, d0
01019ea8  00000000          ori.b    #$0, d0
01019eac  00000000          ori.b    #$0, d0
01019eb0  00000000          ori.b    #$0, d0
01019eb4  00000000          ori.b    #$0, d0
01019eb8  00000000          ori.b    #$0, d0
01019ebc  00000000          ori.b    #$0, d0
01019ec0  00000000          ori.b    #$0, d0
01019ec4  00000000          ori.b    #$0, d0
01019ec8  00000000          ori.b    #$0, d0
01019ecc  00000000          ori.b    #$0, d0
01019ed0  00000000          ori.b    #$0, d0
01019ed4  00000000          ori.b    #$0, d0
01019ed8  00000000          ori.b    #$0, d0
01019edc  00000000          ori.b    #$0, d0
01019ee0  00000000          ori.b    #$0, d0
01019ee4  00000000          ori.b    #$0, d0
01019ee8  00000000          ori.b    #$0, d0
01019eec  00000000          ori.b    #$0, d0
01019ef0  00000000          ori.b    #$0, d0
01019ef4  00000000          ori.b    #$0, d0
01019ef8  00000000          ori.b    #$0, d0
01019efc  00000000          ori.b    #$0, d0
01019f00  00000000          ori.b    #$0, d0
01019f04  00000000          ori.b    #$0, d0
01019f08  00000000          ori.b    #$0, d0
01019f0c  00000000          ori.b    #$0, d0
01019f10  00000000          ori.b    #$0, d0
01019f14  00000000          ori.b    #$0, d0
01019f18  00000000          ori.b    #$0, d0
01019f1c  00000000          ori.b    #$0, d0
01019f20  00000000          ori.b    #$0, d0
01019f24  00000000          ori.b    #$0, d0
01019f28  00000000          ori.b    #$0, d0
01019f2c  00000000          ori.b    #$0, d0
01019f30  00000000          ori.b    #$0, d0
01019f34  00000000          ori.b    #$0, d0
01019f38  00000000          ori.b    #$0, d0
01019f3c  00000000          ori.b    #$0, d0
01019f40  00000000          ori.b    #$0, d0
01019f44  00000000          ori.b    #$0, d0
01019f48  00000000          ori.b    #$0, d0
01019f4c  00000000          ori.b    #$0, d0
01019f50  00000000          ori.b    #$0, d0
01019f54  00000000          ori.b    #$0, d0
01019f58  00000000          ori.b    #$0, d0
01019f5c  00000000          ori.b    #$0, d0
01019f60  00000000          ori.b    #$0, d0
01019f64  00000000          ori.b    #$0, d0
01019f68  00000000          ori.b    #$0, d0
01019f6c  00000000          ori.b    #$0, d0
01019f70  00000000          ori.b    #$0, d0
01019f74  00000000          ori.b    #$0, d0
01019f78  00000000          ori.b    #$0, d0
01019f7c  00000000          ori.b    #$0, d0
01019f80  00000000          ori.b    #$0, d0
01019f84  00000000          ori.b    #$0, d0
01019f88  00000000          ori.b    #$0, d0
01019f8c  00000000          ori.b    #$0, d0
01019f90  00000000          ori.b    #$0, d0
01019f94  00000000          ori.b    #$0, d0
01019f98  00000000          ori.b    #$0, d0
01019f9c  00000000          ori.b    #$0, d0
01019fa0  00000000          ori.b    #$0, d0
01019fa4  00000000          ori.b    #$0, d0
01019fa8  00000000          ori.b    #$0, d0
01019fac  00000000          ori.b    #$0, d0
01019fb0  00000000          ori.b    #$0, d0
01019fb4  00000000          ori.b    #$0, d0
01019fb8  00000000          ori.b    #$0, d0
01019fbc  00000000          ori.b    #$0, d0
01019fc0  00000000          ori.b    #$0, d0
01019fc4  00000000          ori.b    #$0, d0
01019fc8  00000000          ori.b    #$0, d0
01019fcc  00000000          ori.b    #$0, d0
01019fd0  00000000          ori.b    #$0, d0
01019fd4  00000000          ori.b    #$0, d0
01019fd8  00000000          ori.b    #$0, d0
01019fdc  00000000          ori.b    #$0, d0
01019fe0  00000000          ori.b    #$0, d0
01019fe4  00000000          ori.b    #$0, d0
01019fe8  00000000          ori.b    #$0, d0
01019fec  00000000          ori.b    #$0, d0
01019ff0  00000000          ori.b    #$0, d0
01019ff4  00000000          ori.b    #$0, d0
01019ff8  00000000          ori.b    #$0, d0
01019ffc  00000000          ori.b    #$0, d0
0101a000  00000000          ori.b    #$0, d0
0101a004  00000000          ori.b    #$0, d0
0101a008  00000000          ori.b    #$0, d0
0101a00c  00000000          ori.b    #$0, d0
0101a010  00000000          ori.b    #$0, d0
0101a014  00000000          ori.b    #$0, d0
0101a018  00000000          ori.b    #$0, d0
0101a01c  00000000          ori.b    #$0, d0
0101a020  00000000          ori.b    #$0, d0
0101a024  00000000          ori.b    #$0, d0
0101a028  00000000          ori.b    #$0, d0
0101a02c  00000000          ori.b    #$0, d0
0101a030  00000000          ori.b    #$0, d0
0101a034  00000000          ori.b    #$0, d0
0101a038  00000000          ori.b    #$0, d0
0101a03c  00000000          ori.b    #$0, d0
0101a040  00000000          ori.b    #$0, d0
0101a044  00000000          ori.b    #$0, d0
0101a048  00000000          ori.b    #$0, d0
0101a04c  00000000          ori.b    #$0, d0
0101a050  00000000          ori.b    #$0, d0
0101a054  00000000          ori.b    #$0, d0
0101a058  00000000          ori.b    #$0, d0
0101a05c  00000000          ori.b    #$0, d0
0101a060  00000000          ori.b    #$0, d0
0101a064  00000000          ori.b    #$0, d0
0101a068  00000000          ori.b    #$0, d0
0101a06c  00000000          ori.b    #$0, d0
0101a070  00000000          ori.b    #$0, d0
0101a074  00000000          ori.b    #$0, d0
0101a078  00000000          ori.b    #$0, d0
0101a07c  00000000          ori.b    #$0, d0
0101a080  00000000          ori.b    #$0, d0
0101a084  00000000          ori.b    #$0, d0
0101a088  00000000          ori.b    #$0, d0
0101a08c  00000000          ori.b    #$0, d0
0101a090  00000000          ori.b    #$0, d0
0101a094  00000000          ori.b    #$0, d0
0101a098  00000000          ori.b    #$0, d0
0101a09c  00000000          ori.b    #$0, d0
0101a0a0  00000000          ori.b    #$0, d0
0101a0a4  00000000          ori.b    #$0, d0
0101a0a8  00000000          ori.b    #$0, d0
0101a0ac  00000000          ori.b    #$0, d0
0101a0b0  00000000          ori.b    #$0, d0
0101a0b4  00000000          ori.b    #$0, d0
0101a0b8  00000000          ori.b    #$0, d0
0101a0bc  00000000          ori.b    #$0, d0
0101a0c0  00000000          ori.b    #$0, d0
0101a0c4  00000000          ori.b    #$0, d0
0101a0c8  00000000          ori.b    #$0, d0
0101a0cc  00000000          ori.b    #$0, d0
0101a0d0  00000000          ori.b    #$0, d0
0101a0d4  00000000          ori.b    #$0, d0
0101a0d8  00000000          ori.b    #$0, d0
0101a0dc  00000000          ori.b    #$0, d0
0101a0e0  00000000          ori.b    #$0, d0
0101a0e4  00000000          ori.b    #$0, d0
0101a0e8  00000000          ori.b    #$0, d0
0101a0ec  00000000          ori.b    #$0, d0
0101a0f0  00000000          ori.b    #$0, d0
0101a0f4  00000000          ori.b    #$0, d0
0101a0f8  00000000          ori.b    #$0, d0
0101a0fc  00000000          ori.b    #$0, d0
0101a100  00000000          ori.b    #$0, d0
0101a104  00000000          ori.b    #$0, d0
0101a108  00000000          ori.b    #$0, d0
0101a10c  00000000          ori.b    #$0, d0
0101a110  00000000          ori.b    #$0, d0
0101a114  00000000          ori.b    #$0, d0
0101a118  00000000          ori.b    #$0, d0
0101a11c  00000000          ori.b    #$0, d0
0101a120  00000000          ori.b    #$0, d0
0101a124  00000000          ori.b    #$0, d0
0101a128  00000000          ori.b    #$0, d0
0101a12c  00000000          ori.b    #$0, d0
0101a130  00000000          ori.b    #$0, d0
0101a134  00000000          ori.b    #$0, d0
0101a138  00000000          ori.b    #$0, d0
0101a13c  00000000          ori.b    #$0, d0
0101a140  00000000          ori.b    #$0, d0
0101a144  00000000          ori.b    #$0, d0
0101a148  00000000          ori.b    #$0, d0
0101a14c  00000000          ori.b    #$0, d0
0101a150  00000000          ori.b    #$0, d0
0101a154  00000000          ori.b    #$0, d0
0101a158  00000000          ori.b    #$0, d0
0101a15c  00000000          ori.b    #$0, d0
0101a160  00000000          ori.b    #$0, d0
0101a164  00000000          ori.b    #$0, d0
0101a168  00000000          ori.b    #$0, d0
0101a16c  00000000          ori.b    #$0, d0
0101a170  00000000          ori.b    #$0, d0
0101a174  00000000          ori.b    #$0, d0
0101a178  00000000          ori.b    #$0, d0
0101a17c  00000000          ori.b    #$0, d0
0101a180  00000000          ori.b    #$0, d0
0101a184  00000000          ori.b    #$0, d0
0101a188  00000000          ori.b    #$0, d0
0101a18c  00000000          ori.b    #$0, d0
0101a190  00000000          ori.b    #$0, d0
0101a194  00000000          ori.b    #$0, d0
0101a198  00000000          ori.b    #$0, d0
0101a19c  00000000          ori.b    #$0, d0
0101a1a0  00000000          ori.b    #$0, d0
0101a1a4  00000000          ori.b    #$0, d0
0101a1a8  00000000          ori.b    #$0, d0
0101a1ac  00000000          ori.b    #$0, d0
0101a1b0  00000000          ori.b    #$0, d0
0101a1b4  00000000          ori.b    #$0, d0
0101a1b8  00000000          ori.b    #$0, d0
0101a1bc  00000000          ori.b    #$0, d0
0101a1c0  00000000          ori.b    #$0, d0
0101a1c4  00000000          ori.b    #$0, d0
0101a1c8  00000000          ori.b    #$0, d0
0101a1cc  00000000          ori.b    #$0, d0
0101a1d0  00000000          ori.b    #$0, d0
0101a1d4  00000000          ori.b    #$0, d0
0101a1d8  00000000          ori.b    #$0, d0
0101a1dc  00000000          ori.b    #$0, d0
0101a1e0  00000000          ori.b    #$0, d0
0101a1e4  00000000          ori.b    #$0, d0
0101a1e8  00000000          ori.b    #$0, d0
0101a1ec  00000000          ori.b    #$0, d0
0101a1f0  00000000          ori.b    #$0, d0
0101a1f4  00000000          ori.b    #$0, d0
0101a1f8  00000000          ori.b    #$0, d0
0101a1fc  00000000          ori.b    #$0, d0
0101a200  00000000          ori.b    #$0, d0
0101a204  00000000          ori.b    #$0, d0
0101a208  00000000          ori.b    #$0, d0
0101a20c  00000000          ori.b    #$0, d0
0101a210  00000000          ori.b    #$0, d0
0101a214  00000000          ori.b    #$0, d0
0101a218  00000000          ori.b    #$0, d0
0101a21c  00000000          ori.b    #$0, d0
0101a220  00000000          ori.b    #$0, d0
0101a224  00000000          ori.b    #$0, d0
0101a228  00000000          ori.b    #$0, d0
0101a22c  00000000          ori.b    #$0, d0
0101a230  00000000          ori.b    #$0, d0
0101a234  00000000          ori.b    #$0, d0
0101a238  00000000          ori.b    #$0, d0
0101a23c  00000000          ori.b    #$0, d0
0101a240  00000000          ori.b    #$0, d0
0101a244  00000000          ori.b    #$0, d0
0101a248  00000000          ori.b    #$0, d0
0101a24c  00000000          ori.b    #$0, d0
0101a250  00000000          ori.b    #$0, d0
0101a254  00000000          ori.b    #$0, d0
0101a258  00000000          ori.b    #$0, d0
0101a25c  00000000          ori.b    #$0, d0
0101a260  00000000          ori.b    #$0, d0
0101a264  00000000          ori.b    #$0, d0
0101a268  00000000          ori.b    #$0, d0
0101a26c  00000000          ori.b    #$0, d0
0101a270  00000000          ori.b    #$0, d0
0101a274  00000000          ori.b    #$0, d0
0101a278  00000000          ori.b    #$0, d0
0101a27c  00000000          ori.b    #$0, d0
0101a280  00000000          ori.b    #$0, d0
0101a284  00000000          ori.b    #$0, d0
0101a288  00000000          ori.b    #$0, d0
0101a28c  00000000          ori.b    #$0, d0
0101a290  00000000          ori.b    #$0, d0
0101a294  00000000          ori.b    #$0, d0
0101a298  00000000          ori.b    #$0, d0
0101a29c  00000000          ori.b    #$0, d0
0101a2a0  00000000          ori.b    #$0, d0
0101a2a4  00000000          ori.b    #$0, d0
0101a2a8  00000000          ori.b    #$0, d0
0101a2ac  00000000          ori.b    #$0, d0
0101a2b0  00000000          ori.b    #$0, d0
0101a2b4  00000000          ori.b    #$0, d0
0101a2b8  00000000          ori.b    #$0, d0
0101a2bc  00000000          ori.b    #$0, d0
0101a2c0  00000000          ori.b    #$0, d0
0101a2c4  00000000          ori.b    #$0, d0
0101a2c8  00000000          ori.b    #$0, d0
0101a2cc  00000000          ori.b    #$0, d0
0101a2d0  00000000          ori.b    #$0, d0
0101a2d4  00000000          ori.b    #$0, d0
0101a2d8  00000000          ori.b    #$0, d0
0101a2dc  00000000          ori.b    #$0, d0
0101a2e0  00000000          ori.b    #$0, d0
0101a2e4  00000000          ori.b    #$0, d0
0101a2e8  00000000          ori.b    #$0, d0
0101a2ec  00000000          ori.b    #$0, d0
0101a2f0  00000000          ori.b    #$0, d0
0101a2f4  00000000          ori.b    #$0, d0
0101a2f8  00000000          ori.b    #$0, d0
0101a2fc  00000000          ori.b    #$0, d0
0101a300  00000000          ori.b    #$0, d0
0101a304  00000000          ori.b    #$0, d0
0101a308  00000000          ori.b    #$0, d0
0101a30c  00000000          ori.b    #$0, d0
0101a310  00000000          ori.b    #$0, d0
0101a314  00000000          ori.b    #$0, d0
0101a318  00000000          ori.b    #$0, d0
0101a31c  00000000          ori.b    #$0, d0
0101a320  00000000          ori.b    #$0, d0
0101a324  00000000          ori.b    #$0, d0
0101a328  00000000          ori.b    #$0, d0
0101a32c  00000000          ori.b    #$0, d0
0101a330  00000000          ori.b    #$0, d0
0101a334  00000000          ori.b    #$0, d0
0101a338  00000000          ori.b    #$0, d0
0101a33c  00000000          ori.b    #$0, d0
0101a340  00000000          ori.b    #$0, d0
0101a344  00000000          ori.b    #$0, d0
0101a348  00000000          ori.b    #$0, d0
0101a34c  00000000          ori.b    #$0, d0
0101a350  00000000          ori.b    #$0, d0
0101a354  00000000          ori.b    #$0, d0
0101a358  00000000          ori.b    #$0, d0
0101a35c  00000000          ori.b    #$0, d0
0101a360  00000000          ori.b    #$0, d0
0101a364  00000000          ori.b    #$0, d0
0101a368  00000000          ori.b    #$0, d0
0101a36c  00000000          ori.b    #$0, d0
0101a370  00000000          ori.b    #$0, d0
0101a374  00000000          ori.b    #$0, d0
0101a378  00000000          ori.b    #$0, d0
0101a37c  00000000          ori.b    #$0, d0
0101a380  00000000          ori.b    #$0, d0
0101a384  00000000          ori.b    #$0, d0
0101a388  00000000          ori.b    #$0, d0
0101a38c  00000000          ori.b    #$0, d0
0101a390  00000000          ori.b    #$0, d0
0101a394  00000000          ori.b    #$0, d0
0101a398  00000000          ori.b    #$0, d0
0101a39c  00000000          ori.b    #$0, d0
0101a3a0  00000000          ori.b    #$0, d0
0101a3a4  00000000          ori.b    #$0, d0
0101a3a8  00000000          ori.b    #$0, d0
0101a3ac  00000000          ori.b    #$0, d0
0101a3b0  00000000          ori.b    #$0, d0
0101a3b4  00000000          ori.b    #$0, d0
0101a3b8  00000000          ori.b    #$0, d0
0101a3bc  00000000          ori.b    #$0, d0
0101a3c0  00000000          ori.b    #$0, d0
0101a3c4  00000000          ori.b    #$0, d0
0101a3c8  00000000          ori.b    #$0, d0
0101a3cc  00000000          ori.b    #$0, d0
0101a3d0  00000000          ori.b    #$0, d0
0101a3d4  00000000          ori.b    #$0, d0
0101a3d8  00000000          ori.b    #$0, d0
0101a3dc  00000000          ori.b    #$0, d0
0101a3e0  00000000          ori.b    #$0, d0
0101a3e4  00000000          ori.b    #$0, d0
0101a3e8  00000000          ori.b    #$0, d0
0101a3ec  00000000          ori.b    #$0, d0
0101a3f0  00000000          ori.b    #$0, d0
0101a3f4  00000000          ori.b    #$0, d0
0101a3f8  00000000          ori.b    #$0, d0
0101a3fc  00000000          ori.b    #$0, d0
0101a400  00000000          ori.b    #$0, d0
0101a404  00000000          ori.b    #$0, d0
0101a408  00000000          ori.b    #$0, d0
0101a40c  00000000          ori.b    #$0, d0
0101a410  00000000          ori.b    #$0, d0
0101a414  00000000          ori.b    #$0, d0
0101a418  00000000          ori.b    #$0, d0
0101a41c  00000000          ori.b    #$0, d0
0101a420  00000000          ori.b    #$0, d0
0101a424  00000000          ori.b    #$0, d0
0101a428  00000000          ori.b    #$0, d0
0101a42c  00000000          ori.b    #$0, d0
0101a430  00000000          ori.b    #$0, d0
0101a434  00000000          ori.b    #$0, d0
0101a438  00000000          ori.b    #$0, d0
0101a43c  00000000          ori.b    #$0, d0
0101a440  00000000          ori.b    #$0, d0
0101a444  00000000          ori.b    #$0, d0
0101a448  00000000          ori.b    #$0, d0
0101a44c  00000000          ori.b    #$0, d0
0101a450  00000000          ori.b    #$0, d0
0101a454  00000000          ori.b    #$0, d0
0101a458  00000000          ori.b    #$0, d0
0101a45c  00000000          ori.b    #$0, d0
0101a460  00000000          ori.b    #$0, d0
0101a464  00000000          ori.b    #$0, d0
0101a468  00000000          ori.b    #$0, d0
0101a46c  00000000          ori.b    #$0, d0
0101a470  00000000          ori.b    #$0, d0
0101a474  00000000          ori.b    #$0, d0
0101a478  00000000          ori.b    #$0, d0
0101a47c  00000000          ori.b    #$0, d0
0101a480  00000000          ori.b    #$0, d0
0101a484  00000000          ori.b    #$0, d0
0101a488  00000000          ori.b    #$0, d0
0101a48c  00000000          ori.b    #$0, d0
0101a490  00000000          ori.b    #$0, d0
0101a494  00000000          ori.b    #$0, d0
0101a498  00000000          ori.b    #$0, d0
0101a49c  00000000          ori.b    #$0, d0
0101a4a0  00000000          ori.b    #$0, d0
0101a4a4  00000000          ori.b    #$0, d0
0101a4a8  00000000          ori.b    #$0, d0
0101a4ac  00000000          ori.b    #$0, d0
0101a4b0  00000000          ori.b    #$0, d0
0101a4b4  00000000          ori.b    #$0, d0
0101a4b8  00000000          ori.b    #$0, d0
0101a4bc  00000000          ori.b    #$0, d0
0101a4c0  00000000          ori.b    #$0, d0
0101a4c4  00000000          ori.b    #$0, d0
0101a4c8  00000000          ori.b    #$0, d0
0101a4cc  00000000          ori.b    #$0, d0
0101a4d0  00000000          ori.b    #$0, d0
0101a4d4  00000000          ori.b    #$0, d0
0101a4d8  00000000          ori.b    #$0, d0
0101a4dc  00000000          ori.b    #$0, d0
0101a4e0  00000000          ori.b    #$0, d0
0101a4e4  00000000          ori.b    #$0, d0
0101a4e8  00000000          ori.b    #$0, d0
0101a4ec  00000000          ori.b    #$0, d0
0101a4f0  00000000          ori.b    #$0, d0
0101a4f4  00000000          ori.b    #$0, d0
0101a4f8  00000000          ori.b    #$0, d0
0101a4fc  00000000          ori.b    #$0, d0
0101a500  00000000          ori.b    #$0, d0
0101a504  00000000          ori.b    #$0, d0
0101a508  00000000          ori.b    #$0, d0
0101a50c  00000000          ori.b    #$0, d0
0101a510  00000000          ori.b    #$0, d0
0101a514  00000000          ori.b    #$0, d0
0101a518  00000000          ori.b    #$0, d0
0101a51c  00000000          ori.b    #$0, d0
0101a520  00000000          ori.b    #$0, d0
0101a524  00000000          ori.b    #$0, d0
0101a528  00000000          ori.b    #$0, d0
0101a52c  00000000          ori.b    #$0, d0
0101a530  00000000          ori.b    #$0, d0
0101a534  00000000          ori.b    #$0, d0
0101a538  00000000          ori.b    #$0, d0
0101a53c  00000000          ori.b    #$0, d0
0101a540  00000000          ori.b    #$0, d0
0101a544  00000000          ori.b    #$0, d0
0101a548  00000000          ori.b    #$0, d0
0101a54c  00000000          ori.b    #$0, d0
0101a550  00000000          ori.b    #$0, d0
0101a554  00000000          ori.b    #$0, d0
0101a558  00000000          ori.b    #$0, d0
0101a55c  00000000          ori.b    #$0, d0
0101a560  00000000          ori.b    #$0, d0
0101a564  00000000          ori.b    #$0, d0
0101a568  00000000          ori.b    #$0, d0
0101a56c  00000000          ori.b    #$0, d0
0101a570  00000000          ori.b    #$0, d0
0101a574  00000000          ori.b    #$0, d0
0101a578  00000000          ori.b    #$0, d0
0101a57c  00000000          ori.b    #$0, d0
0101a580  00000000          ori.b    #$0, d0
0101a584  00000000          ori.b    #$0, d0
0101a588  00000000          ori.b    #$0, d0
0101a58c  00000000          ori.b    #$0, d0
0101a590  00000000          ori.b    #$0, d0
0101a594  00000000          ori.b    #$0, d0
0101a598  00000000          ori.b    #$0, d0
0101a59c  00000000          ori.b    #$0, d0
0101a5a0  00000000          ori.b    #$0, d0
0101a5a4  00000000          ori.b    #$0, d0
0101a5a8  00000000          ori.b    #$0, d0
0101a5ac  00000000          ori.b    #$0, d0
0101a5b0  00000000          ori.b    #$0, d0
0101a5b4  00000000          ori.b    #$0, d0
0101a5b8  00000000          ori.b    #$0, d0
0101a5bc  00000000          ori.b    #$0, d0
0101a5c0  00000000          ori.b    #$0, d0
0101a5c4  00000000          ori.b    #$0, d0
0101a5c8  00000000          ori.b    #$0, d0
0101a5cc  00000000          ori.b    #$0, d0
0101a5d0  00000000          ori.b    #$0, d0
0101a5d4  00000000          ori.b    #$0, d0
0101a5d8  00000000          ori.b    #$0, d0
0101a5dc  00000000          ori.b    #$0, d0
0101a5e0  00000000          ori.b    #$0, d0
0101a5e4  00000000          ori.b    #$0, d0
0101a5e8  00000000          ori.b    #$0, d0
0101a5ec  00000000          ori.b    #$0, d0
0101a5f0  00000000          ori.b    #$0, d0
0101a5f4  00000000          ori.b    #$0, d0
0101a5f8  00000000          ori.b    #$0, d0
0101a5fc  00000000          ori.b    #$0, d0
0101a600  00000000          ori.b    #$0, d0
0101a604  00000000          ori.b    #$0, d0
0101a608  00000000          ori.b    #$0, d0
0101a60c  00000000          ori.b    #$0, d0
0101a610  00000000          ori.b    #$0, d0
0101a614  00000000          ori.b    #$0, d0
0101a618  00000000          ori.b    #$0, d0
0101a61c  00000000          ori.b    #$0, d0
0101a620  00000000          ori.b    #$0, d0
0101a624  00000000          ori.b    #$0, d0
0101a628  00000000          ori.b    #$0, d0
0101a62c  00000000          ori.b    #$0, d0
0101a630  00000000          ori.b    #$0, d0
0101a634  00000000          ori.b    #$0, d0
0101a638  00000000          ori.b    #$0, d0
0101a63c  00000000          ori.b    #$0, d0
0101a640  00000000          ori.b    #$0, d0
0101a644  00000000          ori.b    #$0, d0
0101a648  00000000          ori.b    #$0, d0
0101a64c  00000000          ori.b    #$0, d0
0101a650  00000000          ori.b    #$0, d0
0101a654  00000000          ori.b    #$0, d0
0101a658  00000000          ori.b    #$0, d0
0101a65c  00000000          ori.b    #$0, d0
0101a660  00000000          ori.b    #$0, d0
0101a664  00000000          ori.b    #$0, d0
0101a668  00000000          ori.b    #$0, d0
0101a66c  00000000          ori.b    #$0, d0
0101a670  00000000          ori.b    #$0, d0
0101a674  00000000          ori.b    #$0, d0
0101a678  00000000          ori.b    #$0, d0
0101a67c  00000000          ori.b    #$0, d0
0101a680  00000000          ori.b    #$0, d0
0101a684  00000000          ori.b    #$0, d0
0101a688  00000000          ori.b    #$0, d0
0101a68c  00000000          ori.b    #$0, d0
0101a690  00000000          ori.b    #$0, d0
0101a694  00000000          ori.b    #$0, d0
0101a698  00000000          ori.b    #$0, d0
0101a69c  00000000          ori.b    #$0, d0
0101a6a0  00000000          ori.b    #$0, d0
0101a6a4  00000000          ori.b    #$0, d0
0101a6a8  00000000          ori.b    #$0, d0
0101a6ac  00000000          ori.b    #$0, d0
0101a6b0  00000000          ori.b    #$0, d0
0101a6b4  00000000          ori.b    #$0, d0
0101a6b8  00000000          ori.b    #$0, d0
0101a6bc  00000000          ori.b    #$0, d0
0101a6c0  00000000          ori.b    #$0, d0
0101a6c4  00000000          ori.b    #$0, d0
0101a6c8  00000000          ori.b    #$0, d0
0101a6cc  00000000          ori.b    #$0, d0
0101a6d0  00000000          ori.b    #$0, d0
0101a6d4  00000000          ori.b    #$0, d0
0101a6d8  00000000          ori.b    #$0, d0
0101a6dc  00000000          ori.b    #$0, d0
0101a6e0  00000000          ori.b    #$0, d0
0101a6e4  00000000          ori.b    #$0, d0
0101a6e8  00000000          ori.b    #$0, d0
0101a6ec  00000000          ori.b    #$0, d0
0101a6f0  00000000          ori.b    #$0, d0
0101a6f4  00000000          ori.b    #$0, d0
0101a6f8  00000000          ori.b    #$0, d0
0101a6fc  00000000          ori.b    #$0, d0
0101a700  00000000          ori.b    #$0, d0
0101a704  00000000          ori.b    #$0, d0
0101a708  00000000          ori.b    #$0, d0
0101a70c  00000000          ori.b    #$0, d0
0101a710  00000000          ori.b    #$0, d0
0101a714  00000000          ori.b    #$0, d0
0101a718  00000000          ori.b    #$0, d0
0101a71c  00000000          ori.b    #$0, d0
0101a720  00000000          ori.b    #$0, d0
0101a724  00000000          ori.b    #$0, d0
0101a728  00000000          ori.b    #$0, d0
0101a72c  00000000          ori.b    #$0, d0
0101a730  00000000          ori.b    #$0, d0
0101a734  00000000          ori.b    #$0, d0
0101a738  00000000          ori.b    #$0, d0
0101a73c  00000000          ori.b    #$0, d0
0101a740  00000000          ori.b    #$0, d0
0101a744  00000000          ori.b    #$0, d0
0101a748  00000000          ori.b    #$0, d0
0101a74c  00000000          ori.b    #$0, d0
0101a750  00000000          ori.b    #$0, d0
0101a754  00000000          ori.b    #$0, d0
0101a758  00000000          ori.b    #$0, d0
0101a75c  00000000          ori.b    #$0, d0
0101a760  00000000          ori.b    #$0, d0
0101a764  00000000          ori.b    #$0, d0
0101a768  00000000          ori.b    #$0, d0
0101a76c  00000000          ori.b    #$0, d0
0101a770  00000000          ori.b    #$0, d0
0101a774  00000000          ori.b    #$0, d0
0101a778  00000000          ori.b    #$0, d0
0101a77c  00000000          ori.b    #$0, d0
0101a780  00000000          ori.b    #$0, d0
0101a784  00000000          ori.b    #$0, d0
0101a788  00000000          ori.b    #$0, d0
0101a78c  00000000          ori.b    #$0, d0
0101a790  00000000          ori.b    #$0, d0
0101a794  00000000          ori.b    #$0, d0
0101a798  00000000          ori.b    #$0, d0
0101a79c  00000000          ori.b    #$0, d0
0101a7a0  00000000          ori.b    #$0, d0
0101a7a4  00000000          ori.b    #$0, d0
0101a7a8  00000000          ori.b    #$0, d0
0101a7ac  00000000          ori.b    #$0, d0
0101a7b0  00000000          ori.b    #$0, d0
0101a7b4  00000000          ori.b    #$0, d0
0101a7b8  00000000          ori.b    #$0, d0
0101a7bc  00000000          ori.b    #$0, d0
0101a7c0  00000000          ori.b    #$0, d0
0101a7c4  00000000          ori.b    #$0, d0
0101a7c8  00000000          ori.b    #$0, d0
0101a7cc  00000000          ori.b    #$0, d0
0101a7d0  00000000          ori.b    #$0, d0
0101a7d4  00000000          ori.b    #$0, d0
0101a7d8  00000000          ori.b    #$0, d0
0101a7dc  00000000          ori.b    #$0, d0
0101a7e0  00000000          ori.b    #$0, d0
0101a7e4  00000000          ori.b    #$0, d0
0101a7e8  00000000          ori.b    #$0, d0
0101a7ec  00000000          ori.b    #$0, d0
0101a7f0  00000000          ori.b    #$0, d0
0101a7f4  00000000          ori.b    #$0, d0
0101a7f8  00000000          ori.b    #$0, d0
0101a7fc  00000000          ori.b    #$0, d0
0101a800  00000000          ori.b    #$0, d0
0101a804  00000000          ori.b    #$0, d0
0101a808  00000000          ori.b    #$0, d0
0101a80c  00000000          ori.b    #$0, d0
0101a810  00000000          ori.b    #$0, d0
0101a814  00000000          ori.b    #$0, d0
0101a818  00000000          ori.b    #$0, d0
0101a81c  00000000          ori.b    #$0, d0
0101a820  00000000          ori.b    #$0, d0
0101a824  00000000          ori.b    #$0, d0
0101a828  00000000          ori.b    #$0, d0
0101a82c  00000000          ori.b    #$0, d0
0101a830  00000000          ori.b    #$0, d0
0101a834  00000000          ori.b    #$0, d0
0101a838  00000000          ori.b    #$0, d0
0101a83c  00000000          ori.b    #$0, d0
0101a840  00000000          ori.b    #$0, d0
0101a844  00000000          ori.b    #$0, d0
0101a848  00000000          ori.b    #$0, d0
0101a84c  00000000          ori.b    #$0, d0
0101a850  00000000          ori.b    #$0, d0
0101a854  00000000          ori.b    #$0, d0
0101a858  00000000          ori.b    #$0, d0
0101a85c  00000000          ori.b    #$0, d0
0101a860  00000000          ori.b    #$0, d0
0101a864  00000000          ori.b    #$0, d0
0101a868  00000000          ori.b    #$0, d0
0101a86c  00000000          ori.b    #$0, d0
0101a870  00000000          ori.b    #$0, d0
0101a874  00000000          ori.b    #$0, d0
0101a878  00000000          ori.b    #$0, d0
0101a87c  00000000          ori.b    #$0, d0
0101a880  00000000          ori.b    #$0, d0
0101a884  00000000          ori.b    #$0, d0
0101a888  00000000          ori.b    #$0, d0
0101a88c  00000000          ori.b    #$0, d0
0101a890  00000000          ori.b    #$0, d0
0101a894  00000000          ori.b    #$0, d0
0101a898  00000000          ori.b    #$0, d0
0101a89c  00000000          ori.b    #$0, d0
0101a8a0  00000000          ori.b    #$0, d0
0101a8a4  00000000          ori.b    #$0, d0
0101a8a8  00000000          ori.b    #$0, d0
0101a8ac  00000000          ori.b    #$0, d0
0101a8b0  00000000          ori.b    #$0, d0
0101a8b4  00000000          ori.b    #$0, d0
0101a8b8  00000000          ori.b    #$0, d0
0101a8bc  00000000          ori.b    #$0, d0
0101a8c0  00000000          ori.b    #$0, d0
0101a8c4  00000000          ori.b    #$0, d0
0101a8c8  00000000          ori.b    #$0, d0
0101a8cc  00000000          ori.b    #$0, d0
0101a8d0  00000000          ori.b    #$0, d0
0101a8d4  00000000          ori.b    #$0, d0
0101a8d8  00000000          ori.b    #$0, d0
0101a8dc  00000000          ori.b    #$0, d0
0101a8e0  00000000          ori.b    #$0, d0
0101a8e4  00000000          ori.b    #$0, d0
0101a8e8  00000000          ori.b    #$0, d0
0101a8ec  00000000          ori.b    #$0, d0
0101a8f0  00000000          ori.b    #$0, d0
0101a8f4  00000000          ori.b    #$0, d0
0101a8f8  00000000          ori.b    #$0, d0
0101a8fc  00000000          ori.b    #$0, d0
0101a900  00000000          ori.b    #$0, d0
0101a904  00000000          ori.b    #$0, d0
0101a908  00000000          ori.b    #$0, d0
0101a90c  00000000          ori.b    #$0, d0
0101a910  00000000          ori.b    #$0, d0
0101a914  00000000          ori.b    #$0, d0
0101a918  00000000          ori.b    #$0, d0
0101a91c  00000000          ori.b    #$0, d0
0101a920  00000000          ori.b    #$0, d0
0101a924  00000000          ori.b    #$0, d0
0101a928  00000000          ori.b    #$0, d0
0101a92c  00000000          ori.b    #$0, d0
0101a930  00000000          ori.b    #$0, d0
0101a934  00000000          ori.b    #$0, d0
0101a938  00000000          ori.b    #$0, d0
0101a93c  00000000          ori.b    #$0, d0
0101a940  00000000          ori.b    #$0, d0
0101a944  00000000          ori.b    #$0, d0
0101a948  00000000          ori.b    #$0, d0
0101a94c  00000000          ori.b    #$0, d0
0101a950  00000000          ori.b    #$0, d0
0101a954  00000000          ori.b    #$0, d0
0101a958  00000000          ori.b    #$0, d0
0101a95c  00000000          ori.b    #$0, d0
0101a960  00000000          ori.b    #$0, d0
0101a964  00000000          ori.b    #$0, d0
0101a968  00000000          ori.b    #$0, d0
0101a96c  00000000          ori.b    #$0, d0
0101a970  00000000          ori.b    #$0, d0
0101a974  00000000          ori.b    #$0, d0
0101a978  00000000          ori.b    #$0, d0
0101a97c  00000000          ori.b    #$0, d0
0101a980  00000000          ori.b    #$0, d0
0101a984  00000000          ori.b    #$0, d0
0101a988  00000000          ori.b    #$0, d0
0101a98c  00000000          ori.b    #$0, d0
0101a990  00000000          ori.b    #$0, d0
0101a994  00000000          ori.b    #$0, d0
0101a998  00000000          ori.b    #$0, d0
0101a99c  00000000          ori.b    #$0, d0
0101a9a0  00000000          ori.b    #$0, d0
0101a9a4  00000000          ori.b    #$0, d0
0101a9a8  00000000          ori.b    #$0, d0
0101a9ac  00000000          ori.b    #$0, d0
0101a9b0  00000000          ori.b    #$0, d0
0101a9b4  00000000          ori.b    #$0, d0
0101a9b8  00000000          ori.b    #$0, d0
0101a9bc  00000000          ori.b    #$0, d0
0101a9c0  00000000          ori.b    #$0, d0
0101a9c4  00000000          ori.b    #$0, d0
0101a9c8  00000000          ori.b    #$0, d0
0101a9cc  00000000          ori.b    #$0, d0
0101a9d0  00000000          ori.b    #$0, d0
0101a9d4  00000000          ori.b    #$0, d0
0101a9d8  00000000          ori.b    #$0, d0
0101a9dc  00000000          ori.b    #$0, d0
0101a9e0  00000000          ori.b    #$0, d0
0101a9e4  00000000          ori.b    #$0, d0
0101a9e8  00000000          ori.b    #$0, d0
0101a9ec  00000000          ori.b    #$0, d0
0101a9f0  00000000          ori.b    #$0, d0
0101a9f4  00000000          ori.b    #$0, d0
0101a9f8  00000000          ori.b    #$0, d0
0101a9fc  00000000          ori.b    #$0, d0
0101aa00  00000000          ori.b    #$0, d0
0101aa04  00000000          ori.b    #$0, d0
0101aa08  00000000          ori.b    #$0, d0
0101aa0c  00000000          ori.b    #$0, d0
0101aa10  00000000          ori.b    #$0, d0
0101aa14  00000000          ori.b    #$0, d0
0101aa18  00000000          ori.b    #$0, d0
0101aa1c  00000000          ori.b    #$0, d0
0101aa20  00000000          ori.b    #$0, d0
0101aa24  00000000          ori.b    #$0, d0
0101aa28  00000000          ori.b    #$0, d0
0101aa2c  00000000          ori.b    #$0, d0
0101aa30  00000000          ori.b    #$0, d0
0101aa34  00000000          ori.b    #$0, d0
0101aa38  00000000          ori.b    #$0, d0
0101aa3c  00000000          ori.b    #$0, d0
0101aa40  00000000          ori.b    #$0, d0
0101aa44  00000000          ori.b    #$0, d0
0101aa48  00000000          ori.b    #$0, d0
0101aa4c  00000000          ori.b    #$0, d0
0101aa50  00000000          ori.b    #$0, d0
0101aa54  00000000          ori.b    #$0, d0
0101aa58  00000000          ori.b    #$0, d0
0101aa5c  00000000          ori.b    #$0, d0
0101aa60  00000000          ori.b    #$0, d0
0101aa64  00000000          ori.b    #$0, d0
0101aa68  00000000          ori.b    #$0, d0
0101aa6c  00000000          ori.b    #$0, d0
0101aa70  00000000          ori.b    #$0, d0
0101aa74  00000000          ori.b    #$0, d0
0101aa78  00000000          ori.b    #$0, d0
0101aa7c  00000000          ori.b    #$0, d0
0101aa80  00000000          ori.b    #$0, d0
0101aa84  00000000          ori.b    #$0, d0
0101aa88  00000000          ori.b    #$0, d0
0101aa8c  00000000          ori.b    #$0, d0
0101aa90  00000000          ori.b    #$0, d0
0101aa94  00000000          ori.b    #$0, d0
0101aa98  00000000          ori.b    #$0, d0
0101aa9c  00000000          ori.b    #$0, d0
0101aaa0  00000000          ori.b    #$0, d0
0101aaa4  00000000          ori.b    #$0, d0
0101aaa8  00000000          ori.b    #$0, d0
0101aaac  00000000          ori.b    #$0, d0
0101aab0  00000000          ori.b    #$0, d0
0101aab4  00000000          ori.b    #$0, d0
0101aab8  00000000          ori.b    #$0, d0
0101aabc  00000000          ori.b    #$0, d0
0101aac0  00000000          ori.b    #$0, d0
0101aac4  00000000          ori.b    #$0, d0
0101aac8  00000000          ori.b    #$0, d0
0101aacc  00000000          ori.b    #$0, d0
0101aad0  00000000          ori.b    #$0, d0
0101aad4  00000000          ori.b    #$0, d0
0101aad8  00000000          ori.b    #$0, d0
0101aadc  00000000          ori.b    #$0, d0
0101aae0  00000000          ori.b    #$0, d0
0101aae4  00000000          ori.b    #$0, d0
0101aae8  00000000          ori.b    #$0, d0
0101aaec  00000000          ori.b    #$0, d0
0101aaf0  00000000          ori.b    #$0, d0
0101aaf4  00000000          ori.b    #$0, d0
0101aaf8  00000000          ori.b    #$0, d0
0101aafc  00000000          ori.b    #$0, d0
0101ab00  00000000          ori.b    #$0, d0
0101ab04  00000000          ori.b    #$0, d0
0101ab08  00000000          ori.b    #$0, d0
0101ab0c  00000000          ori.b    #$0, d0
0101ab10  00000000          ori.b    #$0, d0
0101ab14  00000000          ori.b    #$0, d0
0101ab18  00000000          ori.b    #$0, d0
0101ab1c  00000000          ori.b    #$0, d0
0101ab20  00000000          ori.b    #$0, d0
0101ab24  00000000          ori.b    #$0, d0
0101ab28  00000000          ori.b    #$0, d0
0101ab2c  00000000          ori.b    #$0, d0
0101ab30  00000000          ori.b    #$0, d0
0101ab34  00000000          ori.b    #$0, d0
0101ab38  00000000          ori.b    #$0, d0
0101ab3c  00000000          ori.b    #$0, d0
0101ab40  00000000          ori.b    #$0, d0
0101ab44  00000000          ori.b    #$0, d0
0101ab48  00000000          ori.b    #$0, d0
0101ab4c  00000000          ori.b    #$0, d0
0101ab50  00000000          ori.b    #$0, d0
0101ab54  00000000          ori.b    #$0, d0
0101ab58  00000000          ori.b    #$0, d0
0101ab5c  00000000          ori.b    #$0, d0
0101ab60  00000000          ori.b    #$0, d0
0101ab64  00000000          ori.b    #$0, d0
0101ab68  00000000          ori.b    #$0, d0
0101ab6c  00000000          ori.b    #$0, d0
0101ab70  00000000          ori.b    #$0, d0
0101ab74  00000000          ori.b    #$0, d0
0101ab78  00000000          ori.b    #$0, d0
0101ab7c  00000000          ori.b    #$0, d0
0101ab80  00000000          ori.b    #$0, d0
0101ab84  00000000          ori.b    #$0, d0
0101ab88  00000000          ori.b    #$0, d0
0101ab8c  00000000          ori.b    #$0, d0
0101ab90  00000000          ori.b    #$0, d0
0101ab94  00000000          ori.b    #$0, d0
0101ab98  00000000          ori.b    #$0, d0
0101ab9c  00000000          ori.b    #$0, d0
0101aba0  00000000          ori.b    #$0, d0
0101aba4  00000000          ori.b    #$0, d0
0101aba8  00000000          ori.b    #$0, d0
0101abac  00000000          ori.b    #$0, d0
0101abb0  00000000          ori.b    #$0, d0
0101abb4  00000000          ori.b    #$0, d0
0101abb8  00000000          ori.b    #$0, d0
0101abbc  00000000          ori.b    #$0, d0
0101abc0  00000000          ori.b    #$0, d0
0101abc4  00000000          ori.b    #$0, d0
0101abc8  00000000          ori.b    #$0, d0
0101abcc  00000000          ori.b    #$0, d0
0101abd0  00000000          ori.b    #$0, d0
0101abd4  00000000          ori.b    #$0, d0
0101abd8  00000000          ori.b    #$0, d0
0101abdc  00000000          ori.b    #$0, d0
0101abe0  00000000          ori.b    #$0, d0
0101abe4  00000000          ori.b    #$0, d0
0101abe8  00000000          ori.b    #$0, d0
0101abec  00000000          ori.b    #$0, d0
0101abf0  00000000          ori.b    #$0, d0
0101abf4  00000000          ori.b    #$0, d0
0101abf8  00000000          ori.b    #$0, d0
0101abfc  00000000          ori.b    #$0, d0
0101ac00  00000000          ori.b    #$0, d0
0101ac04  00000000          ori.b    #$0, d0
0101ac08  00000000          ori.b    #$0, d0
0101ac0c  00000000          ori.b    #$0, d0
0101ac10  00000000          ori.b    #$0, d0
0101ac14  00000000          ori.b    #$0, d0
0101ac18  00000000          ori.b    #$0, d0
0101ac1c  00000000          ori.b    #$0, d0
0101ac20  00000000          ori.b    #$0, d0
0101ac24  00000000          ori.b    #$0, d0
0101ac28  00000000          ori.b    #$0, d0
0101ac2c  00000000          ori.b    #$0, d0
0101ac30  00000000          ori.b    #$0, d0
0101ac34  00000000          ori.b    #$0, d0
0101ac38  00000000          ori.b    #$0, d0
0101ac3c  00000000          ori.b    #$0, d0
0101ac40  00000000          ori.b    #$0, d0
0101ac44  00000000          ori.b    #$0, d0
0101ac48  00000000          ori.b    #$0, d0
0101ac4c  00000000          ori.b    #$0, d0
0101ac50  00000000          ori.b    #$0, d0
0101ac54  00000000          ori.b    #$0, d0
0101ac58  00000000          ori.b    #$0, d0
0101ac5c  00000000          ori.b    #$0, d0
0101ac60  00000000          ori.b    #$0, d0
0101ac64  00000000          ori.b    #$0, d0
0101ac68  00000000          ori.b    #$0, d0
0101ac6c  00000000          ori.b    #$0, d0
0101ac70  00000000          ori.b    #$0, d0
0101ac74  00000000          ori.b    #$0, d0
0101ac78  00000000          ori.b    #$0, d0
0101ac7c  00000000          ori.b    #$0, d0
0101ac80  00000000          ori.b    #$0, d0
0101ac84  00000000          ori.b    #$0, d0
0101ac88  00000000          ori.b    #$0, d0
0101ac8c  00000000          ori.b    #$0, d0
0101ac90  00000000          ori.b    #$0, d0
0101ac94  00000000          ori.b    #$0, d0
0101ac98  00000000          ori.b    #$0, d0
0101ac9c  00000000          ori.b    #$0, d0
0101aca0  00000000          ori.b    #$0, d0
0101aca4  00000000          ori.b    #$0, d0
0101aca8  00000000          ori.b    #$0, d0
0101acac  00000000          ori.b    #$0, d0
0101acb0  00000000          ori.b    #$0, d0
0101acb4  00000000          ori.b    #$0, d0
0101acb8  00000000          ori.b    #$0, d0
0101acbc  00000000          ori.b    #$0, d0
0101acc0  00000000          ori.b    #$0, d0
0101acc4  00000000          ori.b    #$0, d0
0101acc8  00000000          ori.b    #$0, d0
0101accc  00000000          ori.b    #$0, d0
0101acd0  00000000          ori.b    #$0, d0
0101acd4  00000000          ori.b    #$0, d0
0101acd8  00000000          ori.b    #$0, d0
0101acdc  00000000          ori.b    #$0, d0
0101ace0  00000000          ori.b    #$0, d0
0101ace4  00000000          ori.b    #$0, d0
0101ace8  00000000          ori.b    #$0, d0
0101acec  00000000          ori.b    #$0, d0
0101acf0  00000000          ori.b    #$0, d0
0101acf4  00000000          ori.b    #$0, d0
0101acf8  00000000          ori.b    #$0, d0
0101acfc  00000000          ori.b    #$0, d0
0101ad00  00000000          ori.b    #$0, d0
0101ad04  00000000          ori.b    #$0, d0
0101ad08  00000000          ori.b    #$0, d0
0101ad0c  00000000          ori.b    #$0, d0
0101ad10  00000000          ori.b    #$0, d0
0101ad14  00000000          ori.b    #$0, d0
0101ad18  00000000          ori.b    #$0, d0
0101ad1c  00000000          ori.b    #$0, d0
0101ad20  00000000          ori.b    #$0, d0
0101ad24  00000000          ori.b    #$0, d0
0101ad28  00000000          ori.b    #$0, d0
0101ad2c  00000000          ori.b    #$0, d0
0101ad30  00000000          ori.b    #$0, d0
0101ad34  00000000          ori.b    #$0, d0
0101ad38  00000000          ori.b    #$0, d0
0101ad3c  00000000          ori.b    #$0, d0
0101ad40  00000000          ori.b    #$0, d0
0101ad44  00000000          ori.b    #$0, d0
0101ad48  00000000          ori.b    #$0, d0
0101ad4c  00000000          ori.b    #$0, d0
0101ad50  00000000          ori.b    #$0, d0
0101ad54  00000000          ori.b    #$0, d0
0101ad58  00000000          ori.b    #$0, d0
0101ad5c  00000000          ori.b    #$0, d0
0101ad60  00000000          ori.b    #$0, d0
0101ad64  00000000          ori.b    #$0, d0
0101ad68  00000000          ori.b    #$0, d0
0101ad6c  00000000          ori.b    #$0, d0
0101ad70  00000000          ori.b    #$0, d0
0101ad74  00000000          ori.b    #$0, d0
0101ad78  00000000          ori.b    #$0, d0
0101ad7c  00000000          ori.b    #$0, d0
0101ad80  00000000          ori.b    #$0, d0
0101ad84  00000000          ori.b    #$0, d0
0101ad88  00000000          ori.b    #$0, d0
0101ad8c  00000000          ori.b    #$0, d0
0101ad90  00000000          ori.b    #$0, d0
0101ad94  00000000          ori.b    #$0, d0
0101ad98  00000000          ori.b    #$0, d0
0101ad9c  00000000          ori.b    #$0, d0
0101ada0  00000000          ori.b    #$0, d0
0101ada4  00000000          ori.b    #$0, d0
0101ada8  00000000          ori.b    #$0, d0
0101adac  00000000          ori.b    #$0, d0
0101adb0  00000000          ori.b    #$0, d0
0101adb4  00000000          ori.b    #$0, d0
0101adb8  00000000          ori.b    #$0, d0
0101adbc  00000000          ori.b    #$0, d0
0101adc0  00000000          ori.b    #$0, d0
0101adc4  00000000          ori.b    #$0, d0
0101adc8  00000000          ori.b    #$0, d0
0101adcc  00000000          ori.b    #$0, d0
0101add0  00000000          ori.b    #$0, d0
0101add4  00000000          ori.b    #$0, d0
0101add8  00000000          ori.b    #$0, d0
0101addc  00000000          ori.b    #$0, d0
0101ade0  00000000          ori.b    #$0, d0
0101ade4  00000000          ori.b    #$0, d0
0101ade8  00000000          ori.b    #$0, d0
0101adec  00000000          ori.b    #$0, d0
0101adf0  00000000          ori.b    #$0, d0
0101adf4  00000000          ori.b    #$0, d0
0101adf8  00000000          ori.b    #$0, d0
0101adfc  00000000          ori.b    #$0, d0
0101ae00  00000000          ori.b    #$0, d0
0101ae04  00000000          ori.b    #$0, d0
0101ae08  00000000          ori.b    #$0, d0
0101ae0c  00000000          ori.b    #$0, d0
0101ae10  00000000          ori.b    #$0, d0
0101ae14  00000000          ori.b    #$0, d0
0101ae18  00000000          ori.b    #$0, d0
0101ae1c  00000000          ori.b    #$0, d0
0101ae20  00000000          ori.b    #$0, d0
0101ae24  00000000          ori.b    #$0, d0
0101ae28  00000000          ori.b    #$0, d0
0101ae2c  00000000          ori.b    #$0, d0
0101ae30  00000000          ori.b    #$0, d0
0101ae34  00000000          ori.b    #$0, d0
0101ae38  00000000          ori.b    #$0, d0
0101ae3c  00000000          ori.b    #$0, d0
0101ae40  00000000          ori.b    #$0, d0
0101ae44  00000000          ori.b    #$0, d0
0101ae48  00000000          ori.b    #$0, d0
0101ae4c  00000000          ori.b    #$0, d0
0101ae50  00000000          ori.b    #$0, d0
0101ae54  00000000          ori.b    #$0, d0
0101ae58  00000000          ori.b    #$0, d0
0101ae5c  00000000          ori.b    #$0, d0
0101ae60  00000000          ori.b    #$0, d0
0101ae64  00000000          ori.b    #$0, d0
0101ae68  00000000          ori.b    #$0, d0
0101ae6c  00000000          ori.b    #$0, d0
0101ae70  00000000          ori.b    #$0, d0
0101ae74  00000000          ori.b    #$0, d0
0101ae78  00000000          ori.b    #$0, d0
0101ae7c  00000000          ori.b    #$0, d0
0101ae80  00000000          ori.b    #$0, d0
0101ae84  00000000          ori.b    #$0, d0
0101ae88  00000000          ori.b    #$0, d0
0101ae8c  00000000          ori.b    #$0, d0
0101ae90  00000000          ori.b    #$0, d0
0101ae94  00000000          ori.b    #$0, d0
0101ae98  00000000          ori.b    #$0, d0
0101ae9c  00000000          ori.b    #$0, d0
0101aea0  00000000          ori.b    #$0, d0
0101aea4  00000000          ori.b    #$0, d0
0101aea8  00000000          ori.b    #$0, d0
0101aeac  00000000          ori.b    #$0, d0
0101aeb0  00000000          ori.b    #$0, d0
0101aeb4  00000000          ori.b    #$0, d0
0101aeb8  00000000          ori.b    #$0, d0
0101aebc  00000000          ori.b    #$0, d0
0101aec0  00000000          ori.b    #$0, d0
0101aec4  00000000          ori.b    #$0, d0
0101aec8  00000000          ori.b    #$0, d0
0101aecc  00000000          ori.b    #$0, d0
0101aed0  00000000          ori.b    #$0, d0
0101aed4  00000000          ori.b    #$0, d0
0101aed8  00000000          ori.b    #$0, d0
0101aedc  00000000          ori.b    #$0, d0
0101aee0  00000000          ori.b    #$0, d0
0101aee4  00000000          ori.b    #$0, d0
0101aee8  00000000          ori.b    #$0, d0
0101aeec  00000000          ori.b    #$0, d0
0101aef0  00000000          ori.b    #$0, d0
0101aef4  00000000          ori.b    #$0, d0
0101aef8  00000000          ori.b    #$0, d0
0101aefc  00000000          ori.b    #$0, d0
0101af00  00000000          ori.b    #$0, d0
0101af04  00000000          ori.b    #$0, d0
0101af08  00000000          ori.b    #$0, d0
0101af0c  00000000          ori.b    #$0, d0
0101af10  00000000          ori.b    #$0, d0
0101af14  00000000          ori.b    #$0, d0
0101af18  00000000          ori.b    #$0, d0
0101af1c  00000000          ori.b    #$0, d0
0101af20  00000000          ori.b    #$0, d0
0101af24  00000000          ori.b    #$0, d0
0101af28  00000000          ori.b    #$0, d0
0101af2c  00000000          ori.b    #$0, d0
0101af30  00000000          ori.b    #$0, d0
0101af34  00000000          ori.b    #$0, d0
0101af38  00000000          ori.b    #$0, d0
0101af3c  00000000          ori.b    #$0, d0
0101af40  00000000          ori.b    #$0, d0
0101af44  00000000          ori.b    #$0, d0
0101af48  00000000          ori.b    #$0, d0
0101af4c  00000000          ori.b    #$0, d0
0101af50  00000000          ori.b    #$0, d0
0101af54  00000000          ori.b    #$0, d0
0101af58  00000000          ori.b    #$0, d0
0101af5c  00000000          ori.b    #$0, d0
0101af60  00000000          ori.b    #$0, d0
0101af64  00000000          ori.b    #$0, d0
0101af68  00000000          ori.b    #$0, d0
0101af6c  00000000          ori.b    #$0, d0
0101af70  00000000          ori.b    #$0, d0
0101af74  00000000          ori.b    #$0, d0
0101af78  00000000          ori.b    #$0, d0
0101af7c  00000000          ori.b    #$0, d0
0101af80  00000000          ori.b    #$0, d0
0101af84  00000000          ori.b    #$0, d0
0101af88  00000000          ori.b    #$0, d0
0101af8c  00000000          ori.b    #$0, d0
0101af90  00000000          ori.b    #$0, d0
0101af94  00000000          ori.b    #$0, d0
0101af98  00000000          ori.b    #$0, d0
0101af9c  00000000          ori.b    #$0, d0
0101afa0  00000000          ori.b    #$0, d0
0101afa4  00000000          ori.b    #$0, d0
0101afa8  00000000          ori.b    #$0, d0
0101afac  00000000          ori.b    #$0, d0
0101afb0  00000000          ori.b    #$0, d0
0101afb4  00000000          ori.b    #$0, d0
0101afb8  00000000          ori.b    #$0, d0
0101afbc  00000000          ori.b    #$0, d0
0101afc0  00000000          ori.b    #$0, d0
0101afc4  00000000          ori.b    #$0, d0
0101afc8  00000000          ori.b    #$0, d0
0101afcc  00000000          ori.b    #$0, d0
0101afd0  00000000          ori.b    #$0, d0
0101afd4  00000000          ori.b    #$0, d0
0101afd8  00000000          ori.b    #$0, d0
0101afdc  00000000          ori.b    #$0, d0
0101afe0  00000000          ori.b    #$0, d0
0101afe4  00000000          ori.b    #$0, d0
0101afe8  00000000          ori.b    #$0, d0
0101afec  00000000          ori.b    #$0, d0
0101aff0  00000000          ori.b    #$0, d0
0101aff4  00000000          ori.b    #$0, d0
0101aff8  00000000          ori.b    #$0, d0
0101affc  00000000          ori.b    #$0, d0
0101b000  00000000          ori.b    #$0, d0
0101b004  00000000          ori.b    #$0, d0
0101b008  00000000          ori.b    #$0, d0
0101b00c  00000000          ori.b    #$0, d0
0101b010  00000000          ori.b    #$0, d0
0101b014  00000000          ori.b    #$0, d0
0101b018  00000000          ori.b    #$0, d0
0101b01c  00000000          ori.b    #$0, d0
0101b020  00000000          ori.b    #$0, d0
0101b024  00000000          ori.b    #$0, d0
0101b028  00000000          ori.b    #$0, d0
0101b02c  00000000          ori.b    #$0, d0
0101b030  00000000          ori.b    #$0, d0
0101b034  00000000          ori.b    #$0, d0
0101b038  00000000          ori.b    #$0, d0
0101b03c  00000000          ori.b    #$0, d0
0101b040  00000000          ori.b    #$0, d0
0101b044  00000000          ori.b    #$0, d0
0101b048  00000000          ori.b    #$0, d0
0101b04c  00000000          ori.b    #$0, d0
0101b050  00000000          ori.b    #$0, d0
0101b054  00000000          ori.b    #$0, d0
0101b058  00000000          ori.b    #$0, d0
0101b05c  00000000          ori.b    #$0, d0
0101b060  00000000          ori.b    #$0, d0
0101b064  00000000          ori.b    #$0, d0
0101b068  00000000          ori.b    #$0, d0
0101b06c  00000000          ori.b    #$0, d0
0101b070  00000000          ori.b    #$0, d0
0101b074  00000000          ori.b    #$0, d0
0101b078  00000000          ori.b    #$0, d0
0101b07c  00000000          ori.b    #$0, d0
0101b080  00000000          ori.b    #$0, d0
0101b084  00000000          ori.b    #$0, d0
0101b088  00000000          ori.b    #$0, d0
0101b08c  00000000          ori.b    #$0, d0
0101b090  00000000          ori.b    #$0, d0
0101b094  00000000          ori.b    #$0, d0
0101b098  00000000          ori.b    #$0, d0
0101b09c  00000000          ori.b    #$0, d0
0101b0a0  00000000          ori.b    #$0, d0
0101b0a4  00000000          ori.b    #$0, d0
0101b0a8  00000000          ori.b    #$0, d0
0101b0ac  00000000          ori.b    #$0, d0
0101b0b0  00000000          ori.b    #$0, d0
0101b0b4  00000000          ori.b    #$0, d0
0101b0b8  00000000          ori.b    #$0, d0
0101b0bc  00000000          ori.b    #$0, d0
0101b0c0  00000000          ori.b    #$0, d0
0101b0c4  00000000          ori.b    #$0, d0
0101b0c8  00000000          ori.b    #$0, d0
0101b0cc  00000000          ori.b    #$0, d0
0101b0d0  00000000          ori.b    #$0, d0
0101b0d4  00000000          ori.b    #$0, d0
0101b0d8  00000000          ori.b    #$0, d0
0101b0dc  00000000          ori.b    #$0, d0
0101b0e0  00000000          ori.b    #$0, d0
0101b0e4  00000000          ori.b    #$0, d0
0101b0e8  00000000          ori.b    #$0, d0
0101b0ec  00000000          ori.b    #$0, d0
0101b0f0  00000000          ori.b    #$0, d0
0101b0f4  00000000          ori.b    #$0, d0
0101b0f8  00000000          ori.b    #$0, d0
0101b0fc  00000000          ori.b    #$0, d0
0101b100  00000000          ori.b    #$0, d0
0101b104  00000000          ori.b    #$0, d0
0101b108  00000000          ori.b    #$0, d0
0101b10c  00000000          ori.b    #$0, d0
0101b110  00000000          ori.b    #$0, d0
0101b114  00000000          ori.b    #$0, d0
0101b118  00000000          ori.b    #$0, d0
0101b11c  00000000          ori.b    #$0, d0
0101b120  00000000          ori.b    #$0, d0
0101b124  00000000          ori.b    #$0, d0
0101b128  00000000          ori.b    #$0, d0
0101b12c  00000000          ori.b    #$0, d0
0101b130  00000000          ori.b    #$0, d0
0101b134  00000000          ori.b    #$0, d0
0101b138  00000000          ori.b    #$0, d0
0101b13c  00000000          ori.b    #$0, d0
0101b140  00000000          ori.b    #$0, d0
0101b144  00000000          ori.b    #$0, d0
0101b148  00000000          ori.b    #$0, d0
0101b14c  00000000          ori.b    #$0, d0
0101b150  00000000          ori.b    #$0, d0
0101b154  00000000          ori.b    #$0, d0
0101b158  00000000          ori.b    #$0, d0
0101b15c  00000000          ori.b    #$0, d0
0101b160  00000000          ori.b    #$0, d0
0101b164  00000000          ori.b    #$0, d0
0101b168  00000000          ori.b    #$0, d0
0101b16c  00000000          ori.b    #$0, d0
0101b170  00000000          ori.b    #$0, d0
0101b174  00000000          ori.b    #$0, d0
0101b178  00000000          ori.b    #$0, d0
0101b17c  00000000          ori.b    #$0, d0
0101b180  00000000          ori.b    #$0, d0
0101b184  00000000          ori.b    #$0, d0
0101b188  00000000          ori.b    #$0, d0
0101b18c  00000000          ori.b    #$0, d0
0101b190  00000000          ori.b    #$0, d0
0101b194  00000000          ori.b    #$0, d0
0101b198  00000000          ori.b    #$0, d0
0101b19c  00000000          ori.b    #$0, d0
0101b1a0  00000000          ori.b    #$0, d0
0101b1a4  00000000          ori.b    #$0, d0
0101b1a8  00000000          ori.b    #$0, d0
0101b1ac  00000000          ori.b    #$0, d0
0101b1b0  00000000          ori.b    #$0, d0
0101b1b4  00000000          ori.b    #$0, d0
0101b1b8  00000000          ori.b    #$0, d0
0101b1bc  00000000          ori.b    #$0, d0
0101b1c0  00000000          ori.b    #$0, d0
0101b1c4  00000000          ori.b    #$0, d0
0101b1c8  00000000          ori.b    #$0, d0
0101b1cc  00000000          ori.b    #$0, d0
0101b1d0  00000000          ori.b    #$0, d0
0101b1d4  00000000          ori.b    #$0, d0
0101b1d8  00000000          ori.b    #$0, d0
0101b1dc  00000000          ori.b    #$0, d0
0101b1e0  00000000          ori.b    #$0, d0
0101b1e4  00000000          ori.b    #$0, d0
0101b1e8  00000000          ori.b    #$0, d0
0101b1ec  00000000          ori.b    #$0, d0
0101b1f0  00000000          ori.b    #$0, d0
0101b1f4  00000000          ori.b    #$0, d0
0101b1f8  00000000          ori.b    #$0, d0
0101b1fc  00000000          ori.b    #$0, d0
0101b200  00000000          ori.b    #$0, d0
0101b204  00000000          ori.b    #$0, d0
0101b208  00000000          ori.b    #$0, d0
0101b20c  00000000          ori.b    #$0, d0
0101b210  00000000          ori.b    #$0, d0
0101b214  00000000          ori.b    #$0, d0
0101b218  00000000          ori.b    #$0, d0
0101b21c  00000000          ori.b    #$0, d0
0101b220  00000000          ori.b    #$0, d0
0101b224  00000000          ori.b    #$0, d0
0101b228  00000000          ori.b    #$0, d0
0101b22c  00000000          ori.b    #$0, d0
0101b230  00000000          ori.b    #$0, d0
0101b234  00000000          ori.b    #$0, d0
0101b238  00000000          ori.b    #$0, d0
0101b23c  00000000          ori.b    #$0, d0
0101b240  00000000          ori.b    #$0, d0
0101b244  00000000          ori.b    #$0, d0
0101b248  00000000          ori.b    #$0, d0
0101b24c  00000000          ori.b    #$0, d0
0101b250  00000000          ori.b    #$0, d0
0101b254  00000000          ori.b    #$0, d0
0101b258  00000000          ori.b    #$0, d0
0101b25c  00000000          ori.b    #$0, d0
0101b260  00000000          ori.b    #$0, d0
0101b264  00000000          ori.b    #$0, d0
0101b268  00000000          ori.b    #$0, d0
0101b26c  00000000          ori.b    #$0, d0
0101b270  00000000          ori.b    #$0, d0
0101b274  00000000          ori.b    #$0, d0
0101b278  00000000          ori.b    #$0, d0
0101b27c  00000000          ori.b    #$0, d0
0101b280  00000000          ori.b    #$0, d0
0101b284  00000000          ori.b    #$0, d0
0101b288  00000000          ori.b    #$0, d0
0101b28c  00000000          ori.b    #$0, d0
0101b290  00000000          ori.b    #$0, d0
0101b294  00000000          ori.b    #$0, d0
0101b298  00000000          ori.b    #$0, d0
0101b29c  00000000          ori.b    #$0, d0
0101b2a0  00000000          ori.b    #$0, d0
0101b2a4  00000000          ori.b    #$0, d0
0101b2a8  00000000          ori.b    #$0, d0
0101b2ac  00000000          ori.b    #$0, d0
0101b2b0  00000000          ori.b    #$0, d0
0101b2b4  00000000          ori.b    #$0, d0
0101b2b8  00000000          ori.b    #$0, d0
0101b2bc  00000000          ori.b    #$0, d0
0101b2c0  00000000          ori.b    #$0, d0
0101b2c4  00000000          ori.b    #$0, d0
0101b2c8  00000000          ori.b    #$0, d0
0101b2cc  00000000          ori.b    #$0, d0
0101b2d0  00000000          ori.b    #$0, d0
0101b2d4  00000000          ori.b    #$0, d0
0101b2d8  00000000          ori.b    #$0, d0
0101b2dc  00000000          ori.b    #$0, d0
0101b2e0  00000000          ori.b    #$0, d0
0101b2e4  00000000          ori.b    #$0, d0
0101b2e8  00000000          ori.b    #$0, d0
0101b2ec  00000000          ori.b    #$0, d0
0101b2f0  00000000          ori.b    #$0, d0
0101b2f4  00000000          ori.b    #$0, d0
0101b2f8  00000000          ori.b    #$0, d0
0101b2fc  00000000          ori.b    #$0, d0
0101b300  00000000          ori.b    #$0, d0
0101b304  00000000          ori.b    #$0, d0
0101b308  00000000          ori.b    #$0, d0
0101b30c  00000000          ori.b    #$0, d0
0101b310  00000000          ori.b    #$0, d0
0101b314  00000000          ori.b    #$0, d0
0101b318  00000000          ori.b    #$0, d0
0101b31c  00000000          ori.b    #$0, d0
0101b320  00000000          ori.b    #$0, d0
0101b324  00000000          ori.b    #$0, d0
0101b328  00000000          ori.b    #$0, d0
0101b32c  00000000          ori.b    #$0, d0
0101b330  00000000          ori.b    #$0, d0
0101b334  00000000          ori.b    #$0, d0
0101b338  00000000          ori.b    #$0, d0
0101b33c  00000000          ori.b    #$0, d0
0101b340  00000000          ori.b    #$0, d0
0101b344  00000000          ori.b    #$0, d0
0101b348  00000000          ori.b    #$0, d0
0101b34c  00000000          ori.b    #$0, d0
0101b350  00000000          ori.b    #$0, d0
0101b354  00000000          ori.b    #$0, d0
0101b358  00000000          ori.b    #$0, d0
0101b35c  00000000          ori.b    #$0, d0
0101b360  00000000          ori.b    #$0, d0
0101b364  00000000          ori.b    #$0, d0
0101b368  00000000          ori.b    #$0, d0
0101b36c  00000000          ori.b    #$0, d0
0101b370  00000000          ori.b    #$0, d0
0101b374  00000000          ori.b    #$0, d0
0101b378  00000000          ori.b    #$0, d0
0101b37c  00000000          ori.b    #$0, d0
0101b380  00000000          ori.b    #$0, d0
0101b384  00000000          ori.b    #$0, d0
0101b388  00000000          ori.b    #$0, d0
0101b38c  00000000          ori.b    #$0, d0
0101b390  00000000          ori.b    #$0, d0
0101b394  00000000          ori.b    #$0, d0
0101b398  00000000          ori.b    #$0, d0
0101b39c  00000000          ori.b    #$0, d0
0101b3a0  00000000          ori.b    #$0, d0
0101b3a4  00000000          ori.b    #$0, d0
0101b3a8  00000000          ori.b    #$0, d0
0101b3ac  00000000          ori.b    #$0, d0
0101b3b0  00000000          ori.b    #$0, d0
0101b3b4  00000000          ori.b    #$0, d0
0101b3b8  00000000          ori.b    #$0, d0
0101b3bc  00000000          ori.b    #$0, d0
0101b3c0  00000000          ori.b    #$0, d0
0101b3c4  00000000          ori.b    #$0, d0
0101b3c8  00000000          ori.b    #$0, d0
0101b3cc  00000000          ori.b    #$0, d0
0101b3d0  00000000          ori.b    #$0, d0
0101b3d4  00000000          ori.b    #$0, d0
0101b3d8  00000000          ori.b    #$0, d0
0101b3dc  00000000          ori.b    #$0, d0
0101b3e0  00000000          ori.b    #$0, d0
0101b3e4  00000000          ori.b    #$0, d0
0101b3e8  00000000          ori.b    #$0, d0
0101b3ec  00000000          ori.b    #$0, d0
0101b3f0  00000000          ori.b    #$0, d0
0101b3f4  00000000          ori.b    #$0, d0
0101b3f8  00000000          ori.b    #$0, d0
0101b3fc  00000000          ori.b    #$0, d0
0101b400  00000000          ori.b    #$0, d0
0101b404  00000000          ori.b    #$0, d0
0101b408  00000000          ori.b    #$0, d0
0101b40c  00000000          ori.b    #$0, d0
0101b410  00000000          ori.b    #$0, d0
0101b414  00000000          ori.b    #$0, d0
0101b418  00000000          ori.b    #$0, d0
0101b41c  00000000          ori.b    #$0, d0
0101b420  00000000          ori.b    #$0, d0
0101b424  00000000          ori.b    #$0, d0
0101b428  00000000          ori.b    #$0, d0
0101b42c  00000000          ori.b    #$0, d0
0101b430  00000000          ori.b    #$0, d0
0101b434  00000000          ori.b    #$0, d0
0101b438  00000000          ori.b    #$0, d0
0101b43c  00000000          ori.b    #$0, d0
0101b440  00000000          ori.b    #$0, d0
0101b444  00000000          ori.b    #$0, d0
0101b448  00000000          ori.b    #$0, d0
0101b44c  00000000          ori.b    #$0, d0
0101b450  00000000          ori.b    #$0, d0
0101b454  00000000          ori.b    #$0, d0
0101b458  00000000          ori.b    #$0, d0
0101b45c  00000000          ori.b    #$0, d0
0101b460  00000000          ori.b    #$0, d0
0101b464  00000000          ori.b    #$0, d0
0101b468  00000000          ori.b    #$0, d0
0101b46c  00000000          ori.b    #$0, d0
0101b470  00000000          ori.b    #$0, d0
0101b474  00000000          ori.b    #$0, d0
0101b478  00000000          ori.b    #$0, d0
0101b47c  00000000          ori.b    #$0, d0
0101b480  00000000          ori.b    #$0, d0
0101b484  00000000          ori.b    #$0, d0
0101b488  00000000          ori.b    #$0, d0
0101b48c  00000000          ori.b    #$0, d0
0101b490  00000000          ori.b    #$0, d0
0101b494  00000000          ori.b    #$0, d0
0101b498  00000000          ori.b    #$0, d0
0101b49c  00000000          ori.b    #$0, d0
0101b4a0  00000000          ori.b    #$0, d0
0101b4a4  00000000          ori.b    #$0, d0
0101b4a8  00000000          ori.b    #$0, d0
0101b4ac  00000000          ori.b    #$0, d0
0101b4b0  00000000          ori.b    #$0, d0
0101b4b4  00000000          ori.b    #$0, d0
0101b4b8  00000000          ori.b    #$0, d0
0101b4bc  00000000          ori.b    #$0, d0
0101b4c0  00000000          ori.b    #$0, d0
0101b4c4  00000000          ori.b    #$0, d0
0101b4c8  00000000          ori.b    #$0, d0
0101b4cc  00000000          ori.b    #$0, d0
0101b4d0  00000000          ori.b    #$0, d0
0101b4d4  00000000          ori.b    #$0, d0
0101b4d8  00000000          ori.b    #$0, d0
0101b4dc  00000000          ori.b    #$0, d0
0101b4e0  00000000          ori.b    #$0, d0
0101b4e4  00000000          ori.b    #$0, d0
0101b4e8  00000000          ori.b    #$0, d0
0101b4ec  00000000          ori.b    #$0, d0
0101b4f0  00000000          ori.b    #$0, d0
0101b4f4  00000000          ori.b    #$0, d0
0101b4f8  00000000          ori.b    #$0, d0
0101b4fc  00000000          ori.b    #$0, d0
0101b500  00000000          ori.b    #$0, d0
0101b504  00000000          ori.b    #$0, d0
0101b508  00000000          ori.b    #$0, d0
0101b50c  00000000          ori.b    #$0, d0
0101b510  00000000          ori.b    #$0, d0
0101b514  00000000          ori.b    #$0, d0
0101b518  00000000          ori.b    #$0, d0
0101b51c  00000000          ori.b    #$0, d0
0101b520  00000000          ori.b    #$0, d0
0101b524  00000000          ori.b    #$0, d0
0101b528  00000000          ori.b    #$0, d0
0101b52c  00000000          ori.b    #$0, d0
0101b530  00000000          ori.b    #$0, d0
0101b534  00000000          ori.b    #$0, d0
0101b538  00000000          ori.b    #$0, d0
0101b53c  00000000          ori.b    #$0, d0
0101b540  00000000          ori.b    #$0, d0
0101b544  00000000          ori.b    #$0, d0
0101b548  00000000          ori.b    #$0, d0
0101b54c  00000000          ori.b    #$0, d0
0101b550  00000000          ori.b    #$0, d0
0101b554  00000000          ori.b    #$0, d0
0101b558  00000000          ori.b    #$0, d0
0101b55c  00000000          ori.b    #$0, d0
0101b560  00000000          ori.b    #$0, d0
0101b564  00000000          ori.b    #$0, d0
0101b568  00000000          ori.b    #$0, d0
0101b56c  00000000          ori.b    #$0, d0
0101b570  00000000          ori.b    #$0, d0
0101b574  00000000          ori.b    #$0, d0
0101b578  00000000          ori.b    #$0, d0
0101b57c  00000000          ori.b    #$0, d0
0101b580  00000000          ori.b    #$0, d0
0101b584  00000000          ori.b    #$0, d0
0101b588  00000000          ori.b    #$0, d0
0101b58c  00000000          ori.b    #$0, d0
0101b590  00000000          ori.b    #$0, d0
0101b594  00000000          ori.b    #$0, d0
0101b598  00000000          ori.b    #$0, d0
0101b59c  00000000          ori.b    #$0, d0
0101b5a0  00000000          ori.b    #$0, d0
0101b5a4  00000000          ori.b    #$0, d0
0101b5a8  00000000          ori.b    #$0, d0
0101b5ac  00000000          ori.b    #$0, d0
0101b5b0  00000000          ori.b    #$0, d0
0101b5b4  00000000          ori.b    #$0, d0
0101b5b8  00000000          ori.b    #$0, d0
0101b5bc  00000000          ori.b    #$0, d0
0101b5c0  00000000          ori.b    #$0, d0
0101b5c4  00000000          ori.b    #$0, d0
0101b5c8  00000000          ori.b    #$0, d0
0101b5cc  00000000          ori.b    #$0, d0
0101b5d0  00000000          ori.b    #$0, d0
0101b5d4  00000000          ori.b    #$0, d0
0101b5d8  00000000          ori.b    #$0, d0
0101b5dc  00000000          ori.b    #$0, d0
0101b5e0  00000000          ori.b    #$0, d0
0101b5e4  00000000          ori.b    #$0, d0
0101b5e8  00000000          ori.b    #$0, d0
0101b5ec  00000000          ori.b    #$0, d0
0101b5f0  00000000          ori.b    #$0, d0
0101b5f4  00000000          ori.b    #$0, d0
0101b5f8  00000000          ori.b    #$0, d0
0101b5fc  00000000          ori.b    #$0, d0
0101b600  00000000          ori.b    #$0, d0
0101b604  00000000          ori.b    #$0, d0
0101b608  00000000          ori.b    #$0, d0
0101b60c  00000000          ori.b    #$0, d0
0101b610  00000000          ori.b    #$0, d0
0101b614  00000000          ori.b    #$0, d0
0101b618  00000000          ori.b    #$0, d0
0101b61c  00000000          ori.b    #$0, d0
0101b620  00000000          ori.b    #$0, d0
0101b624  00000000          ori.b    #$0, d0
0101b628  00000000          ori.b    #$0, d0
0101b62c  00000000          ori.b    #$0, d0
0101b630  00000000          ori.b    #$0, d0
0101b634  00000000          ori.b    #$0, d0
0101b638  00000000          ori.b    #$0, d0
0101b63c  00000000          ori.b    #$0, d0
0101b640  00000000          ori.b    #$0, d0
0101b644  00000000          ori.b    #$0, d0
0101b648  00000000          ori.b    #$0, d0
0101b64c  00000000          ori.b    #$0, d0
0101b650  00000000          ori.b    #$0, d0
0101b654  00000000          ori.b    #$0, d0
0101b658  00000000          ori.b    #$0, d0
0101b65c  00000000          ori.b    #$0, d0
0101b660  00000000          ori.b    #$0, d0
0101b664  00000000          ori.b    #$0, d0
0101b668  00000000          ori.b    #$0, d0
0101b66c  00000000          ori.b    #$0, d0
0101b670  00000000          ori.b    #$0, d0
0101b674  00000000          ori.b    #$0, d0
0101b678  00000000          ori.b    #$0, d0
0101b67c  00000000          ori.b    #$0, d0
0101b680  00000000          ori.b    #$0, d0
0101b684  00000000          ori.b    #$0, d0
0101b688  00000000          ori.b    #$0, d0
0101b68c  00000000          ori.b    #$0, d0
0101b690  00000000          ori.b    #$0, d0
0101b694  00000000          ori.b    #$0, d0
0101b698  00000000          ori.b    #$0, d0
0101b69c  00000000          ori.b    #$0, d0
0101b6a0  00000000          ori.b    #$0, d0
0101b6a4  00000000          ori.b    #$0, d0
0101b6a8  00000000          ori.b    #$0, d0
0101b6ac  00000000          ori.b    #$0, d0
0101b6b0  00000000          ori.b    #$0, d0
0101b6b4  00000000          ori.b    #$0, d0
0101b6b8  00000000          ori.b    #$0, d0
0101b6bc  00000000          ori.b    #$0, d0
0101b6c0  00000000          ori.b    #$0, d0
0101b6c4  00000000          ori.b    #$0, d0
0101b6c8  00000000          ori.b    #$0, d0
0101b6cc  00000000          ori.b    #$0, d0
0101b6d0  00000000          ori.b    #$0, d0
0101b6d4  00000000          ori.b    #$0, d0
0101b6d8  00000000          ori.b    #$0, d0
0101b6dc  00000000          ori.b    #$0, d0
0101b6e0  00000000          ori.b    #$0, d0
0101b6e4  00000000          ori.b    #$0, d0
0101b6e8  00000000          ori.b    #$0, d0
0101b6ec  00000000          ori.b    #$0, d0
0101b6f0  00000000          ori.b    #$0, d0
0101b6f4  00000000          ori.b    #$0, d0
0101b6f8  00000000          ori.b    #$0, d0
0101b6fc  00000000          ori.b    #$0, d0
0101b700  00000000          ori.b    #$0, d0
0101b704  00000000          ori.b    #$0, d0
0101b708  00000000          ori.b    #$0, d0
0101b70c  00000000          ori.b    #$0, d0
0101b710  00000000          ori.b    #$0, d0
0101b714  00000000          ori.b    #$0, d0
0101b718  00000000          ori.b    #$0, d0
0101b71c  00000000          ori.b    #$0, d0
0101b720  00000000          ori.b    #$0, d0
0101b724  00000000          ori.b    #$0, d0
0101b728  00000000          ori.b    #$0, d0
0101b72c  00000000          ori.b    #$0, d0
0101b730  00000000          ori.b    #$0, d0
0101b734  00000000          ori.b    #$0, d0
0101b738  00000000          ori.b    #$0, d0
0101b73c  00000000          ori.b    #$0, d0
0101b740  00000000          ori.b    #$0, d0
0101b744  00000000          ori.b    #$0, d0
0101b748  00000000          ori.b    #$0, d0
0101b74c  00000000          ori.b    #$0, d0
0101b750  00000000          ori.b    #$0, d0
0101b754  00000000          ori.b    #$0, d0
0101b758  00000000          ori.b    #$0, d0
0101b75c  00000000          ori.b    #$0, d0
0101b760  00000000          ori.b    #$0, d0
0101b764  00000000          ori.b    #$0, d0
0101b768  00000000          ori.b    #$0, d0
0101b76c  00000000          ori.b    #$0, d0
0101b770  00000000          ori.b    #$0, d0
0101b774  00000000          ori.b    #$0, d0
0101b778  00000000          ori.b    #$0, d0
0101b77c  00000000          ori.b    #$0, d0
0101b780  00000000          ori.b    #$0, d0
0101b784  00000000          ori.b    #$0, d0
0101b788  00000000          ori.b    #$0, d0
0101b78c  00000000          ori.b    #$0, d0
0101b790  00000000          ori.b    #$0, d0
0101b794  00000000          ori.b    #$0, d0
0101b798  00000000          ori.b    #$0, d0
0101b79c  00000000          ori.b    #$0, d0
0101b7a0  00000000          ori.b    #$0, d0
0101b7a4  00000000          ori.b    #$0, d0
0101b7a8  00000000          ori.b    #$0, d0
0101b7ac  00000000          ori.b    #$0, d0
0101b7b0  00000000          ori.b    #$0, d0
0101b7b4  00000000          ori.b    #$0, d0
0101b7b8  00000000          ori.b    #$0, d0
0101b7bc  00000000          ori.b    #$0, d0
0101b7c0  00000000          ori.b    #$0, d0
0101b7c4  00000000          ori.b    #$0, d0
0101b7c8  00000000          ori.b    #$0, d0
0101b7cc  00000000          ori.b    #$0, d0
0101b7d0  00000000          ori.b    #$0, d0
0101b7d4  00000000          ori.b    #$0, d0
0101b7d8  00000000          ori.b    #$0, d0
0101b7dc  00000000          ori.b    #$0, d0
0101b7e0  00000000          ori.b    #$0, d0
0101b7e4  00000000          ori.b    #$0, d0
0101b7e8  00000000          ori.b    #$0, d0
0101b7ec  00000000          ori.b    #$0, d0
0101b7f0  00000000          ori.b    #$0, d0
0101b7f4  00000000          ori.b    #$0, d0
0101b7f8  00000000          ori.b    #$0, d0
0101b7fc  00000000          ori.b    #$0, d0
0101b800  00000000          ori.b    #$0, d0
0101b804  00000000          ori.b    #$0, d0
0101b808  00000000          ori.b    #$0, d0
0101b80c  00000000          ori.b    #$0, d0
0101b810  00000000          ori.b    #$0, d0
0101b814  00000000          ori.b    #$0, d0
0101b818  00000000          ori.b    #$0, d0
0101b81c  00000000          ori.b    #$0, d0
0101b820  00000000          ori.b    #$0, d0
0101b824  00000000          ori.b    #$0, d0
0101b828  00000000          ori.b    #$0, d0
0101b82c  00000000          ori.b    #$0, d0
0101b830  00000000          ori.b    #$0, d0
0101b834  00000000          ori.b    #$0, d0
0101b838  00000000          ori.b    #$0, d0
0101b83c  00000000          ori.b    #$0, d0
0101b840  00000000          ori.b    #$0, d0
0101b844  00000000          ori.b    #$0, d0
0101b848  00000000          ori.b    #$0, d0
0101b84c  00000000          ori.b    #$0, d0
0101b850  00000000          ori.b    #$0, d0
0101b854  00000000          ori.b    #$0, d0
0101b858  00000000          ori.b    #$0, d0
0101b85c  00000000          ori.b    #$0, d0
0101b860  00000000          ori.b    #$0, d0
0101b864  00000000          ori.b    #$0, d0
0101b868  00000000          ori.b    #$0, d0
0101b86c  00000000          ori.b    #$0, d0
0101b870  00000000          ori.b    #$0, d0
0101b874  00000000          ori.b    #$0, d0
0101b878  00000000          ori.b    #$0, d0
0101b87c  00000000          ori.b    #$0, d0
0101b880  00000000          ori.b    #$0, d0
0101b884  00000000          ori.b    #$0, d0
0101b888  00000000          ori.b    #$0, d0
0101b88c  00000000          ori.b    #$0, d0
0101b890  00000000          ori.b    #$0, d0
0101b894  00000000          ori.b    #$0, d0
0101b898  00000000          ori.b    #$0, d0
0101b89c  00000000          ori.b    #$0, d0
0101b8a0  00000000          ori.b    #$0, d0
0101b8a4  00000000          ori.b    #$0, d0
0101b8a8  00000000          ori.b    #$0, d0
0101b8ac  00000000          ori.b    #$0, d0
0101b8b0  00000000          ori.b    #$0, d0
0101b8b4  00000000          ori.b    #$0, d0
0101b8b8  00000000          ori.b    #$0, d0
0101b8bc  00000000          ori.b    #$0, d0
0101b8c0  00000000          ori.b    #$0, d0
0101b8c4  00000000          ori.b    #$0, d0
0101b8c8  00000000          ori.b    #$0, d0
0101b8cc  00000000          ori.b    #$0, d0
0101b8d0  00000000          ori.b    #$0, d0
0101b8d4  00000000          ori.b    #$0, d0
0101b8d8  00000000          ori.b    #$0, d0
0101b8dc  00000000          ori.b    #$0, d0
0101b8e0  00000000          ori.b    #$0, d0
0101b8e4  00000000          ori.b    #$0, d0
0101b8e8  00000000          ori.b    #$0, d0
0101b8ec  00000000          ori.b    #$0, d0
0101b8f0  00000000          ori.b    #$0, d0
0101b8f4  00000000          ori.b    #$0, d0
0101b8f8  00000000          ori.b    #$0, d0
0101b8fc  00000000          ori.b    #$0, d0
0101b900  00000000          ori.b    #$0, d0
0101b904  00000000          ori.b    #$0, d0
0101b908  00000000          ori.b    #$0, d0
0101b90c  00000000          ori.b    #$0, d0
0101b910  00000000          ori.b    #$0, d0
0101b914  00000000          ori.b    #$0, d0
0101b918  00000000          ori.b    #$0, d0
0101b91c  00000000          ori.b    #$0, d0
0101b920  00000000          ori.b    #$0, d0
0101b924  00000000          ori.b    #$0, d0
0101b928  00000000          ori.b    #$0, d0
0101b92c  00000000          ori.b    #$0, d0
0101b930  00000000          ori.b    #$0, d0
0101b934  00000000          ori.b    #$0, d0
0101b938  00000000          ori.b    #$0, d0
0101b93c  00000000          ori.b    #$0, d0
0101b940  00000000          ori.b    #$0, d0
0101b944  00000000          ori.b    #$0, d0
0101b948  00000000          ori.b    #$0, d0
0101b94c  00000000          ori.b    #$0, d0
0101b950  00000000          ori.b    #$0, d0
0101b954  00000000          ori.b    #$0, d0
0101b958  00000000          ori.b    #$0, d0
0101b95c  00000000          ori.b    #$0, d0
0101b960  00000000          ori.b    #$0, d0
0101b964  00000000          ori.b    #$0, d0
0101b968  00000000          ori.b    #$0, d0
0101b96c  00000000          ori.b    #$0, d0
0101b970  00000000          ori.b    #$0, d0
0101b974  00000000          ori.b    #$0, d0
0101b978  00000000          ori.b    #$0, d0
0101b97c  00000000          ori.b    #$0, d0
0101b980  00000000          ori.b    #$0, d0
0101b984  00000000          ori.b    #$0, d0
0101b988  00000000          ori.b    #$0, d0
0101b98c  00000000          ori.b    #$0, d0
0101b990  00000000          ori.b    #$0, d0
0101b994  00000000          ori.b    #$0, d0
0101b998  00000000          ori.b    #$0, d0
0101b99c  00000000          ori.b    #$0, d0
0101b9a0  00000000          ori.b    #$0, d0
0101b9a4  00000000          ori.b    #$0, d0
0101b9a8  00000000          ori.b    #$0, d0
0101b9ac  00000000          ori.b    #$0, d0
0101b9b0  00000000          ori.b    #$0, d0
0101b9b4  00000000          ori.b    #$0, d0
0101b9b8  00000000          ori.b    #$0, d0
0101b9bc  00000000          ori.b    #$0, d0
0101b9c0  00000000          ori.b    #$0, d0
0101b9c4  00000000          ori.b    #$0, d0
0101b9c8  00000000          ori.b    #$0, d0
0101b9cc  00000000          ori.b    #$0, d0
0101b9d0  00000000          ori.b    #$0, d0
0101b9d4  00000000          ori.b    #$0, d0
0101b9d8  00000000          ori.b    #$0, d0
0101b9dc  00000000          ori.b    #$0, d0
0101b9e0  00000000          ori.b    #$0, d0
0101b9e4  00000000          ori.b    #$0, d0
0101b9e8  00000000          ori.b    #$0, d0
0101b9ec  00000000          ori.b    #$0, d0
0101b9f0  00000000          ori.b    #$0, d0
0101b9f4  00000000          ori.b    #$0, d0
0101b9f8  00000000          ori.b    #$0, d0
0101b9fc  00000000          ori.b    #$0, d0
0101ba00  00000000          ori.b    #$0, d0
0101ba04  00000000          ori.b    #$0, d0
0101ba08  00000000          ori.b    #$0, d0
0101ba0c  00000000          ori.b    #$0, d0
0101ba10  00000000          ori.b    #$0, d0
0101ba14  00000000          ori.b    #$0, d0
0101ba18  00000000          ori.b    #$0, d0
0101ba1c  00000000          ori.b    #$0, d0
0101ba20  00000000          ori.b    #$0, d0
0101ba24  00000000          ori.b    #$0, d0
0101ba28  00000000          ori.b    #$0, d0
0101ba2c  00000000          ori.b    #$0, d0
0101ba30  00000000          ori.b    #$0, d0
0101ba34  00000000          ori.b    #$0, d0
0101ba38  00000000          ori.b    #$0, d0
0101ba3c  00000000          ori.b    #$0, d0
0101ba40  00000000          ori.b    #$0, d0
0101ba44  00000000          ori.b    #$0, d0
0101ba48  00000000          ori.b    #$0, d0
0101ba4c  00000000          ori.b    #$0, d0
0101ba50  00000000          ori.b    #$0, d0
0101ba54  00000000          ori.b    #$0, d0
0101ba58  00000000          ori.b    #$0, d0
0101ba5c  00000000          ori.b    #$0, d0
0101ba60  00000000          ori.b    #$0, d0
0101ba64  00000000          ori.b    #$0, d0
0101ba68  00000000          ori.b    #$0, d0
0101ba6c  00000000          ori.b    #$0, d0
0101ba70  00000000          ori.b    #$0, d0
0101ba74  00000000          ori.b    #$0, d0
0101ba78  00000000          ori.b    #$0, d0
0101ba7c  00000000          ori.b    #$0, d0
0101ba80  00000000          ori.b    #$0, d0
0101ba84  00000000          ori.b    #$0, d0
0101ba88  00000000          ori.b    #$0, d0
0101ba8c  00000000          ori.b    #$0, d0
0101ba90  00000000          ori.b    #$0, d0
0101ba94  00000000          ori.b    #$0, d0
0101ba98  00000000          ori.b    #$0, d0
0101ba9c  00000000          ori.b    #$0, d0
0101baa0  00000000          ori.b    #$0, d0
0101baa4  00000000          ori.b    #$0, d0
0101baa8  00000000          ori.b    #$0, d0
0101baac  00000000          ori.b    #$0, d0
0101bab0  00000000          ori.b    #$0, d0
0101bab4  00000000          ori.b    #$0, d0
0101bab8  00000000          ori.b    #$0, d0
0101babc  00000000          ori.b    #$0, d0
0101bac0  00000000          ori.b    #$0, d0
0101bac4  00000000          ori.b    #$0, d0
0101bac8  00000000          ori.b    #$0, d0
0101bacc  00000000          ori.b    #$0, d0
0101bad0  00000000          ori.b    #$0, d0
0101bad4  00000000          ori.b    #$0, d0
0101bad8  00000000          ori.b    #$0, d0
0101badc  00000000          ori.b    #$0, d0
0101bae0  00000000          ori.b    #$0, d0
0101bae4  00000000          ori.b    #$0, d0
0101bae8  00000000          ori.b    #$0, d0
0101baec  00000000          ori.b    #$0, d0
0101baf0  00000000          ori.b    #$0, d0
0101baf4  00000000          ori.b    #$0, d0
0101baf8  00000000          ori.b    #$0, d0
0101bafc  00000000          ori.b    #$0, d0
0101bb00  00000000          ori.b    #$0, d0
0101bb04  00000000          ori.b    #$0, d0
0101bb08  00000000          ori.b    #$0, d0
0101bb0c  00000000          ori.b    #$0, d0
0101bb10  00000000          ori.b    #$0, d0
0101bb14  00000000          ori.b    #$0, d0
0101bb18  00000000          ori.b    #$0, d0
0101bb1c  00000000          ori.b    #$0, d0
0101bb20  00000000          ori.b    #$0, d0
0101bb24  00000000          ori.b    #$0, d0
0101bb28  00000000          ori.b    #$0, d0
0101bb2c  00000000          ori.b    #$0, d0
0101bb30  00000000          ori.b    #$0, d0
0101bb34  00000000          ori.b    #$0, d0
0101bb38  00000000          ori.b    #$0, d0
0101bb3c  00000000          ori.b    #$0, d0
0101bb40  00000000          ori.b    #$0, d0
0101bb44  00000000          ori.b    #$0, d0
0101bb48  00000000          ori.b    #$0, d0
0101bb4c  00000000          ori.b    #$0, d0
0101bb50  00000000          ori.b    #$0, d0
0101bb54  00000000          ori.b    #$0, d0
0101bb58  00000000          ori.b    #$0, d0
0101bb5c  00000000          ori.b    #$0, d0
0101bb60  00000000          ori.b    #$0, d0
0101bb64  00000000          ori.b    #$0, d0
0101bb68  00000000          ori.b    #$0, d0
0101bb6c  00000000          ori.b    #$0, d0
0101bb70  00000000          ori.b    #$0, d0
0101bb74  00000000          ori.b    #$0, d0
0101bb78  00000000          ori.b    #$0, d0
0101bb7c  00000000          ori.b    #$0, d0
0101bb80  00000000          ori.b    #$0, d0
0101bb84  00000000          ori.b    #$0, d0
0101bb88  00000000          ori.b    #$0, d0
0101bb8c  00000000          ori.b    #$0, d0
0101bb90  00000000          ori.b    #$0, d0
0101bb94  00000000          ori.b    #$0, d0
0101bb98  00000000          ori.b    #$0, d0
0101bb9c  00000000          ori.b    #$0, d0
0101bba0  00000000          ori.b    #$0, d0
0101bba4  00000000          ori.b    #$0, d0
0101bba8  00000000          ori.b    #$0, d0
0101bbac  00000000          ori.b    #$0, d0
0101bbb0  00000000          ori.b    #$0, d0
0101bbb4  00000000          ori.b    #$0, d0
0101bbb8  00000000          ori.b    #$0, d0
0101bbbc  00000000          ori.b    #$0, d0
0101bbc0  00000000          ori.b    #$0, d0
0101bbc4  00000000          ori.b    #$0, d0
0101bbc8  00000000          ori.b    #$0, d0
0101bbcc  00000000          ori.b    #$0, d0
0101bbd0  00000000          ori.b    #$0, d0
0101bbd4  00000000          ori.b    #$0, d0
0101bbd8  00000000          ori.b    #$0, d0
0101bbdc  00000000          ori.b    #$0, d0
0101bbe0  00000000          ori.b    #$0, d0
0101bbe4  00000000          ori.b    #$0, d0
0101bbe8  00000000          ori.b    #$0, d0
0101bbec  00000000          ori.b    #$0, d0
0101bbf0  00000000          ori.b    #$0, d0
0101bbf4  00000000          ori.b    #$0, d0
0101bbf8  00000000          ori.b    #$0, d0
0101bbfc  00000000          ori.b    #$0, d0
0101bc00  00000000          ori.b    #$0, d0
0101bc04  00000000          ori.b    #$0, d0
0101bc08  00000000          ori.b    #$0, d0
0101bc0c  00000000          ori.b    #$0, d0
0101bc10  00000000          ori.b    #$0, d0
0101bc14  00000000          ori.b    #$0, d0
0101bc18  00000000          ori.b    #$0, d0
0101bc1c  00000000          ori.b    #$0, d0
0101bc20  00000000          ori.b    #$0, d0
0101bc24  00000000          ori.b    #$0, d0
0101bc28  00000000          ori.b    #$0, d0
0101bc2c  00000000          ori.b    #$0, d0
0101bc30  00000000          ori.b    #$0, d0
0101bc34  00000000          ori.b    #$0, d0
0101bc38  00000000          ori.b    #$0, d0
0101bc3c  00000000          ori.b    #$0, d0
0101bc40  00000000          ori.b    #$0, d0
0101bc44  00000000          ori.b    #$0, d0
0101bc48  00000000          ori.b    #$0, d0
0101bc4c  00000000          ori.b    #$0, d0
0101bc50  00000000          ori.b    #$0, d0
0101bc54  00000000          ori.b    #$0, d0
0101bc58  00000000          ori.b    #$0, d0
0101bc5c  00000000          ori.b    #$0, d0
0101bc60  00000000          ori.b    #$0, d0
0101bc64  00000000          ori.b    #$0, d0
0101bc68  00000000          ori.b    #$0, d0
0101bc6c  00000000          ori.b    #$0, d0
0101bc70  00000000          ori.b    #$0, d0
0101bc74  00000000          ori.b    #$0, d0
0101bc78  00000000          ori.b    #$0, d0
0101bc7c  00000000          ori.b    #$0, d0
0101bc80  00000000          ori.b    #$0, d0
0101bc84  00000000          ori.b    #$0, d0
0101bc88  00000000          ori.b    #$0, d0
0101bc8c  00000000          ori.b    #$0, d0
0101bc90  00000000          ori.b    #$0, d0
0101bc94  00000000          ori.b    #$0, d0
0101bc98  00000000          ori.b    #$0, d0
0101bc9c  00000000          ori.b    #$0, d0
0101bca0  00000000          ori.b    #$0, d0
0101bca4  00000000          ori.b    #$0, d0
0101bca8  00000000          ori.b    #$0, d0
0101bcac  00000000          ori.b    #$0, d0
0101bcb0  00000000          ori.b    #$0, d0
0101bcb4  00000000          ori.b    #$0, d0
0101bcb8  00000000          ori.b    #$0, d0
0101bcbc  00000000          ori.b    #$0, d0
0101bcc0  00000000          ori.b    #$0, d0
0101bcc4  00000000          ori.b    #$0, d0
0101bcc8  00000000          ori.b    #$0, d0
0101bccc  00000000          ori.b    #$0, d0
0101bcd0  00000000          ori.b    #$0, d0
0101bcd4  00000000          ori.b    #$0, d0
0101bcd8  00000000          ori.b    #$0, d0
0101bcdc  00000000          ori.b    #$0, d0
0101bce0  00000000          ori.b    #$0, d0
0101bce4  00000000          ori.b    #$0, d0
0101bce8  00000000          ori.b    #$0, d0
0101bcec  00000000          ori.b    #$0, d0
0101bcf0  00000000          ori.b    #$0, d0
0101bcf4  00000000          ori.b    #$0, d0
0101bcf8  00000000          ori.b    #$0, d0
0101bcfc  00000000          ori.b    #$0, d0
0101bd00  00000000          ori.b    #$0, d0
0101bd04  00000000          ori.b    #$0, d0
0101bd08  00000000          ori.b    #$0, d0
0101bd0c  00000000          ori.b    #$0, d0
0101bd10  00000000          ori.b    #$0, d0
0101bd14  00000000          ori.b    #$0, d0
0101bd18  00000000          ori.b    #$0, d0
0101bd1c  00000000          ori.b    #$0, d0
0101bd20  00000000          ori.b    #$0, d0
0101bd24  00000000          ori.b    #$0, d0
0101bd28  00000000          ori.b    #$0, d0
0101bd2c  00000000          ori.b    #$0, d0
0101bd30  00000000          ori.b    #$0, d0
0101bd34  00000000          ori.b    #$0, d0
0101bd38  00000000          ori.b    #$0, d0
0101bd3c  00000000          ori.b    #$0, d0
0101bd40  00000000          ori.b    #$0, d0
0101bd44  00000000          ori.b    #$0, d0
0101bd48  00000000          ori.b    #$0, d0
0101bd4c  00000000          ori.b    #$0, d0
0101bd50  00000000          ori.b    #$0, d0
0101bd54  00000000          ori.b    #$0, d0
0101bd58  00000000          ori.b    #$0, d0
0101bd5c  00000000          ori.b    #$0, d0
0101bd60  00000000          ori.b    #$0, d0
0101bd64  00000000          ori.b    #$0, d0
0101bd68  00000000          ori.b    #$0, d0
0101bd6c  00000000          ori.b    #$0, d0
0101bd70  00000000          ori.b    #$0, d0
0101bd74  00000000          ori.b    #$0, d0
0101bd78  00000000          ori.b    #$0, d0
0101bd7c  00000000          ori.b    #$0, d0
0101bd80  00000000          ori.b    #$0, d0
0101bd84  00000000          ori.b    #$0, d0
0101bd88  00000000          ori.b    #$0, d0
0101bd8c  00000000          ori.b    #$0, d0
0101bd90  00000000          ori.b    #$0, d0
0101bd94  00000000          ori.b    #$0, d0
0101bd98  00000000          ori.b    #$0, d0
0101bd9c  00000000          ori.b    #$0, d0
0101bda0  00000000          ori.b    #$0, d0
0101bda4  00000000          ori.b    #$0, d0
0101bda8  00000000          ori.b    #$0, d0
0101bdac  00000000          ori.b    #$0, d0
0101bdb0  00000000          ori.b    #$0, d0
0101bdb4  00000000          ori.b    #$0, d0
0101bdb8  00000000          ori.b    #$0, d0
0101bdbc  00000000          ori.b    #$0, d0
0101bdc0  00000000          ori.b    #$0, d0
0101bdc4  00000000          ori.b    #$0, d0
0101bdc8  00000000          ori.b    #$0, d0
0101bdcc  00000000          ori.b    #$0, d0
0101bdd0  00000000          ori.b    #$0, d0
0101bdd4  00000000          ori.b    #$0, d0
0101bdd8  00000000          ori.b    #$0, d0
0101bddc  00000000          ori.b    #$0, d0
0101bde0  00000000          ori.b    #$0, d0
0101bde4  00000000          ori.b    #$0, d0
0101bde8  00000000          ori.b    #$0, d0
0101bdec  00000000          ori.b    #$0, d0
0101bdf0  00000000          ori.b    #$0, d0
0101bdf4  00000000          ori.b    #$0, d0
0101bdf8  00000000          ori.b    #$0, d0
0101bdfc  00000000          ori.b    #$0, d0
0101be00  00000000          ori.b    #$0, d0
0101be04  00000000          ori.b    #$0, d0
0101be08  00000000          ori.b    #$0, d0
0101be0c  00000000          ori.b    #$0, d0
0101be10  00000000          ori.b    #$0, d0
0101be14  00000000          ori.b    #$0, d0
0101be18  00000000          ori.b    #$0, d0
0101be1c  00000000          ori.b    #$0, d0
0101be20  00000000          ori.b    #$0, d0
0101be24  00000000          ori.b    #$0, d0
0101be28  00000000          ori.b    #$0, d0
0101be2c  00000000          ori.b    #$0, d0
0101be30  00000000          ori.b    #$0, d0
0101be34  00000000          ori.b    #$0, d0
0101be38  00000000          ori.b    #$0, d0
0101be3c  00000000          ori.b    #$0, d0
0101be40  00000000          ori.b    #$0, d0
0101be44  00000000          ori.b    #$0, d0
0101be48  00000000          ori.b    #$0, d0
0101be4c  00000000          ori.b    #$0, d0
0101be50  00000000          ori.b    #$0, d0
0101be54  00000000          ori.b    #$0, d0
0101be58  00000000          ori.b    #$0, d0
0101be5c  00000000          ori.b    #$0, d0
0101be60  00000000          ori.b    #$0, d0
0101be64  00000000          ori.b    #$0, d0
0101be68  00000000          ori.b    #$0, d0
0101be6c  00000000          ori.b    #$0, d0
0101be70  00000000          ori.b    #$0, d0
0101be74  00000000          ori.b    #$0, d0
0101be78  00000000          ori.b    #$0, d0
0101be7c  00000000          ori.b    #$0, d0
0101be80  00000000          ori.b    #$0, d0
0101be84  00000000          ori.b    #$0, d0
0101be88  00000000          ori.b    #$0, d0
0101be8c  00000000          ori.b    #$0, d0
0101be90  00000000          ori.b    #$0, d0
0101be94  00000000          ori.b    #$0, d0
0101be98  00000000          ori.b    #$0, d0
0101be9c  00000000          ori.b    #$0, d0
0101bea0  00000000          ori.b    #$0, d0
0101bea4  00000000          ori.b    #$0, d0
0101bea8  00000000          ori.b    #$0, d0
0101beac  00000000          ori.b    #$0, d0
0101beb0  00000000          ori.b    #$0, d0
0101beb4  00000000          ori.b    #$0, d0
0101beb8  00000000          ori.b    #$0, d0
0101bebc  00000000          ori.b    #$0, d0
0101bec0  00000000          ori.b    #$0, d0
0101bec4  00000000          ori.b    #$0, d0
0101bec8  00000000          ori.b    #$0, d0
0101becc  00000000          ori.b    #$0, d0
0101bed0  00000000          ori.b    #$0, d0
0101bed4  00000000          ori.b    #$0, d0
0101bed8  00000000          ori.b    #$0, d0
0101bedc  00000000          ori.b    #$0, d0
0101bee0  00000000          ori.b    #$0, d0
0101bee4  00000000          ori.b    #$0, d0
0101bee8  00000000          ori.b    #$0, d0
0101beec  00000000          ori.b    #$0, d0
0101bef0  00000000          ori.b    #$0, d0
0101bef4  00000000          ori.b    #$0, d0
0101bef8  00000000          ori.b    #$0, d0
0101befc  00000000          ori.b    #$0, d0
0101bf00  00000000          ori.b    #$0, d0
0101bf04  00000000          ori.b    #$0, d0
0101bf08  00000000          ori.b    #$0, d0
0101bf0c  00000000          ori.b    #$0, d0
0101bf10  00000000          ori.b    #$0, d0
0101bf14  00000000          ori.b    #$0, d0
0101bf18  00000000          ori.b    #$0, d0
0101bf1c  00000000          ori.b    #$0, d0
0101bf20  00000000          ori.b    #$0, d0
0101bf24  00000000          ori.b    #$0, d0
0101bf28  00000000          ori.b    #$0, d0
0101bf2c  00000000          ori.b    #$0, d0
0101bf30  00000000          ori.b    #$0, d0
0101bf34  00000000          ori.b    #$0, d0
0101bf38  00000000          ori.b    #$0, d0
0101bf3c  00000000          ori.b    #$0, d0
0101bf40  00000000          ori.b    #$0, d0
0101bf44  00000000          ori.b    #$0, d0
0101bf48  00000000          ori.b    #$0, d0
0101bf4c  00000000          ori.b    #$0, d0
0101bf50  00000000          ori.b    #$0, d0
0101bf54  00000000          ori.b    #$0, d0
0101bf58  00000000          ori.b    #$0, d0
0101bf5c  00000000          ori.b    #$0, d0
0101bf60  00000000          ori.b    #$0, d0
0101bf64  00000000          ori.b    #$0, d0
0101bf68  00000000          ori.b    #$0, d0
0101bf6c  00000000          ori.b    #$0, d0
0101bf70  00000000          ori.b    #$0, d0
0101bf74  00000000          ori.b    #$0, d0
0101bf78  00000000          ori.b    #$0, d0
0101bf7c  00000000          ori.b    #$0, d0
0101bf80  00000000          ori.b    #$0, d0
0101bf84  00000000          ori.b    #$0, d0
0101bf88  00000000          ori.b    #$0, d0
0101bf8c  00000000          ori.b    #$0, d0
0101bf90  00000000          ori.b    #$0, d0
0101bf94  00000000          ori.b    #$0, d0
0101bf98  00000000          ori.b    #$0, d0
0101bf9c  00000000          ori.b    #$0, d0
0101bfa0  00000000          ori.b    #$0, d0
0101bfa4  00000000          ori.b    #$0, d0
0101bfa8  00000000          ori.b    #$0, d0
0101bfac  00000000          ori.b    #$0, d0
0101bfb0  00000000          ori.b    #$0, d0
0101bfb4  00000000          ori.b    #$0, d0
0101bfb8  00000000          ori.b    #$0, d0
0101bfbc  00000000          ori.b    #$0, d0
0101bfc0  00000000          ori.b    #$0, d0
0101bfc4  00000000          ori.b    #$0, d0
0101bfc8  00000000          ori.b    #$0, d0
0101bfcc  00000000          ori.b    #$0, d0
0101bfd0  00000000          ori.b    #$0, d0
0101bfd4  00000000          ori.b    #$0, d0
0101bfd8  00000000          ori.b    #$0, d0
0101bfdc  00000000          ori.b    #$0, d0
0101bfe0  00000000          ori.b    #$0, d0
0101bfe4  00000000          ori.b    #$0, d0
0101bfe8  00000000          ori.b    #$0, d0
0101bfec  00000000          ori.b    #$0, d0
0101bff0  00000000          ori.b    #$0, d0
0101bff4  00000000          ori.b    #$0, d0
0101bff8  00000000          ori.b    #$0, d0
0101bffc  00000000          ori.b    #$0, d0
0101c000  00000000          ori.b    #$0, d0
0101c004  00000000          ori.b    #$0, d0
0101c008  00000000          ori.b    #$0, d0
0101c00c  00000000          ori.b    #$0, d0
0101c010  00000000          ori.b    #$0, d0
0101c014  00000000          ori.b    #$0, d0
0101c018  00000000          ori.b    #$0, d0
0101c01c  00000000          ori.b    #$0, d0
0101c020  00000000          ori.b    #$0, d0
0101c024  00000000          ori.b    #$0, d0
0101c028  00000000          ori.b    #$0, d0
0101c02c  00000000          ori.b    #$0, d0
0101c030  00000000          ori.b    #$0, d0
0101c034  00000000          ori.b    #$0, d0
0101c038  00000000          ori.b    #$0, d0
0101c03c  00000000          ori.b    #$0, d0
0101c040  00000000          ori.b    #$0, d0
0101c044  00000000          ori.b    #$0, d0
0101c048  00000000          ori.b    #$0, d0
0101c04c  00000000          ori.b    #$0, d0
0101c050  00000000          ori.b    #$0, d0
0101c054  00000000          ori.b    #$0, d0
0101c058  00000000          ori.b    #$0, d0
0101c05c  00000000          ori.b    #$0, d0
0101c060  00000000          ori.b    #$0, d0
0101c064  00000000          ori.b    #$0, d0
0101c068  00000000          ori.b    #$0, d0
0101c06c  00000000          ori.b    #$0, d0
0101c070  00000000          ori.b    #$0, d0
0101c074  00000000          ori.b    #$0, d0
0101c078  00000000          ori.b    #$0, d0
0101c07c  00000000          ori.b    #$0, d0
0101c080  00000000          ori.b    #$0, d0
0101c084  00000000          ori.b    #$0, d0
0101c088  00000000          ori.b    #$0, d0
0101c08c  00000000          ori.b    #$0, d0
0101c090  00000000          ori.b    #$0, d0
0101c094  00000000          ori.b    #$0, d0
0101c098  00000000          ori.b    #$0, d0
0101c09c  00000000          ori.b    #$0, d0
0101c0a0  00000000          ori.b    #$0, d0
0101c0a4  00000000          ori.b    #$0, d0
0101c0a8  00000000          ori.b    #$0, d0
0101c0ac  00000000          ori.b    #$0, d0
0101c0b0  00000000          ori.b    #$0, d0
0101c0b4  00000000          ori.b    #$0, d0
0101c0b8  00000000          ori.b    #$0, d0
0101c0bc  00000000          ori.b    #$0, d0
0101c0c0  00000000          ori.b    #$0, d0
0101c0c4  00000000          ori.b    #$0, d0
0101c0c8  00000000          ori.b    #$0, d0
0101c0cc  00000000          ori.b    #$0, d0
0101c0d0  00000000          ori.b    #$0, d0
0101c0d4  00000000          ori.b    #$0, d0
0101c0d8  00000000          ori.b    #$0, d0
0101c0dc  00000000          ori.b    #$0, d0
0101c0e0  00000000          ori.b    #$0, d0
0101c0e4  00000000          ori.b    #$0, d0
0101c0e8  00000000          ori.b    #$0, d0
0101c0ec  00000000          ori.b    #$0, d0
0101c0f0  00000000          ori.b    #$0, d0
0101c0f4  00000000          ori.b    #$0, d0
0101c0f8  00000000          ori.b    #$0, d0
0101c0fc  00000000          ori.b    #$0, d0
0101c100  00000000          ori.b    #$0, d0
0101c104  00000000          ori.b    #$0, d0
0101c108  00000000          ori.b    #$0, d0
0101c10c  00000000          ori.b    #$0, d0
0101c110  00000000          ori.b    #$0, d0
0101c114  00000000          ori.b    #$0, d0
0101c118  00000000          ori.b    #$0, d0
0101c11c  00000000          ori.b    #$0, d0
0101c120  00000000          ori.b    #$0, d0
0101c124  00000000          ori.b    #$0, d0
0101c128  00000000          ori.b    #$0, d0
0101c12c  00000000          ori.b    #$0, d0
0101c130  00000000          ori.b    #$0, d0
0101c134  00000000          ori.b    #$0, d0
0101c138  00000000          ori.b    #$0, d0
0101c13c  00000000          ori.b    #$0, d0
0101c140  00000000          ori.b    #$0, d0
0101c144  00000000          ori.b    #$0, d0
0101c148  00000000          ori.b    #$0, d0
0101c14c  00000000          ori.b    #$0, d0
0101c150  00000000          ori.b    #$0, d0
0101c154  00000000          ori.b    #$0, d0
0101c158  00000000          ori.b    #$0, d0
0101c15c  00000000          ori.b    #$0, d0
0101c160  00000000          ori.b    #$0, d0
0101c164  00000000          ori.b    #$0, d0
0101c168  00000000          ori.b    #$0, d0
0101c16c  00000000          ori.b    #$0, d0
0101c170  00000000          ori.b    #$0, d0
0101c174  00000000          ori.b    #$0, d0
0101c178  00000000          ori.b    #$0, d0
0101c17c  00000000          ori.b    #$0, d0
0101c180  00000000          ori.b    #$0, d0
0101c184  00000000          ori.b    #$0, d0
0101c188  00000000          ori.b    #$0, d0
0101c18c  00000000          ori.b    #$0, d0
0101c190  00000000          ori.b    #$0, d0
0101c194  00000000          ori.b    #$0, d0
0101c198  00000000          ori.b    #$0, d0
0101c19c  00000000          ori.b    #$0, d0
0101c1a0  00000000          ori.b    #$0, d0
0101c1a4  00000000          ori.b    #$0, d0
0101c1a8  00000000          ori.b    #$0, d0
0101c1ac  00000000          ori.b    #$0, d0
0101c1b0  00000000          ori.b    #$0, d0
0101c1b4  00000000          ori.b    #$0, d0
0101c1b8  00000000          ori.b    #$0, d0
0101c1bc  00000000          ori.b    #$0, d0
0101c1c0  00000000          ori.b    #$0, d0
0101c1c4  00000000          ori.b    #$0, d0
0101c1c8  00000000          ori.b    #$0, d0
0101c1cc  00000000          ori.b    #$0, d0
0101c1d0  00000000          ori.b    #$0, d0
0101c1d4  00000000          ori.b    #$0, d0
0101c1d8  00000000          ori.b    #$0, d0
0101c1dc  00000000          ori.b    #$0, d0
0101c1e0  00000000          ori.b    #$0, d0
0101c1e4  00000000          ori.b    #$0, d0
0101c1e8  00000000          ori.b    #$0, d0
0101c1ec  00000000          ori.b    #$0, d0
0101c1f0  00000000          ori.b    #$0, d0
0101c1f4  00000000          ori.b    #$0, d0
0101c1f8  00000000          ori.b    #$0, d0
0101c1fc  00000000          ori.b    #$0, d0
0101c200  00000000          ori.b    #$0, d0
0101c204  00000000          ori.b    #$0, d0
0101c208  00000000          ori.b    #$0, d0
0101c20c  00000000          ori.b    #$0, d0
0101c210  00000000          ori.b    #$0, d0
0101c214  00000000          ori.b    #$0, d0
0101c218  00000000          ori.b    #$0, d0
0101c21c  00000000          ori.b    #$0, d0
0101c220  00000000          ori.b    #$0, d0
0101c224  00000000          ori.b    #$0, d0
0101c228  00000000          ori.b    #$0, d0
0101c22c  00000000          ori.b    #$0, d0
0101c230  00000000          ori.b    #$0, d0
0101c234  00000000          ori.b    #$0, d0
0101c238  00000000          ori.b    #$0, d0
0101c23c  00000000          ori.b    #$0, d0
0101c240  00000000          ori.b    #$0, d0
0101c244  00000000          ori.b    #$0, d0
0101c248  00000000          ori.b    #$0, d0
0101c24c  00000000          ori.b    #$0, d0
0101c250  00000000          ori.b    #$0, d0
0101c254  00000000          ori.b    #$0, d0
0101c258  00000000          ori.b    #$0, d0
0101c25c  00000000          ori.b    #$0, d0
0101c260  00000000          ori.b    #$0, d0
0101c264  00000000          ori.b    #$0, d0
0101c268  00000000          ori.b    #$0, d0
0101c26c  00000000          ori.b    #$0, d0
0101c270  00000000          ori.b    #$0, d0
0101c274  00000000          ori.b    #$0, d0
0101c278  00000000          ori.b    #$0, d0
0101c27c  00000000          ori.b    #$0, d0
0101c280  00000000          ori.b    #$0, d0
0101c284  00000000          ori.b    #$0, d0
0101c288  00000000          ori.b    #$0, d0
0101c28c  00000000          ori.b    #$0, d0
0101c290  00000000          ori.b    #$0, d0
0101c294  00000000          ori.b    #$0, d0
0101c298  00000000          ori.b    #$0, d0
0101c29c  00000000          ori.b    #$0, d0
0101c2a0  00000000          ori.b    #$0, d0
0101c2a4  00000000          ori.b    #$0, d0
0101c2a8  00000000          ori.b    #$0, d0
0101c2ac  00000000          ori.b    #$0, d0
0101c2b0  00000000          ori.b    #$0, d0
0101c2b4  00000000          ori.b    #$0, d0
0101c2b8  00000000          ori.b    #$0, d0
0101c2bc  00000000          ori.b    #$0, d0
0101c2c0  00000000          ori.b    #$0, d0
0101c2c4  00000000          ori.b    #$0, d0
0101c2c8  00000000          ori.b    #$0, d0
0101c2cc  00000000          ori.b    #$0, d0
0101c2d0  00000000          ori.b    #$0, d0
0101c2d4  00000000          ori.b    #$0, d0
0101c2d8  00000000          ori.b    #$0, d0
0101c2dc  00000000          ori.b    #$0, d0
0101c2e0  00000000          ori.b    #$0, d0
0101c2e4  00000000          ori.b    #$0, d0
0101c2e8  00000000          ori.b    #$0, d0
0101c2ec  00000000          ori.b    #$0, d0
0101c2f0  00000000          ori.b    #$0, d0
0101c2f4  00000000          ori.b    #$0, d0
0101c2f8  00000000          ori.b    #$0, d0
0101c2fc  00000000          ori.b    #$0, d0
0101c300  00000000          ori.b    #$0, d0
0101c304  00000000          ori.b    #$0, d0
0101c308  00000000          ori.b    #$0, d0
0101c30c  00000000          ori.b    #$0, d0
0101c310  00000000          ori.b    #$0, d0
0101c314  00000000          ori.b    #$0, d0
0101c318  00000000          ori.b    #$0, d0
0101c31c  00000000          ori.b    #$0, d0
0101c320  00000000          ori.b    #$0, d0
0101c324  00000000          ori.b    #$0, d0
0101c328  00000000          ori.b    #$0, d0
0101c32c  00000000          ori.b    #$0, d0
0101c330  00000000          ori.b    #$0, d0
0101c334  00000000          ori.b    #$0, d0
0101c338  00000000          ori.b    #$0, d0
0101c33c  00000000          ori.b    #$0, d0
0101c340  00000000          ori.b    #$0, d0
0101c344  00000000          ori.b    #$0, d0
0101c348  00000000          ori.b    #$0, d0
0101c34c  00000000          ori.b    #$0, d0
0101c350  00000000          ori.b    #$0, d0
0101c354  00000000          ori.b    #$0, d0
0101c358  00000000          ori.b    #$0, d0
0101c35c  00000000          ori.b    #$0, d0
0101c360  00000000          ori.b    #$0, d0
0101c364  00000000          ori.b    #$0, d0
0101c368  00000000          ori.b    #$0, d0
0101c36c  00000000          ori.b    #$0, d0
0101c370  00000000          ori.b    #$0, d0
0101c374  00000000          ori.b    #$0, d0
0101c378  00000000          ori.b    #$0, d0
0101c37c  00000000          ori.b    #$0, d0
0101c380  00000000          ori.b    #$0, d0
0101c384  00000000          ori.b    #$0, d0
0101c388  00000000          ori.b    #$0, d0
0101c38c  00000000          ori.b    #$0, d0
0101c390  00000000          ori.b    #$0, d0
0101c394  00000000          ori.b    #$0, d0
0101c398  00000000          ori.b    #$0, d0
0101c39c  00000000          ori.b    #$0, d0
0101c3a0  00000000          ori.b    #$0, d0
0101c3a4  00000000          ori.b    #$0, d0
0101c3a8  00000000          ori.b    #$0, d0
0101c3ac  00000000          ori.b    #$0, d0
0101c3b0  00000000          ori.b    #$0, d0
0101c3b4  00000000          ori.b    #$0, d0
0101c3b8  00000000          ori.b    #$0, d0
0101c3bc  00000000          ori.b    #$0, d0
0101c3c0  00000000          ori.b    #$0, d0
0101c3c4  00000000          ori.b    #$0, d0
0101c3c8  00000000          ori.b    #$0, d0
0101c3cc  00000000          ori.b    #$0, d0
0101c3d0  00000000          ori.b    #$0, d0
0101c3d4  00000000          ori.b    #$0, d0
0101c3d8  00000000          ori.b    #$0, d0
0101c3dc  00000000          ori.b    #$0, d0
0101c3e0  00000000          ori.b    #$0, d0
0101c3e4  00000000          ori.b    #$0, d0
0101c3e8  00000000          ori.b    #$0, d0
0101c3ec  00000000          ori.b    #$0, d0
0101c3f0  00000000          ori.b    #$0, d0
0101c3f4  00000000          ori.b    #$0, d0
0101c3f8  00000000          ori.b    #$0, d0
0101c3fc  00000000          ori.b    #$0, d0
0101c400  00000000          ori.b    #$0, d0
0101c404  00000000          ori.b    #$0, d0
0101c408  00000000          ori.b    #$0, d0
0101c40c  00000000          ori.b    #$0, d0
0101c410  00000000          ori.b    #$0, d0
0101c414  00000000          ori.b    #$0, d0
0101c418  00000000          ori.b    #$0, d0
0101c41c  00000000          ori.b    #$0, d0
0101c420  00000000          ori.b    #$0, d0
0101c424  00000000          ori.b    #$0, d0
0101c428  00000000          ori.b    #$0, d0
0101c42c  00000000          ori.b    #$0, d0
0101c430  00000000          ori.b    #$0, d0
0101c434  00000000          ori.b    #$0, d0
0101c438  00000000          ori.b    #$0, d0
0101c43c  00000000          ori.b    #$0, d0
0101c440  00000000          ori.b    #$0, d0
0101c444  00000000          ori.b    #$0, d0
0101c448  00000000          ori.b    #$0, d0
0101c44c  00000000          ori.b    #$0, d0
0101c450  00000000          ori.b    #$0, d0
0101c454  00000000          ori.b    #$0, d0
0101c458  00000000          ori.b    #$0, d0
0101c45c  00000000          ori.b    #$0, d0
0101c460  00000000          ori.b    #$0, d0
0101c464  00000000          ori.b    #$0, d0
0101c468  00000000          ori.b    #$0, d0
0101c46c  00000000          ori.b    #$0, d0
0101c470  00000000          ori.b    #$0, d0
0101c474  00000000          ori.b    #$0, d0
0101c478  00000000          ori.b    #$0, d0
0101c47c  00000000          ori.b    #$0, d0
0101c480  00000000          ori.b    #$0, d0
0101c484  00000000          ori.b    #$0, d0
0101c488  00000000          ori.b    #$0, d0
0101c48c  00000000          ori.b    #$0, d0
0101c490  00000000          ori.b    #$0, d0
0101c494  00000000          ori.b    #$0, d0
0101c498  00000000          ori.b    #$0, d0
0101c49c  00000000          ori.b    #$0, d0
0101c4a0  00000000          ori.b    #$0, d0
0101c4a4  00000000          ori.b    #$0, d0
0101c4a8  00000000          ori.b    #$0, d0
0101c4ac  00000000          ori.b    #$0, d0
0101c4b0  00000000          ori.b    #$0, d0
0101c4b4  00000000          ori.b    #$0, d0
0101c4b8  00000000          ori.b    #$0, d0
0101c4bc  00000000          ori.b    #$0, d0
0101c4c0  00000000          ori.b    #$0, d0
0101c4c4  00000000          ori.b    #$0, d0
0101c4c8  00000000          ori.b    #$0, d0
0101c4cc  00000000          ori.b    #$0, d0
0101c4d0  00000000          ori.b    #$0, d0
0101c4d4  00000000          ori.b    #$0, d0
0101c4d8  00000000          ori.b    #$0, d0
0101c4dc  00000000          ori.b    #$0, d0
0101c4e0  00000000          ori.b    #$0, d0
0101c4e4  00000000          ori.b    #$0, d0
0101c4e8  00000000          ori.b    #$0, d0
0101c4ec  00000000          ori.b    #$0, d0
0101c4f0  00000000          ori.b    #$0, d0
0101c4f4  00000000          ori.b    #$0, d0
0101c4f8  00000000          ori.b    #$0, d0
0101c4fc  00000000          ori.b    #$0, d0
0101c500  00000000          ori.b    #$0, d0
0101c504  00000000          ori.b    #$0, d0
0101c508  00000000          ori.b    #$0, d0
0101c50c  00000000          ori.b    #$0, d0
0101c510  00000000          ori.b    #$0, d0
0101c514  00000000          ori.b    #$0, d0
0101c518  00000000          ori.b    #$0, d0
0101c51c  00000000          ori.b    #$0, d0
0101c520  00000000          ori.b    #$0, d0
0101c524  00000000          ori.b    #$0, d0
0101c528  00000000          ori.b    #$0, d0
0101c52c  00000000          ori.b    #$0, d0
0101c530  00000000          ori.b    #$0, d0
0101c534  00000000          ori.b    #$0, d0
0101c538  00000000          ori.b    #$0, d0
0101c53c  00000000          ori.b    #$0, d0
0101c540  00000000          ori.b    #$0, d0
0101c544  00000000          ori.b    #$0, d0
0101c548  00000000          ori.b    #$0, d0
0101c54c  00000000          ori.b    #$0, d0
0101c550  00000000          ori.b    #$0, d0
0101c554  00000000          ori.b    #$0, d0
0101c558  00000000          ori.b    #$0, d0
0101c55c  00000000          ori.b    #$0, d0
0101c560  00000000          ori.b    #$0, d0
0101c564  00000000          ori.b    #$0, d0
0101c568  00000000          ori.b    #$0, d0
0101c56c  00000000          ori.b    #$0, d0
0101c570  00000000          ori.b    #$0, d0
0101c574  00000000          ori.b    #$0, d0
0101c578  00000000          ori.b    #$0, d0
0101c57c  00000000          ori.b    #$0, d0
0101c580  00000000          ori.b    #$0, d0
0101c584  00000000          ori.b    #$0, d0
0101c588  00000000          ori.b    #$0, d0
0101c58c  00000000          ori.b    #$0, d0
0101c590  00000000          ori.b    #$0, d0
0101c594  00000000          ori.b    #$0, d0
0101c598  00000000          ori.b    #$0, d0
0101c59c  00000000          ori.b    #$0, d0
0101c5a0  00000000          ori.b    #$0, d0
0101c5a4  00000000          ori.b    #$0, d0
0101c5a8  00000000          ori.b    #$0, d0
0101c5ac  00000000          ori.b    #$0, d0
0101c5b0  00000000          ori.b    #$0, d0
0101c5b4  00000000          ori.b    #$0, d0
0101c5b8  00000000          ori.b    #$0, d0
0101c5bc  00000000          ori.b    #$0, d0
0101c5c0  00000000          ori.b    #$0, d0
0101c5c4  00000000          ori.b    #$0, d0
0101c5c8  00000000          ori.b    #$0, d0
0101c5cc  00000000          ori.b    #$0, d0
0101c5d0  00000000          ori.b    #$0, d0
0101c5d4  00000000          ori.b    #$0, d0
0101c5d8  00000000          ori.b    #$0, d0
0101c5dc  00000000          ori.b    #$0, d0
0101c5e0  00000000          ori.b    #$0, d0
0101c5e4  00000000          ori.b    #$0, d0
0101c5e8  00000000          ori.b    #$0, d0
0101c5ec  00000000          ori.b    #$0, d0
0101c5f0  00000000          ori.b    #$0, d0
0101c5f4  00000000          ori.b    #$0, d0
0101c5f8  00000000          ori.b    #$0, d0
0101c5fc  00000000          ori.b    #$0, d0
0101c600  00000000          ori.b    #$0, d0
0101c604  00000000          ori.b    #$0, d0
0101c608  00000000          ori.b    #$0, d0
0101c60c  00000000          ori.b    #$0, d0
0101c610  00000000          ori.b    #$0, d0
0101c614  00000000          ori.b    #$0, d0
0101c618  00000000          ori.b    #$0, d0
0101c61c  00000000          ori.b    #$0, d0
0101c620  00000000          ori.b    #$0, d0
0101c624  00000000          ori.b    #$0, d0
0101c628  00000000          ori.b    #$0, d0
0101c62c  00000000          ori.b    #$0, d0
0101c630  00000000          ori.b    #$0, d0
0101c634  00000000          ori.b    #$0, d0
0101c638  00000000          ori.b    #$0, d0
0101c63c  00000000          ori.b    #$0, d0
0101c640  00000000          ori.b    #$0, d0
0101c644  00000000          ori.b    #$0, d0
0101c648  00000000          ori.b    #$0, d0
0101c64c  00000000          ori.b    #$0, d0
0101c650  00000000          ori.b    #$0, d0
0101c654  00000000          ori.b    #$0, d0
0101c658  00000000          ori.b    #$0, d0
0101c65c  00000000          ori.b    #$0, d0
0101c660  00000000          ori.b    #$0, d0
0101c664  00000000          ori.b    #$0, d0
0101c668  00000000          ori.b    #$0, d0
0101c66c  00000000          ori.b    #$0, d0
0101c670  00000000          ori.b    #$0, d0
0101c674  00000000          ori.b    #$0, d0
0101c678  00000000          ori.b    #$0, d0
0101c67c  00000000          ori.b    #$0, d0
0101c680  00000000          ori.b    #$0, d0
0101c684  00000000          ori.b    #$0, d0
0101c688  00000000          ori.b    #$0, d0
0101c68c  00000000          ori.b    #$0, d0
0101c690  00000000          ori.b    #$0, d0
0101c694  00000000          ori.b    #$0, d0
0101c698  00000000          ori.b    #$0, d0
0101c69c  00000000          ori.b    #$0, d0
0101c6a0  00000000          ori.b    #$0, d0
0101c6a4  00000000          ori.b    #$0, d0
0101c6a8  00000000          ori.b    #$0, d0
0101c6ac  00000000          ori.b    #$0, d0
0101c6b0  00000000          ori.b    #$0, d0
0101c6b4  00000000          ori.b    #$0, d0
0101c6b8  00000000          ori.b    #$0, d0
0101c6bc  00000000          ori.b    #$0, d0
0101c6c0  00000000          ori.b    #$0, d0
0101c6c4  00000000          ori.b    #$0, d0
0101c6c8  00000000          ori.b    #$0, d0
0101c6cc  00000000          ori.b    #$0, d0
0101c6d0  00000000          ori.b    #$0, d0
0101c6d4  00000000          ori.b    #$0, d0
0101c6d8  00000000          ori.b    #$0, d0
0101c6dc  00000000          ori.b    #$0, d0
0101c6e0  00000000          ori.b    #$0, d0
0101c6e4  00000000          ori.b    #$0, d0
0101c6e8  00000000          ori.b    #$0, d0
0101c6ec  00000000          ori.b    #$0, d0
0101c6f0  00000000          ori.b    #$0, d0
0101c6f4  00000000          ori.b    #$0, d0
0101c6f8  00000000          ori.b    #$0, d0
0101c6fc  00000000          ori.b    #$0, d0
0101c700  00000000          ori.b    #$0, d0
0101c704  00000000          ori.b    #$0, d0
0101c708  00000000          ori.b    #$0, d0
0101c70c  00000000          ori.b    #$0, d0
0101c710  00000000          ori.b    #$0, d0
0101c714  00000000          ori.b    #$0, d0
0101c718  00000000          ori.b    #$0, d0
0101c71c  00000000          ori.b    #$0, d0
0101c720  00000000          ori.b    #$0, d0
0101c724  00000000          ori.b    #$0, d0
0101c728  00000000          ori.b    #$0, d0
0101c72c  00000000          ori.b    #$0, d0
0101c730  00000000          ori.b    #$0, d0
0101c734  00000000          ori.b    #$0, d0
0101c738  00000000          ori.b    #$0, d0
0101c73c  00000000          ori.b    #$0, d0
0101c740  00000000          ori.b    #$0, d0
0101c744  00000000          ori.b    #$0, d0
0101c748  00000000          ori.b    #$0, d0
0101c74c  00000000          ori.b    #$0, d0
0101c750  00000000          ori.b    #$0, d0
0101c754  00000000          ori.b    #$0, d0
0101c758  00000000          ori.b    #$0, d0
0101c75c  00000000          ori.b    #$0, d0
0101c760  00000000          ori.b    #$0, d0
0101c764  00000000          ori.b    #$0, d0
0101c768  00000000          ori.b    #$0, d0
0101c76c  00000000          ori.b    #$0, d0
0101c770  00000000          ori.b    #$0, d0
0101c774  00000000          ori.b    #$0, d0
0101c778  00000000          ori.b    #$0, d0
0101c77c  00000000          ori.b    #$0, d0
0101c780  00000000          ori.b    #$0, d0
0101c784  00000000          ori.b    #$0, d0
0101c788  00000000          ori.b    #$0, d0
0101c78c  00000000          ori.b    #$0, d0
0101c790  00000000          ori.b    #$0, d0
0101c794  00000000          ori.b    #$0, d0
0101c798  00000000          ori.b    #$0, d0
0101c79c  00000000          ori.b    #$0, d0
0101c7a0  00000000          ori.b    #$0, d0
0101c7a4  00000000          ori.b    #$0, d0
0101c7a8  00000000          ori.b    #$0, d0
0101c7ac  00000000          ori.b    #$0, d0
0101c7b0  00000000          ori.b    #$0, d0
0101c7b4  00000000          ori.b    #$0, d0
0101c7b8  00000000          ori.b    #$0, d0
0101c7bc  00000000          ori.b    #$0, d0
0101c7c0  00000000          ori.b    #$0, d0
0101c7c4  00000000          ori.b    #$0, d0
0101c7c8  00000000          ori.b    #$0, d0
0101c7cc  00000000          ori.b    #$0, d0
0101c7d0  00000000          ori.b    #$0, d0
0101c7d4  00000000          ori.b    #$0, d0
0101c7d8  00000000          ori.b    #$0, d0
0101c7dc  00000000          ori.b    #$0, d0
0101c7e0  00000000          ori.b    #$0, d0
0101c7e4  00000000          ori.b    #$0, d0
0101c7e8  00000000          ori.b    #$0, d0
0101c7ec  00000000          ori.b    #$0, d0
0101c7f0  00000000          ori.b    #$0, d0
0101c7f4  00000000          ori.b    #$0, d0
0101c7f8  00000000          ori.b    #$0, d0
0101c7fc  00000000          ori.b    #$0, d0
0101c800  00000000          ori.b    #$0, d0
0101c804  00000000          ori.b    #$0, d0
0101c808  00000000          ori.b    #$0, d0
0101c80c  00000000          ori.b    #$0, d0
0101c810  00000000          ori.b    #$0, d0
0101c814  00000000          ori.b    #$0, d0
0101c818  00000000          ori.b    #$0, d0
0101c81c  00000000          ori.b    #$0, d0
0101c820  00000000          ori.b    #$0, d0
0101c824  00000000          ori.b    #$0, d0
0101c828  00000000          ori.b    #$0, d0
0101c82c  00000000          ori.b    #$0, d0
0101c830  00000000          ori.b    #$0, d0
0101c834  00000000          ori.b    #$0, d0
0101c838  00000000          ori.b    #$0, d0
0101c83c  00000000          ori.b    #$0, d0
0101c840  00000000          ori.b    #$0, d0
0101c844  00000000          ori.b    #$0, d0
0101c848  00000000          ori.b    #$0, d0
0101c84c  00000000          ori.b    #$0, d0
0101c850  00000000          ori.b    #$0, d0
0101c854  00000000          ori.b    #$0, d0
0101c858  00000000          ori.b    #$0, d0
0101c85c  00000000          ori.b    #$0, d0
0101c860  00000000          ori.b    #$0, d0
0101c864  00000000          ori.b    #$0, d0
0101c868  00000000          ori.b    #$0, d0
0101c86c  00000000          ori.b    #$0, d0
0101c870  00000000          ori.b    #$0, d0
0101c874  00000000          ori.b    #$0, d0
0101c878  00000000          ori.b    #$0, d0
0101c87c  00000000          ori.b    #$0, d0
0101c880  00000000          ori.b    #$0, d0
0101c884  00000000          ori.b    #$0, d0
0101c888  00000000          ori.b    #$0, d0
0101c88c  00000000          ori.b    #$0, d0
0101c890  00000000          ori.b    #$0, d0
0101c894  00000000          ori.b    #$0, d0
0101c898  00000000          ori.b    #$0, d0
0101c89c  00000000          ori.b    #$0, d0
0101c8a0  00000000          ori.b    #$0, d0
0101c8a4  00000000          ori.b    #$0, d0
0101c8a8  00000000          ori.b    #$0, d0
0101c8ac  00000000          ori.b    #$0, d0
0101c8b0  00000000          ori.b    #$0, d0
0101c8b4  00000000          ori.b    #$0, d0
0101c8b8  00000000          ori.b    #$0, d0
0101c8bc  00000000          ori.b    #$0, d0
0101c8c0  00000000          ori.b    #$0, d0
0101c8c4  00000000          ori.b    #$0, d0
0101c8c8  00000000          ori.b    #$0, d0
0101c8cc  00000000          ori.b    #$0, d0
0101c8d0  00000000          ori.b    #$0, d0
0101c8d4  00000000          ori.b    #$0, d0
0101c8d8  00000000          ori.b    #$0, d0
0101c8dc  00000000          ori.b    #$0, d0
0101c8e0  00000000          ori.b    #$0, d0
0101c8e4  00000000          ori.b    #$0, d0
0101c8e8  00000000          ori.b    #$0, d0
0101c8ec  00000000          ori.b    #$0, d0
0101c8f0  00000000          ori.b    #$0, d0
0101c8f4  00000000          ori.b    #$0, d0
0101c8f8  00000000          ori.b    #$0, d0
0101c8fc  00000000          ori.b    #$0, d0
0101c900  00000000          ori.b    #$0, d0
0101c904  00000000          ori.b    #$0, d0
0101c908  00000000          ori.b    #$0, d0
0101c90c  00000000          ori.b    #$0, d0
0101c910  00000000          ori.b    #$0, d0
0101c914  00000000          ori.b    #$0, d0
0101c918  00000000          ori.b    #$0, d0
0101c91c  00000000          ori.b    #$0, d0
0101c920  00000000          ori.b    #$0, d0
0101c924  00000000          ori.b    #$0, d0
0101c928  00000000          ori.b    #$0, d0
0101c92c  00000000          ori.b    #$0, d0
0101c930  00000000          ori.b    #$0, d0
0101c934  00000000          ori.b    #$0, d0
0101c938  00000000          ori.b    #$0, d0
0101c93c  00000000          ori.b    #$0, d0
0101c940  00000000          ori.b    #$0, d0
0101c944  00000000          ori.b    #$0, d0
0101c948  00000000          ori.b    #$0, d0
0101c94c  00000000          ori.b    #$0, d0
0101c950  00000000          ori.b    #$0, d0
0101c954  00000000          ori.b    #$0, d0
0101c958  00000000          ori.b    #$0, d0
0101c95c  00000000          ori.b    #$0, d0
0101c960  00000000          ori.b    #$0, d0
0101c964  00000000          ori.b    #$0, d0
0101c968  00000000          ori.b    #$0, d0
0101c96c  00000000          ori.b    #$0, d0
0101c970  00000000          ori.b    #$0, d0
0101c974  00000000          ori.b    #$0, d0
0101c978  00000000          ori.b    #$0, d0
0101c97c  00000000          ori.b    #$0, d0
0101c980  00000000          ori.b    #$0, d0
0101c984  00000000          ori.b    #$0, d0
0101c988  00000000          ori.b    #$0, d0
0101c98c  00000000          ori.b    #$0, d0
0101c990  00000000          ori.b    #$0, d0
0101c994  00000000          ori.b    #$0, d0
0101c998  00000000          ori.b    #$0, d0
0101c99c  00000000          ori.b    #$0, d0
0101c9a0  00000000          ori.b    #$0, d0
0101c9a4  00000000          ori.b    #$0, d0
0101c9a8  00000000          ori.b    #$0, d0
0101c9ac  00000000          ori.b    #$0, d0
0101c9b0  00000000          ori.b    #$0, d0
0101c9b4  00000000          ori.b    #$0, d0
0101c9b8  00000000          ori.b    #$0, d0
0101c9bc  00000000          ori.b    #$0, d0
0101c9c0  00000000          ori.b    #$0, d0
0101c9c4  00000000          ori.b    #$0, d0
0101c9c8  00000000          ori.b    #$0, d0
0101c9cc  00000000          ori.b    #$0, d0
0101c9d0  00000000          ori.b    #$0, d0
0101c9d4  00000000          ori.b    #$0, d0
0101c9d8  00000000          ori.b    #$0, d0
0101c9dc  00000000          ori.b    #$0, d0
0101c9e0  00000000          ori.b    #$0, d0
0101c9e4  00000000          ori.b    #$0, d0
0101c9e8  00000000          ori.b    #$0, d0
0101c9ec  00000000          ori.b    #$0, d0
0101c9f0  00000000          ori.b    #$0, d0
0101c9f4  00000000          ori.b    #$0, d0
0101c9f8  00000000          ori.b    #$0, d0
0101c9fc  00000000          ori.b    #$0, d0
0101ca00  00000000          ori.b    #$0, d0
0101ca04  00000000          ori.b    #$0, d0
0101ca08  00000000          ori.b    #$0, d0
0101ca0c  00000000          ori.b    #$0, d0
0101ca10  00000000          ori.b    #$0, d0
0101ca14  00000000          ori.b    #$0, d0
0101ca18  00000000          ori.b    #$0, d0
0101ca1c  00000000          ori.b    #$0, d0
0101ca20  00000000          ori.b    #$0, d0
0101ca24  00000000          ori.b    #$0, d0
0101ca28  00000000          ori.b    #$0, d0
0101ca2c  00000000          ori.b    #$0, d0
0101ca30  00000000          ori.b    #$0, d0
0101ca34  00000000          ori.b    #$0, d0
0101ca38  00000000          ori.b    #$0, d0
0101ca3c  00000000          ori.b    #$0, d0
0101ca40  00000000          ori.b    #$0, d0
0101ca44  00000000          ori.b    #$0, d0
0101ca48  00000000          ori.b    #$0, d0
0101ca4c  00000000          ori.b    #$0, d0
0101ca50  00000000          ori.b    #$0, d0
0101ca54  00000000          ori.b    #$0, d0
0101ca58  00000000          ori.b    #$0, d0
0101ca5c  00000000          ori.b    #$0, d0
0101ca60  00000000          ori.b    #$0, d0
0101ca64  00000000          ori.b    #$0, d0
0101ca68  00000000          ori.b    #$0, d0
0101ca6c  00000000          ori.b    #$0, d0
0101ca70  00000000          ori.b    #$0, d0
0101ca74  00000000          ori.b    #$0, d0
0101ca78  00000000          ori.b    #$0, d0
0101ca7c  00000000          ori.b    #$0, d0
0101ca80  00000000          ori.b    #$0, d0
0101ca84  00000000          ori.b    #$0, d0
0101ca88  00000000          ori.b    #$0, d0
0101ca8c  00000000          ori.b    #$0, d0
0101ca90  00000000          ori.b    #$0, d0
0101ca94  00000000          ori.b    #$0, d0
0101ca98  00000000          ori.b    #$0, d0
0101ca9c  00000000          ori.b    #$0, d0
0101caa0  00000000          ori.b    #$0, d0
0101caa4  00000000          ori.b    #$0, d0
0101caa8  00000000          ori.b    #$0, d0
0101caac  00000000          ori.b    #$0, d0
0101cab0  00000000          ori.b    #$0, d0
0101cab4  00000000          ori.b    #$0, d0
0101cab8  00000000          ori.b    #$0, d0
0101cabc  00000000          ori.b    #$0, d0
0101cac0  00000000          ori.b    #$0, d0
0101cac4  00000000          ori.b    #$0, d0
0101cac8  00000000          ori.b    #$0, d0
0101cacc  00000000          ori.b    #$0, d0
0101cad0  00000000          ori.b    #$0, d0
0101cad4  00000000          ori.b    #$0, d0
0101cad8  00000000          ori.b    #$0, d0
0101cadc  00000000          ori.b    #$0, d0
0101cae0  00000000          ori.b    #$0, d0
0101cae4  00000000          ori.b    #$0, d0
0101cae8  00000000          ori.b    #$0, d0
0101caec  00000000          ori.b    #$0, d0
0101caf0  00000000          ori.b    #$0, d0
0101caf4  00000000          ori.b    #$0, d0
0101caf8  00000000          ori.b    #$0, d0
0101cafc  00000000          ori.b    #$0, d0
0101cb00  00000000          ori.b    #$0, d0
0101cb04  00000000          ori.b    #$0, d0
0101cb08  00000000          ori.b    #$0, d0
0101cb0c  00000000          ori.b    #$0, d0
0101cb10  00000000          ori.b    #$0, d0
0101cb14  00000000          ori.b    #$0, d0
0101cb18  00000000          ori.b    #$0, d0
0101cb1c  00000000          ori.b    #$0, d0
0101cb20  00000000          ori.b    #$0, d0
0101cb24  00000000          ori.b    #$0, d0
0101cb28  00000000          ori.b    #$0, d0
0101cb2c  00000000          ori.b    #$0, d0
0101cb30  00000000          ori.b    #$0, d0
0101cb34  00000000          ori.b    #$0, d0
0101cb38  00000000          ori.b    #$0, d0
0101cb3c  00000000          ori.b    #$0, d0
0101cb40  00000000          ori.b    #$0, d0
0101cb44  00000000          ori.b    #$0, d0
0101cb48  00000000          ori.b    #$0, d0
0101cb4c  00000000          ori.b    #$0, d0
0101cb50  00000000          ori.b    #$0, d0
0101cb54  00000000          ori.b    #$0, d0
0101cb58  00000000          ori.b    #$0, d0
0101cb5c  00000000          ori.b    #$0, d0
0101cb60  00000000          ori.b    #$0, d0
0101cb64  00000000          ori.b    #$0, d0
0101cb68  00000000          ori.b    #$0, d0
0101cb6c  00000000          ori.b    #$0, d0
0101cb70  00000000          ori.b    #$0, d0
0101cb74  00000000          ori.b    #$0, d0
0101cb78  00000000          ori.b    #$0, d0
0101cb7c  00000000          ori.b    #$0, d0
0101cb80  00000000          ori.b    #$0, d0
0101cb84  00000000          ori.b    #$0, d0
0101cb88  00000000          ori.b    #$0, d0
0101cb8c  00000000          ori.b    #$0, d0
0101cb90  00000000          ori.b    #$0, d0
0101cb94  00000000          ori.b    #$0, d0
0101cb98  00000000          ori.b    #$0, d0
0101cb9c  00000000          ori.b    #$0, d0
0101cba0  00000000          ori.b    #$0, d0
0101cba4  00000000          ori.b    #$0, d0
0101cba8  00000000          ori.b    #$0, d0
0101cbac  00000000          ori.b    #$0, d0
0101cbb0  00000000          ori.b    #$0, d0
0101cbb4  00000000          ori.b    #$0, d0
0101cbb8  00000000          ori.b    #$0, d0
0101cbbc  00000000          ori.b    #$0, d0
0101cbc0  00000000          ori.b    #$0, d0
0101cbc4  00000000          ori.b    #$0, d0
0101cbc8  00000000          ori.b    #$0, d0
0101cbcc  00000000          ori.b    #$0, d0
0101cbd0  00000000          ori.b    #$0, d0
0101cbd4  00000000          ori.b    #$0, d0
0101cbd8  00000000          ori.b    #$0, d0
0101cbdc  00000000          ori.b    #$0, d0
0101cbe0  00000000          ori.b    #$0, d0
0101cbe4  00000000          ori.b    #$0, d0
0101cbe8  00000000          ori.b    #$0, d0
0101cbec  00000000          ori.b    #$0, d0
0101cbf0  00000000          ori.b    #$0, d0
0101cbf4  00000000          ori.b    #$0, d0
0101cbf8  00000000          ori.b    #$0, d0
0101cbfc  00000000          ori.b    #$0, d0
0101cc00  00000000          ori.b    #$0, d0
0101cc04  00000000          ori.b    #$0, d0
0101cc08  00000000          ori.b    #$0, d0
0101cc0c  00000000          ori.b    #$0, d0
0101cc10  00000000          ori.b    #$0, d0
0101cc14  00000000          ori.b    #$0, d0
0101cc18  00000000          ori.b    #$0, d0
0101cc1c  00000000          ori.b    #$0, d0
0101cc20  00000000          ori.b    #$0, d0
0101cc24  00000000          ori.b    #$0, d0
0101cc28  00000000          ori.b    #$0, d0
0101cc2c  00000000          ori.b    #$0, d0
0101cc30  00000000          ori.b    #$0, d0
0101cc34  00000000          ori.b    #$0, d0
0101cc38  00000000          ori.b    #$0, d0
0101cc3c  00000000          ori.b    #$0, d0
0101cc40  00000000          ori.b    #$0, d0
0101cc44  00000000          ori.b    #$0, d0
0101cc48  00000000          ori.b    #$0, d0
0101cc4c  00000000          ori.b    #$0, d0
0101cc50  00000000          ori.b    #$0, d0
0101cc54  00000000          ori.b    #$0, d0
0101cc58  00000000          ori.b    #$0, d0
0101cc5c  00000000          ori.b    #$0, d0
0101cc60  00000000          ori.b    #$0, d0
0101cc64  00000000          ori.b    #$0, d0
0101cc68  00000000          ori.b    #$0, d0
0101cc6c  00000000          ori.b    #$0, d0
0101cc70  00000000          ori.b    #$0, d0
0101cc74  00000000          ori.b    #$0, d0
0101cc78  00000000          ori.b    #$0, d0
0101cc7c  00000000          ori.b    #$0, d0
0101cc80  00000000          ori.b    #$0, d0
0101cc84  00000000          ori.b    #$0, d0
0101cc88  00000000          ori.b    #$0, d0
0101cc8c  00000000          ori.b    #$0, d0
0101cc90  00000000          ori.b    #$0, d0
0101cc94  00000000          ori.b    #$0, d0
0101cc98  00000000          ori.b    #$0, d0
0101cc9c  00000000          ori.b    #$0, d0
0101cca0  00000000          ori.b    #$0, d0
0101cca4  00000000          ori.b    #$0, d0
0101cca8  00000000          ori.b    #$0, d0
0101ccac  00000000          ori.b    #$0, d0
0101ccb0  00000000          ori.b    #$0, d0
0101ccb4  00000000          ori.b    #$0, d0
0101ccb8  00000000          ori.b    #$0, d0
0101ccbc  00000000          ori.b    #$0, d0
0101ccc0  00000000          ori.b    #$0, d0
0101ccc4  00000000          ori.b    #$0, d0
0101ccc8  00000000          ori.b    #$0, d0
0101cccc  00000000          ori.b    #$0, d0
0101ccd0  00000000          ori.b    #$0, d0
0101ccd4  00000000          ori.b    #$0, d0
0101ccd8  00000000          ori.b    #$0, d0
0101ccdc  00000000          ori.b    #$0, d0
0101cce0  00000000          ori.b    #$0, d0
0101cce4  00000000          ori.b    #$0, d0
0101cce8  00000000          ori.b    #$0, d0
0101ccec  00000000          ori.b    #$0, d0
0101ccf0  00000000          ori.b    #$0, d0
0101ccf4  00000000          ori.b    #$0, d0
0101ccf8  00000000          ori.b    #$0, d0
0101ccfc  00000000          ori.b    #$0, d0
0101cd00  00000000          ori.b    #$0, d0
0101cd04  00000000          ori.b    #$0, d0
0101cd08  00000000          ori.b    #$0, d0
0101cd0c  00000000          ori.b    #$0, d0
0101cd10  00000000          ori.b    #$0, d0
0101cd14  00000000          ori.b    #$0, d0
0101cd18  00000000          ori.b    #$0, d0
0101cd1c  00000000          ori.b    #$0, d0
0101cd20  00000000          ori.b    #$0, d0
0101cd24  00000000          ori.b    #$0, d0
0101cd28  00000000          ori.b    #$0, d0
0101cd2c  00000000          ori.b    #$0, d0
0101cd30  00000000          ori.b    #$0, d0
0101cd34  00000000          ori.b    #$0, d0
0101cd38  00000000          ori.b    #$0, d0
0101cd3c  00000000          ori.b    #$0, d0
0101cd40  00000000          ori.b    #$0, d0
0101cd44  00000000          ori.b    #$0, d0
0101cd48  00000000          ori.b    #$0, d0
0101cd4c  00000000          ori.b    #$0, d0
0101cd50  00000000          ori.b    #$0, d0
0101cd54  00000000          ori.b    #$0, d0
0101cd58  00000000          ori.b    #$0, d0
0101cd5c  00000000          ori.b    #$0, d0
0101cd60  00000000          ori.b    #$0, d0
0101cd64  00000000          ori.b    #$0, d0
0101cd68  00000000          ori.b    #$0, d0
0101cd6c  00000000          ori.b    #$0, d0
0101cd70  00000000          ori.b    #$0, d0
0101cd74  00000000          ori.b    #$0, d0
0101cd78  00000000          ori.b    #$0, d0
0101cd7c  00000000          ori.b    #$0, d0
0101cd80  00000000          ori.b    #$0, d0
0101cd84  00000000          ori.b    #$0, d0
0101cd88  00000000          ori.b    #$0, d0
0101cd8c  00000000          ori.b    #$0, d0
0101cd90  00000000          ori.b    #$0, d0
0101cd94  00000000          ori.b    #$0, d0
0101cd98  00000000          ori.b    #$0, d0
0101cd9c  00000000          ori.b    #$0, d0
0101cda0  00000000          ori.b    #$0, d0
0101cda4  00000000          ori.b    #$0, d0
0101cda8  00000000          ori.b    #$0, d0
0101cdac  00000000          ori.b    #$0, d0
0101cdb0  00000000          ori.b    #$0, d0
0101cdb4  00000000          ori.b    #$0, d0
0101cdb8  00000000          ori.b    #$0, d0
0101cdbc  00000000          ori.b    #$0, d0
0101cdc0  00000000          ori.b    #$0, d0
0101cdc4  00000000          ori.b    #$0, d0
0101cdc8  00000000          ori.b    #$0, d0
0101cdcc  00000000          ori.b    #$0, d0
0101cdd0  00000000          ori.b    #$0, d0
0101cdd4  00000000          ori.b    #$0, d0
0101cdd8  00000000          ori.b    #$0, d0
0101cddc  00000000          ori.b    #$0, d0
0101cde0  00000000          ori.b    #$0, d0
0101cde4  00000000          ori.b    #$0, d0
0101cde8  00000000          ori.b    #$0, d0
0101cdec  00000000          ori.b    #$0, d0
0101cdf0  00000000          ori.b    #$0, d0
0101cdf4  00000000          ori.b    #$0, d0
0101cdf8  00000000          ori.b    #$0, d0
0101cdfc  00000000          ori.b    #$0, d0
0101ce00  00000000          ori.b    #$0, d0
0101ce04  00000000          ori.b    #$0, d0
0101ce08  00000000          ori.b    #$0, d0
0101ce0c  00000000          ori.b    #$0, d0
0101ce10  00000000          ori.b    #$0, d0
0101ce14  00000000          ori.b    #$0, d0
0101ce18  00000000          ori.b    #$0, d0
0101ce1c  00000000          ori.b    #$0, d0
0101ce20  00000000          ori.b    #$0, d0
0101ce24  00000000          ori.b    #$0, d0
0101ce28  00000000          ori.b    #$0, d0
0101ce2c  00000000          ori.b    #$0, d0
0101ce30  00000000          ori.b    #$0, d0
0101ce34  00000000          ori.b    #$0, d0
0101ce38  00000000          ori.b    #$0, d0
0101ce3c  00000000          ori.b    #$0, d0
0101ce40  00000000          ori.b    #$0, d0
0101ce44  00000000          ori.b    #$0, d0
0101ce48  00000000          ori.b    #$0, d0
0101ce4c  00000000          ori.b    #$0, d0
0101ce50  00000000          ori.b    #$0, d0
0101ce54  00000000          ori.b    #$0, d0
0101ce58  00000000          ori.b    #$0, d0
0101ce5c  00000000          ori.b    #$0, d0
0101ce60  00000000          ori.b    #$0, d0
0101ce64  00000000          ori.b    #$0, d0
0101ce68  00000000          ori.b    #$0, d0
0101ce6c  00000000          ori.b    #$0, d0
0101ce70  00000000          ori.b    #$0, d0
0101ce74  00000000          ori.b    #$0, d0
0101ce78  00000000          ori.b    #$0, d0
0101ce7c  00000000          ori.b    #$0, d0
0101ce80  00000000          ori.b    #$0, d0
0101ce84  00000000          ori.b    #$0, d0
0101ce88  00000000          ori.b    #$0, d0
0101ce8c  00000000          ori.b    #$0, d0
0101ce90  00000000          ori.b    #$0, d0
0101ce94  00000000          ori.b    #$0, d0
0101ce98  00000000          ori.b    #$0, d0
0101ce9c  00000000          ori.b    #$0, d0
0101cea0  00000000          ori.b    #$0, d0
0101cea4  00000000          ori.b    #$0, d0
0101cea8  00000000          ori.b    #$0, d0
0101ceac  00000000          ori.b    #$0, d0
0101ceb0  00000000          ori.b    #$0, d0
0101ceb4  00000000          ori.b    #$0, d0
0101ceb8  00000000          ori.b    #$0, d0
0101cebc  00000000          ori.b    #$0, d0
0101cec0  00000000          ori.b    #$0, d0
0101cec4  00000000          ori.b    #$0, d0
0101cec8  00000000          ori.b    #$0, d0
0101cecc  00000000          ori.b    #$0, d0
0101ced0  00000000          ori.b    #$0, d0
0101ced4  00000000          ori.b    #$0, d0
0101ced8  00000000          ori.b    #$0, d0
0101cedc  00000000          ori.b    #$0, d0
0101cee0  00000000          ori.b    #$0, d0
0101cee4  00000000          ori.b    #$0, d0
0101cee8  00000000          ori.b    #$0, d0
0101ceec  00000000          ori.b    #$0, d0
0101cef0  00000000          ori.b    #$0, d0
0101cef4  00000000          ori.b    #$0, d0
0101cef8  00000000          ori.b    #$0, d0
0101cefc  00000000          ori.b    #$0, d0
0101cf00  00000000          ori.b    #$0, d0
0101cf04  00000000          ori.b    #$0, d0
0101cf08  00000000          ori.b    #$0, d0
0101cf0c  00000000          ori.b    #$0, d0
0101cf10  00000000          ori.b    #$0, d0
0101cf14  00000000          ori.b    #$0, d0
0101cf18  00000000          ori.b    #$0, d0
0101cf1c  00000000          ori.b    #$0, d0
0101cf20  00000000          ori.b    #$0, d0
0101cf24  00000000          ori.b    #$0, d0
0101cf28  00000000          ori.b    #$0, d0
0101cf2c  00000000          ori.b    #$0, d0
0101cf30  00000000          ori.b    #$0, d0
0101cf34  00000000          ori.b    #$0, d0
0101cf38  00000000          ori.b    #$0, d0
0101cf3c  00000000          ori.b    #$0, d0
0101cf40  00000000          ori.b    #$0, d0
0101cf44  00000000          ori.b    #$0, d0
0101cf48  00000000          ori.b    #$0, d0
0101cf4c  00000000          ori.b    #$0, d0
0101cf50  00000000          ori.b    #$0, d0
0101cf54  00000000          ori.b    #$0, d0
0101cf58  00000000          ori.b    #$0, d0
0101cf5c  00000000          ori.b    #$0, d0
0101cf60  00000000          ori.b    #$0, d0
0101cf64  00000000          ori.b    #$0, d0
0101cf68  00000000          ori.b    #$0, d0
0101cf6c  00000000          ori.b    #$0, d0
0101cf70  00000000          ori.b    #$0, d0
0101cf74  00000000          ori.b    #$0, d0
0101cf78  00000000          ori.b    #$0, d0
0101cf7c  00000000          ori.b    #$0, d0
0101cf80  00000000          ori.b    #$0, d0
0101cf84  00000000          ori.b    #$0, d0
0101cf88  00000000          ori.b    #$0, d0
0101cf8c  00000000          ori.b    #$0, d0
0101cf90  00000000          ori.b    #$0, d0
0101cf94  00000000          ori.b    #$0, d0
0101cf98  00000000          ori.b    #$0, d0
0101cf9c  00000000          ori.b    #$0, d0
0101cfa0  00000000          ori.b    #$0, d0
0101cfa4  00000000          ori.b    #$0, d0
0101cfa8  00000000          ori.b    #$0, d0
0101cfac  00000000          ori.b    #$0, d0
0101cfb0  00000000          ori.b    #$0, d0
0101cfb4  00000000          ori.b    #$0, d0
0101cfb8  00000000          ori.b    #$0, d0
0101cfbc  00000000          ori.b    #$0, d0
0101cfc0  00000000          ori.b    #$0, d0
0101cfc4  00000000          ori.b    #$0, d0
0101cfc8  00000000          ori.b    #$0, d0
0101cfcc  00000000          ori.b    #$0, d0
0101cfd0  00000000          ori.b    #$0, d0
0101cfd4  00000000          ori.b    #$0, d0
0101cfd8  00000000          ori.b    #$0, d0
0101cfdc  00000000          ori.b    #$0, d0
0101cfe0  00000000          ori.b    #$0, d0
0101cfe4  00000000          ori.b    #$0, d0
0101cfe8  00000000          ori.b    #$0, d0
0101cfec  00000000          ori.b    #$0, d0
0101cff0  00000000          ori.b    #$0, d0
0101cff4  00000000          ori.b    #$0, d0
0101cff8  00000000          ori.b    #$0, d0
0101cffc  00000000          ori.b    #$0, d0
0101d000  00000000          ori.b    #$0, d0
0101d004  00000000          ori.b    #$0, d0
0101d008  00000000          ori.b    #$0, d0
0101d00c  00000000          ori.b    #$0, d0
0101d010  00000000          ori.b    #$0, d0
0101d014  00000000          ori.b    #$0, d0
0101d018  00000000          ori.b    #$0, d0
0101d01c  00000000          ori.b    #$0, d0
0101d020  00000000          ori.b    #$0, d0
0101d024  00000000          ori.b    #$0, d0
0101d028  00000000          ori.b    #$0, d0
0101d02c  00000000          ori.b    #$0, d0
0101d030  00000000          ori.b    #$0, d0
0101d034  00000000          ori.b    #$0, d0
0101d038  00000000          ori.b    #$0, d0
0101d03c  00000000          ori.b    #$0, d0
0101d040  00000000          ori.b    #$0, d0
0101d044  00000000          ori.b    #$0, d0
0101d048  00000000          ori.b    #$0, d0
0101d04c  00000000          ori.b    #$0, d0
0101d050  00000000          ori.b    #$0, d0
0101d054  00000000          ori.b    #$0, d0
0101d058  00000000          ori.b    #$0, d0
0101d05c  00000000          ori.b    #$0, d0
0101d060  00000000          ori.b    #$0, d0
0101d064  00000000          ori.b    #$0, d0
0101d068  00000000          ori.b    #$0, d0
0101d06c  00000000          ori.b    #$0, d0
0101d070  00000000          ori.b    #$0, d0
0101d074  00000000          ori.b    #$0, d0
0101d078  00000000          ori.b    #$0, d0
0101d07c  00000000          ori.b    #$0, d0
0101d080  00000000          ori.b    #$0, d0
0101d084  00000000          ori.b    #$0, d0
0101d088  00000000          ori.b    #$0, d0
0101d08c  00000000          ori.b    #$0, d0
0101d090  00000000          ori.b    #$0, d0
0101d094  00000000          ori.b    #$0, d0
0101d098  00000000          ori.b    #$0, d0
0101d09c  00000000          ori.b    #$0, d0
0101d0a0  00000000          ori.b    #$0, d0
0101d0a4  00000000          ori.b    #$0, d0
0101d0a8  00000000          ori.b    #$0, d0
0101d0ac  00000000          ori.b    #$0, d0
0101d0b0  00000000          ori.b    #$0, d0
0101d0b4  00000000          ori.b    #$0, d0
0101d0b8  00000000          ori.b    #$0, d0
0101d0bc  00000000          ori.b    #$0, d0
0101d0c0  00000000          ori.b    #$0, d0
0101d0c4  00000000          ori.b    #$0, d0
0101d0c8  00000000          ori.b    #$0, d0
0101d0cc  00000000          ori.b    #$0, d0
0101d0d0  00000000          ori.b    #$0, d0
0101d0d4  00000000          ori.b    #$0, d0
0101d0d8  00000000          ori.b    #$0, d0
0101d0dc  00000000          ori.b    #$0, d0
0101d0e0  00000000          ori.b    #$0, d0
0101d0e4  00000000          ori.b    #$0, d0
0101d0e8  00000000          ori.b    #$0, d0
0101d0ec  00000000          ori.b    #$0, d0
0101d0f0  00000000          ori.b    #$0, d0
0101d0f4  00000000          ori.b    #$0, d0
0101d0f8  00000000          ori.b    #$0, d0
0101d0fc  00000000          ori.b    #$0, d0
0101d100  00000000          ori.b    #$0, d0
0101d104  00000000          ori.b    #$0, d0
0101d108  00000000          ori.b    #$0, d0
0101d10c  00000000          ori.b    #$0, d0
0101d110  00000000          ori.b    #$0, d0
0101d114  00000000          ori.b    #$0, d0
0101d118  00000000          ori.b    #$0, d0
0101d11c  00000000          ori.b    #$0, d0
0101d120  00000000          ori.b    #$0, d0
0101d124  00000000          ori.b    #$0, d0
0101d128  00000000          ori.b    #$0, d0
0101d12c  00000000          ori.b    #$0, d0
0101d130  00000000          ori.b    #$0, d0
0101d134  00000000          ori.b    #$0, d0
0101d138  00000000          ori.b    #$0, d0
0101d13c  00000000          ori.b    #$0, d0
0101d140  00000000          ori.b    #$0, d0
0101d144  00000000          ori.b    #$0, d0
0101d148  00000000          ori.b    #$0, d0
0101d14c  00000000          ori.b    #$0, d0
0101d150  00000000          ori.b    #$0, d0
0101d154  00000000          ori.b    #$0, d0
0101d158  00000000          ori.b    #$0, d0
0101d15c  00000000          ori.b    #$0, d0
0101d160  00000000          ori.b    #$0, d0
0101d164  00000000          ori.b    #$0, d0
0101d168  00000000          ori.b    #$0, d0
0101d16c  00000000          ori.b    #$0, d0
0101d170  00000000          ori.b    #$0, d0
0101d174  00000000          ori.b    #$0, d0
0101d178  00000000          ori.b    #$0, d0
0101d17c  00000000          ori.b    #$0, d0
0101d180  00000000          ori.b    #$0, d0
0101d184  00000000          ori.b    #$0, d0
0101d188  00000000          ori.b    #$0, d0
0101d18c  00000000          ori.b    #$0, d0
0101d190  00000000          ori.b    #$0, d0
0101d194  00000000          ori.b    #$0, d0
0101d198  00000000          ori.b    #$0, d0
0101d19c  00000000          ori.b    #$0, d0
0101d1a0  00000000          ori.b    #$0, d0
0101d1a4  00000000          ori.b    #$0, d0
0101d1a8  00000000          ori.b    #$0, d0
0101d1ac  00000000          ori.b    #$0, d0
0101d1b0  00000000          ori.b    #$0, d0
0101d1b4  00000000          ori.b    #$0, d0
0101d1b8  00000000          ori.b    #$0, d0
0101d1bc  00000000          ori.b    #$0, d0
0101d1c0  00000000          ori.b    #$0, d0
0101d1c4  00000000          ori.b    #$0, d0
0101d1c8  00000000          ori.b    #$0, d0
0101d1cc  00000000          ori.b    #$0, d0
0101d1d0  00000000          ori.b    #$0, d0
0101d1d4  00000000          ori.b    #$0, d0
0101d1d8  00000000          ori.b    #$0, d0
0101d1dc  00000000          ori.b    #$0, d0
0101d1e0  00000000          ori.b    #$0, d0
0101d1e4  00000000          ori.b    #$0, d0
0101d1e8  00000000          ori.b    #$0, d0
0101d1ec  00000000          ori.b    #$0, d0
0101d1f0  00000000          ori.b    #$0, d0
0101d1f4  00000000          ori.b    #$0, d0
0101d1f8  00000000          ori.b    #$0, d0
0101d1fc  00000000          ori.b    #$0, d0
0101d200  00000000          ori.b    #$0, d0
0101d204  00000000          ori.b    #$0, d0
0101d208  00000000          ori.b    #$0, d0
0101d20c  00000000          ori.b    #$0, d0
0101d210  00000000          ori.b    #$0, d0
0101d214  00000000          ori.b    #$0, d0
0101d218  00000000          ori.b    #$0, d0
0101d21c  00000000          ori.b    #$0, d0
0101d220  00000000          ori.b    #$0, d0
0101d224  00000000          ori.b    #$0, d0
0101d228  00000000          ori.b    #$0, d0
0101d22c  00000000          ori.b    #$0, d0
0101d230  00000000          ori.b    #$0, d0
0101d234  00000000          ori.b    #$0, d0
0101d238  00000000          ori.b    #$0, d0
0101d23c  00000000          ori.b    #$0, d0
0101d240  00000000          ori.b    #$0, d0
0101d244  00000000          ori.b    #$0, d0
0101d248  00000000          ori.b    #$0, d0
0101d24c  00000000          ori.b    #$0, d0
0101d250  00000000          ori.b    #$0, d0
0101d254  00000000          ori.b    #$0, d0
0101d258  00000000          ori.b    #$0, d0
0101d25c  00000000          ori.b    #$0, d0
0101d260  00000000          ori.b    #$0, d0
0101d264  00000000          ori.b    #$0, d0
0101d268  00000000          ori.b    #$0, d0
0101d26c  00000000          ori.b    #$0, d0
0101d270  00000000          ori.b    #$0, d0
0101d274  00000000          ori.b    #$0, d0
0101d278  00000000          ori.b    #$0, d0
0101d27c  00000000          ori.b    #$0, d0
0101d280  00000000          ori.b    #$0, d0
0101d284  00000000          ori.b    #$0, d0
0101d288  00000000          ori.b    #$0, d0
0101d28c  00000000          ori.b    #$0, d0
0101d290  00000000          ori.b    #$0, d0
0101d294  00000000          ori.b    #$0, d0
0101d298  00000000          ori.b    #$0, d0
0101d29c  00000000          ori.b    #$0, d0
0101d2a0  00000000          ori.b    #$0, d0
0101d2a4  00000000          ori.b    #$0, d0
0101d2a8  00000000          ori.b    #$0, d0
0101d2ac  00000000          ori.b    #$0, d0
0101d2b0  00000000          ori.b    #$0, d0
0101d2b4  00000000          ori.b    #$0, d0
0101d2b8  00000000          ori.b    #$0, d0
0101d2bc  00000000          ori.b    #$0, d0
0101d2c0  00000000          ori.b    #$0, d0
0101d2c4  00000000          ori.b    #$0, d0
0101d2c8  00000000          ori.b    #$0, d0
0101d2cc  00000000          ori.b    #$0, d0
0101d2d0  00000000          ori.b    #$0, d0
0101d2d4  00000000          ori.b    #$0, d0
0101d2d8  00000000          ori.b    #$0, d0
0101d2dc  00000000          ori.b    #$0, d0
0101d2e0  00000000          ori.b    #$0, d0
0101d2e4  00000000          ori.b    #$0, d0
0101d2e8  00000000          ori.b    #$0, d0
0101d2ec  00000000          ori.b    #$0, d0
0101d2f0  00000000          ori.b    #$0, d0
0101d2f4  00000000          ori.b    #$0, d0
0101d2f8  00000000          ori.b    #$0, d0
0101d2fc  00000000          ori.b    #$0, d0
0101d300  00000000          ori.b    #$0, d0
0101d304  00000000          ori.b    #$0, d0
0101d308  00000000          ori.b    #$0, d0
0101d30c  00000000          ori.b    #$0, d0
0101d310  00000000          ori.b    #$0, d0
0101d314  00000000          ori.b    #$0, d0
0101d318  00000000          ori.b    #$0, d0
0101d31c  00000000          ori.b    #$0, d0
0101d320  00000000          ori.b    #$0, d0
0101d324  00000000          ori.b    #$0, d0
0101d328  00000000          ori.b    #$0, d0
0101d32c  00000000          ori.b    #$0, d0
0101d330  00000000          ori.b    #$0, d0
0101d334  00000000          ori.b    #$0, d0
0101d338  00000000          ori.b    #$0, d0
0101d33c  00000000          ori.b    #$0, d0
0101d340  00000000          ori.b    #$0, d0
0101d344  00000000          ori.b    #$0, d0
0101d348  00000000          ori.b    #$0, d0
0101d34c  00000000          ori.b    #$0, d0
0101d350  00000000          ori.b    #$0, d0
0101d354  00000000          ori.b    #$0, d0
0101d358  00000000          ori.b    #$0, d0
0101d35c  00000000          ori.b    #$0, d0
0101d360  00000000          ori.b    #$0, d0
0101d364  00000000          ori.b    #$0, d0
0101d368  00000000          ori.b    #$0, d0
0101d36c  00000000          ori.b    #$0, d0
0101d370  00000000          ori.b    #$0, d0
0101d374  00000000          ori.b    #$0, d0
0101d378  00000000          ori.b    #$0, d0
0101d37c  00000000          ori.b    #$0, d0
0101d380  00000000          ori.b    #$0, d0
0101d384  00000000          ori.b    #$0, d0
0101d388  00000000          ori.b    #$0, d0
0101d38c  00000000          ori.b    #$0, d0
0101d390  00000000          ori.b    #$0, d0
0101d394  00000000          ori.b    #$0, d0
0101d398  00000000          ori.b    #$0, d0
0101d39c  00000000          ori.b    #$0, d0
0101d3a0  00000000          ori.b    #$0, d0
0101d3a4  00000000          ori.b    #$0, d0
0101d3a8  00000000          ori.b    #$0, d0
0101d3ac  00000000          ori.b    #$0, d0
0101d3b0  00000000          ori.b    #$0, d0
0101d3b4  00000000          ori.b    #$0, d0
0101d3b8  00000000          ori.b    #$0, d0
0101d3bc  00000000          ori.b    #$0, d0
0101d3c0  00000000          ori.b    #$0, d0
0101d3c4  00000000          ori.b    #$0, d0
0101d3c8  00000000          ori.b    #$0, d0
0101d3cc  00000000          ori.b    #$0, d0
0101d3d0  00000000          ori.b    #$0, d0
0101d3d4  00000000          ori.b    #$0, d0
0101d3d8  00000000          ori.b    #$0, d0
0101d3dc  00000000          ori.b    #$0, d0
0101d3e0  00000000          ori.b    #$0, d0
0101d3e4  00000000          ori.b    #$0, d0
0101d3e8  00000000          ori.b    #$0, d0
0101d3ec  00000000          ori.b    #$0, d0
0101d3f0  00000000          ori.b    #$0, d0
0101d3f4  00000000          ori.b    #$0, d0
0101d3f8  00000000          ori.b    #$0, d0
0101d3fc  00000000          ori.b    #$0, d0
0101d400  00000000          ori.b    #$0, d0
0101d404  00000000          ori.b    #$0, d0
0101d408  00000000          ori.b    #$0, d0
0101d40c  00000000          ori.b    #$0, d0
0101d410  00000000          ori.b    #$0, d0
0101d414  00000000          ori.b    #$0, d0
0101d418  00000000          ori.b    #$0, d0
0101d41c  00000000          ori.b    #$0, d0
0101d420  00000000          ori.b    #$0, d0
0101d424  00000000          ori.b    #$0, d0
0101d428  00000000          ori.b    #$0, d0
0101d42c  00000000          ori.b    #$0, d0
0101d430  00000000          ori.b    #$0, d0
0101d434  00000000          ori.b    #$0, d0
0101d438  00000000          ori.b    #$0, d0
0101d43c  00000000          ori.b    #$0, d0
0101d440  00000000          ori.b    #$0, d0
0101d444  00000000          ori.b    #$0, d0
0101d448  00000000          ori.b    #$0, d0
0101d44c  00000000          ori.b    #$0, d0
0101d450  00000000          ori.b    #$0, d0
0101d454  00000000          ori.b    #$0, d0
0101d458  00000000          ori.b    #$0, d0
0101d45c  00000000          ori.b    #$0, d0
0101d460  00000000          ori.b    #$0, d0
0101d464  00000000          ori.b    #$0, d0
0101d468  00000000          ori.b    #$0, d0
0101d46c  00000000          ori.b    #$0, d0
0101d470  00000000          ori.b    #$0, d0
0101d474  00000000          ori.b    #$0, d0
0101d478  00000000          ori.b    #$0, d0
0101d47c  00000000          ori.b    #$0, d0
0101d480  00000000          ori.b    #$0, d0
0101d484  00000000          ori.b    #$0, d0
0101d488  00000000          ori.b    #$0, d0
0101d48c  00000000          ori.b    #$0, d0
0101d490  00000000          ori.b    #$0, d0
0101d494  00000000          ori.b    #$0, d0
0101d498  00000000          ori.b    #$0, d0
0101d49c  00000000          ori.b    #$0, d0
0101d4a0  00000000          ori.b    #$0, d0
0101d4a4  00000000          ori.b    #$0, d0
0101d4a8  00000000          ori.b    #$0, d0
0101d4ac  00000000          ori.b    #$0, d0
0101d4b0  00000000          ori.b    #$0, d0
0101d4b4  00000000          ori.b    #$0, d0
0101d4b8  00000000          ori.b    #$0, d0
0101d4bc  00000000          ori.b    #$0, d0
0101d4c0  00000000          ori.b    #$0, d0
0101d4c4  00000000          ori.b    #$0, d0
0101d4c8  00000000          ori.b    #$0, d0
0101d4cc  00000000          ori.b    #$0, d0
0101d4d0  00000000          ori.b    #$0, d0
0101d4d4  00000000          ori.b    #$0, d0
0101d4d8  00000000          ori.b    #$0, d0
0101d4dc  00000000          ori.b    #$0, d0
0101d4e0  00000000          ori.b    #$0, d0
0101d4e4  00000000          ori.b    #$0, d0
0101d4e8  00000000          ori.b    #$0, d0
0101d4ec  00000000          ori.b    #$0, d0
0101d4f0  00000000          ori.b    #$0, d0
0101d4f4  00000000          ori.b    #$0, d0
0101d4f8  00000000          ori.b    #$0, d0
0101d4fc  00000000          ori.b    #$0, d0
0101d500  00000000          ori.b    #$0, d0
0101d504  00000000          ori.b    #$0, d0
0101d508  00000000          ori.b    #$0, d0
0101d50c  00000000          ori.b    #$0, d0
0101d510  00000000          ori.b    #$0, d0
0101d514  00000000          ori.b    #$0, d0
0101d518  00000000          ori.b    #$0, d0
0101d51c  00000000          ori.b    #$0, d0
0101d520  00000000          ori.b    #$0, d0
0101d524  00000000          ori.b    #$0, d0
0101d528  00000000          ori.b    #$0, d0
0101d52c  00000000          ori.b    #$0, d0
0101d530  00000000          ori.b    #$0, d0
0101d534  00000000          ori.b    #$0, d0
0101d538  00000000          ori.b    #$0, d0
0101d53c  00000000          ori.b    #$0, d0
0101d540  00000000          ori.b    #$0, d0
0101d544  00000000          ori.b    #$0, d0
0101d548  00000000          ori.b    #$0, d0
0101d54c  00000000          ori.b    #$0, d0
0101d550  00000000          ori.b    #$0, d0
0101d554  00000000          ori.b    #$0, d0
0101d558  00000000          ori.b    #$0, d0
0101d55c  00000000          ori.b    #$0, d0
0101d560  00000000          ori.b    #$0, d0
0101d564  00000000          ori.b    #$0, d0
0101d568  00000000          ori.b    #$0, d0
0101d56c  00000000          ori.b    #$0, d0
0101d570  00000000          ori.b    #$0, d0
0101d574  00000000          ori.b    #$0, d0
0101d578  00000000          ori.b    #$0, d0
0101d57c  00000000          ori.b    #$0, d0
0101d580  00000000          ori.b    #$0, d0
0101d584  00000000          ori.b    #$0, d0
0101d588  00000000          ori.b    #$0, d0
0101d58c  00000000          ori.b    #$0, d0
0101d590  00000000          ori.b    #$0, d0
0101d594  00000000          ori.b    #$0, d0
0101d598  00000000          ori.b    #$0, d0
0101d59c  00000000          ori.b    #$0, d0
0101d5a0  00000000          ori.b    #$0, d0
0101d5a4  00000000          ori.b    #$0, d0
0101d5a8  00000000          ori.b    #$0, d0
0101d5ac  00000000          ori.b    #$0, d0
0101d5b0  00000000          ori.b    #$0, d0
0101d5b4  00000000          ori.b    #$0, d0
0101d5b8  00000000          ori.b    #$0, d0
0101d5bc  00000000          ori.b    #$0, d0
0101d5c0  00000000          ori.b    #$0, d0
0101d5c4  00000000          ori.b    #$0, d0
0101d5c8  00000000          ori.b    #$0, d0
0101d5cc  00000000          ori.b    #$0, d0
0101d5d0  00000000          ori.b    #$0, d0
0101d5d4  00000000          ori.b    #$0, d0
0101d5d8  00000000          ori.b    #$0, d0
0101d5dc  00000000          ori.b    #$0, d0
0101d5e0  00000000          ori.b    #$0, d0
0101d5e4  00000000          ori.b    #$0, d0
0101d5e8  00000000          ori.b    #$0, d0
0101d5ec  00000000          ori.b    #$0, d0
0101d5f0  00000000          ori.b    #$0, d0
0101d5f4  00000000          ori.b    #$0, d0
0101d5f8  00000000          ori.b    #$0, d0
0101d5fc  00000000          ori.b    #$0, d0
0101d600  00000000          ori.b    #$0, d0
0101d604  00000000          ori.b    #$0, d0
0101d608  00000000          ori.b    #$0, d0
0101d60c  00000000          ori.b    #$0, d0
0101d610  00000000          ori.b    #$0, d0
0101d614  00000000          ori.b    #$0, d0
0101d618  00000000          ori.b    #$0, d0
0101d61c  00000000          ori.b    #$0, d0
0101d620  00000000          ori.b    #$0, d0
0101d624  00000000          ori.b    #$0, d0
0101d628  00000000          ori.b    #$0, d0
0101d62c  00000000          ori.b    #$0, d0
0101d630  00000000          ori.b    #$0, d0
0101d634  00000000          ori.b    #$0, d0
0101d638  00000000          ori.b    #$0, d0
0101d63c  00000000          ori.b    #$0, d0
0101d640  00000000          ori.b    #$0, d0
0101d644  00000000          ori.b    #$0, d0
0101d648  00000000          ori.b    #$0, d0
0101d64c  00000000          ori.b    #$0, d0
0101d650  00000000          ori.b    #$0, d0
0101d654  00000000          ori.b    #$0, d0
0101d658  00000000          ori.b    #$0, d0
0101d65c  00000000          ori.b    #$0, d0
0101d660  00000000          ori.b    #$0, d0
0101d664  00000000          ori.b    #$0, d0
0101d668  00000000          ori.b    #$0, d0
0101d66c  00000000          ori.b    #$0, d0
0101d670  00000000          ori.b    #$0, d0
0101d674  00000000          ori.b    #$0, d0
0101d678  00000000          ori.b    #$0, d0
0101d67c  00000000          ori.b    #$0, d0
0101d680  00000000          ori.b    #$0, d0
0101d684  00000000          ori.b    #$0, d0
0101d688  00000000          ori.b    #$0, d0
0101d68c  00000000          ori.b    #$0, d0
0101d690  00000000          ori.b    #$0, d0
0101d694  00000000          ori.b    #$0, d0
0101d698  00000000          ori.b    #$0, d0
0101d69c  00000000          ori.b    #$0, d0
0101d6a0  00000000          ori.b    #$0, d0
0101d6a4  00000000          ori.b    #$0, d0
0101d6a8  00000000          ori.b    #$0, d0
0101d6ac  00000000          ori.b    #$0, d0
0101d6b0  00000000          ori.b    #$0, d0
0101d6b4  00000000          ori.b    #$0, d0
0101d6b8  00000000          ori.b    #$0, d0
0101d6bc  00000000          ori.b    #$0, d0
0101d6c0  00000000          ori.b    #$0, d0
0101d6c4  00000000          ori.b    #$0, d0
0101d6c8  00000000          ori.b    #$0, d0
0101d6cc  00000000          ori.b    #$0, d0
0101d6d0  00000000          ori.b    #$0, d0
0101d6d4  00000000          ori.b    #$0, d0
0101d6d8  00000000          ori.b    #$0, d0
0101d6dc  00000000          ori.b    #$0, d0
0101d6e0  00000000          ori.b    #$0, d0
0101d6e4  00000000          ori.b    #$0, d0
0101d6e8  00000000          ori.b    #$0, d0
0101d6ec  00000000          ori.b    #$0, d0
0101d6f0  00000000          ori.b    #$0, d0
0101d6f4  00000000          ori.b    #$0, d0
0101d6f8  00000000          ori.b    #$0, d0
0101d6fc  00000000          ori.b    #$0, d0
0101d700  00000000          ori.b    #$0, d0
0101d704  00000000          ori.b    #$0, d0
0101d708  00000000          ori.b    #$0, d0
0101d70c  00000000          ori.b    #$0, d0
0101d710  00000000          ori.b    #$0, d0
0101d714  00000000          ori.b    #$0, d0
0101d718  00000000          ori.b    #$0, d0
0101d71c  00000000          ori.b    #$0, d0
0101d720  00000000          ori.b    #$0, d0
0101d724  00000000          ori.b    #$0, d0
0101d728  00000000          ori.b    #$0, d0
0101d72c  00000000          ori.b    #$0, d0
0101d730  00000000          ori.b    #$0, d0
0101d734  00000000          ori.b    #$0, d0
0101d738  00000000          ori.b    #$0, d0
0101d73c  00000000          ori.b    #$0, d0
0101d740  00000000          ori.b    #$0, d0
0101d744  00000000          ori.b    #$0, d0
0101d748  00000000          ori.b    #$0, d0
0101d74c  00000000          ori.b    #$0, d0
0101d750  00000000          ori.b    #$0, d0
0101d754  00000000          ori.b    #$0, d0
0101d758  00000000          ori.b    #$0, d0
0101d75c  00000000          ori.b    #$0, d0
0101d760  00000000          ori.b    #$0, d0
0101d764  00000000          ori.b    #$0, d0
0101d768  00000000          ori.b    #$0, d0
0101d76c  00000000          ori.b    #$0, d0
0101d770  00000000          ori.b    #$0, d0
0101d774  00000000          ori.b    #$0, d0
0101d778  00000000          ori.b    #$0, d0
0101d77c  00000000          ori.b    #$0, d0
0101d780  00000000          ori.b    #$0, d0
0101d784  00000000          ori.b    #$0, d0
0101d788  00000000          ori.b    #$0, d0
0101d78c  00000000          ori.b    #$0, d0
0101d790  00000000          ori.b    #$0, d0
0101d794  00000000          ori.b    #$0, d0
0101d798  00000000          ori.b    #$0, d0
0101d79c  00000000          ori.b    #$0, d0
0101d7a0  00000000          ori.b    #$0, d0
0101d7a4  00000000          ori.b    #$0, d0
0101d7a8  00000000          ori.b    #$0, d0
0101d7ac  00000000          ori.b    #$0, d0
0101d7b0  00000000          ori.b    #$0, d0
0101d7b4  00000000          ori.b    #$0, d0
0101d7b8  00000000          ori.b    #$0, d0
0101d7bc  00000000          ori.b    #$0, d0
0101d7c0  00000000          ori.b    #$0, d0
0101d7c4  00000000          ori.b    #$0, d0
0101d7c8  00000000          ori.b    #$0, d0
0101d7cc  00000000          ori.b    #$0, d0
0101d7d0  00000000          ori.b    #$0, d0
0101d7d4  00000000          ori.b    #$0, d0
0101d7d8  00000000          ori.b    #$0, d0
0101d7dc  00000000          ori.b    #$0, d0
0101d7e0  00000000          ori.b    #$0, d0
0101d7e4  00000000          ori.b    #$0, d0
0101d7e8  00000000          ori.b    #$0, d0
0101d7ec  00000000          ori.b    #$0, d0
0101d7f0  00000000          ori.b    #$0, d0
0101d7f4  00000000          ori.b    #$0, d0
0101d7f8  00000000          ori.b    #$0, d0
0101d7fc  00000000          ori.b    #$0, d0
0101d800  00000000          ori.b    #$0, d0
0101d804  00000000          ori.b    #$0, d0
0101d808  00000000          ori.b    #$0, d0
0101d80c  00000000          ori.b    #$0, d0
0101d810  00000000          ori.b    #$0, d0
0101d814  00000000          ori.b    #$0, d0
0101d818  00000000          ori.b    #$0, d0
0101d81c  00000000          ori.b    #$0, d0
0101d820  00000000          ori.b    #$0, d0
0101d824  00000000          ori.b    #$0, d0
0101d828  00000000          ori.b    #$0, d0
0101d82c  00000000          ori.b    #$0, d0
0101d830  00000000          ori.b    #$0, d0
0101d834  00000000          ori.b    #$0, d0
0101d838  00000000          ori.b    #$0, d0
0101d83c  00000000          ori.b    #$0, d0
0101d840  00000000          ori.b    #$0, d0
0101d844  00000000          ori.b    #$0, d0
0101d848  00000000          ori.b    #$0, d0
0101d84c  00000000          ori.b    #$0, d0
0101d850  00000000          ori.b    #$0, d0
0101d854  00000000          ori.b    #$0, d0
0101d858  00000000          ori.b    #$0, d0
0101d85c  00000000          ori.b    #$0, d0
0101d860  00000000          ori.b    #$0, d0
0101d864  00000000          ori.b    #$0, d0
0101d868  00000000          ori.b    #$0, d0
0101d86c  00000000          ori.b    #$0, d0
0101d870  00000000          ori.b    #$0, d0
0101d874  00000000          ori.b    #$0, d0
0101d878  00000000          ori.b    #$0, d0
0101d87c  00000000          ori.b    #$0, d0
0101d880  00000000          ori.b    #$0, d0
0101d884  00000000          ori.b    #$0, d0
0101d888  00000000          ori.b    #$0, d0
0101d88c  00000000          ori.b    #$0, d0
0101d890  00000000          ori.b    #$0, d0
0101d894  00000000          ori.b    #$0, d0
0101d898  00000000          ori.b    #$0, d0
0101d89c  00000000          ori.b    #$0, d0
0101d8a0  00000000          ori.b    #$0, d0
0101d8a4  00000000          ori.b    #$0, d0
0101d8a8  00000000          ori.b    #$0, d0
0101d8ac  00000000          ori.b    #$0, d0
0101d8b0  00000000          ori.b    #$0, d0
0101d8b4  00000000          ori.b    #$0, d0
0101d8b8  00000000          ori.b    #$0, d0
0101d8bc  00000000          ori.b    #$0, d0
0101d8c0  00000000          ori.b    #$0, d0
0101d8c4  00000000          ori.b    #$0, d0
0101d8c8  00000000          ori.b    #$0, d0
0101d8cc  00000000          ori.b    #$0, d0
0101d8d0  00000000          ori.b    #$0, d0
0101d8d4  00000000          ori.b    #$0, d0
0101d8d8  00000000          ori.b    #$0, d0
0101d8dc  00000000          ori.b    #$0, d0
0101d8e0  00000000          ori.b    #$0, d0
0101d8e4  00000000          ori.b    #$0, d0
0101d8e8  00000000          ori.b    #$0, d0
0101d8ec  00000000          ori.b    #$0, d0
0101d8f0  00000000          ori.b    #$0, d0
0101d8f4  00000000          ori.b    #$0, d0
0101d8f8  00000000          ori.b    #$0, d0
0101d8fc  00000000          ori.b    #$0, d0
0101d900  00000000          ori.b    #$0, d0
0101d904  00000000          ori.b    #$0, d0
0101d908  00000000          ori.b    #$0, d0
0101d90c  00000000          ori.b    #$0, d0
0101d910  00000000          ori.b    #$0, d0
0101d914  00000000          ori.b    #$0, d0
0101d918  00000000          ori.b    #$0, d0
0101d91c  00000000          ori.b    #$0, d0
0101d920  00000000          ori.b    #$0, d0
0101d924  00000000          ori.b    #$0, d0
0101d928  00000000          ori.b    #$0, d0
0101d92c  00000000          ori.b    #$0, d0
0101d930  00000000          ori.b    #$0, d0
0101d934  00000000          ori.b    #$0, d0
0101d938  00000000          ori.b    #$0, d0
0101d93c  00000000          ori.b    #$0, d0
0101d940  00000000          ori.b    #$0, d0
0101d944  00000000          ori.b    #$0, d0
0101d948  00000000          ori.b    #$0, d0
0101d94c  00000000          ori.b    #$0, d0
0101d950  00000000          ori.b    #$0, d0
0101d954  00000000          ori.b    #$0, d0
0101d958  00000000          ori.b    #$0, d0
0101d95c  00000000          ori.b    #$0, d0
0101d960  00000000          ori.b    #$0, d0
0101d964  00000000          ori.b    #$0, d0
0101d968  00000000          ori.b    #$0, d0
0101d96c  00000000          ori.b    #$0, d0
0101d970  00000000          ori.b    #$0, d0
0101d974  00000000          ori.b    #$0, d0
0101d978  00000000          ori.b    #$0, d0
0101d97c  00000000          ori.b    #$0, d0
0101d980  00000000          ori.b    #$0, d0
0101d984  00000000          ori.b    #$0, d0
0101d988  00000000          ori.b    #$0, d0
0101d98c  00000000          ori.b    #$0, d0
0101d990  00000000          ori.b    #$0, d0
0101d994  00000000          ori.b    #$0, d0
0101d998  00000000          ori.b    #$0, d0
0101d99c  00000000          ori.b    #$0, d0
0101d9a0  00000000          ori.b    #$0, d0
0101d9a4  00000000          ori.b    #$0, d0
0101d9a8  00000000          ori.b    #$0, d0
0101d9ac  00000000          ori.b    #$0, d0
0101d9b0  00000000          ori.b    #$0, d0
0101d9b4  00000000          ori.b    #$0, d0
0101d9b8  00000000          ori.b    #$0, d0
0101d9bc  00000000          ori.b    #$0, d0
0101d9c0  00000000          ori.b    #$0, d0
0101d9c4  00000000          ori.b    #$0, d0
0101d9c8  00000000          ori.b    #$0, d0
0101d9cc  00000000          ori.b    #$0, d0
0101d9d0  00000000          ori.b    #$0, d0
0101d9d4  00000000          ori.b    #$0, d0
0101d9d8  00000000          ori.b    #$0, d0
0101d9dc  00000000          ori.b    #$0, d0
0101d9e0  00000000          ori.b    #$0, d0
0101d9e4  00000000          ori.b    #$0, d0
0101d9e8  00000000          ori.b    #$0, d0
0101d9ec  00000000          ori.b    #$0, d0
0101d9f0  00000000          ori.b    #$0, d0
0101d9f4  00000000          ori.b    #$0, d0
0101d9f8  00000000          ori.b    #$0, d0
0101d9fc  00000000          ori.b    #$0, d0
0101da00  00000000          ori.b    #$0, d0
0101da04  00000000          ori.b    #$0, d0
0101da08  00000000          ori.b    #$0, d0
0101da0c  00000000          ori.b    #$0, d0
0101da10  00000000          ori.b    #$0, d0
0101da14  00000000          ori.b    #$0, d0
0101da18  00000000          ori.b    #$0, d0
0101da1c  00000000          ori.b    #$0, d0
0101da20  00000000          ori.b    #$0, d0
0101da24  00000000          ori.b    #$0, d0
0101da28  00000000          ori.b    #$0, d0
0101da2c  00000000          ori.b    #$0, d0
0101da30  00000000          ori.b    #$0, d0
0101da34  00000000          ori.b    #$0, d0
0101da38  00000000          ori.b    #$0, d0
0101da3c  00000000          ori.b    #$0, d0
0101da40  00000000          ori.b    #$0, d0
0101da44  00000000          ori.b    #$0, d0
0101da48  00000000          ori.b    #$0, d0
0101da4c  00000000          ori.b    #$0, d0
0101da50  00000000          ori.b    #$0, d0
0101da54  00000000          ori.b    #$0, d0
0101da58  00000000          ori.b    #$0, d0
0101da5c  00000000          ori.b    #$0, d0
0101da60  00000000          ori.b    #$0, d0
0101da64  00000000          ori.b    #$0, d0
0101da68  00000000          ori.b    #$0, d0
0101da6c  00000000          ori.b    #$0, d0
0101da70  00000000          ori.b    #$0, d0
0101da74  00000000          ori.b    #$0, d0
0101da78  00000000          ori.b    #$0, d0
0101da7c  00000000          ori.b    #$0, d0
0101da80  00000000          ori.b    #$0, d0
0101da84  00000000          ori.b    #$0, d0
0101da88  00000000          ori.b    #$0, d0
0101da8c  00000000          ori.b    #$0, d0
0101da90  00000000          ori.b    #$0, d0
0101da94  00000000          ori.b    #$0, d0
0101da98  00000000          ori.b    #$0, d0
0101da9c  00000000          ori.b    #$0, d0
0101daa0  00000000          ori.b    #$0, d0
0101daa4  00000000          ori.b    #$0, d0
0101daa8  00000000          ori.b    #$0, d0
0101daac  00000000          ori.b    #$0, d0
0101dab0  00000000          ori.b    #$0, d0
0101dab4  00000000          ori.b    #$0, d0
0101dab8  00000000          ori.b    #$0, d0
0101dabc  00000000          ori.b    #$0, d0
0101dac0  00000000          ori.b    #$0, d0
0101dac4  00000000          ori.b    #$0, d0
0101dac8  00000000          ori.b    #$0, d0
0101dacc  00000000          ori.b    #$0, d0
0101dad0  00000000          ori.b    #$0, d0
0101dad4  00000000          ori.b    #$0, d0
0101dad8  00000000          ori.b    #$0, d0
0101dadc  00000000          ori.b    #$0, d0
0101dae0  00000000          ori.b    #$0, d0
0101dae4  00000000          ori.b    #$0, d0
0101dae8  00000000          ori.b    #$0, d0
0101daec  00000000          ori.b    #$0, d0
0101daf0  00000000          ori.b    #$0, d0
0101daf4  00000000          ori.b    #$0, d0
0101daf8  00000000          ori.b    #$0, d0
0101dafc  00000000          ori.b    #$0, d0
0101db00  00000000          ori.b    #$0, d0
0101db04  00000000          ori.b    #$0, d0
0101db08  00000000          ori.b    #$0, d0
0101db0c  00000000          ori.b    #$0, d0
0101db10  00000000          ori.b    #$0, d0
0101db14  00000000          ori.b    #$0, d0
0101db18  00000000          ori.b    #$0, d0
0101db1c  00000000          ori.b    #$0, d0
0101db20  00000000          ori.b    #$0, d0
0101db24  00000000          ori.b    #$0, d0
0101db28  00000000          ori.b    #$0, d0
0101db2c  00000000          ori.b    #$0, d0
0101db30  00000000          ori.b    #$0, d0
0101db34  00000000          ori.b    #$0, d0
0101db38  00000000          ori.b    #$0, d0
0101db3c  00000000          ori.b    #$0, d0
0101db40  00000000          ori.b    #$0, d0
0101db44  00000000          ori.b    #$0, d0
0101db48  00000000          ori.b    #$0, d0
0101db4c  00000000          ori.b    #$0, d0
0101db50  00000000          ori.b    #$0, d0
0101db54  00000000          ori.b    #$0, d0
0101db58  00000000          ori.b    #$0, d0
0101db5c  00000000          ori.b    #$0, d0
0101db60  00000000          ori.b    #$0, d0
0101db64  00000000          ori.b    #$0, d0
0101db68  00000000          ori.b    #$0, d0
0101db6c  00000000          ori.b    #$0, d0
0101db70  00000000          ori.b    #$0, d0
0101db74  00000000          ori.b    #$0, d0
0101db78  00000000          ori.b    #$0, d0
0101db7c  00000000          ori.b    #$0, d0
0101db80  00000000          ori.b    #$0, d0
0101db84  00000000          ori.b    #$0, d0
0101db88  00000000          ori.b    #$0, d0
0101db8c  00000000          ori.b    #$0, d0
0101db90  00000000          ori.b    #$0, d0
0101db94  00000000          ori.b    #$0, d0
0101db98  00000000          ori.b    #$0, d0
0101db9c  00000000          ori.b    #$0, d0
0101dba0  00000000          ori.b    #$0, d0
0101dba4  00000000          ori.b    #$0, d0
0101dba8  00000000          ori.b    #$0, d0
0101dbac  00000000          ori.b    #$0, d0
0101dbb0  00000000          ori.b    #$0, d0
0101dbb4  00000000          ori.b    #$0, d0
0101dbb8  00000000          ori.b    #$0, d0
0101dbbc  00000000          ori.b    #$0, d0
0101dbc0  00000000          ori.b    #$0, d0
0101dbc4  00000000          ori.b    #$0, d0
0101dbc8  00000000          ori.b    #$0, d0
0101dbcc  00000000          ori.b    #$0, d0
0101dbd0  00000000          ori.b    #$0, d0
0101dbd4  00000000          ori.b    #$0, d0
0101dbd8  00000000          ori.b    #$0, d0
0101dbdc  00000000          ori.b    #$0, d0
0101dbe0  00000000          ori.b    #$0, d0
0101dbe4  00000000          ori.b    #$0, d0
0101dbe8  00000000          ori.b    #$0, d0
0101dbec  00000000          ori.b    #$0, d0
0101dbf0  00000000          ori.b    #$0, d0
0101dbf4  00000000          ori.b    #$0, d0
0101dbf8  00000000          ori.b    #$0, d0
0101dbfc  00000000          ori.b    #$0, d0
0101dc00  00000000          ori.b    #$0, d0
0101dc04  00000000          ori.b    #$0, d0
0101dc08  00000000          ori.b    #$0, d0
0101dc0c  00000000          ori.b    #$0, d0
0101dc10  00000000          ori.b    #$0, d0
0101dc14  00000000          ori.b    #$0, d0
0101dc18  00000000          ori.b    #$0, d0
0101dc1c  00000000          ori.b    #$0, d0
0101dc20  00000000          ori.b    #$0, d0
0101dc24  00000000          ori.b    #$0, d0
0101dc28  00000000          ori.b    #$0, d0
0101dc2c  00000000          ori.b    #$0, d0
0101dc30  00000000          ori.b    #$0, d0
0101dc34  00000000          ori.b    #$0, d0
0101dc38  00000000          ori.b    #$0, d0
0101dc3c  00000000          ori.b    #$0, d0
0101dc40  00000000          ori.b    #$0, d0
0101dc44  00000000          ori.b    #$0, d0
0101dc48  00000000          ori.b    #$0, d0
0101dc4c  00000000          ori.b    #$0, d0
0101dc50  00000000          ori.b    #$0, d0
0101dc54  00000000          ori.b    #$0, d0
0101dc58  00000000          ori.b    #$0, d0
0101dc5c  00000000          ori.b    #$0, d0
0101dc60  00000000          ori.b    #$0, d0
0101dc64  00000000          ori.b    #$0, d0
0101dc68  00000000          ori.b    #$0, d0
0101dc6c  00000000          ori.b    #$0, d0
0101dc70  00000000          ori.b    #$0, d0
0101dc74  00000000          ori.b    #$0, d0
0101dc78  00000000          ori.b    #$0, d0
0101dc7c  00000000          ori.b    #$0, d0
0101dc80  00000000          ori.b    #$0, d0
0101dc84  00000000          ori.b    #$0, d0
0101dc88  00000000          ori.b    #$0, d0
0101dc8c  00000000          ori.b    #$0, d0
0101dc90  00000000          ori.b    #$0, d0
0101dc94  00000000          ori.b    #$0, d0
0101dc98  00000000          ori.b    #$0, d0
0101dc9c  00000000          ori.b    #$0, d0
0101dca0  00000000          ori.b    #$0, d0
0101dca4  00000000          ori.b    #$0, d0
0101dca8  00000000          ori.b    #$0, d0
0101dcac  00000000          ori.b    #$0, d0
0101dcb0  00000000          ori.b    #$0, d0
0101dcb4  00000000          ori.b    #$0, d0
0101dcb8  00000000          ori.b    #$0, d0
0101dcbc  00000000          ori.b    #$0, d0
0101dcc0  00000000          ori.b    #$0, d0
0101dcc4  00000000          ori.b    #$0, d0
0101dcc8  00000000          ori.b    #$0, d0
0101dccc  00000000          ori.b    #$0, d0
0101dcd0  00000000          ori.b    #$0, d0
0101dcd4  00000000          ori.b    #$0, d0
0101dcd8  00000000          ori.b    #$0, d0
0101dcdc  00000000          ori.b    #$0, d0
0101dce0  00000000          ori.b    #$0, d0
0101dce4  00000000          ori.b    #$0, d0
0101dce8  00000000          ori.b    #$0, d0
0101dcec  00000000          ori.b    #$0, d0
0101dcf0  00000000          ori.b    #$0, d0
0101dcf4  00000000          ori.b    #$0, d0
0101dcf8  00000000          ori.b    #$0, d0
0101dcfc  00000000          ori.b    #$0, d0
0101dd00  00000000          ori.b    #$0, d0
0101dd04  00000000          ori.b    #$0, d0
0101dd08  00000000          ori.b    #$0, d0
0101dd0c  00000000          ori.b    #$0, d0
0101dd10  00000000          ori.b    #$0, d0
0101dd14  00000000          ori.b    #$0, d0
0101dd18  00000000          ori.b    #$0, d0
0101dd1c  00000000          ori.b    #$0, d0
0101dd20  00000000          ori.b    #$0, d0
0101dd24  00000000          ori.b    #$0, d0
0101dd28  00000000          ori.b    #$0, d0
0101dd2c  00000000          ori.b    #$0, d0
0101dd30  00000000          ori.b    #$0, d0
0101dd34  00000000          ori.b    #$0, d0
0101dd38  00000000          ori.b    #$0, d0
0101dd3c  00000000          ori.b    #$0, d0
0101dd40  00000000          ori.b    #$0, d0
0101dd44  00000000          ori.b    #$0, d0
0101dd48  00000000          ori.b    #$0, d0
0101dd4c  00000000          ori.b    #$0, d0
0101dd50  00000000          ori.b    #$0, d0
0101dd54  00000000          ori.b    #$0, d0
0101dd58  00000000          ori.b    #$0, d0
0101dd5c  00000000          ori.b    #$0, d0
0101dd60  00000000          ori.b    #$0, d0
0101dd64  00000000          ori.b    #$0, d0
0101dd68  00000000          ori.b    #$0, d0
0101dd6c  00000000          ori.b    #$0, d0
0101dd70  00000000          ori.b    #$0, d0
0101dd74  00000000          ori.b    #$0, d0
0101dd78  00000000          ori.b    #$0, d0
0101dd7c  00000000          ori.b    #$0, d0
0101dd80  00000000          ori.b    #$0, d0
0101dd84  00000000          ori.b    #$0, d0
0101dd88  00000000          ori.b    #$0, d0
0101dd8c  00000000          ori.b    #$0, d0
0101dd90  00000000          ori.b    #$0, d0
0101dd94  00000000          ori.b    #$0, d0
0101dd98  00000000          ori.b    #$0, d0
0101dd9c  00000000          ori.b    #$0, d0
0101dda0  00000000          ori.b    #$0, d0
0101dda4  00000000          ori.b    #$0, d0
0101dda8  00000000          ori.b    #$0, d0
0101ddac  00000000          ori.b    #$0, d0
0101ddb0  00000000          ori.b    #$0, d0
0101ddb4  00000000          ori.b    #$0, d0
0101ddb8  00000000          ori.b    #$0, d0
0101ddbc  00000000          ori.b    #$0, d0
0101ddc0  00000000          ori.b    #$0, d0
0101ddc4  00000000          ori.b    #$0, d0
0101ddc8  00000000          ori.b    #$0, d0
0101ddcc  00000000          ori.b    #$0, d0
0101ddd0  00000000          ori.b    #$0, d0
0101ddd4  00000000          ori.b    #$0, d0
0101ddd8  00000000          ori.b    #$0, d0
0101dddc  00000000          ori.b    #$0, d0
0101dde0  00000000          ori.b    #$0, d0
0101dde4  00000000          ori.b    #$0, d0
0101dde8  00000000          ori.b    #$0, d0
0101ddec  00000000          ori.b    #$0, d0
0101ddf0  00000000          ori.b    #$0, d0
0101ddf4  00000000          ori.b    #$0, d0
0101ddf8  00000000          ori.b    #$0, d0
0101ddfc  00000000          ori.b    #$0, d0
0101de00  00000000          ori.b    #$0, d0
0101de04  00000000          ori.b    #$0, d0
0101de08  00000000          ori.b    #$0, d0
0101de0c  00000000          ori.b    #$0, d0
0101de10  00000000          ori.b    #$0, d0
0101de14  00000000          ori.b    #$0, d0
0101de18  00000000          ori.b    #$0, d0
0101de1c  00000000          ori.b    #$0, d0
0101de20  00000000          ori.b    #$0, d0
0101de24  00000000          ori.b    #$0, d0
0101de28  00000000          ori.b    #$0, d0
0101de2c  00000000          ori.b    #$0, d0
0101de30  00000000          ori.b    #$0, d0
0101de34  00000000          ori.b    #$0, d0
0101de38  00000000          ori.b    #$0, d0
0101de3c  00000000          ori.b    #$0, d0
0101de40  00000000          ori.b    #$0, d0
0101de44  00000000          ori.b    #$0, d0
0101de48  00000000          ori.b    #$0, d0
0101de4c  00000000          ori.b    #$0, d0
0101de50  00000000          ori.b    #$0, d0
0101de54  00000000          ori.b    #$0, d0
0101de58  00000000          ori.b    #$0, d0
0101de5c  00000000          ori.b    #$0, d0
0101de60  00000000          ori.b    #$0, d0
0101de64  00000000          ori.b    #$0, d0
0101de68  00000000          ori.b    #$0, d0
0101de6c  00000000          ori.b    #$0, d0
0101de70  00000000          ori.b    #$0, d0
0101de74  00000000          ori.b    #$0, d0
0101de78  00000000          ori.b    #$0, d0
0101de7c  00000000          ori.b    #$0, d0
0101de80  00000000          ori.b    #$0, d0
0101de84  00000000          ori.b    #$0, d0
0101de88  00000000          ori.b    #$0, d0
0101de8c  00000000          ori.b    #$0, d0
0101de90  00000000          ori.b    #$0, d0
0101de94  00000000          ori.b    #$0, d0
0101de98  00000000          ori.b    #$0, d0
0101de9c  00000000          ori.b    #$0, d0
0101dea0  00000000          ori.b    #$0, d0
0101dea4  00000000          ori.b    #$0, d0
0101dea8  00000000          ori.b    #$0, d0
0101deac  00000000          ori.b    #$0, d0
0101deb0  00000000          ori.b    #$0, d0
0101deb4  00000000          ori.b    #$0, d0
0101deb8  00000000          ori.b    #$0, d0
0101debc  00000000          ori.b    #$0, d0
0101dec0  00000000          ori.b    #$0, d0
0101dec4  00000000          ori.b    #$0, d0
0101dec8  00000000          ori.b    #$0, d0
0101decc  00000000          ori.b    #$0, d0
0101ded0  00000000          ori.b    #$0, d0
0101ded4  00000000          ori.b    #$0, d0
0101ded8  00000000          ori.b    #$0, d0
0101dedc  00000000          ori.b    #$0, d0
0101dee0  00000000          ori.b    #$0, d0
0101dee4  00000000          ori.b    #$0, d0
0101dee8  00000000          ori.b    #$0, d0
0101deec  00000000          ori.b    #$0, d0
0101def0  00000000          ori.b    #$0, d0
0101def4  00000000          ori.b    #$0, d0
0101def8  00000000          ori.b    #$0, d0
0101defc  00000000          ori.b    #$0, d0
0101df00  00000000          ori.b    #$0, d0
0101df04  00000000          ori.b    #$0, d0
0101df08  00000000          ori.b    #$0, d0
0101df0c  00000000          ori.b    #$0, d0
0101df10  00000000          ori.b    #$0, d0
0101df14  00000000          ori.b    #$0, d0
0101df18  00000000          ori.b    #$0, d0
0101df1c  00000000          ori.b    #$0, d0
0101df20  00000000          ori.b    #$0, d0
0101df24  00000000          ori.b    #$0, d0
0101df28  00000000          ori.b    #$0, d0
0101df2c  00000000          ori.b    #$0, d0
0101df30  00000000          ori.b    #$0, d0
0101df34  00000000          ori.b    #$0, d0
0101df38  00000000          ori.b    #$0, d0
0101df3c  00000000          ori.b    #$0, d0
0101df40  00000000          ori.b    #$0, d0
0101df44  00000000          ori.b    #$0, d0
0101df48  00000000          ori.b    #$0, d0
0101df4c  00000000          ori.b    #$0, d0
0101df50  00000000          ori.b    #$0, d0
0101df54  00000000          ori.b    #$0, d0
0101df58  00000000          ori.b    #$0, d0
0101df5c  00000000          ori.b    #$0, d0
0101df60  00000000          ori.b    #$0, d0
0101df64  00000000          ori.b    #$0, d0
0101df68  00000000          ori.b    #$0, d0
0101df6c  00000000          ori.b    #$0, d0
0101df70  00000000          ori.b    #$0, d0
0101df74  00000000          ori.b    #$0, d0
0101df78  00000000          ori.b    #$0, d0
0101df7c  00000000          ori.b    #$0, d0
0101df80  00000000          ori.b    #$0, d0
0101df84  00000000          ori.b    #$0, d0
0101df88  00000000          ori.b    #$0, d0
0101df8c  00000000          ori.b    #$0, d0
0101df90  00000000          ori.b    #$0, d0
0101df94  00000000          ori.b    #$0, d0
0101df98  00000000          ori.b    #$0, d0
0101df9c  00000000          ori.b    #$0, d0
0101dfa0  00000000          ori.b    #$0, d0
0101dfa4  00000000          ori.b    #$0, d0
0101dfa8  00000000          ori.b    #$0, d0
0101dfac  00000000          ori.b    #$0, d0
0101dfb0  00000000          ori.b    #$0, d0
0101dfb4  00000000          ori.b    #$0, d0
0101dfb8  00000000          ori.b    #$0, d0
0101dfbc  00000000          ori.b    #$0, d0
0101dfc0  00000000          ori.b    #$0, d0
0101dfc4  00000000          ori.b    #$0, d0
0101dfc8  00000000          ori.b    #$0, d0
0101dfcc  00000000          ori.b    #$0, d0
0101dfd0  00000000          ori.b    #$0, d0
0101dfd4  00000000          ori.b    #$0, d0
0101dfd8  00000000          ori.b    #$0, d0
0101dfdc  00000000          ori.b    #$0, d0
0101dfe0  00000000          ori.b    #$0, d0
0101dfe4  00000000          ori.b    #$0, d0
0101dfe8  00000000          ori.b    #$0, d0
0101dfec  00000000          ori.b    #$0, d0
0101dff0  00000000          ori.b    #$0, d0
0101dff4  00000000          ori.b    #$0, d0
0101dff8  00000000          ori.b    #$0, d0
0101dffc  00000000          ori.b    #$0, d0
0101e000  00000000          ori.b    #$0, d0
0101e004  00000000          ori.b    #$0, d0
0101e008  00000000          ori.b    #$0, d0
0101e00c  00000000          ori.b    #$0, d0
0101e010  00000000          ori.b    #$0, d0
0101e014  00000000          ori.b    #$0, d0
0101e018  00000000          ori.b    #$0, d0
0101e01c  00000000          ori.b    #$0, d0
0101e020  00000000          ori.b    #$0, d0
0101e024  00000000          ori.b    #$0, d0
0101e028  00000000          ori.b    #$0, d0
0101e02c  00000000          ori.b    #$0, d0
0101e030  00000000          ori.b    #$0, d0
0101e034  00000000          ori.b    #$0, d0
0101e038  00000000          ori.b    #$0, d0
0101e03c  00000000          ori.b    #$0, d0
0101e040  00000000          ori.b    #$0, d0
0101e044  00000000          ori.b    #$0, d0
0101e048  00000000          ori.b    #$0, d0
0101e04c  00000000          ori.b    #$0, d0
0101e050  00000000          ori.b    #$0, d0
0101e054  00000000          ori.b    #$0, d0
0101e058  00000000          ori.b    #$0, d0
0101e05c  00000000          ori.b    #$0, d0
0101e060  00000000          ori.b    #$0, d0
0101e064  00000000          ori.b    #$0, d0
0101e068  00000000          ori.b    #$0, d0
0101e06c  00000000          ori.b    #$0, d0
0101e070  00000000          ori.b    #$0, d0
0101e074  00000000          ori.b    #$0, d0
0101e078  00000000          ori.b    #$0, d0
0101e07c  00000000          ori.b    #$0, d0
0101e080  00000000          ori.b    #$0, d0
0101e084  00000000          ori.b    #$0, d0
0101e088  00000000          ori.b    #$0, d0
0101e08c  00000000          ori.b    #$0, d0
0101e090  00000000          ori.b    #$0, d0
0101e094  00000000          ori.b    #$0, d0
0101e098  00000000          ori.b    #$0, d0
0101e09c  00000000          ori.b    #$0, d0
0101e0a0  00000000          ori.b    #$0, d0
0101e0a4  00000000          ori.b    #$0, d0
0101e0a8  00000000          ori.b    #$0, d0
0101e0ac  00000000          ori.b    #$0, d0
0101e0b0  00000000          ori.b    #$0, d0
0101e0b4  00000000          ori.b    #$0, d0
0101e0b8  00000000          ori.b    #$0, d0
0101e0bc  00000000          ori.b    #$0, d0
0101e0c0  00000000          ori.b    #$0, d0
0101e0c4  00000000          ori.b    #$0, d0
0101e0c8  00000000          ori.b    #$0, d0
0101e0cc  00000000          ori.b    #$0, d0
0101e0d0  00000000          ori.b    #$0, d0
0101e0d4  00000000          ori.b    #$0, d0
0101e0d8  00000000          ori.b    #$0, d0
0101e0dc  00000000          ori.b    #$0, d0
0101e0e0  00000000          ori.b    #$0, d0
0101e0e4  00000000          ori.b    #$0, d0
0101e0e8  00000000          ori.b    #$0, d0
0101e0ec  00000000          ori.b    #$0, d0
0101e0f0  00000000          ori.b    #$0, d0
0101e0f4  00000000          ori.b    #$0, d0
0101e0f8  00000000          ori.b    #$0, d0
0101e0fc  00000000          ori.b    #$0, d0
0101e100  00000000          ori.b    #$0, d0
0101e104  00000000          ori.b    #$0, d0
0101e108  00000000          ori.b    #$0, d0
0101e10c  00000000          ori.b    #$0, d0
0101e110  00000000          ori.b    #$0, d0
0101e114  00000000          ori.b    #$0, d0
0101e118  00000000          ori.b    #$0, d0
0101e11c  00000000          ori.b    #$0, d0
0101e120  00000000          ori.b    #$0, d0
0101e124  00000000          ori.b    #$0, d0
0101e128  00000000          ori.b    #$0, d0
0101e12c  00000000          ori.b    #$0, d0
0101e130  00000000          ori.b    #$0, d0
0101e134  00000000          ori.b    #$0, d0
0101e138  00000000          ori.b    #$0, d0
0101e13c  00000000          ori.b    #$0, d0
0101e140  00000000          ori.b    #$0, d0
0101e144  00000000          ori.b    #$0, d0
0101e148  00000000          ori.b    #$0, d0
0101e14c  00000000          ori.b    #$0, d0
0101e150  00000000          ori.b    #$0, d0
0101e154  00000000          ori.b    #$0, d0
0101e158  00000000          ori.b    #$0, d0
0101e15c  00000000          ori.b    #$0, d0
0101e160  00000000          ori.b    #$0, d0
0101e164  00000000          ori.b    #$0, d0
0101e168  00000000          ori.b    #$0, d0
0101e16c  00000000          ori.b    #$0, d0
0101e170  00000000          ori.b    #$0, d0
0101e174  00000000          ori.b    #$0, d0
0101e178  00000000          ori.b    #$0, d0
0101e17c  00000000          ori.b    #$0, d0
0101e180  00000000          ori.b    #$0, d0
0101e184  00000000          ori.b    #$0, d0
0101e188  00000000          ori.b    #$0, d0
0101e18c  00000000          ori.b    #$0, d0
0101e190  00000000          ori.b    #$0, d0
0101e194  00000000          ori.b    #$0, d0
0101e198  00000000          ori.b    #$0, d0
0101e19c  00000000          ori.b    #$0, d0
0101e1a0  00000000          ori.b    #$0, d0
0101e1a4  00000000          ori.b    #$0, d0
0101e1a8  00000000          ori.b    #$0, d0
0101e1ac  00000000          ori.b    #$0, d0
0101e1b0  00000000          ori.b    #$0, d0
0101e1b4  00000000          ori.b    #$0, d0
0101e1b8  00000000          ori.b    #$0, d0
0101e1bc  00000000          ori.b    #$0, d0
0101e1c0  00000000          ori.b    #$0, d0
0101e1c4  00000000          ori.b    #$0, d0
0101e1c8  00000000          ori.b    #$0, d0
0101e1cc  00000000          ori.b    #$0, d0
0101e1d0  00000000          ori.b    #$0, d0
0101e1d4  00000000          ori.b    #$0, d0
0101e1d8  00000000          ori.b    #$0, d0
0101e1dc  00000000          ori.b    #$0, d0
0101e1e0  00000000          ori.b    #$0, d0
0101e1e4  00000000          ori.b    #$0, d0
0101e1e8  00000000          ori.b    #$0, d0
0101e1ec  00000000          ori.b    #$0, d0
0101e1f0  00000000          ori.b    #$0, d0
0101e1f4  00000000          ori.b    #$0, d0
0101e1f8  00000000          ori.b    #$0, d0
0101e1fc  00000000          ori.b    #$0, d0
0101e200  00000000          ori.b    #$0, d0
0101e204  00000000          ori.b    #$0, d0
0101e208  00000000          ori.b    #$0, d0
0101e20c  00000000          ori.b    #$0, d0
0101e210  00000000          ori.b    #$0, d0
0101e214  00000000          ori.b    #$0, d0
0101e218  00000000          ori.b    #$0, d0
0101e21c  00000000          ori.b    #$0, d0
0101e220  00000000          ori.b    #$0, d0
0101e224  00000000          ori.b    #$0, d0
0101e228  00000000          ori.b    #$0, d0
0101e22c  00000000          ori.b    #$0, d0
0101e230  00000000          ori.b    #$0, d0
0101e234  00000000          ori.b    #$0, d0
0101e238  00000000          ori.b    #$0, d0
0101e23c  00000000          ori.b    #$0, d0
0101e240  00000000          ori.b    #$0, d0
0101e244  00000000          ori.b    #$0, d0
0101e248  00000000          ori.b    #$0, d0
0101e24c  00000000          ori.b    #$0, d0
0101e250  00000000          ori.b    #$0, d0
0101e254  00000000          ori.b    #$0, d0
0101e258  00000000          ori.b    #$0, d0
0101e25c  00000000          ori.b    #$0, d0
0101e260  00000000          ori.b    #$0, d0
0101e264  00000000          ori.b    #$0, d0
0101e268  00000000          ori.b    #$0, d0
0101e26c  00000000          ori.b    #$0, d0
0101e270  00000000          ori.b    #$0, d0
0101e274  00000000          ori.b    #$0, d0
0101e278  00000000          ori.b    #$0, d0
0101e27c  00000000          ori.b    #$0, d0
0101e280  00000000          ori.b    #$0, d0
0101e284  00000000          ori.b    #$0, d0
0101e288  00000000          ori.b    #$0, d0
0101e28c  00000000          ori.b    #$0, d0
0101e290  00000000          ori.b    #$0, d0
0101e294  00000000          ori.b    #$0, d0
0101e298  00000000          ori.b    #$0, d0
0101e29c  00000000          ori.b    #$0, d0
0101e2a0  00000000          ori.b    #$0, d0
0101e2a4  00000000          ori.b    #$0, d0
0101e2a8  00000000          ori.b    #$0, d0
0101e2ac  00000000          ori.b    #$0, d0
0101e2b0  00000000          ori.b    #$0, d0
0101e2b4  00000000          ori.b    #$0, d0
0101e2b8  00000000          ori.b    #$0, d0
0101e2bc  00000000          ori.b    #$0, d0
0101e2c0  00000000          ori.b    #$0, d0
0101e2c4  00000000          ori.b    #$0, d0
0101e2c8  00000000          ori.b    #$0, d0
0101e2cc  00000000          ori.b    #$0, d0
0101e2d0  00000000          ori.b    #$0, d0
0101e2d4  00000000          ori.b    #$0, d0
0101e2d8  00000000          ori.b    #$0, d0
0101e2dc  00000000          ori.b    #$0, d0
0101e2e0  00000000          ori.b    #$0, d0
0101e2e4  00000000          ori.b    #$0, d0
0101e2e8  00000000          ori.b    #$0, d0
0101e2ec  00000000          ori.b    #$0, d0
0101e2f0  00000000          ori.b    #$0, d0
0101e2f4  00000000          ori.b    #$0, d0
0101e2f8  00000000          ori.b    #$0, d0
0101e2fc  00000000          ori.b    #$0, d0
0101e300  00000000          ori.b    #$0, d0
0101e304  00000000          ori.b    #$0, d0
0101e308  00000000          ori.b    #$0, d0
0101e30c  00000000          ori.b    #$0, d0
0101e310  00000000          ori.b    #$0, d0
0101e314  00000000          ori.b    #$0, d0
0101e318  00000000          ori.b    #$0, d0
0101e31c  00000000          ori.b    #$0, d0
0101e320  00000000          ori.b    #$0, d0
0101e324  00000000          ori.b    #$0, d0
0101e328  00000000          ori.b    #$0, d0
0101e32c  00000000          ori.b    #$0, d0
0101e330  00000000          ori.b    #$0, d0
0101e334  00000000          ori.b    #$0, d0
0101e338  00000000          ori.b    #$0, d0
0101e33c  00000000          ori.b    #$0, d0
0101e340  00000000          ori.b    #$0, d0
0101e344  00000000          ori.b    #$0, d0
0101e348  00000000          ori.b    #$0, d0
0101e34c  00000000          ori.b    #$0, d0
0101e350  00000000          ori.b    #$0, d0
0101e354  00000000          ori.b    #$0, d0
0101e358  00000000          ori.b    #$0, d0
0101e35c  00000000          ori.b    #$0, d0
0101e360  00000000          ori.b    #$0, d0
0101e364  00000000          ori.b    #$0, d0
0101e368  00000000          ori.b    #$0, d0
0101e36c  00000000          ori.b    #$0, d0
0101e370  00000000          ori.b    #$0, d0
0101e374  00000000          ori.b    #$0, d0
0101e378  00000000          ori.b    #$0, d0
0101e37c  00000000          ori.b    #$0, d0
0101e380  00000000          ori.b    #$0, d0
0101e384  00000000          ori.b    #$0, d0
0101e388  00000000          ori.b    #$0, d0
0101e38c  00000000          ori.b    #$0, d0
0101e390  00000000          ori.b    #$0, d0
0101e394  00000000          ori.b    #$0, d0
0101e398  00000000          ori.b    #$0, d0
0101e39c  00000000          ori.b    #$0, d0
0101e3a0  00000000          ori.b    #$0, d0
0101e3a4  00000000          ori.b    #$0, d0
0101e3a8  00000000          ori.b    #$0, d0
0101e3ac  00000000          ori.b    #$0, d0
0101e3b0  00000000          ori.b    #$0, d0
0101e3b4  00000000          ori.b    #$0, d0
0101e3b8  00000000          ori.b    #$0, d0
0101e3bc  00000000          ori.b    #$0, d0
0101e3c0  00000000          ori.b    #$0, d0
0101e3c4  00000000          ori.b    #$0, d0
0101e3c8  00000000          ori.b    #$0, d0
0101e3cc  00000000          ori.b    #$0, d0
0101e3d0  00000000          ori.b    #$0, d0
0101e3d4  00000000          ori.b    #$0, d0
0101e3d8  00000000          ori.b    #$0, d0
0101e3dc  00000000          ori.b    #$0, d0
0101e3e0  00000000          ori.b    #$0, d0
0101e3e4  00000000          ori.b    #$0, d0
0101e3e8  00000000          ori.b    #$0, d0
0101e3ec  00000000          ori.b    #$0, d0
0101e3f0  00000000          ori.b    #$0, d0
0101e3f4  00000000          ori.b    #$0, d0
0101e3f8  00000000          ori.b    #$0, d0
0101e3fc  00000000          ori.b    #$0, d0
0101e400  00000000          ori.b    #$0, d0
0101e404  00000000          ori.b    #$0, d0
0101e408  00000000          ori.b    #$0, d0
0101e40c  00000000          ori.b    #$0, d0
0101e410  00000000          ori.b    #$0, d0
0101e414  00000000          ori.b    #$0, d0
0101e418  00000000          ori.b    #$0, d0
0101e41c  00000000          ori.b    #$0, d0
0101e420  00000000          ori.b    #$0, d0
0101e424  00000000          ori.b    #$0, d0
0101e428  00000000          ori.b    #$0, d0
0101e42c  00000000          ori.b    #$0, d0
0101e430  00000000          ori.b    #$0, d0
0101e434  00000000          ori.b    #$0, d0
0101e438  00000000          ori.b    #$0, d0
0101e43c  00000000          ori.b    #$0, d0
0101e440  00000000          ori.b    #$0, d0
0101e444  00000000          ori.b    #$0, d0
0101e448  00000000          ori.b    #$0, d0
0101e44c  00000000          ori.b    #$0, d0
0101e450  00000000          ori.b    #$0, d0
0101e454  00000000          ori.b    #$0, d0
0101e458  00000000          ori.b    #$0, d0
0101e45c  00000000          ori.b    #$0, d0
0101e460  00000000          ori.b    #$0, d0
0101e464  00000000          ori.b    #$0, d0
0101e468  00000000          ori.b    #$0, d0
0101e46c  00000000          ori.b    #$0, d0
0101e470  00000000          ori.b    #$0, d0
0101e474  00000000          ori.b    #$0, d0
0101e478  00000000          ori.b    #$0, d0
0101e47c  00000000          ori.b    #$0, d0
0101e480  00000000          ori.b    #$0, d0
0101e484  00000000          ori.b    #$0, d0
0101e488  00000000          ori.b    #$0, d0
0101e48c  00000000          ori.b    #$0, d0
0101e490  00000000          ori.b    #$0, d0
0101e494  00000000          ori.b    #$0, d0
0101e498  00000000          ori.b    #$0, d0
0101e49c  00000000          ori.b    #$0, d0
0101e4a0  00000000          ori.b    #$0, d0
0101e4a4  00000000          ori.b    #$0, d0
0101e4a8  00000000          ori.b    #$0, d0
0101e4ac  00000000          ori.b    #$0, d0
0101e4b0  00000000          ori.b    #$0, d0
0101e4b4  00000000          ori.b    #$0, d0
0101e4b8  00000000          ori.b    #$0, d0
0101e4bc  00000000          ori.b    #$0, d0
0101e4c0  00000000          ori.b    #$0, d0
0101e4c4  00000000          ori.b    #$0, d0
0101e4c8  00000000          ori.b    #$0, d0
0101e4cc  00000000          ori.b    #$0, d0
0101e4d0  00000000          ori.b    #$0, d0
0101e4d4  00000000          ori.b    #$0, d0
0101e4d8  00000000          ori.b    #$0, d0
0101e4dc  00000000          ori.b    #$0, d0
0101e4e0  00000000          ori.b    #$0, d0
0101e4e4  00000000          ori.b    #$0, d0
0101e4e8  00000000          ori.b    #$0, d0
0101e4ec  00000000          ori.b    #$0, d0
0101e4f0  00000000          ori.b    #$0, d0
0101e4f4  00000000          ori.b    #$0, d0
0101e4f8  00000000          ori.b    #$0, d0
0101e4fc  00000000          ori.b    #$0, d0
0101e500  00000000          ori.b    #$0, d0
0101e504  00000000          ori.b    #$0, d0
0101e508  00000000          ori.b    #$0, d0
0101e50c  00000000          ori.b    #$0, d0
0101e510  00000000          ori.b    #$0, d0
0101e514  00000000          ori.b    #$0, d0
0101e518  00000000          ori.b    #$0, d0
0101e51c  00000000          ori.b    #$0, d0
0101e520  00000000          ori.b    #$0, d0
0101e524  00000000          ori.b    #$0, d0
0101e528  00000000          ori.b    #$0, d0
0101e52c  00000000          ori.b    #$0, d0
0101e530  00000000          ori.b    #$0, d0
0101e534  00000000          ori.b    #$0, d0
0101e538  00000000          ori.b    #$0, d0
0101e53c  00000000          ori.b    #$0, d0
0101e540  00000000          ori.b    #$0, d0
0101e544  00000000          ori.b    #$0, d0
0101e548  00000000          ori.b    #$0, d0
0101e54c  00000000          ori.b    #$0, d0
0101e550  00000000          ori.b    #$0, d0
0101e554  00000000          ori.b    #$0, d0
0101e558  00000000          ori.b    #$0, d0
0101e55c  00000000          ori.b    #$0, d0
0101e560  00000000          ori.b    #$0, d0
0101e564  00000000          ori.b    #$0, d0
0101e568  00000000          ori.b    #$0, d0
0101e56c  00000000          ori.b    #$0, d0
0101e570  00000000          ori.b    #$0, d0
0101e574  00000000          ori.b    #$0, d0
0101e578  00000000          ori.b    #$0, d0
0101e57c  00000000          ori.b    #$0, d0
0101e580  00000000          ori.b    #$0, d0
0101e584  00000000          ori.b    #$0, d0
0101e588  00000000          ori.b    #$0, d0
0101e58c  00000000          ori.b    #$0, d0
0101e590  00000000          ori.b    #$0, d0
0101e594  00000000          ori.b    #$0, d0
0101e598  00000000          ori.b    #$0, d0
0101e59c  00000000          ori.b    #$0, d0
0101e5a0  00000000          ori.b    #$0, d0
0101e5a4  00000000          ori.b    #$0, d0
0101e5a8  00000000          ori.b    #$0, d0
0101e5ac  00000000          ori.b    #$0, d0
0101e5b0  00000000          ori.b    #$0, d0
0101e5b4  00000000          ori.b    #$0, d0
0101e5b8  00000000          ori.b    #$0, d0
0101e5bc  00000000          ori.b    #$0, d0
0101e5c0  00000000          ori.b    #$0, d0
0101e5c4  00000000          ori.b    #$0, d0
0101e5c8  00000000          ori.b    #$0, d0
0101e5cc  00000000          ori.b    #$0, d0
0101e5d0  00000000          ori.b    #$0, d0
0101e5d4  00000000          ori.b    #$0, d0
0101e5d8  00000000          ori.b    #$0, d0
0101e5dc  00000000          ori.b    #$0, d0
0101e5e0  00000000          ori.b    #$0, d0
0101e5e4  00000000          ori.b    #$0, d0
0101e5e8  00000000          ori.b    #$0, d0
0101e5ec  00000000          ori.b    #$0, d0
0101e5f0  00000000          ori.b    #$0, d0
0101e5f4  00000000          ori.b    #$0, d0
0101e5f8  00000000          ori.b    #$0, d0
0101e5fc  00000000          ori.b    #$0, d0
0101e600  00000000          ori.b    #$0, d0
0101e604  00000000          ori.b    #$0, d0
0101e608  00000000          ori.b    #$0, d0
0101e60c  00000000          ori.b    #$0, d0
0101e610  00000000          ori.b    #$0, d0
0101e614  00000000          ori.b    #$0, d0
0101e618  00000000          ori.b    #$0, d0
0101e61c  00000000          ori.b    #$0, d0
0101e620  00000000          ori.b    #$0, d0
0101e624  00000000          ori.b    #$0, d0
0101e628  00000000          ori.b    #$0, d0
0101e62c  00000000          ori.b    #$0, d0
0101e630  00000000          ori.b    #$0, d0
0101e634  00000000          ori.b    #$0, d0
0101e638  00000000          ori.b    #$0, d0
0101e63c  00000000          ori.b    #$0, d0
0101e640  00000000          ori.b    #$0, d0
0101e644  00000000          ori.b    #$0, d0
0101e648  00000000          ori.b    #$0, d0
0101e64c  00000000          ori.b    #$0, d0
0101e650  00000000          ori.b    #$0, d0
0101e654  00000000          ori.b    #$0, d0
0101e658  00000000          ori.b    #$0, d0
0101e65c  00000000          ori.b    #$0, d0
0101e660  00000000          ori.b    #$0, d0
0101e664  00000000          ori.b    #$0, d0
0101e668  00000000          ori.b    #$0, d0
0101e66c  00000000          ori.b    #$0, d0
0101e670  00000000          ori.b    #$0, d0
0101e674  00000000          ori.b    #$0, d0
0101e678  00000000          ori.b    #$0, d0
0101e67c  00000000          ori.b    #$0, d0
0101e680  00000000          ori.b    #$0, d0
0101e684  00000000          ori.b    #$0, d0
0101e688  00000000          ori.b    #$0, d0
0101e68c  00000000          ori.b    #$0, d0
0101e690  00000000          ori.b    #$0, d0
0101e694  00000000          ori.b    #$0, d0
0101e698  00000000          ori.b    #$0, d0
0101e69c  00000000          ori.b    #$0, d0
0101e6a0  00000000          ori.b    #$0, d0
0101e6a4  00000000          ori.b    #$0, d0
0101e6a8  00000000          ori.b    #$0, d0
0101e6ac  00000000          ori.b    #$0, d0
0101e6b0  00000000          ori.b    #$0, d0
0101e6b4  00000000          ori.b    #$0, d0
0101e6b8  00000000          ori.b    #$0, d0
0101e6bc  00000000          ori.b    #$0, d0
0101e6c0  00000000          ori.b    #$0, d0
0101e6c4  00000000          ori.b    #$0, d0
0101e6c8  00000000          ori.b    #$0, d0
0101e6cc  00000000          ori.b    #$0, d0
0101e6d0  00000000          ori.b    #$0, d0
0101e6d4  00000000          ori.b    #$0, d0
0101e6d8  00000000          ori.b    #$0, d0
0101e6dc  00000000          ori.b    #$0, d0
0101e6e0  00000000          ori.b    #$0, d0
0101e6e4  00000000          ori.b    #$0, d0
0101e6e8  00000000          ori.b    #$0, d0
0101e6ec  00000000          ori.b    #$0, d0
0101e6f0  00000000          ori.b    #$0, d0
0101e6f4  00000000          ori.b    #$0, d0
0101e6f8  00000000          ori.b    #$0, d0
0101e6fc  00000000          ori.b    #$0, d0
0101e700  00000000          ori.b    #$0, d0
0101e704  00000000          ori.b    #$0, d0
0101e708  00000000          ori.b    #$0, d0
0101e70c  00000000          ori.b    #$0, d0
0101e710  00000000          ori.b    #$0, d0
0101e714  00000000          ori.b    #$0, d0
0101e718  00000000          ori.b    #$0, d0
0101e71c  00000000          ori.b    #$0, d0
0101e720  00000000          ori.b    #$0, d0
0101e724  00000000          ori.b    #$0, d0
0101e728  00000000          ori.b    #$0, d0
0101e72c  00000000          ori.b    #$0, d0
0101e730  00000000          ori.b    #$0, d0
0101e734  00000000          ori.b    #$0, d0
0101e738  00000000          ori.b    #$0, d0
0101e73c  00000000          ori.b    #$0, d0
0101e740  00000000          ori.b    #$0, d0
0101e744  00000000          ori.b    #$0, d0
0101e748  00000000          ori.b    #$0, d0
0101e74c  00000000          ori.b    #$0, d0
0101e750  00000000          ori.b    #$0, d0
0101e754  00000000          ori.b    #$0, d0
0101e758  00000000          ori.b    #$0, d0
0101e75c  00000000          ori.b    #$0, d0
0101e760  00000000          ori.b    #$0, d0
0101e764  00000000          ori.b    #$0, d0
0101e768  00000000          ori.b    #$0, d0
0101e76c  00000000          ori.b    #$0, d0
0101e770  00000000          ori.b    #$0, d0
0101e774  00000000          ori.b    #$0, d0
0101e778  00000000          ori.b    #$0, d0
0101e77c  00000000          ori.b    #$0, d0
0101e780  00000000          ori.b    #$0, d0
0101e784  00000000          ori.b    #$0, d0
0101e788  00000000          ori.b    #$0, d0
0101e78c  00000000          ori.b    #$0, d0
0101e790  00000000          ori.b    #$0, d0
0101e794  00000000          ori.b    #$0, d0
0101e798  00000000          ori.b    #$0, d0
0101e79c  00000000          ori.b    #$0, d0
0101e7a0  00000000          ori.b    #$0, d0
0101e7a4  00000000          ori.b    #$0, d0
0101e7a8  00000000          ori.b    #$0, d0
0101e7ac  00000000          ori.b    #$0, d0
0101e7b0  00000000          ori.b    #$0, d0
0101e7b4  00000000          ori.b    #$0, d0
0101e7b8  00000000          ori.b    #$0, d0
0101e7bc  00000000          ori.b    #$0, d0
0101e7c0  00000000          ori.b    #$0, d0
0101e7c4  00000000          ori.b    #$0, d0
0101e7c8  00000000          ori.b    #$0, d0
0101e7cc  00000000          ori.b    #$0, d0
0101e7d0  00000000          ori.b    #$0, d0
0101e7d4  00000000          ori.b    #$0, d0
0101e7d8  00000000          ori.b    #$0, d0
0101e7dc  00000000          ori.b    #$0, d0
0101e7e0  00000000          ori.b    #$0, d0
0101e7e4  00000000          ori.b    #$0, d0
0101e7e8  00000000          ori.b    #$0, d0
0101e7ec  00000000          ori.b    #$0, d0
0101e7f0  00000000          ori.b    #$0, d0
0101e7f4  00000000          ori.b    #$0, d0
0101e7f8  00000000          ori.b    #$0, d0
0101e7fc  00000000          ori.b    #$0, d0
0101e800  00000000          ori.b    #$0, d0
0101e804  00000000          ori.b    #$0, d0
0101e808  00000000          ori.b    #$0, d0
0101e80c  00000000          ori.b    #$0, d0
0101e810  00000000          ori.b    #$0, d0
0101e814  00000000          ori.b    #$0, d0
0101e818  00000000          ori.b    #$0, d0
0101e81c  00000000          ori.b    #$0, d0
0101e820  00000000          ori.b    #$0, d0
0101e824  00000000          ori.b    #$0, d0
0101e828  00000000          ori.b    #$0, d0
0101e82c  00000000          ori.b    #$0, d0
0101e830  00000000          ori.b    #$0, d0
0101e834  00000000          ori.b    #$0, d0
0101e838  00000000          ori.b    #$0, d0
0101e83c  00000000          ori.b    #$0, d0
0101e840  00000000          ori.b    #$0, d0
0101e844  00000000          ori.b    #$0, d0
0101e848  00000000          ori.b    #$0, d0
0101e84c  00000000          ori.b    #$0, d0
0101e850  00000000          ori.b    #$0, d0
0101e854  00000000          ori.b    #$0, d0
0101e858  00000000          ori.b    #$0, d0
0101e85c  00000000          ori.b    #$0, d0
0101e860  00000000          ori.b    #$0, d0
0101e864  00000000          ori.b    #$0, d0
0101e868  00000000          ori.b    #$0, d0
0101e86c  00000000          ori.b    #$0, d0
0101e870  00000000          ori.b    #$0, d0
0101e874  00000000          ori.b    #$0, d0
0101e878  00000000          ori.b    #$0, d0
0101e87c  00000000          ori.b    #$0, d0
0101e880  00000000          ori.b    #$0, d0
0101e884  00000000          ori.b    #$0, d0
0101e888  00000000          ori.b    #$0, d0
0101e88c  00000000          ori.b    #$0, d0
0101e890  00000000          ori.b    #$0, d0
0101e894  00000000          ori.b    #$0, d0
0101e898  00000000          ori.b    #$0, d0
0101e89c  00000000          ori.b    #$0, d0
0101e8a0  00000000          ori.b    #$0, d0
0101e8a4  00000000          ori.b    #$0, d0
0101e8a8  00000000          ori.b    #$0, d0
0101e8ac  00000000          ori.b    #$0, d0
0101e8b0  00000000          ori.b    #$0, d0
0101e8b4  00000000          ori.b    #$0, d0
0101e8b8  00000000          ori.b    #$0, d0
0101e8bc  00000000          ori.b    #$0, d0
0101e8c0  00000000          ori.b    #$0, d0
0101e8c4  00000000          ori.b    #$0, d0
0101e8c8  00000000          ori.b    #$0, d0
0101e8cc  00000000          ori.b    #$0, d0
0101e8d0  00000000          ori.b    #$0, d0
0101e8d4  00000000          ori.b    #$0, d0
0101e8d8  00000000          ori.b    #$0, d0
0101e8dc  00000000          ori.b    #$0, d0
0101e8e0  00000000          ori.b    #$0, d0
0101e8e4  00000000          ori.b    #$0, d0
0101e8e8  00000000          ori.b    #$0, d0
0101e8ec  00000000          ori.b    #$0, d0
0101e8f0  00000000          ori.b    #$0, d0
0101e8f4  00000000          ori.b    #$0, d0
0101e8f8  00000000          ori.b    #$0, d0
0101e8fc  00000000          ori.b    #$0, d0
0101e900  00000000          ori.b    #$0, d0
0101e904  00000000          ori.b    #$0, d0
0101e908  00000000          ori.b    #$0, d0
0101e90c  00000000          ori.b    #$0, d0
0101e910  00000000          ori.b    #$0, d0
0101e914  00000000          ori.b    #$0, d0
0101e918  00000000          ori.b    #$0, d0
0101e91c  00000000          ori.b    #$0, d0
0101e920  00000000          ori.b    #$0, d0
0101e924  00000000          ori.b    #$0, d0
0101e928  00000000          ori.b    #$0, d0
0101e92c  00000000          ori.b    #$0, d0
0101e930  00000000          ori.b    #$0, d0
0101e934  00000000          ori.b    #$0, d0
0101e938  00000000          ori.b    #$0, d0
0101e93c  00000000          ori.b    #$0, d0
0101e940  00000000          ori.b    #$0, d0
0101e944  00000000          ori.b    #$0, d0
0101e948  00000000          ori.b    #$0, d0
0101e94c  00000000          ori.b    #$0, d0
0101e950  00000000          ori.b    #$0, d0
0101e954  00000000          ori.b    #$0, d0
0101e958  00000000          ori.b    #$0, d0
0101e95c  00000000          ori.b    #$0, d0
0101e960  00000000          ori.b    #$0, d0
0101e964  00000000          ori.b    #$0, d0
0101e968  00000000          ori.b    #$0, d0
0101e96c  00000000          ori.b    #$0, d0
0101e970  00000000          ori.b    #$0, d0
0101e974  00000000          ori.b    #$0, d0
0101e978  00000000          ori.b    #$0, d0
0101e97c  00000000          ori.b    #$0, d0
0101e980  00000000          ori.b    #$0, d0
0101e984  00000000          ori.b    #$0, d0
0101e988  00000000          ori.b    #$0, d0
0101e98c  00000000          ori.b    #$0, d0
0101e990  00000000          ori.b    #$0, d0
0101e994  00000000          ori.b    #$0, d0
0101e998  00000000          ori.b    #$0, d0
0101e99c  00000000          ori.b    #$0, d0
0101e9a0  00000000          ori.b    #$0, d0
0101e9a4  00000000          ori.b    #$0, d0
0101e9a8  00000000          ori.b    #$0, d0
0101e9ac  00000000          ori.b    #$0, d0
0101e9b0  00000000          ori.b    #$0, d0
0101e9b4  00000000          ori.b    #$0, d0
0101e9b8  00000000          ori.b    #$0, d0
0101e9bc  00000000          ori.b    #$0, d0
0101e9c0  00000000          ori.b    #$0, d0
0101e9c4  00000000          ori.b    #$0, d0
0101e9c8  00000000          ori.b    #$0, d0
0101e9cc  00000000          ori.b    #$0, d0
0101e9d0  00000000          ori.b    #$0, d0
0101e9d4  00000000          ori.b    #$0, d0
0101e9d8  00000000          ori.b    #$0, d0
0101e9dc  00000000          ori.b    #$0, d0
0101e9e0  00000000          ori.b    #$0, d0
0101e9e4  00000000          ori.b    #$0, d0
0101e9e8  00000000          ori.b    #$0, d0
0101e9ec  00000000          ori.b    #$0, d0
0101e9f0  00000000          ori.b    #$0, d0
0101e9f4  00000000          ori.b    #$0, d0
0101e9f8  00000000          ori.b    #$0, d0
0101e9fc  00000000          ori.b    #$0, d0
0101ea00  00000000          ori.b    #$0, d0
0101ea04  00000000          ori.b    #$0, d0
0101ea08  00000000          ori.b    #$0, d0
0101ea0c  00000000          ori.b    #$0, d0
0101ea10  00000000          ori.b    #$0, d0
0101ea14  00000000          ori.b    #$0, d0
0101ea18  00000000          ori.b    #$0, d0
0101ea1c  00000000          ori.b    #$0, d0
0101ea20  00000000          ori.b    #$0, d0
0101ea24  00000000          ori.b    #$0, d0
0101ea28  00000000          ori.b    #$0, d0
0101ea2c  00000000          ori.b    #$0, d0
0101ea30  00000000          ori.b    #$0, d0
0101ea34  00000000          ori.b    #$0, d0
0101ea38  00000000          ori.b    #$0, d0
0101ea3c  00000000          ori.b    #$0, d0
0101ea40  00000000          ori.b    #$0, d0
0101ea44  00000000          ori.b    #$0, d0
0101ea48  00000000          ori.b    #$0, d0
0101ea4c  00000000          ori.b    #$0, d0
0101ea50  00000000          ori.b    #$0, d0
0101ea54  00000000          ori.b    #$0, d0
0101ea58  00000000          ori.b    #$0, d0
0101ea5c  00000000          ori.b    #$0, d0
0101ea60  00000000          ori.b    #$0, d0
0101ea64  00000000          ori.b    #$0, d0
0101ea68  00000000          ori.b    #$0, d0
0101ea6c  00000000          ori.b    #$0, d0
0101ea70  00000000          ori.b    #$0, d0
0101ea74  00000000          ori.b    #$0, d0
0101ea78  00000000          ori.b    #$0, d0
0101ea7c  00000000          ori.b    #$0, d0
0101ea80  00000000          ori.b    #$0, d0
0101ea84  00000000          ori.b    #$0, d0
0101ea88  00000000          ori.b    #$0, d0
0101ea8c  00000000          ori.b    #$0, d0
0101ea90  00000000          ori.b    #$0, d0
0101ea94  00000000          ori.b    #$0, d0
0101ea98  00000000          ori.b    #$0, d0
0101ea9c  00000000          ori.b    #$0, d0
0101eaa0  00000000          ori.b    #$0, d0
0101eaa4  00000000          ori.b    #$0, d0
0101eaa8  00000000          ori.b    #$0, d0
0101eaac  00000000          ori.b    #$0, d0
0101eab0  00000000          ori.b    #$0, d0
0101eab4  00000000          ori.b    #$0, d0
0101eab8  00000000          ori.b    #$0, d0
0101eabc  00000000          ori.b    #$0, d0
0101eac0  00000000          ori.b    #$0, d0
0101eac4  00000000          ori.b    #$0, d0
0101eac8  00000000          ori.b    #$0, d0
0101eacc  00000000          ori.b    #$0, d0
0101ead0  00000000          ori.b    #$0, d0
0101ead4  00000000          ori.b    #$0, d0
0101ead8  00000000          ori.b    #$0, d0
0101eadc  00000000          ori.b    #$0, d0
0101eae0  00000000          ori.b    #$0, d0
0101eae4  00000000          ori.b    #$0, d0
0101eae8  00000000          ori.b    #$0, d0
0101eaec  00000000          ori.b    #$0, d0
0101eaf0  00000000          ori.b    #$0, d0
0101eaf4  00000000          ori.b    #$0, d0
0101eaf8  00000000          ori.b    #$0, d0
0101eafc  00000000          ori.b    #$0, d0
0101eb00  00000000          ori.b    #$0, d0
0101eb04  00000000          ori.b    #$0, d0
0101eb08  00000000          ori.b    #$0, d0
0101eb0c  00000000          ori.b    #$0, d0
0101eb10  00000000          ori.b    #$0, d0
0101eb14  00000000          ori.b    #$0, d0
0101eb18  00000000          ori.b    #$0, d0
0101eb1c  00000000          ori.b    #$0, d0
0101eb20  00000000          ori.b    #$0, d0
0101eb24  00000000          ori.b    #$0, d0
0101eb28  00000000          ori.b    #$0, d0
0101eb2c  00000000          ori.b    #$0, d0
0101eb30  00000000          ori.b    #$0, d0
0101eb34  00000000          ori.b    #$0, d0
0101eb38  00000000          ori.b    #$0, d0
0101eb3c  00000000          ori.b    #$0, d0
0101eb40  00000000          ori.b    #$0, d0
0101eb44  00000000          ori.b    #$0, d0
0101eb48  00000000          ori.b    #$0, d0
0101eb4c  00000000          ori.b    #$0, d0
0101eb50  00000000          ori.b    #$0, d0
0101eb54  00000000          ori.b    #$0, d0
0101eb58  00000000          ori.b    #$0, d0
0101eb5c  00000000          ori.b    #$0, d0
0101eb60  00000000          ori.b    #$0, d0
0101eb64  00000000          ori.b    #$0, d0
0101eb68  00000000          ori.b    #$0, d0
0101eb6c  00000000          ori.b    #$0, d0
0101eb70  00000000          ori.b    #$0, d0
0101eb74  00000000          ori.b    #$0, d0
0101eb78  00000000          ori.b    #$0, d0
0101eb7c  00000000          ori.b    #$0, d0
0101eb80  00000000          ori.b    #$0, d0
0101eb84  00000000          ori.b    #$0, d0
0101eb88  00000000          ori.b    #$0, d0
0101eb8c  00000000          ori.b    #$0, d0
0101eb90  00000000          ori.b    #$0, d0
0101eb94  00000000          ori.b    #$0, d0
0101eb98  00000000          ori.b    #$0, d0
0101eb9c  00000000          ori.b    #$0, d0
0101eba0  00000000          ori.b    #$0, d0
0101eba4  00000000          ori.b    #$0, d0
0101eba8  00000000          ori.b    #$0, d0
0101ebac  00000000          ori.b    #$0, d0
0101ebb0  00000000          ori.b    #$0, d0
0101ebb4  00000000          ori.b    #$0, d0
0101ebb8  00000000          ori.b    #$0, d0
0101ebbc  00000000          ori.b    #$0, d0
0101ebc0  00000000          ori.b    #$0, d0
0101ebc4  00000000          ori.b    #$0, d0
0101ebc8  00000000          ori.b    #$0, d0
0101ebcc  00000000          ori.b    #$0, d0
0101ebd0  00000000          ori.b    #$0, d0
0101ebd4  00000000          ori.b    #$0, d0
0101ebd8  00000000          ori.b    #$0, d0
0101ebdc  00000000          ori.b    #$0, d0
0101ebe0  00000000          ori.b    #$0, d0
0101ebe4  00000000          ori.b    #$0, d0
0101ebe8  00000000          ori.b    #$0, d0
0101ebec  00000000          ori.b    #$0, d0
0101ebf0  00000000          ori.b    #$0, d0
0101ebf4  00000000          ori.b    #$0, d0
0101ebf8  00000000          ori.b    #$0, d0
0101ebfc  00000000          ori.b    #$0, d0
0101ec00  00000000          ori.b    #$0, d0
0101ec04  00000000          ori.b    #$0, d0
0101ec08  00000000          ori.b    #$0, d0
0101ec0c  00000000          ori.b    #$0, d0
0101ec10  00000000          ori.b    #$0, d0
0101ec14  00000000          ori.b    #$0, d0
0101ec18  00000000          ori.b    #$0, d0
0101ec1c  00000000          ori.b    #$0, d0
0101ec20  00000000          ori.b    #$0, d0
0101ec24  00000000          ori.b    #$0, d0
0101ec28  00000000          ori.b    #$0, d0
0101ec2c  00000000          ori.b    #$0, d0
0101ec30  00000000          ori.b    #$0, d0
0101ec34  00000000          ori.b    #$0, d0
0101ec38  00000000          ori.b    #$0, d0
0101ec3c  00000000          ori.b    #$0, d0
0101ec40  00000000          ori.b    #$0, d0
0101ec44  00000000          ori.b    #$0, d0
0101ec48  00000000          ori.b    #$0, d0
0101ec4c  00000000          ori.b    #$0, d0
0101ec50  00000000          ori.b    #$0, d0
0101ec54  00000000          ori.b    #$0, d0
0101ec58  00000000          ori.b    #$0, d0
0101ec5c  00000000          ori.b    #$0, d0
0101ec60  00000000          ori.b    #$0, d0
0101ec64  00000000          ori.b    #$0, d0
0101ec68  00000000          ori.b    #$0, d0
0101ec6c  00000000          ori.b    #$0, d0
0101ec70  00000000          ori.b    #$0, d0
0101ec74  00000000          ori.b    #$0, d0
0101ec78  00000000          ori.b    #$0, d0
0101ec7c  00000000          ori.b    #$0, d0
0101ec80  00000000          ori.b    #$0, d0
0101ec84  00000000          ori.b    #$0, d0
0101ec88  00000000          ori.b    #$0, d0
0101ec8c  00000000          ori.b    #$0, d0
0101ec90  00000000          ori.b    #$0, d0
0101ec94  00000000          ori.b    #$0, d0
0101ec98  00000000          ori.b    #$0, d0
0101ec9c  00000000          ori.b    #$0, d0
0101eca0  00000000          ori.b    #$0, d0
0101eca4  00000000          ori.b    #$0, d0
0101eca8  00000000          ori.b    #$0, d0
0101ecac  00000000          ori.b    #$0, d0
0101ecb0  00000000          ori.b    #$0, d0
0101ecb4  00000000          ori.b    #$0, d0
0101ecb8  00000000          ori.b    #$0, d0
0101ecbc  00000000          ori.b    #$0, d0
0101ecc0  00000000          ori.b    #$0, d0
0101ecc4  00000000          ori.b    #$0, d0
0101ecc8  00000000          ori.b    #$0, d0
0101eccc  00000000          ori.b    #$0, d0
0101ecd0  00000000          ori.b    #$0, d0
0101ecd4  00000000          ori.b    #$0, d0
0101ecd8  00000000          ori.b    #$0, d0
0101ecdc  00000000          ori.b    #$0, d0
0101ece0  00000000          ori.b    #$0, d0
0101ece4  00000000          ori.b    #$0, d0
0101ece8  00000000          ori.b    #$0, d0
0101ecec  00000000          ori.b    #$0, d0
0101ecf0  00000000          ori.b    #$0, d0
0101ecf4  00000000          ori.b    #$0, d0
0101ecf8  00000000          ori.b    #$0, d0
0101ecfc  00000000          ori.b    #$0, d0
0101ed00  00000000          ori.b    #$0, d0
0101ed04  00000000          ori.b    #$0, d0
0101ed08  00000000          ori.b    #$0, d0
0101ed0c  00000000          ori.b    #$0, d0
0101ed10  00000000          ori.b    #$0, d0
0101ed14  00000000          ori.b    #$0, d0
0101ed18  00000000          ori.b    #$0, d0
0101ed1c  00000000          ori.b    #$0, d0
0101ed20  00000000          ori.b    #$0, d0
0101ed24  00000000          ori.b    #$0, d0
0101ed28  00000000          ori.b    #$0, d0
0101ed2c  00000000          ori.b    #$0, d0
0101ed30  00000000          ori.b    #$0, d0
0101ed34  00000000          ori.b    #$0, d0
0101ed38  00000000          ori.b    #$0, d0
0101ed3c  00000000          ori.b    #$0, d0
0101ed40  00000000          ori.b    #$0, d0
0101ed44  00000000          ori.b    #$0, d0
0101ed48  00000000          ori.b    #$0, d0
0101ed4c  00000000          ori.b    #$0, d0
0101ed50  00000000          ori.b    #$0, d0
0101ed54  00000000          ori.b    #$0, d0
0101ed58  00000000          ori.b    #$0, d0
0101ed5c  00000000          ori.b    #$0, d0
0101ed60  00000000          ori.b    #$0, d0
0101ed64  00000000          ori.b    #$0, d0
0101ed68  00000000          ori.b    #$0, d0
0101ed6c  00000000          ori.b    #$0, d0
0101ed70  00000000          ori.b    #$0, d0
0101ed74  00000000          ori.b    #$0, d0
0101ed78  00000000          ori.b    #$0, d0
0101ed7c  00000000          ori.b    #$0, d0
0101ed80  00000000          ori.b    #$0, d0
0101ed84  00000000          ori.b    #$0, d0
0101ed88  00000000          ori.b    #$0, d0
0101ed8c  00000000          ori.b    #$0, d0
0101ed90  00000000          ori.b    #$0, d0
0101ed94  00000000          ori.b    #$0, d0
0101ed98  00000000          ori.b    #$0, d0
0101ed9c  00000000          ori.b    #$0, d0
0101eda0  00000000          ori.b    #$0, d0
0101eda4  00000000          ori.b    #$0, d0
0101eda8  00000000          ori.b    #$0, d0
0101edac  00000000          ori.b    #$0, d0
0101edb0  00000000          ori.b    #$0, d0
0101edb4  00000000          ori.b    #$0, d0
0101edb8  00000000          ori.b    #$0, d0
0101edbc  00000000          ori.b    #$0, d0
0101edc0  00000000          ori.b    #$0, d0
0101edc4  00000000          ori.b    #$0, d0
0101edc8  00000000          ori.b    #$0, d0
0101edcc  00000000          ori.b    #$0, d0
0101edd0  00000000          ori.b    #$0, d0
0101edd4  00000000          ori.b    #$0, d0
0101edd8  00000000          ori.b    #$0, d0
0101eddc  00000000          ori.b    #$0, d0
0101ede0  00000000          ori.b    #$0, d0
0101ede4  00000000          ori.b    #$0, d0
0101ede8  00000000          ori.b    #$0, d0
0101edec  00000000          ori.b    #$0, d0
0101edf0  00000000          ori.b    #$0, d0
0101edf4  00000000          ori.b    #$0, d0
0101edf8  00000000          ori.b    #$0, d0
0101edfc  00000000          ori.b    #$0, d0
0101ee00  00000000          ori.b    #$0, d0
0101ee04  00000000          ori.b    #$0, d0
0101ee08  00000000          ori.b    #$0, d0
0101ee0c  00000000          ori.b    #$0, d0
0101ee10  00000000          ori.b    #$0, d0
0101ee14  00000000          ori.b    #$0, d0
0101ee18  00000000          ori.b    #$0, d0
0101ee1c  00000000          ori.b    #$0, d0
0101ee20  00000000          ori.b    #$0, d0
0101ee24  00000000          ori.b    #$0, d0
0101ee28  00000000          ori.b    #$0, d0
0101ee2c  00000000          ori.b    #$0, d0
0101ee30  00000000          ori.b    #$0, d0
0101ee34  00000000          ori.b    #$0, d0
0101ee38  00000000          ori.b    #$0, d0
0101ee3c  00000000          ori.b    #$0, d0
0101ee40  00000000          ori.b    #$0, d0
0101ee44  00000000          ori.b    #$0, d0
0101ee48  00000000          ori.b    #$0, d0
0101ee4c  00000000          ori.b    #$0, d0
0101ee50  00000000          ori.b    #$0, d0
0101ee54  00000000          ori.b    #$0, d0
0101ee58  00000000          ori.b    #$0, d0
0101ee5c  00000000          ori.b    #$0, d0
0101ee60  00000000          ori.b    #$0, d0
0101ee64  00000000          ori.b    #$0, d0
0101ee68  00000000          ori.b    #$0, d0
0101ee6c  00000000          ori.b    #$0, d0
0101ee70  00000000          ori.b    #$0, d0
0101ee74  00000000          ori.b    #$0, d0
0101ee78  00000000          ori.b    #$0, d0
0101ee7c  00000000          ori.b    #$0, d0
0101ee80  00000000          ori.b    #$0, d0
0101ee84  00000000          ori.b    #$0, d0
0101ee88  00000000          ori.b    #$0, d0
0101ee8c  00000000          ori.b    #$0, d0
0101ee90  00000000          ori.b    #$0, d0
0101ee94  00000000          ori.b    #$0, d0
0101ee98  00000000          ori.b    #$0, d0
0101ee9c  00000000          ori.b    #$0, d0
0101eea0  00000000          ori.b    #$0, d0
0101eea4  00000000          ori.b    #$0, d0
0101eea8  00000000          ori.b    #$0, d0
0101eeac  00000000          ori.b    #$0, d0
0101eeb0  00000000          ori.b    #$0, d0
0101eeb4  00000000          ori.b    #$0, d0
0101eeb8  00000000          ori.b    #$0, d0
0101eebc  00000000          ori.b    #$0, d0
0101eec0  00000000          ori.b    #$0, d0
0101eec4  00000000          ori.b    #$0, d0
0101eec8  00000000          ori.b    #$0, d0
0101eecc  00000000          ori.b    #$0, d0
0101eed0  00000000          ori.b    #$0, d0
0101eed4  00000000          ori.b    #$0, d0
0101eed8  00000000          ori.b    #$0, d0
0101eedc  00000000          ori.b    #$0, d0
0101eee0  00000000          ori.b    #$0, d0
0101eee4  00000000          ori.b    #$0, d0
0101eee8  00000000          ori.b    #$0, d0
0101eeec  00000000          ori.b    #$0, d0
0101eef0  00000000          ori.b    #$0, d0
0101eef4  00000000          ori.b    #$0, d0
0101eef8  00000000          ori.b    #$0, d0
0101eefc  00000000          ori.b    #$0, d0
0101ef00  00000000          ori.b    #$0, d0
0101ef04  00000000          ori.b    #$0, d0
0101ef08  00000000          ori.b    #$0, d0
0101ef0c  00000000          ori.b    #$0, d0
0101ef10  00000000          ori.b    #$0, d0
0101ef14  00000000          ori.b    #$0, d0
0101ef18  00000000          ori.b    #$0, d0
0101ef1c  00000000          ori.b    #$0, d0
0101ef20  00000000          ori.b    #$0, d0
0101ef24  00000000          ori.b    #$0, d0
0101ef28  00000000          ori.b    #$0, d0
0101ef2c  00000000          ori.b    #$0, d0
0101ef30  00000000          ori.b    #$0, d0
0101ef34  00000000          ori.b    #$0, d0
0101ef38  00000000          ori.b    #$0, d0
0101ef3c  00000000          ori.b    #$0, d0
0101ef40  00000000          ori.b    #$0, d0
0101ef44  00000000          ori.b    #$0, d0
0101ef48  00000000          ori.b    #$0, d0
0101ef4c  00000000          ori.b    #$0, d0
0101ef50  00000000          ori.b    #$0, d0
0101ef54  00000000          ori.b    #$0, d0
0101ef58  00000000          ori.b    #$0, d0
0101ef5c  00000000          ori.b    #$0, d0
0101ef60  00000000          ori.b    #$0, d0
0101ef64  00000000          ori.b    #$0, d0
0101ef68  00000000          ori.b    #$0, d0
0101ef6c  00000000          ori.b    #$0, d0
0101ef70  00000000          ori.b    #$0, d0
0101ef74  00000000          ori.b    #$0, d0
0101ef78  00000000          ori.b    #$0, d0
0101ef7c  00000000          ori.b    #$0, d0
0101ef80  00000000          ori.b    #$0, d0
0101ef84  00000000          ori.b    #$0, d0
0101ef88  00000000          ori.b    #$0, d0
0101ef8c  00000000          ori.b    #$0, d0
0101ef90  00000000          ori.b    #$0, d0
0101ef94  00000000          ori.b    #$0, d0
0101ef98  00000000          ori.b    #$0, d0
0101ef9c  00000000          ori.b    #$0, d0
0101efa0  00000000          ori.b    #$0, d0
0101efa4  00000000          ori.b    #$0, d0
0101efa8  00000000          ori.b    #$0, d0
0101efac  00000000          ori.b    #$0, d0
0101efb0  00000000          ori.b    #$0, d0
0101efb4  00000000          ori.b    #$0, d0
0101efb8  00000000          ori.b    #$0, d0
0101efbc  00000000          ori.b    #$0, d0
0101efc0  00000000          ori.b    #$0, d0
0101efc4  00000000          ori.b    #$0, d0
0101efc8  00000000          ori.b    #$0, d0
0101efcc  00000000          ori.b    #$0, d0
0101efd0  00000000          ori.b    #$0, d0
0101efd4  00000000          ori.b    #$0, d0
0101efd8  00000000          ori.b    #$0, d0
0101efdc  00000000          ori.b    #$0, d0
0101efe0  00000000          ori.b    #$0, d0
0101efe4  00000000          ori.b    #$0, d0
0101efe8  00000000          ori.b    #$0, d0
0101efec  00000000          ori.b    #$0, d0
0101eff0  00000000          ori.b    #$0, d0
0101eff4  00000000          ori.b    #$0, d0
0101eff8  00000000          ori.b    #$0, d0
0101effc  00000000          ori.b    #$0, d0
0101f000  00000000          ori.b    #$0, d0
0101f004  00000000          ori.b    #$0, d0
0101f008  00000000          ori.b    #$0, d0
0101f00c  00000000          ori.b    #$0, d0
0101f010  00000000          ori.b    #$0, d0
0101f014  00000000          ori.b    #$0, d0
0101f018  00000000          ori.b    #$0, d0
0101f01c  00000000          ori.b    #$0, d0
0101f020  00000000          ori.b    #$0, d0
0101f024  00000000          ori.b    #$0, d0
0101f028  00000000          ori.b    #$0, d0
0101f02c  00000000          ori.b    #$0, d0
0101f030  00000000          ori.b    #$0, d0
0101f034  00000000          ori.b    #$0, d0
0101f038  00000000          ori.b    #$0, d0
0101f03c  00000000          ori.b    #$0, d0
0101f040  00000000          ori.b    #$0, d0
0101f044  00000000          ori.b    #$0, d0
0101f048  00000000          ori.b    #$0, d0
0101f04c  00000000          ori.b    #$0, d0
0101f050  00000000          ori.b    #$0, d0
0101f054  00000000          ori.b    #$0, d0
0101f058  00000000          ori.b    #$0, d0
0101f05c  00000000          ori.b    #$0, d0
0101f060  00000000          ori.b    #$0, d0
0101f064  00000000          ori.b    #$0, d0
0101f068  00000000          ori.b    #$0, d0
0101f06c  00000000          ori.b    #$0, d0
0101f070  00000000          ori.b    #$0, d0
0101f074  00000000          ori.b    #$0, d0
0101f078  00000000          ori.b    #$0, d0
0101f07c  00000000          ori.b    #$0, d0
0101f080  00000000          ori.b    #$0, d0
0101f084  00000000          ori.b    #$0, d0
0101f088  00000000          ori.b    #$0, d0
0101f08c  00000000          ori.b    #$0, d0
0101f090  00000000          ori.b    #$0, d0
0101f094  00000000          ori.b    #$0, d0
0101f098  00000000          ori.b    #$0, d0
0101f09c  00000000          ori.b    #$0, d0
0101f0a0  00000000          ori.b    #$0, d0
0101f0a4  00000000          ori.b    #$0, d0
0101f0a8  00000000          ori.b    #$0, d0
0101f0ac  00000000          ori.b    #$0, d0
0101f0b0  00000000          ori.b    #$0, d0
0101f0b4  00000000          ori.b    #$0, d0
0101f0b8  00000000          ori.b    #$0, d0
0101f0bc  00000000          ori.b    #$0, d0
0101f0c0  00000000          ori.b    #$0, d0
0101f0c4  00000000          ori.b    #$0, d0
0101f0c8  00000000          ori.b    #$0, d0
0101f0cc  00000000          ori.b    #$0, d0
0101f0d0  00000000          ori.b    #$0, d0
0101f0d4  00000000          ori.b    #$0, d0
0101f0d8  00000000          ori.b    #$0, d0
0101f0dc  00000000          ori.b    #$0, d0
0101f0e0  00000000          ori.b    #$0, d0
0101f0e4  00000000          ori.b    #$0, d0
0101f0e8  00000000          ori.b    #$0, d0
0101f0ec  00000000          ori.b    #$0, d0
0101f0f0  00000000          ori.b    #$0, d0
0101f0f4  00000000          ori.b    #$0, d0
0101f0f8  00000000          ori.b    #$0, d0
0101f0fc  00000000          ori.b    #$0, d0
0101f100  00000000          ori.b    #$0, d0
0101f104  00000000          ori.b    #$0, d0
0101f108  00000000          ori.b    #$0, d0
0101f10c  00000000          ori.b    #$0, d0
0101f110  00000000          ori.b    #$0, d0
0101f114  00000000          ori.b    #$0, d0
0101f118  00000000          ori.b    #$0, d0
0101f11c  00000000          ori.b    #$0, d0
0101f120  00000000          ori.b    #$0, d0
0101f124  00000000          ori.b    #$0, d0
0101f128  00000000          ori.b    #$0, d0
0101f12c  00000000          ori.b    #$0, d0
0101f130  00000000          ori.b    #$0, d0
0101f134  00000000          ori.b    #$0, d0
0101f138  00000000          ori.b    #$0, d0
0101f13c  00000000          ori.b    #$0, d0
0101f140  00000000          ori.b    #$0, d0
0101f144  00000000          ori.b    #$0, d0
0101f148  00000000          ori.b    #$0, d0
0101f14c  00000000          ori.b    #$0, d0
0101f150  00000000          ori.b    #$0, d0
0101f154  00000000          ori.b    #$0, d0
0101f158  00000000          ori.b    #$0, d0
0101f15c  00000000          ori.b    #$0, d0
0101f160  00000000          ori.b    #$0, d0
0101f164  00000000          ori.b    #$0, d0
0101f168  00000000          ori.b    #$0, d0
0101f16c  00000000          ori.b    #$0, d0
0101f170  00000000          ori.b    #$0, d0
0101f174  00000000          ori.b    #$0, d0
0101f178  00000000          ori.b    #$0, d0
0101f17c  00000000          ori.b    #$0, d0
0101f180  00000000          ori.b    #$0, d0
0101f184  00000000          ori.b    #$0, d0
0101f188  00000000          ori.b    #$0, d0
0101f18c  00000000          ori.b    #$0, d0
0101f190  00000000          ori.b    #$0, d0
0101f194  00000000          ori.b    #$0, d0
0101f198  00000000          ori.b    #$0, d0
0101f19c  00000000          ori.b    #$0, d0
0101f1a0  00000000          ori.b    #$0, d0
0101f1a4  00000000          ori.b    #$0, d0
0101f1a8  00000000          ori.b    #$0, d0
0101f1ac  00000000          ori.b    #$0, d0
0101f1b0  00000000          ori.b    #$0, d0
0101f1b4  00000000          ori.b    #$0, d0
0101f1b8  00000000          ori.b    #$0, d0
0101f1bc  00000000          ori.b    #$0, d0
0101f1c0  00000000          ori.b    #$0, d0
0101f1c4  00000000          ori.b    #$0, d0
0101f1c8  00000000          ori.b    #$0, d0
0101f1cc  00000000          ori.b    #$0, d0
0101f1d0  00000000          ori.b    #$0, d0
0101f1d4  00000000          ori.b    #$0, d0
0101f1d8  00000000          ori.b    #$0, d0
0101f1dc  00000000          ori.b    #$0, d0
0101f1e0  00000000          ori.b    #$0, d0
0101f1e4  00000000          ori.b    #$0, d0
0101f1e8  00000000          ori.b    #$0, d0
0101f1ec  00000000          ori.b    #$0, d0
0101f1f0  00000000          ori.b    #$0, d0
0101f1f4  00000000          ori.b    #$0, d0
0101f1f8  00000000          ori.b    #$0, d0
0101f1fc  00000000          ori.b    #$0, d0
0101f200  00000000          ori.b    #$0, d0
0101f204  00000000          ori.b    #$0, d0
0101f208  00000000          ori.b    #$0, d0
0101f20c  00000000          ori.b    #$0, d0
0101f210  00000000          ori.b    #$0, d0
0101f214  00000000          ori.b    #$0, d0
0101f218  00000000          ori.b    #$0, d0
0101f21c  00000000          ori.b    #$0, d0
0101f220  00000000          ori.b    #$0, d0
0101f224  00000000          ori.b    #$0, d0
0101f228  00000000          ori.b    #$0, d0
0101f22c  00000000          ori.b    #$0, d0
0101f230  00000000          ori.b    #$0, d0
0101f234  00000000          ori.b    #$0, d0
0101f238  00000000          ori.b    #$0, d0
0101f23c  00000000          ori.b    #$0, d0
0101f240  00000000          ori.b    #$0, d0
0101f244  00000000          ori.b    #$0, d0
0101f248  00000000          ori.b    #$0, d0
0101f24c  00000000          ori.b    #$0, d0
0101f250  00000000          ori.b    #$0, d0
0101f254  00000000          ori.b    #$0, d0
0101f258  00000000          ori.b    #$0, d0
0101f25c  00000000          ori.b    #$0, d0
0101f260  00000000          ori.b    #$0, d0
0101f264  00000000          ori.b    #$0, d0
0101f268  00000000          ori.b    #$0, d0
0101f26c  00000000          ori.b    #$0, d0
0101f270  00000000          ori.b    #$0, d0
0101f274  00000000          ori.b    #$0, d0
0101f278  00000000          ori.b    #$0, d0
0101f27c  00000000          ori.b    #$0, d0
0101f280  00000000          ori.b    #$0, d0
0101f284  00000000          ori.b    #$0, d0
0101f288  00000000          ori.b    #$0, d0
0101f28c  00000000          ori.b    #$0, d0
0101f290  00000000          ori.b    #$0, d0
0101f294  00000000          ori.b    #$0, d0
0101f298  00000000          ori.b    #$0, d0
0101f29c  00000000          ori.b    #$0, d0
0101f2a0  00000000          ori.b    #$0, d0
0101f2a4  00000000          ori.b    #$0, d0
0101f2a8  00000000          ori.b    #$0, d0
0101f2ac  00000000          ori.b    #$0, d0
0101f2b0  00000000          ori.b    #$0, d0
0101f2b4  00000000          ori.b    #$0, d0
0101f2b8  00000000          ori.b    #$0, d0
0101f2bc  00000000          ori.b    #$0, d0
0101f2c0  00000000          ori.b    #$0, d0
0101f2c4  00000000          ori.b    #$0, d0
0101f2c8  00000000          ori.b    #$0, d0
0101f2cc  00000000          ori.b    #$0, d0
0101f2d0  00000000          ori.b    #$0, d0
0101f2d4  00000000          ori.b    #$0, d0
0101f2d8  00000000          ori.b    #$0, d0
0101f2dc  00000000          ori.b    #$0, d0
0101f2e0  00000000          ori.b    #$0, d0
0101f2e4  00000000          ori.b    #$0, d0
0101f2e8  00000000          ori.b    #$0, d0
0101f2ec  00000000          ori.b    #$0, d0
0101f2f0  00000000          ori.b    #$0, d0
0101f2f4  00000000          ori.b    #$0, d0
0101f2f8  00000000          ori.b    #$0, d0
0101f2fc  00000000          ori.b    #$0, d0
0101f300  00000000          ori.b    #$0, d0
0101f304  00000000          ori.b    #$0, d0
0101f308  00000000          ori.b    #$0, d0
0101f30c  00000000          ori.b    #$0, d0
0101f310  00000000          ori.b    #$0, d0
0101f314  00000000          ori.b    #$0, d0
0101f318  00000000          ori.b    #$0, d0
0101f31c  00000000          ori.b    #$0, d0
0101f320  00000000          ori.b    #$0, d0
0101f324  00000000          ori.b    #$0, d0
0101f328  00000000          ori.b    #$0, d0
0101f32c  00000000          ori.b    #$0, d0
0101f330  00000000          ori.b    #$0, d0
0101f334  00000000          ori.b    #$0, d0
0101f338  00000000          ori.b    #$0, d0
0101f33c  00000000          ori.b    #$0, d0
0101f340  00000000          ori.b    #$0, d0
0101f344  00000000          ori.b    #$0, d0
0101f348  00000000          ori.b    #$0, d0
0101f34c  00000000          ori.b    #$0, d0
0101f350  00000000          ori.b    #$0, d0
0101f354  00000000          ori.b    #$0, d0
0101f358  00000000          ori.b    #$0, d0
0101f35c  00000000          ori.b    #$0, d0
0101f360  00000000          ori.b    #$0, d0
0101f364  00000000          ori.b    #$0, d0
0101f368  00000000          ori.b    #$0, d0
0101f36c  00000000          ori.b    #$0, d0
0101f370  00000000          ori.b    #$0, d0
0101f374  00000000          ori.b    #$0, d0
0101f378  00000000          ori.b    #$0, d0
0101f37c  00000000          ori.b    #$0, d0
0101f380  00000000          ori.b    #$0, d0
0101f384  00000000          ori.b    #$0, d0
0101f388  00000000          ori.b    #$0, d0
0101f38c  00000000          ori.b    #$0, d0
0101f390  00000000          ori.b    #$0, d0
0101f394  00000000          ori.b    #$0, d0
0101f398  00000000          ori.b    #$0, d0
0101f39c  00000000          ori.b    #$0, d0
0101f3a0  00000000          ori.b    #$0, d0
0101f3a4  00000000          ori.b    #$0, d0
0101f3a8  00000000          ori.b    #$0, d0
0101f3ac  00000000          ori.b    #$0, d0
0101f3b0  00000000          ori.b    #$0, d0
0101f3b4  00000000          ori.b    #$0, d0
0101f3b8  00000000          ori.b    #$0, d0
0101f3bc  00000000          ori.b    #$0, d0
0101f3c0  00000000          ori.b    #$0, d0
0101f3c4  00000000          ori.b    #$0, d0
0101f3c8  00000000          ori.b    #$0, d0
0101f3cc  00000000          ori.b    #$0, d0
0101f3d0  00000000          ori.b    #$0, d0
0101f3d4  00000000          ori.b    #$0, d0
0101f3d8  00000000          ori.b    #$0, d0
0101f3dc  00000000          ori.b    #$0, d0
0101f3e0  00000000          ori.b    #$0, d0
0101f3e4  00000000          ori.b    #$0, d0
0101f3e8  00000000          ori.b    #$0, d0
0101f3ec  00000000          ori.b    #$0, d0
0101f3f0  00000000          ori.b    #$0, d0
0101f3f4  00000000          ori.b    #$0, d0
0101f3f8  00000000          ori.b    #$0, d0
0101f3fc  00000000          ori.b    #$0, d0
0101f400  00000000          ori.b    #$0, d0
0101f404  00000000          ori.b    #$0, d0
0101f408  00000000          ori.b    #$0, d0
0101f40c  00000000          ori.b    #$0, d0
0101f410  00000000          ori.b    #$0, d0
0101f414  00000000          ori.b    #$0, d0
0101f418  00000000          ori.b    #$0, d0
0101f41c  00000000          ori.b    #$0, d0
0101f420  00000000          ori.b    #$0, d0
0101f424  00000000          ori.b    #$0, d0
0101f428  00000000          ori.b    #$0, d0
0101f42c  00000000          ori.b    #$0, d0
0101f430  00000000          ori.b    #$0, d0
0101f434  00000000          ori.b    #$0, d0
0101f438  00000000          ori.b    #$0, d0
0101f43c  00000000          ori.b    #$0, d0
0101f440  00000000          ori.b    #$0, d0
0101f444  00000000          ori.b    #$0, d0
0101f448  00000000          ori.b    #$0, d0
0101f44c  00000000          ori.b    #$0, d0
0101f450  00000000          ori.b    #$0, d0
0101f454  00000000          ori.b    #$0, d0
0101f458  00000000          ori.b    #$0, d0
0101f45c  00000000          ori.b    #$0, d0
0101f460  00000000          ori.b    #$0, d0
0101f464  00000000          ori.b    #$0, d0
0101f468  00000000          ori.b    #$0, d0
0101f46c  00000000          ori.b    #$0, d0
0101f470  00000000          ori.b    #$0, d0
0101f474  00000000          ori.b    #$0, d0
0101f478  00000000          ori.b    #$0, d0
0101f47c  00000000          ori.b    #$0, d0
0101f480  00000000          ori.b    #$0, d0
0101f484  00000000          ori.b    #$0, d0
0101f488  00000000          ori.b    #$0, d0
0101f48c  00000000          ori.b    #$0, d0
0101f490  00000000          ori.b    #$0, d0
0101f494  00000000          ori.b    #$0, d0
0101f498  00000000          ori.b    #$0, d0
0101f49c  00000000          ori.b    #$0, d0
0101f4a0  00000000          ori.b    #$0, d0
0101f4a4  00000000          ori.b    #$0, d0
0101f4a8  00000000          ori.b    #$0, d0
0101f4ac  00000000          ori.b    #$0, d0
0101f4b0  00000000          ori.b    #$0, d0
0101f4b4  00000000          ori.b    #$0, d0
0101f4b8  00000000          ori.b    #$0, d0
0101f4bc  00000000          ori.b    #$0, d0
0101f4c0  00000000          ori.b    #$0, d0
0101f4c4  00000000          ori.b    #$0, d0
0101f4c8  00000000          ori.b    #$0, d0
0101f4cc  00000000          ori.b    #$0, d0
0101f4d0  00000000          ori.b    #$0, d0
0101f4d4  00000000          ori.b    #$0, d0
0101f4d8  00000000          ori.b    #$0, d0
0101f4dc  00000000          ori.b    #$0, d0
0101f4e0  00000000          ori.b    #$0, d0
0101f4e4  00000000          ori.b    #$0, d0
0101f4e8  00000000          ori.b    #$0, d0
0101f4ec  00000000          ori.b    #$0, d0
0101f4f0  00000000          ori.b    #$0, d0
0101f4f4  00000000          ori.b    #$0, d0
0101f4f8  00000000          ori.b    #$0, d0
0101f4fc  00000000          ori.b    #$0, d0
0101f500  00000000          ori.b    #$0, d0
0101f504  00000000          ori.b    #$0, d0
0101f508  00000000          ori.b    #$0, d0
0101f50c  00000000          ori.b    #$0, d0
0101f510  00000000          ori.b    #$0, d0
0101f514  00000000          ori.b    #$0, d0
0101f518  00000000          ori.b    #$0, d0
0101f51c  00000000          ori.b    #$0, d0
0101f520  00000000          ori.b    #$0, d0
0101f524  00000000          ori.b    #$0, d0
0101f528  00000000          ori.b    #$0, d0
0101f52c  00000000          ori.b    #$0, d0
0101f530  00000000          ori.b    #$0, d0
0101f534  00000000          ori.b    #$0, d0
0101f538  00000000          ori.b    #$0, d0
0101f53c  00000000          ori.b    #$0, d0
0101f540  00000000          ori.b    #$0, d0
0101f544  00000000          ori.b    #$0, d0
0101f548  00000000          ori.b    #$0, d0
0101f54c  00000000          ori.b    #$0, d0
0101f550  00000000          ori.b    #$0, d0
0101f554  00000000          ori.b    #$0, d0
0101f558  00000000          ori.b    #$0, d0
0101f55c  00000000          ori.b    #$0, d0
0101f560  00000000          ori.b    #$0, d0
0101f564  00000000          ori.b    #$0, d0
0101f568  00000000          ori.b    #$0, d0
0101f56c  00000000          ori.b    #$0, d0
0101f570  00000000          ori.b    #$0, d0
0101f574  00000000          ori.b    #$0, d0
0101f578  00000000          ori.b    #$0, d0
0101f57c  00000000          ori.b    #$0, d0
0101f580  00000000          ori.b    #$0, d0
0101f584  00000000          ori.b    #$0, d0
0101f588  00000000          ori.b    #$0, d0
0101f58c  00000000          ori.b    #$0, d0
0101f590  00000000          ori.b    #$0, d0
0101f594  00000000          ori.b    #$0, d0
0101f598  00000000          ori.b    #$0, d0
0101f59c  00000000          ori.b    #$0, d0
0101f5a0  00000000          ori.b    #$0, d0
0101f5a4  00000000          ori.b    #$0, d0
0101f5a8  00000000          ori.b    #$0, d0
0101f5ac  00000000          ori.b    #$0, d0
0101f5b0  00000000          ori.b    #$0, d0
0101f5b4  00000000          ori.b    #$0, d0
0101f5b8  00000000          ori.b    #$0, d0
0101f5bc  00000000          ori.b    #$0, d0
0101f5c0  00000000          ori.b    #$0, d0
0101f5c4  00000000          ori.b    #$0, d0
0101f5c8  00000000          ori.b    #$0, d0
0101f5cc  00000000          ori.b    #$0, d0
0101f5d0  00000000          ori.b    #$0, d0
0101f5d4  00000000          ori.b    #$0, d0
0101f5d8  00000000          ori.b    #$0, d0
0101f5dc  00000000          ori.b    #$0, d0
0101f5e0  00000000          ori.b    #$0, d0
0101f5e4  00000000          ori.b    #$0, d0
0101f5e8  00000000          ori.b    #$0, d0
0101f5ec  00000000          ori.b    #$0, d0
0101f5f0  00000000          ori.b    #$0, d0
0101f5f4  00000000          ori.b    #$0, d0
0101f5f8  00000000          ori.b    #$0, d0
0101f5fc  00000000          ori.b    #$0, d0
0101f600  00000000          ori.b    #$0, d0
0101f604  00000000          ori.b    #$0, d0
0101f608  00000000          ori.b    #$0, d0
0101f60c  00000000          ori.b    #$0, d0
0101f610  00000000          ori.b    #$0, d0
0101f614  00000000          ori.b    #$0, d0
0101f618  00000000          ori.b    #$0, d0
0101f61c  00000000          ori.b    #$0, d0
0101f620  00000000          ori.b    #$0, d0
0101f624  00000000          ori.b    #$0, d0
0101f628  00000000          ori.b    #$0, d0
0101f62c  00000000          ori.b    #$0, d0
0101f630  00000000          ori.b    #$0, d0
0101f634  00000000          ori.b    #$0, d0
0101f638  00000000          ori.b    #$0, d0
0101f63c  00000000          ori.b    #$0, d0
0101f640  00000000          ori.b    #$0, d0
0101f644  00000000          ori.b    #$0, d0
0101f648  00000000          ori.b    #$0, d0
0101f64c  00000000          ori.b    #$0, d0
0101f650  00000000          ori.b    #$0, d0
0101f654  00000000          ori.b    #$0, d0
0101f658  00000000          ori.b    #$0, d0
0101f65c  00000000          ori.b    #$0, d0
0101f660  00000000          ori.b    #$0, d0
0101f664  00000000          ori.b    #$0, d0
0101f668  00000000          ori.b    #$0, d0
0101f66c  00000000          ori.b    #$0, d0
0101f670  00000000          ori.b    #$0, d0
0101f674  00000000          ori.b    #$0, d0
0101f678  00000000          ori.b    #$0, d0
0101f67c  00000000          ori.b    #$0, d0
0101f680  00000000          ori.b    #$0, d0
0101f684  00000000          ori.b    #$0, d0
0101f688  00000000          ori.b    #$0, d0
0101f68c  00000000          ori.b    #$0, d0
0101f690  00000000          ori.b    #$0, d0
0101f694  00000000          ori.b    #$0, d0
0101f698  00000000          ori.b    #$0, d0
0101f69c  00000000          ori.b    #$0, d0
0101f6a0  00000000          ori.b    #$0, d0
0101f6a4  00000000          ori.b    #$0, d0
0101f6a8  00000000          ori.b    #$0, d0
0101f6ac  00000000          ori.b    #$0, d0
0101f6b0  00000000          ori.b    #$0, d0
0101f6b4  00000000          ori.b    #$0, d0
0101f6b8  00000000          ori.b    #$0, d0
0101f6bc  00000000          ori.b    #$0, d0
0101f6c0  00000000          ori.b    #$0, d0
0101f6c4  00000000          ori.b    #$0, d0
0101f6c8  00000000          ori.b    #$0, d0
0101f6cc  00000000          ori.b    #$0, d0
0101f6d0  00000000          ori.b    #$0, d0
0101f6d4  00000000          ori.b    #$0, d0
0101f6d8  00000000          ori.b    #$0, d0
0101f6dc  00000000          ori.b    #$0, d0
0101f6e0  00000000          ori.b    #$0, d0
0101f6e4  00000000          ori.b    #$0, d0
0101f6e8  00000000          ori.b    #$0, d0
0101f6ec  00000000          ori.b    #$0, d0
0101f6f0  00000000          ori.b    #$0, d0
0101f6f4  00000000          ori.b    #$0, d0
0101f6f8  00000000          ori.b    #$0, d0
0101f6fc  00000000          ori.b    #$0, d0
0101f700  00000000          ori.b    #$0, d0
0101f704  00000000          ori.b    #$0, d0
0101f708  00000000          ori.b    #$0, d0
0101f70c  00000000          ori.b    #$0, d0
0101f710  00000000          ori.b    #$0, d0
0101f714  00000000          ori.b    #$0, d0
0101f718  00000000          ori.b    #$0, d0
0101f71c  00000000          ori.b    #$0, d0
0101f720  00000000          ori.b    #$0, d0
0101f724  00000000          ori.b    #$0, d0
0101f728  00000000          ori.b    #$0, d0
0101f72c  00000000          ori.b    #$0, d0
0101f730  00000000          ori.b    #$0, d0
0101f734  00000000          ori.b    #$0, d0
0101f738  00000000          ori.b    #$0, d0
0101f73c  00000000          ori.b    #$0, d0
0101f740  00000000          ori.b    #$0, d0
0101f744  00000000          ori.b    #$0, d0
0101f748  00000000          ori.b    #$0, d0
0101f74c  00000000          ori.b    #$0, d0
0101f750  00000000          ori.b    #$0, d0
0101f754  00000000          ori.b    #$0, d0
0101f758  00000000          ori.b    #$0, d0
0101f75c  00000000          ori.b    #$0, d0
0101f760  00000000          ori.b    #$0, d0
0101f764  00000000          ori.b    #$0, d0
0101f768  00000000          ori.b    #$0, d0
0101f76c  00000000          ori.b    #$0, d0
0101f770  00000000          ori.b    #$0, d0
0101f774  00000000          ori.b    #$0, d0
0101f778  00000000          ori.b    #$0, d0
0101f77c  00000000          ori.b    #$0, d0
0101f780  00000000          ori.b    #$0, d0
0101f784  00000000          ori.b    #$0, d0
0101f788  00000000          ori.b    #$0, d0
0101f78c  00000000          ori.b    #$0, d0
0101f790  00000000          ori.b    #$0, d0
0101f794  00000000          ori.b    #$0, d0
0101f798  00000000          ori.b    #$0, d0
0101f79c  00000000          ori.b    #$0, d0
0101f7a0  00000000          ori.b    #$0, d0
0101f7a4  00000000          ori.b    #$0, d0
0101f7a8  00000000          ori.b    #$0, d0
0101f7ac  00000000          ori.b    #$0, d0
0101f7b0  00000000          ori.b    #$0, d0
0101f7b4  00000000          ori.b    #$0, d0
0101f7b8  00000000          ori.b    #$0, d0
0101f7bc  00000000          ori.b    #$0, d0
0101f7c0  00000000          ori.b    #$0, d0
0101f7c4  00000000          ori.b    #$0, d0
0101f7c8  00000000          ori.b    #$0, d0
0101f7cc  00000000          ori.b    #$0, d0
0101f7d0  00000000          ori.b    #$0, d0
0101f7d4  00000000          ori.b    #$0, d0
0101f7d8  00000000          ori.b    #$0, d0
0101f7dc  00000000          ori.b    #$0, d0
0101f7e0  00000000          ori.b    #$0, d0
0101f7e4  00000000          ori.b    #$0, d0
0101f7e8  00000000          ori.b    #$0, d0
0101f7ec  00000000          ori.b    #$0, d0
0101f7f0  00000000          ori.b    #$0, d0
0101f7f4  00000000          ori.b    #$0, d0
0101f7f8  00000000          ori.b    #$0, d0
0101f7fc  00000000          ori.b    #$0, d0
0101f800  00000000          ori.b    #$0, d0
0101f804  00000000          ori.b    #$0, d0
0101f808  00000000          ori.b    #$0, d0
0101f80c  00000000          ori.b    #$0, d0
0101f810  00000000          ori.b    #$0, d0
0101f814  00000000          ori.b    #$0, d0
0101f818  00000000          ori.b    #$0, d0
0101f81c  00000000          ori.b    #$0, d0
0101f820  00000000          ori.b    #$0, d0
0101f824  00000000          ori.b    #$0, d0
0101f828  00000000          ori.b    #$0, d0
0101f82c  00000000          ori.b    #$0, d0
0101f830  00000000          ori.b    #$0, d0
0101f834  00000000          ori.b    #$0, d0
0101f838  00000000          ori.b    #$0, d0
0101f83c  00000000          ori.b    #$0, d0
0101f840  00000000          ori.b    #$0, d0
0101f844  00000000          ori.b    #$0, d0
0101f848  00000000          ori.b    #$0, d0
0101f84c  00000000          ori.b    #$0, d0
0101f850  00000000          ori.b    #$0, d0
0101f854  00000000          ori.b    #$0, d0
0101f858  00000000          ori.b    #$0, d0
0101f85c  00000000          ori.b    #$0, d0
0101f860  00000000          ori.b    #$0, d0
0101f864  00000000          ori.b    #$0, d0
0101f868  00000000          ori.b    #$0, d0
0101f86c  00000000          ori.b    #$0, d0
0101f870  00000000          ori.b    #$0, d0
0101f874  00000000          ori.b    #$0, d0
0101f878  00000000          ori.b    #$0, d0
0101f87c  00000000          ori.b    #$0, d0
0101f880  00000000          ori.b    #$0, d0
0101f884  00000000          ori.b    #$0, d0
0101f888  00000000          ori.b    #$0, d0
0101f88c  00000000          ori.b    #$0, d0
0101f890  00000000          ori.b    #$0, d0
0101f894  00000000          ori.b    #$0, d0
0101f898  00000000          ori.b    #$0, d0
0101f89c  00000000          ori.b    #$0, d0
0101f8a0  00000000          ori.b    #$0, d0
0101f8a4  00000000          ori.b    #$0, d0
0101f8a8  00000000          ori.b    #$0, d0
0101f8ac  00000000          ori.b    #$0, d0
0101f8b0  00000000          ori.b    #$0, d0
0101f8b4  00000000          ori.b    #$0, d0
0101f8b8  00000000          ori.b    #$0, d0
0101f8bc  00000000          ori.b    #$0, d0
0101f8c0  00000000          ori.b    #$0, d0
0101f8c4  00000000          ori.b    #$0, d0
0101f8c8  00000000          ori.b    #$0, d0
0101f8cc  00000000          ori.b    #$0, d0
0101f8d0  00000000          ori.b    #$0, d0
0101f8d4  00000000          ori.b    #$0, d0
0101f8d8  00000000          ori.b    #$0, d0
0101f8dc  00000000          ori.b    #$0, d0
0101f8e0  00000000          ori.b    #$0, d0
0101f8e4  00000000          ori.b    #$0, d0
0101f8e8  00000000          ori.b    #$0, d0
0101f8ec  00000000          ori.b    #$0, d0
0101f8f0  00000000          ori.b    #$0, d0
0101f8f4  00000000          ori.b    #$0, d0
0101f8f8  00000000          ori.b    #$0, d0
0101f8fc  00000000          ori.b    #$0, d0
0101f900  00000000          ori.b    #$0, d0
0101f904  00000000          ori.b    #$0, d0
0101f908  00000000          ori.b    #$0, d0
0101f90c  00000000          ori.b    #$0, d0
0101f910  00000000          ori.b    #$0, d0
0101f914  00000000          ori.b    #$0, d0
0101f918  00000000          ori.b    #$0, d0
0101f91c  00000000          ori.b    #$0, d0
0101f920  00000000          ori.b    #$0, d0
0101f924  00000000          ori.b    #$0, d0
0101f928  00000000          ori.b    #$0, d0
0101f92c  00000000          ori.b    #$0, d0
0101f930  00000000          ori.b    #$0, d0
0101f934  00000000          ori.b    #$0, d0
0101f938  00000000          ori.b    #$0, d0
0101f93c  00000000          ori.b    #$0, d0
0101f940  00000000          ori.b    #$0, d0
0101f944  00000000          ori.b    #$0, d0
0101f948  00000000          ori.b    #$0, d0
0101f94c  00000000          ori.b    #$0, d0
0101f950  00000000          ori.b    #$0, d0
0101f954  00000000          ori.b    #$0, d0
0101f958  00000000          ori.b    #$0, d0
0101f95c  00000000          ori.b    #$0, d0
0101f960  00000000          ori.b    #$0, d0
0101f964  00000000          ori.b    #$0, d0
0101f968  00000000          ori.b    #$0, d0
0101f96c  00000000          ori.b    #$0, d0
0101f970  00000000          ori.b    #$0, d0
0101f974  00000000          ori.b    #$0, d0
0101f978  00000000          ori.b    #$0, d0
0101f97c  00000000          ori.b    #$0, d0
0101f980  00000000          ori.b    #$0, d0
0101f984  00000000          ori.b    #$0, d0
0101f988  00000000          ori.b    #$0, d0
0101f98c  00000000          ori.b    #$0, d0
0101f990  00000000          ori.b    #$0, d0
0101f994  00000000          ori.b    #$0, d0
0101f998  00000000          ori.b    #$0, d0
0101f99c  00000000          ori.b    #$0, d0
0101f9a0  00000000          ori.b    #$0, d0
0101f9a4  00000000          ori.b    #$0, d0
0101f9a8  00000000          ori.b    #$0, d0
0101f9ac  00000000          ori.b    #$0, d0
0101f9b0  00000000          ori.b    #$0, d0
0101f9b4  00000000          ori.b    #$0, d0
0101f9b8  00000000          ori.b    #$0, d0
0101f9bc  00000000          ori.b    #$0, d0
0101f9c0  00000000          ori.b    #$0, d0
0101f9c4  00000000          ori.b    #$0, d0
0101f9c8  00000000          ori.b    #$0, d0
0101f9cc  00000000          ori.b    #$0, d0
0101f9d0  00000000          ori.b    #$0, d0
0101f9d4  00000000          ori.b    #$0, d0
0101f9d8  00000000          ori.b    #$0, d0
0101f9dc  00000000          ori.b    #$0, d0
0101f9e0  00000000          ori.b    #$0, d0
0101f9e4  00000000          ori.b    #$0, d0
0101f9e8  00000000          ori.b    #$0, d0
0101f9ec  00000000          ori.b    #$0, d0
0101f9f0  00000000          ori.b    #$0, d0
0101f9f4  00000000          ori.b    #$0, d0
0101f9f8  00000000          ori.b    #$0, d0
0101f9fc  00000000          ori.b    #$0, d0
0101fa00  00000000          ori.b    #$0, d0
0101fa04  00000000          ori.b    #$0, d0
0101fa08  00000000          ori.b    #$0, d0
0101fa0c  00000000          ori.b    #$0, d0
0101fa10  00000000          ori.b    #$0, d0
0101fa14  00000000          ori.b    #$0, d0
0101fa18  00000000          ori.b    #$0, d0
0101fa1c  00000000          ori.b    #$0, d0
0101fa20  00000000          ori.b    #$0, d0
0101fa24  00000000          ori.b    #$0, d0
0101fa28  00000000          ori.b    #$0, d0
0101fa2c  00000000          ori.b    #$0, d0
0101fa30  00000000          ori.b    #$0, d0
0101fa34  00000000          ori.b    #$0, d0
0101fa38  00000000          ori.b    #$0, d0
0101fa3c  00000000          ori.b    #$0, d0
0101fa40  00000000          ori.b    #$0, d0
0101fa44  00000000          ori.b    #$0, d0
0101fa48  00000000          ori.b    #$0, d0
0101fa4c  00000000          ori.b    #$0, d0
0101fa50  00000000          ori.b    #$0, d0
0101fa54  00000000          ori.b    #$0, d0
0101fa58  00000000          ori.b    #$0, d0
0101fa5c  00000000          ori.b    #$0, d0
0101fa60  00000000          ori.b    #$0, d0
0101fa64  00000000          ori.b    #$0, d0
0101fa68  00000000          ori.b    #$0, d0
0101fa6c  00000000          ori.b    #$0, d0
0101fa70  00000000          ori.b    #$0, d0
0101fa74  00000000          ori.b    #$0, d0
0101fa78  00000000          ori.b    #$0, d0
0101fa7c  00000000          ori.b    #$0, d0
0101fa80  00000000          ori.b    #$0, d0
0101fa84  00000000          ori.b    #$0, d0
0101fa88  00000000          ori.b    #$0, d0
0101fa8c  00000000          ori.b    #$0, d0
0101fa90  00000000          ori.b    #$0, d0
0101fa94  00000000          ori.b    #$0, d0
0101fa98  00000000          ori.b    #$0, d0
0101fa9c  00000000          ori.b    #$0, d0
0101faa0  00000000          ori.b    #$0, d0
0101faa4  00000000          ori.b    #$0, d0
0101faa8  00000000          ori.b    #$0, d0
0101faac  00000000          ori.b    #$0, d0
0101fab0  00000000          ori.b    #$0, d0
0101fab4  00000000          ori.b    #$0, d0
0101fab8  00000000          ori.b    #$0, d0
0101fabc  00000000          ori.b    #$0, d0
0101fac0  00000000          ori.b    #$0, d0
0101fac4  00000000          ori.b    #$0, d0
0101fac8  00000000          ori.b    #$0, d0
0101facc  00000000          ori.b    #$0, d0
0101fad0  00000000          ori.b    #$0, d0
0101fad4  00000000          ori.b    #$0, d0
0101fad8  00000000          ori.b    #$0, d0
0101fadc  00000000          ori.b    #$0, d0
0101fae0  00000000          ori.b    #$0, d0
0101fae4  00000000          ori.b    #$0, d0
0101fae8  00000000          ori.b    #$0, d0
0101faec  00000000          ori.b    #$0, d0
0101faf0  00000000          ori.b    #$0, d0
0101faf4  00000000          ori.b    #$0, d0
0101faf8  00000000          ori.b    #$0, d0
0101fafc  00000000          ori.b    #$0, d0
0101fb00  00000000          ori.b    #$0, d0
0101fb04  00000000          ori.b    #$0, d0
0101fb08  00000000          ori.b    #$0, d0
0101fb0c  00000000          ori.b    #$0, d0
0101fb10  00000000          ori.b    #$0, d0
0101fb14  00000000          ori.b    #$0, d0
0101fb18  00000000          ori.b    #$0, d0
0101fb1c  00000000          ori.b    #$0, d0
0101fb20  00000000          ori.b    #$0, d0
0101fb24  00000000          ori.b    #$0, d0
0101fb28  00000000          ori.b    #$0, d0
0101fb2c  00000000          ori.b    #$0, d0
0101fb30  00000000          ori.b    #$0, d0
0101fb34  00000000          ori.b    #$0, d0
0101fb38  00000000          ori.b    #$0, d0
0101fb3c  00000000          ori.b    #$0, d0
0101fb40  00000000          ori.b    #$0, d0
0101fb44  00000000          ori.b    #$0, d0
0101fb48  00000000          ori.b    #$0, d0
0101fb4c  00000000          ori.b    #$0, d0
0101fb50  00000000          ori.b    #$0, d0
0101fb54  00000000          ori.b    #$0, d0
0101fb58  00000000          ori.b    #$0, d0
0101fb5c  00000000          ori.b    #$0, d0
0101fb60  00000000          ori.b    #$0, d0
0101fb64  00000000          ori.b    #$0, d0
0101fb68  00000000          ori.b    #$0, d0
0101fb6c  00000000          ori.b    #$0, d0
0101fb70  00000000          ori.b    #$0, d0
0101fb74  00000000          ori.b    #$0, d0
0101fb78  00000000          ori.b    #$0, d0
0101fb7c  00000000          ori.b    #$0, d0
0101fb80  00000000          ori.b    #$0, d0
0101fb84  00000000          ori.b    #$0, d0
0101fb88  00000000          ori.b    #$0, d0
0101fb8c  00000000          ori.b    #$0, d0
0101fb90  00000000          ori.b    #$0, d0
0101fb94  00000000          ori.b    #$0, d0
0101fb98  00000000          ori.b    #$0, d0
0101fb9c  00000000          ori.b    #$0, d0
0101fba0  00000000          ori.b    #$0, d0
0101fba4  00000000          ori.b    #$0, d0
0101fba8  00000000          ori.b    #$0, d0
0101fbac  00000000          ori.b    #$0, d0
0101fbb0  00000000          ori.b    #$0, d0
0101fbb4  00000000          ori.b    #$0, d0
0101fbb8  00000000          ori.b    #$0, d0
0101fbbc  00000000          ori.b    #$0, d0
0101fbc0  00000000          ori.b    #$0, d0
0101fbc4  00000000          ori.b    #$0, d0
0101fbc8  00000000          ori.b    #$0, d0
0101fbcc  00000000          ori.b    #$0, d0
0101fbd0  00000000          ori.b    #$0, d0
0101fbd4  00000000          ori.b    #$0, d0
0101fbd8  00000000          ori.b    #$0, d0
0101fbdc  00000000          ori.b    #$0, d0
0101fbe0  00000000          ori.b    #$0, d0
0101fbe4  00000000          ori.b    #$0, d0
0101fbe8  00000000          ori.b    #$0, d0
0101fbec  00000000          ori.b    #$0, d0
0101fbf0  00000000          ori.b    #$0, d0
0101fbf4  00000000          ori.b    #$0, d0
0101fbf8  00000000          ori.b    #$0, d0
0101fbfc  00000000          ori.b    #$0, d0
0101fc00  00000000          ori.b    #$0, d0
0101fc04  00000000          ori.b    #$0, d0
0101fc08  00000000          ori.b    #$0, d0
0101fc0c  00000000          ori.b    #$0, d0
0101fc10  00000000          ori.b    #$0, d0
0101fc14  00000000          ori.b    #$0, d0
0101fc18  00000000          ori.b    #$0, d0
0101fc1c  00000000          ori.b    #$0, d0
0101fc20  00000000          ori.b    #$0, d0
0101fc24  00000000          ori.b    #$0, d0
0101fc28  00000000          ori.b    #$0, d0
0101fc2c  00000000          ori.b    #$0, d0
0101fc30  00000000          ori.b    #$0, d0
0101fc34  00000000          ori.b    #$0, d0
0101fc38  00000000          ori.b    #$0, d0
0101fc3c  00000000          ori.b    #$0, d0
0101fc40  00000000          ori.b    #$0, d0
0101fc44  00000000          ori.b    #$0, d0
0101fc48  00000000          ori.b    #$0, d0
0101fc4c  00000000          ori.b    #$0, d0
0101fc50  00000000          ori.b    #$0, d0
0101fc54  00000000          ori.b    #$0, d0
0101fc58  00000000          ori.b    #$0, d0
0101fc5c  00000000          ori.b    #$0, d0
0101fc60  00000000          ori.b    #$0, d0
0101fc64  00000000          ori.b    #$0, d0
0101fc68  00000000          ori.b    #$0, d0
0101fc6c  00000000          ori.b    #$0, d0
0101fc70  00000000          ori.b    #$0, d0
0101fc74  00000000          ori.b    #$0, d0
0101fc78  00000000          ori.b    #$0, d0
0101fc7c  00000000          ori.b    #$0, d0
0101fc80  00000000          ori.b    #$0, d0
0101fc84  00000000          ori.b    #$0, d0
0101fc88  00000000          ori.b    #$0, d0
0101fc8c  00000000          ori.b    #$0, d0
0101fc90  00000000          ori.b    #$0, d0
0101fc94  00000000          ori.b    #$0, d0
0101fc98  00000000          ori.b    #$0, d0
0101fc9c  00000000          ori.b    #$0, d0
0101fca0  00000000          ori.b    #$0, d0
0101fca4  00000000          ori.b    #$0, d0
0101fca8  00000000          ori.b    #$0, d0
0101fcac  00000000          ori.b    #$0, d0
0101fcb0  00000000          ori.b    #$0, d0
0101fcb4  00000000          ori.b    #$0, d0
0101fcb8  00000000          ori.b    #$0, d0
0101fcbc  00000000          ori.b    #$0, d0
0101fcc0  00000000          ori.b    #$0, d0
0101fcc4  00000000          ori.b    #$0, d0
0101fcc8  00000000          ori.b    #$0, d0
0101fccc  00000000          ori.b    #$0, d0
0101fcd0  00000000          ori.b    #$0, d0
0101fcd4  00000000          ori.b    #$0, d0
0101fcd8  00000000          ori.b    #$0, d0
0101fcdc  00000000          ori.b    #$0, d0
0101fce0  00000000          ori.b    #$0, d0
0101fce4  00000000          ori.b    #$0, d0
0101fce8  00000000          ori.b    #$0, d0
0101fcec  00000000          ori.b    #$0, d0
0101fcf0  00000000          ori.b    #$0, d0
0101fcf4  00000000          ori.b    #$0, d0
0101fcf8  00000000          ori.b    #$0, d0
0101fcfc  00000000          ori.b    #$0, d0
0101fd00  00000000          ori.b    #$0, d0
0101fd04  00000000          ori.b    #$0, d0
0101fd08  00000000          ori.b    #$0, d0
0101fd0c  00000000          ori.b    #$0, d0
0101fd10  00000000          ori.b    #$0, d0
0101fd14  00000000          ori.b    #$0, d0
0101fd18  00000000          ori.b    #$0, d0
0101fd1c  00000000          ori.b    #$0, d0
0101fd20  00000000          ori.b    #$0, d0
0101fd24  00000000          ori.b    #$0, d0
0101fd28  00000000          ori.b    #$0, d0
0101fd2c  00000000          ori.b    #$0, d0
0101fd30  00000000          ori.b    #$0, d0
0101fd34  00000000          ori.b    #$0, d0
0101fd38  00000000          ori.b    #$0, d0
0101fd3c  00000000          ori.b    #$0, d0
0101fd40  00000000          ori.b    #$0, d0
0101fd44  00000000          ori.b    #$0, d0
0101fd48  00000000          ori.b    #$0, d0
0101fd4c  00000000          ori.b    #$0, d0
0101fd50  00000000          ori.b    #$0, d0
0101fd54  00000000          ori.b    #$0, d0
0101fd58  00000000          ori.b    #$0, d0
0101fd5c  00000000          ori.b    #$0, d0
0101fd60  00000000          ori.b    #$0, d0
0101fd64  00000000          ori.b    #$0, d0
0101fd68  00000000          ori.b    #$0, d0
0101fd6c  00000000          ori.b    #$0, d0
0101fd70  00000000          ori.b    #$0, d0
0101fd74  00000000          ori.b    #$0, d0
0101fd78  00000000          ori.b    #$0, d0
0101fd7c  00000000          ori.b    #$0, d0
0101fd80  00000000          ori.b    #$0, d0
0101fd84  00000000          ori.b    #$0, d0
0101fd88  00000000          ori.b    #$0, d0
0101fd8c  00000000          ori.b    #$0, d0
0101fd90  00000000          ori.b    #$0, d0
0101fd94  00000000          ori.b    #$0, d0
0101fd98  00000000          ori.b    #$0, d0
0101fd9c  00000000          ori.b    #$0, d0
0101fda0  00000000          ori.b    #$0, d0
0101fda4  00000000          ori.b    #$0, d0
0101fda8  00000000          ori.b    #$0, d0
0101fdac  00000000          ori.b    #$0, d0
0101fdb0  00000000          ori.b    #$0, d0
0101fdb4  00000000          ori.b    #$0, d0
0101fdb8  00000000          ori.b    #$0, d0
0101fdbc  00000000          ori.b    #$0, d0
0101fdc0  00000000          ori.b    #$0, d0
0101fdc4  00000000          ori.b    #$0, d0
0101fdc8  00000000          ori.b    #$0, d0
0101fdcc  00000000          ori.b    #$0, d0
0101fdd0  00000000          ori.b    #$0, d0
0101fdd4  00000000          ori.b    #$0, d0
0101fdd8  00000000          ori.b    #$0, d0
0101fddc  00000000          ori.b    #$0, d0
0101fde0  00000000          ori.b    #$0, d0
0101fde4  00000000          ori.b    #$0, d0
0101fde8  00000000          ori.b    #$0, d0
0101fdec  00000000          ori.b    #$0, d0
0101fdf0  00000000          ori.b    #$0, d0
0101fdf4  00000000          ori.b    #$0, d0
0101fdf8  00000000          ori.b    #$0, d0
0101fdfc  00000000          ori.b    #$0, d0
0101fe00  00000000          ori.b    #$0, d0
0101fe04  00000000          ori.b    #$0, d0
0101fe08  00000000          ori.b    #$0, d0
0101fe0c  00000000          ori.b    #$0, d0
0101fe10  00000000          ori.b    #$0, d0
0101fe14  00000000          ori.b    #$0, d0
0101fe18  00000000          ori.b    #$0, d0
0101fe1c  00000000          ori.b    #$0, d0
0101fe20  00000000          ori.b    #$0, d0
0101fe24  00000000          ori.b    #$0, d0
0101fe28  00000000          ori.b    #$0, d0
0101fe2c  00000000          ori.b    #$0, d0
0101fe30  00000000          ori.b    #$0, d0
0101fe34  00000000          ori.b    #$0, d0
0101fe38  00000000          ori.b    #$0, d0
0101fe3c  00000000          ori.b    #$0, d0
0101fe40  00000000          ori.b    #$0, d0
0101fe44  00000000          ori.b    #$0, d0
0101fe48  00000000          ori.b    #$0, d0
0101fe4c  00000000          ori.b    #$0, d0
0101fe50  00000000          ori.b    #$0, d0
0101fe54  00000000          ori.b    #$0, d0
0101fe58  00000000          ori.b    #$0, d0
0101fe5c  00000000          ori.b    #$0, d0
0101fe60  00000000          ori.b    #$0, d0
0101fe64  00000000          ori.b    #$0, d0
0101fe68  00000000          ori.b    #$0, d0
0101fe6c  00000000          ori.b    #$0, d0
0101fe70  00000000          ori.b    #$0, d0
0101fe74  00000000          ori.b    #$0, d0
0101fe78  00000000          ori.b    #$0, d0
0101fe7c  00000000          ori.b    #$0, d0
0101fe80  00000000          ori.b    #$0, d0
0101fe84  00000000          ori.b    #$0, d0
0101fe88  00000000          ori.b    #$0, d0
0101fe8c  00000000          ori.b    #$0, d0
0101fe90  00000000          ori.b    #$0, d0
0101fe94  00000000          ori.b    #$0, d0
0101fe98  00000000          ori.b    #$0, d0
0101fe9c  00000000          ori.b    #$0, d0
0101fea0  00000000          ori.b    #$0, d0
0101fea4  00000000          ori.b    #$0, d0
0101fea8  00000000          ori.b    #$0, d0
0101feac  00000000          ori.b    #$0, d0
0101feb0  00000000          ori.b    #$0, d0
0101feb4  00000000          ori.b    #$0, d0
0101feb8  00000000          ori.b    #$0, d0
0101febc  00000000          ori.b    #$0, d0
0101fec0  00000000          ori.b    #$0, d0
0101fec4  00000000          ori.b    #$0, d0
0101fec8  00000000          ori.b    #$0, d0
0101fecc  00000000          ori.b    #$0, d0
0101fed0  00000000          ori.b    #$0, d0
0101fed4  00000000          ori.b    #$0, d0
0101fed8  00000000          ori.b    #$0, d0
0101fedc  00000000          ori.b    #$0, d0
0101fee0  00000000          ori.b    #$0, d0
0101fee4  00000000          ori.b    #$0, d0
0101fee8  00000000          ori.b    #$0, d0
0101feec  00000000          ori.b    #$0, d0
0101fef0  00000000          ori.b    #$0, d0
0101fef4  00000000          ori.b    #$0, d0
0101fef8  00000000          ori.b    #$0, d0
0101fefc  00000000          ori.b    #$0, d0
0101ff00  00000000          ori.b    #$0, d0
0101ff04  00000000          ori.b    #$0, d0
0101ff08  00000000          ori.b    #$0, d0
0101ff0c  00000000          ori.b    #$0, d0
0101ff10  00000000          ori.b    #$0, d0
0101ff14  00000000          ori.b    #$0, d0
0101ff18  00000000          ori.b    #$0, d0
0101ff1c  00000000          ori.b    #$0, d0
0101ff20  00000000          ori.b    #$0, d0
0101ff24  00000000          ori.b    #$0, d0
0101ff28  00000000          ori.b    #$0, d0
0101ff2c  00000000          ori.b    #$0, d0
0101ff30  00000000          ori.b    #$0, d0
0101ff34  00000000          ori.b    #$0, d0
0101ff38  00000000          ori.b    #$0, d0
0101ff3c  00000000          ori.b    #$0, d0
0101ff40  00000000          ori.b    #$0, d0
0101ff44  00000000          ori.b    #$0, d0
0101ff48  00000000          ori.b    #$0, d0
0101ff4c  00000000          ori.b    #$0, d0
0101ff50  00000000          ori.b    #$0, d0
0101ff54  00000000          ori.b    #$0, d0
0101ff58  00000000          ori.b    #$0, d0
0101ff5c  00000000          ori.b    #$0, d0
0101ff60  00000000          ori.b    #$0, d0
0101ff64  00000000          ori.b    #$0, d0
0101ff68  00000000          ori.b    #$0, d0
0101ff6c  00000000          ori.b    #$0, d0
0101ff70  00000000          ori.b    #$0, d0
0101ff74  00000000          ori.b    #$0, d0
0101ff78  00000000          ori.b    #$0, d0
0101ff7c  00000000          ori.b    #$0, d0
0101ff80  00000000          ori.b    #$0, d0
0101ff84  00000000          ori.b    #$0, d0
0101ff88  00000000          ori.b    #$0, d0
0101ff8c  00000000          ori.b    #$0, d0
0101ff90  00000000          ori.b    #$0, d0
0101ff94  00000000          ori.b    #$0, d0
0101ff98  00000000          ori.b    #$0, d0
0101ff9c  00000000          ori.b    #$0, d0
0101ffa0  00000000          ori.b    #$0, d0
0101ffa4  00000000          ori.b    #$0, d0
0101ffa8  00000000          ori.b    #$0, d0
0101ffac  00000000          ori.b    #$0, d0
0101ffb0  00000000          ori.b    #$0, d0
0101ffb4  00000000          ori.b    #$0, d0
0101ffb8  00000000          ori.b    #$0, d0
0101ffbc  00000000          ori.b    #$0, d0
0101ffc0  00000000          ori.b    #$0, d0
0101ffc4  00000000          ori.b    #$0, d0
0101ffc8  00000000          ori.b    #$0, d0
0101ffcc  00000000          ori.b    #$0, d0
0101ffd0  00000000          ori.b    #$0, d0
0101ffd4  00000000          ori.b    #$0, d0
0101ffd8  00000000          ori.b    #$0, d0
0101ffdc  00000000          ori.b    #$0, d0
0101ffe0  00000000          ori.b    #$0, d0
0101ffe4  00000000          ori.b    #$0, d0
0101ffe8  00000000          ori.b    #$0, d0
0101ffec  00000000          ori.b    #$0, d0
0101fff0  00000000          ori.b    #$0, d0
0101fff4  00000000          ori.b    #$0, d0
0101fff8  00000000          ori.b    #$0, d0
0101fffc  00000000          ori.b    #$0, d0
