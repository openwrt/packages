#!/bin/sh
[ "$1" = python3-async-timeout ] || exit 0

python3 - << 'EOF'
import asyncio
import async_timeout

async def test_no_timeout():
    async with async_timeout.timeout(10):
        await asyncio.sleep(0)
    print("no_timeout OK")

async def test_timeout_fires():
    try:
        async with async_timeout.timeout(0.01):
            await asyncio.sleep(1)
        assert False, "Should have timed out"
    except asyncio.TimeoutError:
        print("timeout_fires OK")

async def test_timeout_none():
    async with async_timeout.timeout(None):
        await asyncio.sleep(0)
    print("timeout_none OK")

async def main():
    await test_no_timeout()
    await test_timeout_fires()
    await test_timeout_none()

asyncio.run(main())
EOF
