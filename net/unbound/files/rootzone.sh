#!/bin/sh
##############################################################################
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# Copyright (C) 2016 Eric Luehrsen
#
##############################################################################
#
# This component will copy root.key back to /etc/unbound/ periodically, but
# avoid ROM flash abuse (UCI option).
#
##############################################################################

roothints_update() {
  # TODO: Might not be implemented. Unbound doesn't natively update hints.
  # Unbound philosophy is built in root hints are good for machine life.
  return 0
}

##############################################################################

rootkey_update() {
  local basekey_date rootkey_date rootkey_age filestuff

  local dnssec=$( uci_get unbound.@unbound[0].validator )
  local dnssec_ntp=$( uci_get unbound.@unbound[0].validator_ntp )
  local dnssec_age=$( uci_get unbound.@unbound[0].root_age )


  if [ "$dnssec_age" -gt 90 -o "$dnssec" -lt 1 ] ; then
    # Feature disabled
    return 0

  elif [ "$dnssec_ntp" -gt 0 -a ! -f "$UNBOUND_TIMEFILE" ] ; then
    # We don't have time yet
    return 0
  fi


  if [ -f /etc/unbound/root.key ] ; then
    basekey_date=$( date -r /etc/unbound/root.key +%s )

  else
    # No persistent storage key
    basekey_date=$( date -d 2000-01-01 +%s )
  fi


  if [ -f "$UNBOUND_KEYFILE" ] ; then
    # Unbound maintains it itself
    rootkey_date=$( date -r $UNBOUND_KEYFILE +%s )
    rootkey_age=$(( (rootkey_date - basekey_date) / 86440 ))

  elif [ -x "$UNBOUND_ANCHOR" ] ; then
    # No tmpfs key - use unbound-anchor
    rootkey_date=$( date -I +%s )
    rootkey_age=$(( (rootkey_date - basekey_date) / 86440 ))
    $UNBOUND_ANCHOR -a $UNBOUND_KEYFILE

  else
    # give up
    rootkey_age=0
  fi


  if [ "$rootkey_age" -gt "$dnssec_age" ] ; then
    filestuff=$( cat $UNBOUND_KEYFILE )


    case "$filestuff" in
      *NOERROR*)
        # Header comment for drill and dig
        logger -t unbound -s "root.key updated after $rootkey_age days"
        cp -p $UNBOUND_KEYFILE /etc/unbound/root.key
        ;;

      *"state=2 [  VALID  ]"*)
        # Comment inline to key for unbound-anchor
        logger -t unbound -s "root.key updated after $rootkey_age days"
        cp -p $UNBOUND_KEYFILE /etc/unbound/root.key
        ;;

      *)
        logger -t unbound -s "root.key still $rootkey_age days old"
        ;;
    esac
  fi
}

##############################################################################

rootzone_update() {
  roothints_update
  rootkey_update
}

##############################################################################

