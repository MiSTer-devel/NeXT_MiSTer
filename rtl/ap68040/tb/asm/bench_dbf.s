; AP040 DBcc timing probe (measurement, not a regression leg).
;
; The NeXT boot ROM calibrates its delay() against a bare "dbf d0,*"
; self-loop, assuming a real 68040's 4 clocks per taken iteration
; (6.25 iterations per microsecond at 25 MHz).  This program brackets
; three loops with the bench's $F108 cycle stamps so the clocks per
; iteration can be read under the bench's clock-enable policies
; (+pace, +dbccstall=N):
;   loop A: the ROM's loop, dbf alone
;   loop B: a memcpy-shaped loop, move.l (a0)+,(a1)+ / dbf
;   loop C: a Bcc loop of the shape a compiler emits (cmp/bne)
;
; assembled with vasmm68k_mot -Fbin -m68040 -no-opt

FAILREG	equ	$F100
DONEREG	equ	$F102
STAMP	equ	$F108

ITER	equ	6250
SRC	equ	$4000
DST	equ	$5000

	org	0
	dc.l	$3400
	dc.l	start
	rept	254
	dc.l	unexp
	endr

	org	$400
start:
	move.l	#$80008000,d0	; caches on
	movec	d0,cacr

	; warm the instruction cache on loop A, then measure it
	move.w	#15,d0
warmA:	dbf	d0,warmA

	move.w	#$0A00,(STAMP).l
	move.w	#ITER-1,d0
	cnop	0,32		; the ROM's loop sits at $010024F0: fast-path aligned
loopA:	dbf	d0,loopA
	move.w	#$0A01,(STAMP).l

	; loop B: memcpy-shaped (256 bytes, repeated so the data is cached)
	lea	(SRC).l,a0
	lea	(DST).l,a1
	move.w	#63,d0
warmB:	move.l	(a0)+,(a1)+
	dbf	d0,warmB

	move.w	#$0B00,(STAMP).l
	move.w	#ITER/64-1,d1
outB:	lea	(SRC).l,a0
	lea	(DST).l,a1
	move.w	#63,d0
	cnop	0,32
loopB:	move.l	(a0)+,(a1)+
	dbf	d0,loopB
	dbf	d1,outB
	move.w	#$0B01,(STAMP).l

	; loop C: counted loop closed with cmp/bne, no DBcc
	moveq	#0,d2
	move.w	#$0C00,(STAMP).l
	move.l	#ITER,d0
loopC:	addq.l	#1,d2
	subq.l	#1,d0
	bne.s	loopC
	move.w	#$0C01,(STAMP).l

	cmp.l	#ITER,d2
	bne.s	fail_all

	move.w	#$600D,(DONEREG).l
	stop	#$2700

fail_all:
	move.w	#1,(FAILREG).l
	move.w	#$BAD0,(DONEREG).l
halt1:
	bra.s	halt1

unexp:
	move.w	#$0099,(FAILREG).l
	move.w	#$BAD0,(DONEREG).l
halt2:
	bra.s	halt2
