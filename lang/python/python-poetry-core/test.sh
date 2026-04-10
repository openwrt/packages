#!/bin/sh
[ "$1" = python3-poetry-core ] || exit 0
python3 - << 'EOF'
import poetry.core
assert poetry.core.__version__, "poetry.core version is empty"

from poetry.core.version.version import Version
v = Version.parse("1.2.3")
assert str(v) == "1.2.3", f"unexpected version string: {v}"
assert v.major == 1
assert v.minor == 2
assert v.patch == 3

v2 = Version.parse("2.0.0")
assert v2 > v, "version comparison failed"

from poetry.core.constraints.version import parse_constraint
c = parse_constraint(">=1.0.0,<2.0.0")
assert c.allows(Version.parse("1.5.0")), "constraint should allow 1.5.0"
assert not c.allows(Version.parse("2.0.0")), "constraint should not allow 2.0.0"
EOF
