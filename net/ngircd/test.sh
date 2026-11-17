#!/bin/sh

case "$1" in
ngircd|ngircd-nossl)
	BIN=/usr/sbin/ngircd
	# The daemon, its init script and the default config must be installed.
	[ -x "$BIN" ] || { echo "FAIL: $BIN not installed"; exit 1; }
	[ -x /etc/init.d/ngircd ] || { echo "FAIL: init script missing"; exit 1; }
	[ -f /etc/ngircd.conf ] || { echo "FAIL: /etc/ngircd.conf missing"; exit 1; }

	# The shipped default config must pass ngircd's own validator (exit 0).
	"$BIN" --configtest >/tmp/ngircd-ct.log 2>&1 || {
		echo "FAIL: configtest rejected the default config"; cat /tmp/ngircd-ct.log; exit 1; }
	grep -qi ngircd /tmp/ngircd-ct.log || { echo "FAIL: unexpected configtest output"; exit 1; }

	# configtest must actually read the file it is given: pointing it at a
	# missing config has to fail, proving the positive check above is real.
	if "$BIN" --configtest --config /tmp/ngircd-absent.conf >/dev/null 2>&1; then
		echo "FAIL: configtest accepted a missing config file"; exit 1
	fi

	echo "ngircd: config validation OK"
	;;
*)
	exit 0
	;;
esac
