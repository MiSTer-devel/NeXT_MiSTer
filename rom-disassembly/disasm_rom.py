#!/usr/bin/env python3
"""Disassemble the NeXTcube 68040 boot ROM (Rev 2.5 v66) into rom-disassembly/.

Method: recursive descent (Capstone M68K, 68040 mode) from the reset vector and
from every longword in the image that points into the ROM (function tables, the
monitor command table, the exception handler table), with ASCII strings found
first so code never runs into them.  Everything reached is code; everything else
is data (strings, ROM-pointer tables, or hex).  Absolute NeXT I/O addresses are
annotated from Previous's ioMemTabNEXT.c.  A linear sweep of the unreached gaps
is written separately for reference.

    python rom-disassembly/disasm_rom.py            # from the repo root
"""
import os, re, struct
from collections import defaultdict
from capstone import Cs, CS_ARCH_M68K, CS_MODE_M68K_040, CS_MODE_BIG_ENDIAN

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROM_PATH = os.path.join(ROOT, "reference/previous/src/Rev_2.5_v66.BIN")
IOTAB = os.path.join(ROOT, "reference/previous/src/ioMemTabNEXT.c")
OUT = os.path.dirname(os.path.abspath(__file__))
BASE = 0x01000000

rom = open(ROM_PATH, "rb").read()
SIZE = len(rom)
END = BASE + SIZE

# ---------------------------------------------------------------- known names
KNOWN = {
    0x0100001e: ("reset_entry", "reset vector target (ROM offset 4)"),
    0x010024cc: ("delay_us", "delay(n us): (n-3)*6.25 iterations of a cached dbf self-loop at $010024F0 (see docs/CPU_NEXT_PORT.md)"),
    0x010024f0: ("delay_loop", "the calibrated dbf d0,* loop"),
    0x01001330: ("post_passed_path", "System test passed path (tb_next_boot)"),
    0x010031b4: ("post_fpu_test", "POST: FPU test entry"),
    0x010031fa: ("post_scc_test", "POST: SCC test entry"),
    0x0100337e: ("post_scsi_test", "POST: SCSI test entry"),
    0x01003430: ("post_ext_scsi_test", "POST: Extended SCSI test entry"),
    0x01003548: ("post_enet_test", "POST: Ethernet test entry"),
    0x0100381a: ("post_ecc_test", "POST: ECC test entry"),
    0x01003b1a: ("post_rtc_test", "POST: RTC test entry"),
    0x01003b98: ("post_timer_test", "POST: Timer test entry"),
    0x01003c7e: ("post_evcnt_test", "POST: Event counter test entry"),
    0x01003d78: ("post_evcnt_measured", "POST: event counter measured delay(1000) in d0 (us)"),
    0x01003f74: ("post_sndout_test", "POST: Sound out test entry"),
    0x010046f2: ("post_ret_fpu", "POST master: FPU test returned (d0)"),
    0x0100471c: ("post_ret_scc", "POST master: SCC test returned (d0)"),
    0x01004746: ("post_ret_scsi", "POST master: SCSI test returned (d0)"),
    0x01004764: ("post_ret_enet", "POST master: Enet test returned (d0)"),
    0x0100479c: ("post_ret_ecc", "POST master: ECC test returned (d0)"),
    0x010047c6: ("post_ret_rtc", "POST master: RTC test returned (d0)"),
    0x010047f0: ("post_ret_timer", "POST master: Timer test returned (d0)"),
    0x0100481a: ("post_ret_evcnt", "POST master: Event counter test returned (d0)"),
    0x01004852: ("post_ret_sndout", "POST master: Sound out test returned (d0)"),
    0x01004884: ("post_ret_ext_scsi", "POST master: Extended SCSI test returned (d0)"),
}

# ---------------------------------------------------------------- I/O map
io = {}          # addr -> (section, name)
io_sections = [] # (addr, section) in file order for range fallback
section = ""
for line in open(IOTAB, encoding="utf-8", errors="replace"):
    m = re.match(r"\s*/\*\s*(.*?)\s*\*/\s*$", line)
    if m and "{" not in line:
        section = m.group(1); continue
    m = re.match(r"\s*\{\s*0x([0-9a-fA-F]+)\s*,\s*0x[0-9a-fA-F]+\s*,\s*SIZE_(\w+)\s*,\s*(\w+)\s*,\s*(\w+)\s*\}\s*,?\s*(?:/\*\s*(.*?)\s*\*/)?", line)
    if m:
        a = int(m.group(1), 16)
        rd, wr = m.group(3), m.group(4)
        def strip(f):
            return re.sub(r"_(Read|Write)$", "", f)
        name = strip(rd) if strip(rd) == strip(wr) else strip(rd) + "/" + strip(wr)
        if m.group(5): name += " (" + m.group(5) + ")"
        io[a] = (section, name)
        if not io_sections or io_sections[-1][1] != section:
            io_sections.append((a, section))
