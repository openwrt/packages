{%
'use strict';

import * as fs from "fs";
import { connect } from "ubus";
import { cursor } from "uci";

function debug(...s) {
	if (global.debug)
		warn("DEBUG: ", ...s, "\n");
}

function puts(...s) {
	return uhttpd.send(...s, "\n");
}

function govalue(value) {
	if (value == Infinity)
		return "+Inf";
	else if (value == -Infinity)
		return "-Inf";
	else if (value != value)
		return "NaN";
	else if (type(value) in [ "int", "double" ])
		return value;
	else if (type(value) in [ "bool", "string" ])
		return +value;

	return null;
}

function metric(name, mtype, help, skipdecl) {
	let func;
	let decl = skipdecl == true ? false : true;

	let yield = function(labels, value) {
		let v = govalue(value);

		if (v == null) {
			debug(`skipping metric: unsupported value '${value}' (${name})`);
			return func;
		}

		let labels_str = "";
		if (length(labels)) {
			let sep = "";
			let s;
			labels_str = "{";
			for (let l in labels) {
				if (labels[l] == null)
					s = "";
				else if (type(labels[l]) == "string") {
					s = labels[l];
					s = replace(labels[l], "\\", "\\\\");
					s = replace(s, "\"", "\\\"");
					s = replace(s, "\n", "\\n");
				} else {
					s = govalue(labels[l]);

					if (!s)
						continue;
				}

				labels_str += sep + l + "=\"" + s + "\"";
				sep = ",";
			}
			labels_str += "}";
		}

		if (decl) {
			if (help)
				puts("# HELP ", name, " ", help);
			puts("# TYPE ", name, " ", mtype);
			decl = false;
		}

		puts(name, labels_str, " ", v);
		return func;
	};

	func = yield;
	return func;
}

function counter(name, help, skipdecl) {
	return metric(name, "counter", help, skipdecl);
}

function gauge(name, help, skipdecl) {
	return metric(name, "gauge", help, skipdecl);
}

function httpstatus(status) {
	puts("Status: ", status, "\nContent-Type: text/plain; version=0.0.4; charset=utf-8\n");
}

function clockdiff(t1, t2) {
	return (t2[0] - t1[0]) * 1000000000 + t2[1] - t1[1];
}

let collectors = {};

global.handle_request = function(env) {
	let scope = {
		config: null,
		fs,
		ubus: connect(),
		counter,
		gauge,
		wsplit: function(line) {
			return split(line, /\s+/);
		},
		nextline: function(f) {
			return rtrim(f.read("line"), "\n");
		},
		oneline: function(fn) {
			let f = fs.open(fn);

			if (!f)
				return null;

			return nextline(f);
		},
		poneline: function(cmd) {
			let f = fs.popen(cmd);

			if (!f)
				return null;

			return nextline(f);
		},
	};

	if (length(collectors) < 1) {
		httpstatus("404 No Collectors found");
		return;
	}

	let cols = [];
	for (let q in split(env.QUERY_STRING, "&")) {
		let s = split(q, "=", 2);
		if (length(s) == 2 && s[0] == "collect") {
			if (!(s[1] in collectors)) {
				httpstatus(`404 Collector ${s[1]} not found`);
				return;
			}

			push(cols, s[1]);
		}
	}

	if (length(cols) > 0)
		cols = uniq(cols);
	else
		cols = keys(collectors);

	httpstatus("200 OK");

	let duration = gauge("node_scrape_collector_duration_seconds");
	let success = gauge("node_scrape_collector_success");

	for (let col in cols) {
		let ok = false;
		let t1, t2;

		scope["config"] = collectors[col].config;
		t1 = clock(true);
		try {
			ok = call(collectors[col].func, null, scope) != false;
		} catch(e) {
			warn(`error running collector '${col}':\n${e.message}\n`);
		}
		t2 = clock(true);

		duration({ collector: col }, clockdiff(t1, t2) / 1000000000.0);
		success({ collector: col }, ok);
	}
};

const lib = "/usr/share/ucode/node-exporter/lib";
const opts = {
	strict_declarations:	true,
	raw_mode:		true,
};

let cols = fs.lsdir(lib, "*.uc");
for (let col in cols) {
	let func;
	let uci = cursor();

	try {
		func = loadfile(lib + "/" + col, opts);
	} catch(e) {
		warn(`error compiling collector '${col}':\n${e.message}\n`);
		continue;
	}

	let name = substr(col, 0, -3);
	let config = uci.get_all("prometheus-node-exporter-ucode", name);
	if (!config || config[".type"] != "collector")
		config = {};
	else {
		delete config[".anonymous"];
		delete config[".type"];
		delete config[".name"];
	}

	collectors[name] = {
		func,
		config,
	};
}

warn(`prometheus-node-exporter-ucode now serving requests with ${length(collectors)} collectors\n`);

if (!("uhttpd" in global)) {
	global.debug = true;

	puts = function(...s) {
		return print(...s, "\n");
	};

	handle_request({
		QUERY_STRING: join("&", map(ARGV, v => "collect=" + v)),
	});
}
%}
