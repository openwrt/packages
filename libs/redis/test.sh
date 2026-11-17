#!/bin/sh
# Functional tests for the redis packages; CI already probes --version.

sock="/tmp/redis-t.$$.sock"; dir="/tmp/redis-t.$$"; logf="/tmp/redis-t.$$.log"
srv_pid=""
cleanup() { [ -n "$srv_pid" ] && kill "$srv_pid" 2>/dev/null; rm -rf "$sock" "$dir" "$logf"; }
trap cleanup EXIT

# Start redis-server in the foreground and background it with the shell. Under
# QEMU the madvise/fork COW self-check trips and redis refuses to start, so
# suppress it with ignore-warnings. Wait up to 30s for the unix socket and dump
# the log if the server never comes up.
start_server() {
	mkdir -p "$dir"
	redis-server --port 0 --unixsocket "$sock" --dir "$dir" --save '' \
		--ignore-warnings ARM64-COW-BUG --logfile "$logf" --daemonize no &
	srv_pid=$!
	i=0
	while [ "$i" -lt 30 ]; do
		[ -S "$sock" ] && return 0
		kill -0 "$srv_pid" 2>/dev/null || break
		i=$((i + 1)); sleep 1
	done
	echo "redis-server did not come up; log:"; cat "$logf" 2>/dev/null
	return 1
}

case "$1" in
redis-server)
	[ -f /etc/redis.conf ] || { echo "FAIL: /etc/redis.conf missing"; exit 1; }
	grep "dir /var/lib/redis" /etc/redis.conf || { echo "FAIL: redis.conf dir"; exit 1; }
	[ -x /etc/init.d/redis ] || { echo "FAIL: init script missing"; exit 1; }
	start_server || { echo "FAIL: redis-server did not start / bind socket"; exit 1; }
	echo "redis-server: started and listening on unix socket"
	;;
redis-cli)
	# No server is installed alongside redis-cli, so prove the client runs
	# and fails cleanly against a dead endpoint.
	redis-cli -s /nonexistent.sock -t 1 ping 2>&1 |
		grep -iE "could not connect|no such" ||
		{ echo "FAIL: redis-cli did not report a connection error"; exit 1; }
	echo "redis-cli: runs and reports connection errors"
	;;
redis-utils)
	[ -x /usr/bin/redis-check-aof ] || { echo "FAIL: redis-check-aof missing"; exit 1; }
	# redis-server comes in as a dependency here: run a real client/server
	# round-trip across several data types through redis-benchmark.
	start_server || { echo "FAIL: redis-server did not start"; exit 1; }
	redis-benchmark -s "$sock" -n 100 -c 2 -q -t set,get,incr,lpush,lrange,hset \
		>/dev/null 2>&1 || { echo "FAIL: redis-benchmark round-trip failed"; exit 1; }
	echo "redis-utils: benchmark round-trip (set/get/incr/lpush/lrange/hset) ok"
	;;
*)
	echo "Unsupported test target: $1" >&2
	exit 1
	;;
esac
