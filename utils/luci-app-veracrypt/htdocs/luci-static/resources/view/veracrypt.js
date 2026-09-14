'use strict';
'require view';
'require form';
'require uci';
'require rpc';
'require ui';
'require poll';

var callStatus = rpc.declare({
	object: 'luci.veracrypt',
	method: 'status'
});

var callListDev = rpc.declare({
	object: 'luci.veracrypt',
	method: 'listdev'
});

var RUN_PARAMS = [
	'action', 'name', 'volume', 'mountpoint', 'password', 'new_password',
	'pim', 'new_pim', 'hash', 'new_hash', 'encryption', 'filesystem',
	'fs_options', 'keyfiles', 'new_keyfiles', 'protect_hidden',
	'protection_password', 'protection_pim', 'protection_hash',
	'protection_keyfiles', 'slot', 'size', 'volume_type', 'random_source',
	'token_lib', 'token_pin', 'mount_options', 'auto_mount', 'force',
	'quick', 'verbose', 'no_size_check', 'legacy_password_maxlength',
	'allow_insecure_mount', 'fsck_auto'
];

function timeoutSec() {
	var t = parseInt(uci.get('veracrypt', 'main', 'timeout'), 10);
	if (isNaN(t) || t < 300)
		t = 300;
	return t;
}

function fmtClock(sec) {
	if (sec < 0)
		sec = 0;
	var m = Math.floor(sec / 60);
	var s = sec % 60;
	return '%d:%02d'.format(m, s);
}

function callRunWithTimeout() {
	return rpc.declare({
		object: 'luci.veracrypt',
		method: 'run',
		timeout: timeoutSec() * 1000,
		params: RUN_PARAMS
	});
}

function callJobWithTimeout() {
	return rpc.declare({
		object: 'luci.veracrypt',
		method: 'job',
		timeout: Math.min(30000, timeoutSec() * 1000)
	});
}

var callTools = rpc.declare({
	object: 'luci.veracrypt',
	method: 'tools'
});

var callJobAnswer = rpc.declare({
	object: 'luci.veracrypt',
	method: 'job_answer',
	params: [ 'answer' ]
});

function packagesForFs(fs) {
	switch (fs) {
		case 'ext4':
		case 'ext3':
		case 'ext2':
			return [ 'lvm2', 'e2fsprogs', 'kmod-fs-ext4' ];
		case 'vfat':
			return [ 'lvm2', 'dosfstools', 'kmod-fs-vfat' ];
		case 'ntfs':
			return [ 'lvm2', 'ntfs-3g', 'kmod-fs-ntfs3' ];
		case 'exfat':
			return [ 'lvm2', 'exfatprogs', 'kmod-fs-exfat' ];
		default:
			return [];
	}
}

function packagesForFsck(fs) {
	switch (fs) {
		case 'ext4':
		case 'ext3':
		case 'ext2':
			return [ 'e2fsprogs' ];
		case 'vfat':
			return [ 'dosfstools' ];
		case 'ntfs':
			return [ 'ntfs-3g' ];
		case 'exfat':
			return [ 'exfatprogs' ];
		default:
			return [ 'e2fsprogs' ];
	}
}

function fsckToolsReady(t, fs) {
	if (!t)
		return false;
	if (!fs || fs === 'none')
		return !!(t.has_e2fsck || t.has_fsck_ext4 || t.has_fsck_fat || t.has_fsck_exfat || t.has_ntfsfix || t.has_fsck);
	if (fs === 'ext4' || fs === 'ext3' || fs === 'ext2')
		return !!(t.has_e2fsck || t.has_fsck_ext4);
	if (fs === 'vfat')
		return !!t.has_fsck_fat;
	if (fs === 'ntfs')
		return !!t.has_ntfsfix;
	if (fs === 'exfat')
		return !!t.has_fsck_exfat;
	return !!t.has_fsck;
}

function toolsReady(t, fs) {
	if (!fs || fs === 'none')
		return true;
	if (!t || !t.has_dmsetup)
		return false;
	if ((fs === 'ext4' || fs === 'ext3' || fs === 'ext2') && !t.has_mkfs_ext4)
		return false;
	if (fs === 'vfat' && !t.has_mkfs_vfat)
		return false;
	if (fs === 'ntfs' && !t.has_mkfs_ntfs)
		return false;
	if (fs === 'exfat' && !t.has_mkfs_exfat)
		return false;
	return true;
}

function installPackages(list) {
	var limit = timeoutSec();
	var statusEl = E('p');
	var elapsed = 0;
	var left = limit;
	function paint() {
		statusEl.textContent = _('apk add %s — elapsed %s, timeout in %s').format(list.join(' '), fmtClock(elapsed), fmtClock(left));
	}
	ui.showModal(_('Install packages'), [ statusEl ]);
	paint();
	var iv = window.setInterval(function() {
		elapsed++;
		left--;
		paint();
	}, 1000);
	var inst = rpc.declare({
		object: 'luci.veracrypt',
		method: 'pkg_install',
		timeout: limit * 1000,
		params: [ 'packages' ]
	});
	return inst(list.join(' ')).then(function(res) {
		if (res && res.pending)
			return waitJob(left, statusEl);
		return res;
	}).then(function(res) {
		window.clearInterval(iv);
		ui.hideModal();
		showResult(res);
		return res && res.ok !== false;
	}).catch(function(err) {
		window.clearInterval(iv);
		ui.hideModal();
		ui.addNotification(null, E('p', err.message || String(err)), 'error');
		return false;
	});
}

