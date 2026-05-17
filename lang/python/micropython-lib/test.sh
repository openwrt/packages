#!/bin/sh

case "$1" in
micropython-lib)
	micropython -c "
import sys
sys.path.append('/usr/lib/micropython')
import collections
import functools
import base64
print('micropython-lib modules OK')
"
	;;
micropython-lib-unix)
	[ -x /usr/bin/micropython-unix ]
	micropython-unix -c "
import sys
import sqlite3
import select
print('micropython-lib-unix modules OK')
"
	;;
*)
	exit 0
	;;
esac
