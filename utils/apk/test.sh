#!/bin/sh

case "$1" in
    "apk")
        apk --version | grep "${2/-r*/}"
        ;;
    *)
        return 0;
esac
