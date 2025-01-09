#!/bin/sh

. /lib/config/uci.sh

APDU_BACKEND="$(uci_get lpac global apdu_backend uqmi)"
APDU_DEBUG="$(uci_get lpac global apdu_debug 0)"

HTTP_BACKEND="$(uci_get lpac global http_backend curl)"
HTTP_DEBUG="$(uci_get lpac global http_debug 0)"

function export_if_not_in_env {
    eval "value=\${$1}"
    if [ -z "$value" ]; then
        export "$1=$2"
    fi
}

export_if_not_in_env LPAC_HTTP "$HTTP_BACKEND"
if [ "$HTTP_DEBUG" -eq 1 ]; then
    export_if_not_in_env LIBEUICC_DEBUG_HTTP "1"
fi

export_if_not_in_env LPAC_APDU "$APDU_BACKEND"
if [ "$APDU_DEBUG" -eq 1 ]; then
    export_if_not_in_env LIBEUICC_DEBUG_APDU "1"
fi

if [ "$APDU_BACKEND" = "at" ]; then
    export_if_not_in_env AT_DEVICE "$(uci_get lpac at device /dev/ttyUSB2)"
    export_if_not_in_env AT_DEBUG "$(uci_get lpac at debug 0)"
elif [ "$APDU_BACKEND" = "uqmi" ]; then
    export_if_not_in_env LPAC_QMI_DEV "$(uci_get lpac uqmi device /dev/cdc-wdm0)"
    export_if_not_in_env LPAC_QMI_DEBUG "$(uci_get lpac uqmi debug 0)"
fi

/usr/lib/lpac "$@"
