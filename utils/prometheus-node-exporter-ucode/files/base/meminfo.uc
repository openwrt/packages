let f = fs.open("/proc/meminfo");

if (!f)
	return false;

let line;
while (line = nextline(f)) {
	const x = wsplit(line);

	if (length(x) < 2)
		continue;

	if (substr(x[0], -1) != ":")
		continue;

	let name;
	if (substr(x[0], -2) == "):")
		name = replace(substr(x[0], 0, -2), "(", "_");
	else
		name = substr(x[0], 0, -1);

	gauge(`node_memory_${name}_bytes`)
		(null, x[2] == "kB" ? x[1] * 1024 : x[1]);
}
