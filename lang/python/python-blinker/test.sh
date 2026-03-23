#!/bin/sh

[ "$1" = python3-blinker ] || exit 0

python3 - <<EOF
import sys
from blinker import Signal, signal

# Named signal
data_saved = signal("data-saved")
results = []
data_saved.connect(lambda sender, **kw: results.append((sender, kw)))
data_saved.send("db", value=42)
assert results == [("db", {"value": 42})], f"Unexpected: {results}"

# Anonymous signal, multiple subscribers
updated = Signal()
log = []
updated.connect(lambda s, **kw: log.append("a"))
updated.connect(lambda s, **kw: log.append("b"))
updated.send(None)
assert log == ["a", "b"], f"Unexpected: {log}"

# Disconnect
def handler(sender, **kw):
    log.append("handler")

updated.connect(handler)
updated.disconnect(handler)
updated.send(None)
assert "handler" not in log[2:], "handler should have been disconnected"

print("python-blinker OK")
EOF
