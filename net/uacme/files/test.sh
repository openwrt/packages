#!/bin/sh

case "$1" in
"uacme")
    uacme -V 2>&1 | grep "$2"
    ;;
"uacme-ualpn")
    ualpn -V 2>&1 | grep "$2"
    ;;
esac
