#!/bin/sh

if [ "$1" = 'sx1302_hal-tests' ]; then
	test_loragw_com -h 2>&1 | grep "$2"
elif [ "$1" = 'sx1302_hal-utils' ]; then
	chip_id -h 2>&1 | grep "$2"
fi
