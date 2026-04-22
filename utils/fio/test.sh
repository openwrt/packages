#!/bin/sh

case "$1" in
	fio)
		# null ioengine discards all I/O — quick sanity check with no disk access
		fio --name=sanity --ioengine=null --rw=randwrite --size=64k \
			--bs=4k --iodepth=1 --numjobs=1 2>&1 | grep -qF "sanity"
		;;
esac
