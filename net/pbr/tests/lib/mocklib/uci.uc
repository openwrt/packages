let mocklib = global.mocklib; // ucode-lsp disable

let byte = (str, off) => { // ucode-lsp disable
	let v = ord(str, off);
	return type(v) == 'array' ? v[0] : v;
};

let hash = (s) => { // ucode-lsp disable
	let h = 7;

	for (let i = 0; i < length(s); i++)
		h = h * 31 + byte(s, i);

	return h;
};

let id = (config, t, n) => { // ucode-lsp disable
	while (true) {
		let id = sprintf('cfg%08x', hash(t + n));

		if (!exists(config, id))
			return id;

		n++;
	}
};

let fixup_config = (config) => { // ucode-lsp disable
	let rv = {};
	let n_section = 0;

	for (let stype in config) {
		switch (type(config[stype])) {
		case 'object':
			config[stype] = [ config[stype] ];
			/* fall through */

		case 'array':
			for (let idx, sobj in config[stype]) {
				let sid, anon;

				if (exists(sobj, '.name') && !exists(rv, sobj['.name'])) {
					sid = sobj['.name'];
					anon = false;
				}
				else {
					sid = id(rv, stype, idx);
					anon = true;
				}

				rv[sid] = {
					'.index': n_section++,
					...sobj,
					'.name': sid,
					'.type': stype,
					'.anonymous': anon
				};
			}

			break;
		}
	}

	for (let n, sid in sort(keys(rv), (a, b) => rv[a]['.index'] - rv[b]['.index']))
		rv[sid]['.index'] = n;

	return rv;
};

return {
	cursor: () => ({
		_configs: {},
		_changes: {},

		load: function(file) {
			let basename = replace(file, /^.+\//, ''),
			    path = sprintf("uci/%s.json", basename),
			    mock = mocklib.read_json_file(path);

			if (!mock || mock != mock) {
				this._configs[basename] = {};
				return null;
			}

			this._configs[basename] = fixup_config(mock);
		},

		_get_section: function(config, section) {
			if (!exists(this._configs, config)) {
				this.load(config);
			}

			let cfg = this._configs[config],
			    extended = match('' + section, /^@([A-Za-z0-9_-]+)\[(-?[0-9]+)\]$/);

			if (extended) {
				let stype = extended[1],
				    sindex = +extended[2];

				let sids = sort(
					filter(keys(cfg), sid => cfg[sid]['.type'] == stype),
					(a, b) => cfg[a]['.index'] - cfg[b]['.index']
				);

				if (sindex < 0)
					sindex = length(sids) + sindex;

				return cfg[sids[sindex]];
			}

			return cfg[section];
		},

		get: function(config, section, option) {
			let sobj = this._get_section(config, section);

			if (option && index(option, ".") == 0)
				return null;
			else if (sobj && option)
				return sobj[option];
			else if (sobj)
				return sobj[".type"];
		},

		get_all: function(config, section) {
			return section ? this._get_section(config, section) : this._configs[config];
		},

		set: function(config, section, option, value) {
			if (!exists(this._configs, config))
				this.load(config);

			if (value == null) {
				/* set(config, section, stype) — set section type */
				return;
			}

			let sobj = this._get_section(config, section);
			if (!sobj) {
				/* Create section if it doesn't exist */
				this._configs[config][section] = {
					'.name': section,
					'.type': 'unknown',
					'.anonymous': false,
					'.index': length(keys(this._configs[config]))
				};
				sobj = this._configs[config][section];
			}
			sobj[option] = value;

			if (!this._changes[config])
				this._changes[config] = [];
			push(this._changes[config], { op: 'set', section, option, value });
		},

		'delete': function(config, section, option) {
			if (!exists(this._configs, config))
				this.load(config);

			if (option) {
				let sobj = this._get_section(config, section);
				if (sobj) delete sobj[option];
			} else {
				delete this._configs[config][section];
			}

			if (!this._changes[config])
				this._changes[config] = [];
			push(this._changes[config], { op: 'delete', section, option });
		},

		add: function(config, stype, name) {
			if (!exists(this._configs, config))
				this.load(config);

			let sid = name || id(this._configs[config], stype, 0);
			this._configs[config][sid] = {
				'.name': sid,
				'.type': stype,
				'.anonymous': !name,
				'.index': length(keys(this._configs[config]))
			};

			if (!this._changes[config])
				this._changes[config] = [];
			push(this._changes[config], { op: 'add', stype, name: sid });

			return sid;
		},

		list_append: function(config, section, option, value) {
			if (!exists(this._configs, config))
				this.load(config);

			let sobj = this._get_section(config, section);
			if (!sobj) return;

			let current = sobj[option];
			if (type(current) == 'array')
				push(current, value);
			else if (current != null)
				sobj[option] = [current, value];
			else
				sobj[option] = [value];

			if (!this._changes[config])
				this._changes[config] = [];
			push(this._changes[config], { op: 'list_append', section, option, value });
		},

		/* Remove a single value from a list option, leaving the rest of the
		   list intact -- the counterpart of list_append(), and what real uci
		   does for `del_list`.

		   Two fidelity details, both measured against ucode 85922056 rather
		   than assumed: delete() above deliberately ignores a fourth
		   argument, exactly as the C implementation does, so a test that
		   passes one still sees the whole option disappear; and list_remove()
		   does nothing at all to an option holding a plain string rather than
		   a list, returning true and leaving the value in place. */
		list_remove: function(config, section, option, value) {
			if (!exists(this._configs, config))
				this.load(config);

			let sobj = this._get_section(config, section);
			if (!sobj) return;

			let current = sobj[option];
			if (type(current) == 'array')
				sobj[option] = filter(current, v => v != value);

			if (!this._changes[config])
				this._changes[config] = [];
			push(this._changes[config], { op: 'list_remove', section, option, value });
		},

		save: function(config) {
			/* No-op in mock: changes are already in memory */
		},

		commit: function(config) {
			/* Clear changes for this config */
			this._changes[config] = [];
		},

		changes: function(config) {
			return this._changes[config] || [];
		},

		reorder: function(config, section, index) {
			/* No-op in mock */
		},

		foreach: function(config, stype, cb) {
			let rv = false;

			if (exists(this._configs, config)) {
				let cfg = this._configs[config],
				    sids = sort(keys(cfg), (a, b) => cfg[a]['.index'] - cfg[b]['.index']);

				for (let i, sid in sids) {
					if (stype == null || cfg[sid]['.type'] == stype) {
						if (cb({ ...(cfg[sid]) }) === false)
							break;

						rv = true;
					}
				}
			}

			return rv;
		}
	})
};
