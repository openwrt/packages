{%
//------------------------------------------------------------------------------
// Copyright (c) 2023-2024 Eric Fahlgren <eric.fahlgren@gmail.com>
// SPDX-License-Identifier: GPL-2.0
//
// The tables defined using 'config_item' are the source of record for the
// configuration file, '/etc/config/snort'.  If you wish to add new items,
// do that only in the tables and propagate that use into the templates.
//
//------------------------------------------------------------------------------

QUIET; // Reference globals passed from CLI, so we get errors when missing.
TYPE;

import { cursor } from 'uci';
let uci = cursor();

function wrn(fmt, ...args) {
	if (QUIET)
		exit(1);

	let msg = "ERROR: " + sprintf(fmt, ...args);

	if (getenv("TTY"))
		warn(`\033[33m${msg}\033[m\n`);
	else
		warn(`[!] ${msg}\n`);
	exit(1);
}

function rpad(str, fill, len)
{
	str = rtrim(str) + ' ';
	while (length(str) < len) {
		str += fill;
	}
	return str;
}

//------------------------------------------------------------------------------

const ConfigItem = {
	contains: function(value) {
		// Check if the value is contained in the listed values,
		// depending on the item type.
		switch (this.type) {
		case "enum":
			return value in this.values;
		case "range":
			return value >= this.values[0] && value <= this.values[1];
		default:
			return true;
		}
	},

	allowed: function() {
		// Show a pretty version of the possible values, for error messages.
		switch (this.type) {
		case "enum":
			return "one of [" + join(", ", this.values) + "]";
		case "range":
			return `${this.values[0]} <= x <= ${this.values[1]}`;
		case "path":
			return "a path string";
		case "str":
			return "a string";
		default:
			return "???";
		}
	},
};

function config_item(type, values, def) {
	// If no default value is provided explicity, then values[0] is used as default.
	if (! type in [ "enum", "range", "path", "str" ]) {
		wrn(`Invalid item type '${type}', must be one of "enum", "range", "path" or "str".`);
		return;
	}
	if (type == "enum") {
		// Convert values to strings, so 'in' works in 'contains'.
		values = map(values, function(i) { return "" + i; });
	}
	if (type == "range" && (length(values) != 2 || values[0] > values[1])) {
		wrn(`A 'range' type item must have exactly 2 values in ascending order.`);
		return;
	}
	// Maybe check 'path' values for existence???
		
	return proto({
		type:     type,
		values:   values,
		default:  def ?? values[0],
	}, ConfigItem);
};

const snort_config = {
	enabled:         config_item("enum",  [ 0, 1 ], 0),         // Defaults to off, so that user must configure before first start.
	manual:          config_item("enum",  [ 0, 1 ], 1),         // Allow user to manually configure, legacy behavior when enabled.
	oinkcode:        config_item("str",   [ "" ]),              // User subscription oinkcode.  Much more in 'snort-rules' script.
	home_net:        config_item("str",   [ "" ], "192.168.1.0/24"),
	external_net:    config_item("str",   [ "" ], "any"),

	config_dir:      config_item("path",  [ "/etc/snort" ]),    // Location of the base snort configuration files.
	temp_dir:        config_item("path",  [ "/var/snort.d" ]),  // Location of all transient snort config, including downloaded rules.
	log_dir:         config_item("path",  [ "/var/log" ]),      // Location of the generated logs, and oh-by-the-way the snort PID file (why?).
	logging:         config_item("enum",  [ 0, 1 ], 1),
	openappid:       config_item("enum",  [ 0, 1 ], 0),

	mode:            config_item("enum",  [ "ids", "ips" ]),
	method:          config_item("enum",  [ "pcap", "afpacket", "nfq" ]),
	action:          config_item("enum",  [ "default", "alert", "block", "drop", "reject" ]),
	interface:       config_item("str",   [ uci.get("network", "wan", "device") ]),
	snaplen:         config_item("range", [ 1518, 65535 ]),     // int daq.snaplen = 1518: set snap length (same as -s) { 0:65535 }

	include:         config_item("path",  [ "" ]),              // User-defined snort configuration, applied at end of snort.lua.
};

const nfq_config = {
	queue_count:     config_item("range", [ 1, 16 ], 4),           // Count of queues to allocate in nft chain when method=nfq, usually 2-8.
	queue_start:     config_item("range", [ 1, 32768], 4),         // Start of queue numbers in nftables.
	queue_maxlen:    config_item("range", [ 1024, 65536 ], 1024),  // --daq-var queue_maxlen=int
	fanout_type:     config_item("enum",  [ "hash", "lb", "cpu", "rollover", "rnd", "qm"], "hash"), // See below.
	thread_count:    config_item("range", [ 0, 32 ], 0),           // 0 = use cpu count
	chain_type:      config_item("enum",  [ "prerouting", "input", "forward", "output", "postrouting" ], "input"),
	chain_priority:  config_item("enum",  [ "raw", "filter", "300"], "filter"),
	include:         config_item("path",  [ "" ]),                 // User-defined rules to include inside queue chain.
};


let _snort_config_doc =
"
This is not an exhaustive list of configuration items, just those that
require more explanation than is given in the tables that define them, below.

https://openwrt.org/docs/guide-user/services/snort

snort
    manual          - When set to 1, use manual configuration for legacy behavior.
                      When disabled, then use this config.
    interface       - Default should usually be 'uci get network.wan.device',
                      something like 'eth0'
    home_net        - IP range/ranges to protect. May be 'any', but more likely it's
                      your lan range, default is '192.168.1.0/24'
    external_net    - IP range external to home.  Usually 'any', but if you only
                      care about true external hosts (trusting all lan devices),
                      then '!$HOME_NET' or some specific range
    mode            - 'ids' or 'ips', for detection-only or prevention, respectively
    oinkcode        - https://www.snort.org/oinkcodes
    config_dir      - Location of the base snort configuration files.  Default /etc/snort
    temp_dir        - Location of all transient snort config, including downloaded rules
                      Default /var/snort.d
    logging         - Enable external logging of events thus enabling 'snort-mgr report',
                      otherwise events only go to system log (i.e., 'logread -e snort:')
    log_dir         - Location of the generated logs, and oh-by-the-way the snort
                      PID file (why?).  Default /var/log
    openappid       - Enabled inspection using the 'openappid' package
                      See 'opkg info openappid'
    action          - Override the specified action of your rules.  One of 'default',
                      'alert', 'block', 'reject' or 'drop', where 'default' means use
                      the rule as defined and don't override.
    method          - 'pcap', 'afpacket' or 'nfq'
    snaplen         - int daq.snaplen = 1518: set snap length (same as -s) { 0:65535 }
    include         - User-defined snort configuration, applied at end of generated snort.lua

nfq - https://github.com/snort3/libdaq/blob/master/modules/nfq/README.nfq.md
    queue_maxlen    - nfq's '--daq-var queue_maxlen=int'
    queue_count     - Count of queues to use when method=nfq, usually 2-8
    fanout_type     - Sets kernel load balancing algorithm*, one of hash, lb, cpu,
                      rollover, rnd, qm.
    thread_count    - int snort.-z: <count> maximum number of packet threads
                      (same as --max-packet-threads); 0 gets the number of
                      CPU cores reported by the system; default is 1 { 0:max32 }
    chain_type      - Chain type when generating nft output
    chain_priority  - Chain priority when generating nft output
    include         - Full path to user-defined extra rules to include inside queue chain

    * - for details on fanout_type, see these pages:
        https://github.com/florincoras/daq/blob/master/README
        https://www.kernel.org/doc/Documentation/networking/packet_mmap.txt
";

function snort_config_doc(comment) {
	if (comment == null) comment = "";
	if (comment != "") comment += " ";
	for (let line in split(_snort_config_doc, "\n")) {
		let msg = rtrim(sprintf("%s%s", comment, line));
		print(msg, "\n");
	}
}

//------------------------------------------------------------------------------

function load(section, config) {
	let self = {
		".name":   section,
		".config": config,
	};

	// Set the defaults from definitions in table.
	for (let item in config) {
		self[item] = config[item].default;
	}

	// Overwrite them with any uci config settings.
	let cfg = uci.get_all("snort", section);
	for (let item in cfg) {
		// If you need to rename, delete or change the meaning of a
		// config item, just intercept it and do the work here.

		if (exists(config, item)) {
			let val = cfg[item];
			if (config[item].contains(val))
				self[item] = val;
			else {
				wrn(`In option ${item}='${val}', must be ${config[item].allowed()}`);
				// ??? self[item] = config[item][0]; ???
			}
		}
	}

	return self;
}

let snort = null;
let nfq   = null;
function load_all() {
	snort = load("snort", snort_config);
	nfq   = load("nfq", nfq_config);
}

function dump_config(settings) {
	let section = settings[".name"];
	let config  = settings[".config"];
	printf("config %s '%s'\n", section, section);
	for (let item in config) {
		printf("\toption %-15s %-17s# %s\n", item, `'${settings[item]}'`, config[item].allowed());
	}
	print("\n");
}

function render_snort() {
	include("templates/snort.uc", { snort, nfq, rpad });
}

function render_nftables() {
	include("templates/nftables.uc", { snort, nfq, rpad });
}

function render_config() {
	snort_config_doc("#");
	dump_config(snort);
	dump_config(nfq);
}

function render_help() {
	snort_config_doc();
}

//------------------------------------------------------------------------------

load_all();

let table_type = TYPE;  // Supply on cli with '-D TYPE=snort'...
switch (table_type) {
	case "snort":
		render_snort();
		return;

	case "nftables":
		render_nftables();
		return;

	case "config":
		render_config();
		return;

	case "help":
		render_help();
		return;

	default:
		print(`Invalid table type '${table_type}', should be one of snort, nftables, config, help.\n`);
		return;
}

//------------------------------------------------------------------------------
-%}
