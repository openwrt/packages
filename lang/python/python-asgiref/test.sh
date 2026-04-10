#!/bin/sh
[ "$1" = python3-asgiref ] || exit 0
python3 - << 'EOF'
import asgiref
assert asgiref.__version__, "asgiref version is empty"

from asgiref.sync import async_to_sync, sync_to_async
import asyncio

async def async_add(a, b):
    return a + b

result = async_to_sync(async_add)(3, 4)
assert result == 7, f"async_to_sync failed: {result}"

def sync_mul(a, b):
    return a * b

async def run():
    result = await sync_to_async(sync_mul)(6, 7)
    assert result == 42, f"sync_to_async failed: {result}"

asyncio.run(run())
EOF
