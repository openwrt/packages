#!/bin/sh
# Runtime test of the openwrt/packages CI: $1 = package name, $2 = version.
# Every module must compile and the controller must answer a status query
# with the default configuration (no radios, no ubus daemon needed).

[ "$1" = chanmgr ] || exit 0

for f in /usr/share/ucode/chanmgr/*.uc /usr/share/rpcd/ucode/chanmgr.uc /usr/sbin/chanmgr; do
	ucode -c -o /dev/null "$f" || exit 1
done

/usr/sbin/chanmgr --version | grep "^chanmgr $2\$" || exit 1
/usr/sbin/chanmgr status | grep '"scheduler"'
