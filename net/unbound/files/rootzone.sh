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
# This component needs to be used within the unbound.sh as an include. It uses
# defaults and UCI scope variables defined there. It will copy root.key back
# to /etc/unbound/ periodically, but avoid ROM flash abuse (UCI option).
#
##############################################################################

rootzone_uci() {
  local cfg=$1

  # This will likely be called outside of "start_service()" context
  config_get_bool UNBOUND_B_DNSSEC "$cfg" validator 0
  config_get_bool UNBOUND_B_NTP_BOOT "$cfg" validator_ntp 1
  config_get UNBOUND_N_ROOT_AGE "$cfg" root_age 9
}

##############################################################################

roothints_update() {
  # TODO: Might not be implemented. Unbound doesn't natively update hints.
  # Unbound philosophy is built in root hints are good for machine life.
  return 0
}

##############################################################################

rootkey_update() {
  local basekey_date rootkey_date rootkey_age filestuff


  if [ "$UNBOUND_N_ROOT_AGE" -gt 90 -o "$UNBOUND_B_DNSSEC" -lt 1 ] ; then
    # Feature disabled
    return 0

  elif [ "$UNBOUND_B_NTP_BOOT" -gt 0 -a ! -f "$UNBOUND_TIMEFILE" ] ; then
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


  if [ "$rootkey_age" -gt "$UNBOUND_N_ROOT_AGE" ] ; then
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
  # Partial UCI fetch for this functional group
  config_load unbound
  config_foreach rootzone_uci unbound

  # You need root.hints and root.key to boot strap recursion
  roothints_update
  rootkey_update
}

##############################################################################

