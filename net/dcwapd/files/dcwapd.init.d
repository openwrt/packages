#!/bin/sh /etc/rc.common

START=99
# Setting the stop value makes the restart script unreliable when invoked by LuCI
#STOP=0

scriptdir=/etc/dcwapd

#validate_section_dcwapd() {
#	uci_validate_section dcwapd general "${1}" \
#		'enabled:bool:1'
#}

start() {
#	validate_section_dcwapd dcwapd

	# only run the start script if the enabled uci option is set properly
	enabled=$(uci get dcwapd.general.enabled)
	if [ "${enabled}" = "1" ]; then
		${scriptdir}/start_dcwapd.sh
	else
		echo "dcwapd is disabled in UCI"
		return 1
	fi
}

stop() {
        ${scriptdir}/stop_dcwapd.sh
	# Add a sleep after stopping because an immediate restat will fail otherwise
	sleep 1
}
