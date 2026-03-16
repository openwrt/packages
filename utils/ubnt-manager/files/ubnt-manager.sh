#!/bin/sh

. /usr/share/libubox/jshn.sh
. /lib/functions.sh

log() {
    local msg="$1"
    logger -t ubnt-manager -s "$msg"
}

rexec() {
    local target="$1"
    local username="$2"
    local password="$3"
    local cmd="$4"
    raw=$(DROPBEAR_PASSWORD="$password" ssh -y "$username@$target" "$cmd" 2>/dev/null)
}

get_json_dump() {
    local cmd="/usr/www/status.cgi"
    rexec "$@" "$cmd"
    echo "$raw"
}

handle_device() {
    local device="${1//-/_}" # replace "-" with "_"
    config_load ubnt-manager
    config_get target "$device" target
    config_get username "$device" username
    config_get password "$device" password
}

add_device_to_list() {
    local device="$1"
    device_list="$device_list $device"
}

list_devices() {
    device_list=""
    config_load ubnt-manager
    config_foreach add_device_to_list device device_list
    echo "$device_list"
}

usage() {
    cat <<EOF
usage: ubnt-manager [command]
-j    | --json          Dump json info
-t    | --target        Target device
-l    | --list-devices  List all devices
-h    | --help          Brings up this menu
EOF
}

while [ "$1" != "" ]; do
    case $1 in
    -t | --target)
        shift
        target=$1
        handle_device "$target"
        ;;
    -j | --json)
        json=1
        ;;
    -l | --list-devices)
        list_devices
        ;;
    -h | --help)
        usage
        ;;
    esac
    shift
done

if [ -n "$json" ]; then
    get_json_dump "$target" "$username" "$password" | sed 's/Content-Type:\ application\/json//'
fi
