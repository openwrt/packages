// SPDX-License-Identifier: Apache-2.0
'use strict';

// trafficctl.history: durable per-device traffic history, accumulated per
// accounting period (#89, #90), and the interface series beside it (#102).
// Ported from trafficctl-history.sh with its files unchanged, so a 1.30.x
// reader (after a downgrade) and this one read each other's store.
//
//   main(args, src)     the `history` command: { out, rc }, out a value to
//                       print as JSON, a string to print as it is, or null.
//                       src replaces the sources in tests: { totals, ifaces }
//                       are what net.totals(true) and net.ifaces() return
//   period_id(t)        the configured period's id at epoch t (default now)
//   iso_week(tm)        "YYYY-Www" of a localtime() record
//   valid_dir(d)        an allowed store directory
//
// WHY THIS EXISTS
//   net.totals() already has correct lifetime totals, but its store is tmpfs
//   on purpose: it is rewritten on every LuCI poll and every metrics scrape,
//   and that write volume would wear the flash out. Everything here is
//   persistence and windowing; no new accounting.
//
// ONE FILE PER PERIOD
//   <dir>/<period>.tsv, the period being 2026-10-09, 2026-W41 or 2026-10. A
//   reset every day/week/month is a new file name, retention is a file
//   delete, and a finished period's file is never touched again, so a crash
//   can only damage the current one.
//
// TSV, NOT JSON
//   An interrupted write costs a TSV its last line and a JSON file all of it.
//   Rewrites still go through a temp file in the SAME directory and a rename
//   (lib.write_atomic): a temp file elsewhere plus a cross-filesystem move is
//   not atomic, and "elsewhere" is exactly what happens when dir is a mount.
//
// DELTAS, NOT SNAPSHOTS
//   A flush folds in only the growth since the previous flush, tracked in a
//   tmpfs cursor. A live total BELOW the cursor means the accumulator was
//   reset (reboot), so the flush rebaselines and adds nothing: a reboot costs
//   at most one interval of traffic instead of corrupting the period. The
//   cursor is tmpfs so that it dies together with the accumulator it tracks.
//   The cursor advances only after the period file is renamed into place; a
//   kill that lands after an NFS rename has taken effect but before the
//   cursor is written folds that interval in twice.
//   A period file that exists and cannot be read (EIO, mode 000) is never
//   rewritten: the flush fails with "read failed" and keeps the cursor.
//
// HOW ACCURATE THE STORED NUMBERS ARE
//   1. Uncountered offload ("degraded"): an offloaded flow's conntrack
//      counters freeze while traffic continues, so the total is a LOWER
//      BOUND. The flag is sticky per device in totals and stored per row.
//   2. Conntrack is sampled: a flow that starts and ends between two samples
//      is never seen. Hence `sample`, driven at sample_interval (tmpfs only),
//      separate from the flush interval.
//   Both count before the shaper: what arrived for a device, not what was
//   delivered to it.
//
// NEVER IN A REQUEST PATH, AND NEVER UNBOUNDED
//   The keeper drives the flush on its own timer. If dir is on a dead
//   NFS/CIFS mount the writer blocks, and ucode cannot time out its own
//   blocking write (no signal() before 2023-07, and a blocked write would not
//   return to see one anyway). So the store is only ever written by a child,
//   `trafficctl history flush-now`, under timeout(1) where the system has it
//   and under system()'s own kill in any case; the keeper and the `flush`
//   command wait for it at most GUARD_MS. A failure parks history in a
//   visible error state instead of retrying silently. The bound holds unless
//   the kernel cannot kill the writer: system() waits for the child after
//   SIGKILL, and a process in uninterruptible sleep (D state, a hard NFS
//   mount) dies only when the I/O returns.

import * as lib from 'trafficctl.lib';
import * as net from 'trafficctl.net';
import { lsdir, stat, access, unlink } from 'fs';

const CLI = '/usr/sbin/trafficctl';
// tmpfs, all of them: see DELTAS above for why the cursor must not survive a
// reboot. The names are the shell's, so a running 1.30.x keeper and this
// code (during an upgrade) and a downgrade see one state.
const CURSOR = '/tmp/trafficctl_history.cursor';
const ERRFILE = '/tmp/trafficctl_history.err';
const STAMP = '/tmp/trafficctl_history.stamp';
const LOCKD = '/tmp/trafficctl_history.lock.d';
const IFCURSOR = '/tmp/trafficctl_history.ifcursor';
// Per period, suffixed with its id, so a period roll starts a fresh one; it
// is rebuilt from the durable file whenever it is missing (every boot).
const IFACC = '/tmp/trafficctl_history.ifacc';
const NAMES = '/etc/trafficctl/names';
const LEASES = '/tmp/dhcp.leases';
const RDNS_CACHE = '/tmp/trafficctl_rdns_cache';

const DIR_DEFAULT = '/etc/trafficctl/history';
// Row layout, tab-separated:
//   key  mac  ip  name  rx  tx  tcp  udp  first_seen  last_seen  degraded
// key is "mac:<mac>" or "ip:<addr>" (see dev_key). Fields are only ever
// appended at the END, so an older reader keeps working.
const FORMAT = 1;
const HEADER = '# trafficctl-history 1\n';
const IF_HEADER = '# trafficctl-history-if 1\n';

