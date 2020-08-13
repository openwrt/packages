# OpenWrt ModemManager

## Description

Cellular modem control and connectivity

Optional libraries libmbim and libqmi are available.
Your modem may require additional kernel modules and/or the usb-modeswitch
package.

## Usage

Once installed, you can configure the 2G/3G/4G modem connections directly in
/etc/config/network as in the following example:

    config interface 'broadband'
        option device      '/sys/devices/platform/soc/20980000.usb/usb1/1-1/1-1.2/1-1.2.1'
        option proto       'modemmanager'
        option apn         'ac.vodafone.es'
        option allowedauth 'pap chap'
        option username    'vodafone'
        option password    'vodafone'
        option pincode     '7423'
        option iptype      'ipv4'
        option lowpower    '1'
        option signalrate  '30'

Only 'device' and 'proto' are mandatory options, the remaining ones are all
optional.

The 'allowedauth' option allows limiting the list of authentication protocols.
It is given as a space-separated list of values, including any of the
following: 'pap', 'chap', 'mschap', 'mschapv2' or 'eap'. It will default to
allowing all protocols.

The 'iptype' option supports any of these values: 'ipv4', 'ipv6' or 'ipv4v6'.
It will default to 'ipv4' if not given.

The 'signalrate' option set's the signal refresh rate (in seconds) for the device.
You can call signal info with command: mmcli -m 0 --signal-get
