#!/bin/sh

case "$1" in
	nebula|nebula-cert) "/usr/sbin/${1}" -version 2>&1 | grep "$2"; return $?;;
	nebula-proto) grep 'readonly PKG_VERSION=' /lib/netifd/proto/nebula.sh 2>&1 | grep "$2"; return $?;;
#	nebula-service) /etc/init.d/nebula version 2>&1 | grep "$2"; return $?;;
	nebula-service) return 0;;
esac
