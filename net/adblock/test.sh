#!/bin/sh

/etc/init.d/"${1}" version 2>/dev/null | grep "${2}"
