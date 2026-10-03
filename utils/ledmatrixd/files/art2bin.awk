# SPDX-License-Identifier: GPL-2.0-or-later
# Convert a 24x67 ASCII-art bitmap ('#' = on, '.' = off) into the 201-byte
# row-major MSB-first framebuffer format used by ledmatrixd and the LuCI app.
# Usage: awk -f art2bin.awk layout.txt > layout.bin

BEGIN { rows = 0; failed = 0 }

function fail(msg) { print "art2bin: " msg > "/dev/stderr"; failed = 1; exit 1 }

{
	if (rows >= 67) fail("more than 67 rows")
	if (length($0) != 24) fail("row " NR " is not 24 chars wide")
	byte = 0
	for (x = 0; x < 24; x++) {
		c = substr($0, x + 1, 1)
		if (c == "#") byte += 2 ^ (7 - x % 8)
		else if (c != ".") fail("row " NR ": unexpected character '" c "'")
		if (x % 8 == 7) { printf "%c", byte; byte = 0 }
	}
	rows++
}

END { if (!failed && rows != 67) fail("expected 67 rows, got " rows) }
