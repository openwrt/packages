
# Everything is done by zabbix_helper_mac80211 now
export PATH=$PATH:/lib/zabbix/mac80211/

zhm () {
	zabbix_helper_mac80211 $@
}

