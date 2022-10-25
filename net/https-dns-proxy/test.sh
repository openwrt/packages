#!/bin/sh

/etc/init.d/"$1" version 2>&1 | grep "$2" && "$1" -V 2>&1 | grep "$2"
