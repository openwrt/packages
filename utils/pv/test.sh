#!/bin/sh
# pv must copy a stream through the pipe unchanged.

[ -x /usr/bin/pv ] || { echo "FAIL: /usr/bin/pv not installed"; exit 1; }

# text stream
payload="pv basic functionality test 0123456789"
out="$(printf '%s' "$payload" | pv -q)"
[ "$out" = "$payload" ] || { echo "FAIL: pv altered a text stream"; exit 1; }

# 256 KiB binary stream: checksum must survive the pipe
tmp="$(mktemp)"
head -c 262144 /dev/urandom > "$tmp"
in_sum="$(md5sum < "$tmp" | cut -d' ' -f1)"
out_sum="$(pv -q < "$tmp" | md5sum | cut -d' ' -f1)"
rm -f "$tmp"
[ "$in_sum" = "$out_sum" ] || { echo "FAIL: pv corrupted a 256 KiB stream"; exit 1; }

echo "pv: stream pass-through OK"
