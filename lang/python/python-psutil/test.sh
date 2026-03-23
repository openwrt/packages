#!/bin/sh

[ "$1" = "python3-psutil" ] || exit 0

python3 - << EOF
import sys
import psutil

if psutil.__version__ != "$2":
    print("Wrong version: " + psutil.__version__)
    sys.exit(1)

# Test basic process info
p = psutil.Process()
assert p.pid > 0, "Expected valid PID"
assert p.status() in (psutil.STATUS_RUNNING, psutil.STATUS_SLEEPING), \
    f"Unexpected status: {p.status()}"

# Test system-wide functions
mem = psutil.virtual_memory()
assert mem.total > 0, "Expected non-zero total memory"
assert 0.0 <= mem.percent <= 100.0, f"Memory percent out of range: {mem.percent}"

cpu = psutil.cpu_count()
assert cpu is not None and cpu > 0, f"Expected positive CPU count, got {cpu}"

# Test disk usage
disk = psutil.disk_usage("/")
assert disk.total > 0, "Expected non-zero disk total"

sys.exit(0)
EOF
