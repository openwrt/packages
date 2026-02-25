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

# noop challange 'solver' for challenge type select

ARGS=5
E_BADARGS=85
LOG_TAG=acme-uacme-dns-persist

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

if [ "$TYPE" != "dns-persist-01" ]; then
    echo "skipping $TYPE" 1>&2
    exit 1
fi

if [ "$METHOD" = "failed" ]; then
   logger -t "$LOG_TAG" -p "daemon.info" -- "Create TXT record $AUTH at _validation-persist.$IDENT to authorize domain"
fi

exit 0