io_addrs = sorted(io)

def io_annot(a):
    """name for an absolute address in NeXT device space"""
    if not (0x02000000 <= a < 0x02200000 or (a >> 16) in (0x020C, 0x820C)):
        return None
    if a in io: return "%s: %s" % io[a]
    lo = [x for x in io_addrs if x <= a and a - x < 16]
    if lo:
        x = lo[-1]; return "%s: %s+%d" % (io[x][0], io[x][1], a - x)
    if (a >> 16) in (0x020C, 0x820C): return "BMAP chip"
    if 0x02100000 <= a < 0x02120000: return "device space mirror (BMAP access path) of $%08x" % (a - 0x00100000)
    sec = [s for x, s in io_sections if x <= a]
    return sec[-1] if sec else "device space"

is_str = bytearray(SIZE)
strings = {}
def printable(c): return 0x20 <= c < 0x7f or c in (0x0a, 0x0d, 0x09)
# ---------------------------------------------------------------- pointers
def rd32(off): return struct.unpack(">I", rom[off:off + 4])[0]
def rom_ptr(v): return BASE <= v < END and (v & 1) == 0

ptr_targets = defaultdict(list)   # target addr -> [source addr]
for off in range(0, SIZE - 3, 2):
    v = rd32(off)
    if rom_ptr(v):
        ptr_targets[v].append(BASE + off)

# ---------------------------------------------------------------- descent
md = Cs(CS_ARCH_M68K, CS_MODE_M68K_040 | CS_MODE_BIG_ENDIAN)
insns = {}       # addr -> (size, mnemonic, op_str, bytes)
code = bytearray(SIZE)   # 1 = instruction start, 2 = continuation
xref_call = defaultdict(set)   # target -> {from}
xref_jump = defaultdict(set)
xref_data = defaultdict(set)   # data addr -> {from insn}
sub_starts = set()
loc_starts = set()
bad_stops = {}

STOP = {"rts", "rte", "rtr", "rtd", "jmp", "bra", "illegal", "stop", "reset"}
CALLS = {"bsr", "jsr"}
BR = re.compile(r"^(b[a-z]{2}|bra|bsr|dbra|db[a-z]{2}|jmp|jsr)(\.[bwl])?$")

def targets_of(ins):
    """absolute targets ($hex) named in a branch/jump operand"""
    if not BR.match(ins.mnemonic): return []
    out = []
    for m in re.finditer(r"\$([0-9a-f]+)", ins.op_str):
        v = int(m.group(1), 16)
        if BASE <= v < END: out.append(v)
    return out

class Ins:
    def __init__(self, address, size, mnemonic, op_str):
        self.address, self.size, self.mnemonic, self.op_str = address, size, mnemonic, op_str
        self.bytes = rom[address - BASE:address - BASE + size]

def ea_len(mode, reg, off):
    """extension-word bytes of an effective address (for the fallback decoder)"""
    if mode in (2, 3, 4): return 0
    if mode == 5: return 2
    if mode == 6:
        ext = struct.unpack(">H", rom[off:off + 2])[0]
        if not (ext & 0x100): return 2
        bd = (ext >> 4) & 3; od = ext & 3
        return 2 + {0: 0, 1: 0, 2: 2, 3: 4}[bd] + {0: 0, 1: 0, 2: 2, 3: 4}[od]
    if mode == 7: return {0: 2, 1: 4, 2: 2, 3: 2, 4: 4}.get(reg, 0)
    return 0

def ea_str(mode, reg, off):
    if mode == 2: return "(a%d)" % reg
    if mode == 3: return "(a%d)+" % reg
    if mode == 4: return "-(a%d)" % reg
    if mode == 5: return "$%x(a%d)" % (struct.unpack(">h", rom[off:off + 2])[0], reg)
    if mode == 6: return "(idx,a%d)" % reg
    if mode == 7 and reg == 1: return "$%08x.l" % rd32(off)
    if mode == 7 and reg == 0: return "$%x.w" % struct.unpack(">h", rom[off:off + 2])[0]
    return "ea(%d,%d)" % (mode, reg)

