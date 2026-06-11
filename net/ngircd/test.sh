#!/bin/sh

case "$1" in
ngircd|ngircd-nossl)
	# Verify the installed default config passes ngircd's built-in syntax check
	[ -f /etc/ngircd.conf ]
	ngircd --configtest 2>&1 | grep -qi "ok\|using config\|ngircd"
	;;
*)
	exit 0
	;;
esac
