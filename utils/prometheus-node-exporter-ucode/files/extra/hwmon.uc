
const metric_chip_names = gauge("node_hwmon_chip_names", "Annotation metric for human-readable chip names");
const metric_sensor_label = gauge("node_hwmon_sensor_label", "Label for given chip and sensor");
const metric_temp_celsius = gauge("node_hwmon_temp_celsius", "Hardware monitor for temperature");
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

// for (let path in hwmon_paths) {
map(hwmon_paths, function(path, index) {
	for (let sensor_path in fs.lsdir(path, "temp*_input")) {

		// Produce node_hwmon_temp_celsius
		if (match(sensor_path, /^temp\d+_input$/)) {

			const sensor = rtrim(sensor_path, "_input");
			const temp = oneline(`${path}/${sensor_path}`) / 1000.00;

			metric_temp_celsius({ chip: chip_names[index], sensor: sensor }, temp);

		}
	}
});

map(hwmon_paths, function(path, index) {
	for (let sensor_path in fs.lsdir(path, "pwm*")) {

		// Produce node_hwmon_pwm
		if (match(sensor_path, /^pwm[0-9]+$/)) {

			const pwm = oneline(`${path}/${sensor_path}`);

			metric_pwm({ chip: chip_names[index], sensor: sensor_path }, pwm);

		}
	}
});
