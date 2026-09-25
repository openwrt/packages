#!/bin/sh

[ "$1" = python3-urllib3 ] || exit 0

python3 - << 'EOF'
import urllib3

# Verify version
assert urllib3.__version__

# Verify core classes are importable
from urllib3 import HTTPConnectionPool, HTTPSConnectionPool, PoolManager
from urllib3.util.retry import Retry
from urllib3.util.timeout import Timeout
from urllib3.exceptions import (
    MaxRetryError, TimeoutError, HTTPError,
    NewConnectionError, DecodeError
)

# Test Retry configuration
retry = Retry(total=3, backoff_factor=0.5)
assert retry.total == 3

# Test Timeout configuration
timeout = Timeout(connect=5.0, read=10.0)
assert timeout.connect_timeout == 5.0

# Test PoolManager creation
pm = PoolManager(num_pools=5, maxsize=10)
assert pm is not None

print("urllib3 OK")
EOF
