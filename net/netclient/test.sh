#!/bin/sh
"/usr/sbin/${1}" version 2>&1 | grep "$2" || "/etc/init.d/${1}" version 2>&1 | grep "$2"
