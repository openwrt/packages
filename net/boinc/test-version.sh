#!/bin/sh

[ "$1" = "boinc" ] || exit 0

boinc_client --version 2>&1 | grep "$2"
