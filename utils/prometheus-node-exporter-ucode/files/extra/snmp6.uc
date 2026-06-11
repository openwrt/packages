function parse(fn, device, skipdecl) {
	let f = fs.open(fn);

	if (!f)
		return false;

	const labels = { device };
	let line;
	while (line = nextline(f)) {
		const x = wsplit(line);

		if (length(x) < 2)
			continue;

		counter(`snmp6_${x[0]}`, null, skipdecl)(labels, x[1]);
	}
}

parse("/proc/net/snmp6", "all");

const root = "/proc/net/dev_snmp6/";
for (let device in fs.lsdir(root))
	parse(root + device, device, true);
