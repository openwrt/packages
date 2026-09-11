#!/usr/bin/env ucode
// luci.fwblack - rpcd backend for the fw.black LuCI app.
//
// Installed to /usr/share/rpcd/ucode/fwblack.uc by luci-app-fwblack.
// Object name on ubus: luci.fwblack (see return statement below).
// Access is gated by /usr/share/rpcd/acl.d/luci-app-fwblack.json.
//
// All privileged work (nft, init script, logread, nslookup) happens here so
// the browser side only needs this one ubus object (+ stock uci/file/rpc).
'use strict';

import * as fs from 'fs';

function sh(cmd) {
	let p = fs.popen(cmd + ' 2>/dev/null', 'r');
	let out = p.read('all');
	let code = p.close();
	if (out == null)
		out = '';
	return { out: out, code: code };
}

function uci_get(opt, def) {
	let r = sh('uci -q get fwblack.global.' + opt);
	let v = trim(r.out);
	return (v == '') ? def : v;
}

function tbl() { return uci_get('table', 'fwblack'); }
function set_v4() { return uci_get('set_v4', 'blacklist_v4'); }
function set_v6() { return uci_get('set_v6', 'blacklist_v6'); }
function blocklist_path() { return uci_get('blocklist', '/etc/fwblack/blocklist.cfg'); }
function cache_path() { return uci_get('cache_file', '/tmp/fwblack.dnscache'); }
function blkips_path() { return '/tmp/blacklist.ips'; }

function read_lines(path) {
	let data = fs.readfile(path);
	let lines = [];
	if (data == null)
		return lines;
	for (let raw in split(data, '\n')) {
		let line = trim(raw);
		if (length(line) > 0 && substr(line, length(line) - 1, 1) == '\r')
			line = substr(line, 0, length(line) - 1);
		if (line != '')
			push(lines, line);
	}
	return lines;
}

/* Literal substring test (dots are literal, unlike regex match()). */
function contains(hay, needle) {
	if (needle == '' || hay == null)
		return false;
	let n = length(needle);
	for (let i = 0; i + n <= length(hay); i++) {
		if (substr(hay, i, n) == needle)
			return true;
	}
	return false;
}

/* Effective blocklist entries: lowercase, no comments/blank lines,
 * full-line and trailing "# comment" handling like resips.sh. */
function blocklist_entries() {
	let entries = [];
	for (let line in read_lines(blocklist_path())) {
		if (substr(line, 0, 1) == '#')
			continue;
		let parts = split(line, '#');
		let e = trim(parts[0]);
		/* strip spaces/tabs inside (resips.sh: tr -d ' \t') */
		let clean = '';
		for (let i = 0; i < length(e); i++) {
			let c = substr(e, i, 1);
			if (c != ' ' && c != '\t')
				clean += c;
		}
		e = lc(clean);
		if (e != '')
			push(entries, e);
	}
	return entries;
}

function parse_json_safe(s) {
	if (trim(s) == '')
		return null;
	try {
		return json(s);
	} catch (e) {
		return null;
	}
}

/* Elements of one nft set as plain string array (nft --json shape:
 * {"nftables":[{...},{"set":{...,"elem":[...]}}]}). */
function nft_elements(family_set) {
	let r = sh('nft --json list set inet ' + tbl() + ' ' + family_set);
	let data = parse_json_safe(r.out);
	let elems = [];
	if (data == null || data.nftables == null)
		return elems;
	for (let item in data.nftables) {
		if (item.set != null && item.set.elem != null) {
			for (let e in item.set.elem) {
				if (type(e) == 'string')
					push(elems, e);
				else if (e != null && e.val != null)
					push(elems, '' + e.val);
			}
		}
	}
	return elems;
}

