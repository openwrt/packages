#!/bin/sh

[ "$1" = python3-trio ] || exit 0

python3 - << 'EOF'
import trio

results = []

async def worker(n):
    await trio.sleep(0)
    results.append(n)

async def main():
    async with trio.open_nursery() as nursery:
        for i in range(3):
            nursery.start_soon(worker, i)

trio.run(main)
assert sorted(results) == [0, 1, 2], f"Expected [0,1,2], got {results}"

print("python3-trio OK")
EOF