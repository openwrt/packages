#!/bin/sh

[ "$1" = python3-msgpack ] || exit 0

python3 - << 'EOF'

import msgpack

# Pack a mixed-type structure and unpack it back, then confirm the compiled C
# extension is actually in use rather than the pure-Python fallback (which the
# package silently drops to when the Cython build produced nothing).
obj = {"a": [1, 2, 3], "b": "text", "c": 3.5, "d": True, "e": None}
packed = msgpack.packb(obj)
assert isinstance(packed, (bytes, bytearray))
assert msgpack.unpackb(packed, raw=False) == obj
assert msgpack.Packer.__module__ == "msgpack._cmsgpack", msgpack.Packer.__module__

EOF