def decode040(addr):
    """68040 instructions Capstone 5 does not decode: PFLUSH*, PTEST, MOVE16,
    FSAVE/FRESTORE, CINV/CPUSH.  Returns an Ins or None."""
    off = addr - BASE
    w = struct.unpack(">H", rom[off:off + 2])[0]
    reg = w & 7
    if w & 0xFFE0 == 0xF500:                       # pflush
        return Ins(addr, 2, ("pflushn", "pflush", "pflushan", "pflusha")[(w >> 3) & 3], "" if w & 0x10 else "(a%d)" % reg)
    if w & 0xFFD8 == 0xF548:                       # ptest
        return Ins(addr, 2, "ptestr" if w & 0x20 else "ptestw", "(a%d)" % reg)
    if w & 0xFF80 == 0xF400 and (w >> 3) & 7 != 0: # cinv/cpush (capstone gets most, keep for safety)
        cache = ("nc", "dc", "ic", "bc")[(w >> 6) & 3]
        scope = (w >> 3) & 3
        op = "cpush" if w & 0x20 else "cinv"
        return Ins(addr, 2, op + ("", "l", "p", "a")[scope], cache if scope == 3 else "%s, (a%d)" % (cache, reg))
    if w & 0xFFC0 == 0xF300 or w & 0xFFC0 == 0xF340:   # fsave / frestore
        mode = (w >> 3) & 7
        return Ins(addr, 2 + ea_len(mode, reg, off + 2), "frestore" if w & 0x40 else "fsave", ea_str(mode, reg, off + 2))
    if w & 0xFFE0 == 0xF620:                       # move16 (ax)+,(ay)+
        w2 = struct.unpack(">H", rom[off + 2:off + 4])[0]
        return Ins(addr, 4, "move16", "(a%d)+, (a%d)+" % (reg, (w2 >> 12) & 7))
    if w & 0xFFE0 == 0xF600:                       # move16 with absolute long
        form = (w >> 3) & 3
        absl = "$%08x.l" % rd32(off + 2)
        ops = ("(a%d)+, %s" % (reg, absl), "%s, (a%d)+" % (absl, reg), "(a%d), %s" % (reg, absl), "%s, (a%d)" % (absl, reg))[form]
        return Ins(addr, 6, "move16", ops)
    return None

def dis1(addr):
    off = addr - BASE
    for ins in md.disasm(rom[off:off + 12], addr, count=1):
        if ins.mnemonic != ".byte":
            return Ins(addr, ins.size, ins.mnemonic, ins.op_str)
        break
    return decode040(addr)

def descend(seed, kind):
    work = [seed]
    while work:
        a = work.pop()
        while True:
            if a < BASE or a >= END or (a & 1): break
            off = a - BASE
            if code[off] or is_str[off]: break
            ins = dis1(a)
            if ins is None:
                bad_stops[a] = kind; break
            n = ins.size
            if off + n > SIZE: break
            if any(is_str[off:off + n]) or any(code[off + 1:off + n]): break
            insns[a] = (n, ins.mnemonic, ins.op_str, rom[off:off + n])
            code[off] = 1
            for k in range(off + 1, off + n): code[k] = 2
            mn = ins.mnemonic.split(".")[0]
            for t in targets_of(ins):
                if mn in CALLS:
                    xref_call[t].add(a); sub_starts.add(t)
                else:
                    xref_jump[t].add(a); loc_starts.add(t)
                work.append(t)
            if not BR.match(ins.mnemonic):
                for m in re.finditer(r"\$([0-9a-f]+)", ins.op_str):
                    v = int(m.group(1), 16)
                    if BASE <= v < END: xref_data[v].add(a)
            if mn in STOP: break
            a += n

sub_starts.add(rd32(4))
descend(rd32(4), "reset")
def looks_text(off):
    return all(printable(c) or c == 0 for c in rom[off:off + 12]) and sum(1 for c in rom[off:off + 12] if printable(c)) >= 8
for t in sorted(ptr_targets):
    off = t - BASE
    if code[off] or looks_text(off) or off < 0x1e: continue   # header longs are not code
    ins = dis1(t)
    if ins is None: continue
    sub_starts.add(t)
    descend(t, "ptr")
