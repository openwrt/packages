let f = fs.open("/proc/net/nf_conntrack");
if (!f)
	return false;

let nat = {};
let nat_metric = gauge("node_nat_traffic");

let line;
while ((line = nextline(f)) != null) {
	const fields = wsplit(line);
	let src, dst;
	let bytes = 0;

	for (let field in fields) {
		if (src == null && substr(field, 0, 4) == "src=")
			src = substr(field, 4);
		else if (dst == null && substr(field, 0, 4) == "dst=")
			dst = substr(field, 4);
		else if (substr(field, 0, 6) == "bytes=")
			bytes += +substr(field, 6);
	}

	if (src == null || dst == null)
		continue;

	if (nat[src] == null)
		nat[src] = {};

	nat[src][dst] = (nat[src][dst] || 0) + bytes;
}

f.close();

for (let src in nat)
	for (let dst in nat[src])
		nat_metric({ src, dst }, nat[src][dst]);
