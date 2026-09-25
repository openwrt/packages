#!/bin/sh
# less is a pager; with a non-tty output and one-screen content (-F quits
# at once) it dumps the input verbatim, which we can check without a
# terminal. Payloads stay small so less never blocks waiting to page.

LESS_BIN=/usr/libexec/less-gnu
[ -x "$LESS_BIN" ] || { echo "FAIL: $LESS_BIN not installed"; exit 1; }

payload="$(printf 'alpha\nbeta\ngamma\ndelta')"

# from stdin
out="$(printf '%s\n' "$payload" | "$LESS_BIN" -F)"
[ "$out" = "$payload" ] || { echo "FAIL: less mangled stdin"; exit 1; }

# from a file argument
tmp="$(mktemp)"; printf '%s\n' "$payload" > "$tmp"
out="$("$LESS_BIN" -F "$tmp")"; rm -f "$tmp"
[ "$out" = "$payload" ] || { echo "FAIL: less mangled a file argument"; exit 1; }

echo "less: pass-through OK"