function ensureFsPackages(o) {
	if (o.action !== 'create')
		return Promise.resolve(true);
	var fs = o.filesystem || 'none';
	var pkgs = packagesForFs(fs);
	if (!pkgs.length)
		return Promise.resolve(true);
	return callTools().then(function(t) {
		if (toolsReady(t, fs))
			return true;
		return new Promise(function(resolve) {
			ui.showModal(_('Missing tools for %s').format(fs), [
				E('p', _('Creating a volume with an inner %s filesystem needs: %s (dmsetup from lvm2, mkfs, and the kmod). Install with apk add, or create with filesystem=none and format after mount.').format(fs, pkgs.join(' '))),
				E('div', { 'class': 'right' }, [
					E('button', {
						'class': 'btn',
						'click': function() { ui.hideModal(); resolve(false); }
					}, _('Cancel')),
					' ',
					E('button', {
						'class': 'btn',
						'click': function() {
							ui.hideModal();
							o.filesystem = 'none';
							resolve(true);
						}
					}, _('Create with filesystem=none')),
					' ',
					E('button', {
						'class': 'btn cbi-button-apply',
						'click': function() {
							ui.hideModal();
							installPackages(pkgs).then(function(ok) { resolve(ok); });
						}
					}, _('apk add and continue'))
				])
			]);
		});
	});
}

function ensureFsckPackages(o) {
	if (o.action !== 'fsck')
		return Promise.resolve(true);
	var fs = o.filesystem || '';
	var pkgs = packagesForFsck(fs);
	return callTools().then(function(t) {
		if (fsckToolsReady(t, fs))
			return true;
		return new Promise(function(resolve) {
			ui.showModal(_('Missing fsck tools'), [
				E('p', _('Checking a volume cannot be done without the matching fsck tool. The app decrypts with --filesystem=none, runs fsck on the mapper or loop device, then dismounts. Install: %s (e2fsprogs for ext*, dosfstools for FAT, exfatprogs for exFAT, ntfs-3g for NTFS).').format(pkgs.join(' '))),
				E('div', { 'class': 'right' }, [
					E('button', {
						'class': 'btn',
						'click': function() { ui.hideModal(); resolve(false); }
					}, _('Cancel')),
					' ',
					E('button', {
						'class': 'btn cbi-button-apply',
						'click': function() {
							ui.hideModal();
							installPackages(pkgs).then(function(ok) { resolve(ok); });
						}
					}, _('apk add'))
				])
			]);
		});
	});
}

function showResult(res) {
	var err = res && res.error ? String(res.error) : '';
	if (err.indexOf('PKCS') !== -1 || err.indexOf('Security Tokens') !== -1)
		err = _('No PKCS #11 library loaded. Set the library path under Timeouts → Security token library (for example /usr/lib/libykcs11.so). This app has no Settings > Security Tokens.');
	if (res && res.need_packages) {
		var pkgs = String(res.need_packages).split(/[\s,]+/).filter(Boolean);
		ui.showModal(_('Missing fsck tools'), [
			E('pre', err || _('Checking a volume cannot be done without the matching fsck tool.')),
			E('p', _('apk add %s').format(pkgs.join(' '))),
			E('div', { 'class': 'right' }, [
				E('button', { 'class': 'btn', 'click': ui.hideModal }, _('Cancel')),
				' ',
				E('button', {
					'class': 'btn cbi-button-apply',
					'click': function() {
						ui.hideModal();
						installPackages(pkgs);
					}
				}, _('apk add'))
			])
		]);
		return;
	}
	if (!res || res.ok === false)
		ui.addNotification(null, E('pre', err || _('Command failed')), 'error');
	else if (res.output)
		ui.addNotification(null, E('pre', res.output), 'info');
	else
		ui.addNotification(null, E('p', _('OK')), 'info');
}

function field(type, attrs) {
	attrs = attrs || {};
	attrs.type = type || 'text';
	attrs.style = (attrs.style || '') + ';width:100%';
	return E('input', attrs);
}

function select(values, cur) {
	var s = E('select', { 'style': 'width:100%' });
	values.forEach(function(v) {
		var val = Array.isArray(v) ? v[0] : v;
		var lab = Array.isArray(v) ? v[1] : v;
		var opt = E('option', { 'value': val }, lab);
		if (String(cur) === String(val))
			opt.selected = true;
		s.appendChild(opt);
	});
	return s;
}

function pathRow(label, value, dirsOnly) {
	var inp = field('text', {
		'value': value || '',
		'placeholder': dirsOnly ? '/mnt/Buffalo' : '/mnt/sda2/media.tc'
	});
	var holder = E('div');
	var fu = new ui.FileUpload(value || '', {
		root_directory: '/',
		initial_directory: '/mnt',
		show_hidden: true,
		enable_upload: false,
		enable_remove: false,
		enable_download: false,
		directory_create: true,
		directory_select: !!dirsOnly
	});
	Promise.resolve(fu.render()).then(function(el) {
		holder.appendChild(el);
		el.addEventListener('cbi-fileupload-select', function(ev) {
			if (ev.detail && ev.detail.path)
				inp.value = ev.detail.path;
		});
	});
	return {
		node: E('div', { 'class': 'cbi-value' }, [
			E('label', { 'class': 'cbi-value-title' }, label),
			E('div', { 'class': 'cbi-value-field' }, [
				E('p', { 'class': 'cbi-map-descr' },
					dirsOnly
						? _('Type the mount directory, or browse and click Select on the folder (opening a folder is not the same as selecting it).')
						: _('Type the container path, or browse and click the file.')
				),
				inp,
				holder
			])
		]),
		getValue: function() {
			var typed = (inp.value || '').trim();
			if (typed)
				return typed;
			try {
				return fu.getValue() || '';
			}
			catch (e) {
				return value || '';
			}
		}
	};
}

