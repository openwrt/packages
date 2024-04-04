#!/bin/sh

curr_ver=0.4.7

# Copyright: antonk (antonk.d3v@gmail.com)
# github.com/friendly-bits

lock_file="/tmp/geoip-shell.lock"
[ -f "$lock_file" ] && {
	logger -t "geoip-shell-fw-include.sh" -p "user.info" "Lock file $lock_file exists, refusing to open another instance."
	return 0
}

/bin/sh "/usr/bin/geoip-shell-run.sh" restore -a 1>/dev/null &
:
