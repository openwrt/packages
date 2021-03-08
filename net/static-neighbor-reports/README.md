# static-neighbor-reports
The `static-neighbor-reports` package allows a user to configure static neighbor reports which
are available for clients to be polled in case they support IEEE802.11k. This greatly improves
the wireless experiences in terms of mobility.

Make sure to enable `ieee80211k` for each VAP neighbor reports should be installed to.

## Configuring
The uci config name is `static-neighbor-report`. There's currently only the section
type `neighbor`.

### neighbor
The followign options are supported for `neighbor` sections:

#### neighbor_report
This is the binary neighbor report element from a foreign AP. It is required for each neighbor.

#### disabled
Values other than `0` disable the neighbor. It won't be installed into hostapd in this case.
If this option is missing, the neighbor is implicitly active.

#### bssid
The BSSID of the foreign AP. This option can usually be omitted, as it's implicitly present in
the first 6 bytes of the binary neighbor report element.

#### ssid
The SSID of the foreign AP. This option can be omitted, in case it matches the SSID used on the local AP.

#### iface
Space seperated list of hostapd interfaces the neighbor should be installed to.

## Retrieving neighbor information
To retrieve the neighbor informations of an AP to be isntalled on a foreign AP, make sure the UCI option
`ieee80211k` is set to `1` on the VAP.

Execute `ubus call hostapd.<ifname> rrm_nr_get_own` on the AP. To get a list of all available interfaces,
execute `ubus list`.

The returned information  follows this format:

```json
{
    "value": [
        "<BSSID>",
        "<SSID>",
        "<Neighbot report element>"
    ]
}
```
