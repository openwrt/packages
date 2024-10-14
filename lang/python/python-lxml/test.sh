#!/bin/sh

[ "$1" = "python3-lxml" ] || exit 0

EXP_VER="$2"

python3 - << EOF
import lxml
import sys

if (lxml.__version__) != "$EXP_VER":
    print("Wrong version: " + lxml.__version__)
    sys.exit(1)

from lxml import etree

root = etree.Element("root")
root.append(etree.Element("child1"))
root.append(etree.Element("child2"))
root.append(etree.Element("child3"))

exp_str = "b'<root><child1/><child2/><child3/></root>'"
got_str = str(etree.tostring(root))
if (got_str != exp_str):
    print("Expected: '" + exp_str + "' . Got: '" + got_str + "'")
else:
    print("OK")

sys.exit(0)
EOF

