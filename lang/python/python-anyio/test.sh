#!/bin/sh

[ "$1" = python3-anyio ] || exit 0

# anyio has no module-level __version__; apk already verifies the package
# version, so this test exercises runtime behaviour instead.

python3 - << 'EOF'
from anyio import create_task_group, run, sleep

# Spawn N children in a task group and check they all complete via a shared
# sink — exercises the asyncio backend and structured-concurrency wait barrier.
results = []


async def child(num: int) -> None:
    await sleep(0)
    results.append(num)


async def main() -> None:
    async with create_task_group() as tg:
        for num in range(5):
            tg.start_soon(child, num)


run(main)

assert sorted(results) == [0, 1, 2, 3, 4], f"unexpected child completions: {results}"

print("python3-anyio OK")
EOF