for a in KNOWN:
    if not code[a - BASE] and not is_str[a - BASE]:
        descend(a, "known")

# ---------------------------------------------------------------- strings
def printable(c): return 0x20 <= c < 0x7f or c in (0x0a, 0x0d, 0x09)
i = 0
while i < SIZE:
    j = i
    while j < SIZE and printable(rom[j]) and not code[j]: j += 1
    if j - i >= 4 and j < SIZE and rom[j] == 0 and not code[i]:
        txt = rom[i:j]
        ok = re.search(rb"[A-Za-z]{2}", txt) is not None
        # a 4-5 char run of mixed-case letters with no space/digit is almost
        # always opcodes ("NqNV" = nop; link a6), not text
        if ok and len(txt) < 6 and not re.search(rb"[ 0-9_.:/%-]", txt) and re.search(rb"[A-Z]", txt) and re.search(rb"[a-z]", txt):
            ok = False
        if ok:
            strings[i] = txt
            for k in range(i, j + 1): is_str[k] = 1
            i = j + 1; continue
    i += 1


# ---------------------------------------------------------------- labels
labels = {}
for a in KNOWN: labels[a] = KNOWN[a][0]
for a in sub_starts:
    if a not in labels and code[a - BASE] == 1: labels[a] = "sub_%08x" % a
for a in loc_starts:
    if a not in labels and code[a - BASE] == 1: labels[a] = "loc_%08x" % a
for off in strings:
    labels.setdefault(BASE + off, "str_%08x" % (BASE + off))
for t in ptr_targets:
    off = t - BASE
    if t not in labels:
        labels[t] = ("sub_%08x" if code[off] == 1 else "dat_%08x") % t
for t in xref_data:
    labels.setdefault(t, "dat_%08x" % t)

def sym(v):
    return labels.get(v)

def annotate_ops(op_str):
    """replace absolute ROM addresses with labels, annotate I/O addresses"""
    notes = []
    def rep(m):
        v = int(m.group(1), 16)
        s = sym(v)
        if s: return s
        n = io_annot(v)
        if n: notes.append("$%08x = %s" % (v, n))
        return m.group(0)
    s = re.sub(r"\$([0-9a-f]{6,8})\b", rep, op_str)
    return s, notes

# ---------------------------------------------------------------- listing
def esc(txt):
    parts, cur = [], ""
    for c in txt:
        if 0x20 <= c < 0x7f and c not in (0x22, 0x5c):
            cur += chr(c)
        else:
            if cur: parts.append('"%s"' % cur); cur = ""
            parts.append("$%02x" % c)
    if cur: parts.append('"%s"' % cur)
    return ",".join(parts)

def show(s):
    return s.decode("latin-1").replace("\n", "\\n").replace("\r", "\\r")

lines = []
def emit(s=""): lines.append(s)

emit("; NeXTcube 68040 boot ROM Rev 2.5 v66 (reference/previous/src/Rev_2.5_v66.BIN)")
emit("; %d bytes at $%08X (also aliased at $00000000 for the reset vectors)" % (SIZE, BASE))
emit("; generated by rom-disassembly/disasm_rom.py -- see README.md for conventions")
emit(";")
emit("; columns: address  bytes  mnemonic operands  ; notes / xrefs")
emit("")
emit("; reset vectors (ROM offset 0)")
emit("%08x  %s  dc.l $%08x  ; initial SSP" % (BASE, rom[0:4].hex(), rd32(0)))
emit("%08x  %s  dc.l $%08x  ; initial PC -> %s" % (BASE + 4, rom[4:8].hex(), rd32(4), sym(rd32(4)) or ""))
emit("")

data_run = []
def flush_data():
    global data_run
    if not data_run: return
    k = 0
    while k < len(data_run):
        a = BASE + data_run[k]
        if k + 3 < len(data_run) and data_run[k + 3] == data_run[k] + 3 and (a & 1) == 0 and rom_ptr(rd32(data_run[k])):
            v = rd32(data_run[k])
            emit("%08x  %s  dc.l %s" % (a, rom[data_run[k]:data_run[k] + 4].hex(), sym(v) or "$%08x" % v))
            k += 4; continue
        row = data_run[k:k + 16]
        n = 1
        while n < len(row):
            if (BASE + row[n]) in labels: break
            if n + 3 < len(row) and ((BASE + row[n]) & 1) == 0 and rom_ptr(rd32(row[n])): break
            n += 1
        row = row[:n]
        bs = rom[row[0]:row[0] + len(row)]
        words = " ".join("$%04x" % struct.unpack(">H", bs[i:i + 2])[0] for i in range(0, len(bs) - 1, 2))
        tail = ("" if len(bs) % 2 == 0 else " dc.b $%02x" % bs[-1])
        asc = "".join(chr(c) if 0x20 <= c < 0x7f else "." for c in bs)
        emit("%08x  %-32s  dc.w %s%s  ; |%s|" % (a, bs.hex(), words, tail, asc))
        k += len(row)
    data_run = []

