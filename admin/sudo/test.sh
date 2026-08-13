#!/bin/sh

# sudo hangs when executed under QEMU emulation (e.g. mips_24kc), so verify the
# installed files rather than running it. The version is checked in
# test-version.sh against the string compiled into the binary.
case "$1" in
sudo)
	[ -x /usr/bin/sudo ] || { echo "FAIL: /usr/bin/sudo missing"; exit 1; }
	[ -x /usr/sbin/visudo ] || { echo "FAIL: /usr/sbin/visudo missing"; exit 1; }
	[ -f /etc/sudoers ] || { echo "FAIL: /etc/sudoers missing"; exit 1; }
	;;
esac
