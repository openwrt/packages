#!/bin/sh
#
# Functional smoke test for knot-resolver (kresd).
#
# Boot kresd against a minimal Lua config that immediately calls quit().
# This exercises the kresd binary's startup path and embedded Lua engine
# — strictly more than --version, which the CI's generic version probe
# already covers.

[ "$1" = knot-resolver ] || exit 0

set -e

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# quit() returns control to kresd, which then shuts down cleanly.
echo 'quit()' > "$tmp/config"

# -n: no fork, -q: quiet. Trailing positional arg is the workdir
# (kresd uses it for cache.lmdb).
kresd -n -q -c "$tmp/config" "$tmp"
