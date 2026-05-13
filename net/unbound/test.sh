#!/bin/sh

case "$1" in
unbound-daemon)
	[ -f /etc/unbound/unbound.conf ] || { echo "FAIL: /etc/unbound/unbound.conf not installed"; exit 1; }
	;;

libunbound)
	ls /usr/lib/libunbound.so.* > /dev/null
	;;

unbound-anchor)
	[ -x /usr/sbin/unbound-anchor ] || { echo "FAIL: unbound-anchor not executable"; exit 1; }
	unbound-anchor -h 2>&1 | grep -qi "unbound\|anchor\|usage\|option"
	;;

unbound-checkconf)
	[ -x /usr/sbin/unbound-checkconf ] || { echo "FAIL: unbound-checkconf not executable"; exit 1; }
	unbound-checkconf -h 2>&1 | grep -qi "unbound\|usage\|option\|config"
	;;

unbound-control)
	[ -x /usr/sbin/unbound-control ] || { echo "FAIL: unbound-control not executable"; exit 1; }
	unbound-control -h 2>&1 | grep -qi "unbound\|usage\|option"
	;;

unbound-control-setup)
	# Shell script — no version string; just verify it is installed
	[ -x /usr/sbin/unbound-control-setup ] || {
		echo "FAIL: unbound-control-setup not executable"
		exit 1
	}
	grep -q "openssl\|unbound" /usr/sbin/unbound-control-setup
	;;

unbound-host)
	[ -x /usr/sbin/unbound-host ] || { echo "FAIL: unbound-host not executable"; exit 1; }
	unbound-host -h 2>&1 | grep -qi "unbound\|usage\|option"
	;;
esac
