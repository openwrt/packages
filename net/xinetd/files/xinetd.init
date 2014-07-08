#!/bin/sh /etc/rc.common
# Copyright (C) 2006-2011 OpenWrt.org

START=50

SERVICE_USE_PID=1

start() {
	service_start /usr/sbin/xinetd -pidfile /var/run/xinetd.pid
}

stop() {
	service_stop /usr/sbin/xinetd
}

