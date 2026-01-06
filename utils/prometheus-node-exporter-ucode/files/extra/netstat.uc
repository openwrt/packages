function parse(fn) {
	let f = fs.open(fn);

	if (!f)
		return false;

	let names, values;
	while (names = nextline(f), values = nextline(f)) {
		const name = wsplit(names);
		const value = wsplit(values);

		if (name[0] != value[0])
			continue;

		if (length(name) != length(value))
			continue;

		let prefix = substr(name[0], 0, -1);
		for (let i = 1; i < length(name); i++)
			gauge(`node_netstat_${prefix}_${name[i]}`)(null, value[i]);
	}

	return true;
}

let n = parse("/proc/net/netstat");
let s = parse("/proc/net/snmp");

if (!n && !s)
	return false;
