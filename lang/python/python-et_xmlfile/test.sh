#!/bin/sh

EXPECTED_VER="$2"

python3 - << EOF

import sys
from io import BytesIO
from xml.etree.ElementTree import Element

from et_xmlfile import xmlfile

if (et_xmlfile.__version__ != "$EXPECTED_VER"):
    print("Invalid version obtained '" + et_xmlfile.__version__ + "'")
    sys.exit(1)

out = BytesIO()
with xmlfile(out) as xf:
    el = Element("root")
    xf.write(el) # write the XML straight to the file-like object

if (out.getvalue() != b"<root />"):
    print("Does not seem to work")
    sys.exit(1)

sys.exit(0)

EOF