function val(el) {
	return el && el.value != null ? String(el.value) : '';
}

function flag(el) {
	return el && el.checked ? '1' : '';
}

function waitJob(limit, statusEl, logEl) {
	var left = limit;
	var elapsed = 0;
	var job = callJobWithTimeout();

	function paint() {
		statusEl.textContent = _('Working… elapsed %s. Operation will time out in %s. Header derivation and random generation can take several minutes on a slow CPU with little RAM.').format(fmtClock(elapsed), fmtClock(left));
	}
	paint();

	var iv = window.setInterval(function() {
		elapsed++;
		left--;
		paint();
	}, 1000);

	function poll() {
		if (left <= 0) {
			window.clearInterval(iv);
			return {
				ok: false,
				error: _('Timed out after %s. veracrypt may still be running on the router.').format(fmtClock(limit))
			};
		}
		return job().then(function(res) {
			if (logEl && res && res.output)
				logEl.textContent = res.output;
			if (res && res.pending)
				return new Promise(function(resolve) {
					window.setTimeout(function() { resolve(poll()); }, 2000);
				});
			window.clearInterval(iv);
			return res;
		}).catch(function(err) {
			window.clearInterval(iv);
			throw err;
		});
	}
	return poll();
}

function runAction(opts) {
	var limit = timeoutSec();
	var statusEl = E('p');
	var elapsed = 0;
	var left = limit;
	function paint() {
		statusEl.textContent = _('Working… elapsed %s. Operation will time out in %s. Header derivation and random generation can take several minutes on a slow CPU with little RAM.').format(fmtClock(elapsed), fmtClock(left));
	}
	var logEl = E('pre', { 'style': 'max-height:220px;overflow:auto;white-space:pre-wrap' });
	var ynBox = E('p');
	if (opts.action === 'fsck' && opts.fsck_auto !== '1') {
		ynBox.appendChild(E('p', { 'class': 'cbi-map-descr' },
			_('fsck is interactive. Press y or n for each prompt.')));
		ynBox.appendChild(E('button', {
			'class': 'btn cbi-button-apply',
			'click': function() { callJobAnswer('y'); }
		}, _('y')));
		ynBox.appendChild(E('span', {}, ' '));
		ynBox.appendChild(E('button', {
			'class': 'btn',
			'click': function() { callJobAnswer('n'); }
		}, _('n')));
	}
	ui.showModal(_('VeraCrypt'), [
		statusEl,
		ynBox,
		logEl,
		E('p', { 'class': 'cbi-map-descr' },
			_('XHR timeout is %d seconds (minimum 300). Change it under Timeouts, then Save & Apply.').format(limit))
	]);
	paint();
	var iv = window.setInterval(function() {
		elapsed++;
		left--;
		paint();
	}, 1000);
	var run = callRunWithTimeout();
	return run(
		opts.action || '', opts.name || '', opts.volume || '', opts.mountpoint || '',
		opts.password || '', opts.new_password || '', opts.pim || '', opts.new_pim || '',
		opts.hash || '', opts.new_hash || '', opts.encryption || '', opts.filesystem || '',
		opts.fs_options || '', opts.keyfiles || '', opts.new_keyfiles || '',
		opts.protect_hidden || '', opts.protection_password || '', opts.protection_pim || '',
		opts.protection_hash || '', opts.protection_keyfiles || '', opts.slot || '',
		opts.size || '', opts.volume_type || '', opts.random_source || '',
		opts.token_lib || '', opts.token_pin || '', opts.mount_options || '',
		opts.auto_mount || '', opts.force || '', opts.quick || '', opts.verbose || '',
		opts.no_size_check || '', opts.legacy_password_maxlength || '',
		opts.allow_insecure_mount || '', opts.fsck_auto || ''
	).then(function(res) {
		if (res && res.pending)
			return waitJob(left, statusEl, logEl);
		return res;
	}).then(function(res) {
		window.clearInterval(iv);
		ui.hideModal();
		showResult(res);
		return res;
	}).catch(function(err) {
		window.clearInterval(iv);
		ui.hideModal();
		ui.addNotification(null, E('p', err.message || String(err)), 'error');
	});
}

var HASHES = [ '', 'sha-512', 'sha-256', 'ripemd160', 'whirlpool', 'streebog' ];
var CIPHERS = [ '', 'AES', 'Serpent', 'Twofish', 'Camellia', 'Kuznyechik',
	'AES-Twofish', 'AES-Twofish-Serpent', 'Serpent-AES', 'Serpent-Twofish-AES',
	'Twofish-Serpent' ];
var FSTYPES = [ '', 'ext4', 'ext3', 'ext2', 'vfat', 'ntfs', 'exfat', 'none' ];
var VTYPES = [ '', 'normal', 'hidden' ];

function slotSelect(cur) {
	var opts = [ [ '', _('(none)') ] ];
	for (var i = 1; i <= 64; i++)
		opts.push([ String(i), String(i) ]);
	return select(opts, cur || '');
}

function sectionName(sid) {
	return uci.get('veracrypt', sid, '.name') || sid;
}

