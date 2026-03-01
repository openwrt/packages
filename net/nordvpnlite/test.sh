#!/bin/sh

case "$1" in
    "nordvpnlite")
        nordvpnlite --version 2>&1 | grep "$2"
        ;;
esac
