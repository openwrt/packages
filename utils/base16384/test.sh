#!/bin/sh

case "$1" in
	"base16384")
        i=1
        while [ $i -le 100 ]; do
            s="$(head /dev/urandom | head -c $i)"
            if [ "$(echo $s)" != "$(echo $s | base16384 -e - - | base16384 -d - -)" ]; then
                exit $i
            fi
            i=$( expr $i + 1 )
        done
esac

exit 0
