if [ "$ACTION" = add ]; then
	for dev in `ls /sys/class/net`; do
		[ -d "/sys/class/net/$dev" ] || continue
		ethtool -K $dev rx-gro-list off 2>/dev/null
	done
fi
