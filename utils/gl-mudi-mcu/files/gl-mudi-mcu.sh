#!/bin/sh

/etc/init.d/gl-mudi-mcu running || exit 0

wifi_get_all_stations() {
  for interface in `iwinfo | grep ESSID | cut -f 1 -s -d" "`
  do
    iwinfo $interface assoclist | grep dBm | cut -f 1 -s -d" "
  done
}

network_ubus_get_nwtype() {
  DEVICE="$1"
  case `ubus call network.device status | jsonfilter -e "@[\"$DEVICE\"].devtype"` in
    'wlan')
      echo repeater
      return 0
      ;;
    'wwan')
      echo modem
      return 0
      ;;
    'ethernet'|\
    *)
      echo cable
      return 0
      ;;
  esac
  return -1
}

# Clock
CLOCK=`date +%H:%M`

. /usr/share/libubox/jshn.sh

json_init
json_add_string "clock" "$CLOCK"

UCI_NETWORK=`uci show network`

# WiFi informations
WIFI_STATUS=`ubus -S call network.wireless status`
if [ -n "$WIFI_STATUS" ] ; then
  if [ "`echo $WIFI_STATUS | jsonfilter -e '@.radio1.up'`" = "true" ] ; then
    json_add_string "up" "1"
    json_add_string "ssid" `echo $WIFI_STATUS | jsonfilter -e '@.radio1.interfaces[0].config.ssid'`
    json_add_string "key" `echo $WIFI_STATUS | jsonfilter -e '@.radio1.interfaces[0].config.key'`
  else
    json_add_string "up" "0"
  fi

  if [ "`echo $WIFI_STATUS | jsonfilter -e '@.radio0.up'`" = "true" ] ; then
    json_add_string "up_5g" "1"
    json_add_string "ssid_5g" `echo $WIFI_STATUS | jsonfilter -e '@.radio0.interfaces[0].config.ssid'`
    json_add_string "key_5g" `echo $WIFI_STATUS | jsonfilter -e '@.radio0.interfaces[0].config.key'`
  else
    json_add_string "up_5g" "0"
  fi
fi

# Network informations
LAN_STATUS=`ubus -S call network.interface.lan status`
if [ -n "$LAN_STATUS" ]; then
  json_add_string "lan_ip" `echo $LAN_STATUS | jsonfilter -e '@["ipv4-address"][0].address'`
fi
DEVICE_STATUS=`ubus call network.device status`
DEFAULT_V4_GATEWAY_INTERFACE=`ip route | grep -m1 default | sed 's/^.*dev \([^[:space:]]\+\).*$/\1/g'`
DEFAULT_V6_GATEWAY_INTERFACE=`ip -6 route | grep -m1 default | sed 's/^.*dev \([^[:space:]]\+\).*$/\1/g'`
if [ -n "$DEFAULT_V4_GATEWAY_INTERFACE" ]; then
  json_add_string "method_nw" "`network_ubus_get_nwtype $DEFAULT_V4_GATEWAY_INTERFACE`|$DEFAULT_V4_GATEWAY_INTERFACE"
elif [ -n "$DEFAULT_V6_GATEWAY_INTERFACE" ]; then
  json_add_string "method_nw" "`network_ubus_get_nwtype $DEFAULT_V6_GATEWAY_INTERFACE`|$DEFAULT_V6_GATEWAY_INTERFACE"
fi
json_add_string "work_mode" "Router"
json_add_string "clients" `wifi_get_all_stations | wc -l`

if [ "`echo $DEVICE_STATUS | jsonfilter -q -e '@[@.devtype="wireguard"].up'`" = "true" ] ; then
  WG_INTERFACE=`uci show network | grep ".proto='wireguard'" | sed 's/^network\.\(.*\).proto=.*$/\1/g'`
  json_add_string "vpn_type" "wireguard"
  json_add_string "vpn_status" "connected"
  json_add_string "vpn_server" `uci get network.@wireguard_$WG_INTERFACE[0].description`
fi

