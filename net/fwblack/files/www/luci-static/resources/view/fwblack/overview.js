'use strict';
'require view';
'require form';
'require fs';
'require ui';
'require uci';
'require rpc';

/* Backend: ubus object luci.fwblack (see /usr/share/rpcd/ucode/fwblack.uc).
 * Reads (status/blocked/lookup/log) and writes (unblock/svc/cache_clear)
 * are gated by /usr/share/rpcd/acl.d/luci-app-fwblack.json. */
var callStatus = rpc.declare({
	object: 'luci.fwblack',
	method: 'status'
});

var callBlocked = rpc.declare({
	object: 'luci.fwblack',
	method: 'blocked'
});

var callUnblock = rpc.declare({
	object: 'luci.fwblack',
	method: 'unblock',
	params: ['ip']
});

var callLookup = rpc.declare({
	object: 'luci.fwblack',
	method: 'lookup',
	params: ['ip']
});

var callLog = rpc.declare({
	object: 'luci.fwblack',
	method: 'log',
	params: ['lines']
});

var callSvc = rpc.declare({
	object: 'luci.fwblack',
	method: 'svc',
	params: ['action']
});

var callCacheClear = rpc.declare({
	object: 'luci.fwblack',
	method: 'cache_clear'
});

function validDomainFragment(s) {
	return /^[A-Za-z0-9._*\-]+$/.test(s);
}

function validIpInput(s) {
	return /^([0-9]{1,3}\.){3}[0-9]{1,3}$/.test(s) ||
		/^[0-9A-Fa-f:.]+$/.test(s) && s.indexOf(':') >= 0;
}

