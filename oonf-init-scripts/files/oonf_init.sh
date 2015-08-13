#!/bin/sh

. /usr/share/libubox/jshn.sh

oonf_log()
{
  logger -s -t ${DAEMON} -p daemon.info "${1}"
}

oonf_get_layer3_device()
{
  local interface="${1}"  # e.g. 'mywifi'
  local status dev proto
  local query="{ \"interface\" : \"${interface}\" }"

  status="$( ubus -S call network.interface status "${query}" )" && {
    json_load "${status}"
    json_get_var 'dev' l3_device
    json_get_var 'proto' proto
    case "${proto}" in
      pppoe)
        # TODO: otherwise it segfaults
        oonf_log "refusing to add '$interface', because of proto '${proto}'"
      ;;
      *)
        echo "${dev}" # e.g. 'wlan0-1'
      ;;
    esac
  }
}

oonf_add_devices_to_configuration()
{
  local i=0
  local device_name= section= interface= single_interface=

  # make a copy of configuration and
  # add a 'name' (physical name) for all
  # 'interface-names' (e.g. mywifi)
  #
  # olsrd2.@interface[2]=interface
  # olsrd2.@interface[2].ifname='wan lan wlanadhoc wlanadhocRADIO1'

  # /var is in ramdisc/tmpfs
  uci export ${DAEMON} >"/var/run/${DAEMON}_dev"

  while section="$( uci -q -c /etc/config get "${DAEMON}.@[${i}]" )"; do {
    echo "section: ${section}"

    interface="$( uci -q -c /etc/config get "${DAEMON}.@[${i}].ifname" )" || {
      i=$(( i + 1 ))
      continue
    }

    case "$( uci -q get "${DAEMON}.@[${i}].ignore" )" in
      1|on|true|enabled|yes)
        oonf_log "removing/ignore section '$section'"
        uci -q -c /var/run delete "${DAEMON}_dev.@[${j}]"
        i=$(( i + 1 ))

        continue
      ;;
    esac

    for single_interface in ${interface}; do {
      device_name="$( oonf_get_layer3_device "${single_interface}" )"

      echo "Interface: ${single_interface} = ${device_name}"

      if [ ! -z "${device_name}" ]
      then
        # add option 'name' for 'ifname' (e.g. 'mywifi')
        uci -q -c /var/run add_list "${DAEMON}_dev.@[${i}].name=${device_name}"
      fi
    } done
    i=$(( $i + 1 ))
  } done

  uci -q -c /var/run commit "${DAEMON}_dev"

  oonf_log "wrote '/var/run/${DAEMON}_dev'"
}

oonf_reread_config()
{
  local pid
  local pidfile="/var/run/${DAEMON}.pid"

  if   [ -e "${pidfile}" ]; then
    read pid <"${pidfile}"
  elif pidfile="$( uci -q get "${DAEMON}.@global[0].pidfile" )"; then
    read pid <"${pidfile}"
  fi

  # if empty, ask kernel
  pid="${pid:-$( pidof ${DAEMON} )}"

  [ -n "${pid}" ] && kill -SIGHUP ${pid}
}

start()
{
  oonf_add_devices_to_configuration

  # produce coredumps
  ulimit -c unlimited

  service_start /usr/sbin/${DAEMON} --set global.fork=true --load uci:///var/run/${DAEMON}_dev
}

stop()
{
  service_stop /usr/sbin/${DAEMON}
}

reload()
{
  oonf_add_devices_to_configuration
  oonf_reread_config
}
