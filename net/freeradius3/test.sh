#!/bin/sh

FR_ETC="/etc/freeradius3"
FR_LIB="/usr/lib/freeradius3"
FR_SHARE="/usr/share/freeradius3"

case "$1" in
freeradius3)
	[ -x /usr/sbin/radiusd ] || { echo "FAIL: /usr/sbin/radiusd not installed"; exit 1; }

	for f in radiusd.conf clients.conf proxy.conf \
		 policy.d/accounting policy.d/filter \
		 sites-available/default sites-enabled/default; do
		[ -s "$FR_ETC/$f" ] || { echo "FAIL: $FR_ETC/$f missing or empty"; exit 1; }
	done

	# radiusd derives every other config path from raddbdir.
	grep -q "^raddbdir = $FR_ETC\$" "$FR_ETC/radiusd.conf" || {
		echo "FAIL: radiusd.conf does not set raddbdir to $FR_ETC"
		grep -n '^raddbdir' "$FR_ETC/radiusd.conf"
		exit 1
	}

	[ -x /etc/init.d/radiusd ] || { echo "FAIL: /etc/init.d/radiusd not installed"; exit 1; }
	;;

freeradius3-default)
	# Pulls in the modules radiusd.conf expects in mods-enabled/, so this is
	# the first package where the server can start. -XC reads the whole
	# config, loads every module and initialises OpenSSL, then exits.
	radiusd -XC || {
		echo "FAIL: 'radiusd -XC' could not start the server"
		exit 1
	}
	;;

freeradius3-common)
	for l in dhcp eap radius server; do
		[ -s "$FR_LIB/libfreeradius-$l.so" ] || {
			echo "FAIL: $FR_LIB/libfreeradius-$l.so not installed"; exit 1; }
	done

	[ -s "$FR_ETC/dictionary" ] || { echo "FAIL: $FR_ETC/dictionary missing or empty"; exit 1; }
	[ -s "$FR_SHARE/dictionary" ] || { echo "FAIL: $FR_SHARE/dictionary missing or empty"; exit 1; }

	# The Makefile packages only PKG_DICTIONARIES; a still-active $INCLUDE
	# without a file behind it stops radiusd from starting.
	includes=$(sed -n 's/^\$INCLUDE[[:space:]][[:space:]]*\(dictionary\.[^[:space:]]*\).*/\1/p' \
		"$FR_SHARE/dictionary")
	[ -n "$includes" ] || {
		echo "FAIL: no active \$INCLUDE lines in $FR_SHARE/dictionary"; exit 1; }

	missing=
	for d in $includes; do
		[ -f "$FR_SHARE/$d" ] || missing="$missing $d"
	done
	[ -z "$missing" ] || {
		echo "FAIL: \$INCLUDE with no dictionary file behind it:$missing"; exit 1; }
	;;

freeradius3-utils)
	for t in radclient radeapclient radwho; do
		[ -x "/usr/bin/$t" ] || { echo "FAIL: /usr/bin/$t not installed"; exit 1; }
		"/usr/bin/$t" -h 2>&1 | grep -q "Usage: $t" || {
			echo "FAIL: '$t -h' did not print its usage"
			"/usr/bin/$t" -h 2>&1 | head -n 5
			exit 1
		}
	done

	[ -x /usr/bin/radtest ] || { echo "FAIL: /usr/bin/radtest not installed"; exit 1; }
	radtest 2>&1 | grep -q "Usage: radtest" || {
		echo "FAIL: 'radtest' did not print its usage"
		radtest 2>&1 | head -n 5
		exit 1
	}

	# Use a TEST-NET HOSTNAME with no NAS name to verify patch 004 passes it
	# as NAS-IP-Address; capture xtrace and stop radclient with no server.
	nas_ip="192.0.2.77"
	radtest_out="/tmp/radtest-hostname.$$"
	HOSTNAME="$nas_ip" sh -x /usr/bin/radtest u p 127.0.0.1:1812 0 testing123 \
		>"$radtest_out" 2>&1 &
	radtest_pid=$!
	sleep 3
	kill "$radtest_pid" 2>/dev/null
	killall radclient 2>/dev/null
	grep -q "NAS-IP-Address = $nas_ip" "$radtest_out" || {
		echo "FAIL: radtest did not use \$HOSTNAME ($nas_ip) for NAS-IP-Address"
		grep -E 'nas=|NAS-IP-Address' "$radtest_out" | head -n 10
		rm -f "$radtest_out"
		exit 1
	}
	rm -f "$radtest_out"
	;;

freeradius3-democerts)
	for f in ca.pem server.pem; do
		[ -s "$FR_ETC/certs/$f" ] || { echo "FAIL: $FR_ETC/certs/$f missing or empty"; exit 1; }
		grep -q "BEGIN CERTIFICATE" "$FR_ETC/certs/$f" || {
			echo "FAIL: $FR_ETC/certs/$f holds no certificate"; exit 1; }
	done

	grep -q "BEGIN .*PRIVATE KEY" "$FR_ETC/certs/server.pem" || {
		echo "FAIL: $FR_ETC/certs/server.pem holds no private key"; exit 1; }
	;;
esac

exit 0
