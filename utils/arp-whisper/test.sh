#!/bin/sh

case "$1" in
    "arp-whisper")
        arp-whisper --version 2>&1 | grep "$2"
        ;;
esac
