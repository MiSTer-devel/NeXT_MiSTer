; AP040 cache: longword reads that cross a 16-byte cache line
;
; NeXTSTEP 3.3's vm_page_buckets table is 2-byte aligned, so every fourth
; bucket read is a cacheable longword straddling two lines; the cache's
; line-crossing hit path (xline/xlook in ap040_cache.v) returned 0 for it
; (2026-09-23, docs/CPU_NEXT_PORT.md).  t_cache only covers a misaligned
; read inside one line.  Each case below reads a longword at offset $E of a
; line with the two lines in every residency combination.
;
; testbench protocol: $F100 fail number, $F102 result magic

FAILREG	equ	$F100
DONEREG	equ	$F102

failt	macro
	move.w	#\1,d7
	bra	fail_all
	endm

chkl	macro
	cmp.l	#\2,\1
	beq.s	ok\@
	failt	\3
ok\@:
	endm

	org	0
	dc.l	$3400
	dc.l	start
	rept	254
	dc.l	unexp
	endr

	org	$400
start:
	move.l	#$80008000,d0
	movec	d0,cacr

	; two adjacent lines at $3600 and $3610
	move.l	#$11223344,($3600).l
	move.l	#$55667788,($3604).l
	move.l	#$99AABBCC,($3608).l
	move.l	#$DDEEFF00,($360C).l
	move.l	#$0A0B0C0D,($3610).l
	move.l	#$1A1B1C1D,($3614).l
	move.l	#$2A2B2C2D,($3618).l
	move.l	#$3A3B3C3D,($361C).l
	cinva	dc

	; 1: neither line cached (both miss)
	move.l	($360E).l,d0
	chkl	d0,$FF000A0B,1

	; 2: both lines cached (hit + hit)
	cinva	dc
	move.l	($3600).l,d0
	move.l	($3610).l,d0
	move.l	($360E).l,d0
	chkl	d0,$FF000A0B,2

	; 3: only the first line cached (hit + miss)
	cinva	dc
	move.l	($3600).l,d0
	move.l	($360E).l,d0
	chkl	d0,$FF000A0B,3

	; 4: only the second line cached (miss + hit)
	cinva	dc
	move.l	($3610).l,d0
	move.l	($360E).l,d0
	chkl	d0,$FF000A0B,4

	; 5: repeated crossing reads with both lines resident (the kernel's
	; bucket walk hits the same pair again and again)
	move.l	($360E).l,d0
	chkl	d0,$FF000A0B,5
	move.l	($360E).l,d1
	chkl	d1,$FF000A0B,6
	move.l	($360D).l,d0
	chkl	d0,$EEFF000A,7
	move.l	($360F).l,d0
	chkl	d0,$000A0B0C,8

	; 9: word crossing the line at offset $F
	move.w	($360F).l,d0
	and.l	#$FFFF,d0
	chkl	d0,$000A,9

	; 10: crossing read in the set-wrap case: lines at $3FF0 and $4000
	; (with the 4 KB data-bank geometry the next set wraps to 0)
	move.l	#$C0C1C2C3,($3FFC).l
	move.l	#$D0D1D2D3,($4000).l
	cinva	dc
	move.l	($3FF0).l,d0
	move.l	($4000).l,d0
	move.l	($3FFE).l,d0
	chkl	d0,$C2C3D0D1,10

	; 11: a store to the second line after the pair was read
	move.l	#$0E0F1011,($3610).l
	move.l	($360E).l,d0
	chkl	d0,$FF000E0F,11

	move.w	#$600D,(DONEREG).l
	stop	#$2700

fail_all:
	move.w	d7,(FAILREG).l
	move.w	#$BAD0,(DONEREG).l
halt1:
	bra.s	halt1

unexp:
	move.w	#$0099,(FAILREG).l
	move.w	#$BAD0,(DONEREG).l
halt2:
	bra.s	halt2