off = 8
while off < SIZE:
    a = BASE + off
    lab = labels.get(a)
    if code[off] == 1:
        flush_data()
        n, mn, ops, bs = insns[a]
        if lab:
            emit("")
            callers = sorted(xref_call.get(a, ()))
            jumps = sorted(xref_jump.get(a, ()))
            ptrs = ptr_targets.get(a, ())
            note = KNOWN.get(a, (None, None))[1]
            if note: emit("; %s" % note)
            if callers: emit("; called from: " + ", ".join("%08x" % c for c in callers[:12]) + (" ..." if len(callers) > 12 else ""))
            if jumps: emit("; jumped to from: " + ", ".join("%08x" % c for c in jumps[:12]) + (" ..." if len(jumps) > 12 else ""))
            if ptrs: emit("; pointer table entries at: " + ", ".join("%08x" % p for p in ptrs[:8]) + (" ..." if len(ptrs) > 8 else ""))
            emit("%s:" % lab)
        ops2, notes = annotate_ops(ops)
        for m in re.finditer(r"str_([0-9a-f]{8})", ops2):
            s = strings.get(int(m.group(1), 16) - BASE)
            if s: notes.append('"%s"' % show(s)[:60])
        line = "%08x  %-16s  %-8s %s" % (a, bs.hex(), mn, ops2)
        if notes: line = "%-64s ; %s" % (line, "; ".join(notes))
        emit(line)
        off += n
    elif is_str[off] and off in strings:
        flush_data()
        s = strings[off]
        refs = sorted(xref_data.get(a, ()))
        emit("")
        if refs: emit("; referenced from: " + ", ".join("%08x" % r for r in refs[:10]) + (" ..." if len(refs) > 10 else ""))
        emit("%s:" % labels[a])
        emit("%08x  dc.b %s,0" % (a, esc(s)))
        off += len(s) + 1
    else:
        # long runs of zero (the unused tail of the ROM) collapse to one line
        if rom[off] == 0 and (a not in labels) and not code[off]:
            z = off
            while z < SIZE and rom[z] == 0 and not code[z] and (BASE + z) not in labels: z += 1
            if z - off >= 64:
                flush_data()
                emit("%08x  dcb.b    %d,0" % (a, z - off))
                off = z
                continue
        if lab and lab.startswith("dat_"):
            flush_data()
            refs = sorted(set(xref_data.get(a, ())) | set(ptr_targets.get(a, ())))
            emit("")
            if refs: emit("; referenced from: " + ", ".join("%08x" % r for r in refs[:10]))
            emit("%s:" % lab)
        data_run.append(off)
        if len(data_run) >= 16: flush_data()
        off += 1
flush_data()

open(os.path.join(OUT, "Rev_2.5_v66.asm"), "w", newline="\n").write("\n".join(lines) + "\n")

# ---------------------------------------------------------------- linear sweep of unreached gaps
lin = ["; Linear-sweep disassembly of the byte ranges NOT reached by the recursive",
       "; descent (and not strings).  Speculative: much of this is data.  Use it to",
       "; look up code the descent missed (computed jumps, tables the scan did not",
       "; recognise); if a routine here is real, add its entry to KNOWN in disasm_rom.py.", ""]
off = 8
while off < SIZE:
    if code[off] or is_str[off]: off += 1; continue
    start = off
    while off < SIZE and not code[off] and not is_str[off]: off += 1
    if off - start < 6: continue
    if not any(rom[start:off]):
        lin.append(""); lin.append("; ---- gap %08x..%08x (%d bytes) all zero ----" % (BASE + start, BASE + off - 1, off - start)); continue
    lin.append("")
    lin.append("; ---- gap %08x..%08x (%d bytes) ----" % (BASE + start, BASE + off - 1, off - start))
    p = start
    while p < off:
        ins = dis1(BASE + p)
        if ins is None or p + ins.size > off:
            lin.append("%08x  %-16s  dc.w     $%s" % (BASE + p, rom[p:p + 2].hex(), rom[p:p + 2].hex()))
            p += 2; continue
        ops2, notes = annotate_ops(ins.op_str)
        line = "%08x  %-16s  %-8s %s" % (ins.address, ins.bytes.hex(), ins.mnemonic, ops2)
        if notes: line = "%-64s ; %s" % (line, "; ".join(notes))
        lin.append(line)
        p += ins.size
