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
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

CHALLENGE_PATH="${CHALLENGE_DIR:-/var/run/acme/challenge}"
mkdir -p "${CHALLENGE_PATH}/.well-known/acme-challenge"
ARGS=5
E_BADARGS=85

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

case "$METHOD" in
    "begin")
        case "$TYPE" in
            http-01)
                printf "%s" "${AUTH}" > "${CHALLENGE_PATH}/.well-known/acme-challenge${TOKEN}"
                exit $?
                ;;
            *)
                exit 1
                ;;
        esac
        ;;

    "done"|"failed")
        case "$TYPE" in
            http-01)
                rm "${CHALLENGE_PATH}/${TOKEN}"
                exit $?
                ;;
            *)
                exit 1
                ;;
        esac
        ;;

    *)
        echo "$0: invalid method" 1>&2 
        exit 1
esac
