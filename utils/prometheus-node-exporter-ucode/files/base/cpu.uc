let f = fs.open("/proc/stat");

if (!f)
	return false;

const desc = [
	null,
	"user",
	"nice",
	"system",
	"idle",
	"iowait",
	"irq",
	"softirq",
	"steal",
	"guest",
	"guest_nice",
];
const m_cpu = counter("node_cpu_seconds_total");

let line;
while (line = nextline(f)) {
	const x = wsplit(line);

	if (length(x) < 2)
		continue;

	if (match(x[0], /^cpu\d+/)) {
		const count = min(length(x), length(desc));
		for (let i = 1; i < count; i++)
			m_cpu({ cpu: x[0], mode: desc[i] }, x[i] / 100.0);
	} else if (x[0] == "intr")
		counter("node_intr_total")(null, x[1]);
	else if (x[0] == "ctxt")
		counter("node_context_switches_total")(null, x[1]);
	else if (x[0] == "btime")
		gauge("node_boot_time_seconds")(null, x[1]);
	else if (x[0] == "processes")
		counter("node_forks_total")(null, x[1]);
	else if (x[0] == "procs_running")
		gauge("node_procs_running_total")(null, x[1]);
	else if (x[0] == "procs_blocked")
		gauge("node_procs_blocked_total")(null, x[1]);
}
