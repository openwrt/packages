#!/bin/sh
# OpenSSH reports "10.4p1" but PKG_VERSION is "10.4_p1"; verify via ssh/sshd
# where present and accept subpackages that ship no version-reporting binary.
want="OpenSSH_$(echo "$2" | sed 's/_p/p/')"
for bin in /usr/libexec/ssh-openssh /usr/sbin/sshd; do
	[ -x "$bin" ] || continue
	"$bin" -V 2>&1 | grep -q "$want" && exit 0
	exit 1
done
exit 0
