#!/bin/sh

case "$1" in
	"base16384")
        opkg install coreutils-base64
        i=1
        while [ $i -le 256 ]; do
            s="$(head /dev/urandom | head -c $i | base64 -w 0)"
            if [ "$(echo $s)" != "$(echo $s | base64 -d | base16384 -e - - | base16384 -d - - | base64 -w 0)" ]; then
                exit $i
            fi
            i=$( expr $i + 1 )
        done
esac

exit 0
