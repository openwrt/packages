'use strict';
'require form';
'require fs';
'require ui';
'require uci';
'require view';

return view.extend({
	load: function() {
		var self = this;
		return Promise.all([
			uci.load('sms_tool_js'),
			L.resolveDefault(fs.read('/tmp/sms_tool_call_log.json'), '{"calls":[]}'),
			L.resolveDefault(fs.list('/dev'), []).then(function(entries) {
				var ports = [];
				for (var i = 0; i < entries.length; i++) {
					if (entries[i].name && entries[i].name.match(/^ttyUSB/))
						ports.push('/dev/' + entries[i].name);
				}
				ports.sort();
				self._ports = ports;
			})
		]).then(function(data) {
			var callLogData;
			try {
				callLogData = JSON.parse(data[1] || '{"calls":[]}');
			} catch (e) {
				callLogData = { calls: [] };
			}
			self._calls = callLogData.calls || [];
		});
	},

	render: function() {
		var self = this;
		var m = new form.Map('sms_tool_js', _('Call Log'),
			_('View and manage modem call logs collected by the background daemon.'));

		var s = m.section(form.TypedSection, 'sms_tool_js');
		s.anonymous = true;
		s.addremove = false;

		s.tab('records', _('Call Records'));
		s.tab('daemon', _('Daemon Configuration'));

		var o = s.taboption('daemon', form.ListValue, 'callport', _('Call log reading port'),
			_('Select one of the available ttyUSBX ports.'));
		o.value('');
		for (var i = 0; i < this._ports.length; i++)
			o.value(this._ports[i]);

		o = s.taboption('daemon', form.Flag, 'calllog_enabled', _('Enable call log daemon'),
			_('Background process to log incoming and missed calls.'));
		o.rmempty = false;
		o.default = '0';
		o.write = function(section_id, value) {
			return uci.load('sms_tool_js').then(function() {
				if (value == '1') {
					uci.set('sms_tool_js', '@sms_tool_js[0]', 'calllog_enabled', '1');
					return uci.save().then(function() {
						return fs.exec_direct('/etc/init.d/sms_tool_calllogd', ['enable']);
					}).then(function() {
						return fs.exec_direct('/etc/init.d/sms_tool_calllogd', ['start']);
					});
				}
				if (value == '0') {
					uci.set('sms_tool_js', '@sms_tool_js[0]', 'calllog_enabled', '0');
					return uci.save().then(function() {
						return fs.exec_direct('/etc/init.d/sms_tool_calllogd', ['stop']);
					}).then(function() {
						return fs.exec_direct('/etc/init.d/sms_tool_calllogd', ['disable']);
					});
				}
			}.bind(this)).then(function() {
				return form.Flag.prototype.write.apply(this, [section_id, value]);
			}.bind(this));
		};

		o = s.taboption('records', form.DummyValue, '_call_records');
		o.rawhtml = true;
		o.render = function() {
			return self.renderRecords(self._calls);
		};

		return m.render();
	},

	renderRecords: function(calls) {
		var self = this;

		var filterOptions = [
			E('option', { 'value': 'all' }, _('All calls')),
			E('option', { 'value': 'missed' }, _('Missed calls')),
			E('option', { 'value': 'received' }, _('Received calls')),
			E('option', { 'value': 'dialed' }, _('Dialed calls'))
		];

		return E([], [
			E('table', { 'class': 'cbi-section-table' }, [
				E('tr', { 'class': 'cbi-section-table-row' }, [
					E('td', { 'class': 'cbi-value-field' }, [
						E('label', { 'class': 'cbi-value-title' }, _('Filter call type')),
						E('div', { 'class': 'cbi-value-control' }, [
							E('select', {
								'class': 'cbi-input-select',
								'id': 'call-log-type',
								'change': function() {
									var t = document.getElementById('callLogTable');
									if (t) {
										t.parentNode.replaceChild(
											self.renderCallLogTable(calls, this.value),
											t
										);
									}
								}
							}, filterOptions)
						])
					])
				])
			]),
			E('div', { 'class': 'right' }, [
				E('button', {
					'class': 'cbi-button cbi-button-neutral',
					'click': function() { window.location.reload(); }
				}, [ _('Refresh') ]),
				' ',
				E('button', {
					'class': 'cbi-button cbi-button-remove',
					'click': ui.createHandlerFn(this, '_handleClear')
				}, [ _('Clear Log') ])
			]),
			E('p'),
			this.renderCallLogTable(calls, 'all')
		]);
	},

	renderCallLogTable: function(calls, filter) {
		var table = E('table', { 'class': 'table', 'id': 'callLogTable' }, [
			E('tr', { 'class': 'tr table-titles' }, [
				E('th', { 'class': 'th' }, _('Date')),
				E('th', { 'class': 'th' }, _('Type')),
				E('th', { 'class': 'th' }, _('Number')),
				E('th', { 'class': 'th' }, _('Duration')),
				E('th', { 'class': 'th' }, _('Name'))
			])
		]);

		var hasRows = false;
		for (var i = 0; i < calls.length; i++) {
			if (filter && filter !== 'all' && (calls[i].type || '').toLowerCase() !== filter)
				continue;
			var row = table.insertRow(-1);
			row.insertCell(0).textContent = calls[i].date || '';
			row.insertCell(1).textContent = _(calls[i].type || '');
			row.insertCell(2).textContent = calls[i].number || '';
			row.insertCell(3).textContent = calls[i].duration || '';
			row.insertCell(4).textContent = '-';
			hasRows = true;
		}

		if (!hasRows) {
			var row = table.insertRow(-1);
			var cell = row.insertCell(0);
			cell.colSpan = 5;
			cell.style.textAlign = 'center';
			cell.textContent = _('No call log entries found');
		}

		return table;
	},

	_handleClear: function() {
		if (confirm(_('Clear all call log entries?'))) {
			return Promise.all([
				fs.write('/tmp/sms_tool_call_log.json', '{"calls":[]}'),
				fs.write('/tmp/sms_tool_call_log.lines', '')
			]).then(function() {
				window.location.reload();
			});
		}
	}
});
