#!/bin/sh

[ "$1" = python3-blinker ] || exit 0

python3 - <<EOF
import sys
from blinker import Signal, signal

# Named signal
data_saved = signal("data-saved")
results = []
cb_named = lambda sender, **kw: results.append((sender, kw))
data_saved.connect(cb_named)
data_saved.send("db", value=42)
assert results == [("db", {"value": 42})], f"Unexpected: {results}"

# Anonymous signal, multiple subscribers
updated = Signal()
log = []
cb_a = lambda s, **kw: log.append("a")
cb_b = lambda s, **kw: log.append("b")
updated.connect(cb_a)
updated.connect(cb_b)
updated.send(None)
assert set(log) == {"a", "b"}, f"Unexpected: {log}"

# Disconnect
def handler(sender, **kw):
    log.append("handler")

updated.connect(handler)
updated.disconnect(handler)
updated.send(None)
assert "handler" not in log[2:], "handler should have been disconnected"

print("python-blinker OK")
EOF
