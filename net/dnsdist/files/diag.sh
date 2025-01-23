#!/bin/sh
DIR=$(mktemp -d)

[ -d $DIR ] || exit 1

cd $DIR

logread > $DIR/logread.txt
wget -q -O dnsdist.statistics.txt http://127.0.0.1:9080/api/v1/servers/localhost
PIDS=$(pidof dnsdist)

echo "dnsdist pids: $PIDS" > dnsdist.pids.txt
cp /etc/dnsdist.conf dnsdist.conf.txt
cp /etc/config/dnsdist dnsdist.uci.txt

ps > ps.txt

dmesg > dmesg.txt

netstat -rn > netstat-rn.txt

netstat -pan > netstat-pan.txt

for pid in $(pidof dnsdist)
do
	ls -al /proc/$pid/fd > dnsdist.pid.$pid.fd.txt
	for f in limits maps smaps smaps_rollup stat statm status
	do
		[ -e /proc/$pid/$f ] && cat /proc/$pid/$f > dnsdist.pid.$pid.$f.txt
	done
done

TARF=$DIR/dnsdist.diagnostics.$(date +%s).tar

tar -cf $TARF *.txt
rm -f *.txt

echo Diagnostics stored as $TARF
