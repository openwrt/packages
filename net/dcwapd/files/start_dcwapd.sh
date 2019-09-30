#!/bin/sh

#
# Dual Channel Wi-Fi Startup Script
#
# This script creates the proper network bridge configuration
#  necessary for Dual Channel Wi-Fi, and starts the dcwapd daemon
#

# Note - shellcheck cannot deal with the dynamic sourcing
# shellcheck disable=SC1090
# which also messes with variables defined in the sourced file
# shellcheck disable=SC2154
scriptdir=$(dirname -- "$(readlink -f -- "$0")")
. "$scriptdir"/dcwapd.inc

get_channelsets
# get the list of channel sets
channelsets=$result

for channelset in $channelsets; do
	if [ -n "$channelset" ]; then
		get_channelset_enabled "$channelset"
		enabled=$result
		if [ "$enabled" = "1" ]; then
			# the channel set is enabled

			# get the list of data channels used by the channel set
			get_datachannels "$channelset"
			datachannels=$result
			for datachannel in $datachannels; do
				datachannel_up "$datachannel"
			done
		fi
	fi
done

# start dcwapd, sending stdout and stderr to the system log
dcwapd 2>&1 | logger &
