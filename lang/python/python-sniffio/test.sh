#!/bin/sh

[ "$1" = "python3-sniffio" ] || exit 0

python3 - << EOF
import sys
import sniffio

if sniffio.__version__ != "$2":
    print("Wrong version: " + sniffio.__version__)
    sys.exit(1)

from sniffio import current_async_library
from sniffio import AsyncLibraryNotFoundError

# Outside async context should raise
try:
    current_async_library()
    sys.exit(1)
except AsyncLibraryNotFoundError:
    pass

sys.exit(0)
EOF
