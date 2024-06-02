#!/bin/sh

case "$1" in
        msmtp)
                msmtp --version | grep "$2"
                ;;
esac
