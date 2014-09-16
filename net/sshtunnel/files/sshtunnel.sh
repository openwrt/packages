#!/bin/sh 

PIDFILE="/tmp/run/sshtunnel"

args="$1"
retrydelay="$2"
server="$3"

while true
do
	logger -p daemon.info -t "sshtunnel[$$][$server]" "connection started"
	
	start-stop-daemon -S -p "${PIDFILE}_${$}.pid" -mx ssh -- $args &>/tmp/log/sshtunnel_$$ 
	
	logger -p daemon.err -t "sshtunnel[$$][$server]" < /tmp/log/sshtunnel_$$
	rm /tmp/log/sshtunnel_$$
	logger -p daemon.info -t "sshtunnel[$$][$server]" "ssh exited with code $?, retrying in $retrydelay seconds"
	rm "${PIDFILE}_${$}.pid"

	sleep "$retrydelay" & wait
done
