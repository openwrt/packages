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
        option plmn        '214001'
        option lowpower    '1'
        option signalrate  '30'
        option allow_roaming '1'
        option force_connection '1'
        option init_epsbearer '<modem|network|connection|custom>'
        option timeout     '120'

Only 'device' and 'proto' are mandatory options, the remaining ones are all
optional.

The 'allowedauth' option allows limiting the list of authentication protocols.
It is given as a space-separated list of values, including any of the
following: 'pap', 'chap', 'mschap', 'mschapv2' or 'eap'. It will default to
allowing all protocols.

The 'iptype' option supports any of these values: 'ipv4', 'ipv6' or 'ipv4v6'.
It will default to 'ipv4' if not given.

The 'plmn' option allows to set the network operator MCCMNC.

The 'signalrate' option set's the signal refresh rate (in seconds) for the device.
You can call signal info with command: mmcli -m 0 --signal-get

The 'timeout' option set's the command timeout (in seconds) for the long
running 'mmcli' calls ('enable', 'simple-connect',
3gpp-register-in-operator' and '3gpp-set-initial-eps-bearer-settings')
in the modemmanager protohandler. The default value is 120 seconds, if
no value is configured.

The 'force_connection' option is designed to ensure that the modem automatically
attempts to reconnect regardless of any errors encountered during the
connection process.

On 4G and 5G networks, the modem attaches to the network with an initial
EPS bearer, before the data connection is established. The 'init_epsbearer'
option selects where the settings for this initial EPS bearer come from:
* modem:      Leave the initial EPS bearer settings stored on the modem
              unchanged (default). These are usually provided by the carrier
              firmware or set by a previous configuration.
* network:    Set an empty initial EPS bearer, so the network assigns the APN.
              Use this to override settings left on the modem, e.g. after
              swapping the SIM card.
* connection: Use the options 'apn', 'iptype', 'allowedauth', 'username' and
              'password', the same options as for the data connection.
* custom:     Use separate options, prefixed with 'init_': 'init_apn',
              'init_iptype', 'init_allowedauth', 'init_username' and
              'init_password'.

The values 'none' and 'default' are deprecated aliases for 'modem' and
'connection'.

The initial EPS bearer settings stored on the modem can also be cleared once
manually:

    mmcli -m <modem> --3gpp-set-initial-eps-bearer-settings=""