return view.extend({
	load: function() {
		return uci.load('veracrypt').then(function() {
			if (!uci.get('veracrypt', 'main')) {
				uci.add('veracrypt', 'settings', 'main');
				uci.set('veracrypt', 'main', 'timeout', '300');
			}
			return callStatus();
		}).then(function(st) {
			return [ true, st ];
		});
	},

	render: function(data) {
		var st = data[1] || {};
		var status = {};
		(st.volumes || []).forEach(function(v) {
			status[v.name] = v;
		});
		var slots = st.slots || [];
		var m, s, o;

		var body = E('div');

		body.appendChild(E('h3', _('Slots')));
		body.appendChild(E('p', { 'class': 'cbi-map-descr' },
			_('Used slots plus one empty slot. Open file picks a container; open device lists /dev/sd*, nvme, mmc, mapper.')));
		if (st.version)
			body.appendChild(E('p', {}, st.version));

		var table = E('table', { 'class': 'table' }, [
			E('tr', { 'class': 'tr table-titles' }, [
				E('th', { 'class': 'th' }, _('Slot')),
				E('th', { 'class': 'th' }, _('Volume')),
				E('th', { 'class': 'th' }, _('Actions'))
			])
		]);
		(slots || []).forEach(function(sl) {
			if (!sl.used)
				return;
			table.appendChild(E('tr', { 'class': 'tr' }, [
				E('td', { 'class': 'td' }, String(sl.slot)),
				E('td', { 'class': 'td' }, sl.line || ''),
				E('td', { 'class': 'td' }, [
					E('button', {
						'class': 'btn',
						'click': ui.createHandlerFn(this, function() {
							return runAction({ action: 'volume-properties', slot: String(sl.slot) });
						})
					}, _('Properties')),
					' ',
					E('button', {
						'class': 'btn cbi-button-remove',
						'click': ui.createHandlerFn(this, function() {
							return runAction({ action: 'unmount', slot: String(sl.slot) }).then(function(res) {
								if (res && res.ok !== false)
									window.location.reload();
							});
						})
					}, _('Unmount')),
					' ',
					E('button', {
						'class': 'btn',
						'click': ui.createHandlerFn(this, function() {
							var parts = String(sl.line || '').trim().split(/\s+/);
							openFsck({ volume: parts[1] || '', slot: String(sl.slot) });
						})
					}, _('Check'))
				])
			]));
		});

		var nextSlot = st.next_slot || 1;
		if (nextSlot > 0) {
			table.appendChild(E('tr', { 'class': 'tr' }, [
				E('td', { 'class': 'td' }, String(nextSlot)),
				E('td', { 'class': 'td' }, _('(empty)')),
				E('td', { 'class': 'td' }, [
					E('button', {
						'class': 'btn cbi-button-apply',
						'click': ui.createHandlerFn(this, function() {
							openFilePicker(nextSlot);
						})
					}, _('Open file')),
					' ',
					E('button', {
						'class': 'btn',
						'click': ui.createHandlerFn(this, function() {
							openDevicePicker(nextSlot);
						})
					}, _('Open device'))
				])
			]));
		}
		body.appendChild(table);
		if (st.list)
			body.appendChild(E('pre', st.list));

		body.appendChild(E('p', {}, [
			E('button', {
				'class': 'btn',
				'click': ui.createHandlerFn(this, function() {
					return runAction({ action: 'list' });
				})
			}, _('List volumes')),
			' ',
			E('button', {
				'class': 'btn',
				'click': ui.createHandlerFn(this, function() {
					return runAction({ action: 'unmount' }).then(function(res) {
						if (res && res.ok !== false)
							window.location.reload();
					});
				})
			}, _('Unmount all')),
			' ',
			E('button', {
				'class': 'btn',
				'click': ui.createHandlerFn(this, function() {
					return runAction({ action: 'version' });
				})
			}, _('Version')),
			' ',
			E('button', {
				'class': 'btn',
				'click': ui.createHandlerFn(this, function() {
					return runAction({ action: 'test' });
				})
			}, _('Test algorithms')),
			' ',
			E('button', {
				'class': 'btn',
				'click': ui.createHandlerFn(this, function() {
					return runAction({ action: 'help' });
				})
			}, _('Help'))
		]));

		function actionModal(title, extraNodes, collect, initial) {
			initial = initial || {};
			var vol = pathRow(_('Volume / file'), initial.volume || '', !!initial.dirOnly);
			var mp = pathRow(_('Mount point'), initial.mountpoint || '', true);
			var fname = field('text', { 'placeholder': 'media.hc', 'value': initial.filename || '' });
			var kf = pathRow(_('Keyfiles'), '', false);
			var nkf = pathRow(_('New keyfiles'), '', false);
			var rnd = pathRow(_('Random source'), '/dev/urandom', false);
			var pw = field('password');
			var npw = field('password');
			var ppw = field('password');
			var pim = field('text', { 'placeholder': '0' });
			var npim = field('text');
			var ppim = field('text');
			var slot = slotSelect(initial.slot || '');
			var hash = select(HASHES, initial.hash || '');
			var nhash = select(HASHES, '');
			var phash = select(HASHES, '');
			var enc = select(CIPHERS, initial.encryption || '');
			var fs = select(FSTYPES, initial.filesystem || '');
			var vtype = select(VTYPES, initial.volume_type || 'normal');
			var phid = select([ [ 'no', _('No') ], [ 'yes', _('Yes') ] ], 'no');
			var size = field('text', { 'placeholder': '100M' });
			var fsopt = field('text');
			var mopt = field('text', { 'placeholder': 'nokernelcrypto' });
			var autom = field('text');
			var tlib = pathRow(_('Token library'), '', false);
			var tpin = field('password');
			var pkf = pathRow(_('Protection keyfiles'), '', false);
			var force = field('checkbox');
			var quick = field('checkbox');
			var verbose = field('checkbox');
			var nosz = field('checkbox');
			var legacy = field('checkbox');
			var insecure = field('checkbox');
			var fsckauto = field('checkbox');
			quick.checked = true;
			fsckauto.checked = true;
			if (initial.size)
				size.value = initial.size;

			var nodes = [
				E('p', _('Console flags are passed as veracrypt --text --non-interactive. Passwords are not saved.'))
			];
			if (!initial.hideVolume)
				nodes.push(vol.node);
			if (initial.showFilename)
				nodes.push(E('div', { 'class': 'cbi-value' }, [
					E('label', { 'class': 'cbi-value-title' }, _('Container file name')),
					E('div', { 'class': 'cbi-value-field' }, fname)
				]));
			if (!initial.hideMount)
				nodes.push(mp.node);
			if (!initial.hideKeyfiles)
				nodes.push(kf.node);
			nodes = nodes.concat(extraNodes({
				vol: vol, mp: mp, kf: kf, nkf: nkf, rnd: rnd, pw: pw, npw: npw, ppw: ppw,
				pim: pim, npim: npim, ppim: ppim, slot: slot, hash: hash, nhash: nhash,
				phash: phash, enc: enc, fs: fs, vtype: vtype, phid: phid, size: size,
				fsopt: fsopt, mopt: mopt, autom: autom, tlib: tlib, tpin: tpin, pkf: pkf,
				force: force, quick: quick, verbose: verbose, nosz: nosz, legacy: legacy,
				insecure: insecure, fname: fname, fsckauto: fsckauto
			}));
			if (!initial.hideSlot)
				nodes.push(E('div', { 'class': 'cbi-value' }, [
					E('label', { 'class': 'cbi-value-title' }, _('Slot (1–64)')),
					E('div', { 'class': 'cbi-value-field' }, slot)
				]));
			if (!initial.hideFlags)
				nodes.push(E('div', { 'class': 'cbi-value' }, [
					E('label', { 'class': 'cbi-value-title' }, _('Force / verbose / quick / no-size-check / legacy password / allow insecure mount')),
					E('div', { 'class': 'cbi-value-field' }, [
						E('label', {}, [ force, ' ', _('force') ]), ' ',
						E('label', {}, [ verbose, ' ', _('verbose') ]), ' ',
						E('label', {}, [ quick, ' ', _('quick') ]), ' ',
						E('label', {}, [ nosz, ' ', _('no-size-check') ]), ' ',
						E('label', {}, [ legacy, ' ', _('legacy-password-maxlength') ]), ' ',
						E('label', {}, [ insecure, ' ', _('allow-insecure-mount') ])
					])
				]));
			nodes.push(E('div', { 'class': 'right' }, [
					E('button', { 'class': 'btn', 'click': ui.hideModal }, _('Cancel')),
					' ',
					E('button', {
						'class': 'btn cbi-button-apply',
						'click': ui.createHandlerFn(this, function() {
							var o = collect({
								vol: vol, mp: mp, kf: kf, nkf: nkf, rnd: rnd, pw: pw, npw: npw, ppw: ppw,
								pim: pim, npim: npim, ppim: ppim, slot: slot, hash: hash, nhash: nhash,
								phash: phash, enc: enc, fs: fs, vtype: vtype, phid: phid, size: size,
								fsopt: fsopt, mopt: mopt, autom: autom, tlib: tlib, tpin: tpin, pkf: pkf,
								force: force, quick: quick, verbose: verbose, nosz: nosz, legacy: legacy,
								insecure: insecure, fsckauto: fsckauto
							});
							o.volume = vol.getValue();
							o.mountpoint = mp.getValue();
							o.keyfiles = kf.getValue();
							o.new_keyfiles = nkf.getValue();
							o.random_source = rnd.getValue();
							o.password = val(pw);
							o.new_password = val(npw);
							o.protection_password = val(ppw);
							o.pim = val(pim);
							o.new_pim = val(npim);
							o.protection_pim = val(ppim);
							o.slot = val(slot);
							o.hash = val(hash);
							o.new_hash = val(nhash);
							o.protection_hash = val(phash);
							o.encryption = val(enc);
							o.filesystem = val(fs);
							o.volume_type = val(vtype);
							o.protect_hidden = val(phid);
							o.size = val(size);
							o.fs_options = val(fsopt);
							o.mount_options = val(mopt);
							o.auto_mount = val(autom);
							o.token_lib = tlib.getValue();
							o.token_pin = val(tpin);
							o.protection_keyfiles = pkf.getValue();
							o.force = flag(force);
							o.quick = flag(quick);
							o.verbose = flag(verbose);
							o.no_size_check = flag(nosz);
							o.legacy_password_maxlength = flag(legacy);
							o.allow_insecure_mount = flag(insecure);
							o.fsck_auto = flag(fsckauto) ? '1' : '0';
							if (o.action === 'create') {
								var fn = val(fname) || initial.filename || 'media.hc';
								o.volume = String(o.volume || '/mnt').replace(/\/+$/, '') + '/' + fn.replace(/^\/+/, '');
								if (!o.size)
									o.size = '100M';
								o.slot = '';
								o.mountpoint = '';
								o.protect_hidden = '';
								o.mount_options = '';
							}
							if (o.action === 'mount') {
								o.encryption = '';
								o.hash = '';
								o.size = '';
								o.volume_type = '';
								o.quick = '';
								if (!o.mount_options)
									o.mount_options = 'nokernelcrypto';
							}
							if (o.action === 'fsck') {
								o.mountpoint = '';
								o.encryption = '';
								o.hash = '';
								o.size = '';
								o.volume_type = '';
								o.quick = '';
								if (!o.mount_options)
									o.mount_options = 'nokernelcrypto';
								if (!o.protect_hidden)
									o.protect_hidden = 'no';
								if (!o.pim)
									o.pim = '0';
							}
							ui.hideModal();
							return ensureFsPackages(o).then(function(go) {
								if (!go)
									return;
								return ensureFsckPackages(o).then(function(go2) {
									if (!go2)
										return;
									return runAction(o).then(function(res) {
										if (res && res.ok !== false && (o.action === 'mount' || o.action === 'unmount' || o.action === 'create' || o.action === 'fsck'))
											window.location.reload();
									});
								});
							});
						})
					}, _('Run'))
			]));
			ui.showModal(title, nodes);
		}

		function mountExtras(f) {
			return [
				E('p', _('Opening reads cipher and hash from the volume header. Password is required; PIM and keyfiles only if the volume was created with them.')),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Password')), E('div', { 'class': 'cbi-value-field' }, f.pw) ]),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('PIM (empty = default)')), E('div', { 'class': 'cbi-value-field' }, f.pim) ]),
				E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Mount options')), E('div', { 'class': 'cbi-value-field' }, f.mopt) ])
			];
		}

		function openFsck(initial) {
			actionModal(_('Check filesystem'), function(f) {
				return [
					E('p', _('Decrypts without mounting (veracrypt --filesystem=none), lists the mapper or loop device (veracrypt -l), runs fsck -f on that device, then dismounts. Unmount the volume first if it is mounted. Default is automatic yes to all prompts; uncheck for interactive y/n.')),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Password')), E('div', { 'class': 'cbi-value-field' }, f.pw) ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('PIM (empty = default)')), E('div', { 'class': 'cbi-value-field' }, f.pim) ]),
					E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Inner filesystem (optional hint)')), E('div', { 'class': 'cbi-value-field' }, f.fs) ]),
					E('div', { 'class': 'cbi-value' }, [
						E('label', { 'class': 'cbi-value-title' }, _('Automatic yes')),
						E('div', { 'class': 'cbi-value-field' }, [
							E('label', {}, [ f.fsckauto, ' ', _('Yes to all fsck prompts (default). Uncheck to answer y or n.') ])
						])
					])
				];
			}, function() { return { action: 'fsck' }; }, {
				volume: (initial && initial.volume) || '',
				slot: (initial && initial.slot) || '',
				hideMount: true,
				hideFlags: true
			});
		}

		function openFilePicker(slotNo) {
			var fu = new ui.FileUpload('', {
				root_directory: '/',
				initial_directory: '/mnt',
				show_hidden: true,
				enable_upload: false,
				enable_remove: false,
				enable_download: false,
				directory_create: true,
				directory_select: false
			});
			Promise.resolve(fu.render()).then(function(el) {
				ui.showModal(_('Open file'), [
					E('p', _('Go up with the parent folder, into a folder by name, then select the container.')),
					el,
					E('div', { 'class': 'right' }, [
						E('button', { 'class': 'btn', 'click': ui.hideModal }, _('Cancel')),
						' ',
						E('button', {
							'class': 'btn cbi-button-apply',
							'click': function() {
								var p = fu.getValue();
								ui.hideModal();
								if (!p)
									return;
								actionModal(_('Mount'), mountExtras, function() {
									return { action: 'mount' };
								}, { volume: p, slot: String(slotNo) });
							}
						}, _('Use file'))
					])
				]);
			});
		}

		function openDevicePicker(slotNo) {
			function usePath(p) {
				ui.hideModal();
				actionModal(_('Mount'), mountExtras, function() {
					return { action: 'mount' };
				}, { volume: p, slot: String(slotNo) });
			}
			ui.showModal(_('Open device'), [ E('p', _('Loading block devices…')) ]);
			return callListDev().then(function(res) {
				var devs = (res && res.devices) || [];
				var rows = [ E('p', _('Block devices (/dev/sd*, nvme, mmc, mapper, and other /sys/class/block nodes)')) ];
				if (!devs.length)
					rows.push(E('p', _('No nodes under /sys/class/block. You can still browse /dev.')));
				devs.forEach(function(d) {
					rows.push(E('div', {}, [
						E('button', {
							'class': 'btn',
							'style': 'margin:2px',
							'click': function() { usePath(d.path); }
						}, d.path)
					]));
				});
				var fu = new ui.FileUpload('/dev', {
					root_directory: '/dev',
					initial_directory: '/dev',
					show_hidden: true,
					enable_upload: false,
					enable_remove: false,
					enable_download: false,
					directory_create: false,
					directory_select: false
				});
				rows.push(E('p', _('Or browse /dev:')));
				var holder = E('div');
				rows.push(holder);
				Promise.resolve(fu.render()).then(function(el) { holder.appendChild(el); });
				rows.push(E('div', { 'class': 'right' }, [
					E('button', { 'class': 'btn', 'click': ui.hideModal }, _('Cancel')),
					' ',
					E('button', {
						'class': 'btn cbi-button-apply',
						'click': function() {
							var p = fu.getValue();
							if (p)
								usePath(p);
						}
					}, _('Use selected /dev node'))
				]));
				ui.showModal(_('Open device'), rows);
			}).catch(function(err) {
				ui.hideModal();
				ui.addNotification(null, E('p', err.message || String(err)), 'error');
			});
		}

		body.appendChild(E('h3', _('Operations')));
		body.appendChild(E('p', {}, [
			E('button', { 'class': 'btn cbi-button-apply', 'click': function() {
				actionModal(_('Mount'), mountExtras, function() { return { action: 'mount' }; }, { slot: String(nextSlot || 1) });
			} }, _('Mount…')),
			' ',
			E('button', { 'class': 'btn', 'click': function() {
				openFsck({ slot: String(nextSlot || 1) });
			} }, _('Check filesystem…')),
			' ',
			E('button', { 'class': 'btn', 'click': function() {
				actionModal(_('Create volume'), function(f) {
					return [
						E('p', _('Folder + file name become the container path. After create, the volume is mounted on /mnt/<name> in the next free slot. Defaults: AES-Twofish-Serpent, SHA-512, size 100M. For ext4/vfat the app can apk add lvm2 and e2fsprogs if you agree.')),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Password')), E('div', { 'class': 'cbi-value-field' }, f.pw) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('PIM (0 = VeraCrypt default)')), E('div', { 'class': 'cbi-value-field' }, f.pim) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Size (--size)')), E('div', { 'class': 'cbi-value-field' }, f.size) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Volume type')), E('div', { 'class': 'cbi-value-field' }, f.vtype) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Encryption')), E('div', { 'class': 'cbi-value-field' }, f.enc) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Hash')), E('div', { 'class': 'cbi-value-field' }, f.hash) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Filesystem')), E('div', { 'class': 'cbi-value-field' }, f.fs) ]),
						f.rnd.node
					];
				}, function() { return { action: 'create' }; }, {
					encryption: 'AES-Twofish-Serpent',
					hash: 'sha-512',
					volume_type: 'normal',
					filesystem: 'none',
					dirOnly: true,
					hideMount: true,
					hideKeyfiles: true,
					hideSlot: true,
					showFilename: true,
					volume: '/mnt',
					filename: 'media.hc',
					size: '100M'
				});
			} }, _('Create…')),
			' ',
			E('button', { 'class': 'btn', 'click': function() {
				actionModal(_('Change password / keyfiles'), function(f) {
					return [
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Current password')), E('div', { 'class': 'cbi-value-field' }, f.pw) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('New password')), E('div', { 'class': 'cbi-value-field' }, f.npw) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('PIM / new PIM')), E('div', { 'class': 'cbi-value-field' }, [ f.pim, f.npim ]) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Hash / new hash')), E('div', { 'class': 'cbi-value-field' }, [ f.hash, f.nhash ]) ]),
						f.nkf.node
					];
				}, function() { return { action: 'change' }; });
			} }, _('Change…')),
			' ',
			E('button', { 'class': 'btn', 'click': function() {
				actionModal(_('Backup headers'), function() { return []; }, function() { return { action: 'backup-headers' }; });
			} }, _('Backup headers…')),
			' ',
			E('button', { 'class': 'btn', 'click': function() {
				actionModal(_('Restore headers'), function() { return []; }, function() { return { action: 'restore-headers' }; });
			} }, _('Restore headers…')),
			' ',
			E('button', { 'class': 'btn', 'click': function() {
				actionModal(_('Create keyfile'), function(f) {
					return [ E('p', _('Keyfile path is the Volume / file field.')), f.rnd.node ];
				}, function() { return { action: 'create-keyfile' }; });
			} }, _('Create keyfile…')),
			' ',
			E('button', { 'class': 'btn', 'click': function() {
				actionModal(_('Volume properties'), function() { return []; }, function() { return { action: 'volume-properties' }; });
			} }, _('Properties…')),
			' ',
			E('button', { 'class': 'btn', 'click': function() {
				actionModal(_('Auto-mount'), function(f) {
					return [ E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('--auto-mount')), E('div', { 'class': 'cbi-value-field' }, f.autom) ]),
						E('div', { 'class': 'cbi-value' }, [ E('label', { 'class': 'cbi-value-title' }, _('Password')), E('div', { 'class': 'cbi-value-field' }, f.pw) ]) ];
				}, function() { return { action: 'auto-mount' }; });
			} }, _('Auto-mount…')),
			' ',
			E('button', { 'class': 'btn', 'click': function() {
				var lib = uci.get('veracrypt', 'main', 'token_lib') || '';
				if (!lib) {
					ui.addNotification(null, E('p',
						_('No PKCS #11 library path is set. Use Timeouts → Security token library (example: /usr/lib/libykcs11.so). This LuCI app has no Settings > Security Tokens.')
					), 'warning');
					return;
				}
				return runAction({ action: 'list-token-keyfiles', token_lib: lib });
			} }, _('List token keyfiles'))
		]));

		m = new form.Map('veracrypt', _('Favorite volumes'),
			_('Saved volume paths. Use Browse to pick a container or mount directory. Slot is 1–64. Passwords are not stored.'));

		s = m.section(form.NamedSection, 'main', 'settings', _('Timeouts'));
		s.addremove = false;
		s.anonymous = false;
		o = s.option(form.Value, 'timeout', _('XHR / operation timeout (seconds)'));
		o.datatype = 'and(uinteger,min(300))';
		o.placeholder = '300';
		o.default = '300';
		o.description = _('Minimum 300 (5 minutes). Header derivation and random generation on a slow chipset with little RAM can take much longer. Save & Apply before the next mount or create.');

		o = s.option(form.FileUpload, 'token_lib', _('Security token library (PKCS #11)'));
		o.root_directory = '/';
		o.show_hidden = true;
		o.enable_upload = false;
		o.enable_remove = false;
		o.optional = true;
		o.description = _('Optional. Path to a PKCS #11 .so (for example /usr/lib/libykcs11.so). Leave empty if you do not use a token.');

		s = m.section(form.GridSection, 'volume', _('Favorites'));
		s.anonymous = false;
		s.addremove = true;
		s.nodescriptions = true;
		s.addbtntitle = _('Add favorite');

		o = s.option(form.DummyValue, '_state', _('State'));
		o.modalonly = false;
		o.textvalue = function(sid) {
			var stv = status[sectionName(sid)];
			return stv && stv.mounted ? _('Mounted') : _('Dismounted');
		};

		o = s.option(form.FileUpload, 'volume', _('Volume file'));
		o.root_directory = '/';
		o.show_hidden = true;
		o.enable_upload = false;
		o.enable_remove = false;
		o.enable_download = false;
		o.directory_create = true;
		o.rmempty = false;
		o.editable = true;

		o = s.option(form.FileUpload, 'mountpoint', _('Mount point'));
		o.root_directory = '/';
		o.show_hidden = true;
		o.enable_upload = false;
		o.enable_remove = false;
		o.directory_create = true;
		o.directory_select = true;
		o.rmempty = false;
		o.editable = true;

		o = s.option(form.ListValue, 'slot', _('Slot'));
		o.value('', _('(auto)'));
		for (var i = 1; i <= 64; i++)
			o.value(String(i), String(i));
		o.modalonly = true;

		o = s.option(form.Flag, 'nokernelcrypto', _('No kernel crypto'));
		o.default = '1';
		o.modalonly = true;

		o = s.option(form.Value, 'mount_options', _('Mount options (-m)'));
		o.placeholder = 'nokernelcrypto';
		o.modalonly = true;

		o = s.option(form.Value, 'pim', _('PIM'));
		o.datatype = 'uinteger';
		o.placeholder = '0';
		o.modalonly = true;

		o = s.option(form.ListValue, 'protect_hidden', _('Protect hidden volume'));
		o.value('no', _('No'));
		o.value('yes', _('Yes'));
		o.default = 'no';
		o.modalonly = true;

		o = s.option(form.FileUpload, 'keyfiles', _('Keyfiles'));
		o.root_directory = '/';
		o.show_hidden = true;
		o.enable_upload = false;
		o.enable_remove = false;
		o.modalonly = true;

		o = s.option(form.ListValue, 'hash', _('Hash'));
		HASHES.forEach(function(h) { if (h) o.value(h, h); });
		o.optional = true;
		o.modalonly = true;

		o = s.option(form.ListValue, 'encryption', _('Encryption'));
		CIPHERS.forEach(function(c) { if (c) o.value(c, c); });
		o.optional = true;
		o.modalonly = true;

		o = s.option(form.Value, 'filesystem', _('Filesystem'));
		o.placeholder = 'ext4';
		o.modalonly = true;

		o = s.option(form.Flag, 'truecrypt', _('TrueCrypt mode'));
		o.modalonly = true;

		o = s.option(form.DummyValue, '_actions', _('Actions'));
		o.modalonly = false;
		o.rawhtml = true;
		o.textvalue = function(sid) {
			var name = sectionName(sid);
			var stv = status[name];
			var mounted = stv && stv.mounted;
			var wrap = E('span', { 'style': 'white-space:nowrap' });
			if (mounted) {
				wrap.appendChild(E('button', {
					'class': 'btn cbi-button-remove',
					'click': ui.createHandlerFn(this, function() {
						return runAction({ action: 'unmount', name: name }).then(function(res) {
							if (res && res.ok !== false)
								window.location.reload();
						});
					})
				}, _('Unmount')));
			}
			else {
				wrap.appendChild(E('button', {
					'class': 'btn cbi-button-apply',
					'click': ui.createHandlerFn(this, function() {
						var pw = field('password');
						ui.showModal(_('Mount %s').format(name), [
							E('p', uci.get('veracrypt', sid, 'volume') || ''),
							pw,
							E('div', { 'class': 'right' }, [
								E('button', { 'class': 'btn', 'click': ui.hideModal }, _('Cancel')),
								' ',
								E('button', {
									'class': 'btn cbi-button-apply',
									'click': ui.createHandlerFn(this, function() {
										ui.hideModal();
										return runAction({ action: 'mount', name: name, password: val(pw) }).then(function(res) {
											if (res && res.ok !== false)
												window.location.reload();
										});
									})
								}, _('Mount'))
							])
						]);
					})
				}, _('Mount')));
				wrap.appendChild(E('span', {}, ' '));
				wrap.appendChild(E('button', {
					'class': 'btn',
					'click': ui.createHandlerFn(this, function() {
						openFsck({
							volume: uci.get('veracrypt', sid, 'volume') || '',
							slot: uci.get('veracrypt', sid, 'slot') || ''
						});
					})
				}, _('Check')));
			}
			return wrap;
		};

		return m.render().then(function(node) {
			body.appendChild(node);
			return body;
		});
	}
});
