#!/bin/sh
# Runtime test for the packages CI. There's no gateway here, so this checks
# the parts that run on the router alone, under its busybox and jq: the
# version, an unreachable gateway, and reading back a day of history.

set -e

tmhi version | grep -F "tmhi $PKG_VERSION"

T=/tmp/tmhi-test
rm -rf "$T"
mkdir -p "$T"

# Nothing listens on port 1, so every request fails straight away.
uci set tmhi.main.host=127.0.0.1
uci set tmhi.main.port=1
uci set tmhi.main.timeout=2
uci set tmhi.main.history_dir="$T"
uci commit tmhi

# health: exit 1 means the gateway didn't answer.
rc=0
tmhi health >"$T/out" 2>&1 || rc=$?
cat "$T/out"
[ "$rc" = 1 ] || {
	echo "health exited with $rc, expected 1"
	exit 1
}

# Two hours of samples ending now, an hour on n41 and an hour on n25, in the
# daemon's format (the column list comes from the installed script).
now=$(date +%s)
awk -v now="$now" -v cols="$(sed -n "s/^COLS='\(.*\)'$/\1/p" /usr/bin/tmhi)" '
BEGIN {
	nc = split(cols, C, " ")
	for (i = 1; i <= nc; i++) printf "%s%s", C[i], (i < nc ? "\t" : "\n")
	for (m = 120; m >= 1; m--) {
		for (i = 1; i <= nc; i++) V[C[i]] = "-"
		V["ts"] = now - m * 60
		V["reg"] = "registered"
		V["nr_bands"] = (m > 60) ? "n41" : "n25"
		V["nr_bw"] = (m > 60) ? 100 : 20
		V["nr_rsrp"] = -95
		V["nr_sinr"] = 12
		for (i = 1; i <= nc; i++) printf "%s%s", V[C[i]], (i < nc ? "\t" : "\n")
	}
}' >"$T/history-$(date +%Y-%m-%d).tsv"

tmhi history -s 3h | tee "$T/out"
grep n41 "$T/out"
grep n25 "$T/out"

tmhi history --json -s 3h >"$T/out.json"
jq -c '{samples, bands: [.bands[] | {key, good, samples}]}' "$T/out.json"
jq -e '.samples == 120 and ([.bands[] | select(.good) | .key] == ["n41 100 MHz"])' "$T/out.json"

rm -rf "$T"
