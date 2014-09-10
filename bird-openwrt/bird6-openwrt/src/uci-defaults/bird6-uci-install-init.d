#!/bin/sh

EXC=`mount -t overlayfs | grep overlayfs -c`

[ $EXC > 0 ] && rm -r /etc/init.d/bird6 || mv /etc/init.d/bird6 /etc/bird6/init.d/bird6.orig

ln -s /etc/bird6/init.d/bird6 /etc/init.d/bird6
