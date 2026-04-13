#!/bin/sh

[ "$1" = python3-pycrate ] || exit 0

python3 - << 'EOF'
from pycrate_core.elt import Envelope, Sequence
from pycrate_core.base import Uint8, Uint16

class Msg(Envelope):
    _GEN = (
        Uint8("Type"),
        Uint16("Length"),
    )

m = Msg()
m["Type"].set_val(1)
m["Length"].set_val(42)
assert m["Type"].get_val() == 1
assert m["Length"].get_val() == 42

print("python3-pycrate OK")
EOF