open(os.path.join(OUT, "unreached-linear.asm"), "w", newline="\n").write("\n".join(lin) + "\n")

# ---------------------------------------------------------------- functions.md
subs = sorted({a for a in sub_starts if code[a - BASE] == 1} | {a for a in KNOWN if code[a - BASE] == 1})
def sub_end(a):
    off = a - BASE + insns[a][0]
    while off < SIZE and code[off] == 1 and (BASE + off) not in sub_starts and (BASE + off) not in KNOWN:
        off += insns[BASE + off][0]
    return BASE + off
fm = ["# Subroutines", "", "%d routines reached by the descent.  `callers` counts bsr/jsr sites; `ptr` = entries in ROM pointer tables." % len(subs), "",
      "| address | label | size | callers | ptr | strings referenced | note |", "|---|---|---:|---:|---:|---|---|"]
for a in subs:
    e = sub_end(a)
    strs = []
    off = a - BASE
    while BASE + off < e:
        n, mn, ops, _ = insns[BASE + off]
        for m in re.finditer(r"\$([0-9a-f]{8})", ops):
            v = int(m.group(1), 16) - BASE
            if v in strings: strs.append(show(strings[v]).strip()[:32])
        off += n
    note = KNOWN.get(a, ("", ""))[1]
    fm.append("| %08x | %s | %d | %d | %d | %s | %s |" % (a, labels.get(a, ""), e - a, len(xref_call.get(a, ())), len(ptr_targets.get(a, ())),
              "; ".join('"%s"' % s.replace("|", "\\|") for s in strs[:3]), note.replace("|", "\\|")))
open(os.path.join(OUT, "functions.md"), "w", newline="\n").write("\n".join(fm) + "\n")

# ---------------------------------------------------------------- strings.md
sm = ["# Strings", "", "%d NUL-terminated strings.  `refs` = code that names the address (absolute operands only; PC-relative and table references are not counted)." % len(strings), "",
      "| address | refs | text |", "|---|---|---|"]
for off in sorted(strings):
    a = BASE + off
    refs = sorted(xref_data.get(a, ()))
    sm.append("| %08x | %s | `%s` |" % (a, " ".join("%08x" % r for r in refs[:4]), show(strings[off]).replace("|", "\\|").replace("`", "'")))
open(os.path.join(OUT, "strings.md"), "w", newline="\n").write("\n".join(sm) + "\n")

# ---------------------------------------------------------------- hardware-refs.md
hw = defaultdict(list)
for a, (n, mn, ops, bs) in insns.items():
    for m in re.finditer(r"\$([0-9a-f]{7,8})\b", ops):
        v = int(m.group(1), 16)
        nm = io_annot(v)
        if nm: hw[v].append((a, mn, ops))
hm = ["# NeXT hardware registers referenced by the ROM", "",
      "Absolute device addresses appearing in ROM instructions, named from Previous's `ioMemTabNEXT.c` (non-Turbo table).",
      "Only absolute operands are listed; register accesses through an address register (the common C idiom) are not.", "",
      "| address | device / register | uses | instructions |", "|---|---|---:|---|"]
for v in sorted(hw):
    uses = sorted(hw[v])
    hm.append("| %08x | %s | %d | %s |" % (v, io_annot(v), len(uses), "<br>".join("%08x %s %s" % (a, mn, o) for a, mn, o in uses[:6]) + (" ..." if len(uses) > 6 else "")))
open(os.path.join(OUT, "hardware-refs.md"), "w", newline="\n").write("\n".join(hm) + "\n")

# ---------------------------------------------------------------- summary
ncode = sum(1 for c in code if c)
nstr = int(sum(is_str))
print("code bytes %d (%.1f%%), string bytes %d, other %d, insns %d, subs %d, strings %d, bad stops %d" %
      (ncode, 100.0 * ncode / SIZE, nstr, SIZE - ncode - nstr, len(insns), len(subs), len(strings), len(bad_stops)))
