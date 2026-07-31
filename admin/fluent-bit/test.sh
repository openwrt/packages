#!/bin/sh
# Regression test for issue #30113: with too small a coroutine stack the HTTP
# output plugin overflows and dies (SIGSEGV/abort) on its first flush. Drive the
# dummy input into the http output and make sure fluent-bit survives a few flush
# cycles. No server is needed -- the crash happens while composing/sending the
# request, so a refused local port is enough to exercise it.

case "$1" in
fluent-bit) ;;
*) exit 0 ;;
esac

BIN=/usr/sbin/fluent-bit
[ -x "$BIN" ] || { echo "FAIL: $BIN not installed"; exit 1; }

cfg=/tmp/fluent-bit-http.conf
cat > "$cfg" <<'EOF'
[SERVICE]
    flush     1
    daemon    off
    log_level error
[INPUT]
    name      dummy
    dummy     {"message":"regress-30113"}
    rate      100
[OUTPUT]
    name      http
    match     *
    host      127.0.0.1
    port      5170
    format    json
EOF

# A healthy run keeps retrying the refused endpoint until timeout stops it
# (rc 124); a coroutine-stack overflow dies from a signal (rc >= 128) within
# the first flush cycle.
timeout 6 "$BIN" -c "$cfg" >/tmp/fluent-bit-http.out 2>&1
rc=$?

if [ "$rc" -ge 128 ]; then
	echo "FAIL: fluent-bit http output died from a signal (rc=$rc) -- coro stack too small"
	grep -iE 'signal|SIGSEGV' /tmp/fluent-bit-http.out | head -1
	exit 1
fi

echo "fluent-bit: http output survived flush cycles (rc=$rc)"
