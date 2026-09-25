'use strict';

import * as real_fs from "fs";

const fixture = "./test/fixtures/nf_conntrack";
const collector_path = "./files/extra/nat_traffic.uc";

// Capture metric emissions
let metrics = {};

function gauge(name) {
	let func;
	func = function(labels, value) {
		let key = name;
		if (labels && length(labels)) {
			let parts = [];
			for (let k in labels)
				push(parts, k + '="' + labels[k] + '"');
			key += "{" + join(",", parts) + "}";
		}
		metrics[key] = value;
		return func;
	};
	return func;
}

// Redirect /proc/net/nf_conntrack to fixture file
const fs = {
	open: function(path) {
		if (path == "/proc/net/nf_conntrack")
			return real_fs.open(fixture);
		return real_fs.open(path);
	}
};

function wsplit(line) {
	return split(line, /\s+/);
}

function nextline(f) {
	return rtrim(f.read("line"), "\n");
}

let func;
try {
	func = loadfile(collector_path, { strict_declarations: true, raw_mode: true });
} catch(e) {
	die("Failed to load collector: " + e.message + "\n");
}

if (call(func, null, { fs, gauge, wsplit, nextline, config: {} }) == false)
	die("Collector returned false — is the fixture file missing?\n");

// Assertions
let passed = 0;
let failed = 0;

function assert_eq(key, expected) {
	const actual = metrics[key];
	if (actual == expected) {
		print("PASS: " + key + " == " + expected + "\n");
		passed++;
	} else {
		print("FAIL: " + key + ": expected " + expected + ", got " + actual + "\n");
		failed++;
	}
}

// line1 (1234+5678=6912) + line2 (100+200=300) share same src/dst => aggregated to 7212
assert_eq('node_nat_traffic{src="192.168.1.2",dst="1.2.3.4"}', 7212);
// line3 (300+400=700)
assert_eq('node_nat_traffic{src="192.168.1.3",dst="1.2.3.4"}', 700);
// line4 (60+120=180)
assert_eq('node_nat_traffic{src="192.168.1.2",dst="8.8.8.8"}', 180);

print("\n" + passed + " passed, " + failed + " failed\n");
exit(failed > 0 ? 1 : 0);
