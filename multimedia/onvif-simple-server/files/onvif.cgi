#!/bin/sh

. /lib/functions.sh

config_load onvif-simple-server
config_get config main config_file /var/run/onvif-simple-server/config.json
config_get_bool enabled main enabled 1
if [ "$enabled" != 1 ] || [ ! -r "$config" ]; then
	printf 'Status: 503 Service Unavailable\r\nContent-Length: 0\r\n\r\n'
	exit 0
fi

service="${SCRIPT_NAME##*/}"
case "$service" in
	device_service|media_service|media2_service|imaging_service|deviceio_service|events_service|ptz_service) ;;
	*) printf 'Status: 404 Not Found\r\nContent-Length: 0\r\n\r\n'; exit 0 ;;
esac

export ONVIF_LOG_FILE=-
cd /usr/share/onvif-simple-server || exit 1
exec /usr/bin/onvif_simple_server -c "$config" "$service"
