#!/bin/sh

EXC=`mount -t overlayfs | grep overlayfs -c`

[ $EXC > 0 ] && rm -r /etc/init.d/bird4 || mv /etc/init.d/bird4 /etc/bird4/init.d/bird4.orig

ln -s /etc/bird4/init.d/bird4 /etc/init.d/bird4
