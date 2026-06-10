#!/bin/sh

case "$1" in
rsyslog)
	rsyslogd -v 2>&1 | grep -qF "$2" || {
		echo "FAIL: rsyslogd -v did not print expected version '$2'"
		exit 1
	}
	echo "rsyslogd version: OK"

	[ -f /etc/rsyslog.conf ] || {
		echo "FAIL: /etc/rsyslog.conf not installed"
		exit 1
	}
	echo "rsyslog.conf: OK"

	[ -x /etc/init.d/rsyslog ] || {
		echo "FAIL: /etc/init.d/rsyslog not executable"
		exit 1
	}
	echo "init script: OK"

	[ -d /usr/lib/rsyslog ] || {
		echo "FAIL: /usr/lib/rsyslog plugin directory not installed"
		exit 1
	}
	echo "plugin dir: OK"
	;;
esac
