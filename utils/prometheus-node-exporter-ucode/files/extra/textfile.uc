// Serves the Prometheus text exposition files (*.prom) of a directory
// verbatim, like the textfile collector of the upstream node_exporter. This
// lets cron jobs and scripts publish metrics without a dedicated collector.

const dir = config.directory || "/var/run/prometheus/textfile";

let files = fs.lsdir(dir, "*.prom");
if (!files)
	return false;

sort(files);

let m_mtime = gauge("node_textfile_mtime_seconds",
	"Unix time of the last modification of a textfile collector file");

for (let name in files) {
	let path = dir + "/" + name;

	let st = fs.stat(path);
	if (st?.mtime != null)
		m_mtime({ file: name }, st.mtime);

	let content = fs.readfile(path);
	if (content != null)
		raw(rtrim(content, "\n"));
}
