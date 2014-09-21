#!/bin/sh
#
#set -vx

[ -d /etc/ssl/certs ] || {
        echo "CA-Certificates not istalled - please install first"
        exit 1
}

NUMCERT=$(find /etc/ssl/certs -name *.crt 2>/dev/null | wc -l)
NUMLINK=$(find /etc/ssl/certs -type l 2>/dev/null | wc -l)

[ $NUMLINK -gt 0 ] && {
	echo "File-Links already exist. Exiting"
	exit 0
}

[ -f /usr/bin/openssl ] && OPENSSL="EXIST"
[ -z "$OPENSSL" ] && {
	opkg update || exit 1
	opkg install openssl-util 2>/dev/null
}

for CERTFILE in `ls -1 $(1)/etc/ssl/certs`; do \
	HASH=`openssl x509 -hash -noout -in /etc/ssl/certs/$CERTFILE`
	SUFFIX=0
	while [ -h "/etc/ssl/certs/$HASH.$SUFFIX" ]; do
		let "SUFFIX += 1"
	done
	ln -s "$CERTFILE" "/etc/ssl/certs/$HASH.$SUFFIX"
	echo "link $HASH.$SUFFIX created for $CERTFILE"
done

[ -z "$OPENSSL" ] && opkg remove --force-remove --autoremove openssl-util 2>/dev/null