return view.extend({
	blocklistText: '',
	statusData: null,
	blockedData: null,

	load: function() {
		return Promise.all([
			uci.load('fwblack'),
			L.resolveDefault(fs.read('/etc/fwblack/blocklist.cfg'), ''),
			L.resolveDefault(callStatus(), null),
			L.resolveDefault(callBlocked(), null)
		]);
	},

	backendAvailable: function() {
		return (this.statusData != null && this.statusData.error == null);
	},

	/* ---------- helpers ---------- */

	notifyOk: function(msg) {
		ui.addNotification(null, E('p', [msg]), 'info');
	},

	notifyErr: function(msg) {
		ui.addNotification(null, E('p', [msg]));
	},

	countBlocklist: function(text) {
		var entries = 0, comments = 0, invalid = [];
		var lines = (text || '').split('\n');
		for (var i = 0; i < lines.length; i++) {
			var line = lines[i].replace(/[\r \t]/g, '');
			if (line === '')
				continue;
			if (line.charAt(0) === '#') {
				comments++;
				continue;
			}
			var e = line.split('#')[0].toLowerCase();
			if (e === '')
				continue;
			if (validDomainFragment(e))
				entries++;
			else if (invalid.length < 5)
				invalid.push(line);
		}
		return { entries: entries, comments: comments, invalid: invalid };
	},

	refreshDynamic: function() {
		var view = this;
		return Promise.all([
			L.resolveDefault(callStatus(), null),
			L.resolveDefault(callBlocked(), null)
		]).then(function(res) {
			view.statusData = res[0];
			view.blockedData = res[1];
			view.renderStatusLine();
			view.renderBlockedTable();
		});
	},

	/* ---------- blocked IPs section ---------- */

	renderBlockedTable: function() {
		var data = this.blockedData;
		if (data == null || data.error != null || data.blocked == null) {
			cbi_update_table(this.blockedTable, [],
				_('Backend unavailable — is luci-app-fwblack installed and rpcd reloaded?'));
		}
		else if (data.blocked.length === 0) {
			cbi_update_table(this.blockedTable, [],
				_('No blocked IPs. Matches appear here after the next scan cycle.'));
		}
		else {
			var rows = [];
			for (var i = 0; i < data.blocked.length; i++) {
				var row = data.blocked[i];
				var src = row.in_file ? (row.in_set ? _('file + nft set') : _('file only')) : _('nft set only');
				rows.push([
					row.ip,
					src + (row.family ? ' (' + row.family + ')' : ''),
					E('div', {}, [
						E('button', {
							'class': 'btn cbi-button-negative',
							'click': ui.createHandlerFn(this, 'handleUnblock', row.ip)
						}, _('Unblock')),
						' ',
						E('button', {
							'class': 'btn cbi-button-action',
							'click': ui.createHandlerFn(this, 'handleLookupFill', row.ip)
						}, _('Lookup'))
					])
				]);
			}
			cbi_update_table(this.blockedTable, rows);
		}
		var st = this.statusData;
		this.blockedSummary.textContent = (data != null && data.count != null)
			? _('Total: %d blocked').format(data.count) +
			  (st != null ? _(' (nft sets: %d v4 + %d v6)').format(st.set_v4_count || 0, st.set_v6_count || 0) : '')
			: '';
	},

	handleUnblock: function(ip, ev) {
		var view = this;
		var btn = ev.currentTarget;
		btn.classList.add('spinning');
		btn.disabled = true;
		return L.resolveDefault(callUnblock(ip), null).then(function(res) {
			if (res != null && res.ok)
				view.notifyOk(_('Unblocked %s (file: %s, nft set: %s)').format(
					ip, res.removed_file ? _('yes') : _('no'), res.removed_set ? _('yes') : _('no')));
			else
				view.notifyErr(_('Failed to unblock %s: %s').format(ip, (res && res.error) || _('unknown error')));
			return view.refreshDynamic();
		}).catch(function(e) {
			view.notifyErr(_('Failed to unblock %s: %s').format(ip, e.message || e));
		}).finally(function() {
			btn.classList.remove('spinning');
			btn.disabled = false;
		});
	},

	handleUnblockAll: function(ev) {
		var view = this;
		var data = this.blockedData;
		if (data == null || data.blocked == null || data.blocked.length === 0) {
			view.notifyOk(_('Nothing to unblock.'));
			return Promise.resolve();
		}
		if (!confirm(_('Unblock all %d IPs?').format(data.blocked.length)))
			return Promise.resolve();
		var chain = Promise.resolve();
		data.blocked.forEach(function(row) {
			chain = chain.then(function() {
				return L.resolveDefault(callUnblock(row.ip), null);
			});
		});
		return chain.then(function() {
			view.notifyOk(_('All blocked IPs removed.'));
			return view.refreshDynamic();
		}).catch(function(e) {
			view.notifyErr(_('Unblock-all failed: %s').format(e.message || e));
		});
	},

	/* ---------- diagnostics section ---------- */

	renderStatusLine: function() {
		var st = this.statusData;
		if (st == null || st.error != null) {
			this.svcStatus.textContent = _('Backend unavailable');
			return;
		}
		this.svcStatus.textContent = _('Daemon: %s | Boot: %s | nft sets: %d v4 + %d v6 | File: %d | Blocklist: %d entries | DNS cache: %d entries').format(
			st.running ? _('running (pid %d)').format(st.pid || 0) : _('stopped'),
			st.enabled ? _('enabled') : _('disabled'),
			st.set_v4_count || 0, st.set_v6_count || 0,
			st.file_count || 0, st.blocklist_entries || 0, st.cache_entries || 0);
	},

	handleSvc: function(action, ev) {
		var view = this;
		return L.resolveDefault(callSvc(action), null).then(function(res) {
			if (res != null && res.ok)
				view.notifyOk(_('Service %s: OK').format(action));
			else
				view.notifyErr(_('Service %s failed: %s').format(action, (res && (res.error || res.output)) || _('unknown error')));
			return view.refreshDynamic();
		}).catch(function(e) {
			view.notifyErr(_('Service %s failed: %s').format(action, e.message || e));
		});
	},

	handleLookupFill: function(ip) {
		this.lookupInput.value = ip;
		return this.handleLookup();
	},

	handleLookup: function() {
		var view = this;
		var ip = (this.lookupInput.value || '').trim();
		if (!validIpInput(ip)) {
			view.notifyErr(_('Enter a valid IPv4 or IPv6 address.'));
			return Promise.resolve();
		}
		view.lookupResult.textContent = _('Looking up %s…').format(ip);
		return L.resolveDefault(callLookup(ip), null).then(function(res) {
			if (res == null || res.error != null) {
				view.lookupResult.textContent = _('Lookup failed: %s').format((res && res.error) || _('backend error'));
				return;
			}
			var names = (res.names && res.names.length) ? res.names.join(', ') : _('(no reverse DNS)');
			var verdict = res.blocked
				? _('BLOCKED — matches: %s').format(res.matched.join(', '))
				: _('not blocked');
			view.lookupResult.textContent = _('%s → %s — %s').format(res.ip, names, verdict);
		}).catch(function(e) {
			view.lookupResult.textContent = _('Lookup failed: %s').format(e.message || e);
		});
	},

	handleShowLog: function() {
		var view = this;
		var n = parseInt(this.logLines.value, 10) || 50;
		view.logArea.value = _('Loading…');
		return L.resolveDefault(callLog(n), null).then(function(res) {
			if (res != null && res.lines != null)
				view.logArea.value = res.lines.length ? res.lines.join('\n') : _('(no fwblack log lines yet — the daemon only logs scans and errors)');
			else
				view.logArea.value = _('Failed to read log: %s').format((res && res.error) || _('backend error'));
		}).catch(function(e) {
			view.logArea.value = _('Failed to read log: %s').format(e.message || e);
		});
	},

	handleCacheClear: function() {
		var view = this;
		return L.resolveDefault(callCacheClear(), null).then(function(res) {
			if (res != null && res.ok)
				view.notifyOk(_('DNS cache cleared. Next cycle re-resolves.'));
			else
				view.notifyErr(_('Failed to clear cache.'));
			return view.refreshDynamic();
		}).catch(function(e) {
			view.notifyErr(_('Failed to clear cache: %s').format(e.message || e));
		});
	},

	/* ---------- main render ---------- */

	render: function(data) {
		var view = this;
		var m, s, o;

		this.blocklistText = data[1] || '';
		this.statusData = data[2];
		this.blockedData = data[3];

		m = new form.Map('fwblack', _('fw.black'),
			_('DNS-based firewall blocklist (nftables). Watches connections, reverse-resolves public IPs, drops TCP 80/443 toward matches in sets blacklist_v4/v6. Inspect via: nft list table inet fwblack.'));

		/* ----- settings + blocklist (UCI/file backed, handled by cbi) ----- */
		s = m.section(form.TypedSection, 'main', _('Configuration'));
		s.anonymous = true;
		s.tab('settings', _('Daemon settings'));
		s.tab('blocklist', _('Blocklist'));

		o = s.option(form.Flag, 'enabled', _('Enabled'));
		o.tab = 'settings';
		o.default = '1';
		o.rmempty = false;

		o = s.option(form.Value, 'interval', _('Scan interval (s)'),
			_('Seconds between conntrack scans. Default 300.'));
		o.tab = 'settings';
		o.datatype = 'uinteger';
		o.default = '300';

		o = s.option(form.Value, 'interval_jitter', _('Interval jitter (s)'),
			_('Random extra 0..N seconds to desync DNS bursts. Default 30.'));
		o.tab = 'settings';
		o.datatype = 'uinteger';
		o.default = '30';

		o = s.option(form.Value, 'blocklist', _('Blocklist path'),
			_('Flat file, one domain fragment per line. Default /etc/fwblack/blocklist.cfg.'));
		o.tab = 'settings';
		o.default = '/etc/fwblack/blocklist.cfg';

		o = s.option(form.Value, 'table', _('nft table'));
		o.tab = 'settings';
		o.default = 'fwblack';
		o.optional = true;

		o = s.option(form.Value, 'set_v4', _('nft set (v4)'));
		o.tab = 'settings';
		o.default = 'blacklist_v4';
		o.optional = true;

		o = s.option(form.Value, 'set_v6', _('nft set (v6)'));
		o.tab = 'settings';
		o.default = 'blacklist_v6';
		o.optional = true;

		o = s.option(form.Value, 'chain', _('nft chain'));
		o.tab = 'settings';
		o.default = 'forward_black';
		o.optional = true;

		o = s.option(form.Value, 'cache_ttl_pos', _('DNS cache TTL, positive (s)'));
		o.tab = 'settings';
		o.datatype = 'uinteger';
		o.default = '86400';
		o.optional = true;

		o = s.option(form.Value, 'cache_ttl_neg', _('DNS cache TTL, negative (s)'));
		o.tab = 'settings';
		o.datatype = 'uinteger';
		o.default = '3600';
		o.optional = true;

		var cnt = this.countBlocklist(this.blocklistText);

		o = s.option(form.DummyValue, '_counts', _('Contents'));
		o.tab = 'blocklist';
		o.cfgvalue = function() {
			return _('Entries: %d | Comments: %d').format(cnt.entries, cnt.comments) +
				(cnt.invalid.length ? _(' | Invalid lines (fix before saving): %s').format(cnt.invalid.join(', ')) : '');
		};

		o = s.option(form.TextValue, '_data', _('Domains (one per line)'),
			_('Literal substring match against reverse DNS (case-insensitive). Lines starting with # are comments; trailing "# comment" allowed. Saved to /etc/fwblack/blocklist.cfg on Save & Apply — the daemon picks it up on its next cycle.'));
		o.tab = 'blocklist';
		o.rows = 14;
		o.monospace = true;
		o.cfgvalue = function() {
			return view.blocklistText;
		};
		o.validate = function(section_id, value) {
			var bad = [];
			var lines = (value || '').split('\n');
			for (var i = 0; i < lines.length; i++) {
				var line = lines[i].replace(/[\r \t]/g, '');
				if (line === '' || line.charAt(0) === '#')
					continue;
				var e = line.split('#')[0].toLowerCase();
				if (e === '' || !validDomainFragment(e))
					bad.push('%d: %s'.format(i + 1, lines[i]));
				if (bad.length >= 5)
					break;
			}
			if (bad.length > 0)
				return _('Invalid entries (allowed: letters, digits, dot, hyphen, underscore, *): %s').format(bad.join('; '));
			return true;
		};
		o.write = function(section_id, value) {
			if (value == null)
				value = '';
			if (value !== '' && value.charAt(value.length - 1) !== '\n')
				value += '\n';
			return fs.write('/etc/fwblack/blocklist.cfg', value).then(function() {
				view.blocklistText = value;
			}).catch(function(e) {
				ui.addNotification(null, E('p', _('Failed to save blocklist: ') + (e.message || e)));
				throw e;
			});
		};
		o.remove = function() {};

		/* ----- render map, then append live sections ----- */
		return m.render().then(function(mapEl) {
			var wrap = E('div', {}, [mapEl]);

			/* Blocked IPs */
			view.blockedSummary = E('p', { 'class': 'cbi-value-description' });
			view.blockedTable = E('table', { 'class': 'table' }, [
				E('tr', { 'class': 'tr table-titles' }, [
					E('th', { 'class': 'th' }, [_('IP address')]),
					E('th', { 'class': 'th' }, [_('Source')]),
					E('th', { 'class': 'th cbi-section-actions' }, [_('Actions')])
				])
			]);
			wrap.appendChild(E('div', { 'class': 'cbi-section' }, [
				E('h3', {}, [_('Blocked IPs')]),
				view.blockedSummary,
				view.blockedTable,
				E('div', { 'class': 'cbi-page-actions' }, [
					E('button', {
						'class': 'btn cbi-button-action',
						'click': ui.createHandlerFn(view, 'refreshDynamic')
					}, _('Refresh')),
					' ',
					E('button', {
						'class': 'btn cbi-button-negative',
						'click': ui.createHandlerFn(view, 'handleUnblockAll')
					}, _('Unblock all'))
				])
			]));
			view.renderBlockedTable();

			/* Diagnostics */
			view.svcStatus = E('p', { 'class': 'cbi-value-description' });
			view.lookupInput = E('input', {
				'class': 'cbi-input-text',
				'placeholder': '8.8.8.8',
				'style': 'width:12em'
			});
			view.lookupResult = E('p', { 'class': 'cbi-value-description' });
			view.logLines = E('input', {
				'class': 'cbi-input-text',
				'value': '50',
				'style': 'width:4em'
			});
			view.logArea = E('textarea', {
				'readonly': 'readonly',
				'rows': 10,
				'style': 'width:100%;font-family:monospace',
				'placeholder': _('Daemon log appears here')
			});
			wrap.appendChild(E('div', { 'class': 'cbi-section' }, [
				E('h3', {}, [_('Diagnostics')]),
				E('h4', {}, [_('Service')]),
				view.svcStatus,
				E('div', { 'class': 'cbi-page-actions' }, [
					E('button', { 'class': 'btn cbi-button-action', 'click': ui.createHandlerFn(view, 'handleSvc', 'start') }, _('Start')),
					' ',
					E('button', { 'class': 'btn cbi-button-action', 'click': ui.createHandlerFn(view, 'handleSvc', 'stop') }, _('Stop')),
					' ',
					E('button', { 'class': 'btn cbi-button-action', 'click': ui.createHandlerFn(view, 'handleSvc', 'restart') }, _('Restart')),
					' ',
					E('button', { 'class': 'btn cbi-button-action', 'click': ui.createHandlerFn(view, 'handleSvc', 'reload') }, _('Reload')),
					' ',
					E('button', { 'class': 'btn cbi-button-positive', 'click': ui.createHandlerFn(view, 'handleSvc', 'enable') }, _('Enable')),
					' ',
					E('button', { 'class': 'btn cbi-button-negative', 'click': ui.createHandlerFn(view, 'handleSvc', 'disable') }, _('Disable')),
					' ',
					E('button', { 'class': 'btn cbi-button-action', 'click': ui.createHandlerFn(view, 'handleCacheClear') }, _('Clear DNS cache'))
				]),
				E('h4', {}, [_('Reverse-DNS test')]),
				E('p', {}, [_('Check what the daemon would do with an IP (no changes made).')]),
				E('div', {}, [
					view.lookupInput,
					' ',
					E('button', { 'class': 'btn cbi-button-action', 'click': ui.createHandlerFn(view, 'handleLookup') }, _('Test lookup'))
				]),
				view.lookupResult,
				E('h4', {}, [_('Log')]),
				E('div', {}, [
					_('Lines: '),
					view.logLines,
					' ',
					E('button', { 'class': 'btn cbi-button-action', 'click': ui.createHandlerFn(view, 'handleShowLog') }, _('Show log'))
				]),
				E('p', {}, [view.logArea]),
				E('p', {}, [E('em', {}, [_('Inspect directly: nft list table inet fwblack')])])
			]));
			view.renderStatusLine();

			return wrap;
		});
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
