#!/bin/sh

if [ "$PKG_NAME" = "nut" ]; then
	exit 0
fi

EXEC="${PKG_NAME#nut-}"

case "$EXEC" in
common | upsmon-sendmail-notify | avahi-service)
	exit 0
	;;
driver-*)
	DRIVER="${EXEC#driver-}"
	/usr/libexec/nut/"$DRIVER" -V 2>&1 | grep -qF "${PKG_VERSION}"
	;;
server)
	"upsd" -V 2>&1 | grep -qF "${PKG_VERSION}" && "upsdrvctl" -V 2>&1 | grep -qF "${PKG_VERSION}"
	;;
upssched)
	# Only intended to be run from upsmon
	exit 0
	;;
web-cgi)
	# Only runs as CGI scripts
	exit 0
	;;
*)
	"$EXEC" -V 2>&1 | grep -qF "${PKG_VERSION}"
	;;
esac
