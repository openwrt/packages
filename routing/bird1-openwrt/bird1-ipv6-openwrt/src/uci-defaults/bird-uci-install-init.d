#!/bin/sh

[ $# -ne 1 ] && exit 1

BIRD=$1

EXC=`mount -t overlayfs | grep overlayfs -c`

[ $EXC > 0 ] && rm -r /etc/init.d/${BIRD} || mv /etc/init.d/${BIRD} /etc/${BIRD}/init.d/${BIRD}.orig

ln -s /etc/${BIRD}/init.d/${BIRD} /etc/init.d/${BIRD}

exit 0
