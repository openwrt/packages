#!/bin/sh

[ "$1" = python3-gevent ] || exit 0

python3 - << 'EOF'
import gevent
from gevent import sleep, spawn, joinall

results = []

def worker(n):
    sleep(0)
    results.append(n)

jobs = [spawn(worker, i) for i in range(3)]
joinall(jobs)

assert sorted(results) == [0, 1, 2], f"Expected [0,1,2], got {results}"

print("python3-gevent OK")
EOF