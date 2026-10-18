# Write pending data before sysupgrade saves the configuration (sourced by /sbin/sysupgrade).
routelink_commit() {
	ubus -t 10 call routelink commit >/dev/null 2>&1
	return 0
}

append sysupgrade_init_conffiles "routelink_commit"
