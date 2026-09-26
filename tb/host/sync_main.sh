#!/bin/sh
# Copy the Main_MiSTer support/next sources the benches co-simulate into
# the build tree, next to the shim headers they include by relative path
# (../../file_io.h and friends resolve to tb/host/shim/*).
#
#   sh host/sync_main.sh <dest dir>          (from tb/)
#   MAIN_SRC=/path/to/Main_MiSTer overrides the fork's location
set -eu
cd "$(dirname "$0")/.."
DEST=${1:-build/host}
MAIN=${MAIN_SRC:-../../Main_MiSTer}
[ -d "$MAIN/support/next" ] || { echo "*** Main_MiSTer not found at $MAIN (set MAIN_SRC)"; exit 1; }
mkdir -p "$DEST/support/next" "$DEST/support/chd"
for f in next_scsi next_cdrom next_cdrom_resp next_cdrom_play next_mo next_rs; do
	cp "$MAIN/support/next/$f.h" "$MAIN/support/next/$f.cpp" "$DEST/support/next/"
done
cp host/shim/file_io.h host/shim/user_io.h host/shim/spi.h host/shim/hardware.h host/shim/cd.h "$DEST/"
cp host/shim/support/chd/mister_chd.h "$DEST/support/chd/"
git -C "$MAIN" rev-parse --short HEAD > "$DEST/MAIN_COMMIT" 2>/dev/null || echo unknown > "$DEST/MAIN_COMMIT"
# the Main tree is comment-free by the user's rule; keep it that way
if grep -l '//\|/\*' "$DEST"/support/next/*.cpp "$DEST"/support/next/*.h >/dev/null 2>&1; then
	echo "*** comment lines in Main support/next:"; grep -l '//\|/\*' "$DEST"/support/next/*; exit 1
fi
echo "Main support/next synced from $MAIN ($(cat "$DEST/MAIN_COMMIT"))"
