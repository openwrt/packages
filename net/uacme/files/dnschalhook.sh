#!/bin/sh
# Copyright (C) 2019-2024 Nicola Di Lieto <nicola.dilieto@gmail.com>
#
# This file is part of uacme.
#
# uacme is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# uacme is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# Part of this is copied from acme.sh
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

ARGS=5
E_BADARGS=85
LOG_TAG=acme-uacme-dnshook

if test $# -ne "$ARGS"
then
    echo "Usage: $(basename "$0") method type ident token auth" 1>&2
    exit $E_BADARGS
fi

METHOD=$1
TYPE=$2
IDENT=$3
TOKEN=$4
AUTH=$5

if [ "$TYPE" != "dns-01" ]; then
    echo "skipping $TYPE" 1>&2
    exit 1
fi

# shellcheck source=net/acme/files/functions.sh
. /usr/lib/acme/functions.sh
. /usr/lib/acme/client/dnsapi_helper.sh
ACCOUNT_CONF_PATH=$UACME_CONFDIR/accounts.conf
DOMAIN_CONF=$UACME_CONFDIR/$IDENT.conf
ACMESH_DNSSCIRPT_DIR=${ACMESH_DNSSCIRPT_DIR:-/usr/lib/acme/client/dnsapi}

#import dns hook script 
if [ ! -f "$ACMESH_DNSSCIRPT_DIR/$dns.sh" ]; then
    echo "dns file $dns doesn't exit" > tee /tmp/dnshooklog
    exit 1
fi
. /usr/lib/acme/client/dnsapi/$dns.sh
case "$METHOD" in
    "begin")
        (umask 077 ; touch -a "$DOMAIN_CONF")
        log info logging $DOMAIN_CONF
        ${dns}_add _acme-challenge.$IDENT $AUTH
        RESULT=$?
        if [ $RESULT -eq 0 ]; then
            sleep ${dns_wait:-"30s"}
            exit 0
        else
            exit $RESULT
        fi
        ;;
    "done"|"failed")
        ${dns}_rm _acme-challenge.$IDENT $AUTH
        exit $?
        ;;
    *)
        echo "$0: invalid method" 1>&2 
        exit 1
        ;;
esac