// The shell waited 50 x 100 ms and then stole the lock regardless. A flush
// killed by the guard leaves its lock behind (no signal handler to remove
// it), so a lock is stale only once it is older than the guard: a live
// flush on a slow mount is never stolen from.
const LOCK_TRIES = 50;
const LOCK_STALE = 20;
// timeout(1) sends TERM at 15 s; system() kills at GUARD_MS whatever runs.
const GUARD_SECS = 15;
const GUARD_MS = 20000;
// The keeper's gc() cadence, in ticks.
const GC_TICKS = 32;

// ── how awk and the shell read things ───────────────────────────────────────

// awk's "$n + 0": the integer prefix, else 0. The store only ever holds
// integers; a hand-edited "1.5" reads as 1 here and as 2 in awk's %.0f.
function anum(s) {
	// The store's own fields are canonical integers: int() takes them
	// directly, and only anything else pays for the regex.
	let n = int(s);
	if (n == n && type(s) == 'string' && '' + n == s)
		return n;
	let m = match('' + (s ?? ''), /^[ \t]*([-+]?[0-9]+)/);
	if (!m)
		return 0;
	n = int(m[1]);
	return (n == n) ? n : 0;
}

// awk's default field split.
function fields(l) {
	l = trim(l, ' \t');
	return (l == '') ? [] : split(l, /[ \t]+/);
}

// A file's lines, '' for each empty one, without the final empty one.
function lines_of(p) {
	return lib.file_lines(p);
}

// Lines of a store file that is about to be rewritten: [] when it does not
// exist, null when it exists and cannot be read (EIO on a share, mode 000).
// readfile() is null for both, and reading an unreadable period as empty
// would let the next write replace it with one interval's worth.
function store_lines(p) {
	let text = lib.readfile(p);
	if (text == null)
		return (stat(lib.path(p)) == null) ? [] : null;
	let l = split(text, '\n');
	if (l[-1] == '')
		pop(l);
	return l;
}

// ── configuration ───────────────────────────────────────────────────────────

function hget(opt) {
	return lib.uci_get('trafficctl', 'history', opt);
}

function enabled() {
	return hget('enabled') == '1';
}

// The store is both a mkdir target and a delete target (prune removes *.tsv
// inside it), so an unconstrained value would hand the write ACL arbitrary
// directory creation plus the removal of any .tsv on the filesystem. Enforced
// here as well as in the rpcd setter: a value that reached the config by
// another route must not be honoured either. The roots are the package's own
// state directory and the usual mount points (a network share, a USB disk).
// A period id: 2026-11, 2026-11-11 or 2026-W46 (luci.trafficctl's period_id).
const PERIOD_RE = /^[0-9]{4}-([0-9]{2}|[0-9]{2}-[0-9]{2}|W[0-9]{2})$/;

const DIR_ROOTS = [ '/etc/trafficctl/', '/mnt/', '/media/', '/srv/', '/tmp/' ];

