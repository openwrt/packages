#!/bin/sh

# shellcheck shell=busybox

# Start the player on the null output and check it comes up and listens,
# which the generic version check alone does not show.

[ "$1" = sendspin-cli ] || exit 0

state=$(mktemp -d)
pid=""
cleanup() { [ -n "$pid" ] && kill "$pid" 2>/dev/null; rm -rf "$state"; }
trap cleanup EXIT

sendspin-cli --output null --name ci --no-mdns --no-control --state-dir "$state" > "$state/log" 2>&1 &
pid=$!

tries=30
while [ "$tries" -gt 0 ] && ! grep -F "listening on port" "$state/log" > /dev/null; do
	sleep 1
	tries=$((tries - 1))
done

kill "$pid"
wait "$pid"
cat "$state/log"
grep -F "sendspin-cli $2 listening on port 8928" "$state/log"
