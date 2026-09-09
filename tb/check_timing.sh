#!/bin/sh
# Release gate: fail if the last Quartus compile did not close timing.
#
# Quartus reports a timing violation as a Critical Warning, not an error,
# and still emits output_files/NeXT.rbf -- so a full compile can "succeed"
# while shipping a design that fails setup or hold at the slow corner.  A
# regressed CPU path (the exception-format tree at exc_fmt[0]) is exactly
# how a -5.345 ns setup violation slipped into an otherwise green build.
# This check parses the TimeQuest summary and refuses any negative slack.
#
#   ./check_timing.sh                 # checks output_files/NeXT.sta.summary
#   ./check_timing.sh path/to.summary # or an explicit summary file
set -eu

SUMMARY=${1:-$(dirname "$0")/../output_files/NeXT.sta.summary}

if [ ! -f "$SUMMARY" ]; then
	echo "*** timing summary not found: $SUMMARY"
	echo "    run a full Quartus compile first (quartus_sh --flow compile NeXT)"
	exit 1
fi

# The summary lists blocks of
#   Type  : Setup '<clock>'
#   Slack : <ns>
#   TNS   : <ns>
# for Setup, Hold, Recovery, Removal and minimum-pulse-width.  Any negative
# slack is a violation.  Print the offenders, and the worst slack per type.
awk '
	/^Type +:/     { type=$0; sub(/^Type +: /,"",type) }
	/^Slack +:/    {
		slack=$3+0
		# track worst per analysis type (the text before the quote)
		key=type; sub(/ .*/,"",key)
		if (!(key in worst) || slack < worst[key]) { worst[key]=slack; wctx[key]=type }
		if (slack < 0) { bad++; printf "  VIOLATED  %+8.3f ns  %s\n", slack, type }
	}
	END {
		print "--- worst slack per analysis type ---"
		for (k in worst) printf "  %-10s %+8.3f ns  %s\n", k, worst[k], wctx[k]
		if (bad) { print ""; printf "*** TIMING NOT CLOSED: %d violated path group(s)\n", bad; exit 1 }
		print ""; print "timing closed: all slacks non-negative"
	}
' "$SUMMARY"
