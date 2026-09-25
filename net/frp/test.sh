#!/bin/sh

# frpc/frps both accept "verify -c <file>" to validate a config without
# connecting, which exercises the TOML config loader end-to-end.
case "$1" in
frpc)
	conf="/tmp/frpc.$$.toml"
	printf 'serverAddr = "127.0.0.1"\nserverPort = 7000\n' > "$conf"
	frpc verify -c "$conf" || { echo "FAIL: frpc rejected a valid config"; rm -f "$conf"; exit 1; }
	rm -f "$conf"
	;;
frps)
	conf="/tmp/frps.$$.toml"
	printf 'bindPort = 7000\n' > "$conf"
	frps verify -c "$conf" || { echo "FAIL: frps rejected a valid config"; rm -f "$conf"; exit 1; }
	rm -f "$conf"
	;;
*)
	exit 0
	;;
esac
