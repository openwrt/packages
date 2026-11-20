
const metric_chip_names = gauge("node_hwmon_chip_names", "Annotation metric for human-readable chip names");
const metric_sensor_label = gauge("node_hwmon_sensor_label", "Label for given chip and sensor");
const metric_temp_celsius = gauge("node_hwmon_temp_celsius", "Hardware monitor for temperature (input)");
const metric_temp_crit_alarm_celsius = gauge("node_hwmon_temp_crit_alarm_celsius", "Hardware monitor for temperature (crit_alarm)");
const metric_temp_crit_celsius = gauge("node_hwmon_temp_crit_celsius", "Hardware monitor for temperature (crit)");
const metric_temp_max_celsius = gauge("node_hwmon_temp_max_celsius", "Hardware monitor for temperature (max)");
const metric_pwm = gauge("node_hwmon_pwm", "Pulse Width Modulation control");

const hwmon_paths = [];
const chip_names = [];

const SC_HWMON_PATH = "/sys/class/hwmon/";

for (let hwmon_path in fs.lsdir(SC_HWMON_PATH, "hwmon*")) {
	const full_path = `${SC_HWMON_PATH}${hwmon_path}`;
	push(hwmon_paths, full_path);

	// Produce node_hwmon_chip_names
	// See https://github.com/prometheus/node_exporter/blob/7c564bcbeffade3dacac43b07c2eeca4957ca71d/collector/hwmon_linux.go#L415
	const chip_name = oneline(`${full_path}/name`) || hwmon_path;

	// See https://github.com/prometheus/node_exporter/blob/7c564bcbeffade3dacac43b07c2eeca4957ca71d/collector/hwmon_linux.go#L355
	let chip = chip_name;
	const real_dev_path = fs.realpath(`${full_path}/device`);

	if (real_dev_path) {
		const dev_name = fs.basename(real_dev_path);
		const dev_type = fs.basename(fs.dirname(real_dev_path));

		chip = `${dev_type}_${dev_name}`;

	}
	push(chip_names, chip);

	metric_chip_names({ chip: chip, chip_name: chip_name }, 1);
}

map(hwmon_paths, function(path, index) {
	for (let sensor_path in fs.lsdir(path, "*_label")) {
		// Produce node_hwmon_sensor_label
		if (match(sensor_path, /_label$/)) {

			const sensor = rtrim(sensor_path, "_label");
			const sensor_label = oneline(`${path}/${sensor_path}`);

			metric_sensor_label({ chip: chip_names[index], sensor: sensor, label: sensor_label }, 1);

		}
	}
});

function check_sensor_type(path, ST, chip) {
	for (let sensor_path in fs.lsdir(path, ST.regex)) {
		const sensor = ST.suffix ? rtrim(sensor_path, ST.suffix) : sensor_path;
		let raw = oneline(`${path}/${sensor_path}`);
		if (raw == null) continue;

		const value = ST.transform(raw);
		ST.metric({ chip, sensor }, value);
	}
}

/* Use multiple map(hwmon_paths) instances to guarantee ordering by metric
 * and not ordering by device */
map(hwmon_paths, function(path, index) {
	check_sensor_type(path, {
		regex: /^temp\d+_input$/,
		suffix: "_input",
		metric: metric_temp_celsius,
		transform: v => v * 0.001,
	}, chip_names[index]);
});

map(hwmon_paths, function(path, index) {
	check_sensor_type(path, {
		regex: /^temp\d+_crit_alarm$/,
		suffix: "_crit_alarm",
		metric: metric_temp_crit_alarm_celsius,
		transform: v => v * 0.001,
	}, chip_names[index]);
});

map(hwmon_paths, function(path, index) {
	check_sensor_type(path, {
		regex: /^temp\d+_crit$/,
		suffix: "_crit",
		metric: metric_temp_crit_celsius,
		transform: v => v * 0.001,
	}, chip_names[index]);

});

map(hwmon_paths, function(path, index) {
	check_sensor_type(path, {
		regex: /^temp\d+_max$/,
		suffix: "_max",
		metric: metric_temp_max_celsius,
		transform: v => v * 0.001,
	}, chip_names[index]);
});

map(hwmon_paths, function(path, index) {
	check_sensor_type(path, {
		regex: /^pwm\d+$/,
		suffix: "",
		metric: metric_pwm,
		transform: v => v,
	}, chip_names[index]);
});
