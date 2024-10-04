#!/bin/sh

. /lib/config/uci.sh

: "${LPAC_APDU=$(uci_get lpac global apdu_backend)}"; export LPAC_APDU
LIBEUICC_DEBUG_APDU="$(uci_get lpac global apdu_debug)" && export LIBEUICC_DEBUG_APDU

if [ "$LPAC_APDU" = "at" ]; then
    export AT_DEVICE="$(uci_get lpac at device)"
    AT_DEBUG="$(uci_get lpac at debug)" && export AT_DEBUG
elif [ "$LPAC_APDU" = "uqmi" ]; then
    export LPAC_QMI_DEV="$(uci_get lpac uqmi device)"
    LPAC_QMI_DEBUG="$(uci_get lpac uqmi debug)" && export LPAC_QMI_DEBUG
fi

export LPAC_HTTP="$(uci_get lpac global http_backend)"
LIBEUICC_DEBUG_HTTP="$(uci_get lpac global http_debug)" && export LIBEUICC_DEBUG_HTTP

exec /usr/lib/lpac "$@"