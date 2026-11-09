let mocklib = global.mocklib; // ucode-lsp disable

let _error = null; // ucode-lsp disable

return {
	connect: function() {
		return {
			call: (object, method, args) => {
				let signature = [ object + "~" + method ];

				if (type(args) == "object") {
					for (let i, k in sort(keys(args))) {
						switch (type(args[k])) {
						case "string":
						case "double":
						case "bool":
						case "int":
							push(signature, k + "-" + replace(args[k], /[^A-Za-z0-9_-]+/g, "_"));
							break;

						default:
							push(signature, type(args[k]));
						}
					}
				}

				let candidates = [];

				for (let i = length(signature); i > 0; i--) {
					let path = sprintf("ubus/%s.json", join("~", signature)),
					    mock = mocklib.read_json_file(path);

					if (mock != mock) {
						_error = "Invalid argument";

						return null;
					}
					else if (mock) {
						mocklib.trace_call("ctx", "call", { object, method, args });

						return mock;
					}

					push(candidates, path);
					pop(signature);
				}

				_error = "Method not found";

				return null;
			},

			disconnect: () => null,

			error: () => {
				let e = _error;
				_error = null;

				return e;
			}
		};
	},

	error: function() {
		let e = _error;
		_error = null;

		return e;
	}
};
