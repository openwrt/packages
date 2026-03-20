#!/bin/sh

[ "$1" = python3-greenlet ] || exit 0

python3 - <<'EOF'
import greenlet

results = []

def consumer():
    while True:
        value = greenlet.getcurrent().parent.switch()
        if value is None:
            break
        results.append(value * 2)

c = greenlet.greenlet(consumer)
c.switch()  # start consumer, runs until first switch back

for i in [1, 2, 3]:
    c.switch(i)
c.switch(None)  # signal done

assert results == [2, 4, 6], f"Expected [2, 4, 6], got {results}"
EOF
