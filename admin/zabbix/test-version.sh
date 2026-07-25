#!/bin/sh

case "$PKG_NAME" in
zabbix-extra-* | zabbix-frontend-server)
	exit 0
	;;
zabbix-agentd-basic)
	zabbix_agentd -V 2>&1 | grep -F "${PKG_VERSION}"
	;;
zabbix-proxy-basic-sqlite)
	zabbix_proxy -V 2>&1 | grep -F "${PKG_VERSION}"
	;;
*)
	# We use tr as parameter string replace is undefined in POSIX
	"$(echo "$PKG_NAME" | tr '-' '_')" -V 2>&1 | grep -F "${PKG_VERSION}"
	;;
esac
