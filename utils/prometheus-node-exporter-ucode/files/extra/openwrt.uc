const x = ubus.call("system", "board");

if (!x)
	return false;

gauge("node_openwrt_info")({
	board_name:	x.board_name,
	id:		x.release.distribution,
	model:		x.model,
	release:	x.release.version,
	revision:	x.release.revision,
	system:		x.system,
	target:		x.release.target,
}, 1);
