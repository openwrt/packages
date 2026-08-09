#!/bin/sh

# PKG_SRC_VERSION is not exported by the CI harness; derive the upstream
# version string (8.0.0beta2) from PKG_VERSION (8.0.0_beta2).
PKG_SRC_VERSION="$(echo "$PKG_VERSION" | tr -d '_')"

case "$PKG_NAME" in
zabbix80-frontend-server)
	exit 0
	;;
zabbix80-agentd-basic)
	zabbix_agentd -V 2>&1 | grep -F "${PKG_SRC_VERSION}"
	;;
zabbix80-proxy-basic-sqlite)
	zabbix_proxy -V 2>&1 | grep -F "${PKG_SRC_VERSION}"
	;;
*)
	# We use tr as parameter string replace is undefined in POSIX
	"$(echo "$PKG_NAME" | sed -e 's/zabbix80/zabbix/' | tr '-' '_')" -V 2>&1 | grep -F "${PKG_SRC_VERSION}"
	;;
esac