function valid_dir(d) {
	if (!lib.plain(d) || d == '')
		return false;
	if (match(d, /(^|\/)\.\.(\/|$)/))
		return false;
	if (match(d, /['"$`|;&<>]/))
		return false;
	// What the path names once "//" and "/./" fold away: /mnt/. passes the
	// root test below and still names the mount root itself.
	let n = d, p = null;
	while (n != p) {
		p = n;
		n = replace(replace(n, /\/\/+/g, '/'), /\/\.(\/|$)/g, '/');
	}
	for (let r in DIR_ROOTS)
		// A bare root would make prune's delete set the whole of /mnt.
		if (substr(d, 0, length(r)) == r && d != r && n != r && n != substr(r, 0, -1))
			return true;
	return false;
}

// One trailing slash dropped, then an absolute path inside an allowed root,
// or the default. A relative path would resolve against whatever directory
// the caller happened to be in (procd, rpcd and a shell all differ).
function store_dir() {
	let d = hget('dir') ?? '';
	if (substr(d, -1) == '/')
		d = substr(d, 0, -1);
	return valid_dir(d) ? d : DIR_DEFAULT;
}

function period_kind() {
	let k = hget('period');
	return (k == 'day' || k == 'week') ? k : 'month';
}

// Digits only, else the default; then clamped. (The shell kept a value past
// what test(1) can compare as it was; that has no sane meaning, so it clamps.)
function bounded(v, dflt, lo, hi) {
	let n = (v != null && match(v, /^[0-9]+$/)) ? int(v) : dflt;
	if (n != n)
		n = hi ?? dflt;
	if (n < lo)
		n = lo;
	if (hi != null && n > hi)
		n = hi;
	return n;
}

function keep() {
	return bounded(hget('keep'), 12, 1, 120);
}

// Floor of 300 s: the point of this store is to stay off the flash write
// path; a 10 s interval would reproduce what put the accumulator in tmpfs.
function flush_interval() {
	return bounded(hget('interval'), 3600, 300, null);
}

// How often the live accumulator is advanced: much shorter than the flush,
// because of accuracy note 2. A conntrack read and a tmpfs write, no flash.
function sample_interval() {
	return bounded(hget('sample_interval'), 60, 10, 3600);
}

// On a single-WAN router the interface series is a handful of rows nobody
// reads; the point of it is multi-WAN.
function ifaces_enabled() {
	return hget('interfaces') != '0';
}

// ── periods ─────────────────────────────────────────────────────────────────

const CUM_DAYS = [ 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334 ];

function leap(y) {
	return (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;
}

// The weekday (0 = Sunday) of 31 December of year y, plus one: Gauss.
function dec31(y) {
	return (y + int(y / 4) - int(y / 100) + int(y / 400)) % 7;
}

// A year has 53 ISO weeks when it starts on a Thursday, or is a leap year
// starting on a Wednesday: when 31 December is a Thursday, or the 31 December
// before it a Wednesday.
function iso_weeks(y) {
	return (dec31(y) == 4 || dec31(y - 1) == 3) ? 53 : 52;
}

// date +%G-W%V by hand (there is no strftime): week 1 is the one holding the
// year's first Thursday, so the days around New Year can belong to the
// neighbouring year's weeks. %Y-W%V would name a week of the other year and
// two different weeks would collide on one id. From the local calendar date,
// so the day, week and month ids roll over at the same local midnight.
function iso_week(tm) {
	let y = tm.year;
	let ord = CUM_DAYS[tm.mon - 1] + tm.mday + ((tm.mon > 2 && leap(y)) ? 1 : 0);
	let wd = (tm.wday + 6) % 7 + 1;
	let w = int((ord - wd + 10) / 7);
	if (w < 1) {
		y--;
		w = iso_weeks(y);
	}
	else if (w > iso_weeks(y)) {
		y++;
		w = 1;
	}
	return sprintf('%d-W%02d', y, w);
}

// Every id is fixed-width and zero-padded, so lexical order IS chronological
// order: read and prune compare them as strings.
function period_id(t) {
	let tm = (t != null) ? localtime(t) : localtime();
	switch (period_kind()) {
	case 'day':
		return sprintf('%d-%02d-%02d', tm.year, tm.mon, tm.mday);
	case 'week':
		return iso_week(tm);
	default:
		return sprintf('%d-%02d', tm.year, tm.mon);
	}
}

function period_file(dir, p) {
	return dir + '/' + p + '.tsv';
}

// Interface totals live in their OWN file per period, not as a record type
// in the device file (#102): every row a 1.22+ reader finds in the device file
// is reported as a device, and a file the old reader never opens cannot be
// misread.
function if_file(dir, p) {
	return dir + '/' + p + '.if.tsv';
}

// The store's files as the shell's "$dir"/*<suffix> glob found them: no dot
// files, regular files (through symlinks), in byte order.
function store_files(dir, suffix) {
	let out = [];
	for (let e in lsdir(lib.path(dir)) ?? []) {
		if (substr(e, 0, 1) == '.' || length(e) <= length(suffix) || substr(e, -length(suffix)) != suffix)
			continue;
		if (stat(lib.path(dir + '/' + e))?.type == 'file')
			push(out, e);
	}
	return sort(out);
}

// Period ids from p_from to p_to (default the current period, and p_from),
// with the file for each. ('from' is a reserved word before 2023-11.)
function period_range(dir, suffix, skip, p_from, p_to) {
	if (p_from == null || p_from == '')
		p_from = period_id();
	if (p_to == null || p_to == '')
		p_to = p_from;
	let out = [];
	for (let e in store_files(dir, suffix)) {
		if (skip && substr(e, -length(skip)) == skip)
			continue;
		let p = substr(e, 0, length(e) - length(suffix));
		if (p < p_from || p_to < p)
			continue;
		push(out, { p, f: dir + '/' + e });
	}
	return out;
}

// ── errors and the guard ────────────────────────────────────────────────────

function err_set(msg) {
	lib.write_atomic(ERRFILE, sprintf('%d\t%s\n', time(), msg));
	lib.log('config', 'history: ' + msg);
}

function err_clear() {
	lib.remove(ERRFILE);
}

let have_timeout;
function guarded(argv) {
	// BusyBox ships timeout(1), but not every build has it (the 22.03
	// rootfs does not); system()'s own kill covers that case.
	have_timeout ??= (lib.sh('command -v timeout') == 0);
	// 'timeout 15' is GUARD_SECS, spelled out for the command lint.
	return lib.run_rc((have_timeout ? 'timeout 15 ' : '') +
		lib.qv([ lib.path(CLI), ...argv ]), GUARD_MS);
}

// A child's reply: its JSON object as printed, or null when it printed none
// (killed by the guard, or died).
function child_reply(r) {
	let out = rtrim(r.out, '\n');
	try {
		let v = json(out);
		if (type(v) == 'object')
			return out;
	}
	catch (e) {
	}
	return null;
}

// ── device keys and names ───────────────────────────────────────────────────

// Every source a key or a name comes from, read once per flush and indexed by
// address. The shell re-read each of them once per device, and a scan per
// device is quadratic in the size of the network. Each map keeps the line the
// shell's "first match, exit" awk would have used.
function first_by(m, k, v) {
	if (k != null && !exists(m, k))
		m[k] = v;
}

function lookups() {
	let lk = { lease_mac: {}, lease_name: {}, neigh: null, hops: null, names: {}, rdns: {} };
	for (let l in lines_of(LEASES)) {
		let f = fields(l);
		first_by(lk.lease_mac, f[2], f[1] ?? '');
		if (f[3] != '*')
			first_by(lk.lease_name, f[2], f[3] ?? '');
	}
	for (let l in lines_of(NAMES)) {
		let f = split(l, /[ \t]+/);
		// awk's "$1 = ''" and the strip of the separator it leaves in front.
		first_by(lk.names, f[0], ltrim(join(' ', slice(f, 1)), ' \t'));
	}
	// "IP HOST TIMESTAMP", HOST '-' for a negative answer. (The shell read
	// this file as tab-separated, which it never is, so it never found a name
	// here.)
	for (let l in lines_of(RDNS_CACHE)) {
		let f = fields(l);
		if (f[1] != null && f[1] != '-')
			first_by(lk.rdns, f[0], f[1]);
	}
	return lk;
}

// A route's next hop is a router, not an end device: its MAC is the source of
// every packet it forwards, so trusting it would collapse a whole subnet into
// one row (tctl_ip_is_nexthop).
function is_nexthop(lk, ip) {
	if (lk.hops == null) {
		lk.hops = {};
		for (let l in lib.lines('ip route show')) {
			let f = fields(l);
			for (let i = 0; i < length(f) - 1; i++)
				if (f[i] == 'via')
					lk.hops[f[i + 1]] = true;
		}
	}
	return exists(lk.hops, ip);
}

// tctl_lookup_mac: the first lease for the address, the neighbour table only
// when that has none; then strictly six hex pairs.
function lookup_mac(lk, ip) {
	let mac = lk.lease_mac[ip] ?? '';
	if (mac == '') {
		if (lk.neigh == null) {
			lk.neigh = {};
			for (let l in lib.lines('ip neigh show')) {
				let f = fields(l);
				for (let i = 0; i < length(f) - 1; i++)
					if (f[i] == 'lladdr') {
						first_by(lk.neigh, f[0], f[i + 1]);
						break;
					}
			}
		}
		mac = lk.neigh[ip] ?? '';
	}
	mac = lc(mac);
	return match(mac, /^[0-9a-f]{2}(:[0-9a-f]{2}){5}$/) ? mac : null;
}

// "mac:<mac>" where a MAC can be established, else "ip:<addr>".
//
// IP is the wrong key for history even though it is the right one for live
// monitoring: a device offline for a week comes back on another lease, and
// its old address goes to something else, so IP-keyed history silently
// merges two devices. MAC is stable, but not always known: clients behind a
// downstream router and extra_subnets have no lease or neighbour entry here,
// and a next hop's MAC is refused. Those get an ip: key, marked as such.
//
// A device seen first without a MAC and later with one gets a SECOND row:
// adopting the first would guess that the two are one device, and the case
// it would break (an address reused by something else) merges unrelated
// traffic.
function dev_key(lk, ip) {
	let mac = is_nexthop(lk, ip) ? null : lookup_mac(lk, ip);
	return mac ? { key: 'mac:' + mac, mac } : { key: 'ip:' + ip, mac: '-' };
}

// Name precedence: manual alias > DHCP lease > cached reverse DNS, the order
// the summary applies.
function dev_name(lk, ip) {
	let n = lk.names[ip] ?? '';
	if (n == '')
		n = lk.lease_name[ip] ?? '';
	if (n == '')
		n = lk.rdns[ip] ?? '';
	return n;
}

// Tabs and newlines would corrupt the row format; a name comes from a DHCP
// lease or a PTR record, neither of which this controls.
function sanitize(s) {
	return substr(replace(s, /[\t\r\n]/g, ''), 0, 64);
}

// ── device store ────────────────────────────────────────────────────────────

// A sample reading: -1 for missing or not a count, as the shell's num().
function reading(v) {
	return (type(v) == 'int' && v >= 0) ? v : -1;
}

// Rows of a device period file: { order, rows } with the first line of a key
// deciding its place and the last its values.
function load_rows(file) {
	let order = [], rows = {}, ls = store_lines(file);
	if (ls == null)
		return null;
	for (let l in ls) {
		if (substr(l, 0, 1) == '#')
			continue;
		let f = split(l, '\t');
		if (length(f) < 10)
			continue;
		let k = f[0];
		if (!exists(rows, k))
			push(order, k);
		rows[k] = { mac: f[1], ip: f[2], name: f[3], rx: anum(f[4]), tx: anum(f[5]),
			tc: anum(f[6]), ud: anum(f[7]), first: anum(f[8]), last: anum(f[9]),
			deg: (length(f) >= 11) ? f[10] : 'false' };
	}
	return { order, rows };
}

function load_cursor(p, n) {
	let c = {};
	for (let l in lines_of(p)) {
		let f = split(l, '\t');
		if (length(f) < n)
			continue;
		c[f[0]] = map(slice(f, 1, n), anum);
	}
	return c;
}

function cursor_text(prev, next) {
	// Keys that were NOT in this sample keep their cursor: a device absent for
	// one flush must not have its next reading treated as a fresh baseline,
	// or its whole lifetime total would be folded in twice.
	let text = '';
	for (let k in keys(prev))
		if (!exists(next, k))
			text += k + '\t' + join('\t', map(prev[k], (v) => sprintf('%d', v))) + '\n';
	for (let k in keys(next))
		text += k + '\t' + join('\t', map(next[k], (v) => sprintf('%d', v))) + '\n';
	return text;
}

// The live reading per key. Two addresses can map to ONE key within a flush
// (a device that changed lease while totals still remembers both), so it is
// the sum over its addresses, and the cursor comparison happens once.
function aggregate(sample, lk) {
	let order = [], agg = {};
	for (let e in sample) {
		let ip = e?.ip;
		if (!lib.valid_ip(ip))
			continue;
		let id = dev_key(lk, ip), name = sanitize(dev_name(lk, ip));
		let a = agg[id.key];
		if (!a) {
			a = agg[id.key] = { rx: 0, tx: 0, tc: 0, ud: 0, ktc: false, kud: false,
				deg: false, mac: '', ip: '', name: '' };
			push(order, id.key);
		}
		let rx = reading(e.bytes_in_total), tx = reading(e.bytes_out_total);
		let tc = reading(e.bytes_tcp_total), ud = reading(e.bytes_udp_total);
		a.rx += (rx < 0) ? 0 : rx;
		a.tx += (tx < 0) ? 0 : tx;
		if (tc >= 0) {
			a.tc += tc;
			a.ktc = true;
		}
		if (ud >= 0) {
			a.ud += ud;
			a.kud = true;
		}
		if (e.degraded === true)
			a.deg = true;
		a.mac = id.mac;
		a.ip = ip;
		if (name != '')
			a.name = name;
	}
	return { order, agg };
}

// Growth of one protocol counter against its cursor, -1 without a reading.
function proto_delta(live, cur) {
	if (live < 0)
		return -1;
	if (cur == null || cur < 0)
		return live;
	return (live >= cur) ? live - cur : 0;
}

function fold(st, live, cur, now) {
	let next = {};
	for (let k in live.order) {
		let a = live.agg[k], c = cur[k];
		let ltc = a.ktc ? a.tc : -1, lud = a.kud ? a.ud : -1;
		// Growth only. A live value below the cursor means the accumulator
		// restarted; rebaseline and add nothing, because the bytes it is now
		// below by were already folded in.
		let drx = a.rx, dtx = a.tx;
		if (c) {
			drx = (a.rx >= c[0]) ? a.rx - c[0] : 0;
			dtx = (a.tx >= c[1]) ? a.tx - c[1] : 0;
		}
		let dtc = proto_delta(ltc, c ? c[2] : null), dud = proto_delta(lud, c ? c[3] : null);

		let r = st.rows[k];
		if (!r) {
			push(st.order, k);
			r = st.rows[k] = { mac: '', ip: '', name: '', rx: 0, tx: 0, tc: 0, ud: 0,
				first: now, last: 0, deg: 'false' };
		}
		r.rx += drx;
		r.tx += dtx;
		if (dtc >= 0)
			r.tc += dtc;
		if (dud >= 0)
			r.ud += dud;
		if (a.mac != '' && a.mac != '-')
			r.mac = a.mac;
		r.ip = a.ip;
		// Keep the last name known. A device that goes offline loses its
		// lease, and an empty name over a good one would erase the only label
		// its history will ever have.
		if (a.name != '')
			r.name = a.name;
		if (a.deg)
			r.deg = 'true';
		// Only movement counts as activity: an idle device must not refresh
		// last_seen for a whole month.
		if (drx > 0 || dtx > 0 || r.last == 0)
			r.last = now;
		next[k] = [ a.rx, a.tx, ltc, lud ];
	}
	return next;
}

function rows_text(st) {
	let text = HEADER;
	for (let k in st.order) {
		let r = st.rows[k];
		text += sprintf('%s\t%s\t%s\t%s\t%d\t%d\t%d\t%d\t%d\t%d\t%s\n', k,
			(r.mac != '') ? r.mac : '-', r.ip, (r.name != '') ? r.name : '-',
			r.rx, r.tx, r.tc, r.ud, r.first, r.last, (r.deg != '') ? r.deg : 'false');
	}
	return text;
}

function totals_sample(src) {
	if (src?.totals != null)
		return src.totals;
	// --all, so a device whose last flow expired still reports the total it
	// has accumulated: a quiet device's growth would otherwise be dropped
	// from every flush it happened to be idle for.
	return net.totals(true);
}

// ── interface series (#102) ─────────────────────────────────────────────────
//
// A SECOND series, not a breakdown of the device one: the kernel's own
// interface counters (/proc/net/dev through net.ifaces), which include the
// router's own traffic and broadcast and so legitimately DISAGREE with the
// sum over devices. Under flow offloading they are the MORE trustworthy of
// the two (the driver counts them), so they carry their own verdict. They
// answer what the device series cannot: how much went out of wan1 versus
// wan2. rx/tx are relative to the INTERFACE: rx on the WAN is download, rx
// on br-lan is what the LAN sent.
//
// Skipped, because their bytes are counted elsewhere already: bridge ports
// (enslaved; the bridge counts them), lo, and the shaper's IFB, which mirrors
// LAN ingress.

function load_if_rows(file) {
	let order = [], rows = {}, ls = store_lines(file);
	if (ls == null)
		return null;
	for (let l in ls) {
		if (substr(l, 0, 1) == '#')
			continue;
		let f = split(l, '\t');
		if (length(f) < 7)
			continue;
		let d = f[0];
		if (!exists(rows, d))
			push(order, d);
		rows[d] = { role: f[1], label: f[2], rx: anum(f[3]), tx: anum(f[4]),
			first: anum(f[5]), last: anum(f[6]) };
	}
	return { order, rows };
}

function if_rows_text(st) {
	let text = IF_HEADER;
	for (let d in st.order) {
		let r = st.rows[d];
		text += sprintf('%s\t%s\t%s\t%d\t%d\t%d\t%d\n', d, (r.role != '') ? r.role : '?',
			(r.label != '') ? r.label : '-', r.rx, r.tx, r.first, r.last);
	}
	return text;
}

function if_sample(src) {
	// Anything but a list is a reader that printed nothing at all, a tick
	// the shell skipped.
	if (src?.ifaces != null)
		return (type(src.ifaces) == 'array') ? src.ifaces : null;
	try {
		return net.ifaces();
	}
	catch (e) {
		warn(sprintf('trafficctl history: no interface sample: %s\n', e.message));
		return null;
	}
}

// Fold the growth since the last tick into the tmpfs accumulator and advance
// the cursor. On every sample tick, because a cursor that only moved at flush
// time lost up to a whole flush interval of a link's traffic whenever its
// counter restarted (#111). The durable file is written by if_flush alone;
// the accumulator is seeded from it when absent (every boot, a period roll),
// which is what makes the eventual copy-over safe rather than double-counting.
function if_accumulate(src, p) {
	if (!ifaces_enabled())
		return true;
	p ??= period_id();
	let acc = IFACC + '.' + p;
	let sample = if_sample(src);
	if (sample == null)
		return true;
	let now = time(), ifb = lib.uci_get('trafficctl', 'main', 'shape_ifb') ?? '';
	let cur = load_cursor(IFCURSOR, 3);
	let seed = lib.is_file(acc) ? acc : if_file(store_dir(), p);
	let st = load_if_rows(seed);
	if (st == null) {
		// Neither the cursor nor the accumulator moves: the growth is
		// folded in once the file reads again.
		err_set('cannot read ' + seed);
		return false;
	}
	let next = {};
	for (let e in sample) {
		let d = e?.dev;
		if (type(d) != 'string' || d == '' || d == 'lo' || e.enslaved === true || (ifb != '' && d == ifb))
			continue;
		let rx = reading(e.rx_bytes), tx = reading(e.tx_bytes);
		if (rx < 0 || tx < 0)
			continue;
		// A live counter BELOW the cursor has restarted (the link went down,
		// or the driver reset it), and the bytes since then were counted by
		// nothing: a /proc/net/dev counter is monotonic for the life of the
		// interface, so they are the delta. (The device series adds nothing
		// in that case for a reason that does not transfer, #111.)
		let c = cur[d] ?? [ 0, 0 ];
		let drx = (rx >= c[0]) ? rx - c[0] : rx, dtx = (tx >= c[1]) ? tx - c[1] : tx;
		let r = st.rows[d];
		if (!r) {
			push(st.order, d);
			r = st.rows[d] = { role: '', label: '', rx: 0, tx: 0, first: now, last: 0 };
		}
		r.rx += drx;
		r.tx += dtx;
		if (type(e.role) == 'string' && e.role != '')
			r.role = e.role;
		if (type(e.label) == 'string' && e.label != '')
			r.label = e.label;
		if (drx > 0 || dtx > 0 || r.last == 0)
			r.last = now;
		next[d] = [ rx, tx ];
	}
	if (!lib.write_atomic(acc, if_rows_text(st)))
		return false;
	// Only after the accumulator is in place, as the device cursor waits for
	// its period file: advancing first and then failing would discard the
	// growth for good, where this way it is folded in on the next tick.
	lib.write_atomic(IFCURSOR, cursor_text(cur, next));
	return true;
}

// Publish the accumulator to the durable file, after picking up the final
// interval, so nothing is stranded in tmpfs at flush time.
// p is the device flush's period, so a flush that crosses midnight writes
// both series to the same one.
function if_flush(dir, src, p) {
	if (!ifaces_enabled())
		return true;
	if (!if_accumulate(src, p))
		return false;
	let acc = IFACC + '.' + p, text = lib.readfile(acc);
	if (text == null)
		return !lib.is_file(acc);
	return lib.write_atomic(if_file(dir, p), text);
}

// ── commands ────────────────────────────────────────────────────────────────

const DISABLED = { ok: false, reason: 'disabled' };

function rows_count(text) {
	return length(filter(split(text, '\n'), (l) => l != '' && substr(l, 0, 1) != '#'));
}

function flush_locked(dir, p, file, now, src) {
	let sample;
	try {
		sample = totals_sample(src);
	}
	catch (e) {
		warn(sprintf('trafficctl history: no sample: %s\n', e.message));
		sample = null;
	}
	if (type(sample) != 'array') {
		err_set('totals produced nothing');
		return { out: { ok: false, reason: 'no sample' }, rc: 1 };
	}
	let st = load_rows(file);
	if (st == null) {
		// Nothing written and the cursor kept: this interval's growth is
		// folded in by the first flush that can read the period again.
		err_set('cannot read ' + file);
		return { out: { ok: false, reason: 'read failed', file }, rc: 1 };
	}
	let cur = load_cursor(CURSOR, 5);
	let next = fold(st, aggregate(sample, lookups()), cur, now);
	let text = rows_text(st);
	if (!lib.write_atomic(file, text)) {
		err_set('cannot write ' + file);
		return { out: { ok: false, reason: 'write failed', file }, rc: 1 };
	}
	// The cursor advances ONLY after the period file is in place: advancing
	// it first and then failing the write would discard the deltas for good,
	// where this way the same growth is folded in next time.
	lib.write_atomic(CURSOR, cursor_text(cur, next));
	lib.write_atomic(STAMP, sprintf('%d\n', now));
	err_clear();
	// After the device file is safely in place. Losing one interval of the
	// additive interface series is not a failed flush.
	// if_accumulate() has said why when it could not read the seed.
	if (!if_flush(dir, src, p) && !lib.is_file(ERRFILE))
		err_set('interface totals could not be written');
	return { out: { ok: true, period: p, devices: rows_count(text), at: now }, rc: 0 };
}

// The flush itself, run in the guarded child only.
function flush_now(src) {
	if (!enabled())
		return { out: DISABLED, rc: 0 };
	let dir = store_dir();
	if (!lib.mkdir_p(dir)) {
		err_set('cannot create ' + dir);
		return { out: { ok: false, reason: 'mkdir failed', dir }, rc: 1 };
	}
	if (!access(lib.path(dir), 'w')) {
		err_set(dir + ' is not writable');
		return { out: { ok: false, reason: 'not writable', dir }, rc: 1 };
	}
	let p = period_id(), file = period_file(dir, p), now = time();

	if (!lib.lock(LOCKD, LOCK_TRIES, LOCK_STALE, true))
		return { out: { ok: false, reason: 'locked' }, rc: 1 };
	let r;
	try {
		r = flush_locked(dir, p, file, now, src);
	}
	catch (e) {
		lib.unlock(LOCKD);
		die(e.message);
	}
	lib.unlock(LOCKD);
	return r;
}

// The flush the user, rpcd and the keeper ask for: in a child under the guard.
function flush() {
	if (!enabled())
		return { out: DISABLED, rc: 0 };
	let r = guarded([ 'history', 'flush-now' ]);
	let reply = child_reply(r);
	if (reply != null)
		return { out: reply + '\n', rc: (r.rc == 0) ? 0 : 1 };
	// timeout(1) exits 124 after its TERM; system() reports its own kill,
	// or any signal, as the negative signal number.
	if (r.rc == 124 || r.rc < 0) {
		err_set(sprintf('flush did not finish within %d s', have_timeout ? GUARD_SECS : GUARD_MS / 1000));
		return { out: { ok: false, reason: 'timed out' }, rc: 1 };
	}
	err_set(sprintf('flush exited with status %d and no reply', r.rc));
	return { out: { ok: false, reason: 'failed', status: r.rc }, rc: 1 };
}

function sample(src) {
	// Advance the accumulator and throw the JSON away: cheap, tmpfs only, and
	// what makes an hourly flush mean anything.
	if (!enabled())
		return { out: DISABLED, rc: 0 };
	try {
		totals_sample(src);
	}
	catch (e) {
		warn(sprintf('trafficctl history: no sample: %s\n', e.message));
	}
	// The interface series advances its own cursor on the same tick (#111).
	if_accumulate(src);
	return { out: { ok: true, at: time() }, rc: 0 };
}

function read(p_from, p_to) {
	let order = [], rows = {};
	for (let e in period_range(store_dir(), '.tsv', '.if.tsv', p_from, p_to)) {
		for (let l in lines_of(e.f)) {
			if (substr(l, 0, 1) == '#')
				continue;
			let f = split(l, '\t');
			if (length(f) < 10)
				continue;
			let k = f[0], r = rows[k], first = anum(f[8]), last = anum(f[9]);
			if (!r) {
				push(order, k);
				r = rows[k] = { mac: '', ip: '', name: null, rx: 0, tx: 0, tc: 0, ud: 0,
					first, last: 0, deg: false, periods: [] };
			}
			if (f[1] != '-')
				r.mac = f[1];
			r.ip = f[2];
			if (f[3] != '-')
				r.name = f[3];
			r.rx += anum(f[4]);
			r.tx += anum(f[5]);
			r.tc += anum(f[6]);
			r.ud += anum(f[7]);
			if (first < r.first)
				r.first = first;
			if (last > r.last)
				r.last = last;
			if (f[10] == 'true')
				r.deg = true;
			if (index(r.periods, e.p) < 0)
				push(r.periods, e.p);
		}
	}
	return map(order, (k) => {
		let r = rows[k];
		return { key: k, key_kind: (substr(k, 0, 4) == 'mac:') ? 'mac' : 'ip',
			mac: (r.mac != '') ? r.mac : '-', ip: r.ip, name: r.name ?? '',
			bytes_in: r.rx, bytes_out: r.tx, bytes_tcp: r.tc, bytes_udp: r.ud,
			first_seen: r.first, last_seen: r.last, degraded: r.deg, periods: r.periods };
	});
}

function if_read(p_from, p_to) {
	let order = [], rows = {};
	for (let e in period_range(store_dir(), '.if.tsv', null, p_from, p_to)) {
		for (let l in lines_of(e.f)) {
			if (substr(l, 0, 1) == '#')
				continue;
			let f = split(l, '\t');
			if (length(f) < 7)
				continue;
			let d = f[0], r = rows[d];
			if (!r) {
				push(order, d);
				r = rows[d] = { rx: 0, tx: 0, first: anum(f[5]), last: 0 };
			}
			r.role = f[1];
			r.label = f[2];
			r.rx += anum(f[3]);
			r.tx += anum(f[4]);
			if (anum(f[5]) < r.first)
				r.first = anum(f[5]);
			if (anum(f[6]) > r.last)
				r.last = anum(f[6]);
		}
	}
	return map(order, (d) => {
		let r = rows[d];
		return { dev: d, role: r.role, label: r.label, bytes_in: r.rx, bytes_out: r.tx,
			first_seen: r.first, last_seen: r.last };
	});
}

// A period is listed once, by its device file: "2026-10" and "2026-10.if"
// would both appear otherwise.
function periods() {
	let dir = store_dir(), out = [];
	for (let e in store_files(dir, '.tsv')) {
		if (substr(e, -7) == '.if.tsv')
			continue;
		let n = 0, bytes = 0;
		for (let l in lines_of(dir + '/' + e)) {
			if (substr(l, 0, 1) == '#')
				continue;
			n++;
			let f = split(l, '\t');
			if (length(f) >= 10)
				bytes += anum(f[4]) + anum(f[5]);
		}
		push(out, { period: substr(e, 0, -4), devices: n, bytes });
	}
	return out;
}

// A PERIOD is the unit of retention, and a period is two files: the device
// totals and the interface totals (#102). Periods are enumerated from the
// device files only (a "2026-10.if" period would never equal the current id
// and be pruned while its device file survived), then both files go. The
// current period is never a candidate: "keep 1" must not mean "delete the data
// being collected".
function prune() {
	let dir = store_dir(), k = keep(), cur = period_id(), dropped = 0;
	let ps = [];
	for (let e in lsdir(lib.path(dir)) ?? []) {
		if (length(e) <= 4 || substr(e, -4) != '.tsv' || substr(e, -7) == '.if.tsv')
			continue;
		if (stat(lib.path(dir + '/' + e))?.type != 'file')
			continue;
		let p = substr(e, 0, -4);
		// A period id, as rpcd validates it: an export.tsv someone saved
		// next to the store is not ours to delete.
		if (p != cur && match(p, PERIOD_RE))
			push(ps, p);
	}
	ps = sort(ps);
	for (let i = 0; i < length(ps) - k; i++) {
		if (unlink(lib.path(dir + '/' + ps[i] + '.tsv')))
			dropped++;
		unlink(lib.path(dir + '/' + ps[i] + '.if.tsv'));
	}
	return { ok: true, kept: k, dropped };
}

// What the stored numbers are worth right now, so a consumer labels the view
// instead of presenting a lower bound as a measurement:
//   degraded  uncountered offload: a LOWER BOUND
//   sampled   conntrack: exact to within flows shorter than sample_interval
function accuracy(mode) {
	return (mode == 'hardware' || mode == 'software') ? 'degraded' : 'sampled';
}

// The interface series' verdict. NOT the device one: an interface counter
// comes from the driver, which uncountered offload does not touch.
function if_accuracy() {
	return 'exact';
}

// The shell's `cut -f1` / `cut -f2-` of each line: a line without a tab is
// printed whole by both.
function err_fields() {
	let at = [], msg = [];
	for (let l in lines_of(ERRFILE)) {
		let i = index(l, '\t');
		push(at, (i < 0) ? l : substr(l, 0, i));
		push(msg, (i < 0) ? l : substr(l, i + 1));
	}
	return { at: join('\n', at), msg: join('\n', msg) };
}

function digits(s) {
	return (s != null && match(s, /^[0-9]+$/)) ? int(s) : 0;
}

function status() {
	let dir = store_dir(), mode = net.offload_mode();
	let last = digits(rtrim(lib.readfile(STAMP) ?? '', '\n'));
	let err = '', errat = 0;
	if (lib.is_file(ERRFILE)) {
		let e = err_fields();
		errat = digits(e.at);
		err = replace(e.msg, /["\\]/g, '');
	}
	let p = lib.path(dir);
	return {
		enabled: enabled(), dir,
		writable: stat(p)?.type == 'directory' && !!access(p, 'w'),
		period: period_id(), period_kind: period_kind(), interval: flush_interval(),
		sample_interval: sample_interval(), keep: keep(), format: FORMAT,
		last_flush: last, accuracy: accuracy(mode), offload: mode,
		interfaces: ifaces_enabled(), iface_accuracy: if_accuracy(),
		error: err, error_at: errat
	};
}

// The procd service loop. Two cadences in one process, which is why this is
// a service and not a cron line: sampling is frequent (accuracy note 2) and
// costs a tmpfs write, flushing is rare and touches durable storage.
//
// It re-reads its configuration every tick, so changing the interval in the
// UI takes effect without anyone knowing there is a service to restart. The
// flush and the prune run as guarded children: either can block on a dead
// mount, and the sampling must go on regardless.
function keeper() {
	// Where a previous run left off, so a restart does not reset the flush
	// clock and stretch the gap to the durable store.
	let last = digits(rtrim(lib.readfile(STAMP) ?? '', '\n'));
	for (let tick = 1; ; tick++) {
		net.reset();
		if (enabled()) {
			try {
				totals_sample();
			}
			catch (e) {
				warn(sprintf('trafficctl history: no sample: %s\n', e.message));
			}
			// Both series advance their tmpfs cursor on every tick; only
			// the durable store waits for the flush interval.
			if_accumulate();
			let now = time();
			// A clock that jumped backwards (NTP settling after boot, the
			// norm without an RTC) would park the next flush in the future.
			if (now < last)
				last = 0;
			if (now - last >= flush_interval()) {
				flush();
				guarded([ 'history', 'prune' ]);
				last = now;
			}
		}
		if (tick % GC_TICKS == 0)
			gc();
		sleep(sample_interval() * 1000);
	}
}

const USAGE = 'Usage: trafficctl history {sample|flush|keeper|validate-dir <path>|read [period [to]]|read-ifaces [period [to]]|periods|prune|status}\n';

function main(args, src) {
	switch (args[0]) {
	case 'sample':
		return sample(src);
	case 'flush':
		return flush();
	case 'flush-now':
		return flush_now(src);
	case 'keeper':
		keeper();
		return { out: null, rc: 0 };
	// Exposed so a caller validates against THIS rule rather than a copy that
	// can drift from it.
	case 'validate-dir': {
		let d = args[1] ?? '';
		if (substr(d, -1) == '/')
			d = substr(d, 0, -1);
		return { out: null, rc: valid_dir(d) ? 0 : 1 };
	}
	case 'read':
		return { out: read(args[1], args[2]), rc: 0 };
	case 'read-ifaces':
		return { out: if_read(args[1], args[2]), rc: 0 };
	case 'periods':
		return { out: periods(), rc: 0 };
	case 'prune':
		return { out: prune(), rc: 0 };
	case 'status':
		return { out: status(), rc: 0 };
	default:
		warn(USAGE);
		return { out: null, rc: 1 };
	}
}

// 2022-12 needs a ';' after `export function f() {}`; one list avoids it.
export { main, period_id, iso_week, valid_dir, accuracy, if_accuracy, keeper, if_accumulate,
	if_flush, sample };
