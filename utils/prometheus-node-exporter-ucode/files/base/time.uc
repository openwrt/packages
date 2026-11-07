gauge("node_time_seconds", "System time in seconds since epoch (1970).")(null, time());

// based loosely on https://github.com/prometheus/node_exporter/blob/master/collector/time.go

const SDS_CLOCK_PATH = "/sys/devices/system/clocksource/";

const avail_gauge = gauge("node_time_clocksource_available_info",
	"Available clocksources read from '/sys/devices/system/clocksource'.");
const current_gauge = gauge("node_time_clocksource_current_info",
	"Current clocksource read from '/sys/devices/system/clocksource'.");

const current_sources = [];

for (let clock_src_path in fs.lsdir(SDS_CLOCK_PATH, "clocksource*")) {

	const csp_match = match(clock_src_path, /clocksource(\d+)/);
	if (!csp_match)
		continue;

	const sources = split(oneline(`${SDS_CLOCK_PATH}/${clock_src_path}/available_clocksource`), ' ');
	const current = oneline(`${SDS_CLOCK_PATH}/${clock_src_path}/current_clocksource`);
	const device = csp_match?.[1];

	for (let source in sources) {
		if (!source) continue;
		avail_gauge({ clocksource: source, device: `${device}` }, 1)
	}

	push(current_sources, { clocksource: current, device: `${device}` });
}

for (let cs in current_sources) {
	current_gauge(cs, 1);
}
