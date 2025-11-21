#!/bin/sh

[ "$1" = "python3-numpy" ] || exit 0

EXP_VER="$2"

python3 - << EOF
import sys
import numpy as np

if (np.__version__ != "$EXP_VER"):
    print("Got incorrect version: " + np.__version__)
    sys.exit(1)

arr = np.array([1, 2, 3, 4, 5])

print(arr)

EOF

