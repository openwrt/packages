#!/bin/sh

[ "$1" = "tcpreplay-all" ] || exit 0

EXEC_LIST="tcpbridge tcpliveplay tcpreplay tcprewrite tcpcapinfo tcpprep tcpreplay-edit"

for executable in $EXEC_LIST ; do
	$executable --version
	$executable --version 2>&1 | grep "$2"
	[ $? == 0 ] || {
		echo "Problem or incorrect version for '$executable'"
		exit 1
	}
done

