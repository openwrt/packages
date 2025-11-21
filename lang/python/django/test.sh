#!/bin/sh

[ "python3-django" = "$1" ] || exit 0

GOT_VER=$(/usr/bin/django-admin version)
[ "$GOT_VER" = "$2" ] || {
	echo "Incorrect version: expected '$2' ; obtained '$GOT_VER'"
	exit 1
}

python3 - << EOF
import sys
import django

if (django.__version__) != "$GOT_VER":
    print("Wrong version: " + django.__version__)
    sys.exit(1)

sys.exit(0)
EOF

