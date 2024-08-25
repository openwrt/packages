#!/bin/sh

. /lib/config/uci.sh

APDU_BACKEND="$(uci_get lpac global apdu_backend uqmi)"
APDU_DEBUG="$(uci_get lpac global apdu_debug 0)"

HTTP_BACKEND="$(uci_get lpac global http_backend curl)"
HTTP_DEBUG="$(uci_get lpac global http_debug 0)"

export LPAC_HTTP="$HTTP_BACKEND"
if [ "$HTTP_DEBUG" -eq 1 ]; then
    export LIBEUICC_DEBUG_HTTP="1"
fi

export LPAC_APDU="$APDU_BACKEND"
if [ "$APDU_DEBUG" -eq 1 ]; then
    export LIBEUICC_DEBUG_APDU="1"
fi

if [ "$APDU_BACKEND" = "at" ]; then
    AT_DEVICE="$(uci_get lpac at device /dev/ttyUSB2)"
    AT_DEBUG="$(uci_get lpac at debug 0)"
    export AT_DEVICE="$AT_DEVICE"
    export AT_DEBUG="$AT_DEBUG"
elif [ "$APDU_BACKEND" = "uqmi" ]; then
    UQMI_DEV="$(uci_get lpac uqmi device /dev/cdc-wdm0)"
    UQMI_DEBUG="$(uci_get lpac uqmi debug 0)"
    export LPAC_QMI_DEV="$UQMI_DEV"
    export LPAC_QMI_DEBUG="$UQMI_DEBUG"
fi

/usr/lib/lpac "$@"
