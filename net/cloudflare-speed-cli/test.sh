#!/bin/sh
set -e

# Everything here runs without network access, so it works the same in the
# build matrix as on a device.

export HOME=/tmp/cloudflare-speed-cli-test
rm -rf "$HOME"

cloudflare-speed-cli --help | grep -- '--json'

# Pointed at a port nothing listens on, every request fails and the run has
# to come back with a summary once the phase durations are up. This exercises
# the async runtime and the HTTP/UDP clients; a reactor that never delivers
# the connection errors would hang here until the timeout fires.
ARGS="--base-url http://127.0.0.1:1 --download-duration 1s --upload-duration 1s --idle-latency-duration 1s"

rc=0
timeout 60 cloudflare-speed-cli --text $ARGS > "$HOME.out" 2>&1 || rc=$?
if [ "$rc" != 0 ]; then
	echo "text run exited with $rc"
	cat "$HOME.out"
	exit 1
fi
grep '== Summary ==' "$HOME.out"

rc=0
timeout 60 cloudflare-speed-cli --json $ARGS > "$HOME.json" 2> "$HOME.out" || rc=$?
if [ "$rc" != 0 ]; then
	echo "json run exited with $rc"
	cat "$HOME.out"
	exit 1
fi
grep '"base_url": "http://127.0.0.1:1"' "$HOME.json"

# Both runs were auto-saved under $HOME; read them back as history.
cloudflare-speed-cli --export-all-csv "$HOME.csv" 2>&1 | grep 'Exported 2 run(s)'
grep '^timestamp_utc,base_url,' "$HOME.csv"

rm -rf "$HOME" "$HOME.out" "$HOME.json" "$HOME.csv"
