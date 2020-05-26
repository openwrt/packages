#!/bin/sh

printf "Initializing tests ...\n"

fakechroot=""

[ -x "/usr/bin/fakechroot" ] && fakechroot="/usr/bin/fakechroot" \
|| [ "$(id -u)" -eq 0 ] || { \
    printf "Error: Testing needs fakechroot or whoami=root for chroot."
    return 1
}

TMPROOT="$(mktemp -d "/tmp/test-nginx-util-XXXXXX")"

ln -s /bin "${TMPROOT}/bin"

mkdir -p "${TMPROOT}/usr/bin/"

cp "./test-nginx-util-root.sh" "${TMPROOT}/usr/bin/"


printf "\n\n******* Testing nginx-ssl-util-noubus *******\n"

cp "./nginx-ssl-util-noubus" "${TMPROOT}/usr/bin/nginx-util"

"${fakechroot}" /bin/chroot "${TMPROOT}" \
    /bin/sh -c "/usr/bin/test-nginx-util-root.sh" ||
{
    echo "!!! Error: $?"
    rm -r "${TMPROOT}"
    exit 1
}


printf "\n\n******* Testing nginx-ssl-util-nopcre-noubus *******\n"

cp "./nginx-ssl-util-nopcre-noubus" "${TMPROOT}/usr/bin/nginx-util"

"${fakechroot}" /bin/chroot "${TMPROOT}" \
    /bin/sh -c "/usr/bin/test-nginx-util-root.sh" ||
{
    echo "!!! Error: $?"
    rm -r "${TMPROOT}"
    exit 1
}


rm -r "${TMPROOT}"