function valid_ip(ip) {
	if (ip == null)
		return false;
	if (match(ip, /^([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$/))
		return true;
	if (match(ip, /^[0-9A-Fa-f:.]+$/) && match(ip, /:.*:/) && !match(ip, /:::/))
		return true;
	return false;
}

function service_state() {
	let r = sh('ubus call service list \'{"name":"fwblack"}\'');
	let data = parse_json_safe(r.out);
	let running = false;
	let pid = null;
	if (data != null && data.fwblack != null && data.fwblack.instances != null &&
	    data.fwblack.instances.fwblack != null) {
		let inst = data.fwblack.instances.fwblack;
		running = (inst.running == true);
		if (inst.pid != null)
			pid = inst.pid;
	}
	let enabled = (sh('ls /etc/rc.d/ | grep -q fwblack').code == 0);
	return { running: running, pid: pid, enabled: enabled };
}

/* rpcd invokes callbacks with a request object; named call arguments live
 * in request.args (see rpcd examples/ucode/example-plugin.uc). */
function R(req) {
	if (req != null && req.args != null)
		return req.args;
	return {};
}

const methods = {
	status: {
		call: function(args) {
			let ev4 = nft_elements(set_v4());
			let ev6 = nft_elements(set_v6());
			let file_ips = [];
			for (let line in read_lines(blkips_path())) {
				if (substr(line, 0, 1) != '#')
					push(file_ips, line);
			}
			let cache_lines = read_lines(cache_path());
			let svc = service_state();
			return {
				running: svc.running,
				pid: svc.pid,
				enabled: svc.enabled,
				table: tbl(),
				set_v4: set_v4(),
				set_v6: set_v6(),
				set_v4_count: length(ev4),
				set_v6_count: length(ev6),
				file_count: length(file_ips),
				blocklist_entries: length(blocklist_entries()),
				cache_entries: length(cache_lines),
				interval: uci_get('interval', '300'),
				interval_jitter: uci_get('interval_jitter', '30')
			};
		}
	},

	/* Union of blocked IPs from the file and both nft sets. */
	blocked: {
		call: function(args) {
			let ev4 = nft_elements(set_v4());
			let ev6 = nft_elements(set_v6());
			let in_set = {};
			for (let ip in ev4)
				in_set[ip] = 'v4';
			for (let ip in ev6) {
				if (in_set[ip] != null)
					in_set[ip] = 'v4+v6';
				else
					in_set[ip] = 'v6';
			}
			let rows = [];
			let seen = {};
			for (let line in read_lines(blkips_path())) {
				if (substr(line, 0, 1) == '#')
					continue;
				seen[line] = true;
				push(rows, {
					ip: line,
					in_file: true,
					in_set: in_set[line] != null,
					family: in_set[line]
				});
			}
			for (let ip in ev4) {
				if (seen[ip] == null) {
					seen[ip] = true;
					push(rows, { ip: ip, in_file: false, in_set: true, family: in_set[ip] });
				}
			}
			for (let ip in ev6) {
				if (seen[ip] == null) {
					seen[ip] = true;
					push(rows, { ip: ip, in_file: false, in_set: true, family: in_set[ip] });
				}
			}
			return { blocked: rows, count: length(rows) };
		}
	},

	/* Remove one IP from the file and both nft sets. */
	unblock: {
		args: { ip: '1.2.3.4' },
		call: function(req) {
			let a = R(req);
			let ip = (a.ip != null) ? trim('' + a.ip) : '';
			if (!valid_ip(ip))
				return { error: 'invalid IP address' };
			let kept = [];
			let removed_file = false;
			for (let line in read_lines(blkips_path())) {
				if (line == ip)
					removed_file = true;
				else
					push(kept, line);
			}
			if (removed_file) {
				let data = '';
				for (let k in kept)
					data += k + '\n';
				fs.writefile(blkips_path(), data);
			}
			let r4 = sh('nft delete element inet ' + tbl() + ' ' + set_v4() + ' { ' + ip + ' }');
			let r6 = sh('nft delete element inet ' + tbl() + ' ' + set_v6() + ' { ' + ip + ' }');
			return {
				ok: true,
				ip: ip,
				removed_file: removed_file,
				removed_set: (r4.code == 0 || r6.code == 0)
			};
		}
	},

	/* Reverse-resolve one IP and report blocklist matches (no side effects). */
	lookup: {
		args: { ip: '8.8.8.8' },
		call: function(req) {
			let a = R(req);
			let ip = (a.ip != null) ? trim('' + a.ip) : '';
			if (!valid_ip(ip))
				return { error: 'invalid IP address' };
			let r = sh('nslookup ' + ip + ' | awk \'tolower($0) ~ /name[ =:]/ {print $NF}\' | sed \'s/\\.$//\'');
			let names = [];
			for (let line in split(r.out, '\n')) {
				let h = lc(trim(line));
				if (h != '')
					push(names, h);
			}
			let matched = [];
			let entries = blocklist_entries();
			for (let e in entries) {
				for (let h in names) {
					if (contains(h, e)) {
						push(matched, e);
						break;
					}
				}
			}
			return {
				ip: ip,
				names: names,
				matched: matched,
				blocked: (length(matched) > 0)
			};
		}
	},

	log: {
		args: { lines: 50 },
		call: function(req) {
			let a = R(req);
			let n = 50;
			if (type(a.lines) == 'int')
				n = a.lines;
			if (n < 1)
				n = 1;
			if (n > 200)
				n = 200;
			/* Daemon lines are tagged "fw-black:"/"resips.sh:"; -e fwblack
			 * would miss the hyphenated form, so filter with grep -E. */
			let r = sh('logread | grep -E \'fw-black|resips\\.sh|fwblack\' | tail -n ' + n);
			let lines = [];
			for (let line in split(r.out, '\n')) {
				if (line != '')
					push(lines, line);
			}
			return { lines: lines };
		}
	},

	/* start|stop|restart|reload|enable|disable via the init script. */
	svc: {
		args: { action: 'restart' },
		call: function(req) {
			let a = R(req);
			let action = (a.action != null) ? trim('' + a.action) : '';
			if (action != 'start' && action != 'stop' && action != 'restart' &&
			    action != 'reload' && action != 'enable' && action != 'disable')
				return { error: 'invalid action' };
			let r = sh('/etc/init.d/fwblack ' + action);
			return { ok: (r.code == 0), action: action, output: trim(r.out) };
		}
	},

	cache_clear: {
		call: function(args) {
			sh('rm -f ' + cache_path());
			return { ok: true };
		}
	}
};

return { 'luci.fwblack': methods };
