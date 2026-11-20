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
if command -v apk > /dev/null; then
    # apk downloads through uclient-fetch, which needs libustream too.
    # Adding the variant overwrites /lib/libustream-ssl.so in place and keeps
    # it in world when PKG_NAME is removed after the test. apk fix rewrites
    # the file if the variant was installed but another one overwrote it.
    # apk pulls the libraries itself, so only the first entry is needed.
    apk add "${LIBUSTREAM_DEPS%% *}"
    apk fix "${LIBUSTREAM_DEPS%% *}"
    exit 0
fi

# opkg depends on libustream for https so we need to download the
# replacement first and replace it offline.
opkg download ${LIBUSTREAM_DEPS}
opkg remove 'libustream-*'
opkg install --offline-root / ./*.ipk
rm ./*.ipk
