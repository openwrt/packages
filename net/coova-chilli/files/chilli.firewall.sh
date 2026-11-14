#!/bin/sh
# firewall4 calls this after applying nft, while holding its own lock.
# Never call fw4 (or restart chilli) here: only synchronize the loaded chains.
. /usr/share/coova-chilli/fw4.sh
{
	flock -x 9
	chilli_fw4_sync || chilli_fw4_warn 'chilli firewall post-apply synchronization failed'
} 9>/tmp/.chilli-flock
exit 0
