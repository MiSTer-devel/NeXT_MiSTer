#!/bin/bash
# the Falcon DSP differential testbench (tb/dsp of Falcon_MiSTer) run against
# the NeXT tree's vendored, modified copy of the block (Falcon memory map,
# boot_mode 1): the modifications must leave the Falcon behaviour intact
set -e
HERE=/home/adam/Falcon_MiSTer/tb/dsp
ROOT=/home/adam/Falcon_MiSTer
RTL=/home/adam/NeXT_MiSTer/rtl/dsp56k
HATARI=/home/adam/hatari
BUILD=/home/adam/NeXT_MiSTer/tb/build/dsp_harness
mkdir -p "$BUILD"
python3 "$HERE/gen/gen_tables.py" "$HATARI/src/falcon" "$RTL" "$HERE/gen/opcodes8h.inc" > /dev/null
GINC="-I$HATARI/build -I$HATARI/src/includes -I$HATARI/src/debug -I$HATARI/src/falcon -I$HATARI/src -I$HATARI/src/cpu"
for f in dsp_cpu dsp_core; do gcc -O2 -w -c $GINC "$HATARI/src/falcon/$f.c" -o "$BUILD/golden_$f.o"; done
gcc -O2 -c "$HERE/golden/golden_stubs.c" -o "$BUILD/golden_stubs.o"
ar rcs "$BUILD/libgolden.a" "$BUILD/golden_dsp_cpu.o" "$BUILD/golden_dsp_core.o" "$BUILD/golden_stubs.o"
DSP_RTL="$RTL/falcon_dsp.sv $RTL/dsp56k_core.sv $RTL/dsp56k_dec.sv $RTL/dsp56k_alu.sv $RTL/dsp_periph.sv $RTL/dsp_ram.sv $RTL/dsp56k_rom.sv"
verilator --cc --exe --build -j 8 -O3 --x-assign fast --x-initial fast \
    -Wall -Wno-fatal -Wno-DECLFILENAME -Wno-UNUSEDSIGNAL -Wno-UNUSEDPARAM -Wno-BLKSEQ \
    --Mdir "$BUILD/obj" -I"$RTL" -CFLAGS "-O2 -I$HERE $GINC" -LDFLAGS "$BUILD/libgolden.a" \
    --top-module falcon_dsp $DSP_RTL \
    "$HERE/tb_dsp.cpp" "$HERE/tb_common.cpp" "$HERE/tb_gen.cpp" "$HERE/tb_lockstep.cpp" \
    "$HERE/tb_tests.cpp" "$HERE/tb_directed.cpp" "$HERE/tb_host.cpp" "$HERE/tb_replay.cpp" -o tb_dsp \
    > "$BUILD/verilator.log" 2>&1 || { grep -v "^%Warning\|^ " "$BUILD/verilator.log" | tail -40; exit 1; }
"$BUILD/obj/tb_dsp" "$@"
