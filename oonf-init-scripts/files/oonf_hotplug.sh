#!/bin/sh

case "${ACTION}" in
	ifup)
		. /etc/rc.common /etc/init.d/${DAEMON} enabled && {
			logger -t '${DAEMON}[hotplug]' -p daemon.info 'reloading configuration'
			. /etc/rc.common /etc/init.d/${DAEMON} reload
		}
	;;
esac
