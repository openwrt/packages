#!/bin/sh

help() {
	echo "$0 {lock|lockrun|unlock} module key [cmd]"
	exit 2
}

what="$1"
[ -z "$what" ] && help
shift

module="$1"
[ -z "$module" ] && help
shift

lkey="$1"
[ -z "$lkey" ] && help
shift

[ -z "$seconds" ] && seconds=5
[ -z "$force" ] && force=1

[ -f /lib/zabbix/owrt/functions.sh ] && . /lib/zabbix/owrt/functions.sh
[ -f /lib/zabbix/${module}/functions.sh ] && . /lib/zabbix/${module}/functions.sh 

lockfile="/tmp/zlock_${lkey}"

if [ "$what" = "lock" ] || [ "$what" = "lockrun" ]; then
	i=0
	while [ -f "$lockfile" ] && [ $i -lt $seconds ]; do
		sleep 1
		i=$(expr $i + 1)
	done
	if [ -f "$lockfile" ] && [ -n "$force" ]; then
		logger -s -t "zlock" -p daemon.warn "Releasing $lockfile!"
		rm -f "$lockfile"
	fi
	if [ -f "$lockfile" ] && [ -z "$force" ]; then
		logger -s -t "zlock" -p daemon.err "Could not get lock for $lockfile!"
		exit 1
	fi
	touch "$lockfile"
	[ "$what" = "lockrun" ] && [ -n "$*" ] && $@
	rm -f "$lockfile"
fi

if [ "$what" = "unlock" ]; then
	rm -f "$lockfile"
fi


