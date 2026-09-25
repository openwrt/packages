#! /bin/sh

set -o errexit

case "${PKG_NAME}" in
    cache-domains-openssl)
        LIBUSTREAM_DEPS="libustream-openssl libopenssl3"
        LIBUSTREAM_DEPS="${LIBUSTREAM_DEPS} libatomic1" # arm_cortex-a15_neon-vfpv4 extra dep
        ;;
    cache-domains-mbedtls)
        LIBUSTREAM_DEPS="libustream-mbedtls libmbedtls"
        ;;
    cache-domains-wolfssl)
        LIBUSTREAM_DEPS="libustream-wolfssl libwolfssl"
        ;;
esac

# Replace the current libustream with the one PKG_NAME depends on.
# opkg depends on libustream for https so we need to download the
# replacement first and replace it offline.
opkg download ${LIBUSTREAM_DEPS}
opkg remove 'libustream-*'
opkg install --offline-root / ./*.ipk
rm ./*.ipk
