#!/bin/sh

case "$1" in
    "iperf3"|"iperf3-ssl")
        service iperf3 start
        sleep 2
        iperf3 --client localhost --time 3 --bitrate 1M --connect-timeout 2000
        result=$?
        service iperf3 stop
        exit ${result}
        ;;
    *)
        echo "Untested package: ${1}" >&2
        exit 1
        ;;
esac
