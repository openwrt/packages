#!/bin/sh

# shellcheck shell=busybox

case "$1" in
rtl-sdr)
    rtl_sdr 2>&1 | grep -q "RTL2832"
    rtl_tcp -h 2>&1 | grep -q "RTL2832"
    rtl_test -h 2>&1 | grep -q "RTL2832"
    rtl_fm -h 2>&1 | grep -q "RTL2832"
    rtl_eeprom -h 2>&1 | grep -q "RTL2832"
    rtl_adsb -h 2>&1 | grep -q "ADS-B"
    rtl_power -h 2>&1 | grep -q "RTL2832"
    ;;
librtlsdr)
    # Pure shared library, checked by packaging and linking tools
    exit 0
    ;;
*)
    echo "test.sh: unknown subpackage '$1' — refusing to silently pass" >&2
    echo "test.sh: update utils/rtl-sdr/test.sh to cover this subpackage" >&2
    exit 1
    ;;
esac
