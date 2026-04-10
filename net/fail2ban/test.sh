#!/bin/sh

[ "$1" = fail2ban ] || exit 0

# Verify fail2ban-client binary is present and functional
fail2ban-client --version 2>&1 | grep -qi "fail2ban" || \
    { echo "fail2ban-client --version did not produce expected output"; exit 1; }

python3 - << 'EOF'
import fail2ban

from fail2ban.version import version
assert version, "fail2ban version is empty"

from fail2ban.helpers import formatExceptionInfo
from fail2ban.exceptions import UnknownJailException

# Verify core exception class is accessible
try:
    raise UnknownJailException("test")
except UnknownJailException:
    pass
EOF
