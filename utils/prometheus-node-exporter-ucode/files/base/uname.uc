gauge("node_uname_info")({
	sysname:	oneline("/proc/sys/kernel/ostype"),
	nodename:	oneline("/proc/sys/kernel/hostname"),
	release:	oneline("/proc/sys/kernel/osrelease"),
	version:	oneline("/proc/sys/kernel/version"),
	machine:	poneline("uname -m"), // TODO lame
	domainname:	oneline("/proc/sys/kernel/domainname"),
}, 1);
