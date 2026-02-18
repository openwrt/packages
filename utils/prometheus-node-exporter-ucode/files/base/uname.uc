gauge("node_uname_info", "Labelled system information as provided by the uname system call.")({
	sysname:	oneline("/proc/sys/kernel/ostype"),
	nodename:	oneline("/proc/sys/kernel/hostname"),
	release:	oneline("/proc/sys/kernel/osrelease"),
	version:	oneline("/proc/sys/kernel/version"),
	machine:	oneline("/proc/sys/kernel/arch"),
	domainname:	oneline("/proc/sys/kernel/domainname"),
}, 1);
