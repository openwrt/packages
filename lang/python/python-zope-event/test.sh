#!/bin/sh

[ "$1" = python3-zope-event ] || exit 0

python3 - << 'PYEOF'
# Verify core API: subscribers list and notify function
import zope.event
assert hasattr(zope.event, 'subscribers'), "missing subscribers list"
assert callable(zope.event.notify), "missing notify()"

# Exercise notify: register a subscriber and fire an event
received = []
zope.event.subscribers.append(received.append)
zope.event.notify("test-event")
assert received == ["test-event"], f"event not received: {received!r}"

print("python3-zope-event OK")
PYEOF
