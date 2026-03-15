#!/bin/sh

[ "$1" = python3-eventlet ] || exit 0

python3 - << 'EOF'
import eventlet

# Test basic green thread spawning
results = []

def worker(n):
    results.append(n)

pool = eventlet.GreenPool(size=4)
for i in range(4):
    pool.spawn(worker, i)
pool.waitall()

assert sorted(results) == [0, 1, 2, 3], f"Unexpected results: {results}"
EOF
