#!/bin/sh

case "$1" in
    "openthread-br")
        otbr-agent --version | grep "$2"
        ;;
esac
