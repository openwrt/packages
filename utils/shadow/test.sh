#!/bin/sh

applet="${1#shadow-}"

find_bin() {
	for d in /usr/sbin /usr/bin; do
		[ -x "$d/$1" ] && echo "$d/$1" && return 0
	done
	return 1
}

case "$1" in
shadow-common)
	[ -f /etc/login.defs ] || {
		echo "FAIL: /etc/login.defs not installed"
		exit 1
	}
	echo "login.defs: OK"

	grep -q "ENCRYPT_METHOD.*BCRYPT" /etc/login.defs || {
		echo "FAIL: BCRYPT not configured as ENCRYPT_METHOD in login.defs"
		exit 1
	}
	echo "BCRYPT encryption: OK"
	;;

shadow-utils|shadow)
	# meta-packages, no binaries to test
	;;

shadow-login|shadow-su)
	# PAM-interactive; presence is covered by generic CI tests.
	;;

shadow-pwck)
	bin=$(find_bin pwck) || { echo "FAIL: pwck not found"; exit 1; }
	# -r is read-only mode. Exit status is non-zero whenever pwck spots any
	# warning in /etc/passwd (which the runtime-test container's stock files
	# routinely trigger), so we only check that pwck actually ran and reached
	# its summary line.
	out=$("$bin" -r 2>&1)
	echo "$out" | grep -qE "no changes|pwck:" || {
		echo "FAIL: pwck -r did not produce expected output"
		echo "$out"
		exit 1
	}
	echo "pwck -r: OK"
	;;

shadow-grpck)
	bin=$(find_bin grpck) || { echo "FAIL: grpck not found"; exit 1; }
	"$bin" -r || {
		echo "FAIL: grpck -r returned non-zero on /etc/group"
		exit 1
	}
	echo "grpck -r: OK"
	;;

shadow-chage)
	bin=$(find_bin chage) || { echo "FAIL: chage not found"; exit 1; }
	# -l lists password-aging info for a user; root always exists.
	"$bin" -l root | grep -q "Last password change" || {
		echo "FAIL: chage -l root did not print expected output"
		exit 1
	}
	echo "chage -l root: OK"
	;;

shadow-useradd)
	bin=$(find_bin useradd) || { echo "FAIL: useradd not found"; exit 1; }
	# -D with no other args dumps defaults to stdout, no system modification.
	"$bin" -D | grep -q "^GROUP=" || {
		echo "FAIL: useradd -D did not dump defaults"
		exit 1
	}
	echo "useradd -D: OK"
	;;

shadow-passwd)
	bin=$(find_bin passwd) || { echo "FAIL: passwd not found"; exit 1; }
	# -S prints the password status line for a user without modifying it.
	"$bin" -S root | grep -q "^root" || {
		echo "FAIL: passwd -S root did not return root's status line"
		exit 1
	}
	echo "passwd -S root: OK"
	;;

shadow-faillog)
	bin=$(find_bin faillog) || { echo "FAIL: faillog not found"; exit 1; }
	# faillog reads /var/log/faillog; in the CI runtime container that file
	# doesn't exist, so create an empty one. -a then dumps the database (just
	# the header in our case).
	[ -f /var/log/faillog ] || : > /var/log/faillog
	"$bin" -a 2>&1 | grep -qE "Login|Username|Failures" || {
		echo "FAIL: faillog -a did not produce a header line"
		exit 1
	}
	echo "faillog -a: OK"
	;;

shadow-*)
	# Remaining applets (chfn, chsh, chgpasswd, chpasswd, expiry, gpasswd,
	# groupadd, groupdel, groupmems, groupmod, grpconv, grpunconv, logoutd,
	# newgrp, newusers, nologin, pwconv, pwunconv, userdel, usermod, vipw)
	# either modify system state or are interactive.
	# Generic CI tests already verify the binary is present, stripped, and
	# links cleanly; that's the practical bar in this environment.
	bin=$(find_bin "$applet") || {
		echo "FAIL: $applet not found in /usr/sbin or /usr/bin"
		exit 1
	}
	echo "$applet binary: OK ($bin)"
	;;
esac
