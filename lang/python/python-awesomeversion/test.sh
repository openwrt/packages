#!/bin/sh

[ "$1" = python3-awesomeversion ] || exit 0

python3 - << 'EOF'
from awesomeversion import AwesomeVersion, AwesomeVersionStrategy

v = AwesomeVersion("1.2.3")
assert v.major == 1
assert v.minor == 2
assert v.patch == 3

v2 = AwesomeVersion("2.0.0")
assert v2 > v

sem = AwesomeVersion("1.0.0")
assert sem.strategy == AwesomeVersionStrategy.SEMVER

print("python3-awesomeversion OK")
EOF