#!/bin/sh
# Stage the last Quartus build as a dated release, gated on timing closure.
#
# Quartus calls a compile "successful" even when it fails timing (a timing
# miss is a Critical Warning), and still writes output_files/NeXT.rbf.  The
# only thing that ever stood between a timing-failed bitstream and the
# releases/ directory was remembering to look at the TimeQuest summary, and
# a -5.345 ns setup violation on the CPU exception path slipped through
# exactly that way.  So this refuses to stage an RBF unless
# tb/check_timing.sh passes.
#
#   ./release.sh          -> releases/NeXT_YYYYMMDD.rbf (or the next free
#                            letter suffix for today: a, b, c, ...)
#   ./release.sh fpsp     -> releases/NeXT_YYYYMMDD_fpsp.rbf
set -eu
cd "$(dirname "$0")"

RBF=output_files/NeXT.rbf
SOF=output_files/NeXT.sof

[ -f "$RBF" ] || { echo "*** no $RBF: run quartus_sh --flow compile NeXT first"; exit 1; }

# The RBF must be judged by the timing summary of the SAME compile.  A full
# compile writes the RBF (assembler) and then the summary (STA), so the
# summary is normally a few seconds newer.  The danger is the reverse: an RBF
# newer than the summary was rebuilt after the last STA, so its timing is
# unverified.  Reject that; a summary newer than the RBF is expected.
if [ "$(stat -c %Y "$RBF")" -gt "$(stat -c %Y output_files/NeXT.sta.summary)" ]; then
	echo "*** $RBF is newer than the timing summary: its timing is unverified, re-run STA"
	exit 1
fi

echo "== timing gate =="
tb/check_timing.sh || { echo; echo "*** release REFUSED: timing not closed"; exit 1; }

day=$(date +%Y%m%d)
if [ $# -ge 1 ]; then
	out="releases/NeXT_${day}_$1.rbf"
else
	out="releases/NeXT_${day}.rbf"
	[ -e "$out" ] && for s in a b c d e f g h i j k l m n o p q r s t u v w x y z; do
		out="releases/NeXT_${day}${s}.rbf"; [ -e "$out" ] || break
	done
fi
[ -e "$out" ] && { echo "*** $out already exists"; exit 1; }

cp "$RBF" "$out"
echo
echo "staged $out  ($(stat -c %s "$out") bytes, from $(date -r "$SOF" '+%Y-%m-%d %H:%M'))"
