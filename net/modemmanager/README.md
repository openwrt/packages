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

   Option descriptions
   device - The full sysfs path to the device you want netifd to configure using modemmanager. Not optional
   proto - The protocol handler you want netifd to use, in this case 'modemmanager' is the only appropriate value.
   apn - an optional parameter to specify which access point name you want the modem to connect to. If omitted, the behavior you get is modem specific. Some modems auto connect to an appropriate access point based on the SIM card.
   pincode - the PIN code needed to unlock the SIM, if any.
   lowpower - request that the modem operate in low power mode.
