'use strict';

// Self-contained regression test for the textfile collector.
// Creates a temp dir with .prom files via the real fs module, mocks
// gauge/raw, loads files/extra/textfile.uc and asserts the output.

import * as fs from "fs";

let failures = 0;

function fail(msg) {
	warn("FAIL: ", msg, "\n");
	failures++;
}

function check(cond, msg) {
	if (!cond)
		fail(msg);
}

const dir = "/tmp/prom-tf-test-" + clock()[0];
fs.mkdir(dir);
fs.writefile(dir + "/a.prom", "# HELP my_metric_total A counter\n# TYPE my_metric_total counter\nmy_metric_total 42\n");
fs.writefile(dir + "/b.prom", "# HELP second Something\n# TYPE second gauge\nsecond{label=\"x\"} 1\n");
fs.writefile(dir + "/ignored.txt", "ignored\n");

const config = { directory: dir };

let emitted = [];
let rawbuf = "";

const gauge = function(name, help) {
	return function(labels, value) {
		push(emitted, { name: name, labels: labels, value: value });
	};
};
const counter = gauge;
const raw = function(s) {
	rawbuf += s;
};

let func = loadfile("./files/extra/textfile.uc", { strict_declarations: true, raw_mode: true });
if (!func) {
	warn("failed to load textfile.uc\n");
	exit(1);
}

if (call(func, null, { config, fs, gauge, counter, raw }) == false)
	fail("collector returned false");

// mtime metrics for both .prom files, sorted
check(length(emitted) == 2, "expected 2 mtime metrics, got " + length(emitted));
if (length(emitted) == 2) {
	check(emitted[0].name == "node_textfile_mtime_seconds" &&
	      emitted[0].labels["file"] == "a.prom", "a.prom mtime first");
	check(emitted[1].labels["file"] == "b.prom", "b.prom mtime second");
	check(emitted[0].value > 0, "mtime value positive");
}

// raw passthrough of both .prom files, non-.prom ignored
check(index(rawbuf, "# HELP my_metric_total") >= 0, "a.prom raw content");
check(index(rawbuf, "my_metric_total 42") >= 0, "a.prom metric");
check(index(rawbuf, "second{label=\"x\"} 1") >= 0, "b.prom metric");
check(index(rawbuf, "ignored") < 0, "non-.prom file ignored");

if (failures) {
	warn(failures + " assertion(s) failed\n");
	exit(1);
}

print("textfile test OK\n");
