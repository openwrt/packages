# OpenWrt ModemManager

## Description

Cellular modem control and connectivity

Optional libraries libmbim and libqmi are available.  Optional mbim-utils and qmi-utils are available.
Your modem may require additional kernel modules.

## Usage

# Once installed, you can configure the 2G/3G/4G modem connections directly in
   /etc/config/network as in the following example:

    config interface 'broadband'
        option device   '/sys/devices/platform/soc/20980000.usb/usb1/1-1/1-1.2/1-1.2.1'
        option proto    'modemmanager'
        option apn      'ac.vodafone.es'
        option username 'vodafone'
        option password 'vodafone'
        option pincode  '7423'
        option lowpower '1'
