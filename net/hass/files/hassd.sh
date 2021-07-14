#!/bin/sh
# todo: hostapd white (black) list so we don't have to listen to all APs

source /lib/functions.sh
config_load hass

logger -t $0 -p info "Starting up"

source /usr/lib/hass/functions.sh

logger -t $0 -p info "Hooking onto existing interfaces"
for interface in `iw dev | grep Interface | cut -f 2 -s -d" "`
do
    register_hook $interface
done

sync_state

# will run in subshell
ubus listen ubus.object.add | \
while read line ; do
    interface=$(echo "$line" | grep -oP '"path":"hostapd\.\K[^"]*(?="\} \}$)')
    if [ $? = 0 ]
    then
        logger -t $0 -p info "$interface is up, setting up hook"
        register_hook $interface
    fi
        
done