# Modem Informations
if [ "`echo $DEVICE_STATUS | jsonfilter -q -e '@[@.devtype="wwan"].up'`" = "true" ] ; then
  # Currently detailed information is only supported in qmi
  MM_INTERFACE=`uci show network | grep ".proto='modemmanager'" | sed 's/^network\.\(.*\).proto=.*$/\1/g'`
  if [ -n "$MM_INTERFACE" ]; then
    MM_DEVICE=`uci get network.$MM_INTERFACE.device`
    MM_RESULT_JSON=`mmcli -m $MM_DEVICE --output-json`
    if [ "`echo $MM_RESULT_JSON | jsonfilter -q -e '@.modem.generic.state'`" = "connected" ] ; then
      json_add_string "modem_up" "1"

      PLMN_MCCMNC=`echo $MM_RESULT_JSON | jsonfilter -q -e '@.modem["3gpp"]["operator-code"]'`
      PLMN_DESC=`echo $MM_RESULT_JSON | jsonfilter -q -e '@.modem["3gpp"]["operator-name"]'`
      if [ -z "$PLMN_DESC" ]; then
        json_add_string "carrier" "$PLMN_MCCMNC"
      else
        json_add_string "carrier" "$PLMN_DESC"
      fi

      MM_SIGNAL_PERCENT=`echo $MM_RESULT_JSON | jsonfilter -q -e '@.modem.generic["signal-quality"].value'`
      if [ "$MM_SIGNAL_PERCENT" -gt "80" ]; then
        json_add_string "signal" "4"
      elif [ "$MM_SIGNAL_PERCENT" -gt "60" ]; then
        json_add_string "signal" "3"
      elif [ "$MM_SIGNAL_PERCENT" -gt "40" ]; then
        json_add_string "signal" "2"
      elif [ "$MM_SIGNAL_PERCENT" -gt "20" ]; then
        json_add_string "signal" "1"
      else
        json_add_string "signal" "0"
      fi

      SIGNAL_TYPE=`echo $MM_RESULT_JSON | jsonfilter -q -e '@.modem.generic["access-technologies"][0]'`
      case "$SIGNAL_TYPE" in
        gsm-umts)
          json_add_string "modem_mode" "3G"
          ;;
        lte)
          json_add_string "modem_mode" "4G"
          ;;
        5gnr)
          json_add_string "modem_mode" "4G+"
          ;;
        *)
          json_add_string "modem_mode" "2G"
          ;;
      esac
    else
      json_add_string "modem_up" "0"
    fi
  fi
  QMI_INTERFACE=`uci show network | grep ".proto='qmi'" | sed 's/^network\.\(.*\).proto=.*$/\1/g'`
  if [ -n "$QMI_INTERFACE" ]; then
    QMI_DEVICE=`uci get network.$QMI_INTERFACE.device`
    REGISTRATION_STATUS=`uqmi -t 1000 -d $QMI_DEVICE --get-serving-system`
    case `uqmi -t 1000 -d $QMI_DEVICE --uim-get-sim-state | jsonfilter -e '@.pin1_status'` in
      enabled)
        json_add_string "SIM" "PIN_SIM"
        ;;
      disabled)
        if [ "`echo $REGISTRATION_STATUS | jsonfilter -e '@.registration'`" != "registered" ]; then
          json_add_string "SIM" "NO_REG"
        fi
        ;;
      *)
        json_add_string "SIM" "NO_SIM"
    esac
    PLMN_MCC=`echo $REGISTRATION_STATUS | jsonfilter -e '@.plmn_mcc'`
    PLMN_MNC=`echo $REGISTRATION_STATUS | jsonfilter -e '@.plmn_mnc'`
    PLMN_DESC=`echo $REGISTRATION_STATUS | jsonfilter -e '@.plmn_description'`
    if [ -z "$PLMN_DESC" ]; then
      json_add_string "carrier" `printf "%03d%02d" $PLMN_MCC $PLMN_MNC`
    else
      json_add_string "carrier" "$PLMN_DESC"
    fi
    SIGNAL_STATUS=`uqmi -t 1000 -d $QMI_DEVICE --get-signal-info`
    SIGNAL_RSSI=`echo $SIGNAL_STATUS | jsonfilter -e '@.rssi'`
    SIGNAL_TYPE=`echo $SIGNAL_STATUS | jsonfilter -e '@.type'`
    if [ "$SIGNAL_RSSI" -gt "-65" ]; then
      json_add_string "signal" "4"
    elif [ "$SIGNAL_RSSI" -gt "-75" ]; then
      json_add_string "signal" "3"
    elif [ "$SIGNAL_RSSI" -gt "-85" ]; then
      json_add_string "signal" "2"
    elif [ "$SIGNAL_RSSI" -gt "-95" ]; then
      json_add_string "signal" "1"
    else
      json_add_string "signal" "0"
    fi

    case "$SIGNAL_TYPE" in
      wcdma)
        json_add_string "modem_mode" "3G"
        ;;
      lte)
        json_add_string "modem_mode" "4G"
        ;;
      nr)
        json_add_string "modem_mode" "4G+"
        ;;
      *)
        json_add_string "modem_mode" "2G"
        ;;
    esac
  fi

  json_add_string "modem_up" "1"
else
  json_add_string "modem_up" "0"
fi

if [ -n "$1" ]; then
  json_add_string "msg" "$1"
fi

json_dump > /dev/ttyS0
