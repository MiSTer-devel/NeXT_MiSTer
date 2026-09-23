# NeXTcube 68040 boot ROM Rev 2.5 v66 — disassembly

Generated from `reference/previous/src/Rev_2.5_v66.BIN` (131,072 bytes, linked
at `$01000000`; the first 8 bytes are also the reset vectors at `$00000000`).
Real content ends at `$0101708c`; the remaining 36 KB is zero padding.

Regenerate with (needs Python 3 and `capstone`):

```bash
python rom-disassembly/disasm_rom.py
```

| file | what |
|---|---|
| `Rev_2.5_v66.asm` | the full listing: every byte of the ROM as code, string, pointer table or hex data, with labels, cross-references and hardware annotations |
| `functions.md` | index of the 507 routines reached: address, size, callers, pointer-table entries, strings referenced |
| `strings.md` | the 253 NUL-terminated strings with the code that references them |
| `hardware-refs.md` | every absolute NeXT device address the code names, with the register's name from Previous's `ioMemTabNEXT.c` |
| `unreached-linear.asm` | linear-sweep disassembly of the bytes the descent did not reach (tables, and any code reached only through computed jumps) — speculative, for lookup |
| `disasm_rom.py` | the generator; `KNOWN` at the top is the place to add names for routines as they are identified |

## How it was produced

Recursive descent with Capstone (M68K, 68040 mode) from the reset vector
(`$0100001e`) and from every longword in the image that is an even address inside
the ROM — this picks up the C function-pointer tables the monitor is built from
(the `mg` globals, the exception handler table, the command tables).  Capstone 5
does not decode the 68040 MMU/cache/FPU-frame instructions (`pflusha`, `ptest`,
`move16`, `fsave`/`frestore`, some `cinv`/`cpush`), so `decode040()` in the
script handles those; without it the descent stalls at the first `pflusha` in
the reset path.  After the descent, NUL-terminated ASCII runs in the unreached
bytes become strings; unreached pointer longwords become `dc.l label`; the rest
is hex.

Coverage: 61,484 bytes of code (18,631 instructions), 6,077 bytes of strings,
about 27 KB of tables (keymaps, timing/ECC tables, jump tables) and 36 KB of
zero padding.

## Conventions

```
address   bytes             mnemonic operands              ; notes
010024cc  57af0004          subq.l   #$3, $4(a7)
```

* `sub_XXXXXXXX` — a `bsr`/`jsr` target or a pointer-table target that decodes as code.
* `loc_XXXXXXXX` — a branch target inside a routine.
* `str_XXXXXXXX` — a string; the referencing instruction shows the text in its note.
* `dat_XXXXXXXX` — data referenced by an absolute operand or a pointer table.
* Named labels come from `KNOWN` in the script: `reset_entry`, `delay_us`/`delay_loop`,
  the POST test entry points and the POST master's return-value checks
  (`post_*`, from `tb/tb_next_boot.sv`'s watchpoints).
* Capstone prints branch targets and PC-relative operands as absolute addresses
  (`bsr.l $1000a4c` means `$01000a4c`); ROM addresses are replaced by their labels.
* Operands naming a device register carry `; $0200c000 = System Control Register 1 ...`
  from Previous's non-Turbo I/O table.  Accesses through an address register
  (the usual C idiom, `movea.l #$2000040,a0` then `(a0)`) are annotated only at the
  instruction that loads the base.
* Before each labelled routine: `; called from:`, `; jumped to from:` and
  `; pointer table entries at:` list the cross-references.

## Landmarks

| address | label | |
|---|---|---|
| `0100001e` | `reset_entry` | reset vector target; sets CACR, jumps into the init chain |
| `01000a3c` | | `pflusha` / `movec tc` — MMU set up, then `jmp (a0)` into the C init |
| `01000a4c` | | first C routine (`nop; link a6`) — the POST/boot driver |
| `010024cc` | `delay_us` | calibrated delay: `(n-3)*6.25` iterations of `dbf d0,*` at `010024f0` (see `docs/CPU_NEXT_PORT.md`) |
| `010031b4`… | `post_*_test` | POST sub-tests (FPU, SCC, SCSI, Enet, ECC, RTC, Timer, Event counter, Sound out, Extended SCSI) |
| `010046f2`… | `post_ret_*` | the POST master's per-test return checks (D0 = error code) |
| `01001330` | `post_passed_path` | "System test passed" |